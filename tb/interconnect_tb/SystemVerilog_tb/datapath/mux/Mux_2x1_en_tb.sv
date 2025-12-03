`timescale 1ns/1ps

import mux2_en_tb_pkg::*;

module Mux_2x1_en_tb;

    mux2_en_if #(32) mux_if();

    Mux_2x1_en #(.width(31)) dut (
        .in1   (mux_if.in0),
        .in2   (mux_if.in1),
        .sel   (mux_if.sel),
        .enable(mux_if.enable),
        .out   (mux_if.out)
    );

    initial begin
        mux2_en_env env = new("mux2_en_env", mux_if);
        mux2_en_smoke test = new();
        test.set_env(env);
        test.run();
        env.report();
        $finish;
    end

endmodule

class mux2_en_smoke extends mux2_en_test_base;
    function new();
        super.new("mux2_en_smoke");
    endfunction

    virtual task run();
        mux2_en_scenario scen;

        scen = new("disabled");
        scen.enable = 0;
        scen.sel = 0;
        scen.in0 = 32'hFFFF_FFFF;
        scen.in1 = 32'h0000_0000;
        send(scen);

        scen = new("enable_sel0");
        scen.enable = 1;
        scen.sel = 0;
        scen.in0 = 32'h1234_1234;
        scen.in1 = 32'h4321_4321;
        send(scen);

        scen = new("enable_sel1");
        scen.enable = 1;
        scen.sel = 1;
        scen.in0 = 32'hAAAA_AAAA;
        scen.in1 = 32'h5555_5555;
        send(scen);
    endtask
endclass

