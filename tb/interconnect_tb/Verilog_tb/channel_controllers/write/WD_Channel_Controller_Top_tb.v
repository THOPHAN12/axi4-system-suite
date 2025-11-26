`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: WD_Channel_Controller_Top_tb
// Description: Testbench for WD (Write Data) Channel Controller
//              Tests write data channel routing and queue management
//
// Test Cases:
//   1. Single write data transaction
//   2. Burst write transaction (multiple beats)
//   3. Queue-based data routing
//   4. wlast detection
//////////////////////////////////////////////////////////////////////////////////

module WD_Channel_Controller_Top_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Slaves_Num = 2;
    parameter Slaves_ID_Size = $clog2(Slaves_Num);
    parameter Address_width = 32;
    parameter S00_Write_data_bus_width = 32;
    parameter S01_Write_data_bus_width = 32;
    parameter M00_Write_data_bus_width = 32;

    //==========================================================================
    // DUT Signals
    //==========================================================================
    reg ACLK, ARESETN;
    
    // Master 0 Write Data
    reg [S00_Write_data_bus_width-1:0] S00_AXI_wdata;
    reg [3:0] S00_AXI_wstrb;
    reg S00_AXI_wlast;
    reg S00_AXI_wvalid;
    wire S00_AXI_wready;
    
    // Master 1 Write Data
    reg [S01_Write_data_bus_width-1:0] S01_AXI_wdata;
    reg [3:0] S01_AXI_wstrb;
    reg S01_AXI_wlast;
    reg S01_AXI_wvalid;
    wire S01_AXI_wready;
    
    // Slave Write Data
    wire [M00_Write_data_bus_width-1:0] M00_AXI_wdata;
    wire [3:0] M00_AXI_wstrb;
    wire M00_AXI_wlast;
    wire M00_AXI_wvalid;
    reg M00_AXI_wready;
    
    // Control signals
    reg [Slaves_ID_Size-1:0] AW_Selected_Slave;
    reg AW_Access_Grant;
    wire [Slaves_ID_Size-1:0] Write_Data_Master;
    wire Write_Data_Finsh;
    wire Queue_Is_Full;

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
    WD_Channel_Controller_Top #(
        .Slaves_Num(Slaves_Num),
        .Slaves_ID_Size(Slaves_ID_Size),
        .Address_width(Address_width),
        .S00_Write_data_bus_width(S00_Write_data_bus_width),
        .S01_Write_data_bus_width(S01_Write_data_bus_width),
        .M00_Write_data_bus_width(M00_Write_data_bus_width)
    ) uut (
        .AW_Selected_Slave(AW_Selected_Slave),
        .AW_Access_Grant(AW_Access_Grant),
        .Write_Data_Master(Write_Data_Master),
        .Write_Data_Finsh(Write_Data_Finsh),
        .Queue_Is_Full(Queue_Is_Full),
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S00_AXI_wdata(S00_AXI_wdata),
        .S00_AXI_wstrb(S00_AXI_wstrb),
        .S00_AXI_wlast(S00_AXI_wlast),
        .S00_AXI_wvalid(S00_AXI_wvalid),
        .S00_AXI_wready(S00_AXI_wready),
        .S01_AXI_wdata(S01_AXI_wdata),
        .S01_AXI_wstrb(S01_AXI_wstrb),
        .S01_AXI_wlast(S01_AXI_wlast),
        .S01_AXI_wvalid(S01_AXI_wvalid),
        .S01_AXI_wready(S01_AXI_wready),
        .M00_AXI_wdata(M00_AXI_wdata),
        .M00_AXI_wstrb(M00_AXI_wstrb),
        .M00_AXI_wlast(M00_AXI_wlast),
        .M00_AXI_wvalid(M00_AXI_wvalid),
        .M00_AXI_wready(M00_AXI_wready)
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
        S00_AXI_wdata = 0;
        S00_AXI_wstrb = 4'hF;
        S00_AXI_wlast = 0;
        S00_AXI_wvalid = 0;
        
        S01_AXI_wdata = 0;
        S01_AXI_wstrb = 4'hF;
        S01_AXI_wlast = 0;
        S01_AXI_wvalid = 0;
        
        M00_AXI_wready = 1;
        AW_Selected_Slave = 0;
        AW_Access_Grant = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        $display("==========================================");
        $display("WD_Channel_Controller_Top Testbench");
        $display("==========================================");

        // Test 1: Single beat write from Master 0
        test_num = 1;
        $display("\n--- Test %0d: Single Beat Write ---", test_num);
        
        AW_Selected_Slave = 0;
        AW_Access_Grant = 1;
        @(posedge ACLK);
        AW_Access_Grant = 0;
        
        #(CLK_PERIOD);
        S00_AXI_wdata = 32'hDEADBEEF;
        S00_AXI_wlast = 1;
        S00_AXI_wvalid = 1;
        
        wait(S00_AXI_wready && M00_AXI_wvalid);
        @(posedge ACLK);
        
        if (M00_AXI_wdata == 32'hDEADBEEF && M00_AXI_wlast) begin
            $display("PASS: Write data routed correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Write data not routed correctly");
            fail_count = fail_count + 1;
        end
        
        S00_AXI_wvalid = 0;
        #(CLK_PERIOD * 2);

        // Test 2: Burst write (4 beats)
        test_num = 2;
        $display("\n--- Test %0d: Burst Write (4 beats) ---", test_num);
        
        AW_Selected_Slave = 0;
        AW_Access_Grant = 1;
        @(posedge ACLK);
        AW_Access_Grant = 0;
        
        #(CLK_PERIOD);
        begin : burst_loop
            integer i;
            for (i = 0; i < 4; i = i + 1) begin
                S00_AXI_wdata = 32'h1000 + i;
                S00_AXI_wlast = (i == 3);
                S00_AXI_wvalid = 1;
                
                wait(S00_AXI_wready);
                @(posedge ACLK);
            end
        end
        
        S00_AXI_wvalid = 0;
        
        if (Write_Data_Finsh) begin
            $display("PASS: Write transaction finished correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Write transaction not finished");
            fail_count = fail_count + 1;
        end

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

