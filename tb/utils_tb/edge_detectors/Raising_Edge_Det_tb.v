`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Raising_Edge_Det Testbench
// Module Name: Raising_Edge_Det_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for Rising Edge Detector module
// 
// Dependencies: Raising_Edge_Det.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Raising_Edge_Det_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 100MHz clock
    
    // Inputs
    reg ACLK;
    reg ARESETN;
    reg Test_Singal;
    
    // Outputs
    wire Raisung;
    
    // Instantiate the Unit Under Test (UUT)
    Raising_Edge_Det uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Test_Singal(Test_Singal),
        .Raisung(Raisung)
    );
    
    // Clock generation
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end
    
    // Test stimulus
    initial begin
        // Initialize inputs
        ARESETN = 0;
        Test_Singal = 0;
        
        // Apply reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        
        // Test 1: No edge (signal stays low)
        $display("Test 1: Signal stays low");
        Test_Singal = 0;
        #(CLK_PERIOD * 3);
        
        // Test 2: Rising edge (0 -> 1)
        $display("Test 2: Rising edge 0 -> 1");
        Test_Singal = 1;
        #(CLK_PERIOD * 2);
        if (Raisung == 1) begin
            $display("PASS: Rising edge detected correctly");
        end else begin
            $display("FAIL: Rising edge not detected");
        end
        #(CLK_PERIOD * 2);
        if (Raisung == 0) begin
            $display("PASS: Raisung cleared after edge");
        end else begin
            $display("FAIL: Raisung should be cleared");
        end
        
        // Test 3: Signal stays high (no edge)
        $display("Test 3: Signal stays high");
        #(CLK_PERIOD * 3);
        if (Raisung == 0) begin
            $display("PASS: No edge detected when signal stays high");
        end else begin
            $display("FAIL: Edge detected when signal is stable high");
        end
        
        // Test 4: Falling edge (1 -> 0) - should NOT trigger rising edge
        $display("Test 4: Falling edge 1 -> 0");
        Test_Singal = 0;
        #(CLK_PERIOD * 2);
        if (Raisung == 0) begin
            $display("PASS: Falling edge does not trigger rising edge detector");
        end else begin
            $display("FAIL: Falling edge incorrectly triggered rising edge");
        end
        
        // Test 5: Multiple rising edges
        $display("Test 5: Multiple rising edges");
        #(CLK_PERIOD * 2);
        Test_Singal = 1;
        #(CLK_PERIOD * 1);
        if (Raisung == 1) begin
            $display("PASS: First rising edge detected");
        end
        Test_Singal = 0;
        #(CLK_PERIOD * 2);
        Test_Singal = 1;
        #(CLK_PERIOD * 1);
        if (Raisung == 1) begin
            $display("PASS: Second rising edge detected");
        end
        
        // Test 6: Reset behavior
        $display("Test 6: Reset behavior");
        ARESETN = 0;
        Test_Singal = 1;
        #(CLK_PERIOD * 2);
        if (Raisung == 0) begin
            $display("PASS: Raisung cleared during reset");
        end else begin
            $display("FAIL: Raisung not cleared during reset");
        end
        
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        
        // Test 7: Quick toggle (within one clock cycle)
        $display("Test 7: Quick signal toggle");
        Test_Singal = 0;
        #(CLK_PERIOD * 1);
        Test_Singal = 1;
        #(CLK_PERIOD * 1);
        Test_Singal = 0;
        #(CLK_PERIOD * 1);
        Test_Singal = 1;
        #(CLK_PERIOD * 2);
        if (Raisung == 1) begin
            $display("PASS: Rising edge detected after toggle");
        end
        
        #(CLK_PERIOD * 5);
        $display("All tests completed");
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t ARESETN=%b Test_Singal=%b Raisung=%b", 
                 $time, ARESETN, Test_Singal, Raisung);
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("Raising_Edge_Det_tb.vcd");
        $dumpvars(0, Raising_Edge_Det_tb);
    end

endmodule

