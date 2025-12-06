// ==============================================================================
// Testbench: Test ALL 4 Peripherals Coverage
// ==============================================================================
// Verifies that RV32I system can access all 4 slaves
//
// Expected behavior:
//   - Slave0 (RAM):  Multiple reads/writes
//   - Slave1 (GPIO): 2 writes, 1 read
//   - Slave2 (UART): 2 writes, 1 read  
//   - Slave3 (SPI):  2 writes, 2 reads
//
// Date: December 5, 2025
// ==============================================================================

`timescale 1ns/1ps

module tb_peripheral_coverage;

// ==============================================================================
// Parameters
// ==============================================================================
parameter CLK_PERIOD = 20;     // 50 MHz
parameter SIM_TIME = 500000;   // 500us (longer for SW/LW execution)

// ==============================================================================
// Signals
// ==============================================================================
reg clk;
reg rst_n;

// GPIO
reg  [31:0] gpio_in;
wire [31:0] gpio_out;

// UART
wire uart_tx_valid;
wire [7:0] uart_tx_byte;

// SPI
wire spi_cs_n;
wire spi_sclk;
wire spi_mosi;
reg  spi_miso;

// Debug
wire [31:0] debug_pc;
wire [31:0] debug_r1;
wire [31:0] debug_r2;

// Statistics
integer cycle_count;
integer instr_fetch_count;
integer data_read_count;
integer data_write_count;

// Slave access counters
integer slave0_reads, slave0_writes;
integer slave1_reads, slave1_writes;
integer slave2_reads, slave2_writes;
integer slave3_reads, slave3_writes;

// Coverage
integer slaves_tested;

// ==============================================================================
// Clock Generation
// ==============================================================================
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Clock counter
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cycle_count <= 0;
    else
        cycle_count <= cycle_count + 1;
end

// ==============================================================================
// DUT: RV32I Pipeline AXI System (with ALL PERIPHERALS test program)
// ==============================================================================
riscv_pipeline_axi_system #(
    .RAM_INIT_HEX("testdata/test_all_peripherals.hex")
) u_dut (
    .ACLK(clk),
    .ARESETN(rst_n),
    
    // GPIO
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    
    // UART
    .uart_tx_valid(uart_tx_valid),
    .uart_tx_byte(uart_tx_byte),
    
    // SPI
    .spi_cs_n(spi_cs_n),
    .spi_sclk(spi_sclk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    
    // Debug
    .debug_pc(debug_pc),
    .debug_r1(debug_r1),
    .debug_r2(debug_r2)
);

// ==============================================================================
// Monitor Slave Access via Address Decoder
// ==============================================================================
always @(posedge clk) begin
    if (rst_n) begin
        // Monitor READ accesses
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M00_AXI_arvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M00_AXI_arready) begin
            slave0_reads = slave0_reads + 1;
            $display("[%0t] READ  -> Slave0 (RAM)  | Addr=0x%08h | Total S0_R=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M00_AXI_araddr, slave0_reads);
        end
        
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M01_AXI_arvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M01_AXI_arready) begin
            slave1_reads = slave1_reads + 1;
            $display("[%0t] READ  -> Slave1 (GPIO) | Addr=0x%08h | Total S1_R=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M01_AXI_araddr, slave1_reads);
        end
        
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M02_AXI_arvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M02_AXI_arready) begin
            slave2_reads = slave2_reads + 1;
            $display("[%0t] READ  -> Slave2 (UART) | Addr=0x%08h | Total S2_R=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M02_AXI_araddr, slave2_reads);
        end
        
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M03_AXI_arvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M03_AXI_arready) begin
            slave3_reads = slave3_reads + 1;
            $display("[%0t] READ  -> Slave3 (SPI)  | Addr=0x%08h | Total S3_R=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AR_Channel_Controller_Top.u_Read_Addr_Channel_Dec.M03_AXI_araddr, slave3_reads);
        end
        
        // Monitor WRITE accesses
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M00_AXI_awvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M00_AXI_awready) begin
            slave0_writes = slave0_writes + 1;
            $display("[%0t] WRITE -> Slave0 (RAM)  | Addr=0x%08h | Total S0_W=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M00_AXI_awaddr, slave0_writes);
        end
        
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M01_AXI_awvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M01_AXI_awready) begin
            slave1_writes = slave1_writes + 1;
            $display("[%0t] WRITE -> Slave1 (GPIO) | Addr=0x%08h | Total S1_W=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M01_AXI_awaddr, slave1_writes);
        end
        
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M02_AXI_awvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M02_AXI_awready) begin
            slave2_writes = slave2_writes + 1;
            $display("[%0t] WRITE -> Slave2 (UART) | Addr=0x%08h | Total S2_W=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M02_AXI_awaddr, slave2_writes);
        end
        
        if (u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M03_AXI_awvalid && 
            u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M03_AXI_awready) begin
            slave3_writes = slave3_writes + 1;
            $display("[%0t] WRITE -> Slave3 (SPI)  | Addr=0x%08h | Total S3_W=%0d", 
                    $time, u_dut.u_axi_interconnect.u_full_interconnect.u_AW_Channel_Controller_Top.u_Write_Addr_Channel_Dec.M03_AXI_awaddr, slave3_writes);
        end
    end
end

// ==============================================================================
// Monitor Instruction Fetch
// ==============================================================================
always @(posedge clk) begin
    if (rst_n) begin
        if (u_dut.riscv_instr_arvalid && u_dut.riscv_instr_arready) begin
            instr_fetch_count = instr_fetch_count + 1;
        end
        
        // Monitor data channel
        if (u_dut.riscv_data_awvalid && u_dut.riscv_data_awready &&
            u_dut.riscv_data_wvalid && u_dut.riscv_data_wready) begin
            data_write_count = data_write_count + 1;
        end
        
        if (u_dut.riscv_data_arvalid && u_dut.riscv_data_arready) begin
            data_read_count = data_read_count + 1;
        end
    end
end

// ==============================================================================
// Status Display
// ==============================================================================
always @(posedge clk) begin
    if (rst_n && (cycle_count % 500 == 0)) begin  // Every 10us
        $display("\n[%0t] === STATUS REPORT ===", $time);
        $display("  PC=0x%08h | Cycles=%0d", debug_pc, cycle_count);
        $display("  Inst Fetches: %0d | Data R: %0d | Data W: %0d", 
                instr_fetch_count, data_read_count, data_write_count);
        $display("  Slave Coverage:");
        $display("    Slave0 (RAM):  R=%0d W=%0d %s", slave0_reads, slave0_writes, 
                (slave0_reads > 0 || slave0_writes > 0) ? "✅" : "❌");
        $display("    Slave1 (GPIO): R=%0d W=%0d %s", slave1_reads, slave1_writes,
                (slave1_reads > 0 || slave1_writes > 0) ? "✅" : "❌");
        $display("    Slave2 (UART): R=%0d W=%0d %s", slave2_reads, slave2_writes,
                (slave2_reads > 0 || slave2_writes > 0) ? "✅" : "❌");
        $display("    Slave3 (SPI):  R=%0d W=%0d %s", slave3_reads, slave3_writes,
                (slave3_reads > 0 || slave3_writes > 0) ? "✅" : "❌");
    end
end

// ==============================================================================
// Testbench Initialization
// ==============================================================================
initial begin
    // Initialize
    rst_n = 0;
    gpio_in = 32'hA5A5A5A5;
    spi_miso = 0;
    cycle_count = 0;
    instr_fetch_count = 0;
    data_read_count = 0;
    data_write_count = 0;
    slave0_reads = 0;
    slave0_writes = 0;
    slave1_reads = 0;
    slave1_writes = 0;
    slave2_reads = 0;
    slave2_writes = 0;
    slave3_reads = 0;
    slave3_writes = 0;
    
    // Reset sequence
    #100;
    rst_n = 1;
    
    $display("\n╔══════════════════════════════════════════════════════════════════╗");
    $display("║   RV32I PERIPHERAL COVERAGE TEST                                ║");
    $display("╚══════════════════════════════════════════════════════════════════╝\n");
    $display("Configuration:");
    $display("  • CPU: RV32I 5-Stage Pipeline");
    $display("  • Test: ALL 4 SLAVES");
    $display("  • Runtime: %0d us", SIM_TIME/1000);
    $display("");
    $display("Address Map:");
    $display("  • Slave0 (RAM):  0x00000000 - 0x3FFFFFFF");
    $display("  • Slave1 (GPIO): 0x40000000 - 0x7FFFFFFF");
    $display("  • Slave2 (UART): 0x80000000 - 0xBFFFFFFF");
    $display("  • Slave3 (SPI):  0xC0000000 - 0xFFFFFFFF");
    $display("");
    $display("[%0t] System initialized - Starting test...\n", $time);
end

// ==============================================================================
// Simulation End
// ==============================================================================
initial begin
    #SIM_TIME;
    
    $display("\n╔══════════════════════════════════════════════════════════════════╗");
    $display("║                  PERIPHERAL COVERAGE RESULTS                     ║");
    $display("╚══════════════════════════════════════════════════════════════════╝\n");
    
    $display("📊 Final Statistics:");
    $display("  • Simulation time: %0t", $time);
    $display("  • Clock cycles: %0d", cycle_count);
    $display("  • Total instruction fetches: %0d", instr_fetch_count);
    $display("  • Total data reads: %0d", data_read_count);
    $display("  • Total data writes: %0d\n", data_write_count);
    
    $display("📍 Slave Access Breakdown:");
    $display("  ┌─────────┬───────┬────────┬────────┐");
    $display("  │ Slave   │ Reads │ Writes │ Status │");
    $display("  ├─────────┼───────┼────────┼────────┤");
    $display("  │ S0 (RAM)│ %5d │ %6d │   %s   │", slave0_reads, slave0_writes,
            (slave0_reads > 0 || slave0_writes > 0) ? "✅" : "❌");
    $display("  │ S1 (GPIO)│ %5d │ %6d │   %s   │", slave1_reads, slave1_writes,
            (slave1_reads > 0 || slave1_writes > 0) ? "✅" : "❌");
    $display("  │ S2 (UART)│ %5d │ %6d │   %s   │", slave2_reads, slave2_writes,
            (slave2_reads > 0 || slave2_writes > 0) ? "✅" : "❌");
    $display("  │ S3 (SPI) │ %5d │ %6d │   %s   │", slave3_reads, slave3_writes,
            (slave3_reads > 0 || slave3_writes > 0) ? "✅" : "❌");
    $display("  └─────────┴───────┴────────┴────────┘\n");
    
    // Calculate coverage
    slaves_tested = 0;
    if (slave0_reads > 0 || slave0_writes > 0) slaves_tested = slaves_tested + 1;
    if (slave1_reads > 0 || slave1_writes > 0) slaves_tested = slaves_tested + 1;
    if (slave2_reads > 0 || slave2_writes > 0) slaves_tested = slaves_tested + 1;
    if (slave3_reads > 0 || slave3_writes > 0) slaves_tested = slaves_tested + 1;
    
    $display("📈 Coverage:");
    $display("  • Slaves tested: %0d/4 (%0d%%)", slaves_tested, slaves_tested*25);
    $display("  • Expected: 4/4 (100%%)");
    
    if (slaves_tested == 4) begin
        $display("\n╔══════════════════════════════════════════════════════════════════╗");
        $display("║         ✅ FULL COVERAGE! ALL 4 SLAVES TESTED! ✅              ║");
        $display("╚══════════════════════════════════════════════════════════════════╝");
        $display("🎉 SUCCESS! System can access ALL peripherals!\n");
    end else begin
        $display("\n╔══════════════════════════════════════════════════════════════════╗");
        $display("║         ⚠️  PARTIAL COVERAGE: %0d/4 slaves tested               ║", slaves_tested);
        $display("╚══════════════════════════════════════════════════════════════════╝");
        
        $display("\n❌ Missing coverage:");
        if (slave0_reads == 0 && slave0_writes == 0) $display("  • Slave0 (RAM)  - NOT ACCESSED");
        if (slave1_reads == 0 && slave1_writes == 0) $display("  • Slave1 (GPIO) - NOT ACCESSED");
        if (slave2_reads == 0 && slave2_writes == 0) $display("  • Slave2 (UART) - NOT ACCESSED");
        if (slave3_reads == 0 && slave3_writes == 0) $display("  • Slave3 (SPI)  - NOT ACCESSED");
        
        $display("\n💡 Possible reasons:");
        $display("  1. CPU didn't reach those instructions yet (need more time)");
        $display("  2. Test program issue (check hex file)");
        $display("  3. Address decoder configuration\n");
    end
    
    $display("Waveform: tb_peripheral_coverage.vcd\n");
    $finish;
end

// ==============================================================================
// VCD Dump
// ==============================================================================
initial begin
    $dumpfile("tb_peripheral_coverage.vcd");
    $dumpvars(0, tb_peripheral_coverage);
end

endmodule

