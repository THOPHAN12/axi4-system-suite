`timescale 1ns/1ps

import write_resp_ctrl_tb_pkg::*;

module BR_Channel_Controller_Top_tb;

    localparam int NUM_MASTERS = 2;
    localparam int NUM_SLAVES  = 2;
    localparam int BID_W       = $clog2(NUM_MASTERS);

    logic clk;
    write_resp_ctrl_if #(NUM_MASTERS, NUM_SLAVES, BID_W) br_if(clk);

    BR_Channel_Controller_Top #(
        .Num_Of_Masters(NUM_MASTERS),
        .Num_Of_Slaves (NUM_SLAVES),
        .Master_ID_Width(BID_W),
        .AXI4_Aw_len   (8),
        .M1_ID         (0),
        .M2_ID         (1)
    ) dut (
        .Write_Data_Master      (br_if.Write_Data_Master),
        .Write_Data_Finsh       (br_if.Write_Data_Finsh),
        .Rem                    (br_if.Rem),
        .Num_Of_Compl_Bursts    (br_if.Num_Of_Compl_Bursts),
        .Is_Master_Part_Of_Split(br_if.Is_Master_Part_Of_Split),
        .Load_The_Original_Signals(br_if.Load_The_Original_Signals),
        .ACLK                   (clk),
        .ARESETN                (br_if.reset_n),
        .S00_AXI_bresp          (br_if.s_bresp[0]),
        .S00_AXI_bvalid         (br_if.s_bvalid[0]),
        .S00_AXI_bready         (br_if.s_bready[0]),
        .S01_AXI_bresp          (br_if.s_bresp[1]),
        .S01_AXI_bvalid         (br_if.s_bvalid[1]),
        .S01_AXI_bready         (br_if.s_bready[1]),
        .M00_AXI_BID            (br_if.m_bid[0]),
        .M00_AXI_bresp          (br_if.m_bresp[0]),
        .M00_AXI_bvalid         (br_if.m_bvalid[0]),
        .M00_AXI_bready         (br_if.m_bready[0]),
        .M01_AXI_BID            (br_if.m_bid[1]),
        .M01_AXI_bresp          (br_if.m_bresp[1]),
        .M01_AXI_bvalid         (br_if.m_bvalid[1]),
        .M01_AXI_bready         (br_if.m_bready[1])
    );

    // Clock & reset -----------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        br_if.reset_n = 1'b0;
        repeat (5) @(posedge clk);
        br_if.reset_n = 1'b1;
    end

    // Environment -------------------------------------------------------------
    write_resp_ctrl_env env;

    initial begin
        env = new("br_ctrl_env", br_if);
        env.start();

        wr_resp_regression_test test = new();
        test.set_env(env);

        @(posedge br_if.reset_n);
        test.run();

        env.get_scoreboard().report();
        env.stop();
        #20;
        $finish;
    end

endmodule

class wr_resp_regression_test extends write_resp_ctrl_test_base;
    function new();
        super.new("wr_resp_regression_test");
    endfunction

    virtual task run();
        wr_resp_scenario scen;

        scen = make_scenario("S0 -> M0 OKAY", 0, 0, 2'b00);
        send(scen);

        scen = make_scenario("S1 -> M1 SLVERR", 1, 1, 2'b10);
        send(scen);

        scen = make_scenario("S0 -> M1 EXOKAY", 0, 1, 2'b01);
        send(scen);
    endtask
endclass

