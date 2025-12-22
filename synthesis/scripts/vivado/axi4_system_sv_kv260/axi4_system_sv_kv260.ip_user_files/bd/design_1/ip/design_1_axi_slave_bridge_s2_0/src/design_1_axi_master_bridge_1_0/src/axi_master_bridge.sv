//==============================================================================
// AXI Master Bridge
//==============================================================================
// Bridge between Zynq PS AXI Master (AXI4 GP) and Custom AXI Interconnect
// Purpose: Protocol conversion/adapter for connecting PS to AXI Interconnect
//
// Features:
//   - AXI4 GP (General Purpose) to AXI4 Full conversion
//   - Signal mapping and pass-through
//   - ID signal handling (stores AWID/ARID and returns with responses)
//   - Optional signals handling (lock, cache, prot, qos, region, user)
//
// Note: This bridge handles ID signals for Zynq PS compatibility. Since
//       AXI Interconnect doesn't use ID signals, they are stored and returned
//       with responses to maintain AXI protocol compliance.
//==============================================================================

`timescale 1ns/1ps

module axi_master_bridge #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 32,
    parameter integer ID_WIDTH = 16  // AXI ID width (for Zynq PS compatibility)
)(
    // Global signals
    input logic                          ACLK,
    input logic                          ARESETN,
    
    // ========================================================================
    // Slave AXI Interface (from Zynq PS - M_AXI_HPM0_FPD or M_AXI_HPM1_FPD)
    // AXI4 GP (General Purpose) with full AXI4 signals
    // ========================================================================
    // Write Address Channel
    input  logic [ID_WIDTH-1:0]          s_axi_awid,    // Write Address ID
    input  logic [ADDR_WIDTH-1:0]        s_axi_awaddr,
    input  logic [7:0]                   s_axi_awlen,
    input  logic [2:0]                   s_axi_awsize,
    input  logic [1:0]                   s_axi_awburst,
    input  logic [0:0]                   s_axi_awlock,
    input  logic [3:0]                   s_axi_awcache,
    input  logic [2:0]                   s_axi_awprot,
    input  logic [3:0]                   s_axi_awqos,
    input  logic [3:0]                   s_axi_awregion,
    input  logic [15:0]                  s_axi_awuser,  // Optional: User signals
    input  logic                         s_axi_awvalid,
    output logic                         s_axi_awready,
    
    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]        s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0]    s_axi_wstrb,
    input  logic                         s_axi_wlast,
    input  logic [15:0]                  s_axi_wuser,  // Optional: User signals
    input  logic                         s_axi_wvalid,
    output logic                         s_axi_wready,
    
    // Write Response Channel
    output logic [ID_WIDTH-1:0]          s_axi_bid,     // Write Response ID
    output logic [1:0]                   s_axi_bresp,
    output logic [15:0]                  s_axi_buser,  // Optional: User signals
    output logic                         s_axi_bvalid,
    input  logic                         s_axi_bready,
    
    // Read Address Channel
    input  logic [ID_WIDTH-1:0]          s_axi_arid,    // Read Address ID
    input  logic [ADDR_WIDTH-1:0]        s_axi_araddr,
    input  logic [7:0]                   s_axi_arlen,
    input  logic [2:0]                   s_axi_arsize,
    input  logic [1:0]                   s_axi_arburst,
    input  logic [0:0]                   s_axi_arlock,
    input  logic [3:0]                   s_axi_arcache,
    input  logic [2:0]                   s_axi_arprot,
    input  logic [3:0]                   s_axi_arqos,
    input  logic [3:0]                   s_axi_arregion,
    input  logic [15:0]                  s_axi_aruser,  // Optional: User signals
    input  logic                         s_axi_arvalid,
    output logic                         s_axi_arready,
    
    // Read Data Channel
    output logic [ID_WIDTH-1:0]          s_axi_rid,     // Read Data ID
    output logic [DATA_WIDTH-1:0]        s_axi_rdata,
    output logic [1:0]                   s_axi_rresp,
    output logic                         s_axi_rlast,
    output logic [15:0]                  s_axi_ruser,  // Optional: User signals
    output logic                         s_axi_rvalid,
    input  logic                         s_axi_rready,
    
    // ========================================================================
    // Master AXI Interface (to AXI Interconnect - M0 or M1)
    // AXI4 Full interface (matches AXI_Interconnect module format)
    // ========================================================================
    // Write Address Channel
    output logic [ADDR_WIDTH-1:0]        m_axi_awaddr,
    output logic [7:0]                   m_axi_awlen,
    output logic [2:0]                   m_axi_awsize,
    output logic [1:0]                   m_axi_awburst,
    output logic                         m_axi_awvalid,
    input  logic                         m_axi_awready,
    
    // Write Data Channel
    output logic [DATA_WIDTH-1:0]        m_axi_wdata,
    output logic [(DATA_WIDTH/8)-1:0]    m_axi_wstrb,
    output logic                         m_axi_wlast,
    output logic                         m_axi_wvalid,
    input  logic                         m_axi_wready,
    
    // Write Response Channel
    input  logic [1:0]                   m_axi_bresp,
    input  logic                         m_axi_bvalid,
    output logic                         m_axi_bready,
    
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]        m_axi_araddr,
    output logic [7:0]                   m_axi_arlen,
    output logic [2:0]                   m_axi_arsize,
    output logic [1:0]                   m_axi_arburst,
    output logic                         m_axi_arvalid,
    input  logic                         m_axi_arready,
    
    // Read Data Channel
    input  logic [DATA_WIDTH-1:0]        m_axi_rdata,
    input  logic [1:0]                   m_axi_rresp,
    input  logic                         m_axi_rlast,
    input  logic                         m_axi_rvalid,
    output logic                         m_axi_rready
);

//==============================================================================
// ID Storage Registers
// Store IDs from address channels to return with responses
//==============================================================================
logic [ID_WIDTH-1:0] awid_reg, arid_reg;

// Store AWID when write address transaction is accepted
always_ff @(posedge ACLK) begin
    if (~ARESETN) begin
        awid_reg <= {ID_WIDTH{1'b0}};
    end else if (s_axi_awvalid && s_axi_awready) begin
        awid_reg <= s_axi_awid;
    end
end

// Store ARID when read address transaction is accepted
always_ff @(posedge ACLK) begin
    if (~ARESETN) begin
        arid_reg <= {ID_WIDTH{1'b0}};
    end else if (s_axi_arvalid && s_axi_arready) begin
        arid_reg <= s_axi_arid;
    end
end

//==============================================================================
// Write Address Channel - Pass through (drop optional signals)
//==============================================================================
assign m_axi_awaddr  = s_axi_awaddr;
assign m_axi_awlen   = s_axi_awlen;
assign m_axi_awsize  = s_axi_awsize;
assign m_axi_awburst = s_axi_awburst;
assign m_axi_awvalid = s_axi_awvalid;
assign s_axi_awready = m_axi_awready;

// Note: Dropping s_axi_awid, s_axi_awlock, s_axi_awcache, s_axi_awprot, 
//       s_axi_awqos, s_axi_awregion, s_axi_awuser as they are not used by 
//       AXI Interconnect. AWID is stored in awid_reg for response matching.

//==============================================================================
// Write Data Channel - Pass through
//==============================================================================
assign m_axi_wdata  = s_axi_wdata;
assign m_axi_wstrb  = s_axi_wstrb;
assign m_axi_wlast  = s_axi_wlast;
assign m_axi_wvalid = s_axi_wvalid;
assign s_axi_wready = m_axi_wready;

// Note: Dropping s_axi_wuser as it's not used by AXI Interconnect

//==============================================================================
// Write Response Channel - Pass through with ID matching
//==============================================================================
assign s_axi_bid    = awid_reg;  // Return stored AWID with write response
assign s_axi_bresp  = m_axi_bresp;
assign s_axi_bvalid = m_axi_bvalid;
assign m_axi_bready = s_axi_bready;

// Note: Setting s_axi_buser to 0 (not used by PS)
assign s_axi_buser = 16'h0;

//==============================================================================
// Read Address Channel - Pass through (drop optional signals)
//==============================================================================
assign m_axi_araddr  = s_axi_araddr;
assign m_axi_arlen   = s_axi_arlen;
assign m_axi_arsize  = s_axi_arsize;
assign m_axi_arburst = s_axi_arburst;
assign m_axi_arvalid = s_axi_arvalid;
assign s_axi_arready = m_axi_arready;

// Note: Dropping s_axi_arid, s_axi_arlock, s_axi_arcache, s_axi_arprot, 
//       s_axi_arqos, s_axi_arregion, s_axi_aruser as they are not used by 
//       AXI Interconnect. ARID is stored in arid_reg for response matching.

//==============================================================================
// Read Data Channel - Pass through with ID matching
//==============================================================================
assign s_axi_rid    = arid_reg;  // Return stored ARID with read data
assign s_axi_rdata  = m_axi_rdata;
assign s_axi_rresp  = m_axi_rresp;
assign s_axi_rlast  = m_axi_rlast;
assign s_axi_rvalid = m_axi_rvalid;
assign m_axi_rready = s_axi_rready;

// Note: Setting s_axi_ruser to 0 (not used by PS)
assign s_axi_ruser = 16'h0;

endmodule

