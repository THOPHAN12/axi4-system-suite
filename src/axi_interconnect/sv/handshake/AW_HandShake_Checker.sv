//=============================================================================
// AW_HandShake_Checker.sv - SystemVerilog
// Write Address Channel Handshake Checker
//=============================================================================

`timescale 1ns/1ps

module AW_HandShake_Checker (
    input  logic ACLK,
    input  logic ARESETN,
    input  logic Valid_Signal,
    input  logic Ready_Signal,
    input  logic Channel_Request,
    output logic HandShake_Done
);

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            HandShake_Done <= 1'b1;
        end else if (Channel_Request) begin
            HandShake_Done <= 1'b0;
        end else if (Valid_Signal && Ready_Signal) begin
            HandShake_Done <= 1'b1;
        end
    end

endmodule

