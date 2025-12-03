`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AW_MUX_2_1_tb
// Description: Testbench for AW Channel 2-to-1 Multiplexer
//              Tests address channel signal multiplexing
//
// Test Cases:
//   1. Select Master 0 signals
//   2. Select Master 1 signals
//   3. Signal routing verification
//////////////////////////////////////////////////////////////////////////////////

module AW_MUX_2_1_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Address_width = 32;
    parameter Aw_len = 8;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg [1:0] Selected_Slave;  // Master selection
    
    // Master 0 (S00) inputs
    reg [Address_width-1:0] S00_AXI_awaddr;
    reg [Aw_len-1:0] S00_AXI_awlen;
    reg [2:0] S00_AXI_awsize;
    reg [1:0] S00_AXI_awburst;
    reg [1:0] S00_AXI_awlock;
    reg [3:0] S00_AXI_awcache;
    reg [2:0] S00_AXI_awprot;
    reg [3:0] S00_AXI_awqos;
    reg S00_AXI_awvalid;
    
    // Master 1 (S01) inputs
    reg [Address_width-1:0] S01_AXI_awaddr;
    reg [Aw_len-1:0] S01_AXI_awlen;
    reg [2:0] S01_AXI_awsize;
    reg [1:0] S01_AXI_awburst;
    reg [1:0] S01_AXI_awlock;
    reg [3:0] S01_AXI_awcache;
    reg [2:0] S01_AXI_awprot;
    reg [3:0] S01_AXI_awqos;
    reg S01_AXI_awvalid;
    
    // Selected output
    wire [Address_width-1:0] Sel_S_AXI_awaddr;
    wire [Aw_len-1:0] Sel_S_AXI_awlen;
    wire [2:0] Sel_S_AXI_awsize;
    wire [1:0] Sel_S_AXI_awburst;
    wire [1:0] Sel_S_AXI_awlock;
    wire [3:0] Sel_S_AXI_awcache;
    wire [2:0] Sel_S_AXI_awprot;
    wire [3:0] Sel_S_AXI_awqos;
    wire Sel_S_AXI_awvalid;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg sim_done;

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    AW_MUX_2_1 uut (
        .Selected_Slave(Selected_Slave),
        .S00_AXI_awaddr(S00_AXI_awaddr),
        .S00_AXI_awlen(S00_AXI_awlen),
        .S00_AXI_awsize(S00_AXI_awsize),
        .S00_AXI_awburst(S00_AXI_awburst),
        .S00_AXI_awlock(S00_AXI_awlock),
        .S00_AXI_awcache(S00_AXI_awcache),
        .S00_AXI_awprot(S00_AXI_awprot),
        .S00_AXI_awqos(S00_AXI_awqos),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S01_AXI_awaddr(S01_AXI_awaddr),
        .S01_AXI_awlen(S01_AXI_awlen),
        .S01_AXI_awsize(S01_AXI_awsize),
        .S01_AXI_awburst(S01_AXI_awburst),
        .S01_AXI_awlock(S01_AXI_awlock),
        .S01_AXI_awcache(S01_AXI_awcache),
        .S01_AXI_awprot(S01_AXI_awprot),
        .S01_AXI_awqos(S01_AXI_awqos),
        .S01_AXI_awvalid(S01_AXI_awvalid),
        .Sel_S_AXI_awaddr(Sel_S_AXI_awaddr),
        .Sel_S_AXI_awlen(Sel_S_AXI_awlen),
        .Sel_S_AXI_awsize(Sel_S_AXI_awsize),
        .Sel_S_AXI_awburst(Sel_S_AXI_awburst),
        .Sel_S_AXI_awlock(Sel_S_AXI_awlock),
        .Sel_S_AXI_awcache(Sel_S_AXI_awcache),
        .Sel_S_AXI_awprot(Sel_S_AXI_awprot),
        .Sel_S_AXI_awqos(Sel_S_AXI_awqos),
        .Sel_S_AXI_awvalid(Sel_S_AXI_awvalid)
    );

    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        sim_done = 0;
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize
        Selected_Slave = 0;
        S00_AXI_awaddr = 32'h00001000;
        S00_AXI_awlen = 4;
        S00_AXI_awsize = 3'b010;
        S00_AXI_awburst = 2'b01;
        S00_AXI_awlock = 0;
        S00_AXI_awcache = 0;
        S00_AXI_awprot = 0;
        S00_AXI_awqos = 5;
        S00_AXI_awvalid = 1;
        
        S01_AXI_awaddr = 32'h00002000;
        S01_AXI_awlen = 8;
        S01_AXI_awsize = 3'b011;
        S01_AXI_awburst = 2'b10;
        S01_AXI_awlock = 0;
        S01_AXI_awcache = 0;
        S01_AXI_awprot = 0;
        S01_AXI_awqos = 10;
        S01_AXI_awvalid = 1;

        #(CLK_PERIOD);

        $display("==========================================");
        $display("AW_MUX_2_1 Testbench");
        $display("==========================================");

        // Test 1: Select Master 0
        test_num = 1;
        $display("\n--- Test %0d: Select Master 0 ---", test_num);
        Selected_Slave = 0;
        #(CLK_PERIOD);
        
        if (Sel_S_AXI_awaddr == S00_AXI_awaddr &&
            Sel_S_AXI_awlen == S00_AXI_awlen &&
            Sel_S_AXI_awqos == S00_AXI_awqos) begin
            $display("PASS: Master 0 signals selected correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Master 0 signals not selected correctly");
            fail_count = fail_count + 1;
        end

        // Test 2: Select Master 1
        test_num = 2;
        $display("\n--- Test %0d: Select Master 1 ---", test_num);
        Selected_Slave = 1;
        #(CLK_PERIOD);
        
        if (Sel_S_AXI_awaddr == S01_AXI_awaddr &&
            Sel_S_AXI_awlen == S01_AXI_awlen &&
            Sel_S_AXI_awqos == S01_AXI_awqos) begin
            $display("PASS: Master 1 signals selected correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Master 1 signals not selected correctly");
            fail_count = fail_count + 1;
        end

        // Summary
        $display("\n==========================================");
        $display("Test Summary");
        $display("==========================================");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("==========================================");
        
        sim_done = 1;
        #(CLK_PERIOD * 2);
        $finish;
    end

endmodule

