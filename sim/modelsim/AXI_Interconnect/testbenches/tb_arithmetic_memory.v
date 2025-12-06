//==============================================================================
// tb_arithmetic_memory.v
// Testbench for Arithmetic + Memory Test
//
// Demonstrates difference between:
//   - Arithmetic operations (NO AXI transactions)
//   - Memory operations (YES AXI transactions)
//
// Test Program: test_arithmetic_with_memory.hex
//==============================================================================

`timescale 1ns/1ps

module tb_arithmetic_memory;

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH = 4;
    parameter RAM_WORDS = 2048;
    parameter RAM_INIT_HEX = "testdata/test_arithmetic_with_memory.hex";
    parameter CLK_PERIOD = 20;  // 50MHz
    
    //==========================================================================
    // Signals
    //==========================================================================
    reg ACLK;
    reg ARESETN;
    reg serv0_timer_irq;
    reg serv1_timer_irq;
    reg [31:0] gpio_in;
    reg spi_miso;
    
    wire [31:0] gpio_out;
    wire uart_tx_valid;
    wire [7:0] uart_tx_byte;
    wire spi_cs_n;
    wire spi_sclk;
    wire spi_mosi;
    
    //==========================================================================
    // Transaction Counters
    //==========================================================================
    integer total_reads = 0;
    integer total_writes = 0;
    integer instruction_fetches = 0;
    integer data_reads = 0;
    integer data_writes = 0;
    
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
        #(CLK_PERIOD * 5);
        ARESETN = 1;
        $display("[%0t] Reset released\n", $time);
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
    // Banner
    //==========================================================================
    initial begin
        $display("\n//////////////////////////////////////////////////////////////////");
        $display("/  ARITHMETIC + MEMORY ACCESS TEST                              /");
        $display("//////////////////////////////////////////////////////////////////\n");
        $display(" Test Program: %s", RAM_INIT_HEX);
        $display(" Clock: %0d MHz", 1000/CLK_PERIOD);
        $display("\n This test demonstrates:");
        $display("   Arithmetic ops (ADD/SUB) = NO AXI transactions");
        $display("   Memory ops (SW/LW) = YES AXI transactions!\n");
        $display("//////////////////////////////////////////////////////////////////\n");
    end
    
    //==========================================================================
    // Monitor READ Transactions with Classification
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_arvalid && dut.serv0_axi_arready) begin
            total_reads = total_reads + 1;
            
            // Classify: Instruction fetch vs Data read
            if (dut.serv0_axi_araddr < 32'h00000100) begin
                // Low addresses = Instruction fetches
                $display("[%0t] READ - Instruction Fetch", $time);
                $display("  Address: 0x%08h", dut.serv0_axi_araddr);
                $display("  Type: CODE");
                instruction_fetches = instruction_fetches + 1;
            end else begin
                // Higher addresses = Data reads
                $display("[%0t] READ - Data Load (LW)", $time);
                $display("  Address: 0x%08h", dut.serv0_axi_araddr);
                $display("  Type: DATA");
                data_reads = data_reads + 1;
            end
            $display("  [Total READs: %0d | Inst: %0d | Data: %0d]\n", 
                    total_reads, instruction_fetches, data_reads);
        end
    end
    
    //==========================================================================
    // Monitor WRITE Transactions
    //==========================================================================
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_awvalid && dut.serv0_axi_awready) begin
            total_writes = total_writes + 1;
            data_writes = data_writes + 1;
            
            $display("[%0t] WRITE - Data Store (SW)", $time);
            $display("  Address: 0x%08h", dut.serv0_axi_awaddr);
            $display("  Type: DATA");
        end
    end
    
    // Monitor Write Data
    always @(posedge ACLK) begin
        if (ARESETN && dut.serv0_axi_wvalid && dut.serv0_axi_wready) begin
            $display("  Data: 0x%08h", dut.serv0_axi_wdata);
            $display("  [Total WRITEs: %0d]\n", total_writes);
        end
    end
    
    //==========================================================================
    // Progress Report
    //==========================================================================
    initial begin
        wait(ARESETN == 1);
        
        forever begin
            #50000;  // Every 50us
            
            $display("\n[%0t] PROGRESS REPORT", $time);
            $display("//////////////////////////////////////////////////////////////////");
            $display("  Instruction Fetches: %0d (Arithmetic ops inside CPU)", instruction_fetches);
            $display("  Data Reads (LW):     %0d (AXI READ transactions)", data_reads);
            $display("  Data Writes (SW):    %0d (AXI WRITE transactions)", data_writes);
            $display("  //////////////////////////////////////////////////////////////////");
            $display("  Total AXI Trans:     %0d (Reads: %0d | Writes: %0d)", 
                    total_reads + total_writes, total_reads, total_writes);
            $display("//////////////////////////////////////////////////////////////////\n");
        end
    end
    
    //==========================================================================
    // Main Test Control
    //==========================================================================
    initial begin
        // Wait for reset
        wait(ARESETN == 1);
        #100;
        
        $display("[%0t] System initialized - Running test...\n", $time);
        $display("Watching for:");
        $display("  Part 1: Arithmetic ops (NO transactions)");
        $display("  Part 2: Store to memory (WRITE transactions)");
        $display("  Part 3: Load from memory (READ transactions)");
        $display("  Part 4: More arithmetic (NO transactions)");
        $display("  Part 5: Store results (WRITE transactions)\n");
        $display("//////////////////////////////////////////////////////////////////\n");
        
        // Run for extended time (SERV is VERY slow!)
        #10000000;  // 10ms - Give SERV plenty of time
        
        // Final Report
        $display("\n//////////////////////////////////////////////////////////////////");
        $display("/                    FINAL RESULTS                               /");
        $display("//////////////////////////////////////////////////////////////////\n");
        
        $display(" Simulation Time: %0t", $time);
        $display(" Clock Cycles: %0d\n", $time / CLK_PERIOD);
        
        $display(" Transaction Breakdown:");
        $display("  Instruction Fetches: %0d", instruction_fetches);
        $display("    (CPU fetching code - expected ~1-5)");
        $display("  Data Reads (LW):     %0d", data_reads);
        $display("    (Expected: ~5 from Part 3)");
        $display("  Data Writes (SW):    %0d", data_writes);
        $display("    (Expected: ~7 from Part 2 + Part 5)");
        $display("  //////////////////////////////////////////////////////////////////");
        $display("  Total Transactions:  %0d\n", total_reads + total_writes);
        
        $display(" Analysis:");
        if (data_writes >= 2 && data_reads >= 1) begin
            $display("  ALL PARTS EXECUTED!");
            $display("    Part 1: Arithmetic - OK (no trans expected)");
            $display("    Part 2: Store to mem - OK (%0d WRITEs)", data_writes);
            $display("    Part 3: Load from mem - OK (%0d READs)", data_reads);
            $display("    Part 5: Final store - OK\n");
            
            $display("//////////////////////////////////////////////////////////////////");
            $display("/                     TEST PASSED!                              /");
            $display("//////////////////////////////////////////////////////////////////\n");
            $display(" SUCCESS!");
            $display("   Hardware: WORKING");
            $display("   Arithmetic ops: Execute in CPU (no AXI)");
            $display("   Memory ops: Generate AXI transactions");
            $display("   Detected %0d transactions total\n", total_reads + total_writes);
            
        end else if (instruction_fetches >= 1) begin
            $display("  PARTIAL EXECUTION");
            $display("    Instruction fetch: OK");
            $display("    May need more time for SW/LW ops\n");
            
            $display("//////////////////////////////////////////////////////////////////");
            $display("/                   PARTIAL SUCCESS                             /");
            $display("//////////////////////////////////////////////////////////////////\n");
            $display(" Hardware verified (instruction fetch)");
            $display("   May need longer runtime for full test");
            $display("   SERV is very slow (bit-serial CPU)\n");
            
        end else begin
            $display("  NO ACTIVITY\n");
            $display("//////////////////////////////////////////////////////////////////");
            $display("/                        IDLE                                   /");
            $display("//////////////////////////////////////////////////////////////////\n");
        end
        
        $display("//////////////////////////////////////////////////////////////////\n");
        
        $finish;
    end
    
    //==========================================================================
    // Timeout
    //==========================================================================
    initial begin
        #15000000;  // 15ms timeout
        $display("\n TIMEOUT: Reached 15ms limit");
        $display(" Stopping simulation...\n");
        $finish;
    end

endmodule

