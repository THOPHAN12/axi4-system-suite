`timescale 1ns/1ps

interface aw_mux_if #(
    parameter int ADDR_W = 32,
    parameter int LEN_W  = 8
) ();

    logic [1:0] Selected_Slave;

    typedef struct packed {
        logic [ADDR_W-1:0] addr;
        logic [LEN_W-1:0]  len;
        logic [2:0]        size;
        logic [1:0]        burst;
        logic [1:0]        lock;
        logic [3:0]        cache;
        logic [2:0]        prot;
        logic [3:0]        qos;
        logic              valid;
    } aw_channel_t;

    aw_channel_t s0;
    aw_channel_t s1;
    aw_channel_t sel;

    task automatic drive_input(int master,
                               aw_channel_t value);
        case (master)
            0: s0 = value;
            1: s1 = value;
        endcase
    endtask

endinterface

