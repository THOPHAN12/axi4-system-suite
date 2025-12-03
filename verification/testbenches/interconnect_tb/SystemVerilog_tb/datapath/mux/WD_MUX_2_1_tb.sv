`timescale 1ns/1ps

import wd_mux_tb_pkg::*;

module WD_MUX_2_1_tb;

    wd_mux_if #(32, 4) wd_if();

    WD_MUX_2_1 dut (
        .Selected_Slave (wd_if.Selected_Slave),
        .S00_AXI_wdata  (wd_if.m0.data),
        .S00_AXI_wstrb  (wd_if.m0.strb),
        .S00_AXI_wlast  (wd_if.m0.last),
        .S00_AXI_wvalid (wd_if.m0.valid),
        .S01_AXI_wdata  (wd_if.m1.data),
        .S01_AXI_wstrb  (wd_if.m1.strb),
        .S01_AXI_wlast  (wd_if.m1.last),
        .S01_AXI_wvalid (wd_if.m1.valid),
        .Sel_S_AXI_wdata (wd_if.sel.data),
        .Sel_S_AXI_wstrb (wd_if.sel.strb),
        .Sel_S_AXI_wlast (wd_if.sel.last),
        .Sel_S_AXI_wvalid(wd_if.sel.valid)
    );

    initial begin
        wd_mux_env env = new("wd_mux_env", wd_if);
        wd_mux_test_base test = new();
        test.set_env(env);

        wd_mux_scenario scen;

        scen = new("select_master0");
        scen.m0.data  = 32'hAAAA_AAAA;
        scen.m0.strb  = 4'hF;
        scen.m0.last  = 1'b0;
        scen.m0.valid = 1'b1;
        scen.m1.data  = 32'hBBBB_BBBB;
        scen.m1.strb  = 4'h0;
        scen.m1.last  = 1'b1;
        scen.m1.valid = 1'b1;
        scen.select   = 0;
        test.send(scen);

        scen = new("select_master1");
        scen.m0.data  = 32'h1234_5678;
        scen.m0.strb  = 4'h3;
        scen.m0.last  = 1'b0;
        scen.m0.valid = 1'b1;
        scen.m1.data  = 32'hDEAD_BEEF;
        scen.m1.strb  = 4'hF;
        scen.m1.last  = 1'b1;
        scen.m1.valid = 1'b1;
        scen.select   = 1;
        test.send(scen);

        env.report();
        $finish;
    end

endmodule

