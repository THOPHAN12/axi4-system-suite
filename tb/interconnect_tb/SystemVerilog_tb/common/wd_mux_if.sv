`timescale 1ns/1ps

interface wd_mux_if #(
    parameter int DATA_W = 32,
    parameter int STRB_W = DATA_W/8
) ();

    logic [0:0] Selected_Slave;

    typedef struct packed {
        logic [DATA_W-1:0] data;
        logic [STRB_W-1:0] strb;
        logic              last;
        logic              valid;
    } wd_channel_t;

    wd_channel_t m0;
    wd_channel_t m1;
    wd_channel_t sel;

endinterface

