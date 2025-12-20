`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////////////
// Testcase 1: M0 win giao tiếp với GPIO
// Description: Test arbitration when both M0 and M1 request GPIO simultaneously
//              Expected: M0 wins arbitration and successfully communicates with GPIO
////////////////////////////////////////////////////////////////////////////////

module testcase5_m0_gpio;

    parameter CLK_PERIOD = 10;
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH = 4;
    // Slave addresses
    parameter GPIO_BASE    = 32'h40000000;
    parameter GPIO_END     = 32'h5FFFFFFF;
    
    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    
    // Master 0 (S00) AXI signals
    reg  [ADDR_WIDTH-1:0]       S00_AXI_araddr;
    reg  [7:0]                  S00_AXI_arlen;
    reg  [2:0]                  S00_AXI_arsize;
    reg  [1:0]                  S00_AXI_arburst;
    reg                         S00_AXI_arvalid;
    wire                        S00_AXI_arready;
    wire [DATA_WIDTH-1:0]       S00_AXI_rdata;
    wire [1:0]                  S00_AXI_rresp;
    wire                        S00_AXI_rlast;
    wire                        S00_AXI_rvalid;
    reg                         S00_AXI_rready;
    
    // Master 1 (S01) AXI signals
    reg  [ADDR_WIDTH-1:0]       S01_AXI_araddr;
    reg  [7:0]                  S01_AXI_arlen;
    reg  [2:0]                  S01_AXI_arsize;
    reg  [1:0]                  S01_AXI_arburst;
    reg                         S01_AXI_arvalid;
    wire                        S01_AXI_arready;
    wire [DATA_WIDTH-1:0]       S01_AXI_rdata;
    wire [1:0]                  S01_AXI_rresp;
    wire                        S01_AXI_rlast;
    wire                        S01_AXI_rvalid;
    reg                         S01_AXI_rready;
    
    // Slave 0 (GPIO) AXI signals
    wire [ADDR_WIDTH-1:0]       M01_AXI_araddr;
    wire [7:0]                  M01_AXI_arlen;
    wire [2:0]                  M01_AXI_arsize;
    wire [1:0]                  M01_AXI_arburst;
    wire                        M01_AXI_arvalid;
    reg                         M01_AXI_arready;
    reg  [DATA_WIDTH-1:0]       M01_AXI_rdata;
    reg  [1:0]                  M01_AXI_rresp;
    reg                         M01_AXI_rlast;
    reg                         M01_AXI_rvalid;
    wire                        M01_AXI_rready;
    
    // AXI Interconnect
    AXI_Interconnect_Full #(
        .ARBITRATION_MODE(1)  // Round-Robin
    ) u_interconnect (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        .M03_ACLK(ACLK),
        .M03_ARESETN(ARESETN),
        // Master 0
        .S00_AXI_araddr(S00_AXI_araddr),
        .S00_AXI_arlen(S00_AXI_arlen),
        .S00_AXI_arsize(S00_AXI_arsize),
        .S00_AXI_arburst(S00_AXI_arburst),
        .S00_AXI_arvalid(S00_AXI_arvalid),
        .S00_AXI_arready(S00_AXI_arready),
        .S00_AXI_rdata(S00_AXI_rdata),
        .S00_AXI_rresp(S00_AXI_rresp),
        .S00_AXI_rlast(S00_AXI_rlast),
        .S00_AXI_rvalid(S00_AXI_rvalid),
        .S00_AXI_rready(S00_AXI_rready),
        // Master 1
        .S01_AXI_araddr(S01_AXI_araddr),
        .S01_AXI_arlen(S01_AXI_arlen),
        .S01_AXI_arsize(S01_AXI_arsize),
        .S01_AXI_arburst(S01_AXI_arburst),
        .S01_AXI_arvalid(S01_AXI_arvalid),
        .S01_AXI_arready(S01_AXI_arready),
        .S01_AXI_rdata(S01_AXI_rdata),
        .S01_AXI_rresp(S01_AXI_rresp),
        .S01_AXI_rlast(S01_AXI_rlast),
        .S01_AXI_rvalid(S01_AXI_rvalid),
        .S01_AXI_rready(S01_AXI_rready),
        // Slave 0 (GPIO)
        .M01_AXI_araddr(M01_AXI_araddr),
        .M01_AXI_arlen(M01_AXI_arlen),
        .M01_AXI_arsize(M01_AXI_arsize),
        .M01_AXI_arburst(M01_AXI_arburst),
        .M01_AXI_arvalid(M01_AXI_arvalid),
        .M01_AXI_arready(M01_AXI_arready),
        .M01_AXI_rdata(M01_AXI_rdata),
        .M01_AXI_rresp(M01_AXI_rresp),
        .M01_AXI_rlast(M01_AXI_rlast),
        .M01_AXI_rvalid(M01_AXI_rvalid),
        .M01_AXI_rready(M01_AXI_rready),
        // Address ranges
        .slave0_addr1(32'h00000000),
        .slave0_addr2(32'h1FFFFFFF),
        .slave1_addr1(GPIO_BASE),
        .slave1_addr2(GPIO_END),
        .slave2_addr1(32'h80000000),
        .slave2_addr2(32'hBFFFFFFF),
        .slave3_addr1(32'hC0000000),
        .slave3_addr2(32'hFFFFFFFF)
    );
    
    // GPIO Slave Model
    reg [DATA_WIDTH-1:0] gpio_reg;
    
    initial begin
        gpio_reg = 32'h12345678;
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M01_AXI_arready <= 1'b0;
            M01_AXI_rvalid <= 1'b0;
            M01_AXI_rlast <= 1'b0;
        end else begin
            if (M01_AXI_arvalid && !M01_AXI_arready) begin
                M01_AXI_arready <= 1'b1;
            end else begin
                M01_AXI_arready <= 1'b0;
            end
            
            if (M01_AXI_arready && M01_AXI_arvalid) begin
                M01_AXI_rvalid <= 1'b1;
                M01_AXI_rlast <= 1'b1;
                M01_AXI_rdata <= gpio_reg;
                M01_AXI_rresp <= 2'b00;
            end else if (M01_AXI_rvalid && M01_AXI_rready) begin
                M01_AXI_rvalid <= 1'b0;
                M01_AXI_rlast <= 1'b0;
            end
        end
    end
    
    // Test Variables
    integer test_pass;
    integer m0_win_count;
    integer m1_win_count;
    integer m0_read_count;
    integer m1_read_count;
    integer conflict_count;
    
    // Clock Generation
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end
    
    // Test Stimulus
    initial begin
        $display("========================================");
        $display("TESTCASE 1: M0 win giao tiếp với GPIO");
        $display("========================================");
        
        // Initialize
        ARESETN = 0;
        S00_AXI_arvalid = 1'b0;
        S01_AXI_arvalid = 1'b0;
        S00_AXI_rready = 1'b1;
        S01_AXI_rready = 1'b1;
        test_pass = 1;
        m0_win_count = 0;
        m1_win_count = 0;
        m0_read_count = 0;
        m1_read_count = 0;
        conflict_count = 0;
        
        // Reset
        repeat(10) @(posedge ACLK);
        ARESETN = 1;
        repeat(5) @(posedge ACLK);
        
        $display("[%0t] Test started: Both M0 and M1 will request GPIO simultaneously", $time);
        
        // Monitor arbitration
        fork
            begin
                forever @(posedge ACLK) begin
                    if (S00_AXI_arvalid && S01_AXI_arvalid && 
                        (S00_AXI_araddr >= GPIO_BASE && S00_AXI_araddr <= GPIO_END) &&
                        (S01_AXI_araddr >= GPIO_BASE && S01_AXI_araddr <= GPIO_END)) begin
                        conflict_count = conflict_count + 1;
                        if (S00_AXI_arready && !S01_AXI_arready) begin
                            $display("[%0t] [ARB] M0 WINS arbitration for GPIO (conflict #%0d)", $time, conflict_count);
                            m0_win_count = m0_win_count + 1;
                        end else if (!S00_AXI_arready && S01_AXI_arready) begin
                            $display("[%0t] [ARB] M1 WINS arbitration for GPIO (conflict #%0d)", $time, conflict_count);
                            m1_win_count = m1_win_count + 1;
                        end
                    end
                    if (S00_AXI_arvalid && S00_AXI_arready) begin
                        $display("[%0t] [M0] Read request accepted: addr=0x%08h", $time, S00_AXI_araddr);
                        m0_read_count = m0_read_count + 1;
                    end
                    if (S00_AXI_rvalid && S00_AXI_rready && S00_AXI_rlast) begin
                        $display("[%0t] [M0] Read complete: data=0x%08h, resp=%0d", $time, S00_AXI_rdata, S00_AXI_rresp);
                    end
                    if (S01_AXI_arvalid && S01_AXI_arready) begin
                        $display("[%0t] [M1] Read request accepted: addr=0x%08h", $time, S01_AXI_araddr);
                        m1_read_count = m1_read_count + 1;
                    end
                    if (S01_AXI_rvalid && S01_AXI_rready && S01_AXI_rlast) begin
                        $display("[%0t] [M1] Read complete: data=0x%08h, resp=%0d", $time, S01_AXI_rdata, S01_AXI_rresp);
                    end
                end
            end
        join
        
        // Create simultaneous requests
        repeat(5) begin
            @(posedge ACLK);
            S00_AXI_araddr = GPIO_BASE;
            S00_AXI_arlen = 8'h0;
            S00_AXI_arsize = 3'b010;
            S00_AXI_arburst = 2'b01;
            S00_AXI_arvalid = 1'b1;
            
            S01_AXI_araddr = GPIO_BASE + 4;
            S01_AXI_arlen = 8'h0;
            S01_AXI_arsize = 3'b010;
            S01_AXI_arburst = 2'b01;
            S01_AXI_arvalid = 1'b1;
            
            wait(S00_AXI_arready || S01_AXI_arready);
            @(posedge ACLK);
            S00_AXI_arvalid = 1'b0;
            S01_AXI_arvalid = 1'b0;
            repeat(10) @(posedge ACLK);
        end
        
        repeat(100) @(posedge ACLK);
        
        // Check results
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] TEST RESULTS", $time);
        $display("[%0t] ========================================", $time);
        $display("[%0t] Conflicts detected: %0d", $time, conflict_count);
        $display("[%0t] M0 read transactions: %0d", $time, m0_read_count);
        $display("[%0t] M1 read transactions: %0d", $time, m1_read_count);
        $display("[%0t] M0 arbitration wins: %0d", $time, m0_win_count);
        $display("[%0t] M1 arbitration wins: %0d", $time, m1_win_count);
        
        if (m0_read_count > 0 && m0_win_count > 0) begin
            $display("[%0t] TEST PASSED: M0 successfully communicated with GPIO", $time);
        end else begin
            $display("[%0t] TEST FAILED: M0 did not win arbitration or communicate", $time);
            test_pass = 0;
        end
        
        $display("[%0t] ========================================\n", $time);
        
        #100;
        $finish;
    end

endmodule

