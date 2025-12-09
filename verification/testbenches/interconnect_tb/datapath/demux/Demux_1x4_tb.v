`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Demux_1x4_tb
// Description: Comprehensive testbench for 1-to-4 Demultiplexer
//              Routes data from 1 Master to 4 Slaves (for RREADY)
//
// Test Cases:
//   1. Route to each slave (0-3)
//   2. Verify only one output active at a time
//   3. Test with different selection values
//   4. Test edge cases
////////////////////////////////////////////////////////////////////////////////

module Demux_1x4_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter WIDTH_0 = 0;  // 1-bit demux
    
    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg [WIDTH_0:0] in;
    reg [1:0] sel;
    wire [WIDTH_0:0] out0, out1, out2, out3;
    
    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Demux_1x4 #(.width(WIDTH_0)) dut (
        .in(in),
        .sel(sel),
        .out0(out0),
        .out1(out1),
        .out2(out2),
        .out3(out3)
    );
    
    //==========================================================================
    // Test Task
    //==========================================================================
    task test_demux_1x4(
        input [WIDTH_0:0] input_val,
        input [1:0] select,
        input [WIDTH_0:0] expected0,
        input [WIDTH_0:0] expected1,
        input [WIDTH_0:0] expected2,
        input [WIDTH_0:0] expected3,
        input [255:0] test_name
    );
        begin
            test_count = test_count + 1;
            in = input_val;
            sel = select;
            #1;
            
            if ((out0 === expected0) && (out1 === expected1) && 
                (out2 === expected2) && (out3 === expected3)) begin
                $display("[PASS] %s: sel=%0d, in=%0b, out=[%0b,%0b,%0b,%0b]", 
                         test_name, sel, in, out0, out1, out2, out3);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: sel=%0d, in=%0b", test_name, sel, in);
                $display("       Expected: [%0b,%0b,%0b,%0b]", 
                         expected0, expected1, expected2, expected3);
                $display("       Got:      [%0b,%0b,%0b,%0b]", 
                         out0, out1, out2, out3);
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
        $display("Demux_1x4 Testbench - 1-to-4 Demultiplexer");
        $display("==========================================");
        $display("Testing: Routes from 1 Master to 4 Slaves");
        $display("==========================================");
        $display("");
        
        // Wait a bit
        #10;
        
        // Test Case 1: Route to Slave 0 (sel=0)
        test_demux_1x4(1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, "Route to Slave 0");
        
        // Test Case 2: Route to Slave 1 (sel=1)
        test_demux_1x4(1'b1, 2'b01, 1'b0, 1'b1, 1'b0, 1'b0, "Route to Slave 1");
        
        // Test Case 3: Route to Slave 2 (sel=2)
        test_demux_1x4(1'b1, 2'b10, 1'b0, 1'b0, 1'b1, 1'b0, "Route to Slave 2");
        
        // Test Case 4: Route to Slave 3 (sel=3)
        test_demux_1x4(1'b1, 2'b11, 1'b0, 1'b0, 1'b0, 1'b1, "Route to Slave 3");
        
        // Test Case 5: Input is 0, route to Slave 0
        test_demux_1x4(1'b0, 2'b00, 1'b0, 1'b0, 1'b0, 1'b0, "Input=0, Route to Slave 0");
        
        // Test Case 6: Input is 0, route to Slave 1
        test_demux_1x4(1'b0, 2'b01, 1'b0, 1'b0, 1'b0, 1'b0, "Input=0, Route to Slave 1");
        
        // Test Case 7: Verify all selections
        test_demux_1x4(1'b1, 2'b00, 1'b1, 1'b0, 1'b0, 1'b0, "Verify sel=0");
        test_demux_1x4(1'b1, 2'b01, 1'b0, 1'b1, 1'b0, 1'b0, "Verify sel=1");
        test_demux_1x4(1'b1, 2'b10, 1'b0, 1'b0, 1'b1, 1'b0, "Verify sel=2");
        test_demux_1x4(1'b1, 2'b11, 1'b0, 1'b0, 1'b0, 1'b1, "Verify sel=3");
        
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

