`timescale 1ns/1ps

interface write_addr_dec_if #(
    parameter int ADDR_W = 32,
    parameter int LEN_W  = 8,
    parameter int NUM_SLAVES = 2,
    parameter int SLV_ID_W = $clog2(NUM_SLAVES)
) (
    input logic clk
);

    logic reset_n;

    logic [ADDR_W-1:0] Master_AXI_awaddr;
    logic [SLV_ID_W-1:0] Master_AXI_awaddr_ID;
    logic [LEN_W-1:0]  Master_AXI_awlen;
    logic [2:0]        Master_AXI_awsize;
    logic [1:0]        Master_AXI_awburst;
    logic [1:0]        Master_AXI_awlock;
    logic [3:0]        Master_AXI_awcache;
    logic [2:0]        Master_AXI_awprot;
    logic [3:0]        Master_AXI_awqos;
    logic              Master_AXI_awvalid;
    logic              Master_AXI_awready;

    logic [ADDR_W-1:0]  slave_awaddr [NUM_SLAVES];
    logic [SLV_ID_W-1:0] slave_awaddr_id [NUM_SLAVES];
    logic [LEN_W-1:0]   slave_awlen [NUM_SLAVES];
    logic [2:0]         slave_awsize [NUM_SLAVES];
    logic [1:0]         slave_awburst[NUM_SLAVES];
    logic [1:0]         slave_awlock [NUM_SLAVES];
    logic [3:0]         slave_awcache[NUM_SLAVES];
    logic [2:0]         slave_awprot [NUM_SLAVES];
    logic [3:0]         slave_awqos  [NUM_SLAVES];
    logic               slave_awvalid[NUM_SLAVES];
    logic               slave_awready[NUM_SLAVES];

    logic [NUM_SLAVES-1:0] Q_Enables;
    logic                  Sel_Slave_Ready;

endinterface

