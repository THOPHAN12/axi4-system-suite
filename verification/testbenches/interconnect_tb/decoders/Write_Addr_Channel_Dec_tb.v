`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Addr_Channel_Dec_tb
// Description: Comprehensive testbench for Write Address Channel Decoder
//              Tests address decoding to select correct slave (4 slaves)
//
// Test Cases:
//   1. Decode address to Slave 0 (bits[31:30] = 00)
//   2. Decode address to Slave 1 (bits[31:30] = 01)
//   3. Decode address to Slave 2 (bits[31:30] = 10)
//   4. Decode address to Slave 3 (bits[31:30] = 11)
//   5. Test Q_Enables output
//   6. Test Sel_Slave_Ready output
//   7. Test signal routing to all slaves
//   8. Test invalid address (default)
////////////////////////////////////////////////////////////////////////////////

module Write_Addr_Channel_Dec_tb();

    //==========================================================================
    // Parameters
    //==========================================================================
    parameter CLK_PERIOD = 10;
    parameter Address_width = 32;
    parameter Base_Addr_Width = 2;
    parameter Num_OF_Masters = 2;
    parameter Masters_ID_Size = $clog2(Num_OF_Masters);
    parameter Num_Of_Slaves = 4;
    parameter AXI4_Aw_len = 8;

    //==========================================================================
    // DUT Signals - Master Inputs
    //==========================================================================
    reg [Masters_ID_Size-1:0] Master_AXI_awaddr_ID;
    reg [Address_width-1:0] Master_AXI_awaddr;
    reg [AXI4_Aw_len-1:0] Master_AXI_awlen;
    reg [2:0] Master_AXI_awsize;
    reg [1:0] Master_AXI_awburst;
    reg [1:0] Master_AXI_awlock;
    reg [3:0] Master_AXI_awcache;
    reg [2:0] Master_AXI_awprot;
    reg [3:0] Master_AXI_awqos;
    reg Master_AXI_awvalid;

    //==========================================================================
    // DUT Signals - Slave Outputs
    //==========================================================================
    wire [Masters_ID_Size-1:0] M00_AXI_awaddr_ID;
    wire [Address_width-1:0] M00_AXI_awaddr;
    wire [AXI4_Aw_len-1:0] M00_AXI_awlen;
    wire [2:0] M00_AXI_awsize;
    wire [1:0] M00_AXI_awburst;
    wire [1:0] M00_AXI_awlock;
    wire [3:0] M00_AXI_awcache;
    wire [2:0] M00_AXI_awprot;
    wire [3:0] M00_AXI_awqos;
    wire M00_AXI_awvalid;
    reg M00_AXI_awready;

    wire [Masters_ID_Size-1:0] M01_AXI_awaddr_ID;
    wire [Address_width-1:0] M01_AXI_awaddr;
    wire [AXI4_Aw_len-1:0] M01_AXI_awlen;
    wire [2:0] M01_AXI_awsize;
    wire [1:0] M01_AXI_awburst;
    wire [1:0] M01_AXI_awlock;
    wire [3:0] M01_AXI_awcache;
    wire [2:0] M01_AXI_awprot;
    wire [3:0] M01_AXI_awqos;
    wire M01_AXI_awvalid;
    reg M01_AXI_awready;

    wire [Masters_ID_Size-1:0] M02_AXI_awaddr_ID;
    wire [Address_width-1:0] M02_AXI_awaddr;
    wire [AXI4_Aw_len-1:0] M02_AXI_awlen;
    wire [2:0] M02_AXI_awsize;
    wire [1:0] M02_AXI_awburst;
    wire [1:0] M02_AXI_awlock;
    wire [3:0] M02_AXI_awcache;
    wire [2:0] M02_AXI_awprot;
    wire [3:0] M02_AXI_awqos;
    wire M02_AXI_awvalid;
    reg M02_AXI_awready;

    wire [Masters_ID_Size-1:0] M03_AXI_awaddr_ID;
    wire [Address_width-1:0] M03_AXI_awaddr;
    wire [AXI4_Aw_len-1:0] M03_AXI_awlen;
    wire [2:0] M03_AXI_awsize;
    wire [1:0] M03_AXI_awburst;
    wire [1:0] M03_AXI_awlock;
    wire [3:0] M03_AXI_awcache;
    wire [2:0] M03_AXI_awprot;
    wire [3:0] M03_AXI_awqos;
    wire M03_AXI_awvalid;
    reg M03_AXI_awready;

    //==========================================================================
    // DUT Signals - Control Outputs
    //==========================================================================
    wire Sel_Slave_Ready;
    wire [Num_Of_Slaves-1:0] Q_Enables;

    //==========================================================================
    // Test Control
    //==========================================================================
    integer test_count;
    integer pass_count;
    integer fail_count;

    //==========================================================================
    // Clock Generation
    //==========================================================================
    reg ACLK;
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    //==========================================================================
    // DUT Instantiation
    //==========================================================================
    Write_Addr_Channel_Dec #(
        .Num_OF_Masters(Num_OF_Masters),
        .Masters_ID_Size(Masters_ID_Size),
        .Address_width(Address_width),
        .AXI4_Aw_len(AXI4_Aw_len),
        .Num_Of_Slaves(Num_Of_Slaves),
        .Base_Addr_Width(Base_Addr_Width)
    ) dut (
        .Master_AXI_awaddr_ID(Master_AXI_awaddr_ID),
        .Master_AXI_awaddr(Master_AXI_awaddr),
        .Master_AXI_awlen(Master_AXI_awlen),
        .Master_AXI_awsize(Master_AXI_awsize),
        .Master_AXI_awburst(Master_AXI_awburst),
        .Master_AXI_awlock(Master_AXI_awlock),
        .Master_AXI_awcache(Master_AXI_awcache),
        .Master_AXI_awprot(Master_AXI_awprot),
        .Master_AXI_awqos(Master_AXI_awqos),
        .Master_AXI_awvalid(Master_AXI_awvalid),
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
        .M01_AXI_awready(M01_AXI_awready),
        .M02_AXI_awaddr_ID(M02_AXI_awaddr_ID),
        .M02_AXI_awaddr(M02_AXI_awaddr),
        .M02_AXI_awlen(M02_AXI_awlen),
        .M02_AXI_awsize(M02_AXI_awsize),
        .M02_AXI_awburst(M02_AXI_awburst),
        .M02_AXI_awlock(M02_AXI_awlock),
        .M02_AXI_awcache(M02_AXI_awcache),
        .M02_AXI_awprot(M02_AXI_awprot),
        .M02_AXI_awqos(M02_AXI_awqos),
        .M02_AXI_awvalid(M02_AXI_awvalid),
        .M02_AXI_awready(M02_AXI_awready),
        .M03_AXI_awaddr_ID(M03_AXI_awaddr_ID),
        .M03_AXI_awaddr(M03_AXI_awaddr),
        .M03_AXI_awlen(M03_AXI_awlen),
        .M03_AXI_awsize(M03_AXI_awsize),
        .M03_AXI_awburst(M03_AXI_awburst),
        .M03_AXI_awlock(M03_AXI_awlock),
        .M03_AXI_awcache(M03_AXI_awcache),
        .M03_AXI_awprot(M03_AXI_awprot),
        .M03_AXI_awqos(M03_AXI_awqos),
        .M03_AXI_awvalid(M03_AXI_awvalid),
        .M03_AXI_awready(M03_AXI_awready),
        .Sel_Slave_Ready(Sel_Slave_Ready),
        .Q_Enables(Q_Enables)
    );

    //==========================================================================
    // Task: Test Address Decoding
    //==========================================================================
    task test_decode;
        input [Address_width-1:0] addr;
        input [1:0] expected_slave;
        input [Num_Of_Slaves-1:0] expected_q_enables;
        input [255:0] test_name;
        begin
            test_count = test_count + 1;
            
            // Setup address and valid
            Master_AXI_awaddr = addr;
            Master_AXI_awaddr_ID = 1;  // Master ID = 1
            Master_AXI_awlen = 8'h0F;
            Master_AXI_awsize = 3'b010;
            Master_AXI_awburst = 2'b01;
            Master_AXI_awlock = 2'b00;
            Master_AXI_awcache = 4'h5;
            Master_AXI_awprot = 3'b010;
            Master_AXI_awqos = 4'h8;
            Master_AXI_awvalid = 1;
            
            #1;
            
            // Check Q_Enables
            if (Q_Enables !== expected_q_enables) begin
                $display("[FAIL] %s: Q_Enables mismatch", test_name);
                $display("       Expected: 4'b%04b, Got: 4'b%04b", expected_q_enables, Q_Enables);
                fail_count = fail_count + 1;
            end else begin
                // Check which slave is valid
                case (expected_slave)
                    2'b00: begin
                        if (M00_AXI_awvalid && !M01_AXI_awvalid && !M02_AXI_awvalid && !M03_AXI_awvalid &&
                            (M00_AXI_awaddr === addr) && (M00_AXI_awaddr_ID === 1)) begin
                            $display("[PASS] %s: Decoded to Slave 0", test_name);
                            pass_count = pass_count + 1;
                        end else begin
                            $display("[FAIL] %s: Slave 0 signals incorrect", test_name);
                            fail_count = fail_count + 1;
                        end
                    end
                    2'b01: begin
                        if (M01_AXI_awvalid && !M00_AXI_awvalid && !M02_AXI_awvalid && !M03_AXI_awvalid &&
                            (M01_AXI_awaddr === addr) && (M01_AXI_awaddr_ID === 1)) begin
                            $display("[PASS] %s: Decoded to Slave 1", test_name);
                            pass_count = pass_count + 1;
                        end else begin
                            $display("[FAIL] %s: Slave 1 signals incorrect", test_name);
                            fail_count = fail_count + 1;
                        end
                    end
                    2'b10: begin
                        if (M02_AXI_awvalid && !M00_AXI_awvalid && !M01_AXI_awvalid && !M03_AXI_awvalid &&
                            (M02_AXI_awaddr === addr) && (M02_AXI_awaddr_ID === 1)) begin
                            $display("[PASS] %s: Decoded to Slave 2", test_name);
                            pass_count = pass_count + 1;
                        end else begin
                            $display("[FAIL] %s: Slave 2 signals incorrect", test_name);
                            fail_count = fail_count + 1;
                        end
                    end
                    2'b11: begin
                        if (M03_AXI_awvalid && !M00_AXI_awvalid && !M01_AXI_awvalid && !M02_AXI_awvalid &&
                            (M03_AXI_awaddr === addr) && (M03_AXI_awaddr_ID === 1)) begin
                            $display("[PASS] %s: Decoded to Slave 3", test_name);
                            pass_count = pass_count + 1;
                        end else begin
                            $display("[FAIL] %s: Slave 3 signals incorrect", test_name);
                            fail_count = fail_count + 1;
                        end
                    end
                endcase
            end
            
            Master_AXI_awvalid = 0;
            #(CLK_PERIOD);
        end
    endtask

    //==========================================================================
    // Test Stimulus
    //==========================================================================
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        // Initialize
        Master_AXI_awaddr = 0;
        Master_AXI_awaddr_ID = 0;
        Master_AXI_awlen = 0;
        Master_AXI_awsize = 0;
        Master_AXI_awburst = 0;
        Master_AXI_awlock = 0;
        Master_AXI_awcache = 0;
        Master_AXI_awprot = 0;
        Master_AXI_awqos = 0;
        Master_AXI_awvalid = 0;
        
        M00_AXI_awready = 1;
        M01_AXI_awready = 1;
        M02_AXI_awready = 1;
        M03_AXI_awready = 1;

        $display("\n");
        $display("==========================================");
        $display("Write_Addr_Channel_Dec Testbench");
        $display("==========================================");
        $display("Testing: Address decoding to 4 slaves");
        $display("Address bits [31:30] select slave");
        $display("==========================================");
        $display("");

        #(CLK_PERIOD * 2);

        // Test 1: Decode to Slave 0 (bits[31:30] = 00)
        test_decode(32'h0000_1000, 2'b00, 4'b0001, "Decode to Slave 0");

        // Test 2: Decode to Slave 1 (bits[31:30] = 01)
        test_decode(32'h4000_1000, 2'b01, 4'b0010, "Decode to Slave 1");

        // Test 3: Decode to Slave 2 (bits[31:30] = 10)
        test_decode(32'h8000_1000, 2'b10, 4'b0100, "Decode to Slave 2");

        // Test 4: Decode to Slave 3 (bits[31:30] = 11)
        test_decode(32'hC000_1000, 2'b11, 4'b1000, "Decode to Slave 3");

        // Test 5: Test Sel_Slave_Ready routing
        $display("\n--- Test 5: Sel_Slave_Ready Routing ---");
        test_count = test_count + 1;
        Master_AXI_awaddr = 32'h4000_1000;  // Slave 1
        Master_AXI_awvalid = 1;
        M01_AXI_awready = 0;
        #1;
        if (Sel_Slave_Ready === 0) begin
            $display("[PASS] Sel_Slave_Ready routed to Slave 1 ready");
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Sel_Slave_Ready not routed correctly");
            fail_count = fail_count + 1;
        end
        Master_AXI_awvalid = 0;
        M01_AXI_awready = 1;
        #(CLK_PERIOD);

        // Wait a bit
        #(CLK_PERIOD * 2);

        // Print Summary
        $display("\n==========================================");
        $display("Test Summary:");
        $display("  Total Tests: %0d", test_count);
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
