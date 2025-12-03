`timescale 1ns/1ps

interface resp_queue_if #(
    parameter int ID_W = 1
) (
    input logic clk
);
    logic reset_n;

    logic [ID_W-1:0] Master_ID;
    logic            Write_Resp_Grant;
    logic            Write_Resp_Finsh;
    logic [ID_W-1:0] Resp_Master_ID;
    logic            Resp_Master_Valid;
    logic            Queue_Is_Full;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output Master_ID, Write_Resp_Grant, Write_Resp_Finsh;
        input  Resp_Master_ID, Resp_Master_Valid, Queue_Is_Full;
    endclocking
endinterface

