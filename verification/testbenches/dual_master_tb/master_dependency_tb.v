`timescale 1ns/1ps

// ==============================================================================
// Master Dependency Testbench (Test Case 4)
// ==============================================================================
// Test case: M0 computes and writes to S0, M1 reads from S0 and uses result as address
// - M0: Read instruction -> Compute -> Write result to S0
// - M1: Read result from S0 -> Use as address offset -> Send to Slave (S1)
// - Dependency: M1 must wait for M0 to complete before reading from S0
// ==============================================================================

module master_dependency_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_WORDS  = 1024;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Address mapping
    parameter SLAVE0_BASE = 32'h00000000;  // S0 base address (shared memory)
    parameter SLAVE1_BASE = 32'h40000000;  // S1 base address (target for M1)

    // Clock and Reset
    reg  ACLK;
    reg  ARESETN;

    // ========================================================================
    // Master 0 AXI4-Lite Interface (driven by axi_master_0 module)
    // ========================================================================
    // Read Address Channel
    wire [ADDR_WIDTH-1:0] M0_ARADDR;
    wire [2:0]            M0_ARPROT;
    wire                  M0_ARVALID;
    wire                  M0_ARREADY;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] M0_RDATA;
    wire [1:0]            M0_RRESP;
    wire                  M0_RVALID;
    wire                  M0_RREADY;
    
    // Write Address Channel
    wire [ADDR_WIDTH-1:0] M0_AWADDR;
    wire [2:0]            M0_AWPROT;
    wire                  M0_AWVALID;
    wire                  M0_AWREADY;
    
    // Write Data Channel
    wire [DATA_WIDTH-1:0] M0_WDATA;
    wire [3:0]            M0_WSTRB;
    wire                  M0_WVALID;
    wire                  M0_WREADY;
    
    // Write Response Channel
    wire [1:0]            M0_BRESP;
    wire                  M0_BVALID;
    wire                  M0_BREADY;

    // ========================================================================
    // Master 1 AXI4-Lite Interface (driven by axi_master_1 module)
    // ========================================================================
    // Read Address Channel
    wire [ADDR_WIDTH-1:0] M1_ARADDR;
    wire [2:0]            M1_ARPROT;
    wire                  M1_ARVALID;
    wire                  M1_ARREADY;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] M1_RDATA;
    wire [1:0]            M1_RRESP;
    wire                  M1_RVALID;
    wire                  M1_RREADY;
    
    // Write Address Channel
    wire [ADDR_WIDTH-1:0] M1_AWADDR;
    wire [2:0]            M1_AWPROT;
    wire                  M1_AWVALID;
    wire                  M1_AWREADY;
    
    // Write Data Channel
    wire [DATA_WIDTH-1:0] M1_WDATA;
    wire [3:0]            M1_WSTRB;
    wire                  M1_WVALID;
    wire                  M1_WREADY;
    
    // Write Response Channel
    wire [1:0]            M1_BRESP;
    wire                  M1_BVALID;
    wire                  M1_BREADY;

    // ========================================================================
    // Slave 0 (S0) AXI4-Lite Interface - Shared Memory
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
    // Slave 1 (S1) AXI4-Lite Interface - Target for M1
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
    // Master Control Signals
    // ========================================================================
    reg        m0_start;
    wire       m0_completed;
    wire       m0_busy;
    wire [31:0] m0_instruction;
    wire [31:0] m0_result;
    
    reg        m1_start;
    wire       m1_completed;
    wire       m1_busy;
    wire [31:0] m1_address_offset;
    
    // Test control
    integer test_pass;
    integer test_fail;
    integer mem_file;

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
    // Simple Interconnect with Fixed Priority Arbitration
    // ========================================================================
    // Request signals
    wire m0_read_req = M0_ARVALID;
    wire m1_read_req = M1_ARVALID;
    wire m0_write_req = M0_AWVALID && M0_WVALID;
    wire m1_write_req = M1_AWVALID && M1_WVALID;
    
    // Fixed Priority: M0 > M1
    wire m0_read_grant = m0_read_req;
    wire m1_read_grant = m1_read_req && !m0_read_req;
    wire m0_write_grant = m0_write_req;
    wire m1_write_grant = m1_write_req && !m0_write_req;
    
    // Address Decoder: Route to S0 or S1
    // M0 always routes to S0 (0x00000000)
    // M1 routes to S0 for read, S1 for write
    wire m0_to_s0 = (M0_ARADDR >= SLAVE0_BASE && M0_ARADDR < SLAVE1_BASE) ||
                     (M0_AWADDR >= SLAVE0_BASE && M0_AWADDR < SLAVE1_BASE);
    wire m1_to_s0 = (M1_ARADDR >= SLAVE0_BASE && M1_ARADDR < SLAVE1_BASE);
    wire m1_to_s1 = (M1_AWADDR >= SLAVE1_BASE && M1_AWADDR < 32'h80000000);
    
    // S0 Read Address Channel (M0 has priority)
    assign S0_ARADDR = (m0_read_grant && m0_to_s0) ? M0_ARADDR : 
                       (m1_read_grant && m1_to_s0) ? M1_ARADDR : 32'h0;
    assign S0_ARPROT = (m0_read_grant && m0_to_s0) ? M0_ARPROT : 
                       (m1_read_grant && m1_to_s0) ? M1_ARPROT : 3'b0;
    assign S0_ARVALID = (m0_read_grant && m0_to_s0 && M0_ARVALID) || 
                        (m1_read_grant && m1_to_s0 && M1_ARVALID);
    
    // M0 Read Channel (to S0)
    assign M0_ARREADY = m0_read_grant && m0_to_s0 ? S0_ARREADY : 1'b0;
    assign M0_RDATA = S0_RDATA;
    assign M0_RRESP = S0_RRESP;
    assign M0_RVALID = (m0_read_grant && m0_to_s0) ? S0_RVALID : 1'b0;
    
    // M1 Read Channel (to S0)
    assign M1_ARREADY = m1_read_grant && m1_to_s0 ? S0_ARREADY : 1'b0;
    assign M1_RDATA = m1_to_s0 ? S0_RDATA : 32'h0;
    assign M1_RRESP = m1_to_s0 ? S0_RRESP : 2'b00;
    assign M1_RVALID = (m1_read_grant && m1_to_s0) ? S0_RVALID : 1'b0;
    
    // S0 Read Data Channel Ready (M0 has priority)
    assign S0_RREADY = (m0_read_grant && m0_to_s0 && M0_RREADY) || 
                       (m1_read_grant && m1_to_s0 && M1_RREADY);
    
    // M0 Write Channel (to S0)
    assign M0_AWREADY = m0_write_grant && m0_to_s0 ? S0_AWREADY : 1'b0;
    assign M0_WREADY = m0_write_grant && m0_to_s0 ? S0_WREADY : 1'b0;
    assign S0_AWADDR = m0_write_grant && m0_to_s0 ? M0_AWADDR : 32'h0;
    assign S0_AWPROT = m0_write_grant && m0_to_s0 ? M0_AWPROT : 3'b0;
    assign S0_AWVALID = m0_write_grant && m0_to_s0 ? M0_AWVALID : 1'b0;
    assign S0_WDATA = m0_write_grant && m0_to_s0 ? M0_WDATA : 32'h0;
    assign S0_WSTRB = m0_write_grant && m0_to_s0 ? M0_WSTRB : 4'b0;
    assign S0_WVALID = m0_write_grant && m0_to_s0 ? M0_WVALID : 1'b0;
    assign M0_BRESP = S0_BRESP;
    assign M0_BVALID = S0_BVALID;
    assign S0_BREADY = M0_BREADY;
    
    // M1 Write Channel (to S1)
    assign M1_AWREADY = m1_write_grant && m1_to_s1 ? S1_AWREADY : 1'b0;
    assign M1_WREADY = m1_write_grant && m1_to_s1 ? S1_WREADY : 1'b0;
    assign S1_AWADDR = m1_write_grant && m1_to_s1 ? M1_AWADDR : 32'h0;
    assign S1_AWPROT = m1_write_grant && m1_to_s1 ? M1_AWPROT : 3'b0;
    assign S1_AWVALID = m1_write_grant && m1_to_s1 ? M1_AWVALID : 1'b0;
    assign S1_WDATA = m1_write_grant && m1_to_s1 ? M1_WDATA : 32'h0;
    assign S1_WSTRB = m1_write_grant && m1_to_s1 ? M1_WSTRB : 4'b0;
    assign S1_WVALID = m1_write_grant && m1_to_s1 ? M1_WVALID : 1'b0;
    assign M1_BRESP = S1_BRESP;
    assign M1_BVALID = S1_BVALID;
    assign S1_BREADY = M1_BREADY;

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
    axi_master_1 #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .SLAVE0_BASE(SLAVE0_BASE),
        .SLAVE1_BASE(SLAVE1_BASE)
    ) u_master_1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(m1_start),
        .m0_completed(m0_completed),
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
    initial begin
        // S0 memory: instruction at [1], result will be written to [0] by M0
        mem_file = $fopen("mem_init_s0_dep.hex", "w");
        if (mem_file) begin
            $fwrite(mem_file, "00000000\n");  // S0[0] = result (will be written by M0)
            // Instruction: opcode=0x01 (ADD), op1=0x123, op2=0x456
            $fwrite(mem_file, "01123456\n");  // S0[1] = instruction
            $fclose(mem_file);
            $display("[TB] Created mem_init_s0_dep.hex");
        end
        
        // S1 memory: initialized with zeros
        mem_file = $fopen("mem_init_s1_dep.hex", "w");
        if (mem_file) begin
            $fwrite(mem_file, "00000000\n");  // S1[0] = will receive data from M1
            $fclose(mem_file);
            $display("[TB] Created mem_init_s1_dep.hex");
        end
    end
    
    // ========================================================================
    // Instantiate Slave 0 (S0) - Shared Memory
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_s0_dep.hex")
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
    // Instantiate Slave 1 (S1) - Target for M1
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_s1_dep.hex")
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
    // Monitor for simulation completion
    // ========================================================================
    always @(posedge ACLK) begin
        if (ARESETN && m0_completed && m1_completed && !m0_busy && !m1_busy) begin
            $display("\n[TB] Both masters have completed and returned to IDLE");
            $display("[TB] Ending simulation...");
            #(CLK_PERIOD * 2);
            $finish;
        end
    end

    // ========================================================================
    // Test Sequence
    // ========================================================================
    initial begin
        test_pass = 0;
        test_fail = 0;
        m0_start = 1'b0;
        m1_start = 1'b0;
        
        // Wait for reset release
        @(posedge ARESETN);
        #(CLK_PERIOD * 10);
        
        $display("\n========================================");
        $display("[TB] Starting Master Dependency Test");
        $display("========================================\n");
        
        // Start M0 first
        $display("[TB] Starting M0: Read instruction -> Compute -> Write to S0");
        m0_start = 1'b1;
        @(posedge ACLK);
        m0_start = 1'b0;
        
        // Start M1 (it will wait for M0 to complete)
        $display("[TB] Starting M1: Wait for M0 -> Read from S0 -> Send to S1");
        m1_start = 1'b1;
        @(posedge ACLK);
        m1_start = 1'b0;
        
        // Wait for both masters to complete and return to IDLE
        wait(m0_completed && m1_completed && !m0_busy && !m1_busy);
        repeat(2) @(posedge ACLK);
        
        // Verify results
        // M0: ADD 0x123 + 0x456 = 0x579, written to S0[0]
        // M1: Reads 0x579 from S0[0], sends data to S1 at address 0x40000000 + 0x579 = 0x40000579
        
        $display("\n[TB] Test Summary:");
        $display("[TB] M0 completed: %s", m0_completed ? "YES" : "NO");
        $display("[TB] M1 completed: %s", m1_completed ? "YES" : "NO");
        $display("[TB] M0 result (written to S0[0]): 0x%08h", m0_result);
        $display("[TB] M1 address offset (read from S0[0]): 0x%08h", m1_address_offset);
        $display("[TB] M1 target address (S1 base + offset): 0x%08h", SLAVE1_BASE + m1_address_offset);
        
        if (m0_completed && m1_completed && m0_result == 32'h579 && m1_address_offset == 32'h579) begin
            $display("[TB] PASS: Both masters completed successfully with correct results");
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: One or both masters did not complete correctly");
            test_fail = test_fail + 1;
        end
        
        $display("\n========================================");
        $display("[TB] Test Summary");
        $display("========================================");
        $display("[TB] Tests Passed: %0d", test_pass);
        $display("[TB] Tests Failed: %0d", test_fail);
        $display("========================================\n");
        
        if (test_fail == 0) begin
            $display("[TB] ALL TESTS PASSED!");
        end else begin
            $display("[TB] SOME TESTS FAILED!");
        end
        
        // Simulation will end automatically via the always block above
    end

    // ========================================================================
    // Waveform Dump
    // ========================================================================
    initial begin
        $dumpfile("master_dependency_tb.vcd");
        $dumpvars(0, master_dependency_tb);
    end

endmodule

