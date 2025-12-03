`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: QoS_Arbiter_tb
// Description: Comprehensive testbench for QoS Arbiter module
//              Tests QoS-based priority arbitration between 2 AXI masters
//
// Test Cases:
//   1. Single request from Master 0
//   2. Single request from Master 1  
//   3. Both masters request with equal QoS (M0 priority)
//   4. Both masters request, M0 has higher QoS
//   5. Both masters request, M1 has higher QoS
//   6. Back-to-back requests
//   7. Reset behavior test
//   8. Token gating test
//   9. Channel_Granted control test
//   10. Maximum QoS priority test
////////////////////////////////////////////////////////////////////////////////

module QoS_Arbiter_tb();

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
    reg  [3:0]                  S00_AXI_awqos;
    reg                         S01_AXI_awvalid;
    reg  [3:0]                  S01_AXI_awqos;
    reg                         Channel_Granted;
    reg                         Token;
    
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
    Qos_Arbiter #(
        .Slaves_Num(Slaves_Num),
        .Slaves_ID_Size(Slaves_ID_Size)
    ) dut (
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S00_AXI_awqos  (S00_AXI_awqos),
        .S01_AXI_awvalid(S01_AXI_awvalid),
        .S01_AXI_awqos  (S01_AXI_awqos),
        .Channel_Granted(Channel_Granted),
        .Token          (Token),
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
        $display("           QoS ARBITER TESTBENCH");
        $display("================================================================================");
        $display("Clock Period: %0d ns", CLK_PERIOD);
        $display("Number of Slaves: %0d", Slaves_Num);
        $display("================================================================================\n");

        // Initialize all signals
        initialize_signals();
        
        // Apply reset
        apply_reset();
        
        // Run test cases
        test_1_single_request_m0();
        test_2_single_request_m1();
        test_3_equal_qos_priority();
        test_4_m0_higher_qos();
        test_5_m1_higher_qos();
        test_6_back_to_back_requests();
        test_7_reset_behavior();
        test_8_token_gating();
        test_9_channel_granted_control();
        test_10_max_qos_priority();
        test_11_zero_qos_priority();
        test_12_alternating_requests();

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
            S00_AXI_awqos    = 4'h0;
            S01_AXI_awvalid  = 0;
            S01_AXI_awqos    = 4'h0;
            Channel_Granted  = 1;  // Default: channel is granted
            Token            = 0;  // Default: no token
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
            S00_AXI_awqos   = 4'h5;
            S01_AXI_awvalid = 0;
            S01_AXI_awqos   = 4'h0;
            Channel_Granted = 1;
            Token           = 0;
            
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
            S00_AXI_awqos   = 4'h0;
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h7;
            Channel_Granted = 1;
            Token           = 0;
            
            // Check: M1 should be selected
            check_result(1, 1);
            
            // Cleanup
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 3: Both Request with Equal QoS (M0 Priority)
    //==========================================================================
    task test_3_equal_qos_priority;
        begin
            test_num = test_num + 1;
            test_name = "Both Request - Equal QoS (M0 Priority)";
            print_test_header(test_num, test_name);
            
            // Setup: Both request with same QoS
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h5;
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h5;
            Channel_Granted = 1;
            Token           = 0;
            
            // Check: M0 should win (>= priority)
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 4: Both Request - M0 Has Higher QoS
    //==========================================================================
    task test_4_m0_higher_qos;
        begin
            test_num = test_num + 1;
            test_name = "Both Request - M0 Higher QoS";
            print_test_header(test_num, test_name);
            
            // Setup: M0 has higher QoS
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'hA;  // QoS = 10
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h3;  // QoS = 3
            Channel_Granted = 1;
            Token           = 0;
            
            // Check: M0 should win
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 5: Both Request - M1 Has Higher QoS
    //==========================================================================
    task test_5_m1_higher_qos;
        begin
            test_num = test_num + 1;
            test_name = "Both Request - M1 Higher QoS";
            print_test_header(test_num, test_name);
            
            // Setup: M1 has higher QoS
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h2;  // QoS = 2
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'hF;  // QoS = 15 (MAX)
            Channel_Granted = 1;
            Token           = 0;
            
            // Check: M1 should win
            check_result(1, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 6: Back-to-Back Requests
    //==========================================================================
    task test_6_back_to_back_requests;
        begin
            test_num = test_num + 1;
            test_name = "Back-to-Back Requests";
            print_test_header(test_num, test_name);
            
            // Request 1: M0 with QoS=8
            $display("  Request 1: M0 (QoS=8)");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h8;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            Token           = 0;
            check_result(0, 1);
            
            // Request 2: M1 with QoS=9 (higher)
            $display("  Request 2: M1 (QoS=9)");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h8;
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h9;
            check_result(1, 1);
            
            // Request 3: Both with QoS=5 (M0 wins)
            $display("  Request 3: Both (QoS=5, M0 wins)");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h5;
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h5;
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 7: Reset Behavior
    //==========================================================================
    task test_7_reset_behavior;
        begin
            test_num = test_num + 1;
            test_name = "Reset Behavior Test";
            print_test_header(test_num, test_name);
            
            // Setup active request
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h7;
            Channel_Granted = 1;
            Token           = 0;
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
    // Test Case 8: Token Gating Test
    //==========================================================================
    task test_8_token_gating;
        begin
            test_num = test_num + 1;
            test_name = "Token Gating Test";
            print_test_header(test_num, test_name);
            
            // Setup: Valid request with Token = 1 (should gate request)
            $display("  Test with Token = 1 (request should be gated)");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h5;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            Token           = 1;  // Token active - gates request
            
            @(posedge ACLK);
            #1;
            if (Channel_Request === 0) begin
                $display("  [PASS] Channel_Request gated by Token");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Channel_Request not gated: %0b", Channel_Request);
                fail_count = fail_count + 1;
            end
            
            // Test with Token = 0 (request should pass)
            $display("  Test with Token = 0 (request should pass)");
            Token = 0;
            @(posedge ACLK);
            #1;
            if (Channel_Request === 1) begin
                $display("  [PASS] Channel_Request active when Token=0");
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Channel_Request should be active: %0b", Channel_Request);
                fail_count = fail_count + 1;
            end
            
            // Cleanup
            S00_AXI_awvalid = 0;
            Token = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 9: Channel_Granted Control Test
    //==========================================================================
    task test_9_channel_granted_control;
        begin
            test_num = test_num + 1;
            test_name = "Channel_Granted Control Test";
            print_test_header(test_num, test_name);
            
            // Test with Channel_Granted = 0 (request should be blocked)
            $display("  Test with Channel_Granted = 0");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h5;
            Channel_Granted = 0;  // Channel not granted
            Token           = 0;
            
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
    // Test Case 10: Maximum QoS Priority Test
    //==========================================================================
    task test_10_max_qos_priority;
        begin
            test_num = test_num + 1;
            test_name = "Maximum QoS Priority Test";
            print_test_header(test_num, test_name);
            
            // M0 with max QoS vs M1 with lower QoS
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'hF;  // Max QoS = 15
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'hE;  // QoS = 14
            Channel_Granted = 1;
            Token           = 0;
            
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 11: Zero QoS Priority Test
    //==========================================================================
    task test_11_zero_qos_priority;
        begin
            test_num = test_num + 1;
            test_name = "Zero QoS Priority Test";
            print_test_header(test_num, test_name);
            
            // Both with zero QoS (M0 should win)
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h0;
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h0;
            Channel_Granted = 1;
            Token           = 0;
            
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 0;
            @(posedge ACLK);
        end
    endtask

    //==========================================================================
    // Test Case 12: Alternating Requests
    //==========================================================================
    task test_12_alternating_requests;
        begin
            test_num = test_num + 1;
            test_name = "Alternating Requests Test";
            print_test_header(test_num, test_name);
            
            // M0 request
            $display("  Cycle 1: M0 request");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h3;
            S01_AXI_awvalid = 0;
            Channel_Granted = 1;
            Token           = 0;
            check_result(0, 1);
            
            // M1 request
            $display("  Cycle 2: M1 request");
            S00_AXI_awvalid = 0;
            S01_AXI_awvalid = 1;
            S01_AXI_awqos   = 4'h4;
            check_result(1, 1);
            
            // M0 request again
            $display("  Cycle 3: M0 request");
            S00_AXI_awvalid = 1;
            S00_AXI_awqos   = 4'h6;
            S01_AXI_awvalid = 0;
            check_result(0, 1);
            
            // Cleanup
            S00_AXI_awvalid = 0;
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
                $display("\n*** ALL TESTS PASSED! ***\n");
            end else begin
                $display("\n*** %0d TEST(S) FAILED! ***\n", fail_count);
            end
        end
    endtask

    //==========================================================================
    // Waveform Dump (for debugging)
    //==========================================================================
    initial begin
        $dumpfile("QoS_Arbiter_tb.vcd");
        $dumpvars(0, QoS_Arbiter_tb);
    end

    //==========================================================================
    // Monitor (optional - uncomment for detailed signal monitoring)
    //==========================================================================
    /*
    initial begin
        $monitor("Time=%0t | M0_valid=%b QoS=%h | M1_valid=%b QoS=%h | Granted=%b Token=%b | Request=%b Selected=%0d",
                 $time, S00_AXI_awvalid, S00_AXI_awqos, S01_AXI_awvalid, S01_AXI_awqos,
                 Channel_Granted, Token, Channel_Request, Selected_Slave);
    end
    */

endmodule


