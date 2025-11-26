`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Arbiter_tb
// Description: Comprehensive testbench for Write_Arbiter module
//              Tests Fixed Priority arbitration between 2 AXI masters
//
// Test Cases:
//   1. Single request from Master 0
//   2. Single request from Master 1  
//   3. Both masters request (M0 priority)
//   4. No requests
//   5. Reset behavior test
//   6. Channel_Granted control test
//   7. Back-to-back requests
//   8. Alternating requests
//   9. M0 continuous requests (M1 starvation test)
//   10. Sequential priority test
////////////////////////////////////////////////////////////////////////////////

module Write_Arbiter_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter Slaves_Num = 2;
    parameter Slaves_ID_Size = $clog2(Slaves_Num);

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg                         ACLK;
    reg                         ARESETN;
    reg                         S00_AXI_awvalid;
    reg                         S01_AXI_awvalid;
    reg                         Channel_Granted;
    
    wire                        Channel_Request;
    wire [Slaves_ID_Size-1:0]   Selected_Slave;

    //==========================================================================
    // Test Control Variables
    //==========================================================================
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg [255:0] test_name;

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Write_Arbiter #(
        .Slaves_Num(Slaves_Num),
        .Slaves_ID_Size(Slaves_ID_Size)
    ) dut (
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S01_AXI_awvalid(S01_AXI_awvalid),
        .Channel_Granted(Channel_Granted),
        .Channel_Request(Channel_Request),
        .Selected_Slave (Selected_Slave)
    );

    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        // Initialize counters
        test_num = 0;
        pass_count = 0;
        fail_count = 0;

        // Print header
        $display("\n");
        $display("================================================================================");
        $display("           WRITE ARBITER (FIXED PRIORITY) TESTBENCH");
        $display("================================================================================");
        $display("Clock Period: %0d ns", CLK_PERIOD);
        $display("Number of Slaves: %0d", Slaves_Num);
        $display("Arbitration: FIXED PRIORITY (M0 > M1)");
        $display("================================================================================\n");

        // Initialize all signals
        initialize_signals();
        
        // Apply reset
        apply_reset();
        
        // Run test cases
        test_1_single_request_m0();
        test_2_single_request_m1();
        test_3_both_request_m0_priority();
        test_4_no_requests();
        test_5_reset_behavior();
        test_6_channel_granted_control();
        test_7_back_to_back_requests();
        test_8_alternating_requests();
        test_9_starvation_test();
        test_10_sequential_priority();

        // Print final results
        print_results();
        
        // End simulation
        #100;
        $finish;
    end

    //==========================================================================
    // Task: Initialize Signals
    //==========================================================================
    task initialize_signals;
        begin
            ARESETN          = 0;
            S00_AXI_awvalid  = 0;
            S01_AXI_awvalid  = 0;
            Channel_Granted  = 1;  // Default: channel is granted
        end
    endtask

    //==========================================================================
    // Task: Apply Reset
    //==========================================================================
    task apply_reset;
        begin
            $display("[%0t] Applying Reset...", $time);
            ARESETN = 0;
            repeat(5) @(posedge ACLK);
            ARESETN = 1;
            repeat(2) @(posedge ACLK);
            $display("[%0t] Reset Released\n", $time);
        end
    endtask

    //==========================================================================
    // Task: Check Result
    //==========================================================================
    task check_result;
        input [Slaves_ID_Size-1:0] expected_slave;
        input expected_request;
        begin
            @(posedge ACLK);
            #1; // Small delay for signal propagation
            
            if (Selected_Slave === expected_slave && Channel_Request === expected_request) begin
                $display("  [PASS] Selected_Slave = %0d, Channel_Request = %0b", 
                         Selected_Slave, Channel_Request);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Expected: Slave=%0d, Request=%0b | Got: Slave=%0d, Request=%0b",
                         expected_slave, expected_request, Selected_Slave, Channel_Request);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //==========================================================================
    // Test Case 1: Single Request from Master 0
    //==========================================================================
    task test_1_single_request_m0;
        begin
            test_num = test_num + 1;
            test_name = "Single Request from Master 0";
            print_test_header(test_num, test_name);
            
            // Setup: Only M0 requests
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            
            // Check: M0 should be selected
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 2: Single Request from Master 1
    //==========================================================================
    task test_2_single_request_m1;
        begin
            test_num = test_num + 1;
            test_name = "Single Request from Master 1";
            print_test_header(test_num, test_name);
            
            // Setup: Only M1 requests
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 1;
            Channel_Granted = 1;
            
            // Check: M1 should be selected
            check_result(1, 1);
            
            // Cleanup
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 3: Both Request (M0 Priority)
    //==========================================================================
    task test_3_both_request_m0_priority;
        begin
            test_num = test_num + 1;
            test_name = "Both Request - M0 Priority (Fixed Priority)";
            print_test_header(test_num, test_name);
            
            // Setup: Both request
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            Channel_Granted = 1;
            
            // Check: M0 should win (fixed priority)
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 4: No Requests
    //==========================================================================
    task test_4_no_requests;
        begin
            test_num = test_num + 1;
            test_name = "No Requests from Any Master";
            print_test_header(test_num, test_name);
            
            // Setup: No requests
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            
            @(posedge ACLK);
            #1;
            
            if (Channel_Request === 0) begin
                $display("  [PASS] No request generated when no masters active");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Request should be 0, got: %0b", Channel_Request);
                fail_count = fail_count + 1;
            end
            
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 5: Reset Behavior
    //==========================================================================
    task test_5_reset_behavior;
        begin
            test_num = test_num + 1;
            test_name = "Reset Behavior Test";
            print_test_header(test_num, test_name);
            
            // Setup active request
            S00_AXI_awvalid = 1;
            Channel_Granted = 1;
            @(posedge ACLK);
            
            // Apply reset
            $display("  Applying reset during active request...");
            ARESETN = 0;
            repeat(2) @(posedge ACLK);
            
            // Check: Selected_Slave should be reset to 0
            #1;
            if (Selected_Slave === 0) begin
                $display("  [PASS] Selected_Slave reset to 0");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Selected_Slave not reset properly: %0d", Selected_Slave);
                fail_count = fail_count + 1;
            end
            
            // Release reset
            ARESETN = 1;
            S00_AXI_awvalid = 0;
            repeat(2) @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 6: Channel_Granted Control Test
    //==========================================================================
    task test_6_channel_granted_control;
        begin
            test_num = test_num + 1;
            test_name = "Channel_Granted Control Test";
            print_test_header(test_num, test_name);
            
            // Test with Channel_Granted = 0 (request should be blocked)
            $display("  Test with Channel_Granted = 0");
            S00_AXI_awvalid = 1;
            Channel_Granted = 0;  // Channel not granted
            
            @(posedge ACLK);
            #1;
            if (Channel_Request === 0) begin
                $display("  [PASS] Request blocked when Channel_Granted=0");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Request should be blocked: %0b", Channel_Request);
                fail_count = fail_count + 1;
            end
            
            // Test with Channel_Granted = 1 (request should pass)
            $display("  Test with Channel_Granted = 1");
            Channel_Granted = 1;
            @(posedge ACLK);
            #1;
            if (Channel_Request === 1) begin
                $display("  [PASS] Request active when Channel_Granted=1");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Request should be active: %0b", Channel_Request);
                fail_count = fail_count + 1;
            end
            
            // Cleanup
            S00_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 7: Back-to-Back Requests
    //==========================================================================
    task test_7_back_to_back_requests;
        begin
            test_num = test_num + 1;
            test_name = "Back-to-Back Requests";
            print_test_header(test_num, test_name);
            
            // Request 1: M0
            $display("  Request 1: M0 only");
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            check_result(0, 1);
            
            // Request 2: M1
            $display("  Request 2: M1 only");
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 1;
            check_result(1, 1);
            
            // Request 3: Both (M0 wins)
            $display("  Request 3: Both (M0 wins due to priority)");
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 8: Alternating Requests
    //==========================================================================
    task test_8_alternating_requests;
        begin
            test_num = test_num + 1;
            test_name = "Alternating Requests Test";
            print_test_header(test_num, test_name);
            
            // M0 request
            $display("  Cycle 1: M0 request");
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            check_result(0, 1);
            
            // M1 request
            $display("  Cycle 2: M1 request");
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 1;
            check_result(1, 1);
            
            // M0 request again
            $display("  Cycle 3: M0 request");
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 0;
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 9: Starvation Test (M0 Continuous)
    //==========================================================================
    task test_9_starvation_test;
        begin
            test_num = test_num + 1;
            test_name = "Starvation Test - M0 Continuous Requests";
            print_test_header(test_num, test_name);
            
            $display("  WARNING: This demonstrates M1 starvation!");
            $display("  Both M0 and M1 request for 5 cycles...");
            
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            Channel_Granted = 1;
            
            // M0 should win ALL 5 times (demonstrating starvation)
            $display("  Cycle 1: Both request");
            check_result(0, 1);
            
            $display("  Cycle 2: Both request");
            check_result(0, 1);
            
            $display("  Cycle 3: Both request");
            check_result(0, 1);
            
            $display("  Cycle 4: Both request");
            check_result(0, 1);
            
            $display("  Cycle 5: Both request");
            check_result(0, 1);
            
            $display("  RESULT: M0 won all 5 cycles ? M1 STARVED!");
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 10: Sequential Priority Test
    //==========================================================================
    task test_10_sequential_priority;
        begin
            test_num = test_num + 1;
            test_name = "Sequential Priority Test";
            print_test_header(test_num, test_name);
            
            Channel_Granted = 1;
            
            // Sequence 1: M1 alone
            $display("  Step 1: M1 alone ? M1 selected");
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 1;
            check_result(1, 1);
            
            // Sequence 2: M0 joins (M0 takes over immediately)
            $display("  Step 2: M0 joins ? M0 takes over (priority)");
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            check_result(0, 1);
            
            // Sequence 3: M0 leaves (M1 gets access)
            $display("  Step 3: M0 leaves ? M1 gets access");
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 1;
            check_result(1, 1);
            
            // Cleanup
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Helper Task: Print Test Header
    //==========================================================================
    task print_test_header;
        input integer num;
        input [255:0] name;
        begin
            $display("--------------------------------------------------------------------------------");
            $display("Test %0d: %0s", num, name);
            $display("--------------------------------------------------------------------------------");
        end
    endtask

    //==========================================================================
    // Helper Task: Print Final Results
    //==========================================================================
    task print_results;
        begin
            $display("\n");
            $display("================================================================================");
            $display("                         TEST SUMMARY");
            $display("================================================================================");
            $display("Total Tests:  %0d", test_num);
            $display("Passed:       %0d", pass_count);
            $display("Failed:       %0d", fail_count);
            $display("Pass Rate:    %0.1f%%", (pass_count * 100.0) / (pass_count + fail_count));
            $display("================================================================================");
            
            if (fail_count == 0) begin
                $display("\n*** ALL TESTS PASSED! ***");
                $display("NOTE: Test 9 demonstrated M1 starvation - this is expected behavior");
                $display("      for Fixed Priority arbitration. Use Write_Arbiter_RR for fairness.\n");
            end else begin
                $display("\n*** %0d TEST(S) FAILED! ***\n", fail_count);
            end
        end
    endtask

    //==========================================================================
    // Waveform Dump
    //==========================================================================
    initial begin
        $dumpfile("Write_Arbiter_tb.vcd");
        $dumpvars(0, Write_Arbiter_tb);
    end

endmodule


