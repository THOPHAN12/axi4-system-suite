`timescale 1ns/1ps

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
//   - High-level tasks for common test scenarios
//==============================================================================

module master_controller #(
    parameter NUM_MASTERS = 2
)(
    input logic ACLK,
    input logic ARESETN,
    
    // Master 0 Control Interface
    output logic m0_start,
    input logic m0_busy,
    input logic m0_completed,
    
    // Master 1 Control Interface
    output logic m1_start,
    input logic m1_busy,
    input logic m1_completed,
    
    // Status outputs
    output logic all_idle,
    output logic any_busy,
    output logic all_completed,
    
    // Internal state (for debugging)
    output logic [1:0] controller_state
);

    //==============================================================================
    // Internal Signals
    //==============================================================================
    logic m0_start_reg;
    logic m1_start_reg;
    
    // State machine
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        M0_RUNNING = 2'b01,
        M1_RUNNING = 2'b10,
        BOTH_RUNNING = 2'b11
    } state_t;
    
    state_t state;
    
    //==============================================================================
    // Control Logic
    //==============================================================================
    assign m0_start = m0_start_reg;
    assign m1_start = m1_start_reg;
    
    // Status outputs
    assign all_idle = !m0_busy && !m1_busy;
    assign any_busy = m0_busy || m1_busy;
    assign all_completed = m0_completed && m1_completed;
    assign controller_state = state;
    
    // State machine
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
            m0_start_reg <= 1'b0;
            m1_start_reg <= 1'b0;
        end else begin
            // Auto-clear start signals after one cycle
            if (m0_start_reg) m0_start_reg <= 1'b0;
            if (m1_start_reg) m1_start_reg <= 1'b0;
            
            // State transitions based on busy flags
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
    
    //==============================================================================
    // Public Tasks (can be called from testbench)
    //==============================================================================
    // Note: In SystemVerilog, tasks in modules can be called from testbench
    // These tasks provide high-level control interface
    
    // Task: Start Master 0 (called from testbench)
    task start_m0_task();
        @(posedge ACLK);
        m0_start_reg <= 1'b1;
    endtask
    
    // Task: Start Master 1 (called from testbench)
    task start_m1_task();
        @(posedge ACLK);
        m1_start_reg <= 1'b1;
    endtask
    
    // Task: Start both masters (called from testbench)
    task start_both_task();
        @(posedge ACLK);
        m0_start_reg <= 1'b1;
        m1_start_reg <= 1'b1;
    endtask
    
    //==============================================================================
    // High-Level Control Tasks
    //==============================================================================
    // Note: Tasks are called from testbench, not from within this module
    // These are provided as reference for testbench implementation
    
    /*
    // Task: Start Master 0
    task start_m0();
        @(posedge ACLK);
        m0_start_reg <= 1'b1;
        @(posedge ACLK);
        m0_start_reg <= 1'b0;
    endtask
    
    // Task: Start Master 1
    task start_m1();
        @(posedge ACLK);
        m1_start_reg <= 1'b1;
        @(posedge ACLK);
        m1_start_reg <= 1'b0;
    endtask
    
    // Task: Start both masters simultaneously
    task start_both();
        @(posedge ACLK);
        m0_start_reg <= 1'b1;
        m1_start_reg <= 1'b1;
        @(posedge ACLK);
        m0_start_reg <= 1'b0;
        m1_start_reg <= 1'b0;
    endtask
    
    // Task: Wait for Master 0 to complete
    task wait_m0_complete();
        wait(m0_completed);
        @(posedge ACLK);
    endtask
    
    // Task: Wait for Master 1 to complete
    task wait_m1_complete();
        wait(m1_completed);
        @(posedge ACLK);
    endtask
    
    // Task: Wait for all masters to be idle
    task wait_all_idle();
        wait(all_idle);
        @(posedge ACLK);
    endtask
    */

endmodule

//==============================================================================
// Master Controller BFM (Bus Functional Model)
//==============================================================================
// This class provides high-level tasks for testbench to control masters
// Usage in testbench:
//   master_controller_bfm bfm = new();
//   bfm.start_m0();
//   bfm.wait_m0_complete();
//==============================================================================

class master_controller_bfm;
    
    // Virtual interface to master controller
    virtual interface master_controller_if m_controller;
    
    // Constructor
    function new(virtual interface master_controller_if controller);
        this.m_controller = controller;
    endfunction
    
    // Task: Start Master 0
    task start_m0();
        @(posedge m_controller.ACLK);
        m_controller.m0_start = 1'b1;
        @(posedge m_controller.ACLK);
        m_controller.m0_start = 1'b0;
    endtask
    
    // Task: Start Master 1
    task start_m1();
        @(posedge m_controller.ACLK);
        m_controller.m1_start = 1'b1;
        @(posedge m_controller.ACLK);
        m_controller.m1_start = 1'b0;
    endtask
    
    // Task: Start both masters simultaneously
    task start_both();
        @(posedge m_controller.ACLK);
        m_controller.m0_start = 1'b1;
        m_controller.m1_start = 1'b1;
        @(posedge m_controller.ACLK);
        m_controller.m0_start = 1'b0;
        m_controller.m1_start = 1'b0;
    endtask
    
    // Task: Start Master 0 and wait for completion
    task start_m0_and_wait();
        start_m0();
        wait_m0_complete();
    endtask
    
    // Task: Start Master 1 and wait for completion
    task start_m1_and_wait();
        start_m1();
        wait_m1_complete();
    endtask
    
    // Task: Sequential operation - M0 then M1
    task sequential_m0_then_m1();
        start_m0();
        wait_m0_complete();
        start_m1();
        wait_m1_complete();
    endtask
    
    // Task: Parallel operation - both start simultaneously
    task parallel_both();
        start_both();
        wait_all_idle();
    endtask
    
    // Task: Contention test - M0 starts, M1 starts during M0 operation
    task contention_test();
        start_m0();
        wait(m_controller.m0_busy);
        #10; // Small delay
        start_m1();
        wait_all_idle();
    endtask
    
    // Task: Wait for Master 0 to complete
    task wait_m0_complete();
        wait(m_controller.m0_completed);
        @(posedge m_controller.ACLK);
    endtask
    
    // Task: Wait for Master 1 to complete
    task wait_m1_complete();
        wait(m_controller.m1_completed);
        @(posedge m_controller.ACLK);
    endtask
    
    // Task: Wait for all masters to be idle
    task wait_all_idle();
        wait(m_controller.all_idle);
        @(posedge m_controller.ACLK);
    endtask
    
    // Task: Wait for any master to be busy
    task wait_any_busy();
        wait(m_controller.any_busy);
    endtask
    
    // Task: Monitor busy flags and print status
    task monitor_busy_flags(int duration_ns);
        int start_time = $time;
        while (($time - start_time) < duration_ns) begin
            @(posedge m_controller.ACLK);
            if (m_controller.m0_busy || m_controller.m1_busy) begin
                $display("[%0t] BUSY STATUS: M0_busy=%b, M1_busy=%b, State=%0d", 
                         $time, m_controller.m0_busy, m_controller.m1_busy, 
                         m_controller.controller_state);
            end
        end
    endtask
    
    // Task: Get current status
    function void get_status(output logic m0_busy, output logic m1_busy, 
                            output logic all_idle, output logic any_busy);
        m0_busy = m_controller.m0_busy;
        m1_busy = m_controller.m1_busy;
        all_idle = m_controller.all_idle;
        any_busy = m_controller.any_busy;
    endfunction
    
endclass

//==============================================================================
// Master Controller Interface
//==============================================================================
// Interface for connecting controller to testbench
//==============================================================================

interface master_controller_if(input logic ACLK);
    
    // Control signals
    logic m0_start;
    logic m0_busy;
    logic m0_completed;
    
    logic m1_start;
    logic m1_busy;
    logic m1_completed;
    
    // Status outputs
    logic all_idle;
    logic any_busy;
    logic all_completed;
    logic [1:0] controller_state;
    
    // Clocking block for synchronous operations
    clocking cb @(posedge ACLK);
        output m0_start, m1_start;
        input m0_busy, m1_busy, m0_completed, m1_completed;
        input all_idle, any_busy, all_completed, controller_state;
    endclocking
    
    // Modport for controller
    modport controller(
        output m0_start, m1_start,
        input m0_busy, m1_busy, m0_completed, m1_completed,
        output all_idle, any_busy, all_completed, controller_state
    );
    
    // Modport for testbench
    modport testbench(
        input m0_start, m1_start,
        output m0_busy, m1_busy, m0_completed, m1_completed,
        input all_idle, any_busy, all_completed, controller_state,
        clocking cb
    );
    
endinterface

