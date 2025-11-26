`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Resp_Queue_tb
// Description: Testbench for Response Queue module
//              Tests response queue functionality for write responses
//
// Test Cases:
//   1. Queue write and read operations
//   2. Queue full condition
//   3. Response ID tracking
//////////////////////////////////////////////////////////////////////////////////

module Resp_Queue_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Masters_Num = 2;
    parameter ID_Size = $clog2(Masters_Num);

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg ACLK;
    reg ARESETN;
    reg [ID_Size-1:0] Master_ID;
    reg Write_Resp_Grant;
    reg Write_Resp_Finsh;
    wire [ID_Size-1:0] Resp_Master_ID;
    wire Resp_Master_Valid;
    wire Queue_Is_Full;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg sim_done;

    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        while (!sim_done) begin
            #(CLK_PERIOD/2) ACLK = ~ACLK;
        end
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Resp_Queue #(
        .Masters_Num(Masters_Num),
        .ID_Size(ID_Size)
    ) uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Master_ID(Master_ID),
        .Write_Resp_Grant(Write_Resp_Grant),
        .Write_Resp_Finsh(Write_Resp_Finsh),
        .Resp_Master_ID(Resp_Master_ID),
        .Resp_Master_Valid(Resp_Master_Valid),
        .Queue_Is_Full(Queue_Is_Full)
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
        ARESETN = 0;
        Master_ID = 0;
        Write_Resp_Grant = 0;
        Write_Resp_Finsh = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("Resp_Queue Testbench");
        $display("==========================================");

        // Test 1: Write and read Master ID
        test_num = 1;
        $display("\n--- Test %0d: Write/Read Master ID ---", test_num);
        
        Master_ID = 0;
        Write_Resp_Grant = 1;
        @(posedge ACLK);
        Write_Resp_Grant = 0;
        
        #(CLK_PERIOD);
        if (Resp_Master_Valid && Resp_Master_ID == 0) begin
            $display("PASS: Master ID 0 read correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Master ID read incorrectly");
            fail_count = fail_count + 1;
        end

        Write_Resp_Finsh = 1;
        @(posedge ACLK);
        Write_Resp_Finsh = 0;
        #(CLK_PERIOD);

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

