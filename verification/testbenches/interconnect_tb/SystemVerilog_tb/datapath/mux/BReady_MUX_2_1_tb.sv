`timescale 1ns/1ps

import bready_mux_tb_pkg::*;

module BReady_MUX_2_1_tb;

    bready_mux_if bready_if();

    BReady_MUX_2_1 dut (
        .Selected_Slave (bready_if.select),
        .S00_AXI_bready (bready_if.m0_ready),
        .S01_AXI_bready (bready_if.m1_ready),
        .Sele_S_AXI_bready(bready_if.sel_ready)
    );

    initial begin
        bready_mux_env env = new("bready_mux_env", bready_if);
        bready_mux_test_base test = new();
        test.set_env(env);

        bready_mux_scenario scen;

        scen = new("select_s0");
        scen.select = 0;
        scen.m0 = 1;
        scen.m1 = 0;
        test.send(scen);

        scen = new("select_s1");
        scen.select = 1;
        scen.m0 = 0;
        scen.m1 = 1;
        test.send(scen);

        env.report();
        $finish;
    end

endmodule

