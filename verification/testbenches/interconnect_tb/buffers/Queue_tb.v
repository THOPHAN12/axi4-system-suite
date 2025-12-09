`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Queue_tb
// Description: Comprehensive testbench for Queue module
//              Tests FIFO functionality for tracking Master IDs in Write Data Channel
//
// Test Cases:
//   1. Single write and read transaction
//   2. Multiple writes then reads (FIFO order)
//   3. Queue full detection
//   4. Split burst handling
//   5. Reset behavior
//   6. Empty queue detection
//   7. Pulse generation test
//   8. Continuous writes and reads
////////////////////////////////////////////////////////////////////////////////

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
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Queue #(
        .Slaves_Num(Slaves_Num),
        .ID_Size(ID_Size)
    ) dut (
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
    // Task: Check Result
    //==========================================================================
    task check_result;
        input [ID_Size-1:0] expected_master;
        input expected_valid;
        input expected_full;
        input [255:0] test_name;
        begin
            test_count = test_count + 1;
            #1;
            
            if ((Write_Data_Master === expected_master) && 
                (Master_Valid === expected_valid) &&
                (Queue_Is_Full === expected_full)) begin
                $display("[PASS] %s: Master=%0d, Valid=%0b, Full=%0b", 
                         test_name, Write_Data_Master, Master_Valid, Queue_Is_Full);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", test_name);
                $display("       Expected: Master=%0d, Valid=%0b, Full=%0b", 
                         expected_master, expected_valid, expected_full);
                $display("       Got:      Master=%0d, Valid=%0b, Full=%0b", 
                         Write_Data_Master, Master_Valid, Queue_Is_Full);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //==========================================================================
    // Task: Write to Queue
    //==========================================================================
    task write_queue;
        input [ID_Size-1:0] slave_id;
        input split;
        begin
            Slave_ID = slave_id;
            Is_Transaction_Part_of_Split = split;
            AW_Access_Grant = 1;
            @(posedge ACLK);
            AW_Access_Grant = 0;
            #(CLK_PERIOD);
        end
    endtask

    //==========================================================================
    // Task: Read from Queue
    //==========================================================================
    task read_queue;
        begin
            Write_Data_Finsh = 1;
            @(posedge ACLK);
            Write_Data_Finsh = 0;
            #(CLK_PERIOD);
        end
    endtask

    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize
        ARESETN = 0;
        Slave_ID = 0;
        AW_Access_Grant = 0;
        Write_Data_Finsh = 0;
        Is_Transaction_Part_of_Split = 0;

        $display("\n");
        $display("==========================================");
        $display("Queue Testbench - FIFO for Master IDs");
        $display("==========================================");
        $display("Slaves_Num: %0d, ID_Size: %0d", Slaves_Num, ID_Size);
        $display("==========================================");
        $display("");

        // Apply Reset
        $display("--- Applying Reset ---");
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        $display("--- Reset Released ---\n");

        // Test 1: Single write and read
        $display("--- Test 1: Single Write/Read ---");
        write_queue(0, 0);
        check_result(0, 1, 0, "Single write, read Master ID 0");
        read_queue();
        check_result(0, 0, 0, "After read, queue empty");
        $display("");

        // Test 2: Multiple writes then reads (FIFO order)
        $display("--- Test 2: Multiple Writes/Reads (FIFO) ---");
        write_queue(0, 0);
        write_queue(1, 0);
        check_result(0, 1, 0, "First write (ID=0) at head");
        read_queue();
        check_result(1, 1, 0, "Second write (ID=1) at head");
        read_queue();
        check_result(1, 0, 0, "Queue empty after all reads");
        $display("");

        // Test 3: Queue full detection (with 2 slaves, queue can hold 2 entries)
        $display("--- Test 3: Queue Full Detection ---");
        write_queue(0, 0);
        write_queue(1, 0);
        check_result(0, 1, 1, "Queue full after 2 writes");
        $display("");

        // Test 4: Split burst handling
        $display("--- Test 4: Split Burst Handling ---");
        ARESETN = 0;
        #(CLK_PERIOD);
        ARESETN = 1;
        #(CLK_PERIOD);
        write_queue(0, 1);  // Split transaction
        check_result(0, 1, 0, "Split transaction written");
        if (Is_Master_Part_Of_Split === 1) begin
            $display("[PASS] Split flag correctly set");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Split flag not set correctly");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        $display("");

        // Test 5: Reset behavior
        $display("--- Test 5: Reset Behavior ---");
        write_queue(1, 0);
        ARESETN = 0;
        #(CLK_PERIOD);
        ARESETN = 1;
        #(CLK_PERIOD);
        check_result(0, 0, 0, "After reset, queue empty");
        $display("");

        // Test 6: Empty queue detection
        $display("--- Test 6: Empty Queue Detection ---");
        ARESETN = 0;
        #(CLK_PERIOD);
        ARESETN = 1;
        #(CLK_PERIOD);
        check_result(0, 0, 0, "Empty queue: Valid=0");
        $display("");

        // Test 7: Pulse generation
        $display("--- Test 7: Pulse Generation ---");
        ARESETN = 0;
        #(CLK_PERIOD);
        ARESETN = 1;
        #(CLK_PERIOD);
        write_queue(0, 0);
        @(posedge ACLK);
        if (Write_Data_HandShake_En_Pulse === 1) begin
            $display("[PASS] Pulse generated on first valid");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Pulse not generated");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        @(posedge ACLK);
        if (Write_Data_HandShake_En_Pulse === 0) begin
            $display("[PASS] Pulse is one cycle");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Pulse not one cycle");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        $display("");

        // Test 8: Continuous writes and reads
        $display("--- Test 8: Continuous Writes/Reads ---");
        ARESETN = 0;
        #(CLK_PERIOD);
        ARESETN = 1;
        #(CLK_PERIOD);
        write_queue(0, 0);
        write_queue(1, 0);
        read_queue();
        check_result(1, 1, 0, "Continuous: Read 0, Read 1");
        write_queue(0, 0);
        read_queue();
        check_result(0, 1, 0, "Continuous: Read 1, Write 0, Read 0");
        read_queue();
        check_result(0, 0, 0, "Continuous: Queue empty");
        $display("");

        // Wait a bit
        #(CLK_PERIOD * 2);

        // Print Summary
        $display("==========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_count);
        $display("  Passed:      %0d", pass_count);
        $display("  Failed:      %0d", fail_count);
        $display("==========================================");
        
        if (fail_count == 0) begin
            $display(">>> ALL TESTS PASSED <<<");
        end else begin
            $display(">>> SOME TESTS FAILED <<<");
        end
        
        $display("");
        #100;
        $finish;
    end

endmodule
