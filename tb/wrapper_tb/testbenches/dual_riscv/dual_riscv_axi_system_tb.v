//==============================================================================
// dual_riscv_axi_system_tb.v
// Testbench for Dual RISC-V AXI System (Verilog version)
// Tests complete system with 2 RISC-V cores + interconnect + 4 slaves
//==============================================================================

`timescale 1ns/1ps

module dual_riscv_axi_system_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH = 4;
    parameter RAM_WORDS = 2048;
    
    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    
    // Interrupts
    reg serv0_timer_irq;
    reg serv1_timer_irq;
    
    // GPIO
    reg [31:0] gpio_in;
    wire [31:0] gpio_out;
    
    // UART
    wire uart_tx_valid;
    wire [7:0] uart_tx_byte;
    
    // SPI
    wire spi_cs_n;
    wire spi_sclk;
    wire spi_mosi;
    reg spi_miso;
    
    // Statistics
    integer uart_char_count;
    
    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    dual_riscv_axi_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .RAM_WORDS(RAM_WORDS),
        .RAM_INIT_HEX("D:/AXI/sim/modelsim/testdata/test_program_simple.hex")
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
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
    
    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end
    
    //==========================================================================
    // UART Monitor
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN && uart_tx_valid) begin
            $write("%c", uart_tx_byte);
            uart_char_count = uart_char_count + 1;
        end
    end
    
    //==========================================================================
    // GPIO Monitor
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN && gpio_out != 0) begin
            $display("[%0t] GPIO Output: 0x%08h", $time, gpio_out);
        end
    end
    
    //==========================================================================
    // Main Test Sequence
    //==========================================================================
    initial begin
        $display("\n========================================");
        $display("Dual RISC-V AXI System Testbench");
        $display("========================================\n");
        
        // Initialize
        ARESETN = 0;
        serv0_timer_irq = 0;
        serv1_timer_irq = 0;
        gpio_in = 32'h00000000;
        spi_miso = 0;
        uart_char_count = 0;
        
        // Reset sequence
        repeat(10) @(posedge ACLK);
        $display("[%0t] Releasing reset...", $time);
        ARESETN = 1;
        repeat(5) @(posedge ACLK);
        
        $display("[%0t] System running...", $time);
        $display("========================================\n");
        
        // Test 1: Let CPUs run
        $display("[TEST 1] Running RISC-V cores...");
        repeat(1000) @(posedge ACLK);  // 10us
        
        // Test 2: GPIO input test
        $display("\n[TEST 2] GPIO Input test...");
        gpio_in = 32'hDEADBEEF;
        repeat(100) @(posedge ACLK);
        gpio_in = 32'h12345678;
        repeat(100) @(posedge ACLK);
        
        // Test 3: Timer interrupt
        $display("\n[TEST 3] Timer interrupt test...");
        serv0_timer_irq = 1;
        repeat(10) @(posedge ACLK);
        serv0_timer_irq = 0;
        repeat(100) @(posedge ACLK);
        
        serv1_timer_irq = 1;
        repeat(10) @(posedge ACLK);
        serv1_timer_irq = 0;
        repeat(100) @(posedge ACLK);
        
        // Test 4: Run longer for program execution
        $display("\n[TEST 4] Extended run for program execution...");
        repeat(5000) @(posedge ACLK);  // 50us
        
        // Summary
        $display("\n========================================");
        $display("Test Complete");
        $display("========================================");
        $display("Simulation time: %0t", $time);
        $display("UART characters: %0d", uart_char_count);
        $display("GPIO output: 0x%08h", gpio_out);
        $display("\nTransaction Statistics:");
        $display("  Master 0 Writes: %0d", m0_write_count);
        $display("  Master 1 Writes: %0d", m1_write_count);
        $display("  Master 0 Reads:  %0d", m0_read_count);
        $display("  Master 1 Reads:  %0d", m1_read_count);
        $display("  Total: %0d transactions", 
            m0_write_count + m1_write_count + m0_read_count + m1_read_count);
        $display("========================================\n");
        
        $finish;
    end
    
    //==========================================================================
    // Timeout Protection
    //==========================================================================
    initial begin
        #100000;  // 100us timeout
        $display("\n========================================");
        $display("ERROR: Simulation timeout!");
        $display("========================================\n");
        $finish;
    end
    
    //==========================================================================
    // Optional: Waveform Dump
    //==========================================================================
    initial begin
        $dumpfile("D:/AXI/sim/waveforms/dual_riscv_system.vcd");
        $dumpvars(0, dual_riscv_axi_system_tb);
    end
    
    //==========================================================================
    // Monitor AXI Transactions (Optional - for debug)
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor Master 0 Write
            if (dut.u_rr_xbar.M0_AWVALID && dut.u_rr_xbar.M0_AWREADY) begin
                $display("[%0t] M0 Write to addr 0x%08h", $time, dut.u_rr_xbar.M0_AWADDR);
            end
            
            // Monitor Master 1 Write  
            if (dut.u_rr_xbar.M1_AWVALID && dut.u_rr_xbar.M1_AWREADY) begin
                $display("[%0t] M1 Write to addr 0x%08h", $time, dut.u_rr_xbar.M1_AWADDR);
            end
            
            // Monitor Master 0 Read
            if (dut.u_rr_xbar.M0_ARVALID && dut.u_rr_xbar.M0_ARREADY) begin
                $display("[%0t] M0 Read from addr 0x%08h", $time, dut.u_rr_xbar.M0_ARADDR);
            end
            
            // Monitor Master 1 Read
            if (dut.u_rr_xbar.M1_ARVALID && dut.u_rr_xbar.M1_ARREADY) begin
                $display("[%0t] M1 Read from addr 0x%08h", $time, dut.u_rr_xbar.M1_ARADDR);
            end
        end
    end
    
    //==========================================================================
    // Performance Counters with Detailed Console Output
    //==========================================================================
    integer m0_write_count = 0;
    integer m1_write_count = 0;
    integer m0_read_count = 0;
    integer m1_read_count = 0;
    
    // Monitor all AXI transactions with detailed output
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor M0 Write
            if (dut.u_rr_xbar.M0_AWVALID && dut.u_rr_xbar.M0_AWREADY) begin
                m0_write_count = m0_write_count + 1;
                $display("[%0t] ✓ M0 WRITE #%0d: AWADDR=0x%08h", 
                         $time, m0_write_count, dut.u_rr_xbar.M0_AWADDR);
            end
            
            // Monitor M1 Write
            if (dut.u_rr_xbar.M1_AWVALID && dut.u_rr_xbar.M1_AWREADY) begin
                m1_write_count = m1_write_count + 1;
                $display("[%0t] ✓ M1 WRITE #%0d: AWADDR=0x%08h", 
                         $time, m1_write_count, dut.u_rr_xbar.M1_AWADDR);
            end
            
            // Monitor M0 Read with detailed info
            if (dut.u_rr_xbar.M0_ARVALID && dut.u_rr_xbar.M0_ARREADY) begin
                m0_read_count = m0_read_count + 1;
                $display("[%0t] ✓ M0 READ  #%0d: ARADDR=0x%08h (Target: %s)", 
                         $time, m0_read_count, dut.u_rr_xbar.M0_ARADDR,
                         (dut.u_rr_xbar.M0_ARADDR[31:30] == 2'b00) ? "RAM" :
                         (dut.u_rr_xbar.M0_ARADDR[31:30] == 2'b01) ? "GPIO" :
                         (dut.u_rr_xbar.M0_ARADDR[31:30] == 2'b10) ? "UART" : "SPI");
            end
            
            // Monitor M1 Read with detailed info
            if (dut.u_rr_xbar.M1_ARVALID && dut.u_rr_xbar.M1_ARREADY) begin
                m1_read_count = m1_read_count + 1;
                $display("[%0t] ✓ M1 READ  #%0d: ARADDR=0x%08h (Target: %s)", 
                         $time, m1_read_count, dut.u_rr_xbar.M1_ARADDR,
                         (dut.u_rr_xbar.M1_ARADDR[31:30] == 2'b00) ? "RAM" :
                         (dut.u_rr_xbar.M1_ARADDR[31:30] == 2'b01) ? "GPIO" :
                         (dut.u_rr_xbar.M1_ARADDR[31:30] == 2'b10) ? "UART" : "SPI");
            end
            
            // Monitor Read Data Return for M0
            if (dut.u_rr_xbar.M0_RVALID && dut.u_rr_xbar.M0_RREADY) begin
                $display("[%0t]   → M0 Read Data: RDATA=0x%08h", 
                         $time, dut.u_rr_xbar.M0_RDATA);
            end
            
            // Monitor Read Data Return for M1
            if (dut.u_rr_xbar.M1_RVALID && dut.u_rr_xbar.M1_RREADY) begin
                $display("[%0t]   → M1 Read Data: RDATA=0x%08h", 
                         $time, dut.u_rr_xbar.M1_RDATA);
            end
            
            // Monitor Write Data for M0
            if (dut.u_rr_xbar.M0_WVALID && dut.u_rr_xbar.M0_WREADY) begin
                $display("[%0t]   → M0 Write Data: WDATA=0x%08h, WSTRB=0x%h", 
                         $time, dut.u_rr_xbar.M0_WDATA, dut.u_rr_xbar.M0_WSTRB);
            end
            
            // Monitor Write Data for M1
            if (dut.u_rr_xbar.M1_WVALID && dut.u_rr_xbar.M1_WREADY) begin
                $display("[%0t]   → M1 Write Data: WDATA=0x%08h, WSTRB=0x%h", 
                         $time, dut.u_rr_xbar.M1_WDATA, dut.u_rr_xbar.M1_WSTRB);
            end
        end
    end
    
    //==========================================================================
    // Arbitration State Monitor
    //==========================================================================
    reg [1:0] last_grant;
    initial last_grant = 2'b00;
    
    always @(posedge ACLK) begin
        if (ARESETN) begin
            if ({dut.u_rr_xbar.grant_r_m0, dut.u_rr_xbar.grant_r_m1} != last_grant) begin
                last_grant = {dut.u_rr_xbar.grant_r_m0, dut.u_rr_xbar.grant_r_m1};
                if (dut.u_rr_xbar.grant_r_m0 && !dut.u_rr_xbar.grant_r_m1)
                    $display("[%0t] [ARB] Grant → Master 0 (Turn=%0d)", $time, dut.u_rr_xbar.rd_turn);
                else if (!dut.u_rr_xbar.grant_r_m0 && dut.u_rr_xbar.grant_r_m1)
                    $display("[%0t] [ARB] Grant → Master 1 (Turn=%0d)", $time, dut.u_rr_xbar.rd_turn);
            end
        end
    end
    
    //==========================================================================
    // Periodic Status Report
    //==========================================================================
    integer report_interval = 10000; // Report every 10us
    integer next_report = 10000;
    
    always @(posedge ACLK) begin
        if (ARESETN && $time >= next_report) begin
            $display("\n[%0t] === STATUS REPORT ===", $time);
            $display("  Transactions: M0_R=%0d M0_W=%0d | M1_R=%0d M1_W=%0d | Total=%0d",
                     m0_read_count, m0_write_count, 
                     m1_read_count, m1_write_count,
                     m0_read_count + m0_write_count + m1_read_count + m1_write_count);
            $display("  Arbitration: Mode=%0d, Turn=%0d, Active=%0d",
                     dut.u_rr_xbar.ARBITRATION_MODE, 
                     dut.u_rr_xbar.rd_turn,
                     dut.u_rr_xbar.read_active);
            $display("  Masters: M0_ARVALID=%0d M1_ARVALID=%0d",
                     dut.u_rr_xbar.M0_ARVALID, dut.u_rr_xbar.M1_ARVALID);
            next_report = next_report + report_interval;
        end
    end
    
endmodule

