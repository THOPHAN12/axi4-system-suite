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

// ========================================================================
// Debug monitors (handshake tracing)
// ========================================================================
// Note: Hierarchical references into DUT to observe internal AXI signals
//       Print only in early cycles to avoid huge logs
integer dbg_cycle;
initial dbg_cycle = 0;

always @(posedge alu_master_system_tb.ACLK) begin
    dbg_cycle = dbg_cycle + 1;
    if (dbg_cycle < 20000) begin
        // Master0 AR handshake at S00
        if (alu_master_system_tb.dut.S00_AXI_arvalid && alu_master_system_tb.dut.S00_AXI_arready) begin
            $display("[%0t] S00 AR HS addr=%h len=%0d", $time,
                     alu_master_system_tb.dut.S00_AXI_araddr,
                     alu_master_system_tb.dut.S00_AXI_arlen);
        end
        // Interconnect -> Slave0 AR handshake (M00)
        if (alu_master_system_tb.dut.M00_AXI_arvalid && alu_master_system_tb.dut.M00_AXI_arready) begin
            $display("[%0t] M00 AR HS addr=%h len=%0d", $time,
                     alu_master_system_tb.dut.M00_AXI_araddr,
                     alu_master_system_tb.dut.M00_AXI_arlen);
        end
        // Slave0 R channel handshake
        if (alu_master_system_tb.dut.M00_AXI_rvalid && alu_master_system_tb.dut.M00_AXI_rready) begin
            $display("[%0t] M00 R HS data=%h last=%0d resp=%0d", $time,
                     alu_master_system_tb.dut.M00_AXI_rdata,
                     alu_master_system_tb.dut.M00_AXI_rlast,
                     alu_master_system_tb.dut.M00_AXI_rresp);
        end
        // Master0 R channel observation
        if (alu_master_system_tb.dut.S00_AXI_rvalid && alu_master_system_tb.dut.S00_AXI_rready) begin
            $display("[%0t] S00 R HS data=%h last=%0d resp=%0d", $time,
                     alu_master_system_tb.dut.S00_AXI_rdata,
                     alu_master_system_tb.dut.S00_AXI_rlast,
                     alu_master_system_tb.dut.S00_AXI_rresp);
        end

        // Write channel handshakes (in case timeout is at write)
        if (alu_master_system_tb.dut.S00_AXI_awvalid && alu_master_system_tb.dut.S00_AXI_awready) begin
            $display("[%0t] S00 AW HS addr=%h len=%0d", $time,
                     alu_master_system_tb.dut.S00_AXI_awaddr,
                     alu_master_system_tb.dut.S00_AXI_awlen);
        end
        if (alu_master_system_tb.dut.M00_AXI_wvalid && alu_master_system_tb.dut.M00_AXI_wready) begin
            $display("[%0t] M00 W HS data=%h last=%0d strb=%b", $time,
                     alu_master_system_tb.dut.M00_AXI_wdata,
                     alu_master_system_tb.dut.M00_AXI_wlast,
                     alu_master_system_tb.dut.M00_AXI_wstrb);
        end
        if (alu_master_system_tb.dut.M00_AXI_bvalid && alu_master_system_tb.dut.M00_AXI_bready) begin
            $display("[%0t] M00 B HS resp=%0d", $time, alu_master_system_tb.dut.M00_AXI_bresp);
        end

        // High-level control
        if (alu_master_system_tb.master0_start) begin
            $display("[%0t] master0_start=1", $time);
        end
        if (alu_master_system_tb.master0_done) begin
            $display("[%0t] master0_done=1", $time);
        end
    end
end

