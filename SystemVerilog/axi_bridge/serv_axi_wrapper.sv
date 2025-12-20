// ==============================================================================
// SERV RISC-V AXI Wrapper
// ==============================================================================
// Wraps SERV core (Wishbone interface) to provide AXI4-Lite interfaces for:
// - Instruction Memory (Read-only)
// - Data Memory (Read/Write)
//
// SERV uses Wishbone interface, this wrapper converts it to AXI4-Lite
// ==============================================================================

`timescale 1ns/1ps

// Note: serv_top module is already compiled into work library
// No need for include statement when compiling from GUI

module serv_axi_wrapper #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter WITH_CSR = 1,
    parameter W = 1,
    parameter RESET_PC = 32'd0
)(
    // Clock and Reset
    input logic                          clk,
    input logic                          rst_n,
    
    // ========================================================================
    // Instruction AXI Master (Read-only)
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
    // Data AXI Master (Read/Write)
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
    // Busy Signal - Indicates core is actively processing
    // ========================================================================
    output logic                          o_busy,
    
    // ========================================================================
    // Debug Signals
    // ========================================================================
    output logic [31:0]                   debug_pc,
    output logic [31:0]                   debug_r1,
    output logic [31:0]                   debug_r2,
    output logic                          debug_zero
);

// ==============================================================================
// Internal Wishbone Signals
// ==============================================================================
// Instruction Bus (Wishbone)
logic [31:0]  wb_ibus_adr;
logic wb_ibus_cyc;
logic [31:0]  wb_ibus_rdt;
logic wb_ibus_ack;

// Data Bus (Wishbone)
logic [31:0]  wb_dbus_adr;
logic [31:0]  wb_dbus_dat;
logic [3:0]   wb_dbus_sel;
logic wb_dbus_we;
logic wb_dbus_cyc;
logic [31:0]  wb_dbus_rdt;
logic wb_dbus_ack;

// Register File Interface (simplified - using internal RF)
logic rf_rreq;
logic rf_wreq;
logic rf_ready;
logic [4:0]   wreg0, wreg1;
logic wen0, wen1;
logic [W-1:0] wdata0, wdata1;
logic [4:0]   rreg0, rreg1;
logic [W-1:0] rdata0, rdata1;

// Register file port connections (6 bits: [5:0] = {WITH_CSR, logic[4:0]})
logic [5:0]   o_wreg0_conn, o_wreg1_conn;
logic [5:0]   o_rreg0_conn, o_rreg1_conn;
assign o_wreg0_conn = {(WITH_CSR ? 1'b1 : 1'b0), wreg0};
assign o_wreg1_conn = {(WITH_CSR ? 1'b1 : 1'b0), wreg1};
assign o_rreg0_conn = {(WITH_CSR ? 1'b1 : 1'b0), rreg0};
assign o_rreg1_conn = {(WITH_CSR ? 1'b1 : 1'b0), rreg1};

// ==============================================================================
// SERV Core Instance
// ==============================================================================
serv_top #(
    .WITH_CSR(WITH_CSR),
    .W(W),
    .RESET_PC(RESET_PC),
    .RESET_STRATEGY("MINI"),
    .DEBUG(1'b0),
    .MDU(1'b0),
    .COMPRESSED(1'b0)
) u_serv_core (
    .clk(clk),
    .i_rst(!rst_n),
    .i_timer_irq(1'b0),
    
    // Register File Interface
    .o_rf_rreq(rf_rreq),
    .o_rf_wreq(rf_wreq),
    .i_rf_ready(rf_ready),
    .o_wreg0(o_wreg0_conn),
    .o_wreg1(o_wreg1_conn),
    .o_wen0(wen0),
    .o_wen1(wen1),
    .o_wdata0(wdata0),
    .o_wdata1(wdata1),
    .o_rreg0(o_rreg0_conn),
    .o_rreg1(o_rreg1_conn),
    .i_rdata0(rdata0),
    .i_rdata1(rdata1),
    
    // Instruction Bus (Wishbone)
    .o_ibus_adr(wb_ibus_adr),
    .o_ibus_cyc(wb_ibus_cyc),
    .i_ibus_rdt(wb_ibus_rdt),
    .i_ibus_ack(wb_ibus_ack),
    
    // Data Bus (Wishbone)
    .o_dbus_adr(wb_dbus_adr),
    .o_dbus_dat(wb_dbus_dat),
    .o_dbus_sel(wb_dbus_sel),
    .o_dbus_we(wb_dbus_we),
    .o_dbus_cyc(wb_dbus_cyc),
    .i_dbus_rdt(wb_dbus_rdt),
    .i_dbus_ack(wb_dbus_ack),
    
    // Extension (unused)
    .o_ext_funct3(),
    .i_ext_ready(1'b0),
    .i_ext_rd(32'h0),
    .o_ext_rs1(),
    .o_ext_rs2(),
    .o_mdu_valid(),
    .o_cnt_done()
);

// ==============================================================================
// Wishbone to AXI4-Lite Converter - Instruction Bus
// ==============================================================================
logic [31:0]  instr_addr_reg;
logic instr_read_pending;

assign m_axi_instr_araddr  = wb_ibus_adr;
assign m_axi_instr_arprot  = 3'b000; // Normal, non-secure, data access
assign m_axi_instr_arvalid = wb_ibus_cyc && !instr_read_pending;
assign m_axi_instr_rready  = instr_read_pending;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        instr_addr_reg     <= 32'h0;
        instr_read_pending <= 1'b0;
    end else begin
        if (wb_ibus_cyc && !instr_read_pending) begin
            instr_addr_reg     <= wb_ibus_adr;
            instr_read_pending <= 1'b1;
        end else if (m_axi_instr_rvalid && m_axi_instr_rready) begin
            instr_read_pending <= 1'b0;
        end
    end
end

assign wb_ibus_rdt = m_axi_instr_rdata;
assign wb_ibus_ack = m_axi_instr_rvalid && m_axi_instr_rready;

// ==============================================================================
// Wishbone to AXI4-Lite Converter - Data Bus
// ==============================================================================
logic [31:0]  data_awaddr_reg, data_araddr_reg;
logic [31:0]  data_wdata_reg;
logic [3:0]   data_wstrb_reg;
logic data_write_pending;
logic data_read_pending;

// Write Address Channel
assign m_axi_data_awaddr  = wb_dbus_adr;
assign m_axi_data_awprot  = 3'b000;
assign m_axi_data_awvalid = wb_dbus_cyc && wb_dbus_we && !data_write_pending;
assign m_axi_data_bready  = data_write_pending;

// Write Data Channel
assign m_axi_data_wdata  = wb_dbus_dat;
assign m_axi_data_wstrb  = wb_dbus_sel;
assign m_axi_data_wvalid = wb_dbus_cyc && wb_dbus_we && !data_write_pending;

// Read Address Channel
assign m_axi_data_araddr  = wb_dbus_adr;
assign m_axi_data_arprot  = 3'b000;
assign m_axi_data_arvalid = wb_dbus_cyc && !wb_dbus_we && !data_read_pending;
assign m_axi_data_rready  = data_read_pending;

// Write Control
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_awaddr_reg     <= 32'h0;
        data_wdata_reg      <= 32'h0;
        data_wstrb_reg      <= 4'h0;
        data_write_pending  <= 1'b0;
    end else begin
        if (wb_dbus_cyc && wb_dbus_we && !data_write_pending) begin
            data_awaddr_reg    <= wb_dbus_adr;
            data_wdata_reg     <= wb_dbus_dat;
            data_wstrb_reg     <= wb_dbus_sel;
            data_write_pending <= 1'b1;
        end else if (m_axi_data_awready && m_axi_data_awvalid &&
                     m_axi_data_wready && m_axi_data_wvalid) begin
            data_write_pending <= 1'b0;
        end
    end
end

// Read Control
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_araddr_reg    <= 32'h0;
        data_read_pending   <= 1'b0;
    end else begin
        if (wb_dbus_cyc && !wb_dbus_we && !data_read_pending) begin
            data_araddr_reg   <= wb_dbus_adr;
            data_read_pending <= 1'b1;
        end else if (m_axi_data_arready && m_axi_data_arvalid) begin
            data_read_pending <= 1'b0;
        end
    end
end

assign wb_dbus_rdt = m_axi_data_rdata;
assign wb_dbus_ack = (wb_dbus_we && m_axi_data_bvalid && m_axi_data_bready) ||
                     (!wb_dbus_we && m_axi_data_rvalid && m_axi_data_rready);

// ==============================================================================
// Register File (simplified - using internal memory)
// ==============================================================================
// Note: SERV uses bit-serial register file, this is a simplified implementation
// For full functionality, use serv_rf_top module
logic [31:0] rf_mem [0:31];
integer i;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 32; i = i + 1) begin
            rf_mem[i] <= 32'h0;
        end
    end else begin
        if (wen0 && wreg0 < 32) begin
            rf_mem[wreg0] <= {31'h0, wdata0};
        end
        if (wen1 && wreg1 < 32) begin
            rf_mem[wreg1] <= {31'h0, wdata1};
        end
    end
end

assign rdata0 = rf_mem[rreg0][W-1:0];
assign rdata1 = rf_mem[rreg1][W-1:0];
assign rf_ready = 1'b1; // Always ready for now

// ==============================================================================
// Busy Signal Generation
// ==============================================================================
// Core is busy when:
// 1. Instruction or Data bus has active cycle (wb_ibus_cyc or wb_dbus_cyc)
// 2. There are pending AXI transactions (waiting for response)
// 3. Register file is being accessed (optional - for more detailed status)

logic instr_busy = wb_ibus_cyc || instr_read_pending;
logic data_busy  = wb_dbus_cyc || data_read_pending || data_write_pending;
logic rf_busy    = rf_rreq || rf_wreq;  // Register file access

// Master busy when any of its buses or register file is active
assign o_busy = instr_busy || data_busy || rf_busy;

// ==============================================================================
// Debug Signals
// ==============================================================================
assign debug_pc = wb_ibus_adr;
assign debug_r1 = rf_mem[1];
assign debug_r2 = rf_mem[2];
assign debug_zero = (rf_mem[0] == 32'h0);

endmodule

