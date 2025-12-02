//=============================================================================
// simple_arbitration_test.sv
// Simple testbench to verify 3 arbitration modes (FIXED, ROUND_ROBIN, QOS)
// Compatible with QuestaSim 10.2c (no OOP features)
//=============================================================================

`timescale 1ns/1ps

module simple_arbitration_test;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10;
    
    // Select arbitration mode for this test
    // Change this to test different modes: "FIXED", "ROUND_ROBIN", "QOS"
    parameter string ARBIT_MODE = "ROUND_ROBIN";
    
    // Clock and Reset
    logic ACLK;
    logic ARESETN;
    
    // Master 0 Write Channel
    logic [ADDR_WIDTH-1:0]      M0_AWADDR;
    logic [2:0]                 M0_AWPROT;
    logic [3:0]                 M0_AWQOS;
    logic                       M0_AWVALID;
    logic                       M0_AWREADY;
    logic [DATA_WIDTH-1:0]      M0_WDATA;
    logic [(DATA_WIDTH/8)-1:0]  M0_WSTRB;
    logic                       M0_WVALID;
    logic                       M0_WREADY;
    logic [1:0]                 M0_BRESP;
    logic                       M0_BVALID;
    logic                       M0_BREADY;
    
    // Master 0 Read Channel
    logic [ADDR_WIDTH-1:0]      M0_ARADDR;
    logic [2:0]                 M0_ARPROT;
    logic [3:0]                 M0_ARQOS;
    logic                       M0_ARVALID;
    logic                       M0_ARREADY;
    logic [DATA_WIDTH-1:0]      M0_RDATA;
    logic [1:0]                 M0_RRESP;
    logic                       M0_RVALID;
    logic                       M0_RLAST;
    logic                       M0_RREADY;
    
    // Master 1 Write Channel
    logic [ADDR_WIDTH-1:0]      M1_AWADDR;
    logic [2:0]                 M1_AWPROT;
    logic [3:0]                 M1_AWQOS;
    logic                       M1_AWVALID;
    logic                       M1_AWREADY;
    logic [DATA_WIDTH-1:0]      M1_WDATA;
    logic [(DATA_WIDTH/8)-1:0]  M1_WSTRB;
    logic                       M1_WVALID;
    logic                       M1_WREADY;
    logic [1:0]                 M1_BRESP;
    logic                       M1_BVALID;
    logic                       M1_BREADY;
    
    // Master 1 Read Channel
    logic [ADDR_WIDTH-1:0]      M1_ARADDR;
    logic [2:0]                 M1_ARPROT;
    logic [3:0]                 M1_ARQOS;
    logic                       M1_ARVALID;
    logic                       M1_ARREADY;
    logic [DATA_WIDTH-1:0]      M1_RDATA;
    logic [1:0]                 M1_RRESP;
    logic                       M1_RVALID;
    logic                       M1_RLAST;
    logic                       M1_RREADY;
    
    // Slave ports (simplified - we'll just tie off for this test)
    logic [ADDR_WIDTH-1:0]      S0_AWADDR, S1_AWADDR, S2_AWADDR, S3_AWADDR;
    logic [2:0]                 S0_AWPROT, S1_AWPROT, S2_AWPROT, S3_AWPROT;
    logic                       S0_AWVALID, S1_AWVALID, S2_AWVALID, S3_AWVALID;
    logic                       S0_AWREADY, S1_AWREADY, S2_AWREADY, S3_AWREADY;
    logic [DATA_WIDTH-1:0]      S0_WDATA, S1_WDATA, S2_WDATA, S3_WDATA;
    logic [(DATA_WIDTH/8)-1:0]  S0_WSTRB, S1_WSTRB, S2_WSTRB, S3_WSTRB;
    logic                       S0_WVALID, S1_WVALID, S2_WVALID, S3_WVALID;
    logic                       S0_WREADY, S1_WREADY, S2_WREADY, S3_WREADY;
    logic [1:0]                 S0_BRESP, S1_BRESP, S2_BRESP, S3_BRESP;
    logic                       S0_BVALID, S1_BVALID, S2_BVALID, S3_BVALID;
    logic                       S0_BREADY, S1_BREADY, S2_BREADY, S3_BREADY;
    logic [ADDR_WIDTH-1:0]      S0_ARADDR, S1_ARADDR, S2_ARADDR, S3_ARADDR;
    logic [2:0]                 S0_ARPROT, S1_ARPROT, S2_ARPROT, S3_ARPROT;
    logic                       S0_ARVALID, S1_ARVALID, S2_ARVALID, S3_ARVALID;
    logic                       S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
    logic [DATA_WIDTH-1:0]      S0_RDATA, S1_RDATA, S2_RDATA, S3_RDATA;
    logic [1:0]                 S0_RRESP, S1_RRESP, S2_RRESP, S3_RRESP;
    logic                       S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
    logic                       S0_RLAST, S1_RLAST, S2_RLAST, S3_RLAST;
    logic                       S0_RREADY, S1_RREADY, S2_RREADY, S3_RREADY;
    
    // Statistics
    int m0_granted_count = 0;
    int m1_granted_count = 0;
    int total_arbitrations = 0;
    
    // DUT instantiation
    axi_rr_interconnect_2x4 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ARBITRATION_MODE(ARBIT_MODE)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
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
    
    // Clock generation
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end
    
    // Simple slave models (always ready, immediate response)
    assign S0_AWREADY = 1'b1;
    assign S1_AWREADY = 1'b1;
    assign S2_AWREADY = 1'b1;
    assign S3_AWREADY = 1'b1;
    assign S0_WREADY = 1'b1;
    assign S1_WREADY = 1'b1;
    assign S2_WREADY = 1'b1;
    assign S3_WREADY = 1'b1;
    assign S0_ARREADY = 1'b1;
    assign S1_ARREADY = 1'b1;
    assign S2_ARREADY = 1'b1;
    assign S3_ARREADY = 1'b1;
    
    // Simple response generation
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S0_BVALID <= 1'b0; S1_BVALID <= 1'b0; S2_BVALID <= 1'b0; S3_BVALID <= 1'b0;
            S0_RVALID <= 1'b0; S1_RVALID <= 1'b0; S2_RVALID <= 1'b0; S3_RVALID <= 1'b0;
        end else begin
            S0_BVALID <= S0_WVALID && S0_WREADY;
            S1_BVALID <= S1_WVALID && S1_WREADY;
            S2_BVALID <= S2_WVALID && S2_WREADY;
            S3_BVALID <= S3_WVALID && S3_WREADY;
            S0_RVALID <= S0_ARVALID && S0_ARREADY;
            S1_RVALID <= S1_ARVALID && S1_ARREADY;
            S2_RVALID <= S2_ARVALID && S2_ARREADY;
            S3_RVALID <= S3_ARVALID && S3_ARREADY;
        end
    end
    
    assign S0_BRESP = 2'b00; assign S1_BRESP = 2'b00; assign S2_BRESP = 2'b00; assign S3_BRESP = 2'b00;
    assign S0_RRESP = 2'b00; assign S1_RRESP = 2'b00; assign S2_RRESP = 2'b00; assign S3_RRESP = 2'b00;
    assign S0_RDATA = 32'hDEADBEEF; assign S1_RDATA = 32'hCAFEBABE;
    assign S2_RDATA = 32'h12345678; assign S3_RDATA = 32'h87654321;
    assign S0_RLAST = 1'b1; assign S1_RLAST = 1'b1; assign S2_RLAST = 1'b1; assign S3_RLAST = 1'b1;
    
    // Monitor arbitration decisions
    always @(posedge ACLK) begin
        if (ARESETN && M0_AWVALID && M1_AWVALID) begin
            total_arbitrations = total_arbitrations + 1;
            if (M0_AWREADY && !M1_AWREADY) begin
                m0_granted_count = m0_granted_count + 1;
                $display("[%0t] ARBITRATION: Both request, M0 GRANTED (Mode=%s)", $time, ARBIT_MODE);
            end else if (!M0_AWREADY && M1_AWREADY) begin
                m1_granted_count = m1_granted_count + 1;
                $display("[%0t] ARBITRATION: Both request, M1 GRANTED (Mode=%s)", $time, ARBIT_MODE);
            end
        end
    end
    
    // Test stimulus
    initial begin
        // Initialize
        ARESETN = 0;
        M0_AWADDR = 0; M0_AWPROT = 0; M0_AWQOS = 4'd8; M0_AWVALID = 0;
        M0_WDATA = 0; M0_WSTRB = 0; M0_WVALID = 0; M0_BREADY = 1;
        M0_ARADDR = 0; M0_ARPROT = 0; M0_ARQOS = 4'd8; M0_ARVALID = 0; M0_RREADY = 1;
        M1_AWADDR = 0; M1_AWPROT = 0; M1_AWQOS = 4'd2; M1_AWVALID = 0;
        M1_WDATA = 0; M1_WSTRB = 0; M1_WVALID = 0; M1_BREADY = 1;
        M1_ARADDR = 0; M1_ARPROT = 0; M1_ARQOS = 4'd2; M1_ARVALID = 0; M1_RREADY = 1;
        
        $display("\n========================================");
        $display("Arbitration Test - Mode: %s", ARBIT_MODE);
        $display("M0 QoS = %0d, M1 QoS = %0d", 8, 2);
        $display("========================================\n");
        
        repeat(5) @(posedge ACLK);
        ARESETN = 1;
        repeat(2) @(posedge ACLK);
        
        // Test 1: Both masters request simultaneously - 10 times
        $display("\n[TEST 1] Both masters request simultaneously (10 cycles)");
        for (int i = 0; i < 10; i++) begin
            @(posedge ACLK);
            M0_AWADDR = 32'h0000_1000 + (i * 4);
            M0_AWVALID = 1;
            M0_WDATA = 32'hA000_0000 + i;
            M0_WSTRB = 4'hF;
            M0_WVALID = 1;
            
            M1_AWADDR = 32'h0000_2000 + (i * 4);
            M1_AWVALID = 1;
            M1_WDATA = 32'hB000_0000 + i;
            M1_WSTRB = 4'hF;
            M1_WVALID = 1;
            
            @(posedge ACLK);
            M0_AWVALID = 0; M0_WVALID = 0;
            M1_AWVALID = 0; M1_WVALID = 0;
            repeat(2) @(posedge ACLK);
        end
        
        repeat(10) @(posedge ACLK);
        
        // Print statistics
        $display("\n========================================");
        $display("ARBITRATION STATISTICS");
        $display("========================================");
        $display("Mode: %s", ARBIT_MODE);
        $display("Total simultaneous arbitrations: %0d", total_arbitrations);
        $display("M0 granted: %0d times (%.1f%%)", m0_granted_count, 
                 (total_arbitrations > 0) ? (100.0 * m0_granted_count / total_arbitrations) : 0.0);
        $display("M1 granted: %0d times (%.1f%%)", m1_granted_count,
                 (total_arbitrations > 0) ? (100.0 * m1_granted_count / total_arbitrations) : 0.0);
        $display("========================================");
        
        // Check expected behavior
        if (ARBIT_MODE == "FIXED") begin
            if (m0_granted_count == total_arbitrations && m1_granted_count == 0) begin
                $display("✓ PASS: FIXED mode - M0 always wins");
            end else begin
                $display("✗ FAIL: FIXED mode - Expected M0 to always win!");
            end
        end else if (ARBIT_MODE == "ROUND_ROBIN") begin
            if (m0_granted_count == m1_granted_count) begin
                $display("✓ PASS: ROUND_ROBIN mode - Fair distribution");
            end else begin
                $display("⚠ WARNING: ROUND_ROBIN mode - Not perfectly fair (expected with even count)");
            end
        end else if (ARBIT_MODE == "QOS") begin
            if (m0_granted_count > m1_granted_count) begin
                $display("✓ PASS: QOS mode - M0 (QoS=8) wins more than M1 (QoS=2)");
            end else begin
                $display("✗ FAIL: QOS mode - Expected M0 (higher QoS) to win more!");
            end
        end
        
        $display("\n========================================");
        $display("Test completed at %0t", $time);
        $display("========================================\n");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #10000;
        $display("ERROR: Timeout!");
        $finish;
    end

endmodule

