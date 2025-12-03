`timescale 1ns/1ps

import demux_tb_pkg::*;

module Demux_1_2_tb;

    demux_if #(1) demux_if_1();
    demux_if #(1) demux_if_2();

    Demux_1_2 #(.Data_Width(1)) uut1 (
        .Selection_Line(demux_if_1.Selection_Line),
        .Input_1       (demux_if_1.input_data),
        .Output_1      (demux_if_1.output_0),
        .Output_2      (demux_if_1.output_1)
    );

    Demux_1_2 #(.Data_Width(1)) uut2 (
        .Selection_Line(demux_if_2.Selection_Line),
        .Input_1       (demux_if_2.input_data),
        .Output_1      (demux_if_2.output_0),
        .Output_2      (demux_if_2.output_1)
    );

    demux_checker checker1;

    initial begin
        checker1 = new("demux_checker", demux_if_1);
        demux_basic_test test = new();
        test.set_checker(checker1);
        test.run();
        checker1.report();
        $finish;
    end

endmodule

class demux_basic_test extends demux_test_base;
    function new();
        super.new("demux_basic_test");
    endfunction

    virtual task run();
        demux_scenario scen;

        scen = new("sel0_input1");
        scen.select = 0;
        scen.input_data = 1;
        scen.out0 = 1;
        scen.out1 = 0;
        send(scen);

        scen = new("sel1_input1");
        scen.select = 1;
        scen.input_data = 1;
        scen.out0 = 0;
        scen.out1 = 1;
        send(scen);
    endtask
endclass

