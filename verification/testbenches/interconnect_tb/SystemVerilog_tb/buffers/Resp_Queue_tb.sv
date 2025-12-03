`timescale 1ns/1ps

import resp_queue_tb_pkg::*;

module Resp_Queue_tb;

    logic clk;
    resp_queue_if #(1) rq_if(clk);

    Resp_Queue #(
        .Masters_Num(2),
        .ID_Size(1)
    ) dut (
        .ACLK             (clk),
        .ARESETN          (rq_if.reset_n),
        .Master_ID        (rq_if.Master_ID),
        .Write_Resp_Grant (rq_if.Write_Resp_Grant),
        .Write_Resp_Finsh (rq_if.Write_Resp_Finsh),
        .Resp_Master_ID   (rq_if.Resp_Master_ID),
        .Resp_Master_Valid(rq_if.Resp_Master_Valid),
        .Queue_Is_Full    (rq_if.Queue_Is_Full)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rq_if.reset_n = 1'b0;
        repeat (5) @(posedge clk);
        rq_if.reset_n = 1'b1;
    end

    resp_queue_env env;

    initial begin
        env = new("resp_queue_env", rq_if);
        env.start();

        resp_queue_regression_test test = new();
        test.set_env(env);

        @(posedge rq_if.reset_n);
        test.run();

        env.get_scoreboard().report();
        env.stop();
        #20;
        $finish;
    end

endmodule

class resp_queue_regression_test extends resp_queue_test_base;
    function new();
        super.new("resp_queue_regression_test");
    endfunction

    virtual task run();
        resp_queue_scenario scen;

        scen = new("ID0 push");
        scen.master_id = 0;
        send(scen);

        scen = new("ID1 push");
        scen.master_id = 1;
        send(scen);
    endtask
endclass

