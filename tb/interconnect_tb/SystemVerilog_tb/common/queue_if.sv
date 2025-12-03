`timescale 1ns/1ps

interface queue_if #(
    parameter int ID_WIDTH = 1
) (
    input logic clk
);
    logic reset;

    logic [ID_WIDTH-1:0] slave_id;
    logic                AW_Access_Grant;
    logic                Write_Data_Finsh;
    logic                Is_Transaction_Part_of_Split;

    logic                Queue_Is_Full;
    logic                Write_Data_HandShake_En_Pulse;
    logic                Is_Master_Part_Of_Split;
    logic                Master_Valid;
    logic [ID_WIDTH-1:0] Write_Data_Master;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output reset;
        output slave_id, AW_Access_Grant, Write_Data_Finsh, Is_Transaction_Part_of_Split;
        input  Queue_Is_Full, Write_Data_HandShake_En_Pulse, Is_Master_Part_Of_Split;
        input  Master_Valid, Write_Data_Master;
    endclocking
endinterface

