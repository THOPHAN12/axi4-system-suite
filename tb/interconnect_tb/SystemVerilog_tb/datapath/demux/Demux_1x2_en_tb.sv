`timescale 1ns/1ps

import demux_en_tb_pkg::*;

module Demux_1x2_en_tb;

    demux_en_if #(32) demux_if32();

    Demux_1x2_en #(.width(31)) dut (
        .in    (demux_if32.in_data),
        .select(demux_if32.select),
        .enable(demux_if32.enable),
        .out1  (demux_if32.out0),
        .out2  (demux_if32.out1)
    );

    initial begin
        demux_en_env env = new("demux_en_env", demux_if32);
        demux_en_test test = new();
        test.set_env(env);
        test.run();
        env.report();
        $finish;
    end

endmodule

class demux_en_test extends demux_en_test_base;
    function new();
        super.new("demux_en_test");
    endfunction

    virtual task run();
        demux_en_scenario scen;

        scen = new("disabled");
        scen.enable = 0;
        scen.data   = 32'hFFFF_FFFF;
        send(scen);

        scen = new("route_out0");
        scen.enable = 1;
        scen.select = 0;
        scen.data   = 32'h1234_5678;
        send(scen);

        scen = new("route_out1");
        scen.enable = 1;
        scen.select = 1;
        scen.data   = 32'hDEAD_BEEF;
        send(scen);
    endtask
endclass

