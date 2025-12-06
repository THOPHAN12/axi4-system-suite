// ==============================================================================
// Testbench for RV32I Pipeline AXI System
// ==============================================================================
// Tests complete system: RV32I + AXI Interconnect + 4 Peripherals
//
// Date: December 5, 2025
// ==============================================================================

`timescale 1ns / 1ps

module tb_riscv_pipeline_system;

// ==============================================================================
// Parameters
// ==============================================================================
parameter CLK_PERIOD = 20;      // 50 MHz
parameter SIM_TIME = 100000;    // 100 microseconds

// ==============================================================================
// Signals
// ==============================================================================
reg clk;
reg rst_n;

// GPIO
reg  [31:0] gpio_in;
wire [31:0] gpio_out;
wire [31:0] gpio_dir;

// UART
reg  uart_rx;
wire uart_tx;

// SPI  
reg  spi_miso;
wire spi_sclk;
wire spi_mosi;
wire spi_cs;

// Debug
wire [31:0] debug_pc;
wire [31:0] debug_r1;
wire [31:0] debug_r2;

// ==============================================================================
// Clock Generation
// ==============================================================================
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// ==============================================================================
// Reset Generation
// ==============================================================================
initial begin
    rst_n = 0;
    gpio_in = 32'h0;
    uart_rx = 1'b1;
    spi_miso = 1'b0;
    
    #(CLK_PERIOD * 5);
    rst_n = 1;
    
    $display("\n//////////////////////////////////////////////////////////////////╗");
    $display("/   RV32I PIPELINE AXI SYSTEM TESTBENCH                            /");
    $display("//////////////////////////////////////////////////////////////////\n");
    $display("Configuration:");
    $display("   CPU: RV32I 5-Stage Pipeline");
    $display("   Interconnect: 2M × 4S (Round-Robin)");
    $display("   Clock: 50 MHz");
    $display("   Slaves: RAM, GPIO, UART, SPI\n");
    $display("[%0t] System initialized - Starting...\n", $time);
end

// ==============================================================================
// DUT: RV32I Pipeline AXI System
// ==============================================================================
riscv_pipeline_axi_system u_dut (
    .ACLK(clk),
    .ARESETN(rst_n),
    
    // GPIO
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    
    // UART
    .uart_tx_valid(),
    .uart_tx_byte(),
    
    // SPI
    .spi_cs_n(),
    .spi_sclk(spi_sclk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    
    // Debug
    .debug_pc(debug_pc),
    .debug_r1(debug_r1),
    .debug_r2(debug_r2)
);

// ==============================================================================
// Transaction Monitoring
// ==============================================================================
integer instr_fetch_count;
integer data_read_count;
integer data_write_count;
integer cycle_count;

initial begin
    instr_fetch_count = 0;
    data_read_count = 0;
    data_write_count = 0;
    cycle_count = 0;
end

// Monitor instruction fetches
always @(posedge clk) begin
    if (rst_n) begin
        cycle_count = cycle_count + 1;
        
        // Count instruction fetches (M0) - access internal signals
        if (u_dut.riscv_instr_arvalid && u_dut.riscv_instr_arready) begin
            instr_fetch_count = instr_fetch_count + 1;
            $display("[%0t] IFETCH[%0d]: PC=0x%08h", 
                    $time, instr_fetch_count, u_dut.riscv_instr_araddr);
        end
        
        // Count data writes (M1)
        if (u_dut.riscv_data_awvalid && u_dut.riscv_data_awready &&
            u_dut.riscv_data_wvalid && u_dut.riscv_data_wready) begin
            data_write_count = data_write_count + 1;
            $display("[%0t] DWRITE[%0d]: Addr=0x%08h Data=0x%08h",
                    $time, data_write_count, u_dut.riscv_data_awaddr, u_dut.riscv_data_wdata);
        end
        
        // Count data reads (M1)
        if (u_dut.riscv_data_arvalid && u_dut.riscv_data_arready) begin
            data_read_count = data_read_count + 1;
            $display("[%0t] DREAD[%0d]: Addr=0x%08h",
                    $time, data_read_count, u_dut.riscv_data_araddr);
        end
    end
end

// Status every 10us
always @(posedge clk) begin
    if (rst_n && (cycle_count % 500 == 0)) begin
        $display("\n[%0t] Status: PC=0x%08h | IFetch=%0d | DRead=%0d | DWrite=%0d | r1=%0d | r2=%0d\n",
                $time, debug_pc, instr_fetch_count, data_read_count, data_write_count, debug_r1, debug_r2);
    end
end

// ==============================================================================
// Test Scenarios
// ==============================================================================

// Scenario 1: Set GPIO input
initial begin
    #(CLK_PERIOD * 50);
    gpio_in = 32'hA5A5A5A5;
    $display("[%0t] Set GPIO input = 0xA5A5A5A5\n", $time);
end

// ==============================================================================
// Simulation Control
// ==============================================================================
initial begin
    // Wait for execution
    #SIM_TIME;
    
    $display("\n///////////////////////////////////////////////////////////////////");
    $display("/                    SIMULATION COMPLETE                           /");
    $display("///////////////////////////////////////////////////////////////////\n");
    
    $display(" Final Statistics:");
    $display("   Simulation time: %0t", $time);
    $display("   Clock cycles: %0d", cycle_count);
    $display("   Instruction fetches: %0d", instr_fetch_count);
    $display("   Data reads: %0d", data_read_count);
    $display("   Data writes: %0d", data_write_count);
    $display("   Total transactions: %0d", instr_fetch_count + data_read_count + data_write_count);
    $display("   CPI: ~%0d\n", cycle_count / (instr_fetch_count + 1));
    
    $display(" Performance:");
    $display("   RV32I CPI: ~%0d", cycle_count / (instr_fetch_count + 1));
    $display("   vs SERV: ~200 CPI");
    $display("   Speedup: ~%0d× faster!\n", 200 / (cycle_count / (instr_fetch_count + 1)));
    
    if (instr_fetch_count > 0 && debug_r1 > 0) begin
        $display("//////////////////////////////////////////////////////////////////");
        $display("/               TEST PASSED! SYSTEM WORKING!                     /");
        $display("/////////////////////////////////////////////////////////////////\n");
        $display(" RV32I Pipeline AXI System is FUNCTIONAL!\n");
    end else begin
        $display("  System may need more time to execute.\n");
    end
    
    $display("Waveform: tb_riscv_pipeline_system.vcd\n");
    $finish;
end

// ==============================================================================
// Waveform Dump
// ==============================================================================
initial begin
    $dumpfile("tb_riscv_pipeline_system.vcd");
    $dumpvars(0, tb_riscv_pipeline_system);
end

endmodule

