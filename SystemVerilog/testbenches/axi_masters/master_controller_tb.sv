`timescale 1ns/1ps

//==============================================================================
// Master Controller Testbench
//==============================================================================
// Testbench demonstrating usage of Master Controller
// Shows how to use controller to simplify testbench code
//==============================================================================

module master_controller_tb;

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
    
    // Mock master busy signals (for testing controller only)
    logic m0_busy_mock;
    logic m1_busy_mock;
    logic m0_completed_mock;
    logic m1_completed_mock;
    
    // Assign mock signals
    assign m0_busy = m0_busy_mock;
    assign m1_busy = m1_busy_mock;
    assign m0_completed = m0_completed_mock;
    assign m1_completed = m1_completed_mock;
    
    //==============================================================================
    // Clock Generation
    //==============================================================================
    always #(CLK_PERIOD/2) ACLK = ~ACLK;
    
    //==============================================================================
    // DUT Instantiation
    //==============================================================================
    master_controller #(
        .NUM_MASTERS(2)
    ) dut (
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
    
    //==============================================================================
    // Helper Tasks (Simplified version of BFM tasks)
    //==============================================================================
    
    // Task: Start Master 0
    task start_m0();
        @(posedge ACLK);
        m0_start = 1'b1;
        @(posedge ACLK);
        m0_start = 1'b0;
    endtask
    
    // Task: Start Master 1
    task start_m1();
        @(posedge ACLK);
        m1_start = 1'b1;
        @(posedge ACLK);
        m1_start = 1'b0;
    endtask
    
    // Task: Start both masters
    task start_both();
        @(posedge ACLK);
        m0_start = 1'b1;
        m1_start = 1'b1;
        @(posedge ACLK);
        m0_start = 1'b0;
        m1_start = 1'b0;
    endtask
    
    // Task: Wait for all idle
    task wait_all_idle();
        wait(all_idle);
        @(posedge ACLK);
    endtask
    
    //==============================================================================
    // Mock Master Behavior
    //==============================================================================
    // Simulate master 0 behavior
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            m0_busy_mock <= 1'b0;
            m0_completed_mock <= 1'b0;
        end else begin
            if (m0_start && !m0_busy_mock) begin
                m0_busy_mock <= 1'b1;
                m0_completed_mock <= 1'b0;
            end else if (m0_busy_mock) begin
                // Simulate operation duration
                if ($time % 100 == 0) begin  // Complete after some time
                    m0_busy_mock <= 1'b0;
                    m0_completed_mock <= 1'b1;
                end
            end else begin
                m0_completed_mock <= 1'b0;
            end
        end
    end
    
    // Simulate master 1 behavior
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            m1_busy_mock <= 1'b0;
            m1_completed_mock <= 1'b0;
        end else begin
            if (m1_start && !m1_busy_mock) begin
                m1_busy_mock <= 1'b1;
                m1_completed_mock <= 1'b0;
            end else if (m1_busy_mock) begin
                // Simulate operation duration
                if ($time % 150 == 0) begin  // Complete after some time
                    m1_busy_mock <= 1'b0;
                    m1_completed_mock <= 1'b1;
                end
            end else begin
                m1_completed_mock <= 1'b0;
            end
        end
    end
    
    //==============================================================================
    // Test Sequence
    //==============================================================================
    initial begin
        $display("============================================================================");
        $display("Master Controller Testbench");
        $display("============================================================================");
        $display("");
        
        // Initialize
        m0_busy_mock = 0;
        m1_busy_mock = 0;
        m0_completed_mock = 0;
        m1_completed_mock = 0;
        
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
        
        // Test 1: Start Master 0
        $display("============================================================================");
        $display("Test 1: Start Master 0");
        $display("============================================================================");
        $display("[%0t] Starting Master 0...", $time);
        start_m0();
        $display("[%0t] After start: all_idle=%b, any_busy=%b, state=%0d", 
                 $time, all_idle, any_busy, controller_state);
        
        wait_all_idle();
        $display("[%0t] Master 0 completed: all_idle=%b, state=%0d", 
                 $time, all_idle, controller_state);
        $display("[%0t] [PASS] Test 1 completed", $time);
        $display("");
        
        // Test 2: Start Master 1
        $display("============================================================================");
        $display("Test 2: Start Master 1");
        $display("============================================================================");
        $display("[%0t] Starting Master 1...", $time);
        start_m1();
        $display("[%0t] After start: all_idle=%b, any_busy=%b, state=%0d", 
                 $time, all_idle, any_busy, controller_state);
        
        wait_all_idle();
        $display("[%0t] Master 1 completed: all_idle=%b, state=%0d", 
                 $time, all_idle, controller_state);
        $display("[%0t] [PASS] Test 2 completed", $time);
        $display("");
        
        // Test 3: Start both simultaneously
        $display("============================================================================");
        $display("Test 3: Start both masters simultaneously");
        $display("============================================================================");
        $display("[%0t] Starting both masters...", $time);
        start_both();
        $display("[%0t] After start: all_idle=%b, any_busy=%b, state=%0d", 
                 $time, all_idle, any_busy, controller_state);
        
        wait_all_idle();
        $display("[%0t] Both masters completed: all_idle=%b, state=%0d", 
                 $time, all_idle, controller_state);
        $display("[%0t] [PASS] Test 3 completed", $time);
        $display("");
        
        #(CLK_PERIOD * 10);
        $display("============================================================================");
        $display("All Tests Complete!");
        $display("============================================================================");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("master_controller_tb.vcd");
        $dumpvars(0, master_controller_tb);
    end

endmodule


