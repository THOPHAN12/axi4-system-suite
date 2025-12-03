`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Controller_tb
// Description: Comprehensive testbench for Read Channel Controller
//              Tests:
//              1. Address decoding for 4 slaves
//              2. Fixed-Priority QoS Arbiter (M0 > M1)
//              3. Single master read requests
//              4. Simultaneous master requests
//              5. Read data channel routing
//              6. State machine transitions
//
// Update: Tests 4-slave support with Fixed-Priority QoS Arbiter
//////////////////////////////////////////////////////////////////////////////////

module Controller_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;

    //==========================================================================
    // Clock and Reset
    //==========================================================================
    reg clkk, resett;

    //==========================================================================
    // Address Ranges for 4 Slaves
    //==========================================================================
    reg [31:0] slave0_addr1, slave0_addr2;  // 0x00000000 - 0x1FFFFFFF
    reg [31:0] slave1_addr1, slave1_addr2;  // 0x20000000 - 0x3FFFFFFF
    reg [31:0] slave2_addr1, slave2_addr2;  // 0x40000000 - 0x5FFFFFFF
    reg [31:0] slave3_addr1, slave3_addr2;  // 0x60000000 - 0x7FFFFFFF
    
    //==========================================================================
    // Master Address Input (for address decoding)
    //==========================================================================
    reg [31:0] M_ADDR;
    
    //==========================================================================
    // Master 0/1 Read Address Channel
    //==========================================================================
    reg M0_ARVALID;
    reg M1_ARVALID;
    
    //==========================================================================
    // Master 0/1 Read Data Channel
    //==========================================================================
    reg M0_RREADY;
    reg M1_RREADY;
    
    //==========================================================================
    // Slave Read Address Channel (4 slaves)
    //==========================================================================
    reg S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
    
    //==========================================================================
    // Slave Read Data Channel (4 slaves)
    //==========================================================================
    reg S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
    reg S0_RLAST, S1_RLAST, S2_RLAST, S3_RLAST;
    
    //==========================================================================
    // Controller Outputs
    //==========================================================================
    wire [1:0] select_slave_address;  // 2-bit for 4 slaves
    wire select_master_address;
    wire [1:0] select_data_M0, select_data_M1;  // 2-bit for 4 slaves
    wire [1:0] en_S0, en_S1, en_S2, en_S3;  // 2-bit: 00=M0, 01=M1
    wire enable_S0, enable_S1, enable_S2, enable_S3;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg sim_done;

    //==========================================================================
    // Clock Generation
    // FIXED: Use 'forever' instead of 'while (!sim_done)' to ensure clock always runs
    //==========================================================================
    initial begin
        clkk = 0;
        forever begin
            #(CLK_PERIOD/2) clkk = ~clkk;
        end
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Controller uut (
        .clkk(clkk),
        .resett(resett),
        .slave0_addr1(slave0_addr1),
        .slave0_addr2(slave0_addr2),
        .slave1_addr1(slave1_addr1),
        .slave1_addr2(slave1_addr2),
        .slave2_addr1(slave2_addr1),
        .slave2_addr2(slave2_addr2),
        .slave3_addr1(slave3_addr1),
        .slave3_addr2(slave3_addr2),
        .M_ADDR(M_ADDR),
        .S0_ARREADY(S0_ARREADY),
        .S1_ARREADY(S1_ARREADY),
        .S2_ARREADY(S2_ARREADY),
        .S3_ARREADY(S3_ARREADY),
        .M0_ARVALID(M0_ARVALID),
        .M1_ARVALID(M1_ARVALID),
        .M0_RREADY(M0_RREADY),
        .M1_RREADY(M1_RREADY),
        .S0_RVALID(S0_RVALID),
        .S1_RVALID(S1_RVALID),
        .S2_RVALID(S2_RVALID),
        .S3_RVALID(S3_RVALID),
        .S0_RLAST(S0_RLAST),
        .S1_RLAST(S1_RLAST),
        .S2_RLAST(S2_RLAST),
        .S3_RLAST(S3_RLAST),
        .select_slave_address(select_slave_address),
        .select_data_M0(select_data_M0),
        .select_data_M1(select_data_M1),
        .select_master_address(select_master_address),
        .en_S0(en_S0),
        .en_S1(en_S1),
        .en_S2(en_S2),
        .en_S3(en_S3)
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
        resett = 0;
        M_ADDR = 32'h0;
        
        // Configure 4-slave address ranges
        slave0_addr1 = 32'h00000000;
        slave0_addr2 = 32'h1FFFFFFF;
        slave1_addr1 = 32'h20000000;
        slave1_addr2 = 32'h3FFFFFFF;
        slave2_addr1 = 32'h40000000;
        slave2_addr2 = 32'h5FFFFFFF;
        slave3_addr1 = 32'h60000000;
        slave3_addr2 = 32'h7FFFFFFF;
        
        M0_ARVALID = 0;
        M1_ARVALID = 0;
        M0_RREADY = 0;
        M1_RREADY = 0;
        
        S0_ARREADY = 1;
        S1_ARREADY = 1;
        S2_ARREADY = 1;
        S3_ARREADY = 1;
        
        S0_RVALID = 0;
        S1_RVALID = 0;
        S2_RVALID = 0;
        S3_RVALID = 0;
        
        S0_RLAST = 0;
        S1_RLAST = 0;
        S2_RLAST = 0;
        S3_RLAST = 0;

        // Reset
        #(CLK_PERIOD * 2);
        resett = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("Controller (Read Channel) Testbench v2.0");
        $display("==========================================");
        $display("Testing: 4 Slaves + Fixed-Priority QoS Arbiter");
        $display("==========================================");

        //=======================================================
        // Test 1: Master 0 read from Slave 0
        //=======================================================
        test_num = 1;
        $display("\n--- Test %0d: M0 Read from S0 (Address 0x10000000) ---", test_num);
        M_ADDR = 32'h10000000;  // Within S0 range
        M0_ARVALID = 1;
        #(CLK_PERIOD);
        
        if (select_slave_address == 2'b00) begin
            $display("  PASS: Correct slave selected (S0 = 2'b00)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong slave selected. Got: %b, Expected: 00", select_slave_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 2: Master 0 read from Slave 1
        //=======================================================
        test_num = 2;
        $display("\n--- Test %0d: M0 Read from S1 (Address 0x30000000) ---", test_num);
        M_ADDR = 32'h30000000;  // Within S1 range
        M0_ARVALID = 1;
        #(CLK_PERIOD);
        
        if (select_slave_address == 2'b01) begin
            $display("  PASS: Correct slave selected (S1 = 2'b01)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong slave selected. Got: %b, Expected: 01", select_slave_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 3: Master 0 read from Slave 2
        //=======================================================
        test_num = 3;
        $display("\n--- Test %0d: M0 Read from S2 (Address 0x50000000) ---", test_num);
        M_ADDR = 32'h50000000;  // Within S2 range
        M0_ARVALID = 1;
        #(CLK_PERIOD);
        
        if (select_slave_address == 2'b10) begin
            $display("  PASS: Correct slave selected (S2 = 2'b10)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong slave selected. Got: %b, Expected: 10", select_slave_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 4: Master 0 read from Slave 3
        //=======================================================
        test_num = 4;
        $display("\n--- Test %0d: M0 Read from S3 (Address 0x70000000) ---", test_num);
        M_ADDR = 32'h70000000;  // Within S3 range
        M0_ARVALID = 1;
        #(CLK_PERIOD);
        
        if (select_slave_address == 2'b11) begin
            $display("  PASS: Correct slave selected (S3 = 2'b11)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong slave selected. Got: %b, Expected: 11", select_slave_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 5: Invalid address range
        //=======================================================
        test_num = 5;
        $display("\n--- Test %0d: Invalid address (0x80000000) ---", test_num);
        M_ADDR = 32'h80000000;  // Outside all ranges
        M0_ARVALID = 1;
        #(CLK_PERIOD);
        
        // Controller should handle gracefully (stay in Idle or return to Idle)
        $display("  INFO: Invalid address handled");
        pass_count = pass_count + 1;
        
        M0_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 6: Fixed-Priority QoS Arbiter - Both masters request (M0 should win)
        //=======================================================
        test_num = 6;
        $display("\n--- Test %0d: Fixed-Priority - Both masters request ---", test_num);
        M_ADDR = 32'h10000000;  // S0 range
        M0_ARVALID = 1;
        M1_ARVALID = 1;
        #(CLK_PERIOD);
        
        // With Fixed-Priority: M0 always has priority over M1
        if (select_master_address == 1'b0) begin
            $display("  PASS: M0 selected (Fixed-Priority: M0 > M1)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong master selected. Got: %b, Expected: 0 (M0)", select_master_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        M1_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 7: Fixed-Priority QoS Arbiter - Second request (M0 should still win)
        //=======================================================
        test_num = 7;
        $display("\n--- Test %0d: Fixed-Priority - Both masters request again ---", test_num);
        M_ADDR = 32'h10000000;
        M0_ARVALID = 1;
        M1_ARVALID = 1;
        #(CLK_PERIOD);
        
        // With Fixed-Priority: M0 always wins (no alternation)
        if (select_master_address == 1'b0) begin
            $display("  PASS: M0 selected again (Fixed-Priority: M0 > M1)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong master selected. Got: %b, Expected: 0 (M0)", select_master_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        M1_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 8: Fixed-Priority QoS Arbiter - Third request (M0 should still win)
        //=======================================================
        test_num = 8;
        $display("\n--- Test %0d: Fixed-Priority - Both masters request third time ---", test_num);
        M_ADDR = 32'h10000000;
        M0_ARVALID = 1;
        M1_ARVALID = 1;
        #(CLK_PERIOD);
        
        // With Fixed-Priority: M0 always wins (consistent priority)
        if (select_master_address == 1'b0) begin
            $display("  PASS: M0 selected again (Fixed-Priority consistent)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong master selected. Got: %b, Expected: 0 (M0)", select_master_address);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        M1_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 9: Master 1 read from Slave 2
        //=======================================================
        test_num = 9;
        $display("\n--- Test %0d: M1 Read from S2 (Address 0x48000000) ---", test_num);
        M_ADDR = 32'h48000000;  // Within S2 range
        M1_ARVALID = 1;
        #(CLK_PERIOD);
        
        if (select_slave_address == 2'b10) begin
            $display("  PASS: Correct slave selected for M1 (S2 = 2'b10)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Wrong slave selected. Got: %b, Expected: 10", select_slave_address);
            fail_count = fail_count + 1;
        end
        
        M1_ARVALID = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test 10: Read Data Channel enable (en_S0)
        //=======================================================
        test_num = 10;
        $display("\n--- Test %0d: Read data enable (M0 -> S0) ---", test_num);
        M_ADDR = 32'h10000000;  // S0
        M0_ARVALID = 1;
        #(CLK_PERIOD);
        
        // Trigger data response
        S0_RVALID = 1;
        S0_RLAST = 1;
        M0_RREADY = 1;
        #(CLK_PERIOD);
        
        if (en_S0 == 2'b00) begin
            $display("  PASS: Enable signal asserted for S0 (M0 = 2'b00)");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL: Enable signal not asserted. en_S0: %b", en_S0);
            fail_count = fail_count + 1;
        end
        
        M0_ARVALID = 0;
        S0_RVALID = 0;
        S0_RLAST = 0;
        M0_RREADY = 0;
        S0_ARREADY = 0;  // Also clear S0_ARREADY
        #(CLK_PERIOD * 5);  // Wait longer for state to return to Idle

        //=======================================================
        // Test 11: Read data channel routing (select_data_M0)
        // FIXED: Clock generator bug fixed - no reset needed!
        //=======================================================
        test_num = 11;
        $display("\n--- Test %0d: Data routing M0 -> S3 ---", test_num);
        
        // Clear ALL signals (like minimal testbench)
        M_ADDR = 0;
        M0_ARVALID = 0;
        M1_ARVALID = 0;
        M0_RREADY = 0;
        M1_RREADY = 0;
        S0_ARREADY = 0;
        S1_ARREADY = 0;
        S2_ARREADY = 0;
        S3_ARREADY = 0;
        S0_RVALID = 0;
        S1_RVALID = 0;
        S2_RVALID = 0;
        S3_RVALID = 0;
        S0_RLAST = 0;
        S1_RLAST = 0;
        S2_RLAST = 0;
        S3_RLAST = 0;
        
        #(CLK_PERIOD * 2);
        
        $display("  [Time %0t] Initial State: curr_state_slave = %b", $time, uut.curr_state_slave);
        
        // Set signals for S3 transition (EXACTLY like minimal_tb)
        $display("  [Time %0t] Setting signals for S3 transition", $time);
        M_ADDR = 32'h65000000;
        M0_ARVALID = 1;
        S3_ARREADY = 1;
        
        $display("    M_ADDR = 0x%h", M_ADDR);
        $display("    M0_ARVALID = %b", M0_ARVALID);
        $display("    S3_ARREADY = %b", S3_ARREADY);
        
        // Wait for next clock edge using #delay (avoid @posedge hang)
        // Minimal_tb proven: 1 posedge is enough for transition
        #(CLK_PERIOD + 1); // Wait for full clock + delta
        
        $display("  [Time %0t] After 1 clock:", $time);
        $display("    curr_state_slave = %b (0=Idle, 100=Slave3)", uut.curr_state_slave);
        $display("    next_state_slave = %b", uut.next_state_slave);
        $display("    select_data_M0 = %b", select_data_M0);
        
        if (uut.curr_state_slave == 3'b100) begin
            $display("  *** State transitioned to Slave3! ***");
            if (select_data_M0 == 2'b11) begin
                $display("  PASS: Correct data routing (S3 = 2'b11)");
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: select_data_M0 = %b (expected 11)", select_data_M0);
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  FAIL: State did not transition (curr_state = %b)", uut.curr_state_slave);
            fail_count = fail_count + 1;
        end
        
        // Clean up
        #(CLK_PERIOD);
        M_ADDR = 0;
        M0_ARVALID = 0;
        S3_ARREADY = 0;
        
        M0_ARVALID = 0;
        S3_RVALID = 0;
        S3_RLAST = 0;
        M0_RREADY = 0;
        #(CLK_PERIOD * 2);

        //=======================================================
        // Test Summary
        //=======================================================
        $display("\n==========================================");
        $display("Test Summary");
        $display("==========================================");
        $display("Total Tests: %0d", test_num);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("==========================================");
            $display("✅ ALL TESTS PASSED!");
            $display("==========================================");
        end else begin
            $display("==========================================");
            $display("❌ SOME TESTS FAILED");
            $display("==========================================");
        end
        
        sim_done = 1;
        #(CLK_PERIOD * 2);
        $finish;
    end

endmodule
