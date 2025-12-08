`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Demux_1x2 Testbench
// Module Name: Demux_1x2_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for 1-to-2 Demultiplexer module (variant)
// 
// Dependencies: Demux_1x2.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Demux_1x2_tb;

    // Test different widths
    parameter WIDTH_0 = 0;   // 1-bit
    parameter WIDTH_31 = 31; // 32-bit
    
    // Test 1: 1-bit Demux
    reg select_0;
    reg [WIDTH_0:0] in_0;
    wire [WIDTH_0:0] out1_0;
    wire [WIDTH_0:0] out2_0;
    
    Demux_1x2 #(.width(WIDTH_0)) uut_0 (
        .in(in_0),
        .select(select_0),
        .out1(out1_0),
        .out2(out2_0)
    );
    
    // Test 2: 32-bit Demux
    reg select_31;
    reg [WIDTH_31:0] in_31;
    wire [WIDTH_31:0] out1_31;
    wire [WIDTH_31:0] out2_31;
    
    Demux_1x2 #(.width(WIDTH_31)) uut_31 (
        .in(in_31),
        .select(select_31),
        .out1(out1_31),
        .out2(out2_31)
    );
    
    integer test_count, pass_count, fail_count;
    
    // Test stimulus
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("==========================================");
        $display("Demux_1x2 Testbench Started");
        $display("==========================================");
        
        // Test 1-bit Demux
        $display("\n--- Testing 1-bit Demux ---");
        
        // Test 1.1: select = 0, route to out1
        select_0 = 0;
        in_0 = 1;
        #1;
        test_count = test_count + 1;
        if (out1_0 == 1 && out2_0 == 0) begin
            $display("PASS: Test 1.1 - select=0 routes to out1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.1 - out1=%b, out2=%b", out1_0, out2_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.2: select = 1, route to out2
        select_0 = 1;
        in_0 = 1;
        #1;
        test_count = test_count + 1;
        if (out1_0 == 0 && out2_0 == 1) begin
            $display("PASS: Test 1.2 - select=1 routes to out2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.2 - out1=%b, out2=%b", out1_0, out2_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.3: input = 0
        select_0 = 0;
        in_0 = 0;
        #1;
        test_count = test_count + 1;
        if (out1_0 == 0 && out2_0 == 0) begin
            $display("PASS: Test 1.3 - input=0, select=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.3 - out1=%b, out2=%b", out1_0, out2_0);
            fail_count = fail_count + 1;
        end
        
        // Test 32-bit Demux
        $display("\n--- Testing 32-bit Demux ---");
        
        // Test 2.1: select = 0
        select_31 = 0;
        in_31 = 32'hFFFFFFFF;
        #1;
        test_count = test_count + 1;
        if (out1_31 == 32'hFFFFFFFF && out2_31 == 32'h00000000) begin
            $display("PASS: Test 2.1 - select=0 routes to out1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.1 - out1=%h, out2=%h", out1_31, out2_31);
            fail_count = fail_count + 1;
        end
        
        // Test 2.2: select = 1
        select_31 = 1;
        in_31 = 32'hAAAAAAAA;
        #1;
        test_count = test_count + 1;
        if (out1_31 == 32'h00000000 && out2_31 == 32'hAAAAAAAA) begin
            $display("PASS: Test 2.2 - select=1 routes to out2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.2 - out1=%h, out2=%h", out1_31, out2_31);
            fail_count = fail_count + 1;
        end
        
        // Test 2.3: Various patterns
        select_31 = 0;
        in_31 = 32'h12345678;
        #1;
        test_count = test_count + 1;
        if (out1_31 == 32'h12345678) begin
            $display("PASS: Test 2.3 - Pattern 12345678 to out1");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end
        
        select_31 = 1;
        in_31 = 32'hABCDEF00;
        #1;
        test_count = test_count + 1;
        if (out2_31 == 32'hABCDEF00) begin
            $display("PASS: Test 2.4 - Pattern ABCDEF00 to out2");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end
        
        // Test rapid switching
        $display("\n--- Testing Rapid Switching ---");
        select_31 = 0;
        in_31 = 32'h11111111;
        #1;
        select_31 = 1;
        in_31 = 32'h22222222;
        #1;
        test_count = test_count + 1;
        if (out2_31 == 32'h22222222 && out1_31 == 0) begin
            $display("PASS: Test 3.1 - Rapid switch to out2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.1");
            fail_count = fail_count + 1;
        end
        
        select_31 = 0;
        in_31 = 32'h33333333;
        #1;
        test_count = test_count + 1;
        if (out1_31 == 32'h33333333 && out2_31 == 0) begin
            $display("PASS: Test 3.2 - Rapid switch back to out1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.2");
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
        $monitor("Time=%0t select=%b in=%h out1=%h out2=%h",
                 $time, select_31, in_31, out1_31, out2_31);
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("Demux_1x2_tb.vcd");
        $dumpvars(0, Demux_1x2_tb);
    end

endmodule

