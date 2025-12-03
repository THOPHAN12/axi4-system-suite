`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Mux_2x1 Testbench
// Module Name: Mux_2x1_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for 2-to-1 Multiplexer module
// 
// Dependencies: Mux_2x1.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Mux_2x1_tb;

    // Parameters for different widths
    parameter WIDTH_0 = 0;  // 1-bit
    parameter WIDTH_32 = 31; // 32-bit
    parameter WIDTH_8 = 7;   // 8-bit
    
    // Test 1: 1-bit Mux
    reg sel_0;
    reg in1_0, in2_0;
    wire out_0;
    
    Mux_2x1 #(.width(WIDTH_0)) uut_0 (
        .in1(in1_0),
        .in2(in2_0),
        .sel(sel_0),
        .out(out_0)
    );
    
    // Test 2: 32-bit Mux
    reg sel_32;
    reg [WIDTH_32:0] in1_32, in2_32;
    wire [WIDTH_32:0] out_32;
    
    Mux_2x1 #(.width(WIDTH_32)) uut_32 (
        .in1(in1_32),
        .in2(in2_32),
        .sel(sel_32),
        .out(out_32)
    );
    
    // Test 3: 8-bit Mux
    reg sel_8;
    reg [WIDTH_8:0] in1_8, in2_8;
    wire [WIDTH_8:0] out_8;
    
    Mux_2x1 #(.width(WIDTH_8)) uut_8 (
        .in1(in1_8),
        .in2(in2_8),
        .sel(sel_8),
        .out(out_8)
    );
    
    integer test_count, pass_count, fail_count;
    
    // Test stimulus
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("==========================================");
        $display("Mux_2x1 Testbench Started");
        $display("==========================================");
        
        // Test 1-bit Mux
        $display("\n--- Testing 1-bit Mux ---");
        
        // Test 1.1: Select input 1 (sel = 0)
        sel_0 = 0; in1_0 = 1; in2_0 = 0;
        #1;
        test_count = test_count + 1;
        if (out_0 == in1_0) begin
            $display("PASS: Test 1.1 - sel=0 selects in1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.1 - sel=0, expected=%b, got=%b", in1_0, out_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.2: Select input 2 (sel = 1)
        sel_0 = 1; in1_0 = 0; in2_0 = 1;
        #1;
        test_count = test_count + 1;
        if (out_0 == in2_0) begin
            $display("PASS: Test 1.2 - sel=1 selects in2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.2 - sel=1, expected=%b, got=%b", in2_0, out_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.3: Toggle inputs with sel=0
        sel_0 = 0; in1_0 = 0; in2_0 = 1;
        #1;
        test_count = test_count + 1;
        if (out_0 == 0) begin
            $display("PASS: Test 1.3 - sel=0, in1=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.3 - expected=0, got=%b", out_0);
            fail_count = fail_count + 1;
        end
        
        // Test 32-bit Mux
        $display("\n--- Testing 32-bit Mux ---");
        
        // Test 2.1: Select input 1 with all patterns
        sel_32 = 0;
        in1_32 = 32'hFFFFFFFF;
        in2_32 = 32'h00000000;
        #1;
        test_count = test_count + 1;
        if (out_32 == in1_32) begin
            $display("PASS: Test 2.1 - sel=0 selects in1 (all 1s)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.1 - expected=%h, got=%h", in1_32, out_32);
            fail_count = fail_count + 1;
        end
        
        // Test 2.2: Select input 2
        sel_32 = 1;
        #1;
        test_count = test_count + 1;
        if (out_32 == in2_32) begin
            $display("PASS: Test 2.2 - sel=1 selects in2 (all 0s)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.2 - expected=%h, got=%h", in2_32, out_32);
            fail_count = fail_count + 1;
        end
        
        // Test 2.3: Random patterns
        sel_32 = 0;
        in1_32 = 32'hA5A5A5A5;
        in2_32 = 32'h5A5A5A5A;
        #1;
        test_count = test_count + 1;
        if (out_32 == 32'hA5A5A5A5) begin
            $display("PASS: Test 2.3 - sel=0 with pattern A5A5A5A5");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.3 - expected=%h, got=%h", 32'hA5A5A5A5, out_32);
            fail_count = fail_count + 1;
        end
        
        sel_32 = 1;
        #1;
        test_count = test_count + 1;
        if (out_32 == 32'h5A5A5A5A) begin
            $display("PASS: Test 2.4 - sel=1 with pattern 5A5A5A5A");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.4 - expected=%h, got=%h", 32'h5A5A5A5A, out_32);
            fail_count = fail_count + 1;
        end
        
        // Test 8-bit Mux
        $display("\n--- Testing 8-bit Mux ---");
        
        // Test 3.1: Basic selection
        sel_8 = 0;
        in1_8 = 8'hFF;
        in2_8 = 8'h00;
        #1;
        test_count = test_count + 1;
        if (out_8 == in1_8) begin
            $display("PASS: Test 3.1 - sel=0 selects in1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.1 - expected=%h, got=%h", in1_8, out_8);
            fail_count = fail_count + 1;
        end
        
        sel_8 = 1;
        #1;
        test_count = test_count + 1;
        if (out_8 == in2_8) begin
            $display("PASS: Test 3.2 - sel=1 selects in2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.2 - expected=%h, got=%h", in2_8, out_8);
            fail_count = fail_count + 1;
        end
        
        // Test 3.3: Different patterns
        sel_8 = 0;
        in1_8 = 8'hAA;
        in2_8 = 8'h55;
        #1;
        test_count = test_count + 1;
        if (out_8 == 8'hAA) begin
            $display("PASS: Test 3.3 - sel=0 with pattern AA");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.3 - expected=AA, got=%h", out_8);
            fail_count = fail_count + 1;
        end
        
        // Test rapid switching
        $display("\n--- Testing Rapid Switching ---");
        sel_32 = 0; in1_32 = 32'h11111111; in2_32 = 32'h22222222;
        #1;
        sel_32 = 1;
        #1;
        test_count = test_count + 1;
        if (out_32 == 32'h22222222) begin
            $display("PASS: Test 4.1 - Rapid switch to in2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 4.1 - expected=22222222, got=%h", out_32);
            fail_count = fail_count + 1;
        end
        
        sel_32 = 0;
        #1;
        test_count = test_count + 1;
        if (out_32 == 32'h11111111) begin
            $display("PASS: Test 4.2 - Rapid switch back to in1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 4.2 - expected=11111111, got=%h", out_32);
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
        $monitor("Time=%0t sel_32=%b in1_32=%h in2_32=%h out_32=%h",
                 $time, sel_32, in1_32, in2_32, out_32);
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("Mux_2x1_tb.vcd");
        $dumpvars(0, Mux_2x1_tb);
    end

endmodule

