`timescale 1ns/1ps

import write_arb_tb_pkg::*;

module Write_Arbiter_RR_tb;

    localparam int NUM_REQ  = 2;
    localparam int ID_WIDTH = $clog2(NUM_REQ);

    logic clk;
    logic reset_n;

    write_arb_if #(NUM_REQ, ID_WIDTH) arb_if (clk);

    assign arb_if.reset_n = reset_n;

    Write_Arbiter_RR #(
        .Slaves_Num(NUM_REQ),
        .Slaves_ID_Size(ID_WIDTH)
    ) dut (
        .ACLK            (clk),
        .ARESETN         (reset_n),
        .S00_AXI_awvalid (arb_if.req[0]),
        .S01_AXI_awvalid (arb_if.req[1]),
        .Channel_Granted (arb_if.channel_granted),
        .Channel_Request (arb_if.channel_request),
        .Selected_Slave  (arb_if.selected_slave)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 1'b0;
        repeat (5) @(posedge clk);
        reset_n = 1'b1;
    end

    write_arb_env env;

    initial begin
        env = new("write_arbiter_rr_env", arb_if);
        env.start();

        string test_name;
        if (!$value$plusargs("TEST=%s", test_name)) begin
            test_name = "round_robin";
        end

        write_arb_test_base test = create_test(test_name);
        if (test == null) begin
            $fatal(1, "[Write_Arbiter_RR_tb] Unknown TEST=%s", test_name);
        end

        test.set_env(env);
        @(posedge reset_n);
        test.run();
        env.report();
        env.stop();
        #50;
        $finish;
    end

    function write_arb_test_base create_test(string test_name);
        if (test_name == "round_robin") begin
            return new write_arb_round_robin_test();
        end
        return null;
    endfunction

endmodule

class write_arb_round_robin_test extends write_arb_test_base;
    function new();
        super.new("write_arb_round_robin_test");
    endfunction

    virtual task run();
        $display("[%s] Starting round-robin regression", name);

        // Single requests behave like fixed priority
        send_step(2'b01, 1'b1, '0, 1'b1);
        send_step(2'b10, 1'b1, 1, 1'b1);

        // Round robin when both request
        repeat (4) begin
            send_step(2'b11, 1'b1, '0, 1'b1);
            send_step(2'b11, 1'b1, 1, 1'b1);
        end

        // No requests
        send_step(2'b00, 1'b1, '0, 1'b0);

        // Channel not granted
        send_step(2'b11, 1'b0, '0, 1'b0, 2);

        // Back-to-back alternating requests with idle gaps
        repeat (3) begin
            send_step(2'b01, 1'b1, '0, 1'b1);
            wait_cycles(1);
            send_step(2'b10, 1'b1, 1, 1'b1);
            wait_cycles(1);
        end

        // Fairness stress: master 0 holds request, master 1 sporadic
        repeat (3) begin
            send_step(2'b01, 1'b1, '0, 1'b1, 2);
            send_step(2'b11, 1'b1, 1, 1'b1);
            send_step(2'b11, 1'b1, '0, 1'b1);
        end

        wait_cycles(5);
    endtask
endclass

