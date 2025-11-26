`timescale 1ns/1ps

interface demux_en_if #(
    parameter int DATA_W = 32
) ();
    typedef logic [DATA_W-1:0] data_t;

    logic select;
    logic enable;
    data_t in_data;
    data_t out0;
    data_t out1;
endinterface

