`timescale 1ns/1ps

interface write_resp_dec_if #(
    parameter int NUM_MASTERS = 2,
    parameter int ID_W = $clog2(NUM_MASTERS)
) ();

    logic [ID_W-1:0] Sel_Resp_ID;
    logic            Sel_Valid;
    logic [1:0]      Sel_Write_Resp;

    logic [NUM_MASTERS-1:0]     bvalid;
    logic [NUM_MASTERS-1:0][1:0] bresp;

endinterface

