`timescale 1ns/1ps

//==============================================================================
// Dual Master Testbench with Controller
//==============================================================================
// Example testbench showing how to use Master Controller to simplify code
// This replaces the long testbench code with simple controller calls
//==============================================================================

module dual_master_with_controller_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz clock
    
    // Clock and Reset
    logic ACLK = 0;
    logic ARESETN = 1;
    
    // Controller signals
    logic m0_start;
    logic m0_busy;
    logic m0_completed;
    logic m1_start;
    logic m1_busy;
    logic m1_completed;
    logic all_idle;
    logic any_busy;
    logic all_completed;
    logic [1:0] controller_state;
    
    // Master 0 internal signals
    logic [31:0] m0_instruction;
    logic [31:0] m0_result;
    
    // Master 1 internal signals
    logic [31:0] m1_address_offset;
    
    // AXI signals (simplified - only showing control interface)
    // In real testbench, these would connect to AXI Interconnect
    
    //==============================================================================
    // Clock Generation
    //==============================================================================
    always #(CLK_PERIOD/2) ACLK = ~ACLK;
    
    //==============================================================================
    // DUT Instantiations
    //==============================================================================
    
    // Master Controller
    master_controller #(
        .NUM_MASTERS(2)
    ) controller (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .m0_start(m0_start),
        .m0_busy(m0_busy),
        .m0_completed(m0_completed),
        .m1_start(m1_start),
        .m1_busy(m1_busy),
        .m1_completed(m1_completed),
        .all_idle(all_idle),
        .any_busy(any_busy),
        .all_completed(all_completed),
        .controller_state(controller_state)
    );
    
    // Note: In a real testbench, you would also instantiate:
    // - axi_master_0 and axi_master_1 modules
    // - AXI Interconnect
    // - Slave models
    // And connect their busy/completed signals to controller
    
    //==============================================================================
    // Helper Tasks (Using Controller)
    //==============================================================================
    // These tasks demonstrate how controller simplifies testbench code
    
    // Task: Start Master 0 using controller
    task start_m0();
        controller.start_m0_task();
    endtask
    
    // Task: Start Master 1 using controller
    task start_m1();
        controller.start_m1_task();
    endtask
    
    // Task: Start both masters using controller
    task start_both();
        controller.start_both_task();
    endtask
    
    // Task: Sequential operation - M0 then M1
    task sequential_m0_then_m1();
        $display("[%0t] Starting sequential operation: M0 then M1", $time);
        start_m0();
        wait(m0_completed);
        $display("[%0t] M0 completed, starting M1", $time);
        start_m1();
        wait(m1_completed);
        $display("[%0t] M1 completed", $time);
    endtask
    
    // Task: Parallel operation - both start simultaneously
    task parallel_both();
        $display("[%0t] Starting parallel operation: both masters", $time);
        start_both();
        wait(all_idle);
        $display("[%0t] Both masters completed", $time);
    endtask
    
    // Task: Contention test - M0 starts, M1 starts during M0 operation
    task contention_test();
        $display("[%0t] Starting contention test", $time);
        start_m0();
        wait(m0_busy);
        $display("[%0t] M0 is busy, starting M1", $time);
        #(CLK_PERIOD * 2);
        start_m1();
        wait(all_idle);
        $display("[%0t] Contention test completed", $time);
    endtask
    
    // Task: Wait for all idle
    task wait_all_idle();
        wait(all_idle);
        @(posedge ACLK);
    endtask
    
    // Task: Monitor busy flags
    task monitor_busy_flags(int duration_ns);
        int start_time = $time;
        while (($time - start_time) < duration_ns) begin
            @(posedge ACLK);
            if (any_busy) begin
                $display("[%0t] BUSY: M0_busy=%b, M1_busy=%b, State=%0d", 
                         $time, m0_busy, m1_busy, controller_state);
            end
        end
    endtask
    
    //==============================================================================
    // Test Sequence
    //==============================================================================
    initial begin
        $display("============================================================================");
        $display("Dual Master Testbench with Controller");
        $display("Demonstrating simplified testbench using Master Controller");
        $display("============================================================================");
        $display("");
        
        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        ARESETN = 0;
        #(CLK_PERIOD * 5);
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        $display("[%0t] Reset released", $time);
        $display("[%0t] Initial state: all_idle=%b, any_busy=%b, state=%0d", 
                 $time, all_idle, any_busy, controller_state);
        $display("");
        
        // Test 1: Sequential operation
        $display("============================================================================");
        $display("Test 1: Sequential Operation (M0 then M1)");
        $display("============================================================================");
        sequential_m0_then_m1();
        $display("[%0t] [PASS] Test 1 completed", $time);
        $display("");
        
        #(CLK_PERIOD * 10);
        
        // Test 2: Parallel operation
        $display("============================================================================");
        $display("Test 2: Parallel Operation (Both masters simultaneously)");
        $display("============================================================================");
        parallel_both();
        $display("[%0t] [PASS] Test 2 completed", $time);
        $display("");
        
        #(CLK_PERIOD * 10);
        
        // Test 3: Contention test
        $display("============================================================================");
        $display("Test 3: Contention Test (M1 starts during M0 operation)");
        $display("============================================================================");
        contention_test();
        $display("[%0t] [PASS] Test 3 completed", $time);
        $display("");
        
        #(CLK_PERIOD * 10);
        $display("============================================================================");
        $display("All Tests Complete!");
        $display("============================================================================");
        $display("");
        $display("Note: This is a simplified example.");
        $display("In a real testbench, you would:");
        $display("  1. Instantiate axi_master_0 and axi_master_1");
        $display("  2. Connect their busy/completed signals to controller");
        $display("  3. Connect AXI signals to AXI Interconnect");
        $display("  4. Use controller tasks to control masters easily");
        $display("============================================================================");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("dual_master_with_controller_tb.vcd");
        $dumpvars(0, dual_master_with_controller_tb);
    end

endmodule


