`timescale 1ns/1ps

import aw_mux_tb_pkg::*;

module AW_MUX_2_1_tb;

    aw_mux_if #(32, 8) aw_if();

    AW_MUX_2_1 dut (
        .Selected_Slave (aw_if.Selected_Slave),
        .S00_AXI_awaddr (aw_if.s0.addr),
        .S00_AXI_awlen  (aw_if.s0.len),
        .S00_AXI_awsize (aw_if.s0.size),
        .S00_AXI_awburst(aw_if.s0.burst),
        .S00_AXI_awlock (aw_if.s0.lock),
        .S00_AXI_awcache(aw_if.s0.cache),
        .S00_AXI_awprot (aw_if.s0.prot),
        .S00_AXI_awqos  (aw_if.s0.qos),
        .S00_AXI_awvalid(aw_if.s0.valid),
        .S01_AXI_awaddr (aw_if.s1.addr),
        .S01_AXI_awlen  (aw_if.s1.len),
        .S01_AXI_awsize (aw_if.s1.size),
        .S01_AXI_awburst(aw_if.s1.burst),
        .S01_AXI_awlock (aw_if.s1.lock),
        .S01_AXI_awcache(aw_if.s1.cache),
        .S01_AXI_awprot (aw_if.s1.prot),
        .S01_AXI_awqos  (aw_if.s1.qos),
        .S01_AXI_awvalid(aw_if.s1.valid),
        .Sel_S_AXI_awaddr (aw_if.sel.addr),
        .Sel_S_AXI_awlen  (aw_if.sel.len),
        .Sel_S_AXI_awsize (aw_if.sel.size),
        .Sel_S_AXI_awburst(aw_if.sel.burst),
        .Sel_S_AXI_awlock (aw_if.sel.lock),
        .Sel_S_AXI_awcache(aw_if.sel.cache),
        .Sel_S_AXI_awprot (aw_if.sel.prot),
        .Sel_S_AXI_awqos  (aw_if.sel.qos),
        .Sel_S_AXI_awvalid(aw_if.sel.valid)
    );

    aw_mux_env env;

    initial begin
        env = new("aw_mux_env", aw_if);
        aw_ctrl_test test = new();
        test.set_env(env);
        test.run();
        env.report();
        $finish;
    end

endmodule

class aw_ctrl_test extends aw_mux_test_base;
    function new();
        super.new("aw_ctrl_test");
    endfunction

    virtual task run();
        aw_mux_if::aw_channel_t s0 = '{default:'0};
        aw_mux_if::aw_channel_t s1 = '{default:'0};

        s0.addr  = 32'h0000_1000;
        s0.len   = 8'd4;
        s0.qos   = 4'h5;
        s0.valid = 1'b1;
        s1.addr  = 32'h0000_2000;
        s1.len   = 8'd8;
        s1.qos   = 4'hA;
        s1.valid = 1'b1;

        aw_mux_scenario scen;

        scen = make_scenario("Select master 0", s0, s1, 0);
        send(scen);

        scen = make_scenario("Select master 1", s0, s1, 1);
        send(scen);
    endtask
endclass

