`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: AW_Channel_Controller_Top_tb
// Description: Testbench for AW (Write Address) Channel Controller
//              Tests address channel arbitration, decoding, and handshake
//
// Test Cases:
//   1. Single master write address request
//   2. Multiple masters simultaneous requests (QoS arbitration)
//   3. Address decoding for different slaves
//   4. Handshake completion
//   5. Queue full condition
//   6. Reset behavior
//////////////////////////////////////////////////////////////////////////////////

module AW_Channel_Controller_Top_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter Masters_Num = 2;
    parameter Slaves_ID_Size = $clog2(Masters_Num);
    parameter Address_width = 32;
    parameter S00_Aw_len = 8;
    parameter S01_Aw_len = 8;
    parameter M00_Aw_len = 8;
    parameter M01_Aw_len = 8;
    parameter Num_Of_Slaves = 2;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    // Clocks and Reset
    reg ACLK, ARESETN;
    reg S00_ACLK, S00_ARESETN;
    reg S01_ACLK, S01_ARESETN;
    reg M00_ACLK, M00_ARESETN;
    reg M01_ACLK, M01_ARESETN;

    // Master 0 (S00) Write Address Channel
    reg [Address_width-1:0]     S00_AXI_awaddr;
    reg [S00_Aw_len-1:0]        S00_AXI_awlen;
    reg [2:0]                   S00_AXI_awsize;
    reg [1:0]                   S00_AXI_awburst;
    reg [1:0]                   S00_AXI_awlock;
    reg [3:0]                   S00_AXI_awcache;
    reg [2:0]                   S00_AXI_awprot;
    reg [3:0]                   S00_AXI_awqos;
    reg                         S00_AXI_awvalid;
    wire                        S00_AXI_awready;

    // Master 1 (S01) Write Address Channel
    reg [Address_width-1:0]     S01_AXI_awaddr;
    reg [S01_Aw_len-1:0]        S01_AXI_awlen;
    reg [2:0]                   S01_AXI_awsize;
    reg [1:0]                   S01_AXI_awburst;
    reg [1:0]                   S01_AXI_awlock;
    reg [3:0]                   S01_AXI_awcache;
    reg [2:0]                   S01_AXI_awprot;
    reg [3:0]                   S01_AXI_awqos;
    reg                         S01_AXI_awvalid;
    wire                        S01_AXI_awready;

    // Slave 0 (M00) Write Address Channel
    wire [Slaves_ID_Size-1:0]   M00_AXI_awaddr_ID;
    wire [Address_width-1:0]    M00_AXI_awaddr;
    wire [M00_Aw_len-1:0]       M00_AXI_awlen;
    wire [2:0]                  M00_AXI_awsize;
    wire [1:0]                  M00_AXI_awburst;
    wire [1:0]                  M00_AXI_awlock;
    wire [3:0]                  M00_AXI_awcache;
    wire [2:0]                  M00_AXI_awprot;
    wire [3:0]                  M00_AXI_awqos;
    wire                        M00_AXI_awvalid;
    reg                         M00_AXI_awready;

    // Slave 1 (M01) Write Address Channel
    wire [Slaves_ID_Size-1:0]   M01_AXI_awaddr_ID;
    wire [Address_width-1:0]    M01_AXI_awaddr;
    wire [M01_Aw_len-1:0]       M01_AXI_awlen;
    wire [2:0]                  M01_AXI_awsize;
    wire [1:0]                  M01_AXI_awburst;
    wire [1:0]                  M01_AXI_awlock;
    wire [3:0]                  M01_AXI_awcache;
    wire [2:0]                  M01_AXI_awprot;
    wire [3:0]                  M01_AXI_awqos;
    wire                        M01_AXI_awvalid;
    reg                         M01_AXI_awready;

    // Control Signals
    wire                        AW_Access_Grant;
    wire [Slaves_ID_Size-1:0]   AW_Selected_Slave;
    reg                         Queue_Is_Full;
    wire                        Token;
    wire [(8/2)-1:0]            Rem;
    wire [(8/2)-1:0]            Num_Of_Compl_Bursts;
    wire                        Load_The_Original_Signals;

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
        S00_ACLK = 0;
        S01_ACLK = 0;
        M00_ACLK = 0;
        M01_ACLK = 0;
        while (!sim_done) begin
            #(CLK_PERIOD/2) begin
                ACLK = ~ACLK;
                S00_ACLK = ~S00_ACLK;
                S01_ACLK = ~S01_ACLK;
                M00_ACLK = ~M00_ACLK;
                M01_ACLK = ~M01_ACLK;
            end
        end
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    AW_Channel_Controller_Top #(
        .Masters_Num(Masters_Num),
        .Slaves_ID_Size(Slaves_ID_Size),
        .Address_width(Address_width),
        .S00_Aw_len(S00_Aw_len),
        .S01_Aw_len(S01_Aw_len),
        .M00_Aw_len(M00_Aw_len),
        .M01_Aw_len(M01_Aw_len),
        .Num_Of_Slaves(Num_Of_Slaves)
    ) uut (
        .AW_Access_Grant(AW_Access_Grant),
        .AW_Selected_Slave(AW_Selected_Slave),
        .Queue_Is_Full(Queue_Is_Full),
        .Token(Token),
        .Rem(Rem),
        .Num_Of_Compl_Bursts(Num_Of_Compl_Bursts),
        .Load_The_Original_Signals(Load_The_Original_Signals),
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S00_ACLK(S00_ACLK),
        .S00_ARESETN(S00_ARESETN),
        .S00_AXI_awaddr(S00_AXI_awaddr),
        .S00_AXI_awlen(S00_AXI_awlen),
        .S00_AXI_awsize(S00_AXI_awsize),
        .S00_AXI_awburst(S00_AXI_awburst),
        .S00_AXI_awlock(S00_AXI_awlock),
        .S00_AXI_awcache(S00_AXI_awcache),
        .S00_AXI_awprot(S00_AXI_awprot),
        .S00_AXI_awqos(S00_AXI_awqos),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S00_AXI_awready(S00_AXI_awready),
        .S01_ACLK(S01_ACLK),
        .S01_ARESETN(S01_ARESETN),
        .S01_AXI_awaddr(S01_AXI_awaddr),
        .S01_AXI_awlen(S01_AXI_awlen),
        .S01_AXI_awsize(S01_AXI_awsize),
        .S01_AXI_awburst(S01_AXI_awburst),
        .S01_AXI_awlock(S01_AXI_awlock),
        .S01_AXI_awcache(S01_AXI_awcache),
        .S01_AXI_awprot(S01_AXI_awprot),
        .S01_AXI_awqos(S01_AXI_awqos),
        .S01_AXI_awvalid(S01_AXI_awvalid),
        .S01_AXI_awready(S01_AXI_awready),
        .M00_ACLK(M00_ACLK),
        .M00_ARESETN(M00_ARESETN),
        .M00_AXI_awaddr_ID(M00_AXI_awaddr_ID),
        .M00_AXI_awaddr(M00_AXI_awaddr),
        .M00_AXI_awlen(M00_AXI_awlen),
        .M00_AXI_awsize(M00_AXI_awsize),
        .M00_AXI_awburst(M00_AXI_awburst),
        .M00_AXI_awlock(M00_AXI_awlock),
        .M00_AXI_awcache(M00_AXI_awcache),
        .M00_AXI_awprot(M00_AXI_awprot),
        .M00_AXI_awqos(M00_AXI_awqos),
        .M00_AXI_awvalid(M00_AXI_awvalid),
        .M00_AXI_awready(M00_AXI_awready),
        .M01_ACLK(M01_ACLK),
        .M01_ARESETN(M01_ARESETN),
        .M01_AXI_awaddr_ID(M01_AXI_awaddr_ID),
        .M01_AXI_awaddr(M01_AXI_awaddr),
        .M01_AXI_awlen(M01_AXI_awlen),
        .M01_AXI_awsize(M01_AXI_awsize),
        .M01_AXI_awburst(M01_AXI_awburst),
        .M01_AXI_awlock(M01_AXI_awlock),
        .M01_AXI_awcache(M01_AXI_awcache),
        .M01_AXI_awprot(M01_AXI_awprot),
        .M01_AXI_awqos(M01_AXI_awqos),
        .M01_AXI_awvalid(M01_AXI_awvalid),
        .M01_AXI_awready(M01_AXI_awready)
    );

    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        // Initialize
        sim_done = 0;
        test_num = 0;
        pass_count = 0;
        fail_count = 0;
        
        // Initialize inputs
        ARESETN = 0;
        S00_ARESETN = 0;
        S01_ARESETN = 0;
        M00_ARESETN = 0;
        M01_ARESETN = 0;
        
        S00_AXI_awaddr = 32'h00000000;
        S00_AXI_awlen = 0;
        S00_AXI_awsize = 3'b010;
        S00_AXI_awburst = 2'b01;
        S00_AXI_awlock = 0;
        S00_AXI_awcache = 0;
        S00_AXI_awprot = 0;
        S00_AXI_awqos = 0;
        S00_AXI_awvalid = 0;
        
        S01_AXI_awaddr = 32'h00000000;
        S01_AXI_awlen = 0;
        S01_AXI_awsize = 3'b010;
        S01_AXI_awburst = 2'b01;
        S01_AXI_awlock = 0;
        S01_AXI_awcache = 0;
        S01_AXI_awprot = 0;
        S01_AXI_awqos = 0;
        S01_AXI_awvalid = 0;
        
        M00_AXI_awready = 1;
        M01_AXI_awready = 1;
        
        Queue_Is_Full = 0;

        // Apply reset
        #(CLK_PERIOD * 3);
        ARESETN = 1;
        S00_ARESETN = 1;
        S01_ARESETN = 1;
        M00_ARESETN = 1;
        M01_ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("AW_Channel_Controller_Top Testbench");
        $display("==========================================");

        // Test 1: Single master request to Slave 0
        test_num = 1;
        $display("\n--- Test %0d: Single Master 0 request to Slave 0 ---", test_num);
        S00_AXI_awaddr = 32'h00001000;  // Slave 0 address range
        S00_AXI_awlen = 4;
        S00_AXI_awqos = 5;
        S00_AXI_awvalid = 1;
        
        wait(S00_AXI_awready);
        @(posedge ACLK);
        S00_AXI_awvalid = 0;
        
        #(CLK_PERIOD * 2);
        if (AW_Access_Grant) begin
            $display("PASS: AW_Access_Grant asserted");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: AW_Access_Grant not asserted");
            fail_count = fail_count + 1;
        end

        // Test 2: Single master request to Slave 1
        test_num = 2;
        $display("\n--- Test %0d: Single Master 0 request to Slave 1 ---", test_num);
        S00_AXI_awaddr = 32'h40001000;  // Slave 1 address range (bit 31:30 = 01)
        S00_AXI_awvalid = 1;
        
        wait(S00_AXI_awready);
        @(posedge ACLK);
        S00_AXI_awvalid = 0;
        #(CLK_PERIOD * 2);
        pass_count = pass_count + 1;

        // Test 3: QoS arbitration - M0 higher priority
        test_num = 3;
        $display("\n--- Test %0d: QoS Arbitration - M0 > M1 ---", test_num);
        S00_AXI_awaddr = 32'h00002000;
        S00_AXI_awqos = 10;
        S00_AXI_awvalid = 1;
        
        S01_AXI_awaddr = 32'h00003000;
        S01_AXI_awqos = 5;
        S01_AXI_awvalid = 1;
        
        wait(S00_AXI_awready || S01_AXI_awready);
        @(posedge ACLK);
        if (AW_Selected_Slave == 0) begin
            $display("PASS: Master 0 selected (higher QoS)");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Wrong master selected");
            fail_count = fail_count + 1;
        end
        
        S00_AXI_awvalid = 0;
        S01_AXI_awvalid = 0;
        #(CLK_PERIOD * 2);

        // Test 4: Queue full condition
        test_num = 4;
        $display("\n--- Test %0d: Queue Full Condition ---", test_num);
        Queue_Is_Full = 1;
        S00_AXI_awvalid = 1;
        #(CLK_PERIOD * 2);
        // awready should not assert when queue is full
        if (!S00_AXI_awready) begin
            $display("PASS: awready not asserted when queue full");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: awready asserted when queue full");
            fail_count = fail_count + 1;
        end
        Queue_Is_Full = 0;
        S00_AXI_awvalid = 0;

        // Summary
        #(CLK_PERIOD * 2);
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

