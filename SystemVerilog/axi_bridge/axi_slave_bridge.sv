//==============================================================================
// AXI Slave Bridge
//==============================================================================
// Bridge between AXI Interconnect (AXI4 Full) and AXI4-Lite Peripherals
// Purpose: Convert AXI4 Full to AXI4-Lite
//
// Features:
//   - AXI4 Full (from AXI Interconnect) to AXI4-Lite (to peripherals)
//   - Only supports single-beat transactions (AWLEN=0, ARLEN=0)
//   - Drops burst-related signals (AWLEN, ARLEN, AWSIZE, ARSIZE, AWBURST, ARBURST)
//   - Enforces WLAST=1, RLAST=1 for AXI4-Lite compatibility
//
// Note: AXI4-Lite only supports single data transfers. Burst transactions
//       with AWLEN>0 or ARLEN>0 will be rejected with SLVERR response.
//==============================================================================

`timescale 1ns/1ps

module axi_slave_bridge #(
    parameter integer DATA_WIDTH = 32,
    parameter integer ADDR_WIDTH = 32
)(
    // Global signals
    input logic                          ACLK,
    input logic                          ARESETN,
    
    // ========================================================================
    // Slave AXI Interface (from AXI Interconnect - AXI4 Full)
    // ========================================================================
    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]        s_axi_awaddr,
    input  logic [7:0]                   s_axi_awlen,      // Burst length (AXI4 Full)
    input  logic [2:0]                   s_axi_awsize,     // Burst size (AXI4 Full)
    input  logic [1:0]                   s_axi_awburst,    // Burst type (AXI4 Full)
    input  logic                         s_axi_awvalid,
    output logic                         s_axi_awready,
    
    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]        s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0]    s_axi_wstrb,
    input  logic                         s_axi_wlast,      // Last write data (AXI4 Full)
    input  logic                         s_axi_wvalid,
    output logic                         s_axi_wready,
    
    // Write Response Channel
    output logic [1:0]                   s_axi_bresp,
    output logic                         s_axi_bvalid,
    input  logic                         s_axi_bready,
    
    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]        s_axi_araddr,
    input  logic [7:0]                   s_axi_arlen,      // Burst length (AXI4 Full)
    input  logic [2:0]                   s_axi_arsize,     // Burst size (AXI4 Full)
    input  logic [1:0]                   s_axi_arburst,    // Burst type (AXI4 Full)
    input  logic                         s_axi_arvalid,
    output logic                         s_axi_arready,
    
    // Read Data Channel
    output logic [DATA_WIDTH-1:0]        s_axi_rdata,
    output logic [1:0]                   s_axi_rresp,
    output logic                         s_axi_rlast,      // Last read data (AXI4 Full)
    output logic                         s_axi_rvalid,
    input  logic                         s_axi_rready,
    
    // ========================================================================
    // Master AXI Interface (to Peripherals - AXI4-Lite)
    // ========================================================================
    // Write Address Channel
    output logic [ADDR_WIDTH-1:0]        m_axi_awaddr,
    output logic [2:0]                   m_axi_awprot,     // Protection type (AXI4-Lite)
    output logic                         m_axi_awvalid,
    input  logic                         m_axi_awready,
    
    // Write Data Channel
    output logic [DATA_WIDTH-1:0]        m_axi_wdata,
    output logic [(DATA_WIDTH/8)-1:0]    m_axi_wstrb,
    output logic                         m_axi_wvalid,
    input  logic                         m_axi_wready,
    
    // Write Response Channel
    input  logic [1:0]                   m_axi_bresp,
    input  logic                         m_axi_bvalid,
    output logic                         m_axi_bready,
    
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]        m_axi_araddr,
    output logic [2:0]                   m_axi_arprot,     // Protection type (AXI4-Lite)
    output logic                         m_axi_arvalid,
    input  logic                         m_axi_arready,
    
    // Read Data Channel
    input  logic [DATA_WIDTH-1:0]        m_axi_rdata,
    input  logic [1:0]                   m_axi_rresp,
    input  logic                         m_axi_rvalid,
    output logic                         m_axi_rready
);

//==============================================================================
// Burst Transaction Detection
//==============================================================================
// AXI4-Lite only supports single-beat transfers (AWLEN=0, ARLEN=0)
// Accept only single-beat transactions

logic write_is_single_beat;
logic read_is_single_beat;

assign write_is_single_beat = (s_axi_awlen == 8'h00);
assign read_is_single_beat  = (s_axi_arlen == 8'h00);

// Burst rejection state machines
logic write_burst_reject;
logic read_burst_reject;
logic write_burst_bvalid;
logic read_burst_rvalid;

// Detect burst write rejection
always_ff @(posedge ACLK) begin
    if (!ARESETN) begin
        write_burst_reject <= 1'b0;
        write_burst_bvalid <= 1'b0;
    end else begin
        // Set when burst write address is accepted
        if (s_axi_awvalid && s_axi_awready && !write_is_single_beat) begin
            write_burst_reject <= 1'b1;
        end
        // Generate B response when write data is received
        if (s_axi_wvalid && s_axi_wready && write_burst_reject && !write_burst_bvalid) begin
            write_burst_bvalid <= 1'b1;
        end
        // Clear after response handshake
        if (s_axi_bvalid && s_axi_bready && write_burst_reject) begin
            write_burst_reject <= 1'b0;
            write_burst_bvalid <= 1'b0;
        end
    end
end

// Detect burst read rejection
always_ff @(posedge ACLK) begin
    if (!ARESETN) begin
        read_burst_reject <= 1'b0;
        read_burst_rvalid <= 1'b0;
    end else begin
        // Set when burst read address is accepted and generate R response immediately
        if (s_axi_arvalid && s_axi_arready && !read_is_single_beat) begin
            read_burst_reject <= 1'b1;
            read_burst_rvalid <= 1'b1;
        end
        // Clear after read response handshake
        if (s_axi_rvalid && s_axi_rready && read_burst_reject) begin
            read_burst_reject <= 1'b0;
            read_burst_rvalid <= 1'b0;
        end
    end
end

//==============================================================================
// Write Address Channel - Convert to AXI4-Lite
//==============================================================================
// AXI4-Lite: No AWLEN, AWSIZE, AWBURST
// Accept address handshake even for bursts (to reject with SLVERR)

assign m_axi_awaddr  = s_axi_awaddr;
assign m_axi_awprot  = 3'b000;  // Default protection (normal, secure, data)
assign m_axi_awvalid = s_axi_awvalid && write_is_single_beat;
// Accept address handshake for bursts too (to generate error response)
assign s_axi_awready = (m_axi_awready && write_is_single_beat) || 
                       (s_axi_awvalid && !write_is_single_beat);

// Note: Dropping s_axi_awlen, s_axi_awsize, s_axi_awburst (not in AXI4-Lite)

//==============================================================================
// Write Data Channel - Pass through
//==============================================================================
// AXI4-Lite always has single data beat, so WLAST is implicit (always 1)

assign m_axi_wdata  = s_axi_wdata;
assign m_axi_wstrb  = s_axi_wstrb;
assign m_axi_wvalid = s_axi_wvalid && write_is_single_beat;
// Accept write data for bursts too (to complete transaction and generate error)
assign s_axi_wready = (m_axi_wready && write_is_single_beat) || 
                      (s_axi_wvalid && !write_is_single_beat);

// Note: WLAST is not in AXI4-Lite (implicitly always last)

//==============================================================================
// Write Response Channel - Generate SLVERR for bursts
//==============================================================================

assign s_axi_bresp  = write_burst_reject ? 2'b10 : m_axi_bresp;  // SLVERR for bursts
assign s_axi_bvalid = write_burst_reject ? write_burst_bvalid : m_axi_bvalid;
assign m_axi_bready = s_axi_bready && !write_burst_reject;

//==============================================================================
// Read Address Channel - Convert to AXI4-Lite
//==============================================================================
// AXI4-Lite: No ARLEN, ARSIZE, ARBURST
// Accept address handshake even for bursts (to reject with SLVERR)

assign m_axi_araddr  = s_axi_araddr;
assign m_axi_arprot  = 3'b000;  // Default protection (normal, secure, data)
assign m_axi_arvalid = s_axi_arvalid && read_is_single_beat;
// Accept address handshake for bursts too (to generate error response)
assign s_axi_arready = (m_axi_arready && read_is_single_beat) || 
                      (s_axi_arvalid && !read_is_single_beat);

// Note: Dropping s_axi_arlen, s_axi_arsize, s_axi_arburst (not in AXI4-Lite)

//==============================================================================
// Read Data Channel - Generate SLVERR for bursts
//==============================================================================
// AXI4-Lite always returns single data beat, so RLAST is always 1

assign s_axi_rdata  = read_burst_reject ? 32'h0 : m_axi_rdata;
assign s_axi_rresp  = read_burst_reject ? 2'b10 : m_axi_rresp;  // SLVERR for bursts
assign s_axi_rlast  = 1'b1;  // AXI4-Lite always has single beat, so RLAST always 1
assign s_axi_rvalid = read_burst_reject ? read_burst_rvalid : m_axi_rvalid;
assign m_axi_rready = s_axi_rready && !read_burst_reject;

endmodule

