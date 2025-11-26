`timescale 1ns/1ps

interface axi_slave_if #(
    parameter int ADDR_W = 32,
    parameter int LEN_W  = 8,
    parameter int SIZE_W = 3,
    parameter int DATA_W = 32
) (
    input  logic clk,
    input  logic reset_n
);

    logic [ADDR_W-1:0] araddr;
    logic [LEN_W-1:0]  arlen;
    logic [SIZE_W-1:0] arsize;
    logic [1:0]        arburst;
    logic              arvalid;
    logic              arready;

    logic              rready;
    logic              rvalid;
    logic              rlast;
    logic [1:0]        rresp;
    logic [DATA_W-1:0] rdata;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        input  araddr, arlen, arsize, arburst, arvalid, rready;
        output arready, rvalid, rlast, rresp, rdata;
    endclocking

    modport model (
        clocking cb,
        input reset_n
    );

    modport dut (
        output araddr,
        output arlen,
        output arsize,
        output arburst,
        output arvalid,
        input  arready,
        input  rvalid,
        input  rlast,
        input  rresp,
        input  rdata,
        output rready
    );

endinterface

