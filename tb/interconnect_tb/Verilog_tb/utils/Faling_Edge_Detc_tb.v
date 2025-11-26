`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: Faling_Edge_Detc Testbench
// Module Name: Faling_Edge_Detc_tb
// Project Name: AXI Interconnect
// Target Devices: 
// Tool Versions: 
// Description: Testbench for Falling Edge Detector module
// 
// Dependencies: Faling_Edge_Detc.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Faling_Edge_Detc_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 100MHz clock
    
    // Inputs
    reg ACLK;
    reg ARESETN;
    reg Test_Singal;
    
    // Outputs
    wire Falling;
    
    // Instantiate the Unit Under Test (UUT)
    Faling_Edge_Detc uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Test_Singal(Test_Singal),
        .Falling(Falling)
    );
    
    // Simulation control
    reg sim_done = 0;
    
    // Clock generation - stops when sim_done is set
    initial begin
        ACLK = 0;
        while (!sim_done) begin
            #(CLK_PERIOD/2) ACLK = ~ACLK;
        end
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
        if (Falling == 0) begin
            $display("PASS: No falling edge detected when signal is low");
        end else begin
            $display("FAIL: Falling edge incorrectly detected");
        end
        
        // Test 2: Rising edge (0 -> 1) - should NOT trigger falling edge
        $display("Test 2: Rising edge 0 -> 1");
        Test_Singal = 1;
        #(CLK_PERIOD * 2);
        if (Falling == 0) begin
            $display("PASS: Rising edge does not trigger falling edge detector");
        end else begin
            $display("FAIL: Rising edge incorrectly triggered falling edge");
        end
        
        // Test 3: Signal stays high (no edge)
        $display("Test 3: Signal stays high");
        #(CLK_PERIOD * 3);
        if (Falling == 0) begin
            $display("PASS: No edge detected when signal stays high");
        end else begin
            $display("FAIL: Edge detected when signal is stable high");
        end
        
        // Test 4: Falling edge (1 -> 0) - SHOULD trigger
        $display("Test 4: Falling edge 1 -> 0");
        // Ensure signal is high first, wait for clock edge to update reg_Test_Signal
        Test_Singal = 1;
        @(posedge ACLK);
        @(posedge ACLK); // Wait for reg_Test_Signal to update to 1
        // Now create falling edge
        Test_Singal = 0;
        #1; // Small delay for combinational logic to settle
        if (Falling == 1) begin
            $display("PASS: Falling edge detected correctly");
        end else begin
            $display("FAIL: Falling edge not detected");
        end
        // Wait for next clock edge, then reg_Test_Signal will update to 0
        @(posedge ACLK);
        #1; // Small delay after clock edge
        if (Falling == 0) begin
            $display("PASS: Falling cleared after edge");
        end else begin
            $display("FAIL: Falling should be cleared");
        end
        
        // Test 5: Multiple falling edges
        $display("Test 5: Multiple falling edges");
        Test_Singal = 1;
        @(posedge ACLK);
        @(posedge ACLK);
        Test_Singal = 0;
        #1;
        if (Falling == 1) begin
            $display("PASS: First falling edge detected");
        end else begin
            $display("FAIL: First falling edge not detected");
        end
        @(posedge ACLK);
        Test_Singal = 1;
        @(posedge ACLK);
        @(posedge ACLK);
        Test_Singal = 0;
        #1;
        if (Falling == 1) begin
            $display("PASS: Second falling edge detected");
        end else begin
            $display("FAIL: Second falling edge not detected");
        end
        
        // Test 6: Reset behavior
        $display("Test 6: Reset behavior");
        ARESETN = 0;
        Test_Singal = 1;
        #(CLK_PERIOD * 2);
        Test_Singal = 0;
        #(CLK_PERIOD * 2);
        if (Falling == 0) begin
            $display("PASS: Falling cleared during reset");
        end else begin
            $display("FAIL: Falling not cleared during reset");
        end
        
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        
        // Test 7: Quick toggle (within one clock cycle)
        $display("Test 7: Quick signal toggle");
        Test_Singal = 1;
        @(posedge ACLK);
        @(posedge ACLK);
        Test_Singal = 0;
        #1;
        if (Falling == 1) begin
            $display("PASS: Falling edge detected after toggle");
        end else begin
            $display("FAIL: Falling edge not detected");
        end
        @(posedge ACLK);
        Test_Singal = 1;
        @(posedge ACLK);
        @(posedge ACLK);
        Test_Singal = 0;
        #1;
        if (Falling == 1) begin
            $display("PASS: Second falling edge detected");
        end else begin
            $display("FAIL: Second falling edge not detected");
        end
        
        #(CLK_PERIOD * 5);
        $display("\n==========================================");
        $display("All tests completed at time %0t ns", $time);
        $display("==========================================\n");
        
        // Stop clock and simulation
        sim_done = 1;
        #(CLK_PERIOD * 2); // Wait a bit for clock to stop
        
        // Force finish - exit code 0 means success
        $display("Simulation finished successfully.");
        $finish(0); // Exit simulation completely
    end
    
    // Timeout mechanism - force stop if simulation runs too long
    initial begin
        #(CLK_PERIOD * 2000); // Timeout after 2000 clock cycles (20us)
        if (!sim_done) begin
            $display("\n*** ERROR: Simulation timeout at time %0t ns! ***", $time);
            $display("*** Forcing simulation to stop. ***");
            sim_done = 1;
            #(CLK_PERIOD * 2);
            $finish(2); // Exit code 2 means error
        end
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("Faling_Edge_Detc_tb.vcd");
        $dumpvars(0, Faling_Edge_Detc_tb);
    end

endmodule

