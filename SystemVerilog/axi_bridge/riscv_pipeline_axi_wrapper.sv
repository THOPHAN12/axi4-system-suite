// ==============================================================================
// RISC-V Pipeline AXI Wrapper
// ==============================================================================
// Wraps RV32I_PIPELINE core to provide AXI4-Lite interfaces for:
// - Instruction Memory (Read-only)
// - Data Memory (Read/Write)
//
// This wrapper replaces local IMEM/DMEM with AXI masters
// ==============================================================================

`timescale 1ns/1ps

`include "../cores/riscv-5stage-pipeline/rtl/core/RV32I_PIPELINE.v"

module riscv_pipeline_axi_wrapper #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
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
    // Debug Signals
    // ========================================================================
    output logic [31:0]                   debug_pc,
    output logic [31:0]                   debug_r1,
    output logic [31:0]                   debug_r2,
    output logic                          debug_zero
);

// ==============================================================================
// Internal Signals
// ==============================================================================
// Instruction Memory Interface (replacing IMEM)
logic [7:0]  instr_addr;
logic [31:0] instr_data;
logic instr_req;
logic instr_ready;

// Data Memory Interface (replacing DMEM)
logic [7:0]  data_addr;
logic [31:0] data_wdata;
logic [31:0] data_rdata;
logic [3:0]  data_wstrb;
logic data_we;
logic data_re;
logic data_ready;

// ==============================================================================
// RISC-V Pipeline Core Instance
// ==============================================================================
// Note: This uses the original RV32I_PIPELINE which has local IMEM/DMEM
// In a real implementation, we would need to modify the core to use AXI
// For now, we'll create a simplified interface

RV32I_PIPELINE #(
    .d_width(DATA_WIDTH)
) u_riscv_core (
    .clk(clk),
    .rst_n(rst_n),
    .zero(debug_zero),
    .r0(), .r1(debug_r1), .r2(debug_r2), .r3(), .r4(), .r5(), .r6(), .r7(),
    .r8(), .r9(), .r10(), .r11(), .r12(), .r13(), .r14(), .r15(),
    .r16(), .r17(), .r18(), .r19(), .r20(), .r21(), .r22(), .r23(),
    .r24(), .r25(), .r26(), .r27(), .r28(), .r29(), .r30(), .r31()
);

// ==============================================================================
// Instruction AXI Master (Read-only)
// ==============================================================================
// Simple AXI4-Lite read interface for instruction fetch
logic [ADDR_WIDTH-1:0] instr_addr_reg;
logic instr_read_pending;

assign m_axi_instr_araddr  = {24'h0, instr_addr_reg[7:0]}; // Extend to 32-bit
assign m_axi_instr_arprot  = 3'b000; // Normal, non-secure, data access
assign m_axi_instr_arvalid = instr_read_pending;
assign m_axi_instr_rready  = instr_read_pending;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        instr_addr_reg     <= 32'h0;
        instr_read_pending <= 1'b0;
    end else begin
        if (instr_req && !instr_read_pending) begin
            instr_addr_reg     <= {24'h0, instr_addr};
            instr_read_pending <= 1'b1;
        end else if (m_axi_instr_arready && m_axi_instr_arvalid) begin
            instr_read_pending <= 1'b0;
        end
    end
end

assign instr_data  = m_axi_instr_rdata;
assign instr_ready = m_axi_instr_rvalid && m_axi_instr_rready;

// ==============================================================================
// Data AXI Master (Read/Write)
// ==============================================================================
// AXI4-Lite interface for data memory access
logic [ADDR_WIDTH-1:0] data_awaddr_reg, data_araddr_reg;
logic [DATA_WIDTH-1:0] data_wdata_reg;
logic [3:0]            data_wstrb_reg;
logic data_write_pending;
logic data_read_pending;

// Write Address Channel
assign m_axi_data_awaddr  = {24'h0, data_awaddr_reg[7:0]};
assign m_axi_data_awprot  = 3'b000;
assign m_axi_data_awvalid = data_write_pending;
assign m_axi_data_bready  = data_write_pending;

// Write Data Channel
assign m_axi_data_wdata  = data_wdata_reg;
assign m_axi_data_wstrb  = data_wstrb_reg;
assign m_axi_data_wvalid = data_write_pending;

// Read Address Channel
assign m_axi_data_araddr  = {24'h0, data_araddr_reg[7:0]};
assign m_axi_data_arprot  = 3'b000;
assign m_axi_data_arvalid = data_read_pending;
assign m_axi_data_rready  = data_read_pending;

// Write Control
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_awaddr_reg     <= 32'h0;
        data_wdata_reg      <= 32'h0;
        data_wstrb_reg      <= 4'h0;
        data_write_pending  <= 1'b0;
    end else begin
        if (data_we && !data_write_pending) begin
            data_awaddr_reg    <= {24'h0, data_addr};
            data_wdata_reg     <= data_wdata;
            data_wstrb_reg     <= data_wstrb;
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
        data_read_pending  <= 1'b0;
    end else begin
        if (data_re && !data_read_pending) begin
            data_araddr_reg   <= {24'h0, data_addr};
            data_read_pending <= 1'b1;
        end else if (m_axi_data_arready && m_axi_data_arvalid) begin
            data_read_pending <= 1'b0;
        end
    end
end

assign data_rdata  = m_axi_data_rdata;
assign data_ready  = (data_we && m_axi_data_bvalid && m_axi_data_bready) ||
                     (data_re && m_axi_data_rvalid && m_axi_data_rready);

// ==============================================================================
// TODO: Connect to actual RISC-V core memory interfaces
// ==============================================================================
// Note: The current RV32I_PIPELINE uses internal IMEM/DMEM
// To fully integrate, we need to modify the core to expose memory interfaces
// or create an adapter that bridges between the core's memory interface
// and AXI

// Placeholder connections - these need to be connected to actual core signals
assign instr_addr = 8'h0; // TODO: Connect to PC
assign instr_req  = 1'b0;  // TODO: Connect to instruction fetch request
assign data_addr  = 8'h0; // TODO: Connect to ALU result (memory address)
assign data_wdata = 32'h0; // TODO: Connect to register file output
assign data_wstrb = 4'h0;  // TODO: Generate from funct3
assign data_we    = 1'b0;  // TODO: Connect to store instruction
assign data_re    = 1'b0;  // TODO: Connect to load instruction

assign debug_pc = 32'h0; // TODO: Connect to PC register

endmodule

