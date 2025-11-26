`timescale 1ns/1ps

interface axi_master_if #(
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
        output araddr, arlen, arsize, arburst, arvalid, rready;
        input  arready, rvalid, rlast, rresp, rdata;
    endclocking

    modport drv (
        clocking cb,
        input   reset_n
    );

    modport mon (
        input araddr,
        input arlen,
        input arsize,
        input arburst,
        input arvalid,
        input arready,
        input rready,
        input rvalid,
        input rlast,
        input rresp,
        input rdata,
        input clk,
        input reset_n
    );

    modport dut (
        input  araddr,
        input  arlen,
        input  arsize,
        input  arburst,
        input  arvalid,
        output arready,
        output rvalid,
        output rlast,
        output rresp,
        output rdata,
        input  rready
    );

endinterface

