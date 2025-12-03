`timescale 1ns/1ps

import axi_tb_pkg::*;

class axi_test_case4 extends axi_test_base;
    function new();
        super.new("test_case4");
    endfunction

    virtual task run();
        $display("[%s] Long burst coverage", name);
        send_txn(0, 32'h0000_0100, 4'd8);
        #40;
        send_txn(1, 32'h0001_0100, 4'd8);
        #400;
    endtask
endclass

