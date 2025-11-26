`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Mux_2x1_en Testbench
// Module Name: Mux_2x1_en_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for 2-to-1 Multiplexer with Enable module
// 
// Dependencies: Mux_2x1_en.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Mux_2x1_en_tb;

    // Test different widths
    parameter WIDTH_0 = 0;   // 1-bit
    parameter WIDTH_31 = 31; // 32-bit
    
    // Test 1: 1-bit Mux with enable
    reg sel_0;
    reg enable_0;
    reg in1_0, in2_0;
    wire [WIDTH_0:0] out_0;
    
    Mux_2x1_en #(.width(WIDTH_0)) uut_0 (
        .in1(in1_0),
        .in2(in2_0),
        .sel(sel_0),
        .enable(enable_0),
        .out(out_0)
    );
    
    // Test 2: 32-bit Mux with enable
    reg sel_31;
    reg enable_31;
    reg [WIDTH_31:0] in1_31, in2_31;
    wire [WIDTH_31:0] out_31;
    
    Mux_2x1_en #(.width(WIDTH_31)) uut_31 (
        .in1(in1_31),
        .in2(in2_31),
        .sel(sel_31),
        .enable(enable_31),
        .out(out_31)
    );
    
    integer test_count, pass_count, fail_count;
    
    // Test stimulus
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("==========================================");
        $display("Mux_2x1_en Testbench Started");
        $display("==========================================");
        
        // Test 1-bit Mux with enable
        $display("\n--- Testing 1-bit Mux with Enable ---");
        
        // Test 1.1: enable = 0, output should be 0
        enable_0 = 0;
        sel_0 = 0;
        in1_0 = 1;
        in2_0 = 0;
        #1;
        test_count = test_count + 1;
        if (out_0 == 0) begin
            $display("PASS: Test 1.1 - enable=0, output=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.1 - expected=0, got=%b", out_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.2: enable = 1, sel = 0, select in1
        enable_0 = 1;
        sel_0 = 0;
        in1_0 = 1;
        in2_0 = 0;
        #1;
        test_count = test_count + 1;
        if (out_0 == in1_0) begin
            $display("PASS: Test 1.2 - enable=1, sel=0 selects in1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.2 - expected=%b, got=%b", in1_0, out_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.3: enable = 1, sel = 1, select in2
        enable_0 = 1;
        sel_0 = 1;
        in1_0 = 0;
        in2_0 = 1;
        #1;
        test_count = test_count + 1;
        if (out_0 == in2_0) begin
            $display("PASS: Test 1.3 - enable=1, sel=1 selects in2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.3 - expected=%b, got=%b", in2_0, out_0);
            fail_count = fail_count + 1;
        end
        
        // Test 1.4: Toggle enable
        enable_0 = 1;
        sel_0 = 0;
        in1_0 = 1;
        #1;
        enable_0 = 0;
        #1;
        test_count = test_count + 1;
        if (out_0 == 0) begin
            $display("PASS: Test 1.4 - Disabling clears output");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.4 - output should be 0 when disabled");
            fail_count = fail_count + 1;
        end
        
        // Test 32-bit Mux with enable
        $display("\n--- Testing 32-bit Mux with Enable ---");
        
        // Test 2.1: enable = 0
        enable_31 = 0;
        sel_31 = 0;
        in1_31 = 32'hFFFFFFFF;
        in2_31 = 32'hAAAAAAAA;
        #1;
        test_count = test_count + 1;
        if (out_31 == 32'h00000000) begin
            $display("PASS: Test 2.1 - enable=0, output=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.1 - expected=0, got=%h", out_31);
            fail_count = fail_count + 1;
        end
        
        // Test 2.2: enable = 1, sel = 0
        enable_31 = 1;
        sel_31 = 0;
        in1_31 = 32'h12345678;
        in2_31 = 32'h87654321;
        #1;
        test_count = test_count + 1;
        if (out_31 == in1_31) begin
            $display("PASS: Test 2.2 - enable=1, sel=0 selects in1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.2 - expected=%h, got=%h", in1_31, out_31);
            fail_count = fail_count + 1;
        end
        
        // Test 2.3: enable = 1, sel = 1
        enable_31 = 1;
        sel_31 = 1;
        #1;
        test_count = test_count + 1;
        if (out_31 == in2_31) begin
            $display("PASS: Test 2.3 - enable=1, sel=1 selects in2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.3 - expected=%h, got=%h", in2_31, out_31);
            fail_count = fail_count + 1;
        end
        
        // Test 2.4: Enable/disable while inputs change
        enable_31 = 1;
        sel_31 = 0;
        in1_31 = 32'hAAAAAAAA;
        #1;
        enable_31 = 0;
        in1_31 = 32'hBBBBBBBB;
        #1;
        test_count = test_count + 1;
        if (out_31 == 0) begin
            $display("PASS: Test 2.4 - Disable prevents input change from affecting output");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.4 - Output should be 0 when disabled");
            fail_count = fail_count + 1;
        end
        
        // Test rapid enable/disable
        $display("\n--- Testing Rapid Enable/Disable ---");
        enable_31 = 1;
        sel_31 = 0;
        in1_31 = 32'h11111111;
        #1;
        enable_31 = 0;
        #1;
        enable_31 = 1;
        sel_31 = 1;
        in2_31 = 32'h22222222;
        #1;
        test_count = test_count + 1;
        if (out_31 == 32'h22222222) begin
            $display("PASS: Test 3.1 - Rapid enable/disable with sel change");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.1");
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
        $monitor("Time=%0t enable=%b sel=%b in1=%h in2=%h out=%h",
                 $time, enable_31, sel_31, in1_31, in2_31, out_31);
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("Mux_2x1_en_tb.vcd");
        $dumpvars(0, Mux_2x1_en_tb);
    end

endmodule

