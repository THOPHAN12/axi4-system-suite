// ==============================================================================
// AXI Master 0 - Compute Master
// ==============================================================================
// This master reads instruction from memory, computes result, and writes back
// Features:
//   - Read instruction from S0[1]
//   - Compute based on opcode (ADD, SUB, MUL)
//   - Write result to S0[0]
//   - Output busy signal when not in IDLE
// ==============================================================================

`timescale 1ns/1ps

module axi_master_0 #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SLAVE0_BASE = 32'h00000000
)(
    input logic ACLK,
    input logic ARESETN,
    
    // Control signals
    input logic start,
    output logic completed,
    output logic busy,
    
    // AXI4-Lite Master Interface
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0] M_AXI_araddr,
    output logic [2:0]            M_AXI_arprot,
    output logic M_AXI_arvalid,
    input logic                  M_AXI_arready,
    
    // Read Data Channel
    input logic [DATA_WIDTH-1:0] M_AXI_rdata,
    input logic [1:0]            M_AXI_rresp,
    input logic                  M_AXI_rvalid,
    output logic M_AXI_rready,
    
    // Write Address Channel
    output logic [ADDR_WIDTH-1:0] M_AXI_awaddr,
    output logic [2:0]            M_AXI_awprot,
    output logic M_AXI_awvalid,
    input logic                  M_AXI_awready,
    
    // Write Data Channel
    output logic [DATA_WIDTH-1:0] M_AXI_wdata,
    output logic [DATA_WIDTH/8-1:0] M_AXI_wstrb,
    output logic M_AXI_wvalid,
    input logic                  M_AXI_wready,
    
    // Write Response Channel
    input logic [1:0]            M_AXI_bresp,
    input logic                  M_AXI_bvalid,
    output logic M_AXI_bready,
    
    // Internal signals
    output logic [31:0] instruction,
    output logic [31:0] result
);

    // State machine
    logic [2:0] state;
    localparam IDLE        = 3'b000;
    localparam READ_REQ    = 3'b001;
    localparam READ_WAIT   = 3'b010;
    localparam COMPUTE     = 3'b011;
    localparam WRITE_REQ   = 3'b100;
    localparam WRITE_WAIT  = 3'b101;
    localparam DONE        = 3'b110;
    
    // Flags to track AW and W handshake completion
    logic aw_handshake_done;
    logic w_handshake_done;
    
    // Computation variables
    logic [7:0]  opcode;
    logic [11:0] op1, op2;
    assign opcode = instruction[31:24];
    assign op1 = instruction[23:12];
    assign op2 = instruction[11:0];
    
    // Busy signal: high when not in IDLE state
    assign busy = (state != IDLE);
    
    // State machine
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
            M_AXI_araddr <= 32'h0;
            M_AXI_arprot <= 3'b000;
            M_AXI_arvalid <= 1'b0;
            M_AXI_rready <= 1'b0;
            M_AXI_awaddr <= 32'h0;
            M_AXI_awprot <= 3'b000;
            M_AXI_awvalid <= 1'b0;
            M_AXI_wdata <= 32'h0;
            M_AXI_wstrb <= 4'b0000;
            M_AXI_wvalid <= 1'b0;
            M_AXI_bready <= 1'b0;
            instruction <= 32'h0;
            result <= 32'h0;
            completed <= 1'b0;
            aw_handshake_done <= 1'b0;
            w_handshake_done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_rready <= 1'b0;
                    M_AXI_awvalid <= 1'b0;
                    M_AXI_wvalid <= 1'b0;
                    M_AXI_bready <= 1'b0;
                    completed <= 1'b0;
                    aw_handshake_done <= 1'b0;
                    w_handshake_done <= 1'b0;
                    if (start) begin
                        state <= READ_REQ;
                    end
                end
                
                READ_REQ: begin
                    M_AXI_araddr <= SLAVE0_BASE + 32'h00000004;  // Read instruction from S0[1]
                    M_AXI_arprot <= 3'b000;
                    M_AXI_arvalid <= 1'b1;
                    if (M_AXI_arready) begin
                        state <= READ_WAIT;
                        M_AXI_arvalid <= 1'b0;
                    end
                end
                
                READ_WAIT: begin
                    M_AXI_rready <= 1'b1;
                    if (M_AXI_rvalid && M_AXI_rready) begin
                        instruction <= M_AXI_rdata;
                        state <= COMPUTE;
                        M_AXI_rready <= 1'b0;
                    end
                end
                
                COMPUTE: begin
                    case (opcode)
                        8'h01: begin  // ADD
                            result <= {16'h0, op1} + {16'h0, op2};
                        end
                        8'h02: begin  // SUB
                            result <= {16'h0, op1} - {16'h0, op2};
                        end
                        8'h03: begin  // MUL
                            result <= op1 * op2;
                        end
                        default: begin
                            result <= 32'hDEADBEEF;
                        end
                    endcase
                    state <= WRITE_REQ;
                end
                
                WRITE_REQ: begin
                    // Set address and data on first cycle, keep valid high until handshake
                    if (!aw_handshake_done) begin
                        M_AXI_awaddr <= SLAVE0_BASE + 32'h00000000;  // Write result to S0[0]
                        M_AXI_awprot <= 3'b000;
                        M_AXI_awvalid <= 1'b1;
                    end else begin
                        M_AXI_awvalid <= 1'b0;
                    end
                    
                    if (!w_handshake_done) begin
                        M_AXI_wdata <= result;
                        M_AXI_wstrb <= 4'b1111;
                        M_AXI_wvalid <= 1'b1;
                    end else begin
                        M_AXI_wvalid <= 1'b0;
                    end
                    
                    // Track AW handshake completion
                    if (M_AXI_awvalid && M_AXI_awready && !aw_handshake_done) begin
                        aw_handshake_done <= 1'b1;
                    end
                    
                    // Track W handshake completion
                    if (M_AXI_wvalid && M_AXI_wready && !w_handshake_done) begin
                        w_handshake_done <= 1'b1;
                    end
                    
                    // Move to next state when both handshakes are complete
                    if (aw_handshake_done && w_handshake_done) begin
                        state <= WRITE_WAIT;
                    end
                end
                
                WRITE_WAIT: begin
                    M_AXI_bready <= 1'b1;
                    if (M_AXI_bvalid && M_AXI_bready) begin
                        state <= DONE;
                        M_AXI_bready <= 1'b0;
                    end
                end
                
                DONE: begin
                    state <= IDLE;
                    completed <= 1'b1;
                end
            endcase
        end
    end

endmodule


