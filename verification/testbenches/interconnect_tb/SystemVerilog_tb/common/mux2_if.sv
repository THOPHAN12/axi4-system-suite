`timescale 1ns/1ps

interface mux2_if #(
    parameter int DATA_W = 32
) ();
    typedef logic [DATA_W-1:0] data_t;

    logic sel;
    data_t in0;
    data_t in1;
    data_t out;
endinterface

