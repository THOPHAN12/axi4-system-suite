`timescale 1ns/1ps

import demux_tb_pkg::*;

module Demux_1x2_tb;

    demux_if #(1) demux_if_1();
    demux_if #(32) demux_if_32();

    Demux_1x2 #(.width(0)) uut_bit (
        .in    (demux_if_1.input_data),
        .select(demux_if_1.Selection_Line),
        .out1  (demux_if_1.output_0),
        .out2  (demux_if_1.output_1)
    );

    Demux_1x2 #(.width(31)) uut_word (
        .in    (demux_if_32.input_data),
        .select(demux_if_32.Selection_Line),
        .out1  (demux_if_32.output_0),
        .out2  (demux_if_32.output_1)
    );

    initial begin
        demux_checker #(1) checker1 = new("demux1_checker", demux_if_1);
        demux_checker #(32) checker32 = new("demux32_checker", demux_if_32);

        demux_bit_test bit_test = new();
        bit_test.set_checker(checker1);
        bit_test.run();

        demux_word_test word_test = new();
        word_test.set_checker(checker32);
        word_test.run();

        checker1.report();
        checker32.report();
        $finish;
    end

endmodule

class demux_bit_test extends demux_test_base#(1);
    function new();
        super.new("demux_bit_test");
    endfunction

    virtual task run();
        demux_scenario #(1) scen;

        scen = new("sel0");
        scen.select = 0;
        scen.input_data = 1;
        scen.out0 = 1;
        scen.out1 = 0;
        send(scen);

        scen = new("sel1");
        scen.select = 1;
        scen.input_data = 1;
        scen.out0 = 0;
        scen.out1 = 1;
        send(scen);
    endtask
endclass

class demux_word_test extends demux_test_base#(32);
    function new();
        super.new("demux_word_test");
    endfunction

    virtual task run();
        demux_scenario #(32) scen;

        scen = new("route_out0");
        scen.select = 0;
        scen.input_data = 32'hFFFF_FFFF;
        scen.out0 = 32'hFFFF_FFFF;
        scen.out1 = '0;
        send(scen);

        scen = new("route_out1");
        scen.select = 1;
        scen.input_data = 32'hA5A5_5A5A;
        scen.out0 = '0;
        scen.out1 = 32'hA5A5_5A5A;
        send(scen);
    endtask
endclass

