`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////////////
// Testbench: arbitration_monitor_tb
// Description: Monitor AXI arbitration between M0 and M1
//              Shows how arbitration works and prints transaction details
////////////////////////////////////////////////////////////////////////////////

module arbitration_monitor_tb;

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter RAM_INIT_HEX = "arbitration_test_simple.hex";
    parameter SIM_TIME = 50000;  // 50us - just monitor initial transactions
    parameter MAX_TRANSACTIONS = 10;  // Stop after monitoring this many transactions
    
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
    // Monitoring Variables
    //==========================================================================
    integer transaction_count;
    integer m0_read_count;
    integer m1_read_count;
    integer m0_write_count;
    integer m1_write_count;
    integer arbitration_conflicts;
    integer m0_arbitration_wins;
    integer m1_arbitration_wins;
    
    integer cycle_count;

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
        serv0_reset_delay_enable = 0;
        serv0_timer_irq = 0;
        serv1_timer_irq = 0;
        gpio_in = 0;
        spi_miso = 0;
        
        // Release reset after 100ns
        #100;
        ARESETN = 1;
        
        $display("============================================================================");
        $display("AXI ARBITRATION MONITOR");
        $display("============================================================================");
        $display("Test program: %s", RAM_INIT_HEX);
        $display("Monitoring first %0d transactions...", MAX_TRANSACTIONS);
        $display("============================================================================");
        $display("");
        $display("Legend:");
        $display("  READ  - Read address channel handshake");
        $display("  RDATA - Read data channel response");
        $display("  WRITE - Write address + data channel handshake");
        $display("  ARB   - Arbitration conflict (both masters request simultaneously)");
        $display("============================================================================");
        $display("");
    end

    //==========================================================================
    // Monitoring Logic
    //==========================================================================
    initial begin
        transaction_count = 0;
        m0_read_count = 0;
        m1_read_count = 0;
        m0_write_count = 0;
        m1_write_count = 0;
        arbitration_conflicts = 0;
        m0_arbitration_wins = 0;
        m1_arbitration_wins = 0;
        cycle_count = 0;
    end
    
    // Cycle counter
    always @(posedge ACLK) begin
        if (ARESETN) begin
            cycle_count <= cycle_count + 1;
        end
    end

    // Monitor M0 read address transactions
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_arvalid && dut.serv0_axi_arready) begin
            m0_read_count <= m0_read_count + 1;
            transaction_count <= transaction_count + 1;
            $display("[%7d ns] [M0 READ ] addr=0x%08h | count=%0d", 
                     $time/1000, dut.serv0_axi_araddr, m0_read_count + 1);
        end
    end
    
    // Monitor M1 read address transactions
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv1_axi_arvalid && dut.serv1_axi_arready) begin
            m1_read_count <= m1_read_count + 1;
            transaction_count <= transaction_count + 1;
            $display("[%7d ns] [M1 READ ] addr=0x%08h | count=%0d", 
                     $time/1000, dut.serv1_axi_araddr, m1_read_count + 1);
        end
    end
    
    // Monitor M0 read data responses
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_rvalid && dut.serv0_axi_rready) begin
            $display("[%7d ns] [M0 RDATA] data=0x%08h", 
                     $time/1000, dut.serv0_axi_rdata);
        end
    end
    
    // Monitor M1 read data responses
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv1_axi_rvalid && dut.serv1_axi_rready) begin
            $display("[%7d ns] [M1 RDATA] data=0x%08h", 
                     $time/1000, dut.serv1_axi_rdata);
        end
    end
    
    // Monitor M0 write transactions
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_awvalid && dut.serv0_axi_awready && 
            dut.serv0_axi_wvalid && dut.serv0_axi_wready) begin
            m0_write_count <= m0_write_count + 1;
            transaction_count <= transaction_count + 1;
            $display("[%7d ns] [M0 WRITE] addr=0x%08h | data=0x%08h (%0d) | count=%0d", 
                     $time/1000, dut.serv0_axi_awaddr, dut.serv0_axi_wdata, 
                     dut.serv0_axi_wdata, m0_write_count + 1);
        end
    end
    
    // Monitor M1 write transactions
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv1_axi_awvalid && dut.serv1_axi_awready && 
            dut.serv1_axi_wvalid && dut.serv1_axi_wready) begin
            m1_write_count <= m1_write_count + 1;
            transaction_count <= transaction_count + 1;
            $display("[%7d ns] [M1 WRITE] addr=0x%08h | data=0x%08h (%0d) | count=%0d", 
                     $time/1000, dut.serv1_axi_awaddr, dut.serv1_axi_wdata, 
                     dut.serv1_axi_wdata, m1_write_count + 1);
        end
    end
    
    // Monitor arbitration conflicts
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_arvalid && dut.serv1_axi_arvalid) begin
            if (dut.serv0_axi_arready) begin
                m0_arbitration_wins <= m0_arbitration_wins + 1;
                arbitration_conflicts <= arbitration_conflicts + 1;
                $display("[%7d ns] [ARB    ] CONFLICT: M0 wins | M0_wins=%0d, M1_wins=%0d, total=%0d", 
                         $time/1000, m0_arbitration_wins + 1, m1_arbitration_wins, arbitration_conflicts + 1);
            end else if (dut.serv1_axi_arready) begin
                m1_arbitration_wins <= m1_arbitration_wins + 1;
                arbitration_conflicts <= arbitration_conflicts + 1;
                $display("[%7d ns] [ARB    ] CONFLICT: M1 wins | M0_wins=%0d, M1_wins=%0d, total=%0d", 
                         $time/1000, m0_arbitration_wins, m1_arbitration_wins + 1, arbitration_conflicts + 1);
            end
        end
    end
    
    // Monitor transaction count and stop after MAX_TRANSACTIONS
    always @(posedge ACLK) begin
        if (transaction_count >= MAX_TRANSACTIONS) begin
            #1000;  // Wait a bit for pending transactions
            
            $display("");
            $display("============================================================================");
            $display("MONITORING COMPLETED - %0d TRANSACTIONS", transaction_count);
            $display("============================================================================");
            $display("Execution time: %0d cycles (%0d ns)", cycle_count, $time/1000);
            $display("");
            $display("Transaction Summary:");
            $display("  M0: %0d reads, %0d writes (total=%0d)", 
                     m0_read_count, m0_write_count, m0_read_count + m0_write_count);
            $display("  M1: %0d reads, %0d writes (total=%0d)", 
                     m1_read_count, m1_write_count, m1_read_count + m1_write_count);
            $display("");
            $display("Arbitration Summary:");
            $display("  Total conflicts: %0d", arbitration_conflicts);
            if (arbitration_conflicts > 0) begin
                $display("  M0 wins: %0d (%.1f%%)", m0_arbitration_wins, 
                         (m0_arbitration_wins * 100.0) / arbitration_conflicts);
                $display("  M1 wins: %0d (%.1f%%)", m1_arbitration_wins, 
                         (m1_arbitration_wins * 100.0) / arbitration_conflicts);
                $display("");
                $display("  Arbitration is %s", 
                         ((m0_arbitration_wins > 0) && (m1_arbitration_wins > 0)) ? 
                         "WORKING (both masters won at least once)" : 
                         "NOT FAIR (only one master winning)");
            end
            $display("============================================================================");
            $display("");
            
            $finish;
        end
    end
    
    // Timeout
    initial begin
        #SIM_TIME;
        $display("");
        $display("============================================================================");
        $display("TIMEOUT: Did not observe %0d transactions within %0d ns", MAX_TRANSACTIONS, SIM_TIME/1000);
        $display("============================================================================");
        $display("Current status:");
        $display("  Transactions: %0d (target: %0d)", transaction_count, MAX_TRANSACTIONS);
        $display("  M0: reads=%0d, writes=%0d", m0_read_count, m0_write_count);
        $display("  M1: reads=%0d, writes=%0d", m1_read_count, m1_write_count);
        $display("  Arbitration conflicts: %0d (M0=%0d, M1=%0d)", 
                 arbitration_conflicts, m0_arbitration_wins, m1_arbitration_wins);
        $display("============================================================================");
        $finish;
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

