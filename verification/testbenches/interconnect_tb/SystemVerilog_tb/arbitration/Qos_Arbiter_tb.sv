`timescale 1ns/1ps

import write_arb_tb_pkg::*;

module Qos_Arbiter_tb;

    localparam int NUM_REQ  = 2;
    localparam int ID_WIDTH = $clog2(NUM_REQ);

    logic clk;
    logic reset_n;

    write_arb_if #(NUM_REQ, ID_WIDTH) arb_if (clk);

    assign arb_if.reset_n = reset_n;

    Qos_Arbiter #(
        .Slaves_Num(NUM_REQ),
        .Slaves_ID_Size(ID_WIDTH)
    ) dut (
        .ACLK            (clk),
        .ARESETN         (reset_n),
        .S00_AXI_awvalid (arb_if.req[0]),
        .S00_AXI_awqos   (arb_if.qos[0]),
        .S01_AXI_awvalid (arb_if.req[1]),
        .S01_AXI_awqos   (arb_if.qos[1]),
        .Channel_Granted (arb_if.channel_granted),
        .Token           (arb_if.token),
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
        env = new("qos_arbiter_env", arb_if);
        env.start();

        string test_name;
        if (!$value$plusargs("TEST=%s", test_name)) begin
            test_name = "qos_priority";
        end

        write_arb_test_base test = create_test(test_name);
        if (test == null) begin
            $fatal(1, "[Qos_Arbiter_tb] Unknown TEST=%s", test_name);
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
        if (test_name == "qos_priority") begin
            return new write_arb_qos_priority_test();
        end
        return null;
    endfunction

endmodule

class write_arb_qos_priority_test extends write_arb_test_base;
    function new();
        super.new("write_arb_qos_priority_test");
    endfunction

    virtual task run();
        $display("[%s] Starting QoS priority regression", name);

        qos_t qos_default = '{default:4'h0};

        // Single requests
        send_step(2'b01, 1'b1, '0, 1'b1, 1, qos_default);
        send_step(2'b10, 1'b1, 1, 1'b1, 1, qos_default);

        // Equal QoS -> master 0 preference
        qos_t qos_equal = '{default:4'h4};
        send_step(2'b11, 1'b1, '0, 1'b1, 2, qos_equal);

        // Master 0 higher QoS
        qos_t qos_m0_hi = '{default:4'h2};
        qos_m0_hi[0] = 4'hF;
        send_step(2'b11, 1'b1, '0, 1'b1, 2, qos_m0_hi);

        // Master 1 higher QoS
        qos_t qos_m1_hi = '{default:4'h2};
        qos_m1_hi[1] = 4'hF;
        send_step(2'b11, 1'b1, 1, 1'b1, 2, qos_m1_hi);

        // Token gating: token low should block channel request
        send_step(2'b11, 1'b1, '0, 1'b0, 2, qos_equal, 1'b0);

        // Channel not granted despite requests
        send_step(2'b11, 1'b0, '0, 1'b0, 2, qos_equal);

        // Back-to-back varying QoS patterns
        repeat (4) begin
            qos_t dynamic_qos = '{default:4'h1};
            dynamic_qos[0] = $urandom_range(1, 15);
            dynamic_qos[1] = $urandom_range(1, 15);
            bit select_m0 = (dynamic_qos[0] >= dynamic_qos[1]);
            send_step(2'b11, 1'b1, select_m0 ? '0 : 1,
                      1'b1, 1, dynamic_qos);
        end

        wait_cycles(5);
    endtask
endclass

