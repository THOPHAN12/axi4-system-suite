`timescale 1ns/1ps

/*
 * alu_master_system_tb.v : Testbench for ALU Master System
 * 
 * Tests:
 *   - Master 0 accessing Slave 0 and Slave 1
 *   - Master 1 accessing Slave 2 and Slave 3
 *   - Arbitration when both masters access simultaneously
 */

module alu_master_system_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    
    // Control signals
    reg  master0_start;
    wire master0_busy;
    wire master0_done;
    
    reg  master1_start;
    wire master1_busy;
    wire master1_done;
    
    // ========================================================================
    // DUT Instantiation
    // ========================================================================
    alu_master_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(256),
        .SLAVE0_ADDR1(32'h0000_0000),
        .SLAVE0_ADDR2(32'h3FFF_FFFF),
        .SLAVE1_ADDR1(32'h4000_0000),
        .SLAVE1_ADDR2(32'h7FFF_FFFF),
        .SLAVE2_ADDR1(32'h8000_0000),
        .SLAVE2_ADDR2(32'hBFFF_FFFF),
        .SLAVE3_ADDR1(32'hC000_0000),
        .SLAVE3_ADDR2(32'hFFFF_FFFF)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .master0_start(master0_start),
        .master0_busy(master0_busy),
        .master0_done(master0_done),
        .master1_start(master1_start),
        .master1_busy(master1_busy),
        .master1_done(master1_done)
    );
    
    // ========================================================================
    // Clock Generation
    // ========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end
    
    // ========================================================================
    // Reset Generation
    // ========================================================================
    initial begin
        ARESETN = 0;
        master0_start = 0;
        master1_start = 0;
        #(CLK_PERIOD * 10);
        ARESETN = 1;
        #(CLK_PERIOD * 5);
        $display("[%0t] Reset released", $time);
    end
    
    // ========================================================================
    // Test Sequence
    // ========================================================================
    initial begin
        $display("========================================");
        $display("ALU Master System Testbench Started");
        $display("========================================");
        
        // Wait for reset release
        wait(ARESETN);
        #(CLK_PERIOD * 10);
        
        // Test 1: Master 0 accesses Slave 0
        $display("\n[%0t] Test 1: Master 0 accessing Slave 0", $time);
        master0_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        
        wait(master0_done);
        $display("[%0t] Test 1: Master 0 done", $time);
        #(CLK_PERIOD * 10);
        
        // Test 2: Master 1 accesses Slave 2
        $display("\n[%0t] Test 2: Master 1 accessing Slave 2", $time);
        master1_start = 1;
        #(CLK_PERIOD);
        master1_start = 0;
        
        wait(master1_done);
        $display("[%0t] Test 2: Master 1 done", $time);
        #(CLK_PERIOD * 10);
        
        // Test 3: Both masters access simultaneously (arbitration test)
        $display("\n[%0t] Test 3: Both masters accessing simultaneously", $time);
        master0_start = 1;
        master1_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        master1_start = 0;
        
        wait(master0_done && master1_done);
        $display("[%0t] Test 3: Both masters done", $time);
        #(CLK_PERIOD * 10);
        
        // Test 4: Master 0 accesses Slave 1
        $display("\n[%0t] Test 4: Master 0 accessing Slave 1", $time);
        master0_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        
        wait(master0_done);
        $display("[%0t] Test 4: Master 0 done", $time);
        #(CLK_PERIOD * 10);
        
        // Test 5: Master 1 accesses Slave 3
        $display("\n[%0t] Test 5: Master 1 accessing Slave 3", $time);
        master1_start = 1;
        #(CLK_PERIOD);
        master1_start = 0;
        
        wait(master1_done);
        $display("[%0t] Test 5: Master 1 done", $time);
        #(CLK_PERIOD * 10);
        
        $display("\n========================================");
        $display("All Tests Completed");
        $display("========================================");
        #(CLK_PERIOD * 10);
        $finish;
    end
    
    // ========================================================================
    // Timeout Check
    // ========================================================================
    initial begin
        #(100000 * CLK_PERIOD);  // 100us timeout
        $display("\n[%0t] ERROR: Testbench timeout!", $time);
        $finish;
    end
    
    // ========================================================================
    // Waveform Dump (optional - uncomment if needed)
    // ========================================================================
    // initial begin
    //     $dumpfile("alu_master_system_tb.vcd");
    //     $dumpvars(0, alu_master_system_tb);
    // end

endmodule

