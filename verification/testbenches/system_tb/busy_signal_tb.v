`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////////////
// Testbench: busy_signal_tb
// Description: Testbench to verify Busy signals from RISC-V Master cores
//              Tests that busy signals correctly indicate when cores are active
////////////////////////////////////////////////////////////////////////////////

module busy_signal_tb;

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter RAM_INIT_HEX = "simple_test.hex";
    parameter SIM_TIME = 10000;  // 10us simulation time
    parameter VERBOSE = 1;  // Verbose output
    
    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg                         ACLK;
    reg                         ARESETN;
    reg  [31:0]                 gpio_in;
    wire [31:0]                 gpio_out;
    wire                        uart_tx_valid;
    wire [7:0]                  uart_tx_byte;
    wire                        spi_cs_n;
    wire                        spi_sclk;
    wire                        spi_mosi;
    reg                         spi_miso;
    
    // Debug signals
    wire [31:0]                 serv0_debug_pc;
    wire [31:0]                 serv0_debug_r1;
    wire [31:0]                 serv0_debug_r2;
    wire [31:0]                 serv1_debug_pc;
    wire [31:0]                 serv1_debug_r1;
    wire [31:0]                 serv1_debug_r2;
    
    // Busy signals - NEW
    wire                        serv0_busy;
    wire                        serv1_busy;
    
    //==========================================================================
    // Test Control and Statistics
    //==========================================================================
    integer cycle_count;
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Busy signal monitoring
    integer serv0_busy_cycles;
    integer serv1_busy_cycles;
    integer serv0_busy_transitions;
    integer serv1_busy_transitions;
    reg serv0_prev_busy;
    reg serv1_prev_busy;
    
    // Transaction monitoring
    integer serv0_instr_fetches;
    integer serv1_instr_fetches;
    integer serv0_data_reads;
    integer serv1_data_reads;
    integer serv0_data_writes;
    integer serv1_data_writes;
    
    // Busy correlation tracking
    integer serv0_busy_with_instr;
    integer serv0_busy_with_data;
    integer serv1_busy_with_instr;
    integer serv1_busy_with_data;
    
    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    //==========================================================================
    // Reset Generation
    //==========================================================================
    initial begin
        ARESETN = 0;
        gpio_in = 0;
        spi_miso = 0;
        cycle_count = 0;
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize busy monitoring
        serv0_busy_cycles = 0;
        serv1_busy_cycles = 0;
        serv0_busy_transitions = 0;
        serv1_busy_transitions = 0;
        serv0_prev_busy = 0;
        serv1_prev_busy = 0;
        
        // Initialize transaction counters
        serv0_instr_fetches = 0;
        serv1_instr_fetches = 0;
        serv0_data_reads = 0;
        serv1_data_reads = 0;
        serv0_data_writes = 0;
        serv1_data_writes = 0;
        
        // Initialize correlation counters
        serv0_busy_with_instr = 0;
        serv0_busy_with_data = 0;
        serv1_busy_with_instr = 0;
        serv1_busy_with_data = 0;
        
        // Hold reset for 10 cycles
        repeat(10) @(posedge ACLK);
        ARESETN = 1;
        
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] BUSY SIGNAL TEST STARTED", $time);
        $display("[%0t] ========================================\n", $time);
        
        // Wait for cores to start
        repeat(100) @(posedge ACLK);
        
        // Run test for specified time
        repeat(SIM_TIME) @(posedge ACLK);
        
        // Print results
        print_results();
        
        $finish;
    end

    //==========================================================================
    // Cycle Counter
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            cycle_count <= cycle_count + 1;
        end
    end

    //==========================================================================
    // Busy Signal Monitoring
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Count busy cycles
            if (serv0_busy) begin
                serv0_busy_cycles = serv0_busy_cycles + 1;
            end
            if (serv1_busy) begin
                serv1_busy_cycles = serv1_busy_cycles + 1;
            end
            
            // Count busy transitions (0->1 and 1->0)
            if (serv0_busy !== serv0_prev_busy) begin
                serv0_busy_transitions = serv0_busy_transitions + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV0] Busy transition: %b -> %b", 
                             $time, serv0_prev_busy, serv0_busy);
                end
            end
            if (serv1_busy !== serv1_prev_busy) begin
                serv1_busy_transitions = serv1_busy_transitions + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV1] Busy transition: %b -> %b", 
                             $time, serv1_prev_busy, serv1_busy);
                end
            end
            
            serv0_prev_busy = serv0_busy;
            serv1_prev_busy = serv1_busy;
        end
    end

    //==========================================================================
    // Transaction Monitoring - Instruction Fetches
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor instruction fetch transactions
            // Check AXI read address channel for instruction bus
            // Access through internal wires in dual_serv_axi_system
            if (dut.S0_M_ARVALID && dut.S0_M_ARREADY) begin
                serv0_instr_fetches = serv0_instr_fetches + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV0] Instruction fetch: Addr=0x%08h, Busy=%b", 
                             $time, dut.S0_M_ARADDR, serv0_busy);
                end
                // Check if busy is asserted during instruction fetch
                if (serv0_busy) begin
                    serv0_busy_with_instr = serv0_busy_with_instr + 1;
                end
            end
            
            if (dut.S1_M_ARVALID && dut.S1_M_ARREADY) begin
                serv1_instr_fetches = serv1_instr_fetches + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV1] Instruction fetch: Addr=0x%08h, Busy=%b", 
                             $time, dut.S1_M_ARADDR, serv1_busy);
                end
                // Check if busy is asserted during instruction fetch
                if (serv1_busy) begin
                    serv1_busy_with_instr = serv1_busy_with_instr + 1;
                end
            end
        end
    end

    //==========================================================================
    // Transaction Monitoring - Data Reads
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor data read transactions
            // Access through internal wires in dual_serv_axi_system
            if (dut.S0_M_ARVALID_D && dut.S0_M_ARREADY_D) begin
                serv0_data_reads = serv0_data_reads + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV0] Data read: Addr=0x%08h, Busy=%b", 
                             $time, dut.S0_M_ARADDR_D, serv0_busy);
                end
                // Check if busy is asserted during data read
                if (serv0_busy) begin
                    serv0_busy_with_data = serv0_busy_with_data + 1;
                end
            end
            
            if (dut.S1_M_ARVALID_D && dut.S1_M_ARREADY_D) begin
                serv1_data_reads = serv1_data_reads + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV1] Data read: Addr=0x%08h, Busy=%b", 
                             $time, dut.S1_M_ARADDR_D, serv1_busy);
                end
                // Check if busy is asserted during data read
                if (serv1_busy) begin
                    serv1_busy_with_data = serv1_busy_with_data + 1;
                end
            end
        end
    end

    //==========================================================================
    // Transaction Monitoring - Data Writes
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor data write transactions
            // Access through internal wires in dual_serv_axi_system
            if (dut.S0_M_AWVALID_D && dut.S0_M_AWREADY_D &&
                dut.S0_M_WVALID_D && dut.S0_M_WREADY_D) begin
                serv0_data_writes = serv0_data_writes + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV0] Data write: Addr=0x%08h, Data=0x%08h, Busy=%b", 
                             $time, dut.S0_M_AWADDR, 
                             dut.S0_M_WDATA_D, serv0_busy);
                end
                // Check if busy is asserted during data write
                if (serv0_busy) begin
                    serv0_busy_with_data = serv0_busy_with_data + 1;
                end
            end
            
            if (dut.S1_M_AWVALID_D && dut.S1_M_AWREADY_D &&
                dut.S1_M_WVALID_D && dut.S1_M_WREADY_D) begin
                serv1_data_writes = serv1_data_writes + 1;
                if (VERBOSE) begin
                    $display("[%0t] [SERV1] Data write: Addr=0x%08h, Data=0x%08h, Busy=%b", 
                             $time, dut.S1_M_AWADDR, 
                             dut.S1_M_WDATA_D, serv1_busy);
                end
                // Check if busy is asserted during data write
                if (serv1_busy) begin
                    serv1_busy_with_data = serv1_busy_with_data + 1;
                end
            end
        end
    end

    //==========================================================================
    // Test Verification Tasks
    //==========================================================================
    task print_results;
        begin
            $display("\n[%0t] ========================================", $time);
            $display("[%0t] BUSY SIGNAL TEST RESULTS", $time);
            $display("[%0t] ========================================", $time);
            
            // SERV0 Results
            $display("\n[%0t] --- SERV0 (Core 0) ---", $time);
            $display("[%0t] Busy cycles: %0d / %0d (%.1f%%)", 
                     $time, serv0_busy_cycles, cycle_count, 
                     (serv0_busy_cycles * 100.0) / cycle_count);
            $display("[%0t] Busy transitions: %0d", $time, serv0_busy_transitions);
            $display("[%0t] Instruction fetches: %0d", $time, serv0_instr_fetches);
            $display("[%0t] Data reads: %0d", $time, serv0_data_reads);
            $display("[%0t] Data writes: %0d", $time, serv0_data_writes);
            $display("[%0t] Busy during instr: %0d / %0d (%.1f%%)", 
                     $time, serv0_busy_with_instr, serv0_instr_fetches,
                     serv0_instr_fetches > 0 ? (serv0_busy_with_instr * 100.0) / serv0_instr_fetches : 0);
            $display("[%0t] Busy during data: %0d / %0d (%.1f%%)", 
                     $time, serv0_busy_with_data, (serv0_data_reads + serv0_data_writes),
                     (serv0_data_reads + serv0_data_writes) > 0 ? 
                     (serv0_busy_with_data * 100.0) / (serv0_data_reads + serv0_data_writes) : 0);
            
            // SERV1 Results
            $display("\n[%0t] --- SERV1 (Core 1) ---", $time);
            $display("[%0t] Busy cycles: %0d / %0d (%.1f%%)", 
                     $time, serv1_busy_cycles, cycle_count, 
                     (serv1_busy_cycles * 100.0) / cycle_count);
            $display("[%0t] Busy transitions: %0d", $time, serv1_busy_transitions);
            $display("[%0t] Instruction fetches: %0d", $time, serv1_instr_fetches);
            $display("[%0t] Data reads: %0d", $time, serv1_data_reads);
            $display("[%0t] Data writes: %0d", $time, serv1_data_writes);
            $display("[%0t] Busy during instr: %0d / %0d (%.1f%%)", 
                     $time, serv1_busy_with_instr, serv1_instr_fetches,
                     serv1_instr_fetches > 0 ? (serv1_busy_with_instr * 100.0) / serv1_instr_fetches : 0);
            $display("[%0t] Busy during data: %0d / %0d (%.1f%%)", 
                     $time, serv1_busy_with_data, (serv1_data_reads + serv1_data_writes),
                     (serv1_data_reads + serv1_data_writes) > 0 ? 
                     (serv1_busy_with_data * 100.0) / (serv1_data_reads + serv1_data_writes) : 0);
            
            // Test Status
            $display("\n[%0t] --- TEST STATUS ---", $time);
            test_count = test_count + 1;
            if (serv0_busy_transitions > 0 && serv1_busy_transitions > 0) begin
                $display("[%0t] TEST 1: PASS - Busy signals are toggling", $time);
                pass_count = pass_count + 1;
            end else begin
                $display("[%0t] TEST 1: FAIL - Busy signals not toggling", $time);
                fail_count = fail_count + 1;
            end
            
            test_count = test_count + 1;
            if (serv0_instr_fetches > 0 && serv0_busy_with_instr > 0) begin
                $display("[%0t] TEST 2: PASS - SERV0 busy during instruction fetches", $time);
                pass_count = pass_count + 1;
            end else begin
                $display("[%0t] TEST 2: FAIL - SERV0 busy not asserted during instruction fetches", $time);
                fail_count = fail_count + 1;
            end
            
            test_count = test_count + 1;
            if (serv1_instr_fetches > 0 && serv1_busy_with_instr > 0) begin
                $display("[%0t] TEST 3: PASS - SERV1 busy during instruction fetches", $time);
                pass_count = pass_count + 1;
            end else begin
                $display("[%0t] TEST 3: FAIL - SERV1 busy not asserted during instruction fetches", $time);
                fail_count = fail_count + 1;
            end
            
            // Summary
            $display("\n[%0t] --- SUMMARY ---", $time);
            $display("[%0t] Total tests: %0d", $time, test_count);
            $display("[%0t] Passed: %0d", $time, pass_count);
            $display("[%0t] Failed: %0d", $time, fail_count);
            
            if (fail_count == 0) begin
                $display("[%0t] STATUS: ALL TESTS PASSED", $time);
            end else begin
                $display("[%0t] STATUS: SOME TESTS FAILED", $time);
            end
            
            $display("[%0t] ========================================\n", $time);
        end
    endtask

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    dual_serv_axi_system #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .RAM_WORDS(2048),
        .RAM_INIT_HEX(RAM_INIT_HEX)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .uart_tx_valid(uart_tx_valid),
        .uart_tx_byte(uart_tx_byte),
        .spi_cs_n(spi_cs_n),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .serv0_debug_pc(serv0_debug_pc),
        .serv0_debug_r1(serv0_debug_r1),
        .serv0_debug_r2(serv0_debug_r2),
        .serv1_debug_pc(serv1_debug_pc),
        .serv1_debug_r1(serv1_debug_r1),
        .serv1_debug_r2(serv1_debug_r2),
        .serv0_busy(serv0_busy),
        .serv1_busy(serv1_busy)
    );

endmodule

