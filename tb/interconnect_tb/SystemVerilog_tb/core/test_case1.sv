`timescale 1ns/1ps

import axi_tb_pkg::*;

class axi_test_case1 extends axi_test_base;
    function new();
        super.new("test_case1");
    endfunction

    virtual task run();
        $display("[%s] Single master smoke test", name);
        send_txn(0, 32'h0000_0004, 4'd1);
        #100;
        send_txn(0, 32'h0000_0010, 4'd3);
        #200;
    endtask
endclass

