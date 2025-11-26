`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: WD_HandShake_tb
// Description: Testbench for Write Data Handshake module
//              Tests wlast detection and handshake completion
//
// Test Cases:
//   1. Single beat handshake
//   2. Burst handshake with wlast
//   3. Reset behavior
//////////////////////////////////////////////////////////////////////////////////

module WD_HandShake_tb();

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
    reg Last_Data;
    reg HandShake_En;
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
    WD_HandShake uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Valid_Signal(Valid_Signal),
        .Ready_Signal(Ready_Signal),
        .Last_Data(Last_Data),
        .HandShake_En(HandShake_En),
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
        Last_Data = 0;
        HandShake_En = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("WD_HandShake Testbench");
        $display("==========================================");

        // Test 1: Single beat handshake with wlast
        test_num = 1;
        $display("\n--- Test %0d: Single Beat with wlast ---", test_num);
        HandShake_En = 1;
        @(posedge ACLK);
        HandShake_En = 0;
        
        Valid_Signal = 1;
        Ready_Signal = 1;
        Last_Data = 1;
        @(posedge ACLK);
        
        if (HandShake_Done) begin
            $display("PASS: HandShake_Done asserted with wlast");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: HandShake_Done not asserted");
            fail_count = fail_count + 1;
        end
        
        Valid_Signal = 0;
        Ready_Signal = 0;
        Last_Data = 0;
        #(CLK_PERIOD);

        // Test 2: Burst without wlast (should not complete)
        test_num = 2;
        $display("\n--- Test %0d: Burst without wlast ---", test_num);
        HandShake_En = 1;
        @(posedge ACLK);
        HandShake_En = 0;
        
        Valid_Signal = 1;
        Ready_Signal = 1;
        Last_Data = 0;  // Not last
        @(posedge ACLK);
        
        if (!HandShake_Done) begin
            $display("PASS: HandShake_Done not asserted without wlast");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: HandShake_Done incorrectly asserted");
            fail_count = fail_count + 1;
        end
        
        // Now complete with wlast
        Last_Data = 1;
        @(posedge ACLK);
        if (HandShake_Done) begin
            $display("PASS: HandShake_Done asserted when wlast set");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: HandShake_Done not asserted with wlast");
            fail_count = fail_count + 1;
        end
        
        Valid_Signal = 0;
        Ready_Signal = 0;
        Last_Data = 0;
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

