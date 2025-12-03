`timescale 1ns/1ps

interface write_arb_if #(
    parameter int NUM_REQ = 2,
    parameter int ID_WIDTH = $clog2(NUM_REQ)
) (
    input  logic clk
);
    logic reset_n;

    logic [NUM_REQ-1:0]                   req;
    logic [NUM_REQ-1:0][3:0]              qos;
    logic                                 token;
    logic                                 channel_granted;

    logic                                 channel_request;
    logic [ID_WIDTH-1:0]                  selected_slave;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output req;
        output qos;
        output token;
        output channel_granted;
        input  channel_request;
        input  selected_slave;
    endclocking

    modport drv (
        clocking cb,
        input reset_n
    );

    modport mon (
        input req,
        input qos,
        input token,
        input channel_granted,
        input channel_request,
        input selected_slave,
        input clk,
        input reset_n
    );

endinterface

