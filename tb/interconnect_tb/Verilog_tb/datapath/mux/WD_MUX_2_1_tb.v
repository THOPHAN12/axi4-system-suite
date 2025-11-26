`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: WD_MUX_2_1_tb
// Description: Testbench for Write Data Channel 2-to-1 Multiplexer
//              Tests write data signal multiplexing
//
// Test Cases:
//   1. Select Master 0 write data
//   2. Select Master 1 write data
//   3. Data integrity verification
//////////////////////////////////////////////////////////////////////////////////

module WD_MUX_2_1_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Write_data_bus_width = 32;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg [1:0] Selected_Slave;  // Master selection
    
    // Master 0 inputs
    reg [Write_data_bus_width-1:0] S00_AXI_wdata;
    reg [3:0] S00_AXI_wstrb;
    reg S00_AXI_wlast;
    reg S00_AXI_wvalid;
    
    // Master 1 inputs
    reg [Write_data_bus_width-1:0] S01_AXI_wdata;
    reg [3:0] S01_AXI_wstrb;
    reg S01_AXI_wlast;
    reg S01_AXI_wvalid;
    
    // Selected output
    wire [Write_data_bus_width-1:0] Sel_S_AXI_wdata;
    wire [3:0] Sel_S_AXI_wstrb;
    wire Sel_S_AXI_wlast;
    wire Sel_S_AXI_wvalid;

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
    WD_MUX_2_1 uut (
        .Selected_Slave(Selected_Slave),
        .S00_AXI_wdata(S00_AXI_wdata),
        .S00_AXI_wstrb(S00_AXI_wstrb),
        .S00_AXI_wlast(S00_AXI_wlast),
        .S00_AXI_wvalid(S00_AXI_wvalid),
        .S01_AXI_wdata(S01_AXI_wdata),
        .S01_AXI_wstrb(S01_AXI_wstrb),
        .S01_AXI_wlast(S01_AXI_wlast),
        .S01_AXI_wvalid(S01_AXI_wvalid),
        .Sel_S_AXI_wdata(Sel_S_AXI_wdata),
        .Sel_S_AXI_wstrb(Sel_S_AXI_wstrb),
        .Sel_S_AXI_wlast(Sel_S_AXI_wlast),
        .Sel_S_AXI_wvalid(Sel_S_AXI_wvalid)
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
        Selected_Slave = 0;
        S00_AXI_wdata = 32'hAAAAAAAA;
        S00_AXI_wstrb = 4'hF;
        S00_AXI_wlast = 0;
        S00_AXI_wvalid = 1;
        
        S01_AXI_wdata = 32'hBBBBBBBB;
        S01_AXI_wstrb = 4'h0;
        S01_AXI_wlast = 1;
        S01_AXI_wvalid = 1;

        #(CLK_PERIOD);

        $display("==========================================");
        $display("WD_MUX_2_1 Testbench");
        $display("==========================================");

        // Test 1: Select Master 0
        test_num = 1;
        $display("\n--- Test %0d: Select Master 0 Write Data ---", test_num);
        Selected_Slave = 0;
        #(CLK_PERIOD);
        
        if (Sel_S_AXI_wdata == S00_AXI_wdata &&
            Sel_S_AXI_wstrb == S00_AXI_wstrb &&
            Sel_S_AXI_wlast == S00_AXI_wlast &&
            Sel_S_AXI_wvalid == S00_AXI_wvalid) begin
            $display("PASS: Master 0 write data selected correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Master 0 write data not selected correctly");
            fail_count = fail_count + 1;
        end

        // Test 2: Select Master 1
        test_num = 2;
        $display("\n--- Test %0d: Select Master 1 Write Data ---", test_num);
        Selected_Slave = 1;
        #(CLK_PERIOD);
        
        if (Sel_S_AXI_wdata == S01_AXI_wdata &&
            Sel_S_AXI_wstrb == S01_AXI_wstrb &&
            Sel_S_AXI_wlast == S01_AXI_wlast &&
            Sel_S_AXI_wvalid == S01_AXI_wvalid) begin
            $display("PASS: Master 1 write data selected correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Master 1 write data not selected correctly");
            fail_count = fail_count + 1;
        end

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

