`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Resp_Channel_Dec_tb
// Description: Testbench for Write Response Channel Decoder
//              Tests response routing based on BID (Master ID)
//
// Test Cases:
//   1. Route response to Master 0
//   2. Route response to Master 1
//   3. BID matching
//////////////////////////////////////////////////////////////////////////////////

module Write_Resp_Channel_Dec_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Num_Of_Masters = 2;
    parameter Master_ID_Width = $clog2(Num_Of_Masters);

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg [Master_ID_Width-1:0] Sel_Resp_ID;
    reg Sel_Valid;
    reg [1:0] Sel_Write_Resp;
    
    wire S00_AXI_bvalid;
    wire S01_AXI_bvalid;
    wire [1:0] S00_AXI_bresp;
    wire [1:0] S01_AXI_bresp;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_num;
    integer pass_count;
    integer fail_count;
    reg sim_done;

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Write_Resp_Channel_Dec #(
        .Num_Of_Masters(Num_Of_Masters),
        .Master_ID_Width(Master_ID_Width)
    ) uut (
        .Sel_Resp_ID(Sel_Resp_ID),
        .Sel_Valid(Sel_Valid),
        .Sel_Write_Resp(Sel_Write_Resp),
        .S00_AXI_bvalid(S00_AXI_bvalid),
        .S01_AXI_bvalid(S01_AXI_bvalid),
        .S00_AXI_bresp(S00_AXI_bresp),
        .S01_AXI_bresp(S01_AXI_bresp)
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
        Sel_Resp_ID = 0;
        Sel_Valid = 0;
        Sel_Write_Resp = 2'b00;

        #(CLK_PERIOD);

        $display("==========================================");
        $display("Write_Resp_Channel_Dec Testbench");
        $display("==========================================");

        // Test 1: Route to Master 0 (ID = 0)
        test_num = 1;
        $display("\n--- Test %0d: Route Response to Master 0 ---", test_num);
        Sel_Resp_ID = 0;  // M1_ID = 0
        Sel_Valid = 1;
        Sel_Write_Resp = 2'b00;  // OKAY
        
        #(CLK_PERIOD);
        if (S00_AXI_bvalid && !S01_AXI_bvalid && S00_AXI_bresp == 2'b00) begin
            $display("PASS: Response routed to Master 0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Response not routed correctly to Master 0");
            fail_count = fail_count + 1;
        end
        
        Sel_Valid = 0;
        #(CLK_PERIOD);

        // Test 2: Route to Master 1 (ID = 1)
        test_num = 2;
        $display("\n--- Test %0d: Route Response to Master 1 ---", test_num);
        Sel_Resp_ID = 1;  // M2_ID = 1
        Sel_Valid = 1;
        Sel_Write_Resp = 2'b01;  // EXOKAY
        
        #(CLK_PERIOD);
        if (S01_AXI_bvalid && !S00_AXI_bvalid && S01_AXI_bresp == 2'b01) begin
            $display("PASS: Response routed to Master 1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Response not routed correctly to Master 1");
            fail_count = fail_count + 1;
        end
        
        Sel_Valid = 0;
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

