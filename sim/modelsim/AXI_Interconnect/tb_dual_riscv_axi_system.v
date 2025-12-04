//==============================================================================
// tb_dual_riscv_axi_system.v
// Testbench for Dual RISC-V AXI System
//
// Features:
//   - Clock generation (50MHz = 20ns period)
//   - Reset sequence
//   - Transaction monitoring
//   - Console output
//   - Automatic test program loading
//   - VCD waveform dump
//
// Usage:
//   vlog -work work -sv tb_dual_riscv_axi_system.v
//   vsim -voptargs=+acc work.tb_dual_riscv_axi_system
//   run 100us
//==============================================================================

`timescale 1ns/1ps

module tb_dual_riscv_axi_system;

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH = 4;
    parameter RAM_WORDS = 2048;
    parameter RAM_INIT_HEX = "testdata/test_program.hex";
    
    parameter CLK_PERIOD = 20;  // 50MHz = 20ns period
    
    //==========================================================================
    // Clock and Reset
    //==========================================================================
    reg ACLK;
    reg ARESETN;
    
    //==========================================================================
    // DUT Inputs
    //==========================================================================
    reg        serv0_timer_irq;
    reg        serv1_timer_irq;
    reg [31:0] gpio_in;
    reg        spi_miso;
    
    //==========================================================================
    // DUT Outputs
    //==========================================================================
    wire [31:0] gpio_out;
    wire        uart_tx_valid;
    wire [7:0]  uart_tx_byte;
    wire        spi_cs_n;
    wire        spi_sclk;
    wire        spi_mosi;
    
    //==========================================================================
    // Transaction Counters
    //==========================================================================
    integer read_count = 0;
    integer write_count = 0;
    integer test_pass = 0;
    
    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    dual_riscv_axi_system #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .ID_WIDTH    (ID_WIDTH),
        .RAM_WORDS   (RAM_WORDS),
        .RAM_INIT_HEX(RAM_INIT_HEX)
    ) dut (
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),
        .serv0_timer_irq(serv0_timer_irq),
        .serv1_timer_irq(serv1_timer_irq),
        .gpio_in        (gpio_in),
        .gpio_out       (gpio_out),
        .uart_tx_valid  (uart_tx_valid),
        .uart_tx_byte   (uart_tx_byte),
        .spi_cs_n       (spi_cs_n),
        .spi_sclk       (spi_sclk),
        .spi_mosi       (spi_mosi),
        .spi_miso       (spi_miso)
    );
    
    //==========================================================================
    // Clock Generation (50MHz = 20ns period)
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
        #(CLK_PERIOD * 5);  // Hold reset for 5 clock cycles
        ARESETN = 1;
        $display("[%0t]  Reset released", $time);
    end
    
    //==========================================================================
    // Initialize Inputs
    //==========================================================================
    initial begin
        serv0_timer_irq = 0;
        serv1_timer_irq = 0;
        gpio_in = 32'h0;
        spi_miso = 0;
    end
    
    //==========================================================================
    // VCD Dump for Waveform Viewing
    //==========================================================================
    initial begin
        $dumpfile("tb_dual_riscv.vcd");
        $dumpvars(0, tb_dual_riscv_axi_system);
    end
    
    //==========================================================================
    // Test Banner
    //==========================================================================
    initial begin
        $display("\n///////////////////////////////////////////////////////////");
        $display("/    TESTBENCH - Dual RISC-V AXI System                    /");
        $display("////////////////////////////////////////////////////////////");
        $display(" Configuration:");
        $display("  Clock Period: %0d ns (Frequency: %0d MHz)", CLK_PERIOD, 1000/CLK_PERIOD);
        $display("  Address Width: %0d bits", ADDR_WIDTH);
        $display("  Data Width: %0d bits", DATA_WIDTH);
        $display("  RAM Words: %0d", RAM_WORDS);
        $display("  RAM Init File: %s\n", RAM_INIT_HEX);
        $display("  Starting simulation at time 0...");
        $display("////////////////////////////////////////////////////////////\n");
    end
    
    //==========================================================================
    // Monitor AXI Transactions from SERV Core 0
    //==========================================================================
    
    // Monitor Write Address Channel
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_awvalid && dut.serv0_axi_awready) begin
            $display("[%0t] SERV0 WRITE ADDRESS", $time);
            $display("    Address: 0x%08h", dut.serv0_axi_awaddr);
            $display("    Prot: 0x%h", dut.serv0_axi_awprot);
            write_count = write_count + 1;
        end
    end
    
    // Monitor Write Data Channel
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_wvalid && dut.serv0_axi_wready) begin
            $display("[%0t] SERV0 WRITE DATA", $time);
            $display("    Data: 0x%08h", dut.serv0_axi_wdata);
            $display("    Strobe: 0x%h", dut.serv0_axi_wstrb);
        end
    end
    
    // Monitor Write Response Channel
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_bvalid && dut.serv0_axi_bready) begin
            $display("[%0t] SERV0 WRITE RESPONSE", $time);
            $display("    Response: 0x%h (%s)", dut.serv0_axi_bresp, 
                    (dut.serv0_axi_bresp == 0) ? "OKAY" :
                    (dut.serv0_axi_bresp == 1) ? "EXOKAY" :
                    (dut.serv0_axi_bresp == 2) ? "SLVERR" : "DECERR");
        end
    end
    
    // Monitor Read Address Channel
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_arvalid && dut.serv0_axi_arready) begin
            $display("[%0t] SERV0 READ ADDRESS", $time);
            $display("    Address: 0x%08h", dut.serv0_axi_araddr);
            $display("    Prot: 0x%h", dut.serv0_axi_arprot);
            read_count = read_count + 1;
        end
    end
    
    // Monitor Read Data Channel
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_rvalid && dut.serv0_axi_rready) begin
            $display("[%0t] SERV0 READ DATA", $time);
            $display("    Data: 0x%08h", dut.serv0_axi_rdata);
            $display("    Response: 0x%h (%s)", dut.serv0_axi_rresp,
                    (dut.serv0_axi_rresp == 0) ? "OKAY" :
                    (dut.serv0_axi_rresp == 1) ? "EXOKAY" :
                    (dut.serv0_axi_rresp == 2) ? "SLVERR" : "DECERR");
        end
    end
    
    //==========================================================================
    // Monitor AXI Transactions from SERV Core 1
    //==========================================================================
    
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv1_axi_awvalid && dut.serv1_axi_awready) begin
            $display("[%0t] SERV1 WRITE ADDRESS: 0x%08h", $time, dut.serv1_axi_awaddr);
            write_count = write_count + 1;
        end
    end
    
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv1_axi_arvalid && dut.serv1_axi_arready) begin
            $display("[%0t] SERV1 READ ADDRESS: 0x%08h", $time, dut.serv1_axi_araddr);
            read_count = read_count + 1;
        end
    end
    
    //==========================================================================
    // Monitor Peripheral Activity
    //==========================================================================
    
    // Monitor GPIO
    always @(posedge ACLK) begin
        if (ARESETN && gpio_out != 32'h0) begin
            $display("[%0t] GPIO OUTPUT: 0x%08h", $time, gpio_out);
        end
    end
    
    // Monitor UART TX
    always @(posedge ACLK) begin
        if (ARESETN && uart_tx_valid) begin
            $display("[%0t] UART TX: 0x%02h ('%c')", $time, uart_tx_byte, uart_tx_byte);
        end
    end
    
    // Monitor SPI
    always @(posedge ACLK) begin
        if (ARESETN && !spi_cs_n) begin
            $display("[%0t] SPI Active: CS=0 SCLK=%b MOSI=%b", $time, spi_sclk, spi_mosi);
        end
    end
    
    //==========================================================================
    // Periodic Status Report
    //==========================================================================
    initial begin
        forever begin
            #10000;  // Every 10us
            if (ARESETN) begin
                $display("\n[%0t] Status: Reads=%0d | Writes=%0d | Total=%0d", 
                         $time, read_count, write_count, read_count + write_count);
            end
        end
    end
    
    //==========================================================================
    // Test Sequence
    //==========================================================================
    initial begin
        // Wait for reset release
        wait(ARESETN == 1);
        #100;
        
        $display("\n[%0t] System initialized - Starting test...\n", $time);
        
        // Test GPIO input
        #1000;
        gpio_in = 32'hA5A5A5A5;
        $display("[%0t] Set GPIO Input: 0x%08h", $time, gpio_in);
        
        // Generate some timer interrupts
        #5000;
        serv0_timer_irq = 1;
        #(CLK_PERIOD * 2);
        serv0_timer_irq = 0;
        $display("[%0t] SERV0 Timer IRQ pulse", $time);
        
        #10000;
        serv1_timer_irq = 1;
        #(CLK_PERIOD * 2);
        serv1_timer_irq = 0;
        $display("[%0t] SERV1 Timer IRQ pulse", $time);
    end
    
    //==========================================================================
    // Simulation Control and Final Report
    //==========================================================================
    initial begin
        // Run for specified time
        #100000;  // 100us
        
        $display("\n///////////////////////////////////////////////////////////");
        $display("/////////////////////////////////////////////////////////////");
        $display("/                    SIMULATION COMPLETE                    /");
        $display("/////////////////////////////////////////////////////////////\n");
        
        $display(" Simulation Time: %0t", $time);
        $display(" Clock Cycles: %0d\n", $time / CLK_PERIOD);
        
        $display(" AXI Transaction Summary:");
        $display("  Read Transactions:  %0d", read_count);
        $display("  Write Transactions: %0d", write_count);
        $display("  Total Transactions: %0d\n", read_count + write_count);
        
        if (read_count + write_count > 0) begin
            $display("/////////////////////////////////////////////////////////////");
            $display("/                     TEST PASSED!                          /");
            $display("/////////////////////////////////////////////////////////////\n");
            $display(" System is ACTIVE");
            $display("   Detected %0d AXI transactions", read_count + write_count);
            $display("   RISC-V cores are executing");
            $display("   Interconnect is routing traffic\n");
            test_pass = 1;
        end else begin
            $display("/////////////////////////////////////////////////////////////");
            $display("/                      SYSTEM IDLE                          /");
            $display("/////////////////////////////////////////////////////////////\n");
            $display("  No transactions detected");
            $display("   Check if test program loaded into RAM");
            $display("   Check reset timing");
            $display("   Check clock generation\n");
        end
        
        $display(" Peripheral Status:");
        $display("   GPIO Output: 0x%08h", gpio_out);
        $display("   SPI CS: %b", spi_cs_n);
        $display("   UART TX Valid: %b\n", uart_tx_valid);
        
        $display("////////////////////////////////////////////////////////////////\n");
        
        if (test_pass) begin
            $display(" TESTBENCH: PASSED \n");
        end else begin
            $display("  TESTBENCH: IDLE (No transactions - check test program)\n");
        end
        
        $display("Waveform saved to: tb_dual_riscv.vcd\n");
        
        $finish;
    end
    
    //==========================================================================
    // Timeout Watchdog
    //==========================================================================
    initial begin
        #1000000;  // 1ms timeout
        $display("\  TIMEOUT: Simulation reached 1ms limit");
        $display("Stopping simulation...\n");
        $finish;
    end
    
    //==========================================================================
    // Debug: Print Important Internal States
    //==========================================================================
    initial begin
        wait(ARESETN == 1);
        #1000;
        
        forever begin
            #10000;  // Every 10us
            
            // Check interconnect state
            $display("\n[%0t]  Debug Info:", $time);
            $display("  Interconnect Arbiter:");
            $display("    WR Turn: %0d | RD Turn: %0d", 
                    dut.u_axi_interconnect.u_full_interconnect.wr_turn,
                    dut.u_axi_interconnect.u_full_interconnect.rd_turn);
            $display("  SERV0 AXI Signals:");
            $display("    AWVALID=%b AWREADY=%b ARVALID=%b ARREADY=%b",
                    dut.serv0_axi_awvalid, dut.serv0_axi_awready,
                    dut.serv0_axi_arvalid, dut.serv0_axi_arready);
            $display("  RAM (S0) Signals:");
            $display("    AWVALID=%b AWREADY=%b ARVALID=%b ARREADY=%b\n",
                    dut.S0_awvalid, dut.S0_awready,
                    dut.S0_arvalid, dut.S0_arready);
        end
    end

endmodule

