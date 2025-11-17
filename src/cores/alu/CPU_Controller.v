`timescale 1ns/1ps

//============================================================================
// CPU Controller - Controls instruction fetch, decode, and execute
// State machine for CPU operation
//============================================================================
module CPU_Controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter [ADDR_WIDTH-1:0] MEM_BASE_ADDR = 32'h80000000  // Base address for data memory (Slave2 for ALU)
) (
    input  wire                          ACLK,
    input  wire                          ARESETN,
    
    // Control signals
    input  wire                          start,           // Start CPU execution
    output reg                           busy,            // CPU is busy
    output reg                           done,            // Instruction execution done
    
    // ALU interface
    output reg  [3:0]                    alu_opcode,
    output reg  [DATA_WIDTH-1:0]         alu_operand_a,
    output reg  [DATA_WIDTH-1:0]         alu_operand_b,
    input  wire [DATA_WIDTH-1:0]         alu_result,
    input  wire                          alu_zero_flag,
    input  wire                          alu_carry_flag,
    
    // AXI Master interface control
    // Read operation
    output reg                           read_req,        // Request read from memory
    output reg  [ADDR_WIDTH-1:0]         read_addr,       // Read address
    input  wire                          read_ready,      // Read address accepted
    input  wire                          read_valid,      // Read data valid
    input  wire [DATA_WIDTH-1:0]         read_data,       // Read data
    input  wire                          read_done,       // Read transaction done
    
    // Write operation
    output reg                           write_req,       // Request write to memory
    output reg  [ADDR_WIDTH-1:0]         write_addr,      // Write address
    output reg  [DATA_WIDTH-1:0]         write_data,      // Write data
    input  wire                          write_ready,     // Write address accepted
    input  wire                          write_data_ready,// Write data accepted
    input  wire                          write_done       // Write transaction done
);

    // State machine states
    localparam IDLE          = 3'b000;
    localparam FETCH_INSTR   = 3'b001;
    localparam DECODE        = 3'b010;
    localparam FETCH_OP1     = 3'b011;
    localparam FETCH_OP2     = 3'b100;
    localparam EXECUTE       = 3'b101;
    localparam STORE_RESULT  = 3'b110;
    localparam LATCH_RESULT  = 3'b111;
    
    reg [2:0] current_state;
    reg [2:0] next_state;
    
    // Instruction register
    reg [DATA_WIDTH-1:0] instruction;
    reg [3:0]            opcode;
    reg [7:0]            src_addr1;
    reg [7:0]            src_addr2;
    reg [7:0]            dst_addr;
    
    // Operand registers
    reg [DATA_WIDTH-1:0] operand1;
    reg [DATA_WIDTH-1:0] operand2;
    reg [DATA_WIDTH-1:0] store_result;
    reg [7:0]            store_dst_addr;
    
    // Instruction address (PC - Program Counter)
    reg [ADDR_WIDTH-1:0] pc;
    
    // ========================================================================
    // State Machine
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            current_state <= IDLE;
            pc <= 32'h0;
            operand1 <= 32'h0;
            operand2 <= 32'h0;
            store_result <= 32'h0;
            opcode <= 4'h0;
            src_addr1 <= 8'h0;
            src_addr2 <= 8'h0;
            dst_addr <= 8'h0;
            store_dst_addr <= 8'h0;
        end else begin
            current_state <= next_state;
            
            // Update operands and result in sequential logic
            if (current_state == FETCH_OP1 && read_done) begin
                operand1 <= read_data;
            end
            if (current_state == FETCH_OP2 && read_done) begin
                operand2 <= read_data;
            end
            if (current_state == DECODE) begin
                opcode <= instruction[31:28];
                src_addr1 <= instruction[23:16];
                src_addr2 <= instruction[15:8];
                dst_addr <= instruction[7:0];
                store_dst_addr <= instruction[7:0];  // Latch destination immediately after decode
            end
            if (current_state == EXECUTE) begin
                store_result <= alu_result;
                // Debug: capture execute info
                $display("[%0t] CTRL EXECUTE: opcode=%0h src1=0x%02h src2=0x%02h dst=0x%02h -> store_dst=0x%02h result=0x%08h",
                         $time, opcode, src_addr1, src_addr2, dst_addr, store_dst_addr, alu_result);
            end
            if (current_state == STORE_RESULT && write_done) begin
                pc <= pc + 4;  // Increment PC (next instruction)
            end
        end
    end
    
    always @(*) begin
        next_state = current_state;
        busy = 1'b1;
        done = 1'b0;
        read_req = 1'b0;
        write_req = 1'b0;
        alu_opcode = opcode;
        alu_operand_a = operand1;
        alu_operand_b = operand2;
        
        // Default values to prevent inferred latches
        read_addr = 32'h0;
        write_addr = 32'h0;
        write_data = 32'h0;
        
        case (current_state)
            IDLE: begin
                busy = 1'b0;
                if (start) begin
                    next_state = FETCH_INSTR;
                end
            end
            
            FETCH_INSTR: begin
                read_req = 1'b1;
                read_addr = MEM_BASE_ADDR | pc;  // Add base address offset
                if (read_done) begin
                    next_state = DECODE;
                end
            end
            
            DECODE: begin
                // Decode instruction - values are stored in sequential logic
                if (opcode == 4'b0101) begin  // NOT operation - only needs one operand
                    next_state = FETCH_OP1;
                end else begin
                    next_state = FETCH_OP1;
                end
            end
            
            FETCH_OP1: begin
                read_req = 1'b1;
                read_addr = MEM_BASE_ADDR | {24'h0, src_addr1};  // Add base address offset
                if (read_done) begin
                    if (opcode == 4'b0101) begin  // NOT - skip operand 2
                        next_state = EXECUTE;
                    end else begin
                        next_state = FETCH_OP2;
                    end
                end
            end
            
            FETCH_OP2: begin
                read_req = 1'b1;
                read_addr = MEM_BASE_ADDR | {24'h0, src_addr2};  // Add base address offset
                if (read_done) begin
                    next_state = EXECUTE;
                end
            end
            
            EXECUTE: begin
                // ALU signals are already assigned above
                next_state = LATCH_RESULT;
            end
            
            LATCH_RESULT: begin
                // Give store_result a full cycle to latch before issuing write
                next_state = STORE_RESULT;
            end
            
            STORE_RESULT: begin
                write_req = 1'b1;
                write_addr = MEM_BASE_ADDR | {24'h0, store_dst_addr};  // Add base address offset
                write_data = store_result;
                if (write_done) begin
                    // Debug: write completion info
                    $display("[%0t] CTRL STORE_RESULT: wrote addr=0x%08h data=0x%08h (done)",
                             $time, write_addr, write_data);
                    next_state = IDLE;
                    done = 1'b1;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // ========================================================================
    // Instruction register update
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            instruction <= 32'h0;
        end else if (current_state == FETCH_INSTR && read_done) begin
            instruction <= read_data;
            $display("[%0t] CTRL FETCH_INSTR: fetched 0x%08h from PC=0x%08h", $time, read_data, pc);
        end
    end
    
    // Debug: state transitions
    always @(posedge ACLK) begin
        if (ARESETN && current_state != next_state) begin
            $display("[%0t] CTRL STATE: %0d -> %0d", $time, current_state, next_state);
        end
    end
    
endmodule

