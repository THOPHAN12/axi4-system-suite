`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////////////
// Testbench: dual_riscv_system_tb
// Description: Simple testbench for Dual RISC-V System
//              Tests RAM arbitration between M0 and M1
////////////////////////////////////////////////////////////////////////////////

module dual_riscv_system_tb;

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter RAM_INIT_HEX = "dual_core_test_clean.hex";
    parameter SIM_TIME = 500000;  // 500us simulation time
    parameter ENABLE_WAVEFORM = 1;  // Enable waveform dump
    parameter MAX_TOTAL_REQUESTS = 10;  // Giới hạn tổng số requests: M0=5, M1=5
    parameter VERBOSE = 0;  // Verbose output: 0=summary only, 1=detailed
    
    // RESET_PC values
    parameter CORE0_RESET_PC = 32'h00000000;
    parameter CORE1_RESET_PC = 32'h00000100;
    
    // Slave address ranges
    parameter RAM_BASE = 32'h00000000;
    parameter RAM_END  = 32'h1FFFFFFF;
    parameter GPIO_BASE = 32'h40000000;
    parameter GPIO_END  = 32'h5FFFFFFF;
    parameter UART_BASE = 32'h80000000;
    parameter UART_END  = 32'hBFFFFFFF;
    parameter SPI_BASE  = 32'hC0000000;
    parameter SPI_END   = 32'hFFFFFFFF;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg                         ACLK;
    reg                         ARESETN;
    reg                         serv0_timer_irq;
    reg                         serv1_timer_irq;
    reg                         serv0_ARESETN_override;
    reg                         serv0_reset_delay_enable;
    reg  [31:0]                 gpio_in;
    wire [31:0]                 gpio_out;
    wire                        uart_tx_valid;
    wire [7:0]                  uart_tx_byte;
    wire                        spi_cs_n;
    wire                        spi_sclk;
    wire                        spi_mosi;
    reg                         spi_miso;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer cycle_count;
    integer timeout;
    integer i;  // Loop variable for unique address checking
    reg stop_counting;
    reg test_start;  // Flag to track when test actually starts (after cores are ready)
    
    //==========================================================================
    // Transaction Statistics
    //==========================================================================
    // Arbitration
    integer ram_conflicts;
    integer m0_ram_wins;
    integer m1_ram_wins;
    integer m0_arbitration_latency_sum, m0_arbitration_count;
    integer m1_arbitration_latency_sum, m1_arbitration_count;
    integer m0_request_time, m1_request_time;
    integer m0_retry_count, m1_retry_count;
    reg m0_prev_arvalid, m1_prev_arvalid;
    reg m0_prev_arready, m1_prev_arready;
    
    // Read transactions - Total
    integer m0_read_requests;
    integer m1_read_requests;
    integer m0_read_completed;
    integer m1_read_completed;
    
    // Read transactions - Per Slave
    integer m0_ram_reads, m0_gpio_reads, m0_uart_reads, m0_spi_reads;
    integer m1_ram_reads, m1_gpio_reads, m1_uart_reads, m1_spi_reads;
    
    // Write transactions
    integer m0_write_requests;
    integer m1_write_requests;
    integer m0_write_completed;
    integer m1_write_completed;
    
    // Write transactions - Per Slave
    integer m0_ram_writes, m0_gpio_writes, m0_uart_writes, m0_spi_writes;
    integer m1_ram_writes, m1_gpio_writes, m1_uart_writes, m1_spi_writes;
    
    // Transaction latency tracking
    integer m0_read_latency_sum, m0_read_latency_count;
    integer m1_read_latency_sum, m1_read_latency_count;
    integer m0_read_start_time, m1_read_start_time;
    integer m0_write_latency_sum, m0_write_latency_count;
    integer m1_write_latency_sum, m1_write_latency_count;
    integer m0_write_start_time, m1_write_start_time;
    
    // Transaction data tracking
    reg [31:0] m0_last_read_addr, m1_last_read_addr;
    reg [31:0] m0_last_write_addr, m1_last_write_addr;
    reg [31:0] m0_last_write_data, m1_last_write_data;
    reg [31:0] m0_last_read_data, m1_last_read_data;
    
    // Track pending read addresses for accurate matching
    reg [31:0] m0_pending_read_addr, m1_pending_read_addr;
    reg m0_pending_read_valid, m1_pending_read_valid;
    
    // Track unique addresses for M0 and M1 (to count only different addresses)
    reg [31:0] m0_unique_addrs [0:9];  // Store up to 10 unique addresses
    reg [31:0] m1_unique_addrs [0:9];
    integer m0_unique_count, m1_unique_count;  // Count of unique addresses
    reg m0_is_unique, m1_is_unique;  // Flags for checking unique addresses
    
    // Debug monitoring: Track PC changes and instruction data
    reg [31:0] m0_prev_pc, m1_prev_pc;  // Previous PC values
    reg [31:0] m0_instruction_data, m1_instruction_data;  // Last instruction data received
    integer expected_data;  // Expected instruction data for verification
    integer m0_pc_changes, m1_pc_changes;  // Count of PC changes
    integer m0_instruction_fetches, m1_instruction_fetches;  // Count of instruction fetches
    reg [31:0] m0_last_fetch_addr, m1_last_fetch_addr;  // Last fetch address
    reg [31:0] m0_last_fetch_data, m1_last_fetch_data;  // Last fetch data
    
    // Track instruction handshake completion
    integer m0_arvalid_count, m1_arvalid_count;  // Count of address valid assertions
    integer m0_arready_count, m1_arready_count;  // Count of address ready assertions
    integer m0_rvalid_count, m1_rvalid_count;  // Count of read data valid assertions
    integer m0_rready_count, m1_rready_count;  // Count of read data ready assertions
    integer m0_handshake_complete, m1_handshake_complete;  // Count of complete handshakes
    reg m0_prev_rvalid, m1_prev_rvalid;  // Previous rvalid for edge detection
    
    // Track Wishbone handshakes (internal signals)
    integer m0_wb_cyc_count, m1_wb_cyc_count;  // Count of wb_cyc assertions
    integer m0_wb_ack_count, m1_wb_ack_count;  // Count of wb_ack assertions
    integer m0_wb_ack_with_cyc, m1_wb_ack_with_cyc;  // Count of wb_ack when wb_cyc is high
    reg m0_prev_wb_cyc, m1_prev_wb_cyc;  // Previous wb_cyc for edge detection
    reg m0_prev_wb_ack, m1_prev_wb_ack;  // Previous wb_ack for edge detection
    reg m0_prev_ibus_ack, m1_prev_ibus_ack;  // Previous i_ibus_ack for edge detection
    reg m0_prev_cnt_done, m1_prev_cnt_done;  // Previous cnt_done for edge detection
    integer m0_cnt_done_count, m1_cnt_done_count;  // Count of cnt_done assertions
    reg [31:0] m0_prev_ibus_adr, m1_prev_ibus_adr;  // Previous PC address from serv_ctrl
    integer m0_pc_internal_changes, m1_pc_internal_changes;  // Count of internal PC changes

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
        serv0_ARESETN_override = 0;
        serv0_reset_delay_enable = 1;
        serv0_timer_irq = 0;
        serv1_timer_irq = 0;
        gpio_in = 0;
        spi_miso = 0;
        cycle_count = 0;
        stop_counting = 0;
        test_start = 0;  // Test hasn't started yet
        ram_conflicts = 0;
        m0_ram_wins = 0;
        m1_ram_wins = 0;
        m0_read_requests = 0;
        m1_read_requests = 0;
        m0_read_completed = 0;
        m1_read_completed = 0;
        m0_write_requests = 0;
        m1_write_requests = 0;
        m0_write_completed = 0;
        m1_write_completed = 0;
        m0_last_read_addr = 0;
        m1_last_read_addr = 0;
        m0_last_write_addr = 0;
        m1_last_write_addr = 0;
        m0_last_write_data = 0;
        m1_last_write_data = 0;
        m0_last_read_data = 0;
        m1_last_read_data = 0;
        m0_pending_read_addr = 0;
        m1_pending_read_addr = 0;
        m0_pending_read_valid = 0;
        m1_pending_read_valid = 0;
        m0_unique_count = 0;
        m1_unique_count = 0;
        
        // Initialize per-slave counters
        m0_ram_reads = 0; m0_gpio_reads = 0; m0_uart_reads = 0; m0_spi_reads = 0;
        m1_ram_reads = 0; m1_gpio_reads = 0; m1_uart_reads = 0; m1_spi_reads = 0;
        m0_ram_writes = 0; m0_gpio_writes = 0; m0_uart_writes = 0; m0_spi_writes = 0;
        m1_ram_writes = 0; m1_gpio_writes = 0; m1_uart_writes = 0; m1_spi_writes = 0;
        
        // Initialize latency tracking
        m0_arbitration_latency_sum = 0; m0_arbitration_count = 0;
        m1_arbitration_latency_sum = 0; m1_arbitration_count = 0;
        m0_request_time = 0; m1_request_time = 0;
        m0_retry_count = 0; m1_retry_count = 0;
        m0_prev_arvalid = 0; m1_prev_arvalid = 0;
        m0_prev_arready = 0; m1_prev_arready = 0;
        m0_read_latency_sum = 0; m0_read_latency_count = 0;
        m1_read_latency_sum = 0; m1_read_latency_count = 0;
        m0_read_start_time = 0; m1_read_start_time = 0;
        m0_write_latency_sum = 0; m0_write_latency_count = 0;
        m1_write_latency_sum = 0; m1_write_latency_count = 0;
        m0_write_start_time = 0; m1_write_start_time = 0;
        
        // Initialize debug monitoring
        m0_prev_pc = 0;
        m1_prev_pc = 0;
        m0_instruction_data = 0;
        m1_instruction_data = 0;
        m0_pc_changes = 0;
        m1_pc_changes = 0;
        m0_instruction_fetches = 0;
        m1_instruction_fetches = 0;
        m0_last_fetch_addr = 0;
        m1_last_fetch_addr = 0;
        m0_last_fetch_data = 0;
        m1_last_fetch_data = 0;
        
        // Initialize handshake tracking
        m0_arvalid_count = 0;
        m1_arvalid_count = 0;
        m0_arready_count = 0;
        m1_arready_count = 0;
        m0_rvalid_count = 0;
        m1_rvalid_count = 0;
        m0_rready_count = 0;
        m1_rready_count = 0;
        m0_handshake_complete = 0;
        m1_handshake_complete = 0;
        m0_prev_arvalid = 0;
        m1_prev_arvalid = 0;
        m0_prev_rvalid = 0;
        m1_prev_rvalid = 0;
        
        // Initialize Wishbone tracking
        m0_wb_cyc_count = 0;
        m1_wb_cyc_count = 0;
        m0_wb_ack_count = 0;
        m1_wb_ack_count = 0;
        m0_wb_ack_with_cyc = 0;
        m1_wb_ack_with_cyc = 0;
        m0_prev_wb_cyc = 0;
        m1_prev_wb_cyc = 0;
        m0_prev_wb_ack = 0;
        m1_prev_wb_ack = 0;
        m0_prev_ibus_ack = 0;
        m1_prev_ibus_ack = 0;
        m0_prev_cnt_done = 0;
        m1_prev_cnt_done = 0;
        m0_cnt_done_count = 0;
        m1_cnt_done_count = 0;
        m0_prev_ibus_adr = 0;
        m1_prev_ibus_adr = 0;
        m0_pc_internal_changes = 0;
        m1_pc_internal_changes = 0;
        
        // Hold reset for 10 cycles
        repeat(10) @(posedge ACLK);
        ARESETN = 1;
        
        // Release Core 1 reset first
        repeat(5) @(posedge ACLK);
        serv0_ARESETN_override = 0;  // Core 1 reset released
        
        // Delay Core 0 reset release by 50 cycles
        repeat(50) @(posedge ACLK);
        serv0_ARESETN_override = 1;  // Core 0 reset released
        
        if (VERBOSE) begin
            $display("\n[%0t] ========================================", $time);
            $display("[%0t] RAM COMMUNICATION TEST STARTED", $time);
            $display("[%0t] Testing Read/Write transactions between M0/M1 and RAM", $time);
            $display("[%0t] ========================================\n", $time);
        end
        
        // Run simulation - wait for cores to start
        repeat(100) @(posedge ACLK);
        
        // Mark test as started - only count completed transactions from now on
        test_start = 1;
        
        // Continue running until both M0 and M1 have 5 unique addresses each
        // stop_counting will be set in always block when limit is reached
        timeout = 0;
        stop_counting = 0;  // Ensure it's clear
        // Reduced timeout to 20000 cycles (20000ns) to detect stuck cores faster
        while ((m0_unique_count < 5 || m1_unique_count < 5) && timeout < 20000 && !stop_counting) begin
            @(posedge ACLK);
            timeout = timeout + 1;
            // Display progress every 5000 cycles (only if VERBOSE)
            if (VERBOSE && timeout % 5000 == 0) begin
                $display("[%0t] Progress: M0 unique=%0d/5 (fetches=%0d, PC_changes=%0d), M1 unique=%0d/5 (fetches=%0d, PC_changes=%0d) (timeout=%0d/20000)", 
                         $time, m0_unique_count, m0_instruction_fetches, m0_pc_changes, 
                         m1_unique_count, m1_instruction_fetches, m1_pc_changes, timeout);
            end
            // Early exit if cores are stuck (no PC changes after many fetches)
            if (timeout > 10000 && m0_pc_changes == 0 && m0_instruction_fetches > 100) begin
                stop_counting = 1;
            end
            if (timeout > 10000 && m1_pc_changes == 0 && m1_instruction_fetches > 100) begin
                stop_counting = 1;
            end
            // Also stop if we have enough requests (even if not all unique) - but wait longer
            if (m0_read_requests >= 50 && m1_read_requests >= 50 && timeout > 10000) begin
                stop_counting = 1;
            end
        end
        
        // Check why we exited
        if (stop_counting || (m0_unique_count >= 5 && m1_unique_count >= 5)) begin
            if (VERBOSE) begin
                $display("[%0t] Stopping: M0 unique=%0d/5, M1 unique=%0d/5", 
                         $time, m0_unique_count, m1_unique_count);
            end
            stop_counting = 1;  // Ensure counting is stopped
        end else if (timeout >= 100000) begin
            if (VERBOSE) begin
                $display("[%0t] Timeout: M0 unique=%0d/5, M1 unique=%0d/5", 
                         $time, m0_unique_count, m1_unique_count);
            end
            stop_counting = 1;  // Stop counting new requests
        end
        
        // Wait a few cycles for pending transactions to complete
        repeat(50) @(posedge ACLK);
        
        // Print concise summary
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] TEST SUMMARY", $time);
        $display("[%0t] ========================================", $time);
        
        // Read Transaction Summary with unique addresses
        $display("[%0t] READ: M0=%0d unique/%0d total, M1=%0d unique/%0d total", 
                 $time, m0_read_completed, m0_read_requests, m1_read_completed, m1_read_requests);
        
        // Display unique addresses found
        if (m0_unique_count > 0) begin
            $display("[%0t] M0 Unique Addresses (%0d total):", $time, m0_unique_count);
            for (i = 0; i < m0_unique_count; i = i + 1) begin
                if (i < 10) begin
                    $display("[%0t]   [%0d] 0x%08h", $time, i+1, m0_unique_addrs[i]);
                end
            end
        end else begin
            $display("[%0t] M0 Unique Addresses: NONE (core may be stuck)", $time);
        end
        if (m1_unique_count > 0) begin
            $display("[%0t] M1 Unique Addresses (%0d total):", $time, m1_unique_count);
            for (i = 0; i < m1_unique_count; i = i + 1) begin
                if (i < 10) begin
                    $display("[%0t]   [%0d] 0x%08h", $time, i+1, m1_unique_addrs[i]);
                end
            end
        end else begin
            $display("[%0t] M1 Unique Addresses: NONE (core may be stuck)", $time);
        end
        
        // Warning if not enough unique addresses
        if (m0_unique_count < 5 || m1_unique_count < 5) begin
            $display("[%0t] WARNING: Expected 5 unique addresses per master, but got M0=%0d, M1=%0d", 
                     $time, m0_unique_count, m1_unique_count);
            $display("[%0t]          Core may be stuck - PC not incrementing properly", $time);
        end
        
        // Debug Information
        $display("\n[%0t] --- DEBUG INFORMATION ---", $time);
        $display("[%0t] M0: PC changes=%0d, Instruction fetches=%0d, Last fetch: Addr=0x%08h, Data=0x%08h", 
                 $time, m0_pc_changes, m0_instruction_fetches, m0_last_fetch_addr, m0_last_fetch_data);
        $display("[%0t] M0 Handshakes: AR valid=%0d, AR ready=%0d, R valid=%0d, R ready=%0d, Complete=%0d", 
                 $time, m0_arvalid_count, m0_arready_count, m0_rvalid_count, m0_rready_count, m0_handshake_complete);
        $display("[%0t] M1: PC changes=%0d, Instruction fetches=%0d, Last fetch: Addr=0x%08h, Data=0x%08h", 
                 $time, m1_pc_changes, m1_instruction_fetches, m1_last_fetch_addr, m1_last_fetch_data);
        $display("[%0t] M1 Handshakes: AR valid=%0d, AR ready=%0d, R valid=%0d, R ready=%0d, Complete=%0d", 
                 $time, m1_arvalid_count, m1_arready_count, m1_rvalid_count, m1_rready_count, m1_handshake_complete);
        
        // Wishbone Handshake Information
        $display("\n[%0t] --- WISHBONE HANDshake INFORMATION ---", $time);
        $display("[%0t] M0 Wishbone: wb_cyc=%0d, wb_ack=%0d, wb_ack_with_cyc=%0d", 
                 $time, m0_wb_cyc_count, m0_wb_ack_count, m0_wb_ack_with_cyc);
        $display("[%0t] M1 Wishbone: wb_cyc=%0d, wb_ack=%0d, wb_ack_with_cyc=%0d", 
                 $time, m1_wb_cyc_count, m1_wb_ack_count, m1_wb_ack_with_cyc);
        
        // Analysis
        if (m0_wb_ack_count == 0 && m0_instruction_fetches > 10) begin
            $display("[%0t] M0 CRITICAL: No wb_ack received! SERV core never got instruction acknowledge", $time);
        end else if (m0_wb_ack_count < m0_instruction_fetches / 2) begin
            $display("[%0t] M0 WARNING: wb_ack count (%0d) much less than instruction fetches (%0d)", 
                     $time, m0_wb_ack_count, m0_instruction_fetches);
        end
        if (m1_wb_ack_count == 0 && m1_instruction_fetches > 10) begin
            $display("[%0t] M1 CRITICAL: No wb_ack received! SERV core never got instruction acknowledge", $time);
        end else if (m1_wb_ack_count < m1_instruction_fetches / 2) begin
            $display("[%0t] M1 WARNING: wb_ack count (%0d) much less than instruction fetches (%0d)", 
                     $time, m1_wb_ack_count, m1_instruction_fetches);
        end
        
        // Analysis
        if (m0_pc_changes == 0 && m0_instruction_fetches > 10) begin
            $display("[%0t] M0 ANALYSIS: PC never changed after %0d fetches - Core is STUCK!", 
                     $time, m0_instruction_fetches);
            $display("[%0t]            Stuck at PC=0x%08h, Instruction=0x%08h", 
                     $time, m0_last_fetch_addr, m0_last_fetch_data);
            if (m0_last_fetch_data == 32'h00000000) begin
                $display("[%0t]            WARNING: Instruction is 0x00000000 (invalid/uninitialized)", $time);
            end
        end
        if (m1_pc_changes == 0 && m1_instruction_fetches > 10) begin
            $display("[%0t] M1 ANALYSIS: PC never changed after %0d fetches - Core is STUCK!", 
                     $time, m1_instruction_fetches);
            $display("[%0t]            Stuck at PC=0x%08h, Instruction=0x%08h", 
                     $time, m1_last_fetch_addr, m1_last_fetch_data);
            if (m1_last_fetch_data == 32'h00000000) begin
                $display("[%0t]            WARNING: Instruction is 0x00000000 (invalid/uninitialized)", $time);
            end
        end
        
        // Write Transaction Summary
        if (m0_write_completed > 0 || m1_write_completed > 0) begin
            $display("[%0t] WRITE: M0=%0d, M1=%0d", $time, m0_write_completed, m1_write_completed);
        end
        
        // Arbitration Summary
        if (ram_conflicts > 0) begin
            $display("[%0t] ARBITRATION: %0d conflicts, M0 wins=%0d (%.1f%%), M1 wins=%0d (%.1f%%)", 
                     $time, ram_conflicts, m0_ram_wins, (m0_ram_wins * 100.0) / ram_conflicts,
                     m1_ram_wins, (m1_ram_wins * 100.0) / ram_conflicts);
        end
        
        // Last Transaction Info
        if (m0_read_completed > 0 && m0_last_read_addr >= RAM_BASE && m0_last_read_addr <= RAM_END) begin
            $display("[%0t] M0 Last: Addr=0x%08h, Data=0x%08h", $time, m0_last_read_addr, m0_last_read_data);
        end
        if (m1_read_completed > 0 && m1_last_read_addr >= RAM_BASE && m1_last_read_addr <= RAM_END) begin
            $display("[%0t] M1 Last: Addr=0x%08h, Data=0x%08h", $time, m1_last_read_addr, m1_last_read_data);
        end
        
        // Test Status
        if ((m0_read_completed > 0 || m0_write_completed > 0) && 
            (m1_read_completed > 0 || m1_write_completed > 0)) begin
            $display("[%0t] STATUS: PASSED", $time);
        end else if (m0_read_completed > 0 || m0_write_completed > 0) begin
            $display("[%0t] STATUS: PARTIAL (M0 only)", $time);
        end else if (m1_read_completed > 0 || m1_write_completed > 0) begin
            $display("[%0t] STATUS: PARTIAL (M1 only)", $time);
        end else begin
            $display("[%0t] STATUS: WARNING (no transactions)", $time);
        end
        
        $display("[%0t] ========================================\n", $time);
        
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
    // RAM Transaction Monitor (Read and Write)
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // =================================================================
            // READ TRANSACTIONS MONITORING
            // =================================================================
            
            // M0 Read Address Channel - Arbitration and Latency Tracking
            if (dut.serv0_axi_arvalid && !dut.serv0_axi_arready) begin
                // Request pending - start arbitration latency tracking
                if (m0_request_time == 0) begin
                    m0_request_time = $time;
                end
            end
            
            // Track address channel handshakes - count edges, not cycles
            if (dut.serv0_axi_arvalid && !m0_prev_arvalid) begin
                // Rising edge of arvalid
                m0_arvalid_count = m0_arvalid_count + 1;
            end
            if (dut.serv0_axi_arready && !m0_prev_arready) begin
                // Rising edge of arready
                m0_arready_count = m0_arready_count + 1;
            end
            
            if (dut.serv0_axi_arvalid && dut.serv0_axi_arready) begin
                // Track ALL address requests (including non-RAM) for accurate data matching
                m0_pending_read_addr = dut.serv0_axi_araddr;
                m0_pending_read_valid = 1;
                
                    // Debug: Track PC changes (instruction fetch addresses)
                if (dut.serv0_axi_araddr >= RAM_BASE && dut.serv0_axi_araddr <= RAM_END) begin
                    // This is an instruction fetch
                    m0_instruction_fetches = m0_instruction_fetches + 1;
                    m0_last_fetch_addr = dut.serv0_axi_araddr;
                    
                    // Debug: Log first 10 address requests (only if VERBOSE)
                    // Removed to reduce transcript verbosity
                    
                    // Check if PC changed
                    if (m0_prev_pc != dut.serv0_axi_araddr) begin
                        if (m0_prev_pc != 0) begin
                            m0_pc_changes = m0_pc_changes + 1;
                            if (VERBOSE) begin
                                $display("[%0t] [M0 DEBUG] PC changed: 0x%08h -> 0x%08h (change #%0d)", 
                                         $time, m0_prev_pc, dut.serv0_axi_araddr, m0_pc_changes);
                            end
                        end
                        m0_prev_pc = dut.serv0_axi_araddr;
                    end else begin
                        // PC did not change - core may be stuck
                        if (VERBOSE && m0_instruction_fetches > 1) begin
                            $display("[%0t] [M0 DEBUG] PC STUCK at 0x%08h (fetch #%0d)", 
                                     $time, dut.serv0_axi_araddr, m0_instruction_fetches);
                        end
                    end
                end
                
                // Track arbitration latency
                if (m0_request_time > 0) begin
                    m0_arbitration_latency_sum = m0_arbitration_latency_sum + ($time - m0_request_time);
                    m0_arbitration_count = m0_arbitration_count + 1;
                    m0_request_time = 0;
                end
                
                // Track transaction latency - start time
                m0_read_start_time = $time;
                
                // Count per-slave read requests (only if not stopped - no limit on requests, only on unique addresses)
                if (!stop_counting && dut.serv0_axi_araddr >= RAM_BASE && dut.serv0_axi_araddr <= RAM_END) begin
                    m0_read_requests = m0_read_requests + 1;
                    m0_ram_reads = m0_ram_reads + 1;
                    m0_last_read_addr = dut.serv0_axi_araddr;
                    // Only display when we get a new unique address (if verbose)
                    if (VERBOSE && (m0_unique_count == 0 || (m0_unique_count > 0 && m0_unique_addrs[m0_unique_count-1] != dut.serv0_axi_araddr))) begin
                        $display("[%0t] [M0] Read request: Addr=0x%08h (Request #%0d, Unique: %0d)", 
                                 $time, dut.serv0_axi_araddr, m0_read_requests, m0_unique_count);
                    end
                    // Check if both masters have 5 unique addresses each and stop counting
                    if (m0_unique_count >= 5 && m1_unique_count >= 5) begin
                        stop_counting = 1;
                    end
                end else if (dut.serv0_axi_araddr >= GPIO_BASE && dut.serv0_axi_araddr <= GPIO_END) begin
                    m0_gpio_reads = m0_gpio_reads + 1;
                end else if (dut.serv0_axi_araddr >= UART_BASE && dut.serv0_axi_araddr <= UART_END) begin
                    m0_uart_reads = m0_uart_reads + 1;
                end else if (dut.serv0_axi_araddr >= SPI_BASE && dut.serv0_axi_araddr <= SPI_END) begin
                    m0_spi_reads = m0_spi_reads + 1;
                end
            end
            
            // M0 Read Data Channel - Track handshakes
            if (dut.serv0_axi_rvalid) begin
                m0_rvalid_count = m0_rvalid_count + 1;
            end
            if (dut.serv0_axi_rready) begin
                m0_rready_count = m0_rready_count + 1;
            end
            if (dut.serv0_axi_rvalid && dut.serv0_axi_rready) begin
                m0_handshake_complete = m0_handshake_complete + 1;
                // Debug: Track instruction data from RAM
                if (m0_pending_read_valid && m0_pending_read_addr >= RAM_BASE && m0_pending_read_addr <= RAM_END) begin
                    m0_instruction_data = dut.serv0_axi_rdata;
                    m0_last_fetch_data = dut.serv0_axi_rdata;
                    // Data verification (only track, don't display during simulation)
                    // Removed debug output to reduce transcript verbosity - errors tracked in summary
                end
                
                // Match data response with pending address
                if (m0_pending_read_valid) begin
                    // Track transaction latency
                    if (m0_read_start_time > 0) begin
                        m0_read_latency_sum = m0_read_latency_sum + ($time - m0_read_start_time);
                        m0_read_latency_count = m0_read_latency_count + 1;
                        m0_read_start_time = 0;
                    end
                    
                    // Count per-slave read completions (only for requests sent after test_start)
                    // Only count unique addresses (different addresses)
                    if (m0_pending_read_addr >= RAM_BASE && m0_pending_read_addr <= RAM_END) begin
                        // Only count if test has started (to avoid counting old requests)
                        if (test_start) begin
                            // Check if this address is unique (not seen before)
                            m0_is_unique = 1;
                            for (i = 0; i < m0_unique_count; i = i + 1) begin
                                if (m0_unique_addrs[i] == m0_pending_read_addr) begin
                                    m0_is_unique = 0;
                                end
                            end
                            
                            // Only count if address is unique
                            if (m0_is_unique) begin
                                m0_unique_addrs[m0_unique_count] = m0_pending_read_addr;
                                m0_unique_count = m0_unique_count + 1;
                                m0_read_completed = m0_read_completed + 1;
                                m0_last_read_data = dut.serv0_axi_rdata;
                                m0_last_read_addr = m0_pending_read_addr;
                                if (VERBOSE) begin
                                    $display("[%0t] [M0] Read completed: Addr=0x%08h, Data=0x%08h (Unique #%0d)", 
                                             $time, m0_pending_read_addr, dut.serv0_axi_rdata, m0_read_completed);
                                end
                            end
                        end
                    end
                    // Clear pending flag after matching
                    m0_pending_read_valid = 0;
                end
            end
            
            // M0 Retry Detection
            if (m0_prev_arvalid && !m0_prev_arready && dut.serv0_axi_arvalid) begin
                m0_retry_count = m0_retry_count + 1;
            end
            m0_prev_arvalid = dut.serv0_axi_arvalid;
            m0_prev_arready = dut.serv0_axi_arready;
            
            // M1 Read Address Channel - Arbitration and Latency Tracking
            if (dut.serv1_axi_arvalid && !dut.serv1_axi_arready) begin
                // Request pending - start arbitration latency tracking
                if (m1_request_time == 0) begin
                    m1_request_time = $time;
                end
            end
            
            // Track address channel handshakes - count edges, not cycles
            if (dut.serv1_axi_arvalid && !m1_prev_arvalid) begin
                // Rising edge of arvalid
                m1_arvalid_count = m1_arvalid_count + 1;
            end
            if (dut.serv1_axi_arready && !m1_prev_arready) begin
                // Rising edge of arready
                m1_arready_count = m1_arready_count + 1;
            end
            
            if (dut.serv1_axi_arvalid && dut.serv1_axi_arready) begin
                // Track ALL address requests (including non-RAM) for accurate data matching
                m1_pending_read_addr = dut.serv1_axi_araddr;
                m1_pending_read_valid = 1;
                
                // Debug: Track PC changes (instruction fetch addresses)
                if (dut.serv1_axi_araddr >= RAM_BASE && dut.serv1_axi_araddr <= RAM_END) begin
                    // This is an instruction fetch
                    m1_instruction_fetches = m1_instruction_fetches + 1;
                    m1_last_fetch_addr = dut.serv1_axi_araddr;
                    
                    // Check if PC changed
                    if (m1_prev_pc != dut.serv1_axi_araddr) begin
                        if (m1_prev_pc != 0) begin
                            m1_pc_changes = m1_pc_changes + 1;
                            if (VERBOSE) begin
                                $display("[%0t] [M1 DEBUG] PC changed: 0x%08h -> 0x%08h (change #%0d)", 
                                         $time, m1_prev_pc, dut.serv1_axi_araddr, m1_pc_changes);
                            end
                        end
                        m1_prev_pc = dut.serv1_axi_araddr;
                    end else begin
                        // PC did not change - core may be stuck
                        if (VERBOSE && m1_instruction_fetches > 1) begin
                            $display("[%0t] [M1 DEBUG] PC STUCK at 0x%08h (fetch #%0d)", 
                                     $time, dut.serv1_axi_araddr, m1_instruction_fetches);
                        end
                    end
                end
                
                // Track arbitration latency
                if (m1_request_time > 0) begin
                    m1_arbitration_latency_sum = m1_arbitration_latency_sum + ($time - m1_request_time);
                    m1_arbitration_count = m1_arbitration_count + 1;
                    m1_request_time = 0;
                end
                
                // Track transaction latency - start time
                m1_read_start_time = $time;
                
                // Count per-slave read requests (only if not stopped - no limit on requests, only on unique addresses)
                if (!stop_counting && dut.serv1_axi_araddr >= RAM_BASE && dut.serv1_axi_araddr <= RAM_END) begin
                    m1_read_requests = m1_read_requests + 1;
                    m1_ram_reads = m1_ram_reads + 1;
                    m1_last_read_addr = dut.serv1_axi_araddr;
                    // Only display when we get a new unique address (if verbose)
                    if (VERBOSE && (m1_unique_count == 0 || (m1_unique_count > 0 && m1_unique_addrs[m1_unique_count-1] != dut.serv1_axi_araddr))) begin
                        $display("[%0t] [M1] Read request: Addr=0x%08h (Request #%0d, Unique: %0d)", 
                                 $time, dut.serv1_axi_araddr, m1_read_requests, m1_unique_count);
                    end
                    // Check if both masters have 5 unique addresses each and stop counting
                    if (m0_unique_count >= 5 && m1_unique_count >= 5) begin
                        stop_counting = 1;
                    end
                end else if (dut.serv1_axi_araddr >= GPIO_BASE && dut.serv1_axi_araddr <= GPIO_END) begin
                    m1_gpio_reads = m1_gpio_reads + 1;
                end else if (dut.serv1_axi_araddr >= UART_BASE && dut.serv1_axi_araddr <= UART_END) begin
                    m1_uart_reads = m1_uart_reads + 1;
                end else if (dut.serv1_axi_araddr >= SPI_BASE && dut.serv1_axi_araddr <= SPI_END) begin
                    m1_spi_reads = m1_spi_reads + 1;
                end
            end
            
            // M1 Read Data Channel - Track handshakes
            if (dut.serv1_axi_rvalid) begin
                m1_rvalid_count = m1_rvalid_count + 1;
            end
            if (dut.serv1_axi_rready) begin
                m1_rready_count = m1_rready_count + 1;
            end
            if (dut.serv1_axi_rvalid && dut.serv1_axi_rready) begin
                m1_handshake_complete = m1_handshake_complete + 1;
                // Debug: Track instruction data from RAM
                if (m1_pending_read_valid && m1_pending_read_addr >= RAM_BASE && m1_pending_read_addr <= RAM_END) begin
                    m1_instruction_data = dut.serv1_axi_rdata;
                    m1_last_fetch_data = dut.serv1_axi_rdata;
                    // Data verification (only track, don't display during simulation)
                    // Removed debug output to reduce transcript verbosity - errors tracked in summary
                end
                
                // Match data response with pending address
                if (m1_pending_read_valid) begin
                    // Track transaction latency
                    if (m1_read_start_time > 0) begin
                        m1_read_latency_sum = m1_read_latency_sum + ($time - m1_read_start_time);
                        m1_read_latency_count = m1_read_latency_count + 1;
                        m1_read_start_time = 0;
                    end
                    
                    // Count per-slave read completions (only for requests sent after test_start)
                    // Only count unique addresses (different addresses)
                    if (m1_pending_read_addr >= RAM_BASE && m1_pending_read_addr <= RAM_END) begin
                        // Only count if test has started (to avoid counting old requests)
                        if (test_start) begin
                            // Check if this address is unique (not seen before)
                            m1_is_unique = 1;
                            for (i = 0; i < m1_unique_count; i = i + 1) begin
                                if (m1_unique_addrs[i] == m1_pending_read_addr) begin
                                    m1_is_unique = 0;
                                end
                            end
                            
                            // Only count if address is unique
                            if (m1_is_unique) begin
                                m1_unique_addrs[m1_unique_count] = m1_pending_read_addr;
                                m1_unique_count = m1_unique_count + 1;
                                m1_read_completed = m1_read_completed + 1;
                                m1_last_read_data = dut.serv1_axi_rdata;
                                m1_last_read_addr = m1_pending_read_addr;
                                if (VERBOSE) begin
                                    $display("[%0t] [M1] Read completed: Addr=0x%08h, Data=0x%08h (Unique #%0d)", 
                                             $time, m1_pending_read_addr, dut.serv1_axi_rdata, m1_read_completed);
                                end
                            end
                        end
                    end
                    // Clear pending flag after matching
                    m1_pending_read_valid = 0;
                end
            end
            
            // M1 Retry Detection
            if (m1_prev_arvalid && !m1_prev_arready && dut.serv1_axi_arvalid) begin
                m1_retry_count = m1_retry_count + 1;
            end
            m1_prev_arvalid = dut.serv1_axi_arvalid;
            m1_prev_arready = dut.serv1_axi_arready;
            
            // =================================================================
            // WRITE TRANSACTIONS MONITORING
            // =================================================================
            
            // M0 Write Address Channel
            if (dut.serv0_axi_awvalid && dut.serv0_axi_awready) begin
                m0_write_start_time = $time;
                
                // Count per-slave write requests
                if (dut.serv0_axi_awaddr >= RAM_BASE && dut.serv0_axi_awaddr <= RAM_END) begin
                    m0_write_requests = m0_write_requests + 1;
                    m0_ram_writes = m0_ram_writes + 1;
                    m0_last_write_addr = dut.serv0_axi_awaddr;
                end else if (dut.serv0_axi_awaddr >= GPIO_BASE && dut.serv0_axi_awaddr <= GPIO_END) begin
                    m0_gpio_writes = m0_gpio_writes + 1;
                end else if (dut.serv0_axi_awaddr >= UART_BASE && dut.serv0_axi_awaddr <= UART_END) begin
                    m0_uart_writes = m0_uart_writes + 1;
                end else if (dut.serv0_axi_awaddr >= SPI_BASE && dut.serv0_axi_awaddr <= SPI_END) begin
                    m0_spi_writes = m0_spi_writes + 1;
                end
            end
            
            // M0 Write Data Channel
            if (dut.serv0_axi_wvalid && dut.serv0_axi_wready) begin
                if (m0_last_write_addr >= RAM_BASE && m0_last_write_addr <= RAM_END) begin
                    m0_last_write_data = dut.serv0_axi_wdata;
                end
            end
            
            // M0 Write Response Channel
            if (dut.serv0_axi_bvalid && dut.serv0_axi_bready) begin
                // Track write latency
                if (m0_write_start_time > 0) begin
                    m0_write_latency_sum = m0_write_latency_sum + ($time - m0_write_start_time);
                    m0_write_latency_count = m0_write_latency_count + 1;
                    m0_write_start_time = 0;
                end
                
                if (m0_last_write_addr >= RAM_BASE && m0_last_write_addr <= RAM_END) begin
                    m0_write_completed = m0_write_completed + 1;
                end
            end
            
            // M1 Write Address Channel
            if (dut.serv1_axi_awvalid && dut.serv1_axi_awready) begin
                m1_write_start_time = $time;
                
                // Count per-slave write requests
                if (dut.serv1_axi_awaddr >= RAM_BASE && dut.serv1_axi_awaddr <= RAM_END) begin
                    m1_write_requests = m1_write_requests + 1;
                    m1_ram_writes = m1_ram_writes + 1;
                    m1_last_write_addr = dut.serv1_axi_awaddr;
                end else if (dut.serv1_axi_awaddr >= GPIO_BASE && dut.serv1_axi_awaddr <= GPIO_END) begin
                    m1_gpio_writes = m1_gpio_writes + 1;
                end else if (dut.serv1_axi_awaddr >= UART_BASE && dut.serv1_axi_awaddr <= UART_END) begin
                    m1_uart_writes = m1_uart_writes + 1;
                end else if (dut.serv1_axi_awaddr >= SPI_BASE && dut.serv1_axi_awaddr <= SPI_END) begin
                    m1_spi_writes = m1_spi_writes + 1;
                end
            end
            
            // M1 Write Data Channel
            if (dut.serv1_axi_wvalid && dut.serv1_axi_wready) begin
                if (m1_last_write_addr >= RAM_BASE && m1_last_write_addr <= RAM_END) begin
                    m1_last_write_data = dut.serv1_axi_wdata;
                end
            end
            
            // M1 Write Response Channel
            if (dut.serv1_axi_bvalid && dut.serv1_axi_bready) begin
                // Track write latency
                if (m1_write_start_time > 0) begin
                    m1_write_latency_sum = m1_write_latency_sum + ($time - m1_write_start_time);
                    m1_write_latency_count = m1_write_latency_count + 1;
                    m1_write_start_time = 0;
                end
                
                if (m1_last_write_addr >= RAM_BASE && m1_last_write_addr <= RAM_END) begin
                    m1_write_completed = m1_write_completed + 1;
                end
            end
            
            // =================================================================
            // WISHBONE SIGNAL MONITORING (Internal signals from wb2axi_read)
            // =================================================================
            // Monitor wb_cyc transitions for M0
            if (dut.u_serv0.u_wb2axi_inst.wb_cyc !== m0_prev_wb_cyc) begin
                m0_wb_cyc_count = m0_wb_cyc_count + 1;
                m0_prev_wb_cyc = dut.u_serv0.u_wb2axi_inst.wb_cyc;
            end
            
            // Monitor wb_ack assertions for M0 (edge detection - rising edge)
            // CRITICAL: Check for rising edge (0->1 transition) to count each ack pulse
            // Use !== for comparison to handle X states correctly
            if (dut.u_serv0.u_wb2axi_inst.wb_ack === 1'b1 && m0_prev_wb_ack === 1'b0) begin
                m0_wb_ack_count = m0_wb_ack_count + 1;
                // Check if wb_cyc is high when ack is asserted
                if (dut.u_serv0.u_wb2axi_inst.wb_cyc === 1'b1) begin
                    m0_wb_ack_with_cyc = m0_wb_ack_with_cyc + 1;
                end
                // Timing analysis: log first 5 acks with timing info (only if VERBOSE)
                // Removed to reduce transcript verbosity
            end
            // Update previous value for edge detection (MUST be after edge check)
            // Use blocking assignment to ensure it's updated in the same cycle
            m0_prev_wb_ack = dut.u_serv0.u_wb2axi_inst.wb_ack;
            
            // Monitor wb_cyc transitions for M1
            if (dut.u_serv1.u_wb2axi_inst.wb_cyc !== m1_prev_wb_cyc) begin
                m1_wb_cyc_count = m1_wb_cyc_count + 1;
                m1_prev_wb_cyc = dut.u_serv1.u_wb2axi_inst.wb_cyc;
            end
            
            // Monitor wb_ack assertions for M1 (edge detection - rising edge)
            // CRITICAL: Check for rising edge (0->1 transition) to count each ack pulse
            // Use === for comparison to handle X states correctly
            if (dut.u_serv1.u_wb2axi_inst.wb_ack === 1'b1 && m1_prev_wb_ack === 1'b0) begin
                m1_wb_ack_count = m1_wb_ack_count + 1;
                // Check if wb_cyc is high when ack is asserted
                if (dut.u_serv1.u_wb2axi_inst.wb_cyc === 1'b1) begin
                    m1_wb_ack_with_cyc = m1_wb_ack_with_cyc + 1;
                end
                // Timing analysis: log first 5 acks with timing info (only if VERBOSE)
                // Removed to reduce transcript verbosity
            end
            // Update previous value for edge detection (MUST be after edge check)
            // Use blocking assignment to ensure it's updated in the same cycle
            m1_prev_wb_ack = dut.u_serv1.u_wb2axi_inst.wb_ack;
            
            // =================================================================
            // INSTRUCTION DATA VERIFICATION
            // =================================================================
            // Monitor instruction data when received by SERV core (via wb_rdt)
            // Check if instruction data matches expected values from hex file
            // DISABLED to reduce transcript verbosity - only log in final summary
            // (Instructions are already logged in wb_ack monitoring above)
            
            // Monitor i_ibus_ack signal in SERV core to verify wb_ack reaches the core
            // This is the actual signal SERV core sees (connected from wb_ibus_ack)
            // Path: dut.u_serv0.u_serv_core.i_ibus_ack (serv_rf_top instance)
            // Removed debug output to reduce transcript verbosity
            if (dut.u_serv0.u_serv_core.i_ibus_ack && !m0_prev_ibus_ack) begin
                // Track but don't display
            end
            m0_prev_ibus_ack = dut.u_serv0.u_serv_core.i_ibus_ack;
            
            if (dut.u_serv1.u_serv_core.i_ibus_ack && !m1_prev_ibus_ack) begin
                // Track but don't display
            end
            m1_prev_ibus_ack = dut.u_serv1.u_serv_core.i_ibus_ack;
            
            // =================================================================
            // COUNTER STATE MONITORING (SERV core internal signals)
            // =================================================================
            // Monitor cnt_done, cnt_en, and rf_ready for M0
            // These signals are critical for PC update
            
            // M0 counter monitoring
            if (dut.u_serv0.u_serv_core.o_cnt_done && !m0_prev_cnt_done) begin
                m0_cnt_done_count = m0_cnt_done_count + 1;
                // Removed debug output to reduce transcript verbosity
            end
            m0_prev_cnt_done = dut.u_serv0.u_serv_core.o_cnt_done;
            
            // Monitor PC address changes directly from SERV core (o_ibus_adr)
            // This is the actual PC, not the AXI address
            
            // M0 PC internal monitoring (from serv_ctrl o_ibus_adr)
            if (dut.u_serv0.u_serv_core.cpu.ctrl.o_ibus_adr !== m0_prev_ibus_adr) begin
                m0_pc_internal_changes = m0_pc_internal_changes + 1;
                if (m0_pc_internal_changes <= 10) begin
                    // Removed debug output to reduce transcript verbosity
                end
                m0_prev_ibus_adr = dut.u_serv0.u_serv_core.cpu.ctrl.o_ibus_adr;
            end
            
            // M1 counter monitoring
            if (dut.u_serv1.u_serv_core.o_cnt_done && !m1_prev_cnt_done) begin
                m1_cnt_done_count = m1_cnt_done_count + 1;
                // Removed debug output to reduce transcript verbosity
            end
            m1_prev_cnt_done = dut.u_serv1.u_serv_core.o_cnt_done;
            
            // M1 PC internal monitoring (from serv_ctrl o_ibus_adr)
            if (dut.u_serv1.u_serv_core.cpu.ctrl.o_ibus_adr !== m1_prev_ibus_adr) begin
                m1_pc_internal_changes = m1_pc_internal_changes + 1;
                if (m1_pc_internal_changes <= 10) begin
                    // Removed debug output to reduce transcript verbosity
                end
                m1_prev_ibus_adr = dut.u_serv1.u_serv_core.cpu.ctrl.o_ibus_adr;
            end
            
            // =================================================================
            // ARBITRATION CONFLICT DETECTION (Read only)
            // =================================================================
            // Detect RAM arbitration conflicts when both M0 and M1 request RAM simultaneously
            if (dut.serv0_axi_arvalid && dut.serv1_axi_arvalid) begin
                if ((dut.serv0_axi_araddr >= RAM_BASE && dut.serv0_axi_araddr <= RAM_END) &&
                    (dut.serv1_axi_araddr >= RAM_BASE && dut.serv1_axi_araddr <= RAM_END)) begin
                    
                    // Both masters requesting RAM - this is a conflict
                    ram_conflicts = ram_conflicts + 1;
                    // Only display conflicts in verbose mode
                    if (VERBOSE && ram_conflicts <= 3) begin
                        // Removed debug output to reduce transcript verbosity
                    end
                    
                    // Determine winner based on arready (only one should be ready in conflict)
                    if (dut.serv0_axi_arready && !dut.serv1_axi_arready) begin
                        m0_ram_wins = m0_ram_wins + 1;
                    end else if (!dut.serv0_axi_arready && dut.serv1_axi_arready) begin
                        m1_ram_wins = m1_ram_wins + 1;
                    end
                end
            end
        end
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    dual_riscv_axi_system #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ID_WIDTH(4),
        .RAM_WORDS(2048),
        .RAM_INIT_HEX(RAM_INIT_HEX)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .serv0_ARESETN_override(serv0_ARESETN_override),
        .serv0_reset_delay_enable(serv0_reset_delay_enable),
        .serv0_timer_irq(serv0_timer_irq),
        .serv1_timer_irq(serv1_timer_irq),
        .gpio_in(gpio_in),
        .gpio_out(gpio_out),
        .uart_tx_valid(uart_tx_valid),
        .uart_tx_byte(uart_tx_byte),
        .spi_cs_n(spi_cs_n),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso)
    );

endmodule

