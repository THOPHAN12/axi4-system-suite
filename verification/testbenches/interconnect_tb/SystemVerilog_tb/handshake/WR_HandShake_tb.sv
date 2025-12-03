`timescale 1ns/1ps

import handshake_tb_pkg::*;

module WR_HandShake_tb;

    logic clk;
    handshake_if wr_if(clk);

    WR_HandShake dut (
        .ACLK           (clk),
        .ARESETN        (wr_if.reset_n),
        .Valid_Signal   (wr_if.valid),
        .Ready_Signal   (wr_if.ready),
        .Channel_Request(wr_if.channel_request),
        .HandShake_Done (wr_if.handshake_done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        handshake_env env = new("wr_hs_env", wr_if);
        wr_handshake_regression test = new();
        test.set_env(env);

        env.apply_reset(2);
        test.run();

        env.get_scoreboard().report();
        #10;
        $finish;
    end

endmodule

class wr_handshake_regression extends handshake_test_base;
    function new();
        super.new("wr_handshake_regression");
    endfunction

    virtual task run();
        check_done("Reset sets HandShake_Done", 1'b1);

        env.pulse_channel_request();
        check_done("Request clears handshake", 1'b0);

        env.drive_valid_ready(1'b1, 1'b1);
        check_done("Valid & Ready assert handshake", 1'b1);

        env.idle();

        // Second handshake to ensure repeatability
        env.pulse_channel_request();
        check_done("Second request clears flag", 1'b0);
        env.drive_valid_ready(1'b1, 1'b1);
        check_done("Second handshake completes", 1'b1);
        env.idle();
    endtask
endclass
