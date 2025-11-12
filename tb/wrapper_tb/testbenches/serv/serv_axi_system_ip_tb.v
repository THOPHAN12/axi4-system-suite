/*
 * serv_axi_system_ip_tb.v : Testbench for Complete SERV RISC-V System IP
 * 
 * Tests the complete IP module with integrated memory slaves
 */

`timescale 1ns/1ps

module serv_axi_system_ip_tb;

// Parameters
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter ID_WIDTH   = 4;
parameter CLK_PERIOD = 10;  // 100 MHz

// Clock and Reset
reg  ACLK;
reg  ARESETN;
reg  i_timer_irq;

// Status signals
wire inst_mem_ready;
wire data_mem_ready;

// Clock generation
always begin
    ACLK = 1'b0;
    #(CLK_PERIOD/2);
    ACLK = 1'b1;
    #(CLK_PERIOD/2);
end

// Reset generation
initial begin
    ARESETN = 1'b0;
    i_timer_irq = 1'b0;
    #(CLK_PERIOD * 10);
    ARESETN = 1'b1;
    $display("[%0t] Reset released", $time);
    #(CLK_PERIOD * 1000);
    $finish;
end

// DUT Instance - Complete IP Module
serv_axi_system_ip #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .ID_WIDTH           (ID_WIDTH),
    .WITH_CSR           (1),
    .W                  (1),
    .PRE_REGISTER       (1),
    .RESET_STRATEGY     ("MINI"),
    .RESET_PC           (32'h0000_0000),
    .DEBUG              (1'b0),
    .MDU                (1'b0),
    .COMPRESSED         (0),
    .Num_Of_Slaves      (2),
    .SLAVE0_ADDR1       (32'h0000_0000),
    .SLAVE0_ADDR2       (32'h0000_FFFF),
    .SLAVE1_ADDR1       (32'h1000_0000),
    .SLAVE1_ADDR2       (32'h1FFF_FFFF),
    .INST_MEM_SIZE      (1024),
    .DATA_MEM_SIZE      (1024),
    .INST_MEM_INIT_FILE ("../../sim/modelsim/test_program_simple.hex"),
    .DATA_MEM_INIT_FILE ("")
) u_dut (
    .ACLK               (ACLK),
    .ARESETN            (ARESETN),
    .i_timer_irq        (i_timer_irq),
    .inst_mem_ready     (inst_mem_ready),
    .data_mem_ready     (data_mem_ready)
);

// Monitoring
initial begin
    $dumpfile("serv_axi_system_ip_tb.vcd");
    $dumpvars(0, serv_axi_system_ip_tb);
    
    $display("============================================================================");
    $display("SERV RISC-V System IP Testbench");
    $display("============================================================================");
    $display("Complete IP Module with Integrated Memory Slaves");
    $display("  - Instruction Memory (ROM): Integrated");
    $display("  - Data Memory (RAM): Integrated");
    $display("  - No external slave connections needed!");
    $display("============================================================================");
    $display("");
end

// Test stimulus
initial begin
    // Wait for reset
    wait(ARESETN);
    #(CLK_PERIOD * 10);
    
    $display("[%0t] System ready - SERV will start fetching instructions", $time);
    $display("[%0t] Instruction Memory Ready: %b", $time, inst_mem_ready);
    $display("[%0t] Data Memory Ready: %b", $time, data_mem_ready);
    $display("");
    
    // Monitor for a while
    #(CLK_PERIOD * 500);
    
    $display("[%0t] Test completed", $time);
end

endmodule

