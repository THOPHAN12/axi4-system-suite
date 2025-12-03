`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: BReady_MUX_2_1 Testbench
// Module Name: BReady_MUX_2_1_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for BReady 2-to-1 Multiplexer module
// 
// Dependencies: BReady_MUX_2_1.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module BReady_MUX_2_1_tb;

    // Inputs
    reg Selected_Slave;
    reg S00_AXI_bready;
    reg S01_AXI_bready;
    
    // Outputs
    wire Sele_S_AXI_bready;
    
    // Instantiate the Unit Under Test (UUT)
    BReady_MUX_2_1 uut (
        .Selected_Slave(Selected_Slave),
        .S00_AXI_bready(S00_AXI_bready),
        .S01_AXI_bready(S01_AXI_bready),
        .Sele_S_AXI_bready(Sele_S_AXI_bready)
    );
    
    integer test_count, pass_count, fail_count;
    
    // Test stimulus
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("==========================================");
        $display("BReady_MUX_2_1 Testbench Started");
        $display("==========================================");
        
        // Test 1: Selected_Slave = 0 (select S00)
        $display("\n--- Testing Selected_Slave = 0 (S00) ---");
        
        Selected_Slave = 0;
        S00_AXI_bready = 1;
        S01_AXI_bready = 0;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == S00_AXI_bready) begin
            $display("PASS: Test 1.1 - Selected_Slave=0 selects S00_AXI_bready");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.1 - expected=%b, got=%b", S00_AXI_bready, Sele_S_AXI_bready);
            fail_count = fail_count + 1;
        end
        
        S00_AXI_bready = 0;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 0) begin
            $display("PASS: Test 1.2 - S00_AXI_bready=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.2 - expected=0, got=%b", Sele_S_AXI_bready);
            fail_count = fail_count + 1;
        end
        
        // Test 2: Selected_Slave = 1 (select S01)
        $display("\n--- Testing Selected_Slave = 1 (S01) ---");
        
        Selected_Slave = 1;
        S00_AXI_bready = 0;
        S01_AXI_bready = 1;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == S01_AXI_bready) begin
            $display("PASS: Test 2.1 - Selected_Slave=1 selects S01_AXI_bready");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.1 - expected=%b, got=%b", S01_AXI_bready, Sele_S_AXI_bready);
            fail_count = fail_count + 1;
        end
        
        S01_AXI_bready = 0;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 0) begin
            $display("PASS: Test 2.2 - S01_AXI_bready=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.2 - expected=0, got=%b", Sele_S_AXI_bready);
            fail_count = fail_count + 1;
        end
        
        // Test 3: Verify S01 is ignored when Selected_Slave = 0
        $display("\n--- Testing Isolation ---");
        
        Selected_Slave = 0;
        S00_AXI_bready = 1;
        S01_AXI_bready = 1; // This should be ignored
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 1) begin
            $display("PASS: Test 3.1 - S01_AXI_bready ignored when Selected_Slave=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.1 - S01 should be ignored");
            fail_count = fail_count + 1;
        end
        
        Selected_Slave = 1;
        S00_AXI_bready = 1; // This should be ignored
        S01_AXI_bready = 0;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 0) begin
            $display("PASS: Test 3.2 - S00_AXI_bready ignored when Selected_Slave=1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.2 - S00 should be ignored");
            fail_count = fail_count + 1;
        end
        
        // Test 4: Rapid switching
        $display("\n--- Testing Rapid Switching ---");
        
        Selected_Slave = 0;
        S00_AXI_bready = 1;
        S01_AXI_bready = 0;
        #1;
        Selected_Slave = 1;
        S00_AXI_bready = 0;
        S01_AXI_bready = 1;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 1) begin
            $display("PASS: Test 4.1 - Rapid switch to S01");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 4.1 - expected=1, got=%b", Sele_S_AXI_bready);
            fail_count = fail_count + 1;
        end
        
        Selected_Slave = 0;
        S00_AXI_bready = 1;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 1) begin
            $display("PASS: Test 4.2 - Rapid switch back to S00");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 4.2");
            fail_count = fail_count + 1;
        end
        
        // Test 5: Both ready signals toggle while selection changes
        $display("\n--- Testing Signal Toggling ---");
        
        Selected_Slave = 0;
        S00_AXI_bready = 0;
        S01_AXI_bready = 0;
        #1;
        S00_AXI_bready = 1;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 1) begin
            $display("PASS: Test 5.1 - S00_AXI_bready toggle works");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end
        
        Selected_Slave = 1;
        S00_AXI_bready = 1;
        S01_AXI_bready = 0;
        #1;
        S01_AXI_bready = 1;
        #1;
        test_count = test_count + 1;
        if (Sele_S_AXI_bready == 1) begin
            $display("PASS: Test 5.2 - S01_AXI_bready toggle works");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end
        
        // Summary
        $display("\n==========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_count);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", fail_count);
        $display("==========================================");
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED!");
        end
        
        #10;
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t Selected_Slave=%b S00_bready=%b S01_bready=%b Sele_bready=%b",
                 $time, Selected_Slave, S00_AXI_bready, S01_AXI_bready, Sele_S_AXI_bready);
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("BReady_MUX_2_1_tb.vcd");
        $dumpvars(0, BReady_MUX_2_1_tb);
    end

endmodule

