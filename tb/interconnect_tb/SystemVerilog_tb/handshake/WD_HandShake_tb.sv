`timescale 1ns/1ps

import wd_handshake_tb_pkg::*;

module WD_HandShake_tb;

    logic clk;
    wd_handshake_if wd_if(clk);

    WD_HandShake dut (
        .ACLK         (clk),
        .ARESETN      (wd_if.reset_n),
        .Valid_Signal (wd_if.valid),
        .Ready_Signal (wd_if.ready),
        .Last_Data    (wd_if.last),
        .HandShake_En (wd_if.handshake_en),
        .HandShake_Done(wd_if.handshake_done)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        wd_handshake_env env = new("wd_hs_env", wd_if);
        wd_handshake_regression test = new();
        test.set_env(env);

        env.apply_reset(3);
        test.run();

        env.get_scoreboard().report();
        #10;
        $finish;
    end

endmodule

class wd_handshake_regression extends wd_handshake_test_base;
    function new();
        super.new("wd_handshake_regression");
    endfunction

    virtual task run();
        // Single beat with wlast
        env.pulse_enable();
        env.drive_valid_ready_last(1'b1, 1'b1, 1'b1);
        check_done("Single beat handshake completes with wlast", 1'b1);

        env.idle();
        env.pulse_enable();
        env.drive_valid_ready_last(1'b1, 1'b1, 1'b0);
        check_done("Burst without last keeps handshake low", 1'b0);

        env.drive_valid_ready_last(1'b1, 1'b1, 1'b1);
        check_done("Burst completes when last asserted", 1'b1);

        env.idle();
    endtask
endclass
