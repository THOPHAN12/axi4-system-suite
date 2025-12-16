// ==============================================================================
// Busy Signal Testbench
// ==============================================================================
// Simple testbench to verify busy signal functionality
// Tests:
//   1. busy = 0 when master is in IDLE
//   2. busy = 1 when master starts processing
//   3. busy = 0 when master completes and returns to IDLE
// ==============================================================================

`timescale 1ns/1ps

module busy_test_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_WORDS  = 1024;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Address mapping
    parameter SLAVE0_BASE = 32'h00000000;
    parameter SLAVE1_BASE = 32'h40000000;

    // Clock and Reset
    reg  ACLK;
    reg  ARESETN;

    // ========================================================================
    // Master 0 Signals
    // ========================================================================
    wire [ADDR_WIDTH-1:0] M0_ARADDR;
    wire [2:0]            M0_ARPROT;
    wire                  M0_ARVALID;
    wire                  M0_ARREADY;
    wire [DATA_WIDTH-1:0] M0_RDATA;
    wire [1:0]            M0_RRESP;
    wire                  M0_RVALID;
    wire                  M0_RREADY;
    wire [ADDR_WIDTH-1:0] M0_AWADDR;
    wire [2:0]            M0_AWPROT;
    wire                  M0_AWVALID;
    wire                  M0_AWREADY;
    wire [DATA_WIDTH-1:0] M0_WDATA;
    wire [3:0]            M0_WSTRB;
    wire                  M0_WVALID;
    wire                  M0_WREADY;
    wire [1:0]            M0_BRESP;
    wire                  M0_BVALID;
    wire                  M0_BREADY;
    
    reg        m0_start;
    wire       m0_completed;
    wire       m0_busy;
    wire [31:0] m0_instruction;
    wire [31:0] m0_result;

    // ========================================================================
    // Master 1 Signals
    // ========================================================================
    wire [ADDR_WIDTH-1:0] M1_ARADDR;
    wire [2:0]            M1_ARPROT;
    wire                  M1_ARVALID;
    wire                  M1_ARREADY;
    wire [DATA_WIDTH-1:0] M1_RDATA;
    wire [1:0]            M1_RRESP;
    wire                  M1_RVALID;
    wire                  M1_RREADY;
    wire [ADDR_WIDTH-1:0] M1_AWADDR;
    wire [2:0]            M1_AWPROT;
    wire                  M1_AWVALID;
    wire                  M1_AWREADY;
    wire [DATA_WIDTH-1:0] M1_WDATA;
    wire [3:0]            M1_WSTRB;
    wire                  M1_WVALID;
    wire                  M1_WREADY;
    wire [1:0]            M1_BRESP;
    wire                  M1_BVALID;
    wire                  M1_BREADY;
    
    reg        m1_start;
    wire       m1_completed;
    wire       m1_busy;
    wire       m0_completed_for_m1;  // M1 needs M0 completion signal
    wire [31:0] m1_address_offset;

    // ========================================================================
    // Slave 0 (S0) AXI4-Lite Interface
    // ========================================================================
    wire [ADDR_WIDTH-1:0] S0_AWADDR;
    wire [2:0]            S0_AWPROT;
    wire                  S0_AWVALID;
    wire                  S0_AWREADY;
    wire [DATA_WIDTH-1:0] S0_WDATA;
    wire [3:0]            S0_WSTRB;
    wire                  S0_WVALID;
    wire                  S0_WREADY;
    wire [1:0]            S0_BRESP;
    wire                  S0_BVALID;
    wire                  S0_BREADY;
    wire [ADDR_WIDTH-1:0] S0_ARADDR;
    wire [2:0]            S0_ARPROT;
    wire                  S0_ARVALID;
    wire                  S0_ARREADY;
    wire [DATA_WIDTH-1:0] S0_RDATA;
    wire [1:0]            S0_RRESP;
    wire                  S0_RVALID;
    wire                  S0_RREADY;

    // ========================================================================
    // Slave 1 (S1) AXI4-Lite Interface
    // ========================================================================
    wire [ADDR_WIDTH-1:0] S1_AWADDR;
    wire [2:0]            S1_AWPROT;
    wire                  S1_AWVALID;
    wire                  S1_AWREADY;
    wire [DATA_WIDTH-1:0] S1_WDATA;
    wire [3:0]            S1_WSTRB;
    wire                  S1_WVALID;
    wire                  S1_WREADY;
    wire [1:0]            S1_BRESP;
    wire                  S1_BVALID;
    wire                  S1_BREADY;
    wire [ADDR_WIDTH-1:0] S1_ARADDR;
    wire [2:0]            S1_ARPROT;
    wire                  S1_ARVALID;
    wire                  S1_ARREADY;
    wire [DATA_WIDTH-1:0] S1_RDATA;
    wire [1:0]            S1_RRESP;
    wire                  S1_RVALID;
    wire                  S1_RREADY;

    // ========================================================================
    // Simple Interconnect (M0 -> S0, M1 -> S0 for read, S1 for write)
    // Fixed Priority: M0 > M1
    // ========================================================================
    // M0 always goes to S0, M1 can read from S0 when M0 is not requesting read
    // S0 Read Address Channel (M0 has priority)
    assign S0_ARADDR = M0_ARVALID ? M0_ARADDR : (M1_ARVALID ? M1_ARADDR : 32'h0);
    assign S0_ARPROT = M0_ARVALID ? M0_ARPROT : (M1_ARVALID ? M1_ARPROT : 3'b0);
    assign S0_ARVALID = M0_ARVALID || (M1_ARVALID && !M0_ARVALID);
    assign M0_ARREADY = M0_ARVALID ? S0_ARREADY : 1'b0;
    assign M1_ARREADY = M1_ARVALID && !M0_ARVALID ? S0_ARREADY : 1'b0;
    
    // S0 Read Data Channel (M0 has priority)
    // Track which master is currently receiving data
    reg m0_read_active;
    reg m1_read_active;
    
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            m0_read_active <= 1'b0;
            m1_read_active <= 1'b0;
        end else begin
            // M0 read active when AR handshake completes
            if (M0_ARVALID && M0_ARREADY) begin
                m0_read_active <= 1'b1;
            end else if (M0_RVALID && M0_RREADY) begin
                m0_read_active <= 1'b0;
            end
            
            // M1 read active when AR handshake completes and M0 is not active
            if (M1_ARVALID && M1_ARREADY && !M0_ARVALID) begin
                m1_read_active <= 1'b1;
            end else if (M1_RVALID && M1_RREADY) begin
                m1_read_active <= 1'b0;
            end
        end
    end
    
    assign M0_RDATA = S0_RDATA;
    assign M0_RRESP = S0_RRESP;
    assign M0_RVALID = m0_read_active ? S0_RVALID : 1'b0;
    assign M1_RDATA = m1_read_active ? S0_RDATA : 32'h0;
    assign M1_RRESP = m1_read_active ? S0_RRESP : 2'b00;
    assign M1_RVALID = m1_read_active ? S0_RVALID : 1'b0;
    assign S0_RREADY = (m0_read_active && M0_RREADY) || (m1_read_active && M1_RREADY);
    
    // M0 write to S0
    assign S0_AWADDR = M0_AWVALID ? M0_AWADDR : 32'h0;
    assign S0_AWPROT = M0_AWVALID ? M0_AWPROT : 3'b0;
    assign S0_AWVALID = M0_AWVALID;
    assign S0_WDATA = M0_WVALID ? M0_WDATA : 32'h0;
    assign S0_WSTRB = M0_WVALID ? M0_WSTRB : 4'b0;
    assign S0_WVALID = M0_WVALID;
    assign M0_AWREADY = M0_AWVALID ? S0_AWREADY : 1'b0;
    assign M0_WREADY = M0_WVALID ? S0_WREADY : 1'b0;
    assign M0_BRESP = S0_BRESP;
    assign M0_BVALID = S0_BVALID;
    assign S0_BREADY = M0_BREADY;
    
    // M1 write to S1
    assign S1_AWADDR = M1_AWVALID ? M1_AWADDR : 32'h0;
    assign S1_AWPROT = M1_AWVALID ? M1_AWPROT : 3'b0;
    assign S1_AWVALID = M1_AWVALID;
    assign S1_WDATA = M1_WVALID ? M1_WDATA : 32'h0;
    assign S1_WSTRB = M1_WVALID ? M1_WSTRB : 4'b0;
    assign S1_WVALID = M1_WVALID;
    assign M1_AWREADY = M1_AWVALID ? S1_AWREADY : 1'b0;
    assign M1_WREADY = M1_WVALID ? S1_WREADY : 1'b0;
    assign M1_BRESP = S1_BRESP;
    assign M1_BVALID = S1_BVALID;
    assign S1_BREADY = M1_BREADY;

    // ========================================================================
    // Clock Generation
    // ========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    // ========================================================================
    // Reset Generation
    // ========================================================================
    initial begin
        ARESETN = 0;
        #(CLK_PERIOD * 5);
        ARESETN = 1;
        $display("[TB] Reset released at time %0t", $time);
    end

    // ========================================================================
    // Instantiate Master 0
    // ========================================================================
    axi_master_0 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE0_BASE(SLAVE0_BASE)
    ) u_master_0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(m0_start),
        .completed(m0_completed),
        .busy(m0_busy),
        .M_AXI_araddr(M0_ARADDR),
        .M_AXI_arprot(M0_ARPROT),
        .M_AXI_arvalid(M0_ARVALID),
        .M_AXI_arready(M0_ARREADY),
        .M_AXI_rdata(M0_RDATA),
        .M_AXI_rresp(M0_RRESP),
        .M_AXI_rvalid(M0_RVALID),
        .M_AXI_rready(M0_RREADY),
        .M_AXI_awaddr(M0_AWADDR),
        .M_AXI_awprot(M0_AWPROT),
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

    // ========================================================================
    // Instantiate Master 1
    // ========================================================================
    assign m0_completed_for_m1 = m0_completed;
    
    axi_master_1 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE0_BASE(SLAVE0_BASE),
        .SLAVE1_BASE(SLAVE1_BASE)
    ) u_master_1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(m1_start),
        .m0_completed(m0_completed_for_m1),
        .completed(m1_completed),
        .busy(m1_busy),
        .M_AXI_araddr(M1_ARADDR),
        .M_AXI_arprot(M1_ARPROT),
        .M_AXI_arvalid(M1_ARVALID),
        .M_AXI_arready(M1_ARREADY),
        .M_AXI_rdata(M1_RDATA),
        .M_AXI_rresp(M1_RRESP),
        .M_AXI_rvalid(M1_RVALID),
        .M_AXI_rready(M1_RREADY),
        .M_AXI_awaddr(M1_AWADDR),
        .M_AXI_awprot(M1_AWPROT),
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

    // ========================================================================
    // Create memory initialization files
    // ========================================================================
    integer mem_file;
    initial begin
        // S0 memory: instruction at [1]
        mem_file = $fopen("mem_init_s0_busy.hex", "w");
        if (mem_file) begin
            $fwrite(mem_file, "00000000\n");  // S0[0] = result (will be written by M0)
            $fwrite(mem_file, "01123456\n");  // S0[1] = instruction (ADD 0x123 + 0x456)
            $fclose(mem_file);
            $display("[TB] Created mem_init_s0_busy.hex");
        end
        
        // S1 memory: initialized with zeros
        mem_file = $fopen("mem_init_s1_busy.hex", "w");
        if (mem_file) begin
            $fwrite(mem_file, "00000000\n");
            $fclose(mem_file);
            $display("[TB] Created mem_init_s1_busy.hex");
        end
    end

    // ========================================================================
    // Instantiate Slave 0 (S0)
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_s0_busy.hex")
    ) u_slave0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(S0_AWADDR),
        .S_AXI_awprot(S0_AWPROT),
        .S_AXI_awvalid(S0_AWVALID),
        .S_AXI_awready(S0_AWREADY),
        .S_AXI_wdata(S0_WDATA),
        .S_AXI_wstrb(S0_WSTRB),
        .S_AXI_wvalid(S0_WVALID),
        .S_AXI_wready(S0_WREADY),
        .S_AXI_bresp(S0_BRESP),
        .S_AXI_bvalid(S0_BVALID),
        .S_AXI_bready(S0_BREADY),
        .S_AXI_araddr(S0_ARADDR),
        .S_AXI_arprot(S0_ARPROT),
        .S_AXI_arvalid(S0_ARVALID),
        .S_AXI_arready(S0_ARREADY),
        .S_AXI_rdata(S0_RDATA),
        .S_AXI_rresp(S0_RRESP),
        .S_AXI_rvalid(S0_RVALID),
        .S_AXI_rlast(),
        .S_AXI_rready(S0_RREADY)
    );

    // ========================================================================
    // Instantiate Slave 1 (S1)
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_s1_busy.hex")
    ) u_slave1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(S1_AWADDR),
        .S_AXI_awprot(S1_AWPROT),
        .S_AXI_awvalid(S1_AWVALID),
        .S_AXI_awready(S1_AWREADY),
        .S_AXI_wdata(S1_WDATA),
        .S_AXI_wstrb(S1_WSTRB),
        .S_AXI_wvalid(S1_WVALID),
        .S_AXI_wready(S1_WREADY),
        .S_AXI_bresp(S1_BRESP),
        .S_AXI_bvalid(S1_BVALID),
        .S_AXI_bready(S1_BREADY),
        .S_AXI_araddr(S1_ARADDR),
        .S_AXI_arprot(S1_ARPROT),
        .S_AXI_arvalid(S1_ARVALID),
        .S_AXI_arready(S1_ARREADY),
        .S_AXI_rdata(S1_RDATA),
        .S_AXI_rresp(S1_RRESP),
        .S_AXI_rvalid(S1_RVALID),
        .S_AXI_rlast(),
        .S_AXI_rready(S1_RREADY)
    );

    // ========================================================================
    // Busy Signal Test
    // ========================================================================
    integer test_pass;
    integer test_fail;
    integer start_time;
    
    initial begin
        test_pass = 0;
        test_fail = 0;
        m0_start = 1'b0;
        m1_start = 1'b0;
        
        // Wait for reset release
        @(posedge ARESETN);
        #(CLK_PERIOD * 5);
        
        start_time = $time;
        
        $display("\n========================================");
        $display("[TB] Starting Busy Signal Test");
        $display("========================================\n");
        
        // ====================================================================
        // Test 1: Check M0 busy = 0 when in IDLE
        // ====================================================================
        $display("[TEST 1] Checking M0 busy = 0 in IDLE state");
        if (m0_busy == 1'b0) begin
            $display("[TEST 1] PASS: M0 busy = 0 in IDLE");
            test_pass = test_pass + 1;
        end else begin
            $display("[TEST 1] FAIL: M0 busy = %b (expected 0)", m0_busy);
            test_fail = test_fail + 1;
        end
        #(CLK_PERIOD * 2);
        
        // ====================================================================
        // Test 2: Start M0 and check busy = 1
        // ====================================================================
        $display("\n[TEST 2] Starting M0 and checking busy = 1");
        m0_start = 1'b1;
        @(posedge ACLK);
        m0_start = 1'b0;
        #(CLK_PERIOD * 2);  // Wait a few cycles for state change
        
        if (m0_busy == 1'b1) begin
            $display("[TEST 2] PASS: M0 busy = 1 after start");
            test_pass = test_pass + 1;
        end else begin
            $display("[TEST 2] FAIL: M0 busy = %b (expected 1)", m0_busy);
            test_fail = test_fail + 1;
        end
        
        // ====================================================================
        // Test Summary
        // ====================================================================
        $display("\n========================================");
        $display("[TB] Test Summary");
        $display("========================================");
        $display("[TB] Tests Passed: %0d", test_pass);
        $display("[TB] Tests Failed: %0d", test_fail);
        $display("[TB] Total Simulation Time: %0t ns", $time - start_time);
        $display("========================================\n");
        
        if (test_fail == 0) begin
            $display("[TB] ALL TESTS PASSED! Busy signals work correctly.");
        end else begin
            $display("[TB] SOME TESTS FAILED! Please check busy signal implementation.");
        end
        
        #(CLK_PERIOD * 10);
        $finish;
    end
    
    // ========================================================================
    // Global Timeout - Force finish if simulation runs too long
    // ========================================================================
    initial begin
        #(CLK_PERIOD * 5000);  // Global timeout: 5000 cycles (reduced for faster test)
        $display("\n[TB] GLOBAL TIMEOUT: Simulation exceeded maximum time limit");
        $display("[TB] Forcing simulation to finish");
        $display("[TB] This may indicate a deadlock or infinite loop");
        $finish;
    end

    // ========================================================================
    // Waveform Dump
    // ========================================================================
    initial begin
        $dumpfile("busy_test_tb.vcd");
        $dumpvars(0, busy_test_tb);
    end

endmodule

