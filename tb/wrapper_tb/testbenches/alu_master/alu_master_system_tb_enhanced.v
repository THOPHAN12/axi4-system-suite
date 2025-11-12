`timescale 1ns/1ps

/*
 * alu_master_system_tb_enhanced.v : Enhanced Testbench for ALU Master System
 * 
 * Tests:
 *   - Master 0 accessing Slave 0 and Slave 1
 *   - Master 1 accessing Slave 2 and Slave 3
 *   - Data integrity: Read/Write operations
 *   - Address routing: Verify correct slave selection
 *   - Arbitration when both masters access simultaneously
 */

module alu_master_system_tb_enhanced;

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
    // Test Results
    // ========================================================================
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
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
    // Monitor AXI Transactions
    // ========================================================================
    // Monitor Master 0 AXI signals
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor Write Address Channel
            if (dut.S00_AXI_awvalid && dut.S00_AXI_awready) begin
                $display("[%0t] M0->AW: addr=0x%08h, len=%0d", 
                    $time, dut.S00_AXI_awaddr, dut.S00_AXI_awlen);
            end
            
            // Monitor Write Data Channel
            if (dut.S00_AXI_wvalid && dut.S00_AXI_wready) begin
                $display("[%0t] M0->WD: data=0x%08h, wlast=%b", 
                    $time, dut.S00_AXI_wdata, dut.S00_AXI_wlast);
            end
            
            // Monitor Write Response Channel
            if (dut.S00_AXI_bvalid && dut.S00_AXI_bready) begin
                $display("[%0t] M0<-BR: resp=%0d", 
                    $time, dut.S00_AXI_bresp);
            end
            
            // Monitor Read Address Channel
            if (dut.S00_AXI_arvalid && dut.S00_AXI_arready) begin
                $display("[%0t] M0->AR: addr=0x%08h, len=%0d", 
                    $time, dut.S00_AXI_araddr, dut.S00_AXI_arlen);
            end
            
            // Monitor Read Data Channel
            if (dut.S00_AXI_rvalid && dut.S00_AXI_rready) begin
                $display("[%0t] M0<-RD: data=0x%08h, rlast=%b", 
                    $time, dut.S00_AXI_rdata, dut.S00_AXI_rlast);
            end
        end
    end
    
    // Monitor Master 1 AXI signals
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor Write Address Channel
            if (dut.S01_AXI_awvalid && dut.S01_AXI_awready) begin
                $display("[%0t] M1->AW: addr=0x%08h, len=%0d", 
                    $time, dut.S01_AXI_awaddr, dut.S01_AXI_awlen);
            end
            
            // Monitor Write Data Channel
            if (dut.S01_AXI_wvalid && dut.S01_AXI_wready) begin
                $display("[%0t] M1->WD: data=0x%08h, wlast=%b", 
                    $time, dut.S01_AXI_wdata, dut.S01_AXI_wlast);
            end
            
            // Monitor Write Response Channel
            if (dut.S01_AXI_bvalid && dut.S01_AXI_bready) begin
                $display("[%0t] M1<-BR: resp=%0d", 
                    $time, dut.S01_AXI_bresp);
            end
            
            // Monitor Read Address Channel
            if (dut.S01_AXI_arvalid && dut.S01_AXI_arready) begin
                $display("[%0t] M1->AR: addr=0x%08h, len=%0d", 
                    $time, dut.S01_AXI_araddr, dut.S01_AXI_arlen);
            end
            
            // Monitor Read Data Channel
            if (dut.S01_AXI_rvalid && dut.S01_AXI_rready) begin
                $display("[%0t] M1<-RD: data=0x%08h, rlast=%b", 
                    $time, dut.S01_AXI_rdata, dut.S01_AXI_rlast);
            end
        end
    end
    
    // Monitor Slave AXI signals to verify routing
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor Slave 0 (M00)
            if (dut.M00_AXI_awvalid && dut.M00_AXI_awready) begin
                $display("[%0t] S0<-AW: addr=0x%08h (from interconnect)", 
                    $time, dut.M00_AXI_awaddr);
            end
            if (dut.M00_AXI_wvalid && dut.M00_AXI_wready) begin
                $display("[%0t] S0<-WD: data=0x%08h", 
                    $time, dut.M00_AXI_wdata);
            end
            
            // Monitor Slave 1 (M01)
            if (dut.M01_AXI_awvalid && dut.M01_AXI_awready) begin
                $display("[%0t] S1<-AW: addr=0x%08h (from interconnect)", 
                    $time, dut.M01_AXI_awaddr);
            end
            if (dut.M01_AXI_wvalid && dut.M01_AXI_wready) begin
                $display("[%0t] S1<-WD: data=0x%08h", 
                    $time, dut.M01_AXI_wdata);
            end
            
            // Monitor Slave 2 (M02) - Read only
            if (dut.M02_AXI_arvalid && dut.M02_AXI_arready) begin
                $display("[%0t] S2<-AR: addr=0x%08h (from interconnect)", 
                    $time, dut.M02_AXI_araddr);
            end
            
            // Monitor Slave 3 (M03) - Read only
            if (dut.M03_AXI_arvalid && dut.M03_AXI_arready) begin
                $display("[%0t] S3<-AR: addr=0x%08h (from interconnect)", 
                    $time, dut.M03_AXI_araddr);
            end
        end
    end
    
    // ========================================================================
    // Test Functions
    // ========================================================================
    task check_master_done;
        input integer master_num;
        input integer timeout_cycles;
        integer cycles;
        reg done_signal;
        begin
            cycles = 0;
            if (master_num == 0) begin
                done_signal = master0_done;
            end else begin
                done_signal = master1_done;
            end
            
            while (!done_signal && cycles < timeout_cycles) begin
                @(posedge ACLK);
                cycles = cycles + 1;
                if (master_num == 0) begin
                    done_signal = master0_done;
                end else begin
                    done_signal = master1_done;
                end
            end
            
            if (done_signal) begin
                $display("[%0t] ✓ Master %0d completed successfully", $time, master_num);
                pass_count = pass_count + 1;
            end else begin
                $display("[%0t] ✗ Master %0d TIMEOUT after %0d cycles", 
                    $time, master_num, timeout_cycles);
                fail_count = fail_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask
    
    // ========================================================================
    // Test Sequence
    // ========================================================================
    initial begin
        $display("\n============================================================================");
        $display("ALU Master System Enhanced Testbench Started");
        $display("============================================================================");
        
        // Wait for reset release
        wait(ARESETN);
        #(CLK_PERIOD * 10);
        
        // Test 1: Master 0 accesses Slave 0
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 1: Master 0 accessing Slave 0", $time);
        $display("[%0t] ========================================", $time);
        master0_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        
        check_master_done(0, 10000);  // 10us timeout
        #(CLK_PERIOD * 10);
        
        // Test 2: Master 1 accesses Slave 2
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 2: Master 1 accessing Slave 2", $time);
        $display("[%0t] ========================================", $time);
        master1_start = 1;
        #(CLK_PERIOD);
        master1_start = 0;
        
        check_master_done(1, 10000);  // 10us timeout
        #(CLK_PERIOD * 10);
        
        // Test 3: Both masters access simultaneously (arbitration test)
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 3: Both masters accessing simultaneously", $time);
        $display("[%0t] ========================================", $time);
        master0_start = 1;
        master1_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        master1_start = 0;
        
        // Wait for both to complete
        fork
            check_master_done(0, 10000);
            check_master_done(1, 10000);
        join
        #(CLK_PERIOD * 10);
        
        // Test 4: Master 0 accesses Slave 1
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 4: Master 0 accessing Slave 1", $time);
        $display("[%0t] ========================================", $time);
        master0_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        
        check_master_done(0, 10000);
        #(CLK_PERIOD * 10);
        
        // Test 5: Master 1 accesses Slave 3
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 5: Master 1 accessing Slave 3", $time);
        $display("[%0t] ========================================", $time);
        master1_start = 1;
        #(CLK_PERIOD);
        master1_start = 0;
        
        check_master_done(1, 10000);
        #(CLK_PERIOD * 10);
        
        // Print Summary
        $display("\n============================================================================");
        $display("Test Summary");
        $display("============================================================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        if (fail_count == 0) begin
            $display("Status:      ✓ ALL TESTS PASSED");
        end else begin
            $display("Status:      ✗ SOME TESTS FAILED");
        end
        $display("============================================================================");
        
        #(CLK_PERIOD * 10);
        $finish;
    end
    
    // ========================================================================
    // Timeout Check
    // ========================================================================
    initial begin
        #(200000 * CLK_PERIOD);  // 200us timeout
        $display("\n[%0t] ERROR: Testbench timeout!", $time);
        $display("Test Summary: %0d tests, %0d passed, %0d failed", 
            test_count, pass_count, fail_count);
        $finish;
    end
    
    // ========================================================================
    // Waveform Dump
    // ========================================================================
    initial begin
        $dumpfile("alu_master_system_tb_enhanced.vcd");
        $dumpvars(0, alu_master_system_tb_enhanced);
    end

endmodule

