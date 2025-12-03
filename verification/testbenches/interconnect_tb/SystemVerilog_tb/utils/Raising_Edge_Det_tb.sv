`timescale 1ns/1ps

import edge_det_tb_pkg::*;

module Raising_Edge_Det_tb;

    logic clk;
    edge_det_if edge_if(clk);

    Raising_Edge_Det dut (
        .ACLK       (clk),
        .ARESETN    (edge_if.reset_n),
        .Test_Singal(edge_if.test_signal),
        .Raisung    (edge_if.rising_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        edge_det_env env = new("rising_edge_env", edge_if);
        rising_edge_test test = new();
        test.set_env(env);

        env.apply_reset(3);
        test.run();

        env.get_scoreboard().report();
        #20;
        $finish;
    end

endmodule

class rising_edge_test extends edge_det_test_base;
    function new();
        super.new("rising_edge_test");
    endfunction

    virtual task run();
        // Signal held low - no pulse
        env.set_signal(1'b0);
        env.wait_and_check("Idle low", check_rise:1'b1, rise_val:1'b0);

        // Rising edge 0 -> 1
        env.set_signal(1'b1);
        env.wait_and_check("Rising edge detected", check_rise:1'b1, rise_val:1'b1);
        env.wait_and_check("Pulse clears", check_rise:1'b1, rise_val:1'b0);

        // Hold high, ensure no additional pulses
        env.hold_cycles(2);
        env.wait_and_check("Stable high", check_rise:1'b1, rise_val:1'b0);

        // Falling edge should not trigger
        env.set_signal(1'b0);
        env.wait_and_check("Falling edge ignored", check_rise:1'b1, rise_val:1'b0);

        // Multiple rising edges
        repeat (2) begin
            env.set_signal(1'b1);
            env.wait_and_check("Multi rise pulse", check_rise:1'b1, rise_val:1'b1);
            env.wait_and_check("Pulse clears", check_rise:1'b1, rise_val:1'b0);
            env.set_signal(1'b0);
            env.wait_and_check("Return low", check_rise:1'b1, rise_val:1'b0);
        end

        // Reset behavior
        env.apply_reset(2);
        env.wait_and_check("After reset pulse high", check_rise:1'b1, rise_val:1'b0);
        env.set_signal(1'b1);
        env.wait_and_check("Edge after reset", check_rise:1'b1, rise_val:1'b1);
    endtask
endclass

