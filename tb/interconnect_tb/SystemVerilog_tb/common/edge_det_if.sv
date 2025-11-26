`timescale 1ns/1ps

interface edge_det_if (
    input logic clk
);
    logic reset_n;
    logic test_signal;
    logic rising_pulse;
    logic falling_pulse;
endinterface

