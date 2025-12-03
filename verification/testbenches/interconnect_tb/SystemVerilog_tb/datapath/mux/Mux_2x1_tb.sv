`timescale 1ns/1ps

import mux2_tb_pkg::*;

module Mux_2x1_tb;

    mux2_if #(32) mux_if();

    Mux_2x1 #(.width(31)) dut (
        .in1(mux_if.in0),
        .in2(mux_if.in1),
        .sel(mux_if.sel),
        .out(mux_if.out)
    );

    initial begin
        mux2_env env = new("mux2_env", mux_if);
        mux2_regression test = new();
        test.set_env(env);
        test.run();
        env.report();
        $finish;
    end

endmodule

class mux2_regression extends mux2_test_base;
    function new();
        super.new("mux2_regression");
    endfunction

    virtual task run();
        mux2_scenario scen;

        scen = new("select_in0");
        scen.sel = 0;
        scen.in0 = 32'h1111_1111;
        scen.in1 = 32'h2222_2222;
        send(scen);

        scen = new("select_in1");
        scen.sel = 1;
        scen.in0 = 32'hAAAA_AAAA;
        scen.in1 = 32'h5555_5555;
        send(scen);
    endtask
endclass

