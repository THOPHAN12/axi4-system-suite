`timescale 1ns/1ps

//==============================================================================
// Raising_Edge_Det_tb.sv
// Testbench for Raising_Edge_Det module (SystemVerilog)
//==============================================================================

module Raising_Edge_Det_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // 100MHz clock
    
    // Clock and reset
    logic ACLK = 0;
    logic ARESETN = 1;
    logic Test_Signal = 0;
    logic Raising;

    // Clock generation
    always #(CLK_PERIOD/2) ACLK = ~ACLK;

    // DUT instantiation
    Raising_Edge_Det dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Test_Singal(Test_Signal),
        .Raisung(Raising)
    );

    // Test sequence
    initial begin
        $display("============================================================================");
        $display("Raising_Edge_Det Testbench - SystemVerilog");
        $display("============================================================================");
        $display("");
        
        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        ARESETN = 0;
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD);
        $display("[%0t] Reset released", $time);
        $display("");
        
        // Test 1: Rising edge detection
        $display("[%0t] Test 1: Rising edge detection", $time);
        Test_Signal = 0;
        #(CLK_PERIOD * 2);
        Test_Signal = 1;  // Rising edge
        #(CLK_PERIOD);
        if (Raising == 1) begin
            $display("[%0t] ✓ PASS: Rising edge detected correctly", $time);
        end else begin
            $display("[%0t] ✗ FAIL: Rising edge NOT detected! Expected: 1, Got: %0d", $time, Raising);
        end
        #(CLK_PERIOD);
        $display("");
        
        // Test 2: No edge (signal stays high)
        $display("[%0t] Test 2: Signal stays high (no edge)", $time);
        Test_Signal = 1;
        #(CLK_PERIOD * 2);
        if (Raising == 0) begin
            $display("[%0t] ✓ PASS: No false edge detected", $time);
        end else begin
            $display("[%0t] ✗ FAIL: False edge detected! Expected: 0, Got: %0d", $time, Raising);
        end
        $display("");
        
        // Test 3: Falling edge (should not trigger)
        $display("[%0t] Test 3: Falling edge (should not trigger)", $time);
        Test_Signal = 1;
        #(CLK_PERIOD);
        Test_Signal = 0;  // Falling edge
        #(CLK_PERIOD);
        if (Raising == 0) begin
            $display("[%0t] ✓ PASS: Falling edge correctly ignored", $time);
        end else begin
            $display("[%0t] ✗ FAIL: Falling edge incorrectly detected! Expected: 0, Got: %0d", $time, Raising);
        end
        #(CLK_PERIOD);
        $display("");
        
        // Test 4: Multiple rising edges
        $display("[%0t] Test 4: Multiple rising edges", $time);
        for (int i = 0; i < 3; i++) begin
            Test_Signal = 0;
            #(CLK_PERIOD * 2);
            Test_Signal = 1;  // Rising edge
            #(CLK_PERIOD);
            if (Raising == 1) begin
                $display("[%0t] ✓ PASS: Rising edge %0d detected", $time, i+1);
            end else begin
                $display("[%0t] ✗ FAIL: Rising edge %0d NOT detected!", $time, i+1);
            end
            #(CLK_PERIOD);
        end
        $display("");
        
        // Test 5: Reset during operation
        $display("[%0t] Test 5: Reset during operation", $time);
        Test_Signal = 1;
        #(CLK_PERIOD);
        ARESETN = 0;
        #(CLK_PERIOD);
        if (Raising == 0) begin
            $display("[%0t] ✓ PASS: Output reset correctly", $time);
        end else begin
            $display("[%0t] ✗ FAIL: Output not reset! Expected: 0, Got: %0d", $time, Raising);
        end
        ARESETN = 1;
        #(CLK_PERIOD);
        $display("");
        
        #(CLK_PERIOD * 5);
        $display("============================================================================");
        $display("Test Complete!");
        $display("============================================================================");
        $finish;
    end

    // Monitor signals (optional)
    initial begin
        $monitor("[%0t] Test_Signal=%b, Raising=%b", $time, Test_Signal, Raising);
    end

endmodule


