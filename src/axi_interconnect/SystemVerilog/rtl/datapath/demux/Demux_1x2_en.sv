//=============================================================================
// Demux_1x2_en.sv - SystemVerilog
// 1-to-2 Demultiplexer with Enable
//=============================================================================

`timescale 1ns/1ps

module Demux_1x2_en #(
    parameter int unsigned width = 31
) (
    //---------------------- Input Ports ----------------------
    input logic [width:0] in,
    input logic           select,
    input logic           enable,
    
    //---------------------- Output Ports ----------------------
    output logic [width:0] out1,
    output logic [width:0] out2
);

    //---------------------- Code Start ----------------------
    always_comb begin
        if (enable) begin
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
        end else begin
            out1 = '0;
            out2 = '0;
        end
    end

endmodule

