//=============================================================================
// AW_MUX_2_1.sv - SystemVerilog
// Write Address Channel MUX (2-to-1)
//=============================================================================

`timescale 1ns/1ps

module AW_MUX_2_1 #(
    parameter int unsigned Address_width = 32,
    parameter int unsigned S_Aw_len = 8  // AXI4 - 8 bits for burst length
) (
    input  logic                          Selected_Slave,

    input  logic [Address_width-1:0]      S00_AXI_awaddr,  // the write address
    input  logic [S_Aw_len-1:0]          S00_AXI_awlen,  // number of transfer per burst
    input  logic [2:0]                   S00_AXI_awsize, // number of bytes within the transfer
    input  logic [1:0]                    S00_AXI_awburst, // burst type
    input  logic [1:0]                    S00_AXI_awlock,  // lock type
    input  logic [3:0]                    S00_AXI_awcache,  // optional signal for connecting to different types of memories
    input  logic [2:0]                    S00_AXI_awprot,  // identifies the level of protection
    input  logic [3:0]                    S00_AXI_awqos,   // for priority transactions
    input  logic                          S00_AXI_awvalid, // Address write valid signal

    input  logic [Address_width-1:0]      S01_AXI_awaddr,  // the write address
    input  logic [S_Aw_len-1:0]          S01_AXI_awlen,  // number of transfer per burst
    input  logic [2:0]                   S01_AXI_awsize, // number of bytes within the transfer
    input  logic [1:0]                   S01_AXI_awburst, // burst type
    input  logic [1:0]                   S01_AXI_awlock,  // lock type
    input  logic [3:0]                   S01_AXI_awcache,  // optional signal for connecting to different types of memories
    input  logic [2:0]                   S01_AXI_awprot,  // identifies the level of protection
    input  logic [3:0]                   S01_AXI_awqos,   // for priority transactions
    input  logic                         S01_AXI_awvalid, // Address write valid signal

    output logic [Address_width-1:0]     Sel_S_AXI_awaddr,  // the write address
    output logic [S_Aw_len-1:0]         Sel_S_AXI_awlen,  // number of transfer per burst
    output logic [2:0]                  Sel_S_AXI_awsize, // number of bytes within the transfer
    output logic [1:0]                  Sel_S_AXI_awburst, // burst type
    output logic [1:0]                  Sel_S_AXI_awlock,  // lock type
    output logic [3:0]                   Sel_S_AXI_awcache, // optional signal for connecting to different types of memories
    output logic [2:0]                  Sel_S_AXI_awprot,  // identifies the level of protection
    output logic [3:0]                  Sel_S_AXI_awqos,   // for priority transactions
    output logic                        Sel_S_AXI_awvalid  // Address write valid signal
);

    always_comb begin
        if (!Selected_Slave) begin
            Sel_S_AXI_awaddr  = S00_AXI_awaddr;
            Sel_S_AXI_awlen   = S00_AXI_awlen;
            Sel_S_AXI_awsize  = S00_AXI_awsize;
            Sel_S_AXI_awburst = S00_AXI_awburst;
            Sel_S_AXI_awlock  = S00_AXI_awlock;
            Sel_S_AXI_awcache = S00_AXI_awcache;
            Sel_S_AXI_awprot  = S00_AXI_awprot;
            Sel_S_AXI_awqos   = S00_AXI_awqos;
            Sel_S_AXI_awvalid = S00_AXI_awvalid;
        end else begin
            Sel_S_AXI_awaddr  = S01_AXI_awaddr;
            Sel_S_AXI_awlen   = S01_AXI_awlen;
            Sel_S_AXI_awsize  = S01_AXI_awsize;
            Sel_S_AXI_awburst = S01_AXI_awburst;
            Sel_S_AXI_awlock  = S01_AXI_awlock;
            Sel_S_AXI_awcache = S01_AXI_awcache;
            Sel_S_AXI_awprot  = S01_AXI_awprot;
            Sel_S_AXI_awqos   = S01_AXI_awqos;
            Sel_S_AXI_awvalid = S01_AXI_awvalid;
        end
    end

endmodule

