//=============================================================================
// WD_HandShake.sv - SystemVerilog
// Write Data Channel Handshake
//=============================================================================

`timescale 1ns/1ps

module WD_HandShake (
    input  logic ACLK,
    input  logic ARESETN,
    input  logic Valid_Signal,
    input  logic Ready_Signal,
    input  logic Last_Data,
    input  logic HandShake_En,
    output logic HandShake_Done
);

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            HandShake_Done <= 1'b0;
        end else if (HandShake_En || HandShake_Done) begin
            HandShake_Done <= 1'b0;
        end else if (Valid_Signal && Ready_Signal && Last_Data) begin
            HandShake_Done <= 1'b1;
        end else begin
            HandShake_Done <= 1'b0;
        end
    end

endmodule

