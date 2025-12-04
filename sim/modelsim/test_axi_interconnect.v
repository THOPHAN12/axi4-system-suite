//------------------------------------------------------------------------------
// test_axi_interconnect.v
// Simple testbench to verify AXI_Interconnect functionality
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module test_axi_interconnect;

    reg         clk;
    reg         resetn;
    
    // Test signals
    integer     test_count = 0;
    integer     pass_count = 0;
    integer     fail_count = 0;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz
    end
    
    // Reset
    initial begin
        resetn = 0;
        #100;
        resetn = 1;
        $display("\n========================================");
        $display("  AXI_Interconnect Function Test");
        $display("========================================\n");
    end
    
    // Master 0 signals
    reg [31:0]  m0_awaddr;
    reg [7:0]   m0_awlen;
    reg [2:0]   m0_awsize;
    reg [1:0]   m0_awburst;
    reg         m0_awvalid;
    wire        m0_awready;
    reg [31:0]  m0_wdata;
    reg [3:0]   m0_wstrb;
    reg         m0_wlast;
    reg         m0_wvalid;
    wire        m0_wready;
    wire [1:0]  m0_bresp;
    wire        m0_bvalid;
    reg         m0_bready;
    reg [31:0]  m0_araddr;
    reg [7:0]   m0_arlen;
    reg [2:0]   m0_arsize;
    reg [1:0]   m0_arburst;
    reg         m0_arvalid;
    wire        m0_arready;
    wire [31:0] m0_rdata;
    wire [1:0]  m0_rresp;
    wire        m0_rlast;
    wire        m0_rvalid;
    reg         m0_rready;
    
    // Master 1 signals  
    reg [31:0]  m1_awaddr;
    reg [7:0]   m1_awlen;
    reg [2:0]   m1_awsize;
    reg [1:0]   m1_awburst;
    reg         m1_awvalid;
    wire        m1_awready;
    reg [31:0]  m1_wdata;
    reg [3:0]   m1_wstrb;
    reg         m1_wlast;
    reg         m1_wvalid;
    wire        m1_wready;
    wire [1:0]  m1_bresp;
    wire        m1_bvalid;
    reg         m1_bready;
    reg [31:0]  m1_araddr;
    reg [7:0]   m1_arlen;
    reg [2:0]   m1_arsize;
    reg [1:0]   m1_arburst;
    reg         m1_arvalid;
    wire        m1_arready;
    wire [31:0] m1_rdata;
    wire [1:0]  m1_rresp;
    wire        m1_rlast;
    wire        m1_rvalid;
    reg         m1_rready;
    
    // Slave signals (simple memory models)
    wire [31:0] s0_awaddr, s1_awaddr, s2_awaddr, s3_awaddr;
    wire [7:0]  s0_awlen, s1_awlen, s2_awlen, s3_awlen;
    wire [2:0]  s0_awsize, s1_awsize, s2_awsize, s3_awsize;
    wire [1:0]  s0_awburst, s1_awburst, s2_awburst, s3_awburst;
    wire        s0_awvalid, s1_awvalid, s2_awvalid, s3_awvalid;
    reg         s0_awready, s1_awready, s2_awready, s3_awready;
    wire [31:0] s0_wdata, s1_wdata, s2_wdata, s3_wdata;
    wire [3:0]  s0_wstrb, s1_wstrb, s2_wstrb, s3_wstrb;
    wire        s0_wlast, s1_wlast, s2_wlast, s3_wlast;
    wire        s0_wvalid, s1_wvalid, s2_wvalid, s3_wvalid;
    reg         s0_wready, s1_wready, s2_wready, s3_wready;
    reg [1:0]   s0_bresp, s1_bresp, s2_bresp, s3_bresp;
    reg         s0_bvalid, s1_bvalid, s2_bvalid, s3_bvalid;
    wire        s0_bready, s1_bready, s2_bready, s3_bready;
    wire [31:0] s0_araddr, s1_araddr, s2_araddr, s3_araddr;
    wire [7:0]  s0_arlen, s1_arlen, s2_arlen, s3_arlen;
    wire [2:0]  s0_arsize, s1_arsize, s2_arsize, s3_arsize;
    wire [1:0]  s0_arburst, s1_arburst, s2_arburst, s3_arburst;
    wire        s0_arvalid, s1_arvalid, s2_arvalid, s3_arvalid;
    reg         s0_arready, s1_arready, s2_arready, s3_arready;
    reg [31:0]  s0_rdata, s1_rdata, s2_rdata, s3_rdata;
    reg [1:0]   s0_rresp, s1_rresp, s2_rresp, s3_rresp;
    reg         s0_rlast, s1_rlast, s2_rlast, s3_rlast;
    reg         s0_rvalid, s1_rvalid, s2_rvalid, s3_rvalid;
    wire        s0_rready, s1_rready, s2_rready, s3_rready;
    
    // DUT instantiation
    AXI_Interconnect #(
        .ARBITRATION_MODE(1)  // Round-Robin mode
    ) dut (
        .ACLK(clk),
        .ARESETN(resetn),
        // M0
        .M0_AWADDR(m0_awaddr), .M0_AWLEN(m0_awlen), .M0_AWSIZE(m0_awsize), .M0_AWBURST(m0_awburst),
        .M0_AWVALID(m0_awvalid), .M0_AWREADY(m0_awready),
        .M0_WDATA(m0_wdata), .M0_WSTRB(m0_wstrb), .M0_WLAST(m0_wlast),
        .M0_WVALID(m0_wvalid), .M0_WREADY(m0_wready),
        .M0_BRESP(m0_bresp), .M0_BVALID(m0_bvalid), .M0_BREADY(m0_bready),
        .M0_ARADDR(m0_araddr), .M0_ARLEN(m0_arlen), .M0_ARSIZE(m0_arsize), .M0_ARBURST(m0_arburst),
        .M0_ARVALID(m0_arvalid), .M0_ARREADY(m0_arready),
        .M0_RDATA(m0_rdata), .M0_RRESP(m0_rresp), .M0_RLAST(m0_rlast),
        .M0_RVALID(m0_rvalid), .M0_RREADY(m0_rready),
        // M1
        .M1_AWADDR(m1_awaddr), .M1_AWLEN(m1_awlen), .M1_AWSIZE(m1_awsize), .M1_AWBURST(m1_awburst),
        .M1_AWVALID(m1_awvalid), .M1_AWREADY(m1_awready),
        .M1_WDATA(m1_wdata), .M1_WSTRB(m1_wstrb), .M1_WLAST(m1_wlast),
        .M1_WVALID(m1_wvalid), .M1_WREADY(m1_wready),
        .M1_BRESP(m1_bresp), .M1_BVALID(m1_bvalid), .M1_BREADY(m1_bready),
        .M1_ARADDR(m1_araddr), .M1_ARLEN(m1_arlen), .M1_ARSIZE(m1_arsize), .M1_ARBURST(m1_arburst),
        .M1_ARVALID(m1_arvalid), .M1_ARREADY(m1_arready),
        .M1_RDATA(m1_rdata), .M1_RRESP(m1_rresp), .M1_RLAST(m1_rlast),
        .M1_RVALID(m1_rvalid), .M1_RREADY(m1_rready),
        // S0-S3
        .S0_AWADDR(s0_awaddr), .S0_AWLEN(s0_awlen), .S0_AWSIZE(s0_awsize), .S0_AWBURST(s0_awburst),
        .S0_AWVALID(s0_awvalid), .S0_AWREADY(s0_awready),
        .S0_WDATA(s0_wdata), .S0_WSTRB(s0_wstrb), .S0_WLAST(s0_wlast),
        .S0_WVALID(s0_wvalid), .S0_WREADY(s0_wready),
        .S0_BRESP(s0_bresp), .S0_BVALID(s0_bvalid), .S0_BREADY(s0_bready),
        .S0_ARADDR(s0_araddr), .S0_ARLEN(s0_arlen), .S0_ARSIZE(s0_arsize), .S0_ARBURST(s0_arburst),
        .S0_ARVALID(s0_arvalid), .S0_ARREADY(s0_arready),
        .S0_RDATA(s0_rdata), .S0_RRESP(s0_rresp), .S0_RLAST(s0_rlast),
        .S0_RVALID(s0_rvalid), .S0_RREADY(s0_rready),
        .S1_AWADDR(s1_awaddr), .S1_AWLEN(s1_awlen), .S1_AWSIZE(s1_awsize), .S1_AWBURST(s1_awburst),
        .S1_AWVALID(s1_awvalid), .S1_AWREADY(s1_awready),
        .S1_WDATA(s1_wdata), .S1_WSTRB(s1_wstrb), .S1_WLAST(s1_wlast),
        .S1_WVALID(s1_wvalid), .S1_WREADY(s1_wready),
        .S1_BRESP(s1_bresp), .S1_BVALID(s1_bvalid), .S1_BREADY(s1_bready),
        .S1_ARADDR(s1_araddr), .S1_ARLEN(s1_arlen), .S1_ARSIZE(s1_arsize), .S1_ARBURST(s1_arburst),
        .S1_ARVALID(s1_arvalid), .S1_ARREADY(s1_arready),
        .S1_RDATA(s1_rdata), .S1_RRESP(s1_rresp), .S1_RLAST(s1_rlast),
        .S1_RVALID(s1_rvalid), .S1_RREADY(s1_rready),
        .S2_AWADDR(s2_awaddr), .S2_AWLEN(s2_awlen), .S2_AWSIZE(s2_awsize), .S2_AWBURST(s2_awburst),
        .S2_AWVALID(s2_awvalid), .S2_AWREADY(s2_awready),
        .S2_WDATA(s2_wdata), .S2_WSTRB(s2_wstrb), .S2_WLAST(s2_wlast),
        .S2_WVALID(s2_wvalid), .S2_WREADY(s2_wready),
        .S2_BRESP(s2_bresp), .S2_BVALID(s2_bvalid), .S2_BREADY(s2_bready),
        .S2_ARADDR(s2_araddr), .S2_ARLEN(s2_arlen), .S2_ARSIZE(s2_arsize), .S2_ARBURST(s2_arburst),
        .S2_ARVALID(s2_arvalid), .S2_ARREADY(s2_arready),
        .S2_RDATA(s2_rdata), .S2_RRESP(s2_rresp), .S2_RLAST(s2_rlast),
        .S2_RVALID(s2_rvalid), .S2_RREADY(s2_rready),
        .S3_AWADDR(s3_awaddr), .S3_AWLEN(s3_awlen), .S3_AWSIZE(s3_awsize), .S3_AWBURST(s3_awburst),
        .S3_AWVALID(s3_awvalid), .S3_AWREADY(s3_awready),
        .S3_WDATA(s3_wdata), .S3_WSTRB(s3_wstrb), .S3_WLAST(s3_wlast),
        .S3_WVALID(s3_wvalid), .S3_WREADY(s3_wready),
        .S3_BRESP(s3_bresp), .S3_BVALID(s3_bvalid), .S3_BREADY(s3_bready),
        .S3_ARADDR(s3_araddr), .S3_ARLEN(s3_arlen), .S3_ARSIZE(s3_arsize), .S3_ARBURST(s3_arburst),
        .S3_ARVALID(s3_arvalid), .S3_ARREADY(s3_arready),
        .S3_RDATA(s3_rdata), .S3_RRESP(s3_rresp), .S3_RLAST(s3_rlast),
        .S3_RVALID(s3_rvalid), .S3_RREADY(s3_rready)
    );
    
    // Simple slave models (always ready, return data based on address)
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            s0_arready <= 0; s1_arready <= 0; s2_arready <= 0; s3_arready <= 0;
            s0_awready <= 0; s1_awready <= 0; s2_awready <= 0; s3_awready <= 0;
            s0_wready <= 0; s1_wready <= 0; s2_wready <= 0; s3_wready <= 0;
            s0_rvalid <= 0; s1_rvalid <= 0; s2_rvalid <= 0; s3_rvalid <= 0;
            s0_bvalid <= 0; s1_bvalid <= 0; s2_bvalid <= 0; s3_bvalid <= 0;
        end else begin
            // Always ready
            s0_arready <= 1; s1_arready <= 1; s2_arready <= 1; s3_arready <= 1;
            s0_awready <= 1; s1_awready <= 1; s2_awready <= 1; s3_awready <= 1;
            s0_wready <= 1; s1_wready <= 1; s2_wready <= 1; s3_wready <= 1;
            
            // Read response
            s0_rvalid <= s0_arvalid; s1_rvalid <= s1_arvalid;
            s2_rvalid <= s2_arvalid; s3_rvalid <= s3_arvalid;
            s0_rdata <= s0_araddr + 32'h0000_0000;  // S0 response
            s1_rdata <= s1_araddr + 32'h1111_1111;  // S1 response
            s2_rdata <= s2_araddr + 32'h2222_2222;  // S2 response
            s3_rdata <= s3_araddr + 32'h3333_3333;  // S3 response
            s0_rresp <= 2'b00; s1_rresp <= 2'b00; s2_rresp <= 2'b00; s3_rresp <= 2'b00;
            s0_rlast <= 1; s1_rlast <= 1; s2_rlast <= 1; s3_rlast <= 1;
            
            // Write response
            s0_bvalid <= s0_wvalid; s1_bvalid <= s1_wvalid;
            s2_bvalid <= s2_wvalid; s3_bvalid <= s3_wvalid;
            s0_bresp <= 2'b00; s1_bresp <= 2'b00; s2_bresp <= 2'b00; s3_bresp <= 2'b00;
        end
    end
    
    // Test sequence
    initial begin
        // Initialize
        m0_awvalid = 0; m0_wvalid = 0; m0_bready = 1; m0_arvalid = 0; m0_rready = 1;
        m1_awvalid = 0; m1_wvalid = 0; m1_bready = 1; m1_arvalid = 0; m1_rready = 1;
        m0_awlen = 0; m0_awsize = 3'b010; m0_awburst = 2'b01; m0_wlast = 1; m0_wstrb = 4'hF;
        m1_awlen = 0; m1_awsize = 3'b010; m1_awburst = 2'b01; m1_wlast = 1; m1_wstrb = 4'hF;
        m0_arlen = 0; m0_arsize = 3'b010; m0_arburst = 2'b01;
        m1_arlen = 0; m1_arsize = 3'b010; m1_arburst = 2'b01;
        
        wait(resetn);
        @(posedge clk);
        
        $display("[TEST 1] M0 Read from S0 (RAM - 0x0000_0100)");
        m0_araddr = 32'h0000_0100;
        m0_arvalid = 1;
        @(posedge clk);
        m0_arvalid = 0;
        wait(m0_rvalid);
        $display("  Result: RDATA=0x%h (Expected: 0x0000_0100)", m0_rdata);
        if (m0_rdata == 32'h0000_0100) begin
            $display("  PASS!");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL!");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        @(posedge clk);
        @(posedge clk);
        
        $display("\n[TEST 2] M1 Read from S1 (GPIO - 0x4000_0200)");
        m1_araddr = 32'h4000_0200;
        m1_arvalid = 1;
        @(posedge clk);
        m1_arvalid = 0;
        wait(m1_rvalid);
        $display("  Result: RDATA=0x%h (Expected: 0x5111_1311)", m1_rdata);
        if (m1_rdata == 32'h5111_1311) begin
            $display("  PASS!");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL!");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        @(posedge clk);
        @(posedge clk);
        
        $display("\n[TEST 3] M0 Write to S2 (UART - 0x8000_0300)");
        m0_awaddr = 32'h8000_0300;
        m0_wdata = 32'hDEAD_BEEF;
        m0_awvalid = 1;
        m0_wvalid = 1;
        @(posedge clk);
        m0_awvalid = 0;
        m0_wvalid = 0;
        wait(m0_bvalid);
        $display("  Result: BRESP=0x%h (Expected: 0x00 - OK)", m0_bresp);
        if (m0_bresp == 2'b00) begin
            $display("  PASS!");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL!");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        @(posedge clk);
        @(posedge clk);
        
        $display("\n[TEST 4] M1 Write to S3 (SPI - 0xC000_0400)");
        m1_awaddr = 32'hC000_0400;
        m1_wdata = 32'hCAFE_BABE;
        m1_awvalid = 1;
        m1_wvalid = 1;
        @(posedge clk);
        m1_awvalid = 0;
        m1_wvalid = 0;
        wait(m1_bvalid);
        $display("  Result: BRESP=0x%h (Expected: 0x00 - OK)", m1_bresp);
        if (m1_bresp == 2'b00) begin
            $display("  PASS!");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL!");
            fail_count = fail_count + 1;
        end
        test_count = test_count + 1;
        @(posedge clk);
        @(posedge clk);
        
        // Summary
        $display("\n========================================");
        $display("  TEST SUMMARY");
        $display("========================================");
        $display("  Total:  %0d", test_count);
        $display("  PASSED: %0d", pass_count);
        $display("  FAILED: %0d", fail_count);
        if (fail_count == 0) begin
            $display("\n  STATUS: ALL TESTS PASSED!");
        end else begin
            $display("\n  STATUS: SOME TESTS FAILED!");
        end
        $display("========================================\n");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #100000;
        $display("\nERROR: Test timeout!");
        $finish;
    end

endmodule

