//=============================================================================
// Demux_1x2.sv - SystemVerilog
// 1-to-2 Demultiplexer
//=============================================================================

`timescale 1ns/1ps

module Demux_1x2 #(
    parameter int unsigned width = 31
) (
    //---------------------- Input Ports ----------------------
    input logic [width:0] in,
    input logic           select,
    
    //---------------------- Output Ports ----------------------
    output logic [width:0] out1,
    output logic [width:0] out2
);

    //---------------------- Code Start ----------------------
    always_comb begin
        case (select)
            1'b0: begin
                out1 = in;
                out2 = '0;
            end
            1'b1: begin
                out1 = '0;
                out2 = in;
            end
            default: begin
                out1 = '0;
                out2 = '0;
            end
        endcase
    end

endmodule

