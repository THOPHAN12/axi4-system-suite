`timescale 1ns/1ps

import write_addr_dec_tb_pkg::*;

module Write_Addr_Channel_Dec_tb;

    logic clk;
    write_addr_dec_if #(32, 8, 2, 1) dec_if(clk);

    Write_Addr_Channel_Dec #(
        .Address_width (32),
        .Base_Addr_Width(2),
        .Slaves_Num    (2),
        .Slaves_ID_Size(1),
        .S00_Aw_len    (8)
    ) dut (
        .Master_AXI_awaddr    (dec_if.Master_AXI_awaddr),
        .Master_AXI_awaddr_ID (dec_if.Master_AXI_awaddr_ID),
        .Master_AXI_awlen     (dec_if.Master_AXI_awlen),
        .Master_AXI_awsize    (dec_if.Master_AXI_awsize),
        .Master_AXI_awburst   (dec_if.Master_AXI_awburst),
        .Master_AXI_awlock    (dec_if.Master_AXI_awlock),
        .Master_AXI_awcache   (dec_if.Master_AXI_awcache),
        .Master_AXI_awprot    (dec_if.Master_AXI_awprot),
        .Master_AXI_awqos     (dec_if.Master_AXI_awqos),
        .Master_AXI_awvalid   (dec_if.Master_AXI_awvalid),
        .Master_AXI_awready   (dec_if.Master_AXI_awready),
        .M00_AXI_awaddr       (dec_if.slave_awaddr[0]),
        .M00_AXI_awaddr_ID    (dec_if.slave_awaddr_id[0]),
        .M00_AXI_awlen        (dec_if.slave_awlen[0]),
        .M00_AXI_awsize       (dec_if.slave_awsize[0]),
        .M00_AXI_awburst      (dec_if.slave_awburst[0]),
        .M00_AXI_awlock       (dec_if.slave_awlock[0]),
        .M00_AXI_awcache      (dec_if.slave_awcache[0]),
        .M00_AXI_awprot       (dec_if.slave_awprot[0]),
        .M00_AXI_awqos        (dec_if.slave_awqos[0]),
        .M00_AXI_awvalid      (dec_if.slave_awvalid[0]),
        .M00_AXI_awready      (dec_if.slave_awready[0]),
        .M01_AXI_awaddr       (dec_if.slave_awaddr[1]),
        .M01_AXI_awaddr_ID    (dec_if.slave_awaddr_id[1]),
        .M01_AXI_awlen        (dec_if.slave_awlen[1]),
        .M01_AXI_awsize       (dec_if.slave_awsize[1]),
        .M01_AXI_awburst      (dec_if.slave_awburst[1]),
        .M01_AXI_awlock       (dec_if.slave_awlock[1]),
        .M01_AXI_awcache      (dec_if.slave_awcache[1]),
        .M01_AXI_awprot       (dec_if.slave_awprot[1]),
        .M01_AXI_awqos        (dec_if.slave_awqos[1]),
        .M01_AXI_awvalid      (dec_if.slave_awvalid[1]),
        .M01_AXI_awready      (dec_if.slave_awready[1]),
        .Q_Enables            (dec_if.Q_Enables),
        .Sel_Slave_Ready      (dec_if.Sel_Slave_Ready)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        dec_if.reset_n = 1'b0;
        repeat (5) @(posedge clk);
        dec_if.reset_n = 1'b1;
    end

    write_addr_dec_env env;

    initial begin
        env = new("write_addr_dec_env", dec_if);
        write_addr_dec_test test = new();
        test.set_env(env);

        write_addr_dec_scenario scen;

        scen = new("decode_slave0");
        scen.addr = 32'h0000_1000;
        scen.expected_slave = 0;
        test.send(scen);

        scen = new("decode_slave1");
        scen.addr = 32'h4000_1000;
        scen.expected_slave = 1;
        test.send(scen);

        env.report();
        $finish;
    end

endmodule

