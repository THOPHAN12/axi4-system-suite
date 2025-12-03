//=============================================================================
// quick_arb_test.sv - Quick test for arbitration modes
//=============================================================================

`timescale 1ns/1ps

module quick_arb_test;

    parameter string MODE = "ROUND_ROBIN";  // Change to test: FIXED, ROUND_ROBIN, QOS
    
    logic ACLK, ARESETN;
    
    // Master requests
    logic M0_AWVALID, M0_AWREADY, M1_AWVALID, M1_AWREADY;
    logic [31:0] M0_AWADDR, M1_AWADDR;
    logic [2:0] M0_AWPROT, M1_AWPROT;
    logic [3:0] M0_AWQOS, M1_AWQOS;
    
    // Dummy ports
    logic [31:0] M0_WDATA, M1_WDATA, M0_ARADDR, M1_ARADDR, M0_RDATA, M1_RDATA;
    logic [3:0] M0_WSTRB, M1_WSTRB;
    logic M0_WVALID, M0_WREADY, M1_WVALID, M1_WREADY;
    logic [1:0] M0_BRESP, M1_BRESP, M0_RRESP, M1_RRESP;
    logic M0_BVALID, M0_BREADY, M1_BVALID, M1_BREADY;
    logic [2:0] M0_ARPROT, M1_ARPROT;
    logic [3:0] M0_ARQOS, M1_ARQOS;
    logic M0_ARVALID, M0_ARREADY, M1_ARVALID, M1_ARREADY;
    logic M0_RVALID, M0_RLAST, M0_RREADY, M1_RVALID, M1_RLAST, M1_RREADY;
    
    // Slave ports (all 4 slaves)
    logic [31:0] S0_AWADDR, S1_AWADDR, S2_AWADDR, S3_AWADDR;
    logic [2:0] S0_AWPROT, S1_AWPROT, S2_AWPROT, S3_AWPROT;
    logic S0_AWVALID, S1_AWVALID, S2_AWVALID, S3_AWVALID;
    logic S0_AWREADY, S1_AWREADY, S2_AWREADY, S3_AWREADY;
    logic [31:0] S0_WDATA, S1_WDATA, S2_WDATA, S3_WDATA;
    logic [3:0] S0_WSTRB, S1_WSTRB, S2_WSTRB, S3_WSTRB;
    logic S0_WVALID, S1_WVALID, S2_WVALID, S3_WVALID;
    logic S0_WREADY, S1_WREADY, S2_WREADY, S3_WREADY;
    logic [1:0] S0_BRESP, S1_BRESP, S2_BRESP, S3_BRESP;
    logic S0_BVALID, S1_BVALID, S2_BVALID, S3_BVALID;
    logic S0_BREADY, S1_BREADY, S2_BREADY, S3_BREADY;
    logic [31:0] S0_ARADDR, S1_ARADDR, S2_ARADDR, S3_ARADDR;
    logic [2:0] S0_ARPROT, S1_ARPROT, S2_ARPROT, S3_ARPROT;
    logic S0_ARVALID, S1_ARVALID, S2_ARVALID, S3_ARVALID;
    logic S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
    logic [31:0] S0_RDATA, S1_RDATA, S2_RDATA, S3_RDATA;
    logic [1:0] S0_RRESP, S1_RRESP, S2_RRESP, S3_RRESP;
    logic S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
    logic S0_RLAST, S1_RLAST, S2_RLAST, S3_RLAST;
    logic S0_RREADY, S1_RREADY, S2_RREADY, S3_RREADY;
    
    int m0_count, m1_count;
    
    // DUT
    axi_rr_interconnect_2x4 #(.ARBITRATION_MODE(MODE)) dut (
        .ACLK(ACLK), .ARESETN(ARESETN),
        .M0_AWADDR(M0_AWADDR), .M0_AWPROT(M0_AWPROT), .M0_AWQOS(M0_AWQOS),
        .M0_AWVALID(M0_AWVALID), .M0_AWREADY(M0_AWREADY),
        .M0_WDATA(M0_WDATA), .M0_WSTRB(M0_WSTRB), .M0_WVALID(M0_WVALID), .M0_WREADY(M0_WREADY),
        .M0_BRESP(M0_BRESP), .M0_BVALID(M0_BVALID), .M0_BREADY(M0_BREADY),
        .M0_ARADDR(M0_ARADDR), .M0_ARPROT(M0_ARPROT), .M0_ARQOS(M0_ARQOS),
        .M0_ARVALID(M0_ARVALID), .M0_ARREADY(M0_ARREADY),
        .M0_RDATA(M0_RDATA), .M0_RRESP(M0_RRESP), .M0_RVALID(M0_RVALID),
        .M0_RLAST(M0_RLAST), .M0_RREADY(M0_RREADY),
        .M1_AWADDR(M1_AWADDR), .M1_AWPROT(M1_AWPROT), .M1_AWQOS(M1_AWQOS),
        .M1_AWVALID(M1_AWVALID), .M1_AWREADY(M1_AWREADY),
        .M1_WDATA(M1_WDATA), .M1_WSTRB(M1_WSTRB), .M1_WVALID(M1_WVALID), .M1_WREADY(M1_WREADY),
        .M1_BRESP(M1_BRESP), .M1_BVALID(M1_BVALID), .M1_BREADY(M1_BREADY),
        .M1_ARADDR(M1_ARADDR), .M1_ARPROT(M1_ARPROT), .M1_ARQOS(M1_ARQOS),
        .M1_ARVALID(M1_ARVALID), .M1_ARREADY(M1_ARREADY),
        .M1_RDATA(M1_RDATA), .M1_RRESP(M1_RRESP), .M1_RVALID(M1_RVALID),
        .M1_RLAST(M1_RLAST), .M1_RREADY(M1_RREADY),
        .S0_AWADDR(S0_AWADDR), .S0_AWPROT(S0_AWPROT), .S0_AWVALID(S0_AWVALID), .S0_AWREADY(S0_AWREADY),
        .S0_WDATA(S0_WDATA), .S0_WSTRB(S0_WSTRB), .S0_WVALID(S0_WVALID), .S0_WREADY(S0_WREADY),
        .S0_BRESP(S0_BRESP), .S0_BVALID(S0_BVALID), .S0_BREADY(S0_BREADY),
        .S0_ARADDR(S0_ARADDR), .S0_ARPROT(S0_ARPROT), .S0_ARVALID(S0_ARVALID), .S0_ARREADY(S0_ARREADY),
        .S0_RDATA(S0_RDATA), .S0_RRESP(S0_RRESP), .S0_RVALID(S0_RVALID), .S0_RLAST(S0_RLAST), .S0_RREADY(S0_RREADY),
        .S1_AWADDR(S1_AWADDR), .S1_AWPROT(S1_AWPROT), .S1_AWVALID(S1_AWVALID), .S1_AWREADY(S1_AWREADY),
        .S1_WDATA(S1_WDATA), .S1_WSTRB(S1_WSTRB), .S1_WVALID(S1_WVALID), .S1_WREADY(S1_WREADY),
        .S1_BRESP(S1_BRESP), .S1_BVALID(S1_BVALID), .S1_BREADY(S1_BREADY),
        .S1_ARADDR(S1_ARADDR), .S1_ARPROT(S1_ARPROT), .S1_ARVALID(S1_ARVALID), .S1_ARREADY(S1_ARREADY),
        .S1_RDATA(S1_RDATA), .S1_RRESP(S1_RRESP), .S1_RVALID(S1_RVALID), .S1_RLAST(S1_RLAST), .S1_RREADY(S1_RREADY),
        .S2_AWADDR(S2_AWADDR), .S2_AWPROT(S2_AWPROT), .S2_AWVALID(S2_AWVALID), .S2_AWREADY(S2_AWREADY),
        .S2_WDATA(S2_WDATA), .S2_WSTRB(S2_WSTRB), .S2_WVALID(S2_WVALID), .S2_WREADY(S2_WREADY),
        .S2_BRESP(S2_BRESP), .S2_BVALID(S2_BVALID), .S2_BREADY(S2_BREADY),
        .S2_ARADDR(S2_ARADDR), .S2_ARPROT(S2_ARPROT), .S2_ARVALID(S2_ARVALID), .S2_ARREADY(S2_ARREADY),
        .S2_RDATA(S2_RDATA), .S2_RRESP(S2_RRESP), .S2_RVALID(S2_RVALID), .S2_RLAST(S2_RLAST), .S2_RREADY(S2_RREADY),
        .S3_AWADDR(S3_AWADDR), .S3_AWPROT(S3_AWPROT), .S3_AWVALID(S3_AWVALID), .S3_AWREADY(S3_AWREADY),
        .S3_WDATA(S3_WDATA), .S3_WSTRB(S3_WSTRB), .S3_WVALID(S3_WVALID), .S3_WREADY(S3_WREADY),
        .S3_BRESP(S3_BRESP), .S3_BVALID(S3_BVALID), .S3_BREADY(S3_BREADY),
        .S3_ARADDR(S3_ARADDR), .S3_ARPROT(S3_ARPROT), .S3_ARVALID(S3_ARVALID), .S3_ARREADY(S3_ARREADY),
        .S3_RDATA(S3_RDATA), .S3_RRESP(S3_RRESP), .S3_RVALID(S3_RVALID), .S3_RLAST(S3_RLAST), .S3_RREADY(S3_RREADY)
    );
    
    // Clock
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;
    end
    
    // Slave models - always ready
    assign S0_AWREADY = 1; assign S1_AWREADY = 1; assign S2_AWREADY = 1; assign S3_AWREADY = 1;
    assign S0_WREADY = 1; assign S1_WREADY = 1; assign S2_WREADY = 1; assign S3_WREADY = 1;
    always_ff @(posedge ACLK) begin
        S0_BVALID <= S0_WVALID; S1_BVALID <= S1_WVALID;
        S2_BVALID <= S2_WVALID; S3_BVALID <= S3_WVALID;
    end
    assign S0_BRESP = 0; assign S1_BRESP = 0; assign S2_BRESP = 0; assign S3_BRESP = 0;
    
    // Monitor
    always @(posedge ACLK) begin
        if (ARESETN && M0_AWVALID && M0_AWREADY) begin
            m0_count++;
            $display("[%0t] M0 granted (count=%0d)", $time, m0_count);
        end
        if (ARESETN && M1_AWVALID && M1_AWREADY) begin
            m1_count++;
            $display("[%0t] M1 granted (count=%0d)", $time, m1_count);
        end
    end
    
    // Test
    initial begin
        $display("\n=== ARBITRATION TEST: %s ===\n", MODE);
        ARESETN = 0; m0_count = 0; m1_count = 0;
        M0_AWVALID = 0; M1_AWVALID = 0; M0_AWADDR = 0; M1_AWADDR = 0;
        M0_AWPROT = 0; M1_AWPROT = 0;
        M0_AWQOS = 4'd10; M1_AWQOS = 4'd2;  // M0 higher QoS
        M0_WVALID = 0; M1_WVALID = 0; M0_WDATA = 0; M1_WDATA = 0;
        M0_WSTRB = 0; M1_WSTRB = 0; M0_BREADY = 1; M1_BREADY = 1;
        repeat(3) @(posedge ACLK);
        ARESETN = 1;
        repeat(2) @(posedge ACLK);
        
        // Both masters request 10 times
        for (int i = 0; i < 10; i++) begin
            @(posedge ACLK);
            M0_AWADDR = 32'h0000_1000; M0_AWVALID = 1; M0_WVALID = 1; M0_WDATA = 32'hAAAA0000 + i; M0_WSTRB = 4'hF;
            M1_AWADDR = 32'h4000_2000; M1_AWVALID = 1; M1_WVALID = 1; M1_WDATA = 32'hBBBB0000 + i; M1_WSTRB = 4'hF;
            @(posedge ACLK);
            M0_AWVALID = 0; M0_WVALID = 0;
            M1_AWVALID = 0; M1_WVALID = 0;
            repeat(3) @(posedge ACLK);
        end
        
        repeat(5) @(posedge ACLK);
        
        $display("\n=== RESULTS ===");
        $display("Mode: %s", MODE);
        $display("M0 QoS=%0d, M1 QoS=%0d", 10, 2);
        $display("M0 granted: %0d times", m0_count);
        $display("M1 granted: %0d times", m1_count);
        
        if (MODE == "FIXED") begin
            if (m0_count == 10 && m1_count == 0)
                $display("✓ PASS: FIXED priority works (M0 always wins)");
            else
                $display("✗ FAIL: Expected M0=10, M1=0");
        end else if (MODE == "ROUND_ROBIN") begin
            if (m0_count == 5 && m1_count == 5)
                $display("✓ PASS: Round-robin works (fair 50/50)");
            else
                $display("⚠ Check: Expected M0=5, M1=5 for perfect fairness");
        end else if (MODE == "QOS") begin
            if (m0_count == 10 && m1_count == 0)
                $display("✓ PASS: QoS works (M0 has higher QoS, always wins)");
            else
                $display("✗ FAIL: Expected M0=10, M1=0 (M0 has QoS=10 > M1 QoS=2)");
        end
        
        $display("===============\n");
        $finish;
    end
    
    initial #5000 $finish;

endmodule

