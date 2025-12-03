`timescale 1ns/1ps

interface handshake_if (
    input logic clk
);
    logic reset_n;
    logic valid;
    logic ready;
    logic channel_request;
    logic handshake_done;
endinterface

