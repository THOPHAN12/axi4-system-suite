`timescale 1ns/1ps

import handshake_tb_pkg::*;

module AW_HandShake_Checker_tb;

    logic clk;
    handshake_if aw_if(clk);

    AW_HandShake_Checker dut (
        .ACLK           (clk),
        .ARESETN        (aw_if.reset_n),
        .Valid_Signal   (aw_if.valid),
        .Ready_Signal   (aw_if.ready),
        .Channel_Request(aw_if.channel_request),
        .HandShake_Done (aw_if.handshake_done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        handshake_env env = new("aw_hs_env", aw_if);
        aw_handshake_regression test = new();
        test.set_env(env);

        env.apply_reset(3);
        test.run();

        env.get_scoreboard().report();
        #10;
        $finish;
    end

endmodule

class aw_handshake_regression extends handshake_test_base;
    function new();
        super.new("aw_handshake_regression");
    endfunction

    virtual task run();
        // After reset handshake_done should be 1
        check_done("HandShake_Done high after reset", 1'b1);

        // Pulse channel request to start a new transfer
        env.pulse_channel_request();
        check_done("HandShake_Done cleared after request", 1'b0);

        // Valid/Ready asserted in separate cycles
        env.drive_valid_ready(1'b1, 1'b0);
        check_done("Handshake still waiting for Ready", 1'b0);

        env.drive_valid_ready(1'b1, 1'b1);
        check_done("Handshake completes when Valid & Ready", 1'b1);

        // Back-to-back request
        env.idle();
        env.pulse_channel_request();
        check_done("Second request clears flag", 1'b0);

        env.drive_valid_ready(1'b0, 1'b1);
        check_done("Only Ready asserted", 1'b0);

        env.drive_valid_ready(1'b1, 1'b1);
        check_done("Second handshake completes", 1'b1);

        env.idle();
    endtask
endclass
