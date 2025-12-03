`timescale 1ns/1ps

import write_data_ctrl_tb_pkg::*;

module WD_Channel_Controller_Top_tb;

    localparam int NUM_MASTERS = 2;
    localparam int DATA_W      = 32;
    localparam int ID_W        = 1;

    logic clk;
    write_data_ctrl_if #(NUM_MASTERS, DATA_W, ID_W) wd_if(clk);

    WD_Channel_Controller_Top #(
        .Slaves_Num              (NUM_MASTERS),
        .Slaves_ID_Size          (ID_W),
        .Address_width           (32),
        .S00_Write_data_bus_width(DATA_W),
        .S01_Write_data_bus_width(DATA_W),
        .M00_Write_data_bus_width(DATA_W)
    ) dut (
        .AW_Selected_Slave (wd_if.AW_Selected_Slave),
        .AW_Access_Grant   (wd_if.AW_Access_Grant),
        .Write_Data_Master (wd_if.Write_Data_Master),
        .Write_Data_Finsh  (wd_if.Write_Data_Finsh),
        .Queue_Is_Full     (wd_if.Queue_Is_Full),
        .ACLK              (clk),
        .ARESETN           (wd_if.reset_n),
        .S00_AXI_wdata     (wd_if.s_wdata[0]),
        .S00_AXI_wstrb     (wd_if.s_wstrb[0]),
        .S00_AXI_wlast     (wd_if.s_wlast[0]),
        .S00_AXI_wvalid    (wd_if.s_wvalid[0]),
        .S00_AXI_wready    (wd_if.s_wready[0]),
        .S01_AXI_wdata     (wd_if.s_wdata[1]),
        .S01_AXI_wstrb     (wd_if.s_wstrb[1]),
        .S01_AXI_wlast     (wd_if.s_wlast[1]),
        .S01_AXI_wvalid    (wd_if.s_wvalid[1]),
        .S01_AXI_wready    (wd_if.s_wready[1]),
        .M00_AXI_wdata     (wd_if.m_wdata),
        .M00_AXI_wstrb     (wd_if.m_wstrb),
        .M00_AXI_wlast     (wd_if.m_wlast),
        .M00_AXI_wvalid    (wd_if.m_wvalid),
        .M00_AXI_wready    (wd_if.m_wready)
    );

    // Clock & reset -----------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        wd_if.reset_n = 1'b0;
        repeat (5) @(posedge clk);
        wd_if.reset_n = 1'b1;
    end

    // Environment -------------------------------------------------------------
    write_data_ctrl_env env;

    initial begin
        env = new("wd_ctrl_env", wd_if);
        env.start();

        wd_ctrl_regression_test test = new();
        test.set_env(env);

        @(posedge wd_if.reset_n);
        test.run();

        env.get_scoreboard().report();
        env.stop();
        #20;
        $finish;
    end

endmodule

class wd_ctrl_regression_test extends write_data_ctrl_test_base;
    function new();
        super.new("wd_ctrl_regression_test");
    endfunction

    virtual task run();
        wd_scenario scen;

        // Single beat from master 0 -> slave 0
        scen = make_scenario("single beat m0", 0, 0);
        scen.add_beat(32'hDEAD_BEEF, 4'hF, 1'b1);
        scen.expect_finish = 1;
        send(scen);

        // Burst transaction from master 0
        scen = make_scenario("burst m0", 0, 0);
        for (int i = 0; i < 4; i++) begin
            scen.add_beat(32'h1000 + i, 4'hF, (i == 3));
        end
        scen.expect_finish = 1;
        send(scen);

        // Master 1 write to slave 1
        scen = make_scenario("single beat m1", 1, 1);
        scen.add_beat(32'hCAFE_BABE, 4'hF, 1'b1);
        scen.expect_finish = 1;
        send(scen);
    endtask
endclass

