`timescale 1ns/1ps

interface demux_if #(
    parameter int DATA_W = 1
) ();

    logic Selection_Line;
    logic [DATA_W-1:0] input_data;
    logic [DATA_W-1:0] output_0;
    logic [DATA_W-1:0] output_1;

endinterface

