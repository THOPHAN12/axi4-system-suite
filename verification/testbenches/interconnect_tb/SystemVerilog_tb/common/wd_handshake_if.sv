`timescale 1ns/1ps

interface wd_handshake_if (
    input logic clk
);
    logic reset_n;
    logic valid;
    logic ready;
    logic last;
    logic handshake_en;
    logic handshake_done;
endinterface

