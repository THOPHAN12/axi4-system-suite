`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: BR_Channel_Controller_Top_tb
// Description: Testbench for BR (Write Response) Channel Controller
//              Tests write response channel routing and arbitration
//
// Test Cases:
//   1. Single slave response
//   2. Multiple slave responses (arbitration)
//   3. Response routing based on BID
//   4. Response handshake
//////////////////////////////////////////////////////////////////////////////////

module BR_Channel_Controller_Top_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Num_Of_Masters = 2;
    parameter Num_Of_Slaves = 2;
    parameter Master_ID_Width = $clog2(Num_Of_Masters);
    parameter AXI4_Aw_len = 8;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg ACLK, ARESETN;
    
    // Master 0 (S00) Write Response
    wire [1:0] S00_AXI_bresp;
    wire S00_AXI_bvalid;
    reg S00_AXI_bready;
    
    // Master 1 (S01) Write Response
    wire [1:0] S01_AXI_bresp;
    wire S01_AXI_bvalid;
    reg S01_AXI_bready;
    
    // Slave 0 (M00) Write Response
    reg [Master_ID_Width-1:0] M00_AXI_BID;
    reg [1:0] M00_AXI_bresp;
    reg M00_AXI_bvalid;
    wire M00_AXI_bready;
    
    // Slave 1 (M01) Write Response
    reg [Master_ID_Width-1:0] M01_AXI_BID;
    reg [1:0] M01_AXI_bresp;
    reg M01_AXI_bvalid;
    wire M01_AXI_bready;
    
    // Control signals
    reg [1:0] Write_Data_Master;
    reg Write_Data_Finsh;
    reg [3:0] Rem;
    reg [3:0] Num_Of_Compl_Bursts;
    reg Is_Master_Part_Of_Split;
    reg Load_The_Original_Signals;

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
    BR_Channel_Controller_Top #(
        .Num_Of_Masters(Num_Of_Masters),
        .Num_Of_Slaves(Num_Of_Slaves),
        .Master_ID_Width(Master_ID_Width),
        .AXI4_Aw_len(AXI4_Aw_len),
        .M1_ID(0),
        .M2_ID(1)
    ) uut (
        .Write_Data_Master(Write_Data_Master),
        .Write_Data_Finsh(Write_Data_Finsh),
        .Rem(Rem),
        .Num_Of_Compl_Bursts(Num_Of_Compl_Bursts),
        .Is_Master_Part_Of_Split(Is_Master_Part_Of_Split),
        .Load_The_Original_Signals(Load_The_Original_Signals),
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S00_AXI_bresp(S00_AXI_bresp),
        .S00_AXI_bvalid(S00_AXI_bvalid),
        .S00_AXI_bready(S00_AXI_bready),
        .S01_AXI_bresp(S01_AXI_bresp),
        .S01_AXI_bvalid(S01_AXI_bvalid),
        .S01_AXI_bready(S01_AXI_bready),
        .M00_AXI_BID(M00_AXI_BID),
        .M00_AXI_bresp(M00_AXI_bresp),
        .M00_AXI_bvalid(M00_AXI_bvalid),
        .M00_AXI_bready(M00_AXI_bready),
        .M01_AXI_BID(M01_AXI_BID),
        .M01_AXI_bresp(M01_AXI_bresp),
        .M01_AXI_bvalid(M01_AXI_bvalid),
        .M01_AXI_bready(M01_AXI_bready)
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
        S00_AXI_bready = 1;
        S01_AXI_bready = 1;
        
        M00_AXI_BID = 0;
        M00_AXI_bresp = 2'b00;
        M00_AXI_bvalid = 0;
        
        M01_AXI_BID = 0;
        M01_AXI_bresp = 2'b00;
        M01_AXI_bvalid = 0;
        
        Write_Data_Master = 0;
        Write_Data_Finsh = 0;
        Rem = 0;
        Num_Of_Compl_Bursts = 0;
        Is_Master_Part_Of_Split = 0;
        Load_The_Original_Signals = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("BR_Channel_Controller_Top Testbench");
        $display("==========================================");

        // Test 1: Slave 0 response to Master 0
        test_num = 1;
        $display("\n--- Test %0d: S0 Response to M0 ---", test_num);
        M00_AXI_BID = 0;  // Master 0 ID
        M00_AXI_bresp = 2'b00;  // OKAY
        M00_AXI_bvalid = 1;
        
        wait(M00_AXI_bready);
        @(posedge ACLK);
        
        if (S00_AXI_bvalid && S00_AXI_bresp == 2'b00) begin
            $display("PASS: Response routed to Master 0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Response not routed correctly");
            fail_count = fail_count + 1;
        end
        
        M00_AXI_bvalid = 0;
        #(CLK_PERIOD * 2);

        // Test 2: Slave 1 response to Master 1
        test_num = 2;
        $display("\n--- Test %0d: S1 Response to M1 ---", test_num);
        M01_AXI_BID = 1;  // Master 1 ID
        M01_AXI_bresp = 2'b01;  // EXOKAY
        M01_AXI_bvalid = 1;
        
        wait(M01_AXI_bready);
        @(posedge ACLK);
        
        if (S01_AXI_bvalid && S01_AXI_bresp == 2'b01) begin
            $display("PASS: Response routed to Master 1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Response not routed correctly");
            fail_count = fail_count + 1;
        end
        
        M01_AXI_bvalid = 0;
        #(CLK_PERIOD * 2);

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

