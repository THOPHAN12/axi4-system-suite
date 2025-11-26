`timescale 1ns/1ps

import read_controller_tb_pkg::*;

module Controller_tb;

    logic clk;
    read_controller_if ctrl_if(clk);

    Controller dut (
        .clkk                  (clk),
        .resett                (ctrl_if.reset),
        .slave0_addr1          (ctrl_if.slave0_addr1),
        .slave0_addr2          (ctrl_if.slave0_addr2),
        .slave1_addr1          (ctrl_if.slave1_addr1),
        .slave1_addr2          (ctrl_if.slave1_addr2),
        .slave2_addr1          (ctrl_if.slave2_addr1),
        .slave2_addr2          (ctrl_if.slave2_addr2),
        .slave3_addr1          (ctrl_if.slave3_addr1),
        .slave3_addr2          (ctrl_if.slave3_addr2),
        .M_ADDR                (ctrl_if.M_ADDR),
        .S0_ARREADY            (ctrl_if.S0_ARREADY),
        .S1_ARREADY            (ctrl_if.S1_ARREADY),
        .S2_ARREADY            (ctrl_if.S2_ARREADY),
        .S3_ARREADY            (ctrl_if.S3_ARREADY),
        .M0_ARVALID            (ctrl_if.M0_ARVALID),
        .M1_ARVALID            (ctrl_if.M1_ARVALID),
        .M0_RREADY             (ctrl_if.M0_RREADY),
        .M1_RREADY             (ctrl_if.M1_RREADY),
        .S0_RVALID             (ctrl_if.S0_RVALID),
        .S1_RVALID             (ctrl_if.S1_RVALID),
        .S2_RVALID             (ctrl_if.S2_RVALID),
        .S3_RVALID             (ctrl_if.S3_RVALID),
        .S0_RLAST              (ctrl_if.S0_RLAST),
        .S1_RLAST              (ctrl_if.S1_RLAST),
        .S2_RLAST              (ctrl_if.S2_RLAST),
        .S3_RLAST              (ctrl_if.S3_RLAST),
        .select_slave_address  (ctrl_if.select_slave_address),
        .select_data_M0        (ctrl_if.select_data_M0),
        .select_data_M1        (ctrl_if.select_data_M1),
        .select_master_address (ctrl_if.select_master_address),
        .en_S0                 (ctrl_if.en_S0),
        .en_S1                 (ctrl_if.en_S1),
        .en_S2                 (ctrl_if.en_S2),
        .en_S3                 (ctrl_if.en_S3)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        ctrl_if.reset = 1'b0;
        repeat (5) @(posedge clk);
        ctrl_if.reset = 1'b1;
    end

    initial begin
        ctrl_if.slave0_addr1 = 32'h0000_0000;
        ctrl_if.slave0_addr2 = 32'h1FFF_FFFF;
        ctrl_if.slave1_addr1 = 32'h2000_0000;
        ctrl_if.slave1_addr2 = 32'h3FFF_FFFF;
        ctrl_if.slave2_addr1 = 32'h4000_0000;
        ctrl_if.slave2_addr2 = 32'h5FFF_FFFF;
        ctrl_if.slave3_addr1 = 32'h6000_0000;
        ctrl_if.slave3_addr2 = 32'h7FFF_FFFF;
    end

    read_ctrl_env env;

    initial begin
        env = new("read_controller_env", ctrl_if);
        env.start();

        read_ctrl_regression_test test = new();
        test.set_env(env);

        @(posedge ctrl_if.reset);
        test.run();

        env.get_scoreboard().report();
        env.stop();
        #50;
        $finish;
    end

endmodule

class read_ctrl_regression_test extends read_ctrl_test_base;
    function new();
        super.new("read_ctrl_regression_test");
    endfunction

    virtual task run();
        // Address decode for all slaves
        send_scenario(make_addr_request("M0 -> S0", 32'h1000_0000, 1'b1, 1'b0, 2'b00));
        send_idle(1);

        send_scenario(make_addr_request("M0 -> S1", 32'h3000_0000, 1'b1, 1'b0, 2'b01));
        send_idle(1);

        send_scenario(make_addr_request("M0 -> S2", 32'h5000_0000, 1'b1, 1'b0, 2'b10));
        send_idle(1);

        send_scenario(make_addr_request("M0 -> S3", 32'h7000_0000, 1'b1, 1'b0, 2'b11));
        send_idle(1);

        // Invalid address (no expectations)
        read_ctrl_scenario invalid = new("Invalid address");
        invalid.addr = 32'h8000_0000;
        invalid.m0_arvalid = 1'b1;
        invalid.expected = '{default:0};
        send_scenario(invalid);
        send_idle(1);

        // Fixed-priority arbitration (M0 wins over M1)
        send_scenario(make_addr_request("Priority check", 32'h1000_0000, 1'b1, 1'b1, 2'b00, 1'b1, 1'b0));
        send_idle(1);

        // Master 1 stand-alone request
        send_scenario(make_addr_request("M1 -> S2", 32'h4800_0000, 1'b0, 1'b1, 2'b10));
        send_idle(1);

        // Data enable path for slave 0
        send_scenario(make_addr_request("Prime S0", 32'h1000_0000, 1'b1, 1'b0, 2'b00));
        send_idle(1);
        read_ctrl_scenario en_s0 = make_data_response(
            "Enable S0",
            4'b0001, 4'b0001,
            1'b1, 1'b0,
            '0, 1'b0,
            '0, 1'b0,
            2'b00, 1'b1
        );
        send_scenario(en_s0);
        send_idle(1);

        // Data routing for slave 3
        send_scenario(make_addr_request("Prime S3", 32'h6500_0000, 1'b1, 1'b0, 2'b11));
        send_idle(2);
        read_ctrl_scenario data_s3 = make_data_response(
            "Route S3 -> M0",
            4'b1000, 4'b1000,
            1'b1, 1'b0,
            2'b11, 1'b1
        );
        send_scenario(data_s3);
        send_idle(2);
    endtask
endclass

