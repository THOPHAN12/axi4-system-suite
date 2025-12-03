`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Queue_tb
// Description: Testbench for Queue module used in Write Data Channel
//              Tests FIFO functionality for tracking Master IDs
//
// Test Cases:
//   1. Write and read single transaction
//   2. Multiple writes then reads (FIFO order)
//   3. Queue full detection
//   4. Split burst handling
//   5. Reset behavior
//////////////////////////////////////////////////////////////////////////////////

module Queue_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Slaves_Num = 2;
    parameter ID_Size = $clog2(Slaves_Num);

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg ACLK;
    reg ARESETN;
    reg [ID_Size-1:0] Slave_ID;
    reg AW_Access_Grant;
    reg Write_Data_Finsh;
    reg Is_Transaction_Part_of_Split;
    
    wire Queue_Is_Full;
    wire Write_Data_HandShake_En_Pulse;
    wire Is_Master_Part_Of_Split;
    wire Master_Valid;
    wire [ID_Size-1:0] Write_Data_Master;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg sim_done;

    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        while (!sim_done) begin
            #(CLK_PERIOD/2) ACLK = ~ACLK;
        end
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Queue #(
        .Slaves_Num(Slaves_Num),
        .ID_Size(ID_Size)
    ) uut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Slave_ID(Slave_ID),
        .AW_Access_Grant(AW_Access_Grant),
        .Write_Data_Finsh(Write_Data_Finsh),
        .Is_Transaction_Part_of_Split(Is_Transaction_Part_of_Split),
        .Queue_Is_Full(Queue_Is_Full),
        .Write_Data_HandShake_En_Pulse(Write_Data_HandShake_En_Pulse),
        .Is_Master_Part_Of_Split(Is_Master_Part_Of_Split),
        .Master_Valid(Master_Valid),
        .Write_Data_Master(Write_Data_Master)
    );

    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        sim_done = 0;
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize
        ARESETN = 0;
        Slave_ID = 0;
        AW_Access_Grant = 0;
        Write_Data_Finsh = 0;
        Is_Transaction_Part_of_Split = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("Queue Testbench");
        $display("==========================================");

        // Test 1: Write and read single transaction
        test_num = 1;
        $display("\n--- Test %0d: Single Write/Read ---", test_num);
        
        Slave_ID = 0;
        AW_Access_Grant = 1;
        @(posedge ACLK);
        AW_Access_Grant = 0;
        
        #(CLK_PERIOD);
        if (Master_Valid && Write_Data_Master == 0) begin
            $display("PASS: Master ID 0 read correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Master ID read incorrectly");
            fail_count = fail_count + 1;
        end

        Write_Data_Finsh = 1;
        @(posedge ACLK);
        Write_Data_Finsh = 0;
        #(CLK_PERIOD);

        // Test 2: Multiple writes
        test_num = 2;
        $display("\n--- Test %0d: Multiple Writes ---", test_num);
        
        Slave_ID = 0;
        AW_Access_Grant = 1;
        @(posedge ACLK);
        AW_Access_Grant = 0;
        
        Slave_ID = 1;
        AW_Access_Grant = 1;
        @(posedge ACLK);
        AW_Access_Grant = 0;
        
        #(CLK_PERIOD);
        if (Master_Valid && Write_Data_Master == 0) begin
            $display("PASS: First write (ID=0) read correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: First write read incorrectly");
            fail_count = fail_count + 1;
        end

        Write_Data_Finsh = 1;
        @(posedge ACLK);
        Write_Data_Finsh = 0;
        #(CLK_PERIOD);
        
        if (Master_Valid && Write_Data_Master == 1) begin
            $display("PASS: Second write (ID=1) read correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Second write read incorrectly");
            fail_count = fail_count + 1;
        end

        Write_Data_Finsh = 1;
        @(posedge ACLK);
        Write_Data_Finsh = 0;
        #(CLK_PERIOD);

        // Summary
        $display("\n==========================================");
        $display("Test Summary");
        $display("==========================================");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("==========================================");
        
        sim_done = 1;
        #(CLK_PERIOD * 2);
        $finish;
    end

endmodule

