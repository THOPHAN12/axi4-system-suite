`timescale 1ns/1ps

//============================================================================
// ALU Core - Simple Arithmetic Logic Unit
// Supports: ADD, SUB, AND, OR, XOR, NOT, SHIFT_LEFT, SHIFT_RIGHT
//============================================================================
module ALU_Core #(
    parameter DATA_WIDTH = 32
) (
    input  wire [3:0]                    opcode,      // Operation code
    input  wire [DATA_WIDTH-1:0]         operand_a,   // First operand
    input  wire [DATA_WIDTH-1:0]         operand_b,   // Second operand
    output reg  [DATA_WIDTH-1:0]         result,      // ALU result
    output reg                           zero_flag,   // Zero flag
    output reg                           carry_flag   // Carry flag (for ADD/SUB)
);

    // Opcode definitions
    localparam OP_ADD        = 4'b0000;
    localparam OP_SUB        = 4'b0001;
    localparam OP_AND        = 4'b0010;
    localparam OP_OR         = 4'b0011;
    localparam OP_XOR        = 4'b0100;
    localparam OP_NOT        = 4'b0101;
    localparam OP_SHIFT_LEFT = 4'b0110;
    localparam OP_SHIFT_RIGHT= 4'b0111;
    
    always @(*) begin
        carry_flag = 1'b0;
        zero_flag = 1'b0;
        
        case (opcode)
            OP_ADD: begin
                {carry_flag, result} = operand_a + operand_b;
            end
            
            OP_SUB: begin
                {carry_flag, result} = operand_a - operand_b;
                carry_flag = (operand_a < operand_b) ? 1'b1 : 1'b0;  // Borrow flag
            end
            
            OP_AND: begin
                result = operand_a & operand_b;
            end
            
            OP_OR: begin
                result = operand_a | operand_b;
            end
            
            OP_XOR: begin
                result = operand_a ^ operand_b;
            end
            
            OP_NOT: begin
                result = ~operand_a;
            end
            
            OP_SHIFT_LEFT: begin
                result = operand_a << operand_b[4:0];  // Shift by lower 5 bits
            end
            
            OP_SHIFT_RIGHT: begin
                result = operand_a >> operand_b[4:0];  // Shift by lower 5 bits
            end
            
            default: begin
                result = 32'h0;
            end
        endcase
        
        // Zero flag
        zero_flag = (result == 32'h0) ? 1'b1 : 1'b0;
    end

endmodule

