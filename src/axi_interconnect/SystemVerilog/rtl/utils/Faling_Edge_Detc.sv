//=============================================================================
// Faling_Edge_Detc.sv - SystemVerilog
// Falling Edge Detector
//=============================================================================

`timescale 1ns/1ps

module Faling_Edge_Detc (
    input  logic ACLK,
    input  logic ARESETN,
    input  logic Test_Singal,
    output logic Falling
);

    logic reg_Test_Signal;

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            reg_Test_Signal <= 1'b0;
        end else begin
            reg_Test_Signal <= Test_Singal;
        end
    end

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Falling <= 1'b0;
        end else begin
            Falling <= (reg_Test_Signal ^ Test_Singal) & ~(Test_Singal);
        end
    end

endmodule

