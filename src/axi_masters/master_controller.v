//==============================================================================
// Master Controller
//==============================================================================
// High-level controller for managing multiple AXI master modules
// Provides abstraction layer for testbench to control masters easily
//
// Features:
//   - Start/stop control for multiple masters
//   - Busy flag monitoring
//   - Sequential and parallel operation support
//   - Contention detection and handling
//==============================================================================

`timescale 1ns/1ps

module master_controller #(
    parameter NUM_MASTERS = 2
)(
    input wire ACLK,
    input wire ARESETN,
    
    // Master 0 Control Interface
    output reg m0_start,
    input wire m0_busy,
    input wire m0_completed,
    
    // Master 1 Control Interface
    output reg m1_start,
    input wire m1_busy,
    input wire m1_completed,
    
    // Status outputs
    output wire all_idle,
    output wire any_busy,
    output wire all_completed,
    
    // Internal state (for debugging)
    output reg [1:0] controller_state
);

    //==============================================================================
    // Internal Signals
    //==============================================================================
    reg m0_start_reg;
    reg m1_start_reg;
    
    // State encoding
    localparam IDLE = 2'b00;
    localparam M0_RUNNING = 2'b01;
    localparam M1_RUNNING = 2'b10;
    localparam BOTH_RUNNING = 2'b11;
    
    reg [1:0] state;
    
    //==============================================================================
    // Control Logic
    //==============================================================================
    always @(*) begin
        m0_start = m0_start_reg;
        m1_start = m1_start_reg;
    end
    
    // Status outputs
    assign all_idle = !m0_busy && !m1_busy;
    assign any_busy = m0_busy || m1_busy;
    assign all_completed = m0_completed && m1_completed;
    
    always @(*) begin
        controller_state = state;
    end
    
    // State machine
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
            m0_start_reg <= 1'b0;
            m1_start_reg <= 1'b0;
        end else begin
            // Auto-clear start signals after one cycle
            m0_start_reg <= 1'b0;
            m1_start_reg <= 1'b0;
            
            // State transitions
            case (state)
                IDLE: begin
                    if (m0_busy && m1_busy) begin
                        state <= BOTH_RUNNING;
                    end else if (m0_busy) begin
                        state <= M0_RUNNING;
                    end else if (m1_busy) begin
                        state <= M1_RUNNING;
                    end
                end
                
                M0_RUNNING: begin
                    if (m1_busy) begin
                        state <= BOTH_RUNNING;
                    end else if (!m0_busy) begin
                        state <= IDLE;
                    end
                end
                
                M1_RUNNING: begin
                    if (m0_busy) begin
                        state <= BOTH_RUNNING;
                    end else if (!m1_busy) begin
                        state <= IDLE;
                    end
                end
                
                BOTH_RUNNING: begin
                    if (!m0_busy && !m1_busy) begin
                        state <= IDLE;
                    end else if (!m0_busy) begin
                        state <= M1_RUNNING;
                    end else if (!m1_busy) begin
                        state <= M0_RUNNING;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule


