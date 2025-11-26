//=============================================================================
// Mux_2x1.sv - SystemVerilog
// 2-to-1 Multiplexer
//=============================================================================

`timescale 1ns/1ps

module Mux_2x1 #(
    parameter int unsigned width = 31
) (
    //---------------------- Input Ports ----------------------
    input logic [width:0] in1,
    input logic [width:0] in2,
    input logic           sel,
    
    //---------------------- Output Ports ----------------------
    output logic [width:0] out
);

    //---------------------- Code Start ----------------------
    always_comb begin
        case (sel)
            1'b0: out = in1; // select first input if selection line has 0 on it
            1'b1: out = in2; // select second input if selection line has 1 on it
            default: out = in1; // Default to avoid latch
        endcase
    end

endmodule

