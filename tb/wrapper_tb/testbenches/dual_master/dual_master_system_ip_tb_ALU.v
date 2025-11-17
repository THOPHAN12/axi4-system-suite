/*
 * dual_master_system_ip_tb_ALU.v : Testbench for Complete Dual Master System IP (ALU-focused)
 * 
 * Tests the complete IP module with integrated memory slaves:
 * - SERV RISC-V processor
 * - ALU Master
 * - 4 Memory Slaves (Instruction, Data, ALU, Reserved)
 */

`timescale 1ns/1ps

module dual_master_system_ip_tb_ALU;

// Parameters
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter ID_WIDTH   = 4;
parameter CLK_PERIOD = 10;  // 100 MHz

// Clock and Reset
reg  ACLK;
reg  ARESETN;
reg  i_timer_irq;

// ALU Master Control
reg  alu_master_start;
wire alu_master_busy;
wire alu_master_done;

// Status signals
wire inst_mem_ready;
wire data_mem_ready;
wire alu_mem_ready;
wire reserved_mem_ready;

// ALU memory/test configuration
// NOTE: ALU Master bypasses interconnect and connects directly to Slave2 (ALU RAM)
// All ALU addresses must use Slave2 base address (0x80000000)
localparam [31:0] ALU_MEM_BASE_ADDR      = 32'h8000_0000;  // Slave2 base address
localparam [7:0]  ALU_DATA_BASE_ADDR     = 8'h40;
localparam integer ALU_DATA_STRIDE_BYTES = 12;      // 3 words per test (A, B, result)
localparam integer ALU_MEM_WORDS         = 1024;    // Keep in sync with ALU_MEM_SIZE parameter
localparam integer NUM_ALU_TESTS         = 10;

// AXI slave address map (mirrors DUT parameters for readability)
localparam [31:0] SLAVE0_ADDR_START = 32'h0000_0000;  // Instruction memory
localparam [31:0] SLAVE0_ADDR_END   = 32'h3FFF_FFFF;
localparam [31:0] SLAVE1_ADDR_START = 32'h4000_0000;  // Data memory
localparam [31:0] SLAVE1_ADDR_END   = 32'h7FFF_FFFF;
localparam [31:0] SLAVE2_ADDR_START = 32'h8000_0000;  // ALU memory
localparam [31:0] SLAVE2_ADDR_END   = 32'hBFFF_FFFF;
localparam [31:0] SLAVE3_ADDR_START = 32'hC000_0000;  // Reserved memory
localparam [31:0] SLAVE3_ADDR_END   = 32'hFFFF_FFFF;

// ALU opcodes (match ALU_Core)
localparam [3:0] OP_ADD         = 4'h0;
localparam [3:0] OP_SUB         = 4'h1;
localparam [3:0] OP_AND         = 4'h2;
localparam [3:0] OP_OR          = 4'h3;
localparam [3:0] OP_XOR         = 4'h4;
localparam [3:0] OP_NOT         = 4'h5;
localparam [3:0] OP_SHIFT_LEFT  = 4'h6;
localparam [3:0] OP_SHIFT_RIGHT = 4'h7;

// Test vector storage
reg [3:0]   test_opcode    [0:NUM_ALU_TESTS-1];
reg [31:0]  test_operand_a [0:NUM_ALU_TESTS-1];
reg [31:0]  test_operand_b [0:NUM_ALU_TESTS-1];
reg [31:0]  test_expected  [0:NUM_ALU_TESTS-1];
reg [8*64-1:0] test_name   [0:NUM_ALU_TESTS-1];

integer instruction_byte_ptr;
integer pass_count;
integer fail_count;
integer test_idx;

// Initialize ALU test vectors
initial begin
    instruction_byte_ptr = 0;  // Offset from ALU_MEM_BASE_ADDR
    pass_count = 0;
    fail_count = 0;

    test_name[0]    = "ADD basic";
    test_opcode[0]  = OP_ADD;
    test_operand_a[0] = 32'd15;
    test_operand_b[0] = 32'd27;
    test_expected[0]  = 32'd42;

    test_name[1]    = "SUB basic";
    test_opcode[1]  = OP_SUB;
    test_operand_a[1] = 32'd100;
    test_operand_b[1] = 32'd58;
    test_expected[1]  = 32'd42;

    test_name[2]    = "AND mask";
    test_opcode[2]  = OP_AND;
    test_operand_a[2] = 32'hFF00_FF00;
    test_operand_b[2] = 32'h0F0F_0F0F;
    test_expected[2]  = 32'h0F00_0F00;

    test_name[3]    = "OR combine";
    test_opcode[3]  = OP_OR;
    test_operand_a[3] = 32'h1234_5678;
    test_operand_b[3] = 32'h00FF_00FF;
    test_expected[3]  = 32'h12FF_56FF;

    test_name[4]    = "XOR toggle";
    test_opcode[4]  = OP_XOR;
    test_operand_a[4] = 32'hAAAA_5555;
    test_operand_b[4] = 32'hFFFF_0000;
    test_expected[4]  = 32'h5555_5555;

    test_name[5]    = "NOT invert";
    test_opcode[5]  = OP_NOT;
    test_operand_a[5] = 32'h0000_FFFF;
    test_operand_b[5] = 32'h0000_0000;  // Unused
    test_expected[5]  = 32'hFFFF_0000;

    test_name[6]    = "SHIFT_LEFT";
    test_opcode[6]  = OP_SHIFT_LEFT;
    test_operand_a[6] = 32'h0000_0001;
    test_operand_b[6] = 32'd8;
    test_expected[6]  = 32'h0000_0100;

    test_name[7]    = "SHIFT_RIGHT";
    test_opcode[7]  = OP_SHIFT_RIGHT;
    test_operand_a[7] = 32'h8000_0000;
    test_operand_b[7] = 32'd4;
    test_expected[7]  = 32'h0800_0000;

    test_name[8]    = "ADD overflow";
    test_opcode[8]  = OP_ADD;
    test_operand_a[8] = 32'hFFFF_FFFF;
    test_operand_b[8] = 32'h0000_0001;
    test_expected[8]  = 32'h0000_0000;

    test_name[9]    = "SUB borrow";
    test_opcode[9]  = OP_SUB;
    test_operand_a[9] = 32'h0000_0000;
    test_operand_b[9] = 32'h0000_0001;
    test_expected[9]  = 32'hFFFF_FFFF;
end

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
    alu_master_start = 1'b0;
    #(CLK_PERIOD * 10);
    ARESETN = 1'b1;
    $display("[%0t] Reset released", $time);
end

// DUT Instance - Complete IP Module
dual_master_system_ip #(
    .ADDR_WIDTH             (ADDR_WIDTH),
    .DATA_WIDTH             (DATA_WIDTH),
    .ID_WIDTH               (ID_WIDTH),
    .WITH_CSR               (1),
    .W                      (1),
    .PRE_REGISTER           (1),
    .RESET_STRATEGY         ("MINI"),
    .RESET_PC               (32'h0000_0000),
    .DEBUG                  (1'b0),
    .MDU                    (1'b0),
    .COMPRESSED             (0),
    .Masters_Num            (2),
    .Address_width           (32),
    .S00_Aw_len             (8),
    .S00_Write_data_bus_width(32),
    .S00_Write_data_bytes_num(4),
    .S00_AR_len             (8),
    .S00_Read_data_bus_width(32),
    .S01_Aw_len             (8),
    .S01_Write_data_bus_width(32),
    .S01_AR_len             (8),
    .M00_Aw_len             (8),
    .M00_Write_data_bus_width(32),
    .M00_Write_data_bytes_num(4),
    .M00_AR_len             (8),
    .M00_Read_data_bus_width(32),
    .M01_Aw_len             (8),
    .M01_AR_len             (8),
    .M02_Aw_len             (8),
    .M02_AR_len             (8),
    .M02_Read_data_bus_width(32),
    .M03_Aw_len             (8),
    .M03_AR_len             (8),
    .M03_Read_data_bus_width(32),
    .Is_Master_AXI_4        (1'b1),
    .M1_ID                  (0),
    .M2_ID                  (1),
    .Resp_ID_width          (2),
    .Num_Of_Masters         (2),
    .Num_Of_Slaves          (4),
    .Master_ID_Width        (1),
    .AXI4_AR_len            (8),
    .AXI4_Aw_len            (8),
    .SLAVE0_ADDR1           (32'h0000_0000),  // Instruction memory
    .SLAVE0_ADDR2           (32'h3FFF_FFFF),
    .SLAVE1_ADDR1           (32'h4000_0000),  // Data memory
    .SLAVE1_ADDR2           (32'h7FFF_FFFF),
    .SLAVE2_ADDR1           (32'h8000_0000),  // ALU memory
    .SLAVE2_ADDR2           (32'hBFFF_FFFF),
    .SLAVE3_ADDR1           (32'hC000_0000),  // Reserved memory
    .SLAVE3_ADDR2           (32'hFFFF_FFFF),
    .INST_MEM_SIZE          (1024),
    .DATA_MEM_SIZE          (1024),
    .ALU_MEM_SIZE           (1024),
    .RESERVED_MEM_SIZE      (1024),
    .INST_MEM_INIT_FILE     ("../../test_program_simple.hex"),
    .DATA_MEM_INIT_FILE      (""),
    .ALU_MEM_INIT_FILE       (""),
    .RESERVED_MEM_INIT_FILE  ("")
) u_dut (
    .ACLK                   (ACLK),
    .ARESETN                (ARESETN),
    .i_timer_irq            (i_timer_irq),
    .alu_master_start       (alu_master_start),
    .alu_master_busy        (alu_master_busy),
    .alu_master_done        (alu_master_done),
    .inst_mem_ready         (inst_mem_ready),
    .data_mem_ready         (data_mem_ready),
    .alu_mem_ready          (alu_mem_ready),
    .reserved_mem_ready     (reserved_mem_ready)
);

// Monitoring
initial begin
    $dumpfile("dual_master_system_ip_tb_ALU.vcd");
    $dumpvars(0, dual_master_system_ip_tb_ALU);
    
    $display("============================================================================");
    $display("Dual Master System IP Testbench");
    $display("============================================================================");
    $display("Complete IP Module with Integrated Memory Slaves");
    $display("  - SERV RISC-V Core (Instruction + Data buses)");
    $display("  - ALU Master");
    $display("  - Instruction Memory (ROM): Integrated");
    $display("  - Data Memory (RAM): Integrated");
    $display("  - ALU Memory (RAM): Integrated");
    $display("  - Reserved Memory (ROM): Integrated");
    $display("  - No external slave connections needed!");
    $display("============================================================================");
    $display("");
end

// -----------------------------------------------------------------------------
// Helper functions and tasks
// -----------------------------------------------------------------------------
function [31:0] build_instruction_word;
    input [3:0] opcode;
    input [7:0] src1_addr;
    input [7:0] src2_addr;
    input [7:0] dst_addr;
    begin
        build_instruction_word = {opcode, 4'h0, src1_addr, src2_addr, dst_addr};
    end
endfunction

function [7:0] calc_data_addr;
    input integer test_idx;
    input integer slot; // 0: operand A, 1: operand B, 2: destination
    integer byte_addr;
    begin
        byte_addr = ALU_DATA_BASE_ADDR + (test_idx * ALU_DATA_STRIDE_BYTES) + (slot * 4);
        calc_data_addr = byte_addr[7:0];
    end
endfunction

function integer addr_slave_idx;
    input [31:0] byte_addr;
    begin
        if (byte_addr >= SLAVE0_ADDR_START && byte_addr <= SLAVE0_ADDR_END) begin
            addr_slave_idx = 0;
        end else if (byte_addr >= SLAVE1_ADDR_START && byte_addr <= SLAVE1_ADDR_END) begin
            addr_slave_idx = 1;
        end else if (byte_addr >= SLAVE2_ADDR_START && byte_addr <= SLAVE2_ADDR_END) begin
            addr_slave_idx = 2;
        end else if (byte_addr >= SLAVE3_ADDR_START && byte_addr <= SLAVE3_ADDR_END) begin
            addr_slave_idx = 3;
        end else begin
            addr_slave_idx = -1;
        end
    end
endfunction

task automatic write_alu_memory_word;
    input [31:0] byte_addr;
    input [31:0] data;
    integer word_idx;
    integer slave_idx;
    begin
        // Debug: show input address
        $display("[%0t]   WRITE_TASK: byte_addr=0x%08h data=0x%08h", $time, byte_addr, data);
        slave_idx = addr_slave_idx(byte_addr);
        
        // Write to correct slave based on address
        if (slave_idx == 0) begin
            // Slave0: Instruction RAM (base 0x00000000)
            word_idx = byte_addr >> 2;
            u_dut.u_inst_mem.memory[word_idx] = data;
            $display("[%0t]   ALU MEM[0x%08h] <= 0x%08h (word %0d)", $time, byte_addr, data, word_idx);
        end else if (slave_idx == 1) begin
            // Slave1: Data RAM (base 0x40000000)
            word_idx = (byte_addr - SLAVE1_ADDR_START) >> 2;
            u_dut.u_data_mem.memory[word_idx] = data;
            $display("[%0t]   ALU MEM[0x%08h] <= 0x%08h (word %0d)", $time, byte_addr, data, word_idx);
        end else if (slave_idx == 2) begin
            // Slave2: ALU RAM (base 0x80000000)
            word_idx = (byte_addr - SLAVE2_ADDR_START) >> 2;
            u_dut.u_alu_mem.memory[word_idx] = data;
            $display("[%0t]   ALU MEM[0x%08h] <= 0x%08h (word %0d)", $time, byte_addr, data, word_idx);
        end else if (slave_idx == 3) begin
            // Slave3: Reserved RAM (base 0xC0000000)
            word_idx = (byte_addr - SLAVE3_ADDR_START) >> 2;
            u_dut.u_reserved_mem.memory[word_idx] = data;
            $display("[%0t]   ALU MEM[0x%08h] <= 0x%08h (word %0d)", $time, byte_addr, data, word_idx);
        end else begin
            $display("[%0t]   WARNING: Memory write out of range @0x%08h", $time, byte_addr);
        end
    end
endtask

task automatic read_alu_memory_word;
    input [31:0] byte_addr;
    output [31:0] data;
    integer word_idx;
    integer slave_idx;
    begin
        slave_idx = addr_slave_idx(byte_addr);
        
        // Read from correct slave based on address
        if (slave_idx == 0) begin
            // Slave0: Instruction RAM (base 0x00000000)
            word_idx = byte_addr >> 2;
            data = u_dut.u_inst_mem.memory[word_idx];
        end else if (slave_idx == 1) begin
            // Slave1: Data RAM (base 0x40000000)
            word_idx = (byte_addr - SLAVE1_ADDR_START) >> 2;
            data = u_dut.u_data_mem.memory[word_idx];
        end else if (slave_idx == 2) begin
            // Slave2: ALU RAM (base 0x80000000)
            word_idx = (byte_addr - SLAVE2_ADDR_START) >> 2;
            data = u_dut.u_alu_mem.memory[word_idx];
        end else if (slave_idx == 3) begin
            // Slave3: Reserved RAM (base 0xC0000000)
            word_idx = (byte_addr - SLAVE3_ADDR_START) >> 2;
            data = u_dut.u_reserved_mem.memory[word_idx];
        end else begin
            data = 32'hDEAD_BEEF;
            $display("[%0t]   WARNING: Memory read out of range @0x%08h", $time, byte_addr);
        end
    end
endtask

task automatic wait_alu_master_reset;
    begin
        @(posedge ACLK);
        while (alu_master_busy) @(posedge ACLK);
        while (alu_master_done) @(posedge ACLK);
    end
endtask

task automatic run_alu_test;
    input integer test_id;
    reg [7:0] src1_addr;
    reg [7:0] src2_addr;
    reg [7:0] dst_addr;
    reg [31:0] instruction_word;
    reg [31:0] actual_result;
    reg [31:0] src1_byte_addr;
    reg [31:0] src2_byte_addr;
    reg [31:0] dst_byte_addr;
    integer    src1_slave_idx;
    integer    src2_slave_idx;
    integer    dst_slave_idx;
    begin
        src1_addr = calc_data_addr(test_id, 0);
        src2_addr = calc_data_addr(test_id, 1);
        dst_addr  = calc_data_addr(test_id, 2);
        src1_byte_addr = ALU_MEM_BASE_ADDR | {24'h0, src1_addr};
        src2_byte_addr = ALU_MEM_BASE_ADDR | {24'h0, src2_addr};
        dst_byte_addr  = ALU_MEM_BASE_ADDR | {24'h0, dst_addr};
        src1_slave_idx = addr_slave_idx(src1_byte_addr);
        src2_slave_idx = addr_slave_idx(src2_byte_addr);
        dst_slave_idx  = addr_slave_idx(dst_byte_addr);
        instruction_word = build_instruction_word(test_opcode[test_id], src1_addr, src2_addr, dst_addr);
        
        $display("[%0t] ------------------------------------------------------------", $time);
        $display("[%0t] ALU Test %0d: %0s", $time, test_id, test_name[test_id]);
        $display("[%0t]   opcode=%04b | src1_addr=0x%08h [Slave%0d] | src2_addr=0x%08h [Slave%0d] | dst_addr=0x%08h [Slave%0d] | PC=0x%08h",
                 $time,
                 test_opcode[test_id],
                 src1_byte_addr, src1_slave_idx,
                 src2_byte_addr, src2_slave_idx,
                 dst_byte_addr,  dst_slave_idx,
                 ALU_MEM_BASE_ADDR + instruction_byte_ptr);
        $display("[%0t]   Operands/Expect (DEC): A=%0d | B=%0d | Expected=%0d",
                 $time, test_operand_a[test_id], test_operand_b[test_id], test_expected[test_id]);
        
        // Program instruction memory (sequential address space)
        // NOTE: Hard-coded base address to work around ModelSim localparam caching issue
        write_alu_memory_word(32'h80000000 + instruction_byte_ptr, instruction_word);
        instruction_byte_ptr = instruction_byte_ptr + 4;
        
        // Prepare operands/result slots
        write_alu_memory_word(src1_byte_addr, test_operand_a[test_id]);
        if (test_opcode[test_id] != OP_NOT) begin
            write_alu_memory_word(src2_byte_addr, test_operand_b[test_id]);
        end else begin
            $display("[%0t]   NOTE: NOT operation - operand B ignored", $time);
        end
        write_alu_memory_word(dst_byte_addr, 32'h0);
        
        // Kick off ALU master
        wait(!alu_master_busy);
        alu_master_start = 1'b1;
        @(posedge ACLK);
        alu_master_start = 1'b0;
        
        while (!alu_master_busy) @(posedge ACLK);
        $display("[%0t]   ALU Master busy...", $time);
        
        while (!alu_master_done) @(posedge ACLK);
        $display("[%0t]   ALU Master done", $time);
        
        // Allow write path to settle (need more cycles for AXI write completion + RAM update)
        repeat (8) @(posedge ACLK);
        read_alu_memory_word(dst_byte_addr, actual_result);
        
        if (actual_result === test_expected[test_id]) begin
            pass_count = pass_count + 1;
            $display("[%0t]   PASS: expected=%0d actual=%0d", $time, test_expected[test_id], actual_result);
        end else begin
            fail_count = fail_count + 1;
            $display("[%0t]   FAIL: expected=%0d actual=%0d", $time, test_expected[test_id], actual_result);
        end
        
        $display("[%0t]   Flags: zero=%0b carry=%0b",
                 $time,
                 u_dut.u_alu_master.u_alu.zero_flag,
                 u_dut.u_alu_master.u_alu.carry_flag);
        $display("");
        
        wait_alu_master_reset();
    end
endtask

task automatic display_memory_map;
    begin
        $display("AXI Slave Address Map:");
        $display("  Slave0 (Instruction ROM) : 0x%08h - 0x%08h", SLAVE0_ADDR_START, SLAVE0_ADDR_END);
        $display("  Slave1 (Data RAM)        : 0x%08h - 0x%08h", SLAVE1_ADDR_START, SLAVE1_ADDR_END);
        $display("  Slave2 (ALU RAM)         : 0x%08h - 0x%08h", SLAVE2_ADDR_START, SLAVE2_ADDR_END);
        $display("  Slave3 (Reserved ROM)    : 0x%08h - 0x%08h", SLAVE3_ADDR_START, SLAVE3_ADDR_END);
        $display("  ALU operand region base  : 0x%08h (data slots start)", ALU_MEM_BASE_ADDR | {24'h0, ALU_DATA_BASE_ADDR});
        $display("");
    end
endtask

// Test stimulus
initial begin
    // Wait for reset
    wait(ARESETN);
    #(CLK_PERIOD * 10);
    
    $display("[%0t] System ready", $time);
    $display("[%0t] Instruction Memory Ready: %b", $time, inst_mem_ready);
    $display("[%0t] Data Memory Ready: %b", $time, data_mem_ready);
    $display("[%0t] ALU Memory Ready: %b", $time, alu_mem_ready);
    $display("[%0t] Reserved Memory Ready: %b", $time, reserved_mem_ready);
    $display("");
    display_memory_map();
    
    $display("[%0t] SERV RISC-V will start fetching instructions", $time);
    $display("[%0t] ALU Master Status: busy=%b, done=%b", $time, alu_master_busy, alu_master_done);
    $display("");
    
    wait_alu_master_reset();
    instruction_byte_ptr = 0;  // offset within ALU slave address space
    pass_count = 0;
    fail_count = 0;
    
    for (test_idx = 0; test_idx < NUM_ALU_TESTS; test_idx = test_idx + 1) begin
        run_alu_test(test_idx);
    end
    
    $display("============================================================================");
    $display("[%0t] ALU Test Summary: PASS=%0d | FAIL=%0d", $time, pass_count, fail_count);
    if (fail_count == 0) begin
        $display("[%0t] All ALU test cases PASSED", $time);
    end else begin
        $display("[%0t] Some ALU test cases FAILED - please investigate", $time);
    end
    $display("============================================================================");
    $finish;
end

// Monitor AXI transactions (optional - for debugging)
// This can be expanded to monitor specific transactions if needed

endmodule

