`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Mux_4x1_tb
// Description: Comprehensive testbench for 4-to-1 Multiplexer
//              Routes data from 4 Slaves to 1 Master (for Read channel)
//
// Test Cases:
//   1. Select each input (0-3)
//   2. Verify routing correctness
//   3. Test with different data widths
//   4. Test edge cases (all zeros, all ones)
//   5. Verify default behavior
////////////////////////////////////////////////////////////////////////////////

module Mux_4x1_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter WIDTH_32 = 31;  // 32-bit width
    parameter WIDTH_0 = 0;    // 1-bit width
    
    //==========================================================================
    // DUT Signals - 32-bit version (for RDATA)
    //==========================================================================
    reg [WIDTH_32:0] in0_32, in1_32, in2_32, in3_32;
    reg [1:0] sel_32;
    wire [WIDTH_32:0] out_32;
    
    //==========================================================================
    // DUT Signals - 1-bit version (for RVALID, RLAST)
    //==========================================================================
    reg [WIDTH_0:0] in0_0, in1_0, in2_0, in3_0;
    reg [1:0] sel_0;
    wire [WIDTH_0:0] out_0;
    
    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    //==========================================================================
    // DUT Instantiation - 32-bit
    //==========================================================================
    Mux_4x1 #(.width(WIDTH_32)) dut_32 (
        .in0(in0_32),
        .in1(in1_32),
        .in2(in2_32),
        .in3(in3_32),
        .sel(sel_32),
        .out(out_32)
    );
    
    //==========================================================================
    // DUT Instantiation - 1-bit
    //==========================================================================
    Mux_4x1 #(.width(WIDTH_0)) dut_0 (
        .in0(in0_0),
        .in1(in1_0),
        .in2(in2_0),
        .in3(in3_0),
        .sel(sel_0),
        .out(out_0)
    );
    
    //==========================================================================
    // Test Tasks
    //==========================================================================
    task test_4x1_32bit(
        input [WIDTH_32:0] input0,
        input [WIDTH_32:0] input1,
        input [WIDTH_32:0] input2,
        input [WIDTH_32:0] input3,
        input [1:0] select,
        input [WIDTH_32:0] expected,
        input [255:0] test_name
    );
        begin
            test_count = test_count + 1;
            in0_32 = input0;
            in1_32 = input1;
            in2_32 = input2;
            in3_32 = input3;
            sel_32 = select;
            #1;
            
            if (out_32 === expected) begin
                $display("[PASS] %s: sel=%0d, out=0x%08X (expected 0x%08X)", 
                         test_name, sel_32, out_32, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: sel=%0d, out=0x%08X (expected 0x%08X)", 
                         test_name, sel_32, out_32, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    task test_4x1_1bit(
        input [WIDTH_0:0] input0,
        input [WIDTH_0:0] input1,
        input [WIDTH_0:0] input2,
        input [WIDTH_0:0] input3,
        input [1:0] select,
        input [WIDTH_0:0] expected,
        input [255:0] test_name
    );
        begin
            test_count = test_count + 1;
            in0_0 = input0;
            in1_0 = input1;
            in2_0 = input2;
            in3_0 = input3;
            sel_0 = select;
            #1;
            
            if (out_0 === expected) begin
                $display("[PASS] %s: sel=%0d, out=%0b (expected %0b)", 
                         test_name, sel_0, out_0, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: sel=%0d, out=%0b (expected %0b)", 
                         test_name, sel_0, out_0, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("\n");
        $display("==========================================");
        $display("Mux_4x1 Testbench - 4-to-1 Multiplexer");
        $display("==========================================");
        $display("Testing: Routes from 4 Slaves to 1 Master");
        $display("==========================================");
        $display("");
        
        // Wait a bit
        #10;
        
        //========================================================================
        // Test 32-bit Mux (for RDATA, RRESP)
        //========================================================================
        $display("--- Testing 32-bit Mux (RDATA) ---");
        
        // Test Case 1: Select Slave 0 (sel=0)
        test_4x1_32bit(32'hDEAD_BEEF, 32'h1111_1111, 32'h2222_2222, 32'h3333_3333,
                       2'b00, 32'hDEAD_BEEF, "Select Slave 0");
        
        // Test Case 2: Select Slave 1 (sel=1)
        test_4x1_32bit(32'hDEAD_BEEF, 32'h1111_1111, 32'h2222_2222, 32'h3333_3333,
                       2'b01, 32'h1111_1111, "Select Slave 1");
        
        // Test Case 3: Select Slave 2 (sel=2)
        test_4x1_32bit(32'hDEAD_BEEF, 32'h1111_1111, 32'h2222_2222, 32'h3333_3333,
                       2'b10, 32'h2222_2222, "Select Slave 2");
        
        // Test Case 4: Select Slave 3 (sel=3)
        test_4x1_32bit(32'hDEAD_BEEF, 32'h1111_1111, 32'h2222_2222, 32'h3333_3333,
                       2'b11, 32'h3333_3333, "Select Slave 3");
        
        // Test Case 5: All inputs same value
        test_4x1_32bit(32'hAAAA_AAAA, 32'hAAAA_AAAA, 32'hAAAA_AAAA, 32'hAAAA_AAAA,
                       2'b01, 32'hAAAA_AAAA, "All inputs same");
        
        // Test Case 6: Zero values
        test_4x1_32bit(32'h0000_0000, 32'h0000_0000, 32'h0000_0000, 32'h0000_0000,
                       2'b10, 32'h0000_0000, "Zero values");
        
        // Test Case 7: Maximum values
        test_4x1_32bit(32'hFFFF_FFFF, 32'hFFFF_FFFF, 32'hFFFF_FFFF, 32'hFFFF_FFFF,
                       2'b11, 32'hFFFF_FFFF, "Maximum values");
        
        // Test Case 8: Verify all selections
        test_4x1_32bit(32'h0000_0001, 32'h0000_0010, 32'h0000_0100, 32'h0000_1000,
                       2'b00, 32'h0000_0001, "Verify sel=0");
        test_4x1_32bit(32'h0000_0001, 32'h0000_0010, 32'h0000_0100, 32'h0000_1000,
                       2'b01, 32'h0000_0010, "Verify sel=1");
        test_4x1_32bit(32'h0000_0001, 32'h0000_0010, 32'h0000_0100, 32'h0000_1000,
                       2'b10, 32'h0000_0100, "Verify sel=2");
        test_4x1_32bit(32'h0000_0001, 32'h0000_0010, 32'h0000_0100, 32'h0000_1000,
                       2'b11, 32'h0000_1000, "Verify sel=3");
        
        $display("");
        
        //========================================================================
        // Test 1-bit Mux (for RVALID, RLAST)
        //========================================================================
        $display("--- Testing 1-bit Mux (RVALID, RLAST) ---");
        
        // Test Case 9: Select Slave 0 (sel=0)
        test_4x1_1bit(1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, "Select Slave 0 (1-bit)");
        
        // Test Case 10: Select Slave 1 (sel=1)
        test_4x1_1bit(1'b0, 1'b1, 1'b0, 1'b0, 2'b01, 1'b1, "Select Slave 1 (1-bit)");
        
        // Test Case 11: Select Slave 2 (sel=2)
        test_4x1_1bit(1'b0, 1'b0, 1'b1, 1'b0, 2'b10, 1'b1, "Select Slave 2 (1-bit)");
        
        // Test Case 12: Select Slave 3 (sel=3)
        test_4x1_1bit(1'b0, 1'b0, 1'b0, 1'b1, 2'b11, 1'b1, "Select Slave 3 (1-bit)");
        
        // Test Case 13: All inputs 0
        test_4x1_1bit(1'b0, 1'b0, 1'b0, 1'b0, 2'b01, 1'b0, "All inputs 0");
        
        // Test Case 14: All inputs 1
        test_4x1_1bit(1'b1, 1'b1, 1'b1, 1'b1, 2'b10, 1'b1, "All inputs 1");
        
        $display("");
        
        // Wait a bit
        #20;
        
        // Print Summary
        $display("==========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_count);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", fail_count);
        $display("==========================================");
        
        if (fail_count == 0) begin
            $display(">>> ALL TESTS PASSED <<<");
        end else begin
            $display(">>> SOME TESTS FAILED <<<");
        end
        
        $display("");
        $finish;
    end

endmodule

