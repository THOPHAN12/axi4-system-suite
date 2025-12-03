`timescale 1ns/1ps

import queue_tb_pkg::*;

module Queue_tb;

    localparam int Slaves_Num = 2;
    localparam int ID_Size    = $clog2(Slaves_Num);

    logic clk;
    queue_if #(ID_Size) q_if(clk);

    Queue #(
        .Slaves_Num(Slaves_Num),
        .ID_Size   (ID_Size)
    ) dut (
        .ACLK                       (clk),
        .ARESETN                    (q_if.reset),
        .Slave_ID                   (q_if.slave_id),
        .AW_Access_Grant            (q_if.AW_Access_Grant),
        .Write_Data_Finsh           (q_if.Write_Data_Finsh),
        .Is_Transaction_Part_of_Split(q_if.Is_Transaction_Part_of_Split),
        .Queue_Is_Full              (q_if.Queue_Is_Full),
        .Write_Data_HandShake_En_Pulse(q_if.Write_Data_HandShake_En_Pulse),
        .Is_Master_Part_Of_Split    (q_if.Is_Master_Part_Of_Split),
        .Master_Valid               (q_if.Master_Valid),
        .Write_Data_Master          (q_if.Write_Data_Master)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        q_if.reset = 1'b0;
        repeat (4) @(posedge clk);
        q_if.reset = 1'b1;
    end

    queue_env env;

    initial begin
        env = new("queue_env", q_if);
        env.start();

        queue_smoke_test test = new();
        test.set_env(env);

        @(posedge q_if.reset);
        test.run();

        env.get_scoreboard().report();
        env.stop();
        #20;
        $finish;
    end

endmodule

class queue_smoke_test extends queue_test_base;
    function new();
        super.new("queue_smoke_test");
    endfunction

    virtual task run();
        // Single transaction
        send_scenario(make_push("push_id0", '0));
        wait_cycles(1);
        send_scenario(make_finish("finish_id0"));
        wait_cycles(1);

        // Multiple writes preserve FIFO order
        send_scenario(make_push("push_id0_again", '0));
        wait_cycles(1);
        send_scenario(make_push("push_id1", 1));
        wait_cycles(1);

        queue_scenario finish_first = make_finish("finish_id0_again");
        finish_first.expected.check_master_valid = 1'b0;
        finish_first.expected.check_write_data_master = 1'b0;
        send_scenario(finish_first);
        wait_cycles(1);

        queue_scenario finish_second = make_finish("finish_id1");
        finish_second.expected.check_master_valid = 1'b0;
        finish_second.expected.check_write_data_master = 1'b0;
        send_scenario(finish_second);
        wait_cycles(1);

        // Split burst handling
        queue_scenario split_push = make_push("split_push", '0);
        split_push.Is_Transaction_Part_of_Split = 1'b1;
        send_scenario(split_push);
        wait_cycles(1);

        send_scenario(make_finish("finish_split"));
        wait_cycles(1);
    endtask
endclass

