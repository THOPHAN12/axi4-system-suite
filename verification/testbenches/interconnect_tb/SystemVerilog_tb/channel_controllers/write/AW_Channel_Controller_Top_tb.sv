`timescale 1ns/1ps

import write_controller_tb_pkg::*;

module AW_Channel_Controller_Top_tb;

    localparam int NUM_MASTERS = 2;
    localparam int NUM_SLAVES  = 2;
    localparam int ADDR_W      = 32;
    localparam int LEN_W       = 8;

    logic clk;
    write_controller_if #(NUM_MASTERS, NUM_SLAVES, ADDR_W, LEN_W) wr_if(clk);

    // DUT ---------------------------------------------------------------------
    AW_Channel_Controller_Top #(
        .Masters_Num   (NUM_MASTERS),
        .Slaves_ID_Size($clog2(NUM_SLAVES)),
        .Address_width (ADDR_W),
        .S00_Aw_len    (LEN_W),
        .S01_Aw_len    (LEN_W),
        .M00_Aw_len    (LEN_W),
        .M01_Aw_len    (LEN_W),
        .Num_Of_Slaves (NUM_SLAVES)
    ) dut (
        .AW_Access_Grant         (wr_if.AW_Access_Grant),
        .AW_Selected_Slave       (wr_if.AW_Selected_Slave),
        .Queue_Is_Full           (wr_if.Queue_Is_Full),
        .Token                   (wr_if.Token),
        .Rem                     (wr_if.Rem),
        .Num_Of_Compl_Bursts     (wr_if.Num_Of_Compl_Bursts),
        .Load_The_Original_Signals(wr_if.Load_The_Original_Signals),
        .ACLK                    (clk),
        .ARESETN                 (wr_if.reset_n),
        .S00_ACLK                (clk),
        .S00_ARESETN             (wr_if.reset_n),
        .S00_AXI_awaddr          (wr_if.s_awaddr[0]),
        .S00_AXI_awlen           (wr_if.s_awlen[0]),
        .S00_AXI_awsize          (wr_if.s_awsize[0]),
        .S00_AXI_awburst         (wr_if.s_awburst[0]),
        .S00_AXI_awlock          ('0),
        .S00_AXI_awcache         ('0),
        .S00_AXI_awprot          ('0),
        .S00_AXI_awqos           (wr_if.s_awqos[0]),
        .S00_AXI_awvalid         (wr_if.s_awvalid[0]),
        .S00_AXI_awready         (wr_if.s_awready[0]),
        .S01_ACLK                (clk),
        .S01_ARESETN             (wr_if.reset_n),
        .S01_AXI_awaddr          (wr_if.s_awaddr[1]),
        .S01_AXI_awlen           (wr_if.s_awlen[1]),
        .S01_AXI_awsize          (wr_if.s_awsize[1]),
        .S01_AXI_awburst         (wr_if.s_awburst[1]),
        .S01_AXI_awlock          ('0),
        .S01_AXI_awcache         ('0),
        .S01_AXI_awprot          ('0),
        .S01_AXI_awqos           (wr_if.s_awqos[1]),
        .S01_AXI_awvalid         (wr_if.s_awvalid[1]),
        .S01_AXI_awready         (wr_if.s_awready[1]),
        .M00_ACLK                (clk),
        .M00_ARESETN             (wr_if.reset_n),
        .M00_AXI_awaddr_ID       (),
        .M00_AXI_awaddr          (wr_if.m_awaddr[0]),
        .M00_AXI_awlen           (wr_if.m_awlen[0]),
        .M00_AXI_awsize          (wr_if.m_awsize[0]),
        .M00_AXI_awburst         (wr_if.m_awburst[0]),
        .M00_AXI_awlock          (),
        .M00_AXI_awcache         (),
        .M00_AXI_awprot          (),
        .M00_AXI_awqos           (wr_if.m_awqos[0]),
        .M00_AXI_awvalid         (wr_if.m_awvalid[0]),
        .M00_AXI_awready         (wr_if.m_awready[0]),
        .M01_ACLK                (clk),
        .M01_ARESETN             (wr_if.reset_n),
        .M01_AXI_awaddr_ID       (),
        .M01_AXI_awaddr          (wr_if.m_awaddr[1]),
        .M01_AXI_awlen           (wr_if.m_awlen[1]),
        .M01_AXI_awsize          (wr_if.m_awsize[1]),
        .M01_AXI_awburst         (wr_if.m_awburst[1]),
        .M01_AXI_awlock          (),
        .M01_AXI_awcache         (),
        .M01_AXI_awprot          (),
        .M01_AXI_awqos           (wr_if.m_awqos[1]),
        .M01_AXI_awvalid         (wr_if.m_awvalid[1]),
        .M01_AXI_awready         (wr_if.m_awready[1])
    );

    // Clock & reset -----------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        wr_if.reset_n = 1'b0;
        repeat (5) @(posedge clk);
        wr_if.reset_n = 1'b1;
    end

    // Environment -------------------------------------------------------------
    write_ctrl_env env;

    initial begin
        env = new("aw_controller_env", wr_if);
        env.start();

        aw_ctrl_regression_test test = new();
        test.set_env(env);

        @(posedge wr_if.reset_n);
        test.run();

        env.get_scoreboard().report();
        env.stop();
        #50;
        $finish;
    end

endmodule

class aw_ctrl_regression_test extends write_ctrl_test_base;
    function new();
        super.new("aw_ctrl_regression_test");
    endfunction

    virtual task run();
        write_ctrl_scenario scen;

        // Single master request -> Slave 0
        scen = new("M0 -> S0");
        scen.s_awaddr[0]  = 32'h1000_0000;
        scen.s_awvalid    = '{1'b1, 1'b0};
        scen.expected.check_aw_grant       = 1;
        scen.expected.aw_grant             = 1;
        scen.expected.check_selected_slave = 1;
        scen.expected.selected_slave       = 0;
        send(scen);

        // Both masters request, priority to master 0
        scen = new("M0 vs M1 priority");
        scen.s_awaddr    = '{32'h2000_0000, 32'h2000_0000};
        scen.s_awqos     = '{4'hF, 4'h2};
        scen.s_awvalid   = '{1'b1, 1'b1};
        scen.expected.check_aw_grant       = 1;
        scen.expected.aw_grant             = 1;
        scen.expected.check_selected_slave = 1;
        scen.expected.selected_slave       = 0;
        send(scen);

        // Queue full suppresses grant
        scen = new("Queue full");
        scen.queue_full = 1'b1;
        scen.s_awvalid  = '{1'b1, 1'b0};
        scen.expected.check_queue_full = 1;
        scen.expected.queue_full       = 1;
        scen.expected.check_aw_grant   = 1;
        scen.expected.aw_grant         = 0;
        send(scen);

        // Master 1 standalone request -> Slave 1
        scen = new("M1 -> S1");
        scen.queue_full = 1'b0;
        scen.s_awaddr   = '{32'h0, 32'h8000_0000};
        scen.s_awvalid  = '{1'b0, 1'b1};
        scen.expected.check_aw_grant       = 1;
        scen.expected.aw_grant             = 1;
        scen.expected.check_selected_slave = 1;
        scen.expected.selected_slave       = 1;
        send(scen);
    endtask
endclass

