`timescale 1ns/1ps

import axi_tb_pkg::*;

class axi_test_case5 extends axi_test_base;
    function new();
        super.new("test_case5");
    endfunction

    virtual task run();
        $display("[%s] Stress mix of short and long bursts", name);
        fork
            begin
                repeat (3) begin
                    send_txn(0, 32'h0000_0200 + $urandom_range(0, 16), 4'd1);
                    #30;
                end
            end
            begin
                send_txn(1, 32'h0001_0200, 4'd5);
                #80;
                send_txn(1, 32'h0001_0300, 4'd2);
            end
        join
        #400;
    endtask
endclass

