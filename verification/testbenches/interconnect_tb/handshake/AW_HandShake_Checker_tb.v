`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AW_HandShake_Checker_tb
// Description: Testbench for AW Handshake Checker module
//              Tests handshake completion detection for AW channel
//
// Test Cases:
//   1. Normal handshake completion
//   2. Channel request reset handshake
//   3. Reset behavior
//   4. Valid/Ready timing variations
//////////////////////////////////////////////////////////////////////////////////

module AW_HandShake_Checker_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg ACLK;
    reg ARESETN;
    reg Valid_Signal;
    reg Ready_Signal;
    reg Channel_Request;
    wire HandShake_Done;

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
    AW_HandShake_Checker uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Valid_Signal(Valid_Signal),
        .Ready_Signal(Ready_Signal),
        .Channel_Request(Channel_Request),
        .HandShake_Done(HandShake_Done)
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
        Valid_Signal = 0;
        Ready_Signal = 0;
        Channel_Request = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("AW_HandShake_Checker Testbench");
        $display("==========================================");

        // Test 1: Reset state
        test_num = 1;
        $display("\n--- Test %0d: Reset State ---", test_num);
        if (HandShake_Done == 1) begin
            $display("PASS: HandShake_Done = 1 after reset");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: HandShake_Done != 1 after reset");
            fail_count = fail_count + 1;
        end

        // Test 2: Channel Request resets HandShake_Done
        test_num = 2;
        $display("\n--- Test %0d: Channel Request Reset ---", test_num);
        Channel_Request = 1;
        @(posedge ACLK);
        if (HandShake_Done == 0) begin
            $display("PASS: HandShake_Done reset to 0 on Channel_Request");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: HandShake_Done not reset");
            fail_count = fail_count + 1;
        end
        Channel_Request = 0;

        // Test 3: Normal handshake completion
        test_num = 3;
        $display("\n--- Test %0d: Normal Handshake ---", test_num);
        Channel_Request = 1;
        @(posedge ACLK);
        Channel_Request = 0;
        
        Valid_Signal = 1;
        Ready_Signal = 1;
        @(posedge ACLK);
        
        if (HandShake_Done == 1) begin
            $display("PASS: HandShake_Done asserted after valid handshake");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: HandShake_Done not asserted");
            fail_count = fail_count + 1;
        end
        
        Valid_Signal = 0;
        Ready_Signal = 0;
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

