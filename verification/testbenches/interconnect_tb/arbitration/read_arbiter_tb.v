`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: read_arbiter_tb
// Description: Comprehensive testbench for Read_Arbiter module
//              Tests QoS-based arbitration between 2 AXI masters
//
// Source File: src/axi_interconnect/rtl/arbitration/algorithms/read_arbiter.v
// Module: Read_Arbiter
// Arbitration Policy: QoS-based (Higher QoS > Lower QoS, M0 priority on tie)
//
// Features:
//   - Token signal for split transaction control
//   - Channel_Request blocked when Token active
//   - Selected_Master updates only when Channel_Granted & (~Token)
//
// Test Cases:
//   1. Single request from Master 0
//   2. Single request from Master 1  
//   3. Both masters request (QoS-based)
//   4. No requests
//   5. Reset behavior test
//   6. Channel_Granted control test
//   7. Token control (split transaction)
//   8. QoS priority tests (M0 > M1 when equal)
//   9. QoS priority tests (M1 > M0 when higher QoS)
//   10. Back-to-back requests
////////////////////////////////////////////////////////////////////////////////

module read_arbiter_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter Masters_Num = 2;
    parameter Masters_ID_Size = $clog2(Masters_Num);

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg                         ACLK;
    reg                         ARESETN;
    reg                         S00_AXI_arvalid;
    reg [3:0]                   S00_AXI_arqos;
    reg                         S01_AXI_arvalid;
    reg [3:0]                   S01_AXI_arqos;
    reg                         Channel_Granted;
    reg                         Token;
    
    wire                        Channel_Request;
    wire [Masters_ID_Size-1:0]  Selected_Master;

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
    Read_Arbiter #(
        .Masters_Num(Masters_Num),
        .Masters_ID_Size(Masters_ID_Size)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S00_AXI_arvalid(S00_AXI_arvalid),
        .S00_AXI_arqos(S00_AXI_arqos),
        .S01_AXI_arvalid(S01_AXI_arvalid),
        .S01_AXI_arqos(S01_AXI_arqos),
        .Channel_Granted(Channel_Granted),
        .Token(Token),
        .Channel_Request(Channel_Request),
        .Selected_Master(Selected_Master)
    );

    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    //==========================================================================
    // Task: Initialize Signals
    //==========================================================================
    task initialize_signals;
        begin
            ARESETN          = 0;
            S00_AXI_arvalid  = 0;
            S00_AXI_arqos    = 0;
            S01_AXI_arvalid  = 0;
            S01_AXI_arqos    = 0;
            Channel_Granted  = 1;  // Default: channel is granted
            Token            = 0;  // Default: no split transaction
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
        input [Masters_ID_Size-1:0] expected_master;
        input expected_request;
        input [255:0] test_name;
        begin
            test_num = test_num + 1;
            repeat(2) @(posedge ACLK);  // Wait for registered output
            
            if ((Selected_Master === expected_master) && 
                (Channel_Request === expected_request)) begin
                $display("[PASS] %s: Master=%0d, Request=%0b", 
                         test_name, Selected_Master, Channel_Request);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s", test_name);
                $display("       Expected: Master=%0d, Request=%0b", 
                         expected_master, expected_request);
                $display("       Got:      Master=%0d, Request=%0b", 
                         Selected_Master, Channel_Request);
                fail_count = fail_count + 1;
            end
        end
    endtask

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
        $display("           READ ARBITER (QoS-BASED) TESTBENCH");
        $display("================================================================================");
        $display("Clock Period: %0d ns", CLK_PERIOD);
        $display("Number of Masters: %0d", Masters_Num);
        $display("Arbitration: QoS-BASED (Higher QoS > Lower QoS, M0 priority when equal)");
        $display("================================================================================\n");

        // Initialize all signals
        initialize_signals();
        
        // Apply reset
        apply_reset();
        
        // Test 1: Single request from Master 0
        $display("--- Test 1: Single Request from Master 0 ---");
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h5;
        check_result(0, 1, "Single request M0");
        S00_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 2: Single request from Master 1
        $display("--- Test 2: Single Request from Master 1 ---");
        S01_AXI_arvalid = 1;
        S01_AXI_arqos = 4'h5;
        check_result(1, 1, "Single request M1");
        S01_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 3: Both masters request, M0 has higher QoS
        $display("--- Test 3: Both Request, M0 Higher QoS ---");
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h8;
        S01_AXI_arvalid = 1;
        S01_AXI_arqos = 4'h5;
        check_result(0, 1, "M0 QoS=8 > M1 QoS=5");
        S00_AXI_arvalid = 0;
        S01_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 4: Both masters request, M1 has higher QoS
        $display("--- Test 4: Both Request, M1 Higher QoS ---");
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h3;
        S01_AXI_arvalid = 1;
        S01_AXI_arqos = 4'h7;
        check_result(1, 1, "M1 QoS=7 > M0 QoS=3");
        S00_AXI_arvalid = 0;
        S01_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 5: Both masters request, equal QoS (M0 priority)
        $display("--- Test 5: Both Request, Equal QoS (M0 Priority) ---");
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h5;
        S01_AXI_arvalid = 1;
        S01_AXI_arqos = 4'h5;
        check_result(0, 1, "Equal QoS, M0 has priority");
        S00_AXI_arvalid = 0;
        S01_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 6: No requests
        $display("--- Test 6: No Requests ---");
        S00_AXI_arvalid = 0;
        S01_AXI_arvalid = 0;
        check_result(0, 0, "No requests");
        $display("");

        // Test 7: Channel not granted
        $display("--- Test 7: Channel Not Granted ---");
        Channel_Granted = 0;
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h5;
        check_result(0, 0, "Channel not granted, no request");
        Channel_Granted = 1;
        S00_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 8: Token active (split transaction)
        $display("--- Test 8: Token Active (Split Transaction) ---");
        Token = 1;
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h5;
        check_result(0, 0, "Token active, no new request");
        Token = 0;
        S00_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 9: Reset behavior
        $display("--- Test 9: Reset Behavior ---");
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h5;
        apply_reset();
        check_result(0, 0, "After reset, default to M0");
        S00_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Test 10: Back-to-back requests
        $display("--- Test 10: Back-to-Back Requests ---");
        S00_AXI_arvalid = 1;
        S00_AXI_arqos = 4'h6;
        @(posedge ACLK);
        S00_AXI_arvalid = 0;
        S01_AXI_arvalid = 1;
        S01_AXI_arqos = 4'h4;
        check_result(1, 1, "Back-to-back: M0 then M1");
        S01_AXI_arvalid = 0;
        repeat(2) @(posedge ACLK);
        $display("");

        // Wait a bit
        repeat(5) @(posedge ACLK);

        // Print final results
        $display("==========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_num);
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

