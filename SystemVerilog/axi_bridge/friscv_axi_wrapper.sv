// ==============================================================================
// F-RISCV AXI Wrapper
// ==============================================================================
// Wraps F-RISCV core (already has AXI4 interface) to provide AXI4-Lite interfaces
// F-RISCV uses AXI4 with ID, this wrapper adapts it to AXI4-Lite (no ID)
// and handles potential data width differences
// ==============================================================================

`timescale 1ns/1ps

// Note: F-RISCV uses SystemVerilog, so we need to use .sv extension
// For Verilog compatibility, we'll create a wrapper that adapts the interface

module friscv_axi_wrapper #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter AXI_ID_W = 8,
    parameter BOOT_ADDR = 0,
    parameter HART_ID = 0
)(
    // Clock and Reset
    input logic                          clk,
    input logic                          rst_n,
    
    // ========================================================================
    // Instruction AXI Master (Read-only) - AXI4-Lite
    // ========================================================================
    output logic [ADDR_WIDTH-1:0]         m_axi_instr_araddr,
    output logic [2:0]                    m_axi_instr_arprot,
    output logic                          m_axi_instr_arvalid,
    input logic                          m_axi_instr_arready,
    input logic [DATA_WIDTH-1:0]         m_axi_instr_rdata,
    input logic [1:0]                    m_axi_instr_rresp,
    input logic                          m_axi_instr_rvalid,
    output logic                          m_axi_instr_rready,
    
    // ========================================================================
    // Data AXI Master (Read/Write) - AXI4-Lite
    // ========================================================================
    // Write Address Channel
    output logic [ADDR_WIDTH-1:0]         m_axi_data_awaddr,
    output logic [2:0]                    m_axi_data_awprot,
    output logic                          m_axi_data_awvalid,
    input logic                          m_axi_data_awready,
    // Write Data Channel
    output logic [DATA_WIDTH-1:0]         m_axi_data_wdata,
    output logic [3:0]                    m_axi_data_wstrb,
    output logic                          m_axi_data_wvalid,
    input logic                          m_axi_data_wready,
    // Write Response Channel
    input logic [1:0]                    m_axi_data_bresp,
    input logic                          m_axi_data_bvalid,
    output logic                          m_axi_data_bready,
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]         m_axi_data_araddr,
    output logic [2:0]                    m_axi_data_arprot,
    output logic                          m_axi_data_arvalid,
    input logic                          m_axi_data_arready,
    // Read Data Channel
    input logic [DATA_WIDTH-1:0]         m_axi_data_rdata,
    input logic [1:0]                    m_axi_data_rresp,
    input logic                          m_axi_data_rvalid,
    output logic                          m_axi_data_rready,
    
    // ========================================================================
    // Debug Signals
    // ========================================================================
    output logic [31:0]                   debug_pc,
    output logic [31:0]                   debug_r1,
    output logic [31:0]                   debug_r2,
    output logic                          debug_zero
);

// ==============================================================================
// Internal AXI4 Signals (with ID) - for F-RISCV core
// ==============================================================================
// Instruction AXI4 (with ID)
logic imem_arvalid;
logic imem_arready;
logic [ADDR_WIDTH-1:0]     imem_araddr;
logic [2:0]                imem_arprot;
logic [AXI_ID_W-1:0]       imem_arid;
logic imem_rvalid;
logic imem_rready;
logic [AXI_ID_W-1:0]       imem_rid;
logic [1:0]                imem_rresp;
logic [DATA_WIDTH-1:0]     imem_rdata;  // Note: F-RISCV may use wider bus

// Data AXI4 (with ID)
logic dmem_awvalid;
logic dmem_awready;
logic [ADDR_WIDTH-1:0]     dmem_awaddr;
logic [2:0]                dmem_awprot;
logic [AXI_ID_W-1:0]       dmem_awid;
logic dmem_wvalid;
logic dmem_wready;
logic [DATA_WIDTH-1:0]    dmem_wdata;
logic [DATA_WIDTH/8-1:0]  dmem_wstrb;
logic dmem_bvalid;
logic dmem_bready;
logic [AXI_ID_W-1:0]       dmem_bid;
logic [1:0]                dmem_bresp;
logic dmem_arvalid;
logic dmem_arready;
logic [ADDR_WIDTH-1:0]     dmem_araddr;
logic [2:0]                dmem_arprot;
logic [AXI_ID_W-1:0]       dmem_arid;
logic dmem_rvalid;
logic dmem_rready;
logic [AXI_ID_W-1:0]       dmem_rid;
logic [1:0]                dmem_rresp;
logic [DATA_WIDTH-1:0]     dmem_rdata;

// Debug signals from F-RISCV
logic [7:0]                status;
logic [32*DATA_WIDTH-1:0]  dbg_regs;

// ==============================================================================
// F-RISCV Core Instance
// ==============================================================================
// Note: F-RISCV is SystemVerilog, so we need to use $systemverilog or include
// For now, we'll create a placeholder that shows the interface
// In actual implementation, instantiate friscv_rv32i_core.sv

// Placeholder - actual instantiation would be:
/*
friscv_rv32i_core #(
    .ILEN(32),
    .XLEN(32),
    .BOOT_ADDR(BOOT_ADDR),
    .HART_ID(HART_ID),
    .AXI_ADDR_W(ADDR_WIDTH),
    .AXI_ID_W(AXI_ID_W),
    .AXI_IMEM_W(DATA_WIDTH),
    .AXI_DMEM_W(DATA_WIDTH),
    .CACHE_EN(0)  // Disable cache for simplicity
) u_friscv_core (
    .aclk(clk),
    .aresetn(rst_n),
    .srst(1'b0),
    .ext_irq(1'b0),
    .sw_irq(1'b0),
    .timer_irq(1'b0),
    .status(status),
    .dbg_regs(dbg_regs),
    
    // Instruction memory interface
    .imem_arvalid(imem_arvalid),
    .imem_arready(imem_arready),
    .imem_araddr(imem_araddr),
    .imem_arprot(imem_arprot),
    .imem_arid(imem_arid),
    .imem_rvalid(imem_rvalid),
    .imem_rready(imem_rready),
    .imem_rid(imem_rid),
    .imem_rresp(imem_rresp),
    .imem_rdata(imem_rdata),
    
    // Data memory interface
    .dmem_awvalid(dmem_awvalid),
    .dmem_awready(dmem_awready),
    .dmem_awaddr(dmem_awaddr),
    .dmem_awprot(dmem_awprot),
    .dmem_awid(dmem_awid),
    .dmem_wvalid(dmem_wvalid),
    .dmem_wready(dmem_wready),
    .dmem_wdata(dmem_wdata),
    .dmem_wstrb(dmem_wstrb),
    .dmem_bvalid(dmem_bvalid),
    .dmem_bready(dmem_bready),
    .dmem_bid(dmem_bid),
    .dmem_bresp(dmem_bresp),
    .dmem_arvalid(dmem_arvalid),
    .dmem_arready(dmem_arready),
    .dmem_araddr(dmem_araddr),
    .dmem_arprot(dmem_arprot),
    .dmem_arid(dmem_arid),
    .dmem_rvalid(dmem_rvalid),
    .dmem_rready(dmem_rready),
    .dmem_rid(dmem_rid),
    .dmem_rresp(dmem_rresp),
    .dmem_rdata(dmem_rdata)
);
*/

// Temporary: Connect signals directly (will be replaced with actual core)
assign imem_arvalid = 1'b0;
assign imem_araddr  = 32'h0;
assign imem_arprot  = 3'b000;
assign imem_arid    = {AXI_ID_W{1'b0}};
assign imem_rready  = 1'b0;

assign dmem_awvalid = 1'b0;
assign dmem_awaddr  = 32'h0;
assign dmem_awprot  = 3'b000;
assign dmem_awid    = {AXI_ID_W{1'b0}};
assign dmem_wvalid  = 1'b0;
assign dmem_wdata   = 32'h0;
assign dmem_wstrb   = {DATA_WIDTH/8{1'b0}};
assign dmem_bready  = 1'b0;
assign dmem_arvalid = 1'b0;
assign dmem_araddr  = 32'h0;
assign dmem_arprot  = 3'b000;
assign dmem_arid    = {AXI_ID_W{1'b0}};
assign dmem_rready  = 1'b0;

// ==============================================================================
// AXI4 to AXI4-Lite Adapter - Instruction Bus
// ==============================================================================
// AXI4-Lite doesn't have ID, so we ignore it
// F-RISCV may use wider data bus, we take lower 32 bits

assign m_axi_instr_araddr  = imem_araddr;
assign m_axi_instr_arprot  = imem_arprot;
assign m_axi_instr_arvalid = imem_arvalid;
assign imem_arready        = m_axi_instr_arready;

assign m_axi_instr_rdata   = imem_rdata[DATA_WIDTH-1:0];  // Take lower bits if wider
assign m_axi_instr_rresp   = imem_rresp;
assign m_axi_instr_rvalid  = imem_rvalid;
assign imem_rready         = m_axi_instr_rready;

// Ignore ID signals for AXI4-Lite
// imem_arid, imem_rid are not used

// ==============================================================================
// AXI4 to AXI4-Lite Adapter - Data Bus
// ==============================================================================
// Write Address Channel
assign m_axi_data_awaddr  = dmem_awaddr;
assign m_axi_data_awprot  = dmem_awprot;
assign m_axi_data_awvalid = dmem_awvalid;
assign dmem_awready       = m_axi_data_awready;

// Write Data Channel
assign m_axi_data_wdata   = dmem_wdata[DATA_WIDTH-1:0];  // Take lower bits if wider
assign m_axi_data_wstrb   = dmem_wstrb[3:0];  // Take lower 4 bits
assign m_axi_data_wvalid  = dmem_wvalid;
assign dmem_wready        = m_axi_data_wready;

// Write Response Channel
assign m_axi_data_bresp   = dmem_bresp;
assign m_axi_data_bvalid  = dmem_bvalid;
assign dmem_bready        = m_axi_data_bready;

// Read Address Channel
assign m_axi_data_araddr  = dmem_araddr;
assign m_axi_data_arprot  = dmem_arprot;
assign m_axi_data_arvalid = dmem_arvalid;
assign dmem_arready       = m_axi_data_arready;

// Read Data Channel
assign m_axi_data_rdata   = dmem_rdata[DATA_WIDTH-1:0];  // Take lower bits if wider
assign m_axi_data_rresp   = dmem_rresp;
assign m_axi_data_rvalid  = dmem_rvalid;
assign dmem_rready        = m_axi_data_rready;

// Ignore ID signals for AXI4-Lite
// dmem_awid, dmem_bid, dmem_arid, dmem_rid are not used

// ==============================================================================
// Debug Signals
// ==============================================================================
assign debug_pc = imem_araddr;  // Current instruction address
assign debug_r1 = dbg_regs[1*DATA_WIDTH +: DATA_WIDTH];
assign debug_r2 = dbg_regs[2*DATA_WIDTH +: DATA_WIDTH];
assign debug_zero = (dbg_regs[0*DATA_WIDTH +: DATA_WIDTH] == 32'h0);

endmodule

