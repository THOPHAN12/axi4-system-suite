`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Addr_Channel_Dec_tb
// Description: Testbench for Write Address Channel Decoder
//              Tests address decoding to select correct slave
//
// Test Cases:
//   1. Decode address to Slave 0
//   2. Decode address to Slave 1
//   3. Different address ranges
//////////////////////////////////////////////////////////////////////////////////

module Write_Addr_Channel_Dec_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Address_width = 32;
    parameter Base_Addr_Width = 2;
    parameter Slaves_Num = 2;
    parameter Slaves_ID_Size = $clog2(Slaves_Num);
    parameter S00_Aw_len = 8;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg [Address_width-1:0] Master_AXI_awaddr;
    reg [Slaves_ID_Size-1:0] Master_AXI_awaddr_ID;
    reg [S00_Aw_len-1:0] Master_AXI_awlen;
    reg [2:0] Master_AXI_awsize;
    reg [1:0] Master_AXI_awburst;
    reg [1:0] Master_AXI_awlock;
    reg [3:0] Master_AXI_awcache;
    reg [2:0] Master_AXI_awprot;
    reg [3:0] Master_AXI_awqos;
    reg Master_AXI_awvalid;
    wire Master_AXI_awready;

    // Slave 0 outputs
    wire [Address_width-1:0] M00_AXI_awaddr;
    wire [S00_Aw_len-1:0] M00_AXI_awlen;
    wire [2:0] M00_AXI_awsize;
    wire [1:0] M00_AXI_awburst;
    wire [1:0] M00_AXI_awlock;
    wire [3:0] M00_AXI_awcache;
    wire [2:0] M00_AXI_awprot;
    wire [3:0] M00_AXI_awqos;
    wire M00_AXI_awvalid;
    reg M00_AXI_awready;
    wire [Slaves_ID_Size-1:0] M00_AXI_awaddr_ID;

    // Slave 1 outputs
    wire [Address_width-1:0] M01_AXI_awaddr;
    wire [S00_Aw_len-1:0] M01_AXI_awlen;
    wire [2:0] M01_AXI_awsize;
    wire [1:0] M01_AXI_awburst;
    wire [1:0] M01_AXI_awlock;
    wire [3:0] M01_AXI_awcache;
    wire [2:0] M01_AXI_awprot;
    wire [3:0] M01_AXI_awqos;
    wire M01_AXI_awvalid;
    reg M01_AXI_awready;
    wire [Slaves_ID_Size-1:0] M01_AXI_awaddr_ID;

    wire [Slaves_Num-1:0] Q_Enables;
    wire Sel_Slave_Ready;

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
    reg ACLK;
    initial begin
        ACLK = 0;
        while (!sim_done) begin
            #(CLK_PERIOD/2) ACLK = ~ACLK;
        end
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Write_Addr_Channel_Dec #(
        .Address_width(Address_width),
        .Base_Addr_Width(Base_Addr_Width),
        .Slaves_Num(Slaves_Num),
        .Slaves_ID_Size(Slaves_ID_Size),
        .S00_Aw_len(S00_Aw_len)
    ) uut (
        .Master_AXI_awaddr(Master_AXI_awaddr),
        .Master_AXI_awaddr_ID(Master_AXI_awaddr_ID),
        .Master_AXI_awlen(Master_AXI_awlen),
        .Master_AXI_awsize(Master_AXI_awsize),
        .Master_AXI_awburst(Master_AXI_awburst),
        .Master_AXI_awlock(Master_AXI_awlock),
        .Master_AXI_awcache(Master_AXI_awcache),
        .Master_AXI_awprot(Master_AXI_awprot),
        .Master_AXI_awqos(Master_AXI_awqos),
        .Master_AXI_awvalid(Master_AXI_awvalid),
        .Master_AXI_awready(Master_AXI_awready),
        .M00_AXI_awaddr(M00_AXI_awaddr),
        .M00_AXI_awaddr_ID(M00_AXI_awaddr_ID),
        .M00_AXI_awlen(M00_AXI_awlen),
        .M00_AXI_awsize(M00_AXI_awsize),
        .M00_AXI_awburst(M00_AXI_awburst),
        .M00_AXI_awlock(M00_AXI_awlock),
        .M00_AXI_awcache(M00_AXI_awcache),
        .M00_AXI_awprot(M00_AXI_awprot),
        .M00_AXI_awqos(M00_AXI_awqos),
        .M00_AXI_awvalid(M00_AXI_awvalid),
        .M00_AXI_awready(M00_AXI_awready),
        .M01_AXI_awaddr(M01_AXI_awaddr),
        .M01_AXI_awaddr_ID(M01_AXI_awaddr_ID),
        .M01_AXI_awlen(M01_AXI_awlen),
        .M01_AXI_awsize(M01_AXI_awsize),
        .M01_AXI_awburst(M01_AXI_awburst),
        .M01_AXI_awlock(M01_AXI_awlock),
        .M01_AXI_awcache(M01_AXI_awcache),
        .M01_AXI_awprot(M01_AXI_awprot),
        .M01_AXI_awqos(M01_AXI_awqos),
        .M01_AXI_awvalid(M01_AXI_awvalid),
        .M01_AXI_awready(M01_AXI_awready),
        .Q_Enables(Q_Enables),
        .Sel_Slave_Ready(Sel_Slave_Ready)
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
        Master_AXI_awaddr = 0;
        Master_AXI_awaddr_ID = 0;
        Master_AXI_awlen = 0;
        Master_AXI_awsize = 3'b010;
        Master_AXI_awburst = 2'b01;
        Master_AXI_awlock = 0;
        Master_AXI_awcache = 0;
        Master_AXI_awprot = 0;
        Master_AXI_awqos = 0;
        Master_AXI_awvalid = 0;
        
        M00_AXI_awready = 1;
        M01_AXI_awready = 1;

        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("Write_Addr_Channel_Dec Testbench");
        $display("==========================================");

        // Test 1: Decode to Slave 0 (address bit[31:30] = 00)
        test_num = 1;
        $display("\n--- Test %0d: Decode to Slave 0 ---", test_num);
        Master_AXI_awaddr = 32'h00001000;  // Bits [31:30] = 00
        Master_AXI_awaddr_ID = 0;
        Master_AXI_awvalid = 1;
        
        #(CLK_PERIOD);
        if (M00_AXI_awvalid && !M01_AXI_awvalid && Q_Enables[0]) begin
            $display("PASS: Address decoded to Slave 0");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Address not decoded correctly to Slave 0");
            fail_count = fail_count + 1;
        end
        
        Master_AXI_awvalid = 0;
        #(CLK_PERIOD);

        // Test 2: Decode to Slave 1 (address bit[31:30] = 01)
        test_num = 2;
        $display("\n--- Test %0d: Decode to Slave 1 ---", test_num);
        Master_AXI_awaddr = 32'h40001000;  // Bits [31:30] = 01
        Master_AXI_awvalid = 1;
        
        #(CLK_PERIOD);
        if (M01_AXI_awvalid && !M00_AXI_awvalid && Q_Enables[1]) begin
            $display("PASS: Address decoded to Slave 1");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Address not decoded correctly to Slave 1");
            fail_count = fail_count + 1;
        end
        
        Master_AXI_awvalid = 0;
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

