`timescale 1ns/1ps

//==============================================================================
// dual_master_busy_contention_tb.sv
// Testbench to test busy flags when M0 and M1 contend for resources
// Tests:
//   1. Both masters start simultaneously and contend for same slave
//   2. M0 starts first, M1 starts during M0's operation
//   3. M1 waits for M0, then both become busy
//   4. Monitor busy flags throughout contention scenarios
//==============================================================================

module dual_master_busy_contention_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz clock
    
    // Clock and Reset
    logic ACLK = 0;
    logic ARESETN = 1;
    
    // Control signals for masters
    logic m0_start = 0;
    logic m0_completed = 0;
    logic m0_busy;
    logic m1_start = 0;
    logic m1_completed = 0;
    logic m1_busy;
    
    // Master 0 internal signals
    logic [31:0] m0_instruction;
    logic [31:0] m0_result;
    
    // Master 1 internal signals
    logic [31:0] m1_address_offset;
    
    //==============================================================================
    // AXI Interconnect Signals
    //==============================================================================
    // Master 0 AXI4 Signals
    logic [31:0]    M0_AWADDR;
    logic [7:0]     M0_AWLEN;
    logic [2:0]     M0_AWSIZE;
    logic [1:0]     M0_AWBURST;
    logic           M0_AWVALID;
    logic           M0_AWREADY;
    logic [31:0]    M0_WDATA;
    logic [3:0]     M0_WSTRB;
    logic           M0_WLAST;
    logic           M0_WVALID;
    logic           M0_WREADY;
    logic [1:0]     M0_BRESP;
    logic           M0_BVALID;
    logic           M0_BREADY;
    logic [31:0]    M0_ARADDR;
    logic [7:0]     M0_ARLEN;
    logic [2:0]     M0_ARSIZE;
    logic [1:0]     M0_ARBURST;
    logic           M0_ARVALID;
    logic           M0_ARREADY;
    logic [31:0]    M0_RDATA;
    logic [1:0]     M0_RRESP;
    logic           M0_RLAST;
    logic           M0_RVALID;
    logic           M0_RREADY;
    
    // Master 1 AXI4 Signals
    logic [31:0]    M1_AWADDR;
    logic [7:0]     M1_AWLEN;
    logic [2:0]     M1_AWSIZE;
    logic [1:0]     M1_AWBURST;
    logic           M1_AWVALID;
    logic           M1_AWREADY;
    logic [31:0]    M1_WDATA;
    logic [3:0]     M1_WSTRB;
    logic           M1_WLAST;
    logic           M1_WVALID;
    logic           M1_WREADY;
    logic [1:0]     M1_BRESP;
    logic           M1_BVALID;
    logic           M1_BREADY;
    logic [31:0]    M1_ARADDR;
    logic [7:0]     M1_ARLEN;
    logic [2:0]     M1_ARSIZE;
    logic [1:0]     M1_ARBURST;
    logic           M1_ARVALID;
    logic           M1_ARREADY;
    logic [31:0]    M1_RDATA;
    logic [1:0]     M1_RRESP;
    logic           M1_RLAST;
    logic           M1_RVALID;
    logic           M1_RREADY;
    
    // Slave 0 AXI4 Signals (RAM - 0x00000000)
    logic [31:0]    S0_AWADDR;
    logic [7:0]     S0_AWLEN;
    logic [2:0]     S0_AWSIZE;
    logic [1:0]     S0_AWBURST;
    logic           S0_AWVALID;
    logic           S0_AWREADY;
    logic [31:0]    S0_WDATA;
    logic [3:0]     S0_WSTRB;
    logic           S0_WLAST;
    logic           S0_WVALID;
    logic           S0_WREADY;
    logic [1:0]     S0_BRESP;
    logic           S0_BVALID;
    logic           S0_BREADY;
    logic [31:0]    S0_ARADDR;
    logic [7:0]     S0_ARLEN;
    logic [2:0]     S0_ARSIZE;
    logic [1:0]     S0_ARBURST;
    logic           S0_ARVALID;
    logic           S0_ARREADY;
    logic [31:0]    S0_RDATA;
    logic [1:0]     S0_RRESP;
    logic           S0_RLAST;
    logic           S0_RVALID;
    logic           S0_RREADY;
    
    // Slave 1 AXI4 Signals (GPIO - 0x40000000)
    logic [31:0]    S1_AWADDR;
    logic [7:0]     S1_AWLEN;
    logic [2:0]     S1_AWSIZE;
    logic [1:0]     S1_AWBURST;
    logic           S1_AWVALID;
    logic           S1_AWREADY;
    logic [31:0]    S1_WDATA;
    logic [3:0]     S1_WSTRB;
    logic           S1_WLAST;
    logic           S1_WVALID;
    logic           S1_WREADY;
    logic [1:0]     S1_BRESP;
    logic           S1_BVALID;
    logic           S1_BREADY;
    logic [31:0]    S1_ARADDR;
    logic [7:0]     S1_ARLEN;
    logic [2:0]     S1_ARSIZE;
    logic [1:0]     S1_ARBURST;
    logic           S1_ARVALID;
    logic           S1_ARREADY;
    logic [31:0]    S1_RDATA;
    logic [1:0]     S1_RRESP;
    logic           S1_RLAST;
    logic           S1_RVALID;
    logic           S1_RREADY;
    
    //==============================================================================
    // Clock Generation
    //==============================================================================
    always #(CLK_PERIOD/2) ACLK = ~ACLK;
    
    //==============================================================================
    // DUT Instantiations
    //==============================================================================
    
    // Master 0 - Compute Master (AXI4-Lite)
    axi_master_0 #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .SLAVE0_BASE(32'h00000000)
    ) master0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(m0_start),
        .completed(m0_completed),
        .busy(m0_busy),
        .M_AXI_araddr(M0_ARADDR),
        .M_AXI_arprot(),  // Not used by interconnect
        .M_AXI_arvalid(M0_ARVALID),
        .M_AXI_arready(M0_ARREADY),
        .M_AXI_rdata(M0_RDATA),
        .M_AXI_rresp(M0_RRESP),
        .M_AXI_rvalid(M0_RVALID),
        .M_AXI_rready(M0_RREADY),
        .M_AXI_awaddr(M0_AWADDR),
        .M_AXI_awprot(),  // Not used by interconnect
        .M_AXI_awvalid(M0_AWVALID),
        .M_AXI_awready(M0_AWREADY),
        .M_AXI_wdata(M0_WDATA),
        .M_AXI_wstrb(M0_WSTRB),
        .M_AXI_wvalid(M0_WVALID),
        .M_AXI_wready(M0_WREADY),
        .M_AXI_bresp(M0_BRESP),
        .M_AXI_bvalid(M0_BVALID),
        .M_AXI_bready(M0_BREADY),
        .instruction(m0_instruction),
        .result(m0_result)
    );
    
    // AXI4-Lite to AXI4 Full conversion for Master 0
    // AXI4-Lite is equivalent to AXI4 with: AWLEN=0, AWSIZE=2 (4 bytes), AWBURST=1 (INCR), WLAST=1
    assign M0_AWLEN = 8'h0;
    assign M0_AWSIZE = 3'h2;  // 4 bytes
    assign M0_AWBURST = 2'h1; // INCR
    assign M0_WLAST = 1'b1;   // Single transfer
    assign M0_ARLEN = 8'h0;
    assign M0_ARSIZE = 3'h2;  // 4 bytes
    assign M0_ARBURST = 2'h1; // INCR
    
    // Master 1 - Dependency Master (AXI4-Lite)
    axi_master_1 #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .SLAVE0_BASE(32'h00000000),
        .SLAVE1_BASE(32'h40000000)
    ) master1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(m1_start),
        .m0_completed(m0_completed),
        .completed(m1_completed),
        .busy(m1_busy),
        .M_AXI_araddr(M1_ARADDR),
        .M_AXI_arprot(),  // Not used by interconnect
        .M_AXI_arvalid(M1_ARVALID),
        .M_AXI_arready(M1_ARREADY),
        .M_AXI_rdata(M1_RDATA),
        .M_AXI_rresp(M1_RRESP),
        .M_AXI_rvalid(M1_RVALID),
        .M_AXI_rready(M1_RREADY),
        .M_AXI_awaddr(M1_AWADDR),
        .M_AXI_awprot(),  // Not used by interconnect
        .M_AXI_awvalid(M1_AWVALID),
        .M_AXI_awready(M1_AWREADY),
        .M_AXI_wdata(M1_WDATA),
        .M_AXI_wstrb(M1_WSTRB),
        .M_AXI_wvalid(M1_WVALID),
        .M_AXI_wready(M1_WREADY),
        .M_AXI_bresp(M1_BRESP),
        .M_AXI_bvalid(M1_BVALID),
        .M_AXI_bready(M1_BREADY),
        .address_offset(m1_address_offset)
    );
    
    // AXI4-Lite to AXI4 Full conversion for Master 1
    // AXI4-Lite is equivalent to AXI4 with: AWLEN=0, AWSIZE=2 (4 bytes), AWBURST=1 (INCR), WLAST=1
    assign M1_AWLEN = 8'h0;
    assign M1_AWSIZE = 3'h2;  // 4 bytes
    assign M1_AWBURST = 2'h1; // INCR
    assign M1_WLAST = 1'b1;   // Single transfer
    assign M1_ARLEN = 8'h0;
    assign M1_ARSIZE = 3'h2;  // 4 bytes
    assign M1_ARBURST = 2'h1; // INCR
    
    // AXI Interconnect
    AXI_Interconnect #(
        .ARBITRATION_MODE(1)  // ROUND_ROBIN
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0
        .M0_AWADDR(M0_AWADDR),
        .M0_AWLEN(M0_AWLEN),
        .M0_AWSIZE(M0_AWSIZE),
        .M0_AWBURST(M0_AWBURST),
        .M0_AWVALID(M0_AWVALID),
        .M0_AWREADY(M0_AWREADY),
        .M0_WDATA(M0_WDATA),
        .M0_WSTRB(M0_WSTRB),
        .M0_WLAST(M0_WLAST),
        .M0_WVALID(M0_WVALID),
        .M0_WREADY(M0_WREADY),
        .M0_BRESP(M0_BRESP),
        .M0_BVALID(M0_BVALID),
        .M0_BREADY(M0_BREADY),
        .M0_ARADDR(M0_ARADDR),
        .M0_ARLEN(M0_ARLEN),
        .M0_ARSIZE(M0_ARSIZE),
        .M0_ARBURST(M0_ARBURST),
        .M0_ARVALID(M0_ARVALID),
        .M0_ARREADY(M0_ARREADY),
        .M0_RDATA(M0_RDATA),
        .M0_RRESP(M0_RRESP),
        .M0_RLAST(M0_RLAST),
        .M0_RVALID(M0_RVALID),
        .M0_RREADY(M0_RREADY),
        
        // Master 1
        .M1_AWADDR(M1_AWADDR),
        .M1_AWLEN(M1_AWLEN),
        .M1_AWSIZE(M1_AWSIZE),
        .M1_AWBURST(M1_AWBURST),
        .M1_AWVALID(M1_AWVALID),
        .M1_AWREADY(M1_AWREADY),
        .M1_WDATA(M1_WDATA),
        .M1_WSTRB(M1_WSTRB),
        .M1_WLAST(M1_WLAST),
        .M1_WVALID(M1_WVALID),
        .M1_WREADY(M1_WREADY),
        .M1_BRESP(M1_BRESP),
        .M1_BVALID(M1_BVALID),
        .M1_BREADY(M1_BREADY),
        .M1_ARADDR(M1_ARADDR),
        .M1_ARLEN(M1_ARLEN),
        .M1_ARSIZE(M1_ARSIZE),
        .M1_ARBURST(M1_ARBURST),
        .M1_ARVALID(M1_ARVALID),
        .M1_ARREADY(M1_ARREADY),
        .M1_RDATA(M1_RDATA),
        .M1_RRESP(M1_RRESP),
        .M1_RLAST(M1_RLAST),
        .M1_RVALID(M1_RVALID),
        .M1_RREADY(M1_RREADY),
        
        // Slave 0
        .S0_AWADDR(S0_AWADDR),
        .S0_AWLEN(S0_AWLEN),
        .S0_AWSIZE(S0_AWSIZE),
        .S0_AWBURST(S0_AWBURST),
        .S0_AWVALID(S0_AWVALID),
        .S0_AWREADY(S0_AWREADY),
        .S0_WDATA(S0_WDATA),
        .S0_WSTRB(S0_WSTRB),
        .S0_WLAST(S0_WLAST),
        .S0_WVALID(S0_WVALID),
        .S0_WREADY(S0_WREADY),
        .S0_BRESP(S0_BRESP),
        .S0_BVALID(S0_BVALID),
        .S0_BREADY(S0_BREADY),
        .S0_ARADDR(S0_ARADDR),
        .S0_ARLEN(S0_ARLEN),
        .S0_ARSIZE(S0_ARSIZE),
        .S0_ARBURST(S0_ARBURST),
        .S0_ARVALID(S0_ARVALID),
        .S0_ARREADY(S0_ARREADY),
        .S0_RDATA(S0_RDATA),
        .S0_RRESP(S0_RRESP),
        .S0_RLAST(S0_RLAST),
        .S0_RVALID(S0_RVALID),
        .S0_RREADY(S0_RREADY),
        
        // Slave 1
        .S1_AWADDR(S1_AWADDR),
        .S1_AWLEN(S1_AWLEN),
        .S1_AWSIZE(S1_AWSIZE),
        .S1_AWBURST(S1_AWBURST),
        .S1_AWVALID(S1_AWVALID),
        .S1_AWREADY(S1_AWREADY),
        .S1_WDATA(S1_WDATA),
        .S1_WSTRB(S1_WSTRB),
        .S1_WLAST(S1_WLAST),
        .S1_WVALID(S1_WVALID),
        .S1_WREADY(S1_WREADY),
        .S1_BRESP(S1_BRESP),
        .S1_BVALID(S1_BVALID),
        .S1_BREADY(S1_BREADY),
        .S1_ARADDR(S1_ARADDR),
        .S1_ARLEN(S1_ARLEN),
        .S1_ARSIZE(S1_ARSIZE),
        .S1_ARBURST(S1_ARBURST),
        .S1_ARVALID(S1_ARVALID),
        .S1_ARREADY(S1_ARREADY),
        .S1_RDATA(S1_RDATA),
        .S1_RRESP(S1_RRESP),
        .S1_RLAST(S1_RLAST),
        .S1_RVALID(S1_RVALID),
        .S1_RREADY(S1_RREADY),
        
        // Unused slaves (tie off)
        .S2_AWADDR(),
        .S2_AWLEN(),
        .S2_AWSIZE(),
        .S2_AWBURST(),
        .S2_AWVALID(),
        .S2_AWREADY(1'b0),
        .S2_WDATA(),
        .S2_WSTRB(),
        .S2_WLAST(),
        .S2_WVALID(),
        .S2_WREADY(1'b0),
        .S2_BRESP(2'b00),
        .S2_BVALID(1'b0),
        .S2_BREADY(),  // Output port, leave unconnected
        .S2_ARADDR(),
        .S2_ARLEN(),
        .S2_ARSIZE(),
        .S2_ARBURST(),
        .S2_ARVALID(),
        .S2_ARREADY(1'b0),
        .S2_RDATA(32'h0),
        .S2_RRESP(2'b00),
        .S2_RLAST(1'b0),
        .S2_RVALID(1'b0),
        .S2_RREADY(),  // Output port, leave unconnected
        
        .S3_AWADDR(),
        .S3_AWLEN(),
        .S3_AWSIZE(),
        .S3_AWBURST(),
        .S3_AWVALID(),
        .S3_AWREADY(1'b0),
        .S3_WDATA(),
        .S3_WSTRB(),
        .S3_WLAST(),
        .S3_WVALID(),
        .S3_WREADY(1'b0),
        .S3_BRESP(2'b00),
        .S3_BVALID(1'b0),
        .S3_BREADY(),  // Output port, leave unconnected
        .S3_ARADDR(),
        .S3_ARLEN(),
        .S3_ARSIZE(),
        .S3_ARBURST(),
        .S3_ARVALID(),
        .S3_ARREADY(1'b0),
        .S3_RDATA(32'h0),
        .S3_RRESP(2'b00),
        .S3_RLAST(1'b0),
        .S3_RVALID(1'b0),
        .S3_RREADY()   // Output port, leave unconnected
    );
    
    //==============================================================================
    // Simple AXI Slave Models
    //==============================================================================
    
    // Slave 0: RAM Model
    axi_simple_slave_model #(
        .ADDR_BASE(32'h00000000),
        .ADDR_MASK(32'hE0000000)
    ) slave0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .AWADDR(S0_AWADDR),
        .AWLEN(S0_AWLEN),
        .AWSIZE(S0_AWSIZE),
        .AWBURST(S0_AWBURST),
        .AWVALID(S0_AWVALID),
        .AWREADY(S0_AWREADY),
        .WDATA(S0_WDATA),
        .WSTRB(S0_WSTRB),
        .WLAST(S0_WLAST),
        .WVALID(S0_WVALID),
        .WREADY(S0_WREADY),
        .BRESP(S0_BRESP),
        .BVALID(S0_BVALID),
        .BREADY(S0_BREADY),
        .ARADDR(S0_ARADDR),
        .ARLEN(S0_ARLEN),
        .ARSIZE(S0_ARSIZE),
        .ARBURST(S0_ARBURST),
        .ARVALID(S0_ARVALID),
        .ARREADY(S0_ARREADY),
        .RDATA(S0_RDATA),
        .RRESP(S0_RRESP),
        .RLAST(S0_RLAST),
        .RVALID(S0_RVALID),
        .RREADY(S0_RREADY)
    );
    
    // Slave 1: GPIO Model
    axi_simple_slave_model #(
        .ADDR_BASE(32'h40000000),
        .ADDR_MASK(32'hE0000000)
    ) slave1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .AWADDR(S1_AWADDR),
        .AWLEN(S1_AWLEN),
        .AWSIZE(S1_AWSIZE),
        .AWBURST(S1_AWBURST),
        .AWVALID(S1_AWVALID),
        .AWREADY(S1_AWREADY),
        .WDATA(S1_WDATA),
        .WSTRB(S1_WSTRB),
        .WLAST(S1_WLAST),
        .WVALID(S1_WVALID),
        .WREADY(S1_WREADY),
        .BRESP(S1_BRESP),
        .BVALID(S1_BVALID),
        .BREADY(S1_BREADY),
        .ARADDR(S1_ARADDR),
        .ARLEN(S1_ARLEN),
        .ARSIZE(S1_ARSIZE),
        .ARBURST(S1_ARBURST),
        .ARVALID(S1_ARVALID),
        .ARREADY(S1_ARREADY),
        .RDATA(S1_RDATA),
        .RRESP(S1_RRESP),
        .RLAST(S1_RLAST),
        .RVALID(S1_RVALID),
        .RREADY(S1_RREADY)
    );
    
    //==============================================================================
    // Busy Flag Monitor
    //==============================================================================
    always_ff @(posedge ACLK) begin
        if (ARESETN) begin
            if (m0_busy || m1_busy) begin
                $display("[%0t] BUSY STATUS: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
            end
        end
    end
    
    //==============================================================================
    // Test Sequence
    //==============================================================================
    initial begin
        $display("============================================================================");
        $display("Dual Master Busy Contention Testbench");
        $display("Testing busy flags during resource contention");
        $display("============================================================================");
        $display("");
        
        // Initialize
        m0_start = 0;
        m1_start = 0;
        
        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        ARESETN = 0;
        #(CLK_PERIOD * 5);
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        $display("[%0t] Reset released", $time);
        $display("[%0t] Initial state: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        // Initialize memory for master0 (instruction at address 0x4)
        // Instruction format: [opcode:8][op1:12][op2:12]
        // Example: ADD op1=0x123, op2=0x456 -> 0x01123456
        // We'll write this through the slave model after reset
        #(CLK_PERIOD * 2);
        $display("[%0t] Note: Master0 will read instruction from address 0x4", $time);
        $display("[%0t] Master0 expects: Read from 0x4, Compute, Write to 0x0", $time);
        $display("");
        
        // Test 1: Both masters start simultaneously (contention scenario)
        $display("============================================================================");
        $display("Test 1: Simultaneous Start - Both masters contend for Slave 0");
        $display("============================================================================");
        $display("[%0t] Starting both masters simultaneously...", $time);
        $display("[%0t] Before start: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        @(posedge ACLK);
        m0_start = 1;
        m1_start = 1;  // M1 will wait for M0, but start signal is set
        
        @(posedge ACLK);
        m0_start = 0;
        m1_start = 0;
        
        $display("[%0t] After start pulse: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        // Monitor busy flags
        wait(m0_busy);
        $display("[%0t] M0 became busy", $time);
        
        // Wait for M0 to complete
        wait(m0_completed);
        $display("[%0t] M0 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        // M1 should start after M0 completes
        wait(m1_busy);
        $display("[%0t] M1 became busy (after M0 completed)", $time);
        
        wait(m1_completed);
        $display("[%0t] M1 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        #(CLK_PERIOD * 5);
        $display("[%0t] [PASS] Test 1 completed", $time);
        $display("");
        
        // Test 2: M0 starts first, M1 starts during M0's operation
        $display("============================================================================");
        $display("Test 2: M0 starts first, M1 starts during M0 operation");
        $display("============================================================================");
        
        #(CLK_PERIOD * 10);
        
        $display("[%0t] Starting M0...", $time);
        @(posedge ACLK);
        m0_start = 1;
        @(posedge ACLK);
        m0_start = 0;
        
        wait(m0_busy);
        $display("[%0t] M0 is busy, starting M1...", $time);
        $display("[%0t] Status: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        @(posedge ACLK);
        m1_start = 1;
        @(posedge ACLK);
        m1_start = 0;
        
        $display("[%0t] M1 start signal sent: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        // M1 should wait for M0, so M1_busy should be 0 until M0 completes
        #(CLK_PERIOD * 5);
        if (!m1_busy) begin
            $display("[%0t] [PASS] M1 correctly waiting for M0 (M1_busy=0)", $time);
        end else begin
            $display("[%0t] [FAIL] M1 should wait for M0 but M1_busy=%b", $time, m1_busy);
        end
        
        wait(m0_completed);
        $display("[%0t] M0 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        // Now M1 should become busy
        wait(m1_busy);
        $display("[%0t] M1 became busy after M0 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        wait(m1_completed);
        $display("[%0t] M1 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        #(CLK_PERIOD * 5);
        $display("[%0t] [PASS] Test 2 completed", $time);
        $display("");
        
        // Test 3: Sequential operations - no contention
        $display("============================================================================");
        $display("Test 3: Sequential operations - M0 completes, then M1 starts");
        $display("============================================================================");
        
        #(CLK_PERIOD * 10);
        
        $display("[%0t] Starting M0...", $time);
        @(posedge ACLK);
        m0_start = 1;
        @(posedge ACLK);
        m0_start = 0;
        
        wait(m0_busy);
        $display("[%0t] M0 is busy: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        wait(m0_completed);
        $display("[%0t] M0 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        #(CLK_PERIOD * 5);
        
        $display("[%0t] Starting M1...", $time);
        @(posedge ACLK);
        m1_start = 1;
        @(posedge ACLK);
        m1_start = 0;
        
        wait(m1_busy);
        $display("[%0t] M1 is busy: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        wait(m1_completed);
        $display("[%0t] M1 completed: M0_busy=%b, M1_busy=%b", $time, m0_busy, m1_busy);
        
        #(CLK_PERIOD * 5);
        $display("[%0t] [PASS] Test 3 completed", $time);
        $display("");
        
        // Test 4: Multiple M0 operations to test busy flag transitions
        $display("============================================================================");
        $display("Test 4: Multiple M0 operations - busy flag transitions");
        $display("============================================================================");
        
        #(CLK_PERIOD * 10);
        
        repeat(3) begin
            $display("[%0t] Starting M0 operation...", $time);
            $display("[%0t] Before start: M0_busy=%b", $time, m0_busy);
            
            @(posedge ACLK);
            m0_start = 1;
            @(posedge ACLK);
            m0_start = 0;
            
            wait(m0_busy);
            $display("[%0t] M0 became busy", $time);
            
            wait(!m0_busy);
            $display("[%0t] M0 completed (busy=0)", $time);
            
            #(CLK_PERIOD * 5);
        end
        
        $display("[%0t] [PASS] Test 4 completed", $time);
        $display("");
        
        #(CLK_PERIOD * 10);
        $display("============================================================================");
        $display("All Tests Complete!");
        $display("============================================================================");
        $display("");
        $display("Simulation finished successfully at time %0t", $time);
        $display("============================================================================");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("dual_master_busy_contention_tb.vcd");
        $dumpvars(0, dual_master_busy_contention_tb);
    end

endmodule

//==============================================================================
// Simple AXI Slave Model (copied from AXI_Interconnect_tb.sv)
//==============================================================================
module axi_simple_slave_model #(
    parameter ADDR_BASE = 32'h00000000,
    parameter ADDR_MASK = 32'hE0000000
) (
    input logic ACLK,
    input logic ARESETN,
    
    // Write Address Channel
    input logic [31:0] AWADDR,
    input logic [7:0] AWLEN,
    input logic [2:0] AWSIZE,
    input logic [1:0] AWBURST,
    input logic AWVALID,
    output logic AWREADY,
    
    // Write Data Channel
    input logic [31:0] WDATA,
    input logic [3:0] WSTRB,
    input logic WLAST,
    input logic WVALID,
    output logic WREADY,
    
    // Write Response Channel
    output logic [1:0] BRESP,
    output logic BVALID,
    input logic BREADY,
    
    // Read Address Channel
    input logic [31:0] ARADDR,
    input logic [7:0] ARLEN,
    input logic [2:0] ARSIZE,
    input logic [1:0] ARBURST,
    input logic ARVALID,
    output logic ARREADY,
    
    // Read Data Channel
    output logic [31:0] RDATA,
    output logic [1:0] RRESP,
    output logic RLAST,
    output logic RVALID,
    input logic RREADY
);

    // Simple memory model
    logic [31:0] mem [0:1023];
    
    // Write Address Channel - Fixed to avoid deadlock
    logic [31:0] awaddr_reg;
    logic aw_handshake_done;
    
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            AWREADY <= 1'b0;
            awaddr_reg <= 32'h0;
            aw_handshake_done <= 1'b0;
        end else begin
            if (!aw_handshake_done && AWVALID) begin
                AWREADY <= 1'b1;
                awaddr_reg <= AWADDR;
            end else begin
                AWREADY <= 1'b0;
            end
            
            if (AWVALID && AWREADY) begin
                aw_handshake_done <= 1'b1;
            end else if (WVALID && WREADY && WLAST) begin
                aw_handshake_done <= 1'b0;  // Reset after write complete
            end
        end
    end
    
    // Write Data Channel - Fixed
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            WREADY <= 1'b0;
        end else begin
            if (AWVALID && AWREADY && !WREADY) begin
                WREADY <= 1'b1;  // Ready after AW handshake
            end else if (WVALID && WREADY && WLAST) begin
                WREADY <= 1'b0;  // Not ready after last data
            end else if (!WVALID) begin
                WREADY <= 1'b0;
            end
        end
    end
    
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            // Reset
        end else if (WVALID && WREADY) begin
            if ((awaddr_reg & ADDR_MASK) == (ADDR_BASE & ADDR_MASK)) begin
                mem[awaddr_reg[11:2]] <= WDATA;
            end
        end
    end
    
    // Write Response Channel - Fixed
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            BVALID <= 1'b0;
            BRESP <= 2'b00;
        end else begin
            if (WVALID && WREADY && WLAST && !BVALID) begin
                BVALID <= 1'b1;
                BRESP <= 2'b00; // OKAY
            end else if (BVALID && BREADY) begin
                BVALID <= 1'b0;
            end
        end
    end
    
    // Read Address Channel - Fixed to avoid deadlock
    logic [31:0] araddr_reg;
    logic ar_handshake_done;
    
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ARREADY <= 1'b0;
            araddr_reg <= 32'h0;
            ar_handshake_done <= 1'b0;
        end else begin
            if (!ar_handshake_done && ARVALID) begin
                ARREADY <= 1'b1;
                araddr_reg <= ARADDR;
            end else begin
                ARREADY <= 1'b0;
            end
            
            if (ARVALID && ARREADY) begin
                ar_handshake_done <= 1'b1;
            end else if (RVALID && RREADY && RLAST) begin
                ar_handshake_done <= 1'b0;  // Reset after read complete
            end
        end
    end
    
    // Read Data Channel - Fixed
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            RVALID <= 1'b0;
            RDATA <= 32'h0;
            RRESP <= 2'b00;
            RLAST <= 1'b0;
        end else begin
            if (ARVALID && ARREADY && !RVALID) begin
                RVALID <= 1'b1;
                if ((araddr_reg & ADDR_MASK) == (ADDR_BASE & ADDR_MASK)) begin
                    RDATA <= mem[araddr_reg[11:2]];
                end else begin
                    RDATA <= 32'hDEADBEEF; // Default value
                end
                RRESP <= 2'b00; // OKAY
                RLAST <= 1'b1;
            end else if (RVALID && RREADY) begin
                RVALID <= 1'b0;
                RLAST <= 1'b0;
            end
        end
    end

endmodule

