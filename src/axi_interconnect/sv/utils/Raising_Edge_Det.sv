//=============================================================================
// Raising_Edge_Det.sv - SystemVerilog
// Rising Edge Detector
//=============================================================================

`timescale 1ns/1ps

module Raising_Edge_Det (
    input  logic ACLK,
    input  logic ARESETN,
    input  logic Test_Singal,
    output logic Raisung
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
            Raisung <= 1'b0;
        end else begin
            Raisung <= (reg_Test_Signal ^ Test_Singal) & Test_Singal;
        end
    end

endmodule

