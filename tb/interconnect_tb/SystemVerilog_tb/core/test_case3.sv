`timescale 1ns/1ps

import axi_tb_pkg::*;

class axi_test_case3 extends axi_test_base;
    function new();
        super.new("test_case3");
    endfunction

    virtual task run();
        $display("[%s] Concurrent master requests", name);
        fork
            begin
                send_txn(0, 32'h0000_0020, 4'd4);
                #50;
                send_txn(0, 32'h0000_0040, 4'd1);
            end
            begin
                #10;
                send_txn(1, 32'h0001_0020, 4'd3);
                #60;
                send_txn(1, 32'h0001_0030, 4'd0);
            end
        join
        #300;
    endtask
endclass

