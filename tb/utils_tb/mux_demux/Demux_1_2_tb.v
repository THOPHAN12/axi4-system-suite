`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Demux_1_2 Testbench
// Module Name: Demux_1_2_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for 1-to-2 Demultiplexer module
// 
// Dependencies: Demux_1_2.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Demux_1_2_tb;

    // Test different data widths
    parameter WIDTH_1 = 1;   // 1-bit
    parameter WIDTH_2 = 2;   // 2-bit (for bresp)
    parameter WIDTH_32 = 32; // 32-bit
    
    // Test 1: 1-bit Demux (default)
    reg Selection_Line_1;
    reg [WIDTH_1-1:0] Input_1_1;
    reg [WIDTH_1-1:0] Output_1_1;
    reg [WIDTH_1-1:0] Output_2_1;
    
    Demux_1_2 #(.Data_Width(WIDTH_1)) uut_1 (
        .Selection_Line(Selection_Line_1),
        .Input_1(Input_1_1),
        .Output_1(Output_1_1),
        .Output_2(Output_2_1)
    );
    
    // Test 2: 2-bit Demux (for bresp)
    reg Selection_Line_2;
    reg [WIDTH_2-1:0] Input_1_2;
    wire [WIDTH_2-1:0] Output_1_2;
    wire [WIDTH_2-1:0] Output_2_2;
    
    Demux_1_2 #(.Data_Width(WIDTH_2)) uut_2 (
        .Selection_Line(Selection_Line_2),
        .Input_1(Input_1_2),
        .Output_1(Output_1_2),
        .Output_2(Output_2_2)
    );
    
    // Test 3: 32-bit Demux
    reg Selection_Line_32;
    reg [WIDTH_32-1:0] Input_1_32;
    wire [WIDTH_32-1:0] Output_1_32;
    wire [WIDTH_32-1:0] Output_2_32;
    
    Demux_1_2 #(.Data_Width(WIDTH_32)) uut_32 (
        .Selection_Line(Selection_Line_32),
        .Input_1(Input_1_32),
        .Output_1(Output_1_32),
        .Output_2(Output_2_32)
    );
    
    integer test_count, pass_count, fail_count;
    
    // Test stimulus
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        $display("==========================================");
        $display("Demux_1_2 Testbench Started");
        $display("==========================================");
        
        // Test 1-bit Demux
        $display("\n--- Testing 1-bit Demux ---");
        
        // Test 1.1: Selection_Line = 0, route to Output_1
        Selection_Line_1 = 0;
        Input_1_1 = 1;
        #1;
        test_count = test_count + 1;
        if (Output_1_1 == 1 && Output_2_1 == 0) begin
            $display("PASS: Test 1.1 - sel=0 routes to Output_1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.1 - sel=0, Output_1=%b, Output_2=%b", Output_1_1, Output_2_1);
            fail_count = fail_count + 1;
        end
        
        // Test 1.2: Selection_Line = 1, route to Output_2
        Selection_Line_1 = 1;
        Input_1_1 = 1;
        #1;
        test_count = test_count + 1;
        if (Output_1_1 == 0 && Output_2_1 == 1) begin
            $display("PASS: Test 1.2 - sel=1 routes to Output_2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.2 - sel=1, Output_1=%b, Output_2=%b", Output_1_1, Output_2_1);
            fail_count = fail_count + 1;
        end
        
        // Test 1.3: Input = 0, sel = 0
        Selection_Line_1 = 0;
        Input_1_1 = 0;
        #1;
        test_count = test_count + 1;
        if (Output_1_1 == 0 && Output_2_1 == 0) begin
            $display("PASS: Test 1.3 - sel=0, input=0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 1.3 - Output_1=%b, Output_2=%b", Output_1_1, Output_2_1);
            fail_count = fail_count + 1;
        end
        
        // Test 2-bit Demux (for bresp)
        $display("\n--- Testing 2-bit Demux (bresp) ---");
        
        Selection_Line_2 = 0;
        Input_1_2 = 2'b10; // SLVERR
        #1;
        test_count = test_count + 1;
        if (Output_1_2 == 2'b10 && Output_2_2 == 2'b00) begin
            $display("PASS: Test 2.1 - sel=0 routes bresp to Output_1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.1 - Output_1=%b, Output_2=%b", Output_1_2, Output_2_2);
            fail_count = fail_count + 1;
        end
        
        Selection_Line_2 = 1;
        Input_1_2 = 2'b01; // EXOKAY
        #1;
        test_count = test_count + 1;
        if (Output_1_2 == 2'b00 && Output_2_2 == 2'b01) begin
            $display("PASS: Test 2.2 - sel=1 routes bresp to Output_2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 2.2 - Output_1=%b, Output_2=%b", Output_1_2, Output_2_2);
            fail_count = fail_count + 1;
        end
        
        // Test all bresp codes
        $display("\n--- Testing all bresp codes ---");
        Selection_Line_2 = 0;
        Input_1_2 = 2'b00; // OKAY
        #1;
        test_count = test_count + 1;
        if (Output_1_2 == 2'b00) begin
            $display("PASS: Test 2.3 - OKAY (00)");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end
        
        Input_1_2 = 2'b11; // DECERR
        #1;
        test_count = test_count + 1;
        if (Output_1_2 == 2'b11) begin
            $display("PASS: Test 2.4 - DECERR (11)");
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
        end
        
        // Test 32-bit Demux
        $display("\n--- Testing 32-bit Demux ---");
        
        Selection_Line_32 = 0;
        Input_1_32 = 32'hAAAAAAAA;
        #1;
        test_count = test_count + 1;
        if (Output_1_32 == 32'hAAAAAAAA && Output_2_32 == 32'h00000000) begin
            $display("PASS: Test 3.1 - sel=0 routes 32-bit data to Output_1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.1 - Output_1=%h, Output_2=%h", Output_1_32, Output_2_32);
            fail_count = fail_count + 1;
        end
        
        Selection_Line_32 = 1;
        Input_1_32 = 32'h55555555;
        #1;
        test_count = test_count + 1;
        if (Output_1_32 == 32'h00000000 && Output_2_32 == 32'h55555555) begin
            $display("PASS: Test 3.2 - sel=1 routes 32-bit data to Output_2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 3.2 - Output_1=%h, Output_2=%h", Output_1_32, Output_2_32);
            fail_count = fail_count + 1;
        end
        
        // Test rapid switching
        $display("\n--- Testing Rapid Switching ---");
        Selection_Line_32 = 0;
        Input_1_32 = 32'h11111111;
        #1;
        Selection_Line_32 = 1;
        Input_1_32 = 32'h22222222;
        #1;
        test_count = test_count + 1;
        if (Output_2_32 == 32'h22222222) begin
            $display("PASS: Test 4.1 - Rapid switch routes to Output_2");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 4.1 - Output_2=%h", Output_2_32);
            fail_count = fail_count + 1;
        end
        
        Selection_Line_32 = 0;
        Input_1_32 = 32'h33333333;
        #1;
        test_count = test_count + 1;
        if (Output_1_32 == 32'h33333333) begin
            $display("PASS: Test 4.2 - Rapid switch back to Output_1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test 4.2 - Output_1=%h", Output_1_32);
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
        $monitor("Time=%0t sel=%b Input_1_32=%h Output_1_32=%h Output_2_32=%h",
                 $time, Selection_Line_32, Input_1_32, Output_1_32, Output_2_32);
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("Demux_1_2_tb.vcd");
        $dumpvars(0, Demux_1_2_tb);
    end

endmodule

