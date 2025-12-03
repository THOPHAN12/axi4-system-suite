//=============================================================================
// arb_test_verilog.v
// Testbench for Verilog version - tests all 3 arbitration modes
// Compatible with Verilog-2001 and all simulators
//=============================================================================

`timescale 1ns/1ps

module arb_test_verilog;

    // Test configuration - Change this to test different modes
    // 0 = FIXED, 1 = ROUND_ROBIN, 2 = QOS
    parameter ARBIT_MODE = 1;  
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10;
    
    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    
    // Master 0 Write Channel
    reg [ADDR_WIDTH-1:0]      M0_AWADDR;
    reg [2:0]                 M0_AWPROT;
    reg [3:0]                 M0_AWQOS;
    reg                       M0_AWVALID;
    wire                      M0_AWREADY;
    reg [DATA_WIDTH-1:0]      M0_WDATA;
    reg [(DATA_WIDTH/8)-1:0]  M0_WSTRB;
    reg                       M0_WVALID;
    wire                      M0_WREADY;
    wire [1:0]                M0_BRESP;
    wire                      M0_BVALID;
    reg                       M0_BREADY;
    
    // Master 0 Read Channel
    reg [ADDR_WIDTH-1:0]      M0_ARADDR;
    reg [2:0]                 M0_ARPROT;
    reg [3:0]                 M0_ARQOS;
    reg                       M0_ARVALID;
    wire                      M0_ARREADY;
    wire [DATA_WIDTH-1:0]     M0_RDATA;
    wire [1:0]                M0_RRESP;
    wire                      M0_RVALID;
    wire                      M0_RLAST;
    reg                       M0_RREADY;
    
    // Master 1 Write Channel
    reg [ADDR_WIDTH-1:0]      M1_AWADDR;
    reg [2:0]                 M1_AWPROT;
    reg [3:0]                 M1_AWQOS;
    reg                       M1_AWVALID;
    wire                      M1_AWREADY;
    reg [DATA_WIDTH-1:0]      M1_WDATA;
    reg [(DATA_WIDTH/8)-1:0]  M1_WSTRB;
    reg                       M1_WVALID;
    wire                      M1_WREADY;
    wire [1:0]                M1_BRESP;
    wire                      M1_BVALID;
    reg                       M1_BREADY;
    
    // Master 1 Read Channel
    reg [ADDR_WIDTH-1:0]      M1_ARADDR;
    reg [2:0]                 M1_ARPROT;
    reg [3:0]                 M1_ARQOS;
    reg                       M1_ARVALID;
    wire                      M1_ARREADY;
    wire [DATA_WIDTH-1:0]     M1_RDATA;
    wire [1:0]                M1_RRESP;
    wire                      M1_RVALID;
    wire                      M1_RLAST;
    reg                       M1_RREADY;
    
    // Slave ports (4 slaves) - simplified
    wire [ADDR_WIDTH-1:0]      S0_AWADDR, S1_AWADDR, S2_AWADDR, S3_AWADDR;
    wire [2:0]                 S0_AWPROT, S1_AWPROT, S2_AWPROT, S3_AWPROT;
    wire                       S0_AWVALID, S1_AWVALID, S2_AWVALID, S3_AWVALID;
    reg                        S0_AWREADY, S1_AWREADY, S2_AWREADY, S3_AWREADY;
    wire [DATA_WIDTH-1:0]      S0_WDATA, S1_WDATA, S2_WDATA, S3_WDATA;
    wire [(DATA_WIDTH/8)-1:0]  S0_WSTRB, S1_WSTRB, S2_WSTRB, S3_WSTRB;
    wire                       S0_WVALID, S1_WVALID, S2_WVALID, S3_WVALID;
    reg                        S0_WREADY, S1_WREADY, S2_WREADY, S3_WREADY;
    reg [1:0]                  S0_BRESP, S1_BRESP, S2_BRESP, S3_BRESP;
    reg                        S0_BVALID, S1_BVALID, S2_BVALID, S3_BVALID;
    wire                       S0_BREADY, S1_BREADY, S2_BREADY, S3_BREADY;
    wire [ADDR_WIDTH-1:0]      S0_ARADDR, S1_ARADDR, S2_ARADDR, S3_ARADDR;
    wire [2:0]                 S0_ARPROT, S1_ARPROT, S2_ARPROT, S3_ARPROT;
    wire                       S0_ARVALID, S1_ARVALID, S2_ARVALID, S3_ARVALID;
    reg                        S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
    reg [DATA_WIDTH-1:0]       S0_RDATA, S1_RDATA, S2_RDATA, S3_RDATA;
    reg [1:0]                  S0_RRESP, S1_RRESP, S2_RRESP, S3_RRESP;
    reg                        S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
    reg                        S0_RLAST, S1_RLAST, S2_RLAST, S3_RLAST;
    wire                       S0_RREADY, S1_RREADY, S2_RREADY, S3_RREADY;
    
    // Statistics
    integer m0_granted_count;
    integer m1_granted_count;
    integer total_tests;
    
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
    
    // Simple slave models (always ready)
    initial begin
        S0_AWREADY = 1; S1_AWREADY = 1; S2_AWREADY = 1; S3_AWREADY = 1;
        S0_WREADY = 1; S1_WREADY = 1; S2_WREADY = 1; S3_WREADY = 1;
        S0_ARREADY = 1; S1_ARREADY = 1; S2_ARREADY = 1; S3_ARREADY = 1;
        S0_BRESP = 0; S1_BRESP = 0; S2_BRESP = 0; S3_BRESP = 0;
        S0_RRESP = 0; S1_RRESP = 0; S2_RRESP = 0; S3_RRESP = 0;
        S0_RDATA = 32'hDEAD0000; S1_RDATA = 32'hDEAD0001;
        S2_RDATA = 32'hDEAD0002; S3_RDATA = 32'hDEAD0003;
        S0_RLAST = 1; S1_RLAST = 1; S2_RLAST = 1; S3_RLAST = 1;
    end
    
    // Simple response generation
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S0_BVALID <= 0; S1_BVALID <= 0; S2_BVALID <= 0; S3_BVALID <= 0;
            S0_RVALID <= 0; S1_RVALID <= 0; S2_RVALID <= 0; S3_RVALID <= 0;
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
    
    // Monitor arbitration
    always @(posedge ACLK) begin
        if (ARESETN && M0_AWVALID && M0_AWREADY) begin
            m0_granted_count = m0_granted_count + 1;
            $display("[%0t] M0 Write granted (total=%0d)", $time, m0_granted_count);
        end
        if (ARESETN && M1_AWVALID && M1_AWREADY) begin
            m1_granted_count = m1_granted_count + 1;
            $display("[%0t] M1 Write granted (total=%0d)", $time, m1_granted_count);
        end
    end
    
    // Test stimulus
    initial begin
        // Display mode
        $display("\n========================================");
        case (ARBIT_MODE)
            0: $display("ARBITRATION TEST: FIXED PRIORITY");
            1: $display("ARBITRATION TEST: ROUND_ROBIN");
            2: $display("ARBITRATION TEST: QOS");
            default: $display("ARBITRATION TEST: UNKNOWN MODE");
        endcase
        $display("========================================\n");
        
        // Initialize
        ARESETN = 0;
        m0_granted_count = 0;
        m1_granted_count = 0;
        total_tests = 10;
        
        M0_AWADDR = 0; M0_AWPROT = 0; M0_AWQOS = 4'd10; M0_AWVALID = 0;
        M0_WDATA = 0; M0_WSTRB = 0; M0_WVALID = 0; M0_BREADY = 1;
        M0_ARADDR = 0; M0_ARPROT = 0; M0_ARQOS = 4'd10; M0_ARVALID = 0; M0_RREADY = 1;
        
        M1_AWADDR = 0; M1_AWPROT = 0; M1_AWQOS = 4'd2; M1_AWVALID = 0;
        M1_WDATA = 0; M1_WSTRB = 0; M1_WVALID = 0; M1_BREADY = 1;
        M1_ARADDR = 0; M1_ARPROT = 0; M1_ARQOS = 4'd2; M1_ARVALID = 0; M1_RREADY = 1;
        
        repeat(5) @(posedge ACLK);
        ARESETN = 1;
        repeat(3) @(posedge ACLK);
        
        // Test: Both masters request simultaneously
        $display("[TEST] Both masters request %0d times", total_tests);
        repeat(total_tests) begin
            @(posedge ACLK);
            // M0 write to slave 0
            M0_AWADDR = 32'h0000_1000;
            M0_AWVALID = 1;
            M0_WDATA = 32'hAAAA_0000;
            M0_WSTRB = 4'hF;
            M0_WVALID = 1;
            
            // M1 write to slave 1
            M1_AWADDR = 32'h4000_2000;
            M1_AWVALID = 1;
            M1_WDATA = 32'hBBBB_0000;
            M1_WSTRB = 4'hF;
            M1_WVALID = 1;
            
            @(posedge ACLK);
            M0_AWVALID = 0; M0_WVALID = 0;
            M1_AWVALID = 0; M1_WVALID = 0;
            
            repeat(4) @(posedge ACLK);
        end
        
        repeat(10) @(posedge ACLK);
        
        // Results
        $display("\n========================================");
        $display("RESULTS");
        $display("========================================");
        $display("Mode: %s", 
            (ARBIT_MODE == 0) ? "FIXED" : 
            (ARBIT_MODE == 1) ? "ROUND_ROBIN" : "QOS");
        $display("M0 QoS=%0d, M1 QoS=%0d", 10, 2);
        $display("M0 granted: %0d times", m0_granted_count);
        $display("M1 granted: %0d times", m1_granted_count);
        
        // Check results
        case (ARBIT_MODE)
            0: begin // FIXED
                if (m0_granted_count == total_tests && m1_granted_count == 0)
                    $display(">>> PASS: FIXED mode works (M0 always wins)");
                else
                    $display(">>> FAIL: Expected M0=%0d, M1=0", total_tests);
            end
            1: begin // ROUND_ROBIN
                if (m0_granted_count == total_tests/2 && m1_granted_count == total_tests/2)
                    $display(">>> PASS: ROUND_ROBIN mode works (fair 50/50)");
                else
                    $display(">>> CHECK: Expected M0=%0d, M1=%0d for perfect fairness", 
                        total_tests/2, total_tests/2);
            end
            2: begin // QOS
                if (m0_granted_count == total_tests && m1_granted_count == 0)
                    $display(">>> PASS: QOS mode works (M0 QoS=10 > M1 QoS=2)");
                else
                    $display(">>> FAIL: Expected M0=%0d, M1=0 (M0 has higher QoS)", total_tests);
            end
        endcase
        
        $display("========================================\n");
        $finish;
    end
    
    // Timeout
    initial begin
        #50000;
        $display("ERROR: Timeout!");
        $finish;
    end

endmodule


