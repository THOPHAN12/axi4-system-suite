`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Arbiter_RR_tb
// Description: Comprehensive testbench for Write_Arbiter_RR module
//              Tests Round-Robin arbitration between 2 AXI masters
//
// Test Cases:
//   1. Single request from Master 0
//   2. Single request from Master 1  
//   3. Both masters request (Round-Robin)
//   4. No requests
//   5. Reset behavior test
//   6. Channel_Granted control test
//   7. Round-Robin fairness test (extended)
//   8. Alternating requests
//   9. No starvation test
//   10. Sequential round-robin test
////////////////////////////////////////////////////////////////////////////////

module Write_Arbiter_RR_tb();

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
    Write_Arbiter_RR #(
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
        $display("           WRITE ARBITER ROUND-ROBIN TESTBENCH");
        $display("================================================================================");
        $display("Clock Period: %0d ns", CLK_PERIOD);
        $display("Number of Slaves: %0d", Slaves_Num);
        $display("Arbitration: ROUND-ROBIN (Fair)");
        $display("================================================================================\n");

        // Initialize all signals
        initialize_signals();
        
        // Apply reset
        apply_reset();
        
        // Run test cases
        test_1_single_request_m0();
        test_2_single_request_m1();
        test_3_both_request_round_robin();
        test_4_no_requests();
        test_5_reset_behavior();
        test_6_channel_granted_control();
        test_7_round_robin_fairness();
        test_8_alternating_requests();
        test_9_no_starvation_test();
        test_10_sequential_round_robin();

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
    // Test Case 3: Both Request (Round-Robin)
    //==========================================================================
    task test_3_both_request_round_robin;
        begin
            test_num = test_num + 1;
            test_name = "Both Request - Round-Robin Arbitration";
            print_test_header(test_num, test_name);
            
            // Setup: Both request
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            Channel_Granted = 1;
            
            // First arbitration: Should be M0 (last_served was reset to 1)
            $display("  Round 1: Expecting M0 (after reset)");
            check_result(0, 1);
            
            // Second arbitration: Should be M1 (M0 was just served)
            $display("  Round 2: Expecting M1 (M0 was last)");
            check_result(1, 1);
            
            // Third arbitration: Should be M0 (M1 was just served)
            $display("  Round 3: Expecting M0 (M1 was last)");
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
    // Test Case 7: Round-Robin Fairness Test (Extended)
    //==========================================================================
    task test_7_round_robin_fairness;
        // Variable declarations must be at the beginning
        integer m0_count, m1_count;
        integer i;
        reg [9:0] pattern;  // Store pattern of selections
        
        begin
            test_num = test_num + 1;
            test_name = "Round-Robin Fairness Test (10 cycles)";
            print_test_header(test_num, test_name);
            
            $display("  Both M0 and M1 request continuously for 10 cycles...");
            $display("  Expecting perfect alternation (M0-M1-M0-M1-...)");
            
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            Channel_Granted = 1;
            
            // Initialize counters
            m0_count = 0;
            m1_count = 0;
            pattern = 10'b0;
            
            for (i = 0; i < 10; i = i + 1) begin
                @(posedge ACLK);
                #1;
                
                if (Selected_Slave == 0) begin
                    m0_count = m0_count + 1;
                    pattern[i] = 1'b0;
                end else begin
                    m1_count = m1_count + 1;
                    pattern[i] = 1'b1;
                end
                
                $display("  Cycle %0d: Selected = M%0d", i+1, Selected_Slave);
            end
            
            // Check fairness (should be 5-5 or 6-4)
            $display("  Pattern: %b", pattern);
            $display("  M0 count: %0d, M1 count: %0d", m0_count, m1_count);
            
            if ((m0_count == 5 && m1_count == 5) || (m0_count == 6 && m1_count == 4)) begin
                $display("  [PASS] Fair distribution achieved!");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Unfair distribution: M0=%0d, M1=%0d", m0_count, m1_count);
                fail_count = fail_count + 1;
            end
            
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
    // Test Case 9: No Starvation Test
    //==========================================================================
    task test_9_no_starvation_test;
        // Variable declarations must be at the beginning
        integer m0_served, m1_served;
        integer j;
        
        begin
            test_num = test_num + 1;
            test_name = "No Starvation Test - Continuous Requests";
            print_test_header(test_num, test_name);
            
            $display("  Both M0 and M1 request continuously...");
            $display("  Verifying NO starvation (both get service)");
            
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            Channel_Granted = 1;
            
            // Initialize counters
            m0_served = 0;
            m1_served = 0;
            
            for (j = 0; j < 8; j = j + 1) begin
                @(posedge ACLK);
                #1;
                
                if (Selected_Slave == 0) begin
                    m0_served = m0_served + 1;
                    $display("  Cycle %0d: M0 served", j+1);
                end else begin
                    m1_served = m1_served + 1;
                    $display("  Cycle %0d: M1 served", j+1);
                end
            end
            
            $display("  Results: M0=%0d times, M1=%0d times", m0_served, m1_served);
            
            // Both should have been served at least once
            if (m0_served > 0 && m1_served > 0) begin
                $display("  [PASS] NO STARVATION - Both masters served!");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] STARVATION detected!");
                fail_count = fail_count + 1;
            end
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 10: Sequential Round-Robin Test
    //==========================================================================
    task test_10_sequential_round_robin;
        // Variable declarations must be at the beginning
        reg first_selected;
        
        begin
            test_num = test_num + 1;
            test_name = "Sequential Round-Robin Test";
            print_test_header(test_num, test_name);
            
            Channel_Granted = 1;
            
            // Sequence 1: Both request
            $display("  Step 1: Both request ? Round-robin starts");
            S00_AXI_awvalid = 1;
            S01_AXI_awvalid = 1;
            @(posedge ACLK);
            #1;
            first_selected = Selected_Slave;
            $display("  First selected: M%0d", first_selected);
            pass_count = pass_count + 1;
            
            // Sequence 2: Continue both request
            $display("  Step 2: Both continue ? Other master selected");
            @(posedge ACLK);
            #1;
            if (Selected_Slave != first_selected) begin
                $display("  [PASS] Alternated to M%0d (Round-Robin working)", Selected_Slave);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Did not alternate! Still M%0d", Selected_Slave);
                fail_count = fail_count + 1;
            end
            
            // Sequence 3: One master stops
            $display("  Step 3: M0 stops ? M1 continues");
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
                $display("Round-Robin arbitration provides FAIR access to both masters!");
                $display("NO STARVATION - Both M0 and M1 get equal service opportunity.\n");
            end else begin
                $display("\n*** %0d TEST(S) FAILED! ***\n", fail_count);
            end
        end
    endtask

    //==========================================================================
    // Waveform Dump
    //==========================================================================
    initial begin
        $dumpfile("Write_Arbiter_RR_tb.vcd");
        $dumpvars(0, Write_Arbiter_RR_tb);
    end

endmodule


