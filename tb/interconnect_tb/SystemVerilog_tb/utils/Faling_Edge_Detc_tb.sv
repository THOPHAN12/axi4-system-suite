`timescale 1ns/1ps

import edge_det_tb_pkg::*;

module Faling_Edge_Detc_tb;

    logic clk;
    edge_det_if edge_if(clk);

    Faling_Edge_Detc dut (
        .ACLK       (clk),
        .ARESETN    (edge_if.reset_n),
        .Test_Singal(edge_if.test_signal),
        .Falling    (edge_if.falling_pulse)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        edge_det_env env = new("falling_edge_env", edge_if);
        falling_edge_test test = new();
        test.set_env(env);

        env.apply_reset(3);
        test.run();

        env.get_scoreboard().report();
        #20;
        $finish;
    end

endmodule

class falling_edge_test extends edge_det_test_base;
    function new();
        super.new("falling_edge_test");
    endfunction

    virtual task run();
        // Hold low - no falling pulse
        env.set_signal(1'b0);
        env.wait_and_check("Idle low", check_fall:1'b1, fall_val:1'b0);

        // Rising edge should not trigger falling pulse
        env.set_signal(1'b1);
        env.wait_and_check("Rising ignored", check_fall:1'b1, fall_val:1'b0);

        // Falling edge detection
        env.set_signal(1'b0);
        env.wait_and_check("Falling edge detected", check_fall:1'b1, fall_val:1'b1);
        env.wait_and_check("Pulse clears", check_fall:1'b1, fall_val:1'b0);

        // Multiple falling edges
        repeat (2) begin
            env.set_signal(1'b1);
            env.wait_and_check("Hold high", check_fall:1'b1, fall_val:1'b0);
            env.set_signal(1'b0);
            env.wait_and_check("Repeated falling edge", check_fall:1'b1, fall_val:1'b1);
            env.wait_and_check("Pulse clears", check_fall:1'b1, fall_val:1'b0);
        end

        // Reset behavior
        env.apply_reset(2);
        env.wait_and_check("After reset", check_fall:1'b1, fall_val:1'b0);
        env.set_signal(1'b1);
        env.wait_and_check("High state", check_fall:1'b1, fall_val:1'b0);
        env.set_signal(1'b0);
        env.wait_and_check("Edge after reset", check_fall:1'b1, fall_val:1'b1);
    endtask
endclass

