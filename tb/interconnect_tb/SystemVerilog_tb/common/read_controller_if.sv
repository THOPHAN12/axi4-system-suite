`timescale 1ns/1ps

interface read_controller_if (input logic clk);
    logic reset;

    // Address ranges
    logic [31:0] slave0_addr1, slave0_addr2;
    logic [31:0] slave1_addr1, slave1_addr2;
    logic [31:0] slave2_addr1, slave2_addr2;
    logic [31:0] slave3_addr1, slave3_addr2;

    // Master inputs
    logic [31:0] M_ADDR;
    logic        M0_ARVALID;
    logic        M1_ARVALID;
    logic        M0_RREADY;
    logic        M1_RREADY;

    // Slave handshake inputs
    logic        S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
    logic        S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
    logic        S0_RLAST,  S1_RLAST,  S2_RLAST,  S3_RLAST;

    // DUT outputs
    logic [1:0]  select_slave_address;
    logic        select_master_address;
    logic [1:0]  select_data_M0;
    logic [1:0]  select_data_M1;
    logic [1:0]  en_S0, en_S1, en_S2, en_S3;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output reset;
        output M_ADDR, M0_ARVALID, M1_ARVALID, M0_RREADY, M1_RREADY;
        output S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
        output S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
        output S0_RLAST,  S1_RLAST,  S2_RLAST,  S3_RLAST;
        input  select_slave_address, select_master_address;
        input  select_data_M0, select_data_M1;
        input  en_S0, en_S1, en_S2, en_S3;
    endclocking
endinterface

