`timescale 1ns/1ps

import axi_tb_pkg::*;

class axi_test_case2 extends axi_test_base;
    function new();
        super.new("test_case2");
    endfunction

    virtual task run();
        $display("[%s] Master 1 basic accesses to slave 1", name);
        send_txn(1, 32'h0001_0000, 4'd0);
        #50;
        send_txn(1, 32'h0001_0010, 4'd2);
        #200;
    endtask
endclass

