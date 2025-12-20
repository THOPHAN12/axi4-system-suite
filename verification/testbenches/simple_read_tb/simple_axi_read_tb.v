`timescale 1ns/1ps

// ==============================================================================
// Simple AXI Read Testbench
// ==============================================================================
// Test case: 1 Master performs read operations from 1 Slave (Slave 0)
// ==============================================================================

module simple_axi_read_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_WORDS  = 1024;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz

    // Clock and Reset
    reg  ACLK;
    reg  ARESETN;

    // ========================================================================
    // Master AXI4-Lite Interface (Read-only for this test)
    // ========================================================================
    // Read Address Channel
    reg  [ADDR_WIDTH-1:0] M_AXI_araddr;
    reg  [2:0]            M_AXI_arprot;
    reg                   M_AXI_arvalid;
    wire                  M_AXI_arready;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] M_AXI_rdata;
    wire [1:0]            M_AXI_rresp;
    wire                  M_AXI_rvalid;
    wire                  M_AXI_rlast;
    reg                   M_AXI_rready;

    // ========================================================================
    // Slave AXI4-Lite Interface
    // ========================================================================
    // Write Address Channel (not used in this test, but required by interface)
    wire [ADDR_WIDTH-1:0] S_AXI_awaddr;
    wire [2:0]            S_AXI_awprot;
    wire                  S_AXI_awvalid;
    wire                  S_AXI_awready;
    
    // Write Data Channel (not used in this test)
    wire [DATA_WIDTH-1:0] S_AXI_wdata;
    wire [3:0]            S_AXI_wstrb;
    wire                  S_AXI_wvalid;
    wire                  S_AXI_wready;
    
    // Write Response Channel (not used in this test)
    wire [1:0]            S_AXI_bresp;
    wire                  S_AXI_bvalid;
    wire                  S_AXI_bready;
    
    // Read Address Channel
    wire [ADDR_WIDTH-1:0] S_AXI_araddr;
    wire [2:0]            S_AXI_arprot;
    wire                  S_AXI_arvalid;
    wire                  S_AXI_arready;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] S_AXI_rdata;
    wire [1:0]            S_AXI_rresp;
    wire                  S_AXI_rvalid;
    wire                  S_AXI_rlast;
    wire                  S_AXI_rready;

    // ========================================================================
    // Test Control Signals
    // ========================================================================
    reg [31:0] read_addr;
    reg [31:0] expected_data;
    reg [31:0] read_data;
    reg        read_req;  // Flag to trigger read request (allows address 0x00000000)
    integer test_pass;
    integer test_fail;
    integer mem_file;  // For creating memory initialization file

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
    // Master AXI Read Logic (Simple Master)
    // ========================================================================
    reg [2:0] master_state;
    localparam IDLE     = 3'b000;
    localparam READ_REQ = 3'b001;
    localparam READ_WAIT = 3'b010;
    localparam READ_DONE = 3'b011;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            master_state <= IDLE;
            M_AXI_araddr  <= 32'h0;
            M_AXI_arprot  <= 3'b000;
            M_AXI_arvalid <= 1'b0;
            M_AXI_rready  <= 1'b0;
            read_data     <= 32'h0;
        end else begin
            case (master_state)
                IDLE: begin
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_rready  <= 1'b0;
                    // Stay in IDLE until read_req flag is set by test
                    if (read_req) begin
                        $display("[TB Master] IDLE -> READ_REQ, addr=0x%08h", read_addr);
                        master_state <= READ_REQ;
                    end
                end
                
                READ_REQ: begin
                    M_AXI_araddr  <= read_addr;
                    M_AXI_arprot  <= 3'b000;
                    M_AXI_arvalid <= 1'b1;
                    $display("[TB Master] READ_REQ: arvalid=1, arready=%b, addr=0x%08h", 
                             M_AXI_arready, read_addr);
                    // Keep arvalid high until handshake completes
                    if (M_AXI_arready) begin
                        $display("[TB Master] READ_REQ -> READ_WAIT (handshake complete)");
                        master_state <= READ_WAIT;
                        // Keep arvalid high for one more cycle to ensure slave sees it
                        // Will be cleared in READ_WAIT state
                    end
                end
                
                READ_WAIT: begin
                    // Clear arvalid now that we're in READ_WAIT
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_rready <= 1'b1;
                    $display("[TB Master] READ_WAIT: rready=1, rvalid=%b, rdata=0x%08h", 
                             M_AXI_rvalid, M_AXI_rdata);
                    if (M_AXI_rvalid && M_AXI_rready) begin
                        read_data <= M_AXI_rdata;
                        $display("[TB Master] READ_WAIT -> READ_DONE, read_data=0x%08h", M_AXI_rdata);
                        master_state <= READ_DONE;
                        M_AXI_rready <= 1'b0;
                    end
                end
                
                READ_DONE: begin
                    $display("[TB Master] READ_DONE -> IDLE");
                    master_state <= IDLE;
                    read_req <= 1'b0;  // Clear read_req flag
                end
            endcase
        end
    end

    // ========================================================================
    // Connect Master to Slave
    // ========================================================================
    assign S_AXI_araddr  = M_AXI_araddr;
    assign S_AXI_arprot  = M_AXI_arprot;
    assign S_AXI_arvalid = M_AXI_arvalid;
    assign M_AXI_arready = S_AXI_arready;
    
    assign M_AXI_rdata   = S_AXI_rdata;
    assign M_AXI_rresp   = S_AXI_rresp;
    assign M_AXI_rvalid  = S_AXI_rvalid;
    assign M_AXI_rlast   = S_AXI_rlast;
    assign S_AXI_rready  = M_AXI_rready;

    // Tie off unused write signals
    assign S_AXI_awaddr  = 32'h0;
    assign S_AXI_awprot  = 3'b000;
    assign S_AXI_awvalid = 1'b0;
    assign S_AXI_wdata   = 32'h0;
    assign S_AXI_wstrb   = 4'b0000;
    assign S_AXI_wvalid  = 1'b0;
    assign S_AXI_bready  = 1'b1;

    // ========================================================================
    // Create memory initialization file
    // ========================================================================
    initial begin
        mem_file = $fopen("mem_init.hex", "w");
        if (mem_file) begin
            $fwrite(mem_file, "DEADBEEF\n");  // mem[0]
            $fwrite(mem_file, "CAFEBABE\n");  // mem[1]
            $fwrite(mem_file, "12345678\n");  // mem[2]
            $fwrite(mem_file, "87654321\n");  // mem[3]
            $fwrite(mem_file, "ABCDEF00\n");  // mem[4]
            $fwrite(mem_file, "00FEDCBA\n");  // mem[5]
            $fwrite(mem_file, "11111111\n");  // mem[6]
            $fwrite(mem_file, "22222222\n");  // mem[7]
            $fclose(mem_file);
            $display("[TB] Created mem_init.hex file with test data");
        end
    end
    
    // ========================================================================
    // Instantiate AXI Lite RAM Slave
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init.hex")
    ) u_slave_ram (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        .S_AXI_awaddr(S_AXI_awaddr),
        .S_AXI_awprot(S_AXI_awprot),
        .S_AXI_awvalid(S_AXI_awvalid),
        .S_AXI_awready(S_AXI_awready),
        
        .S_AXI_wdata(S_AXI_wdata),
        .S_AXI_wstrb(S_AXI_wstrb),
        .S_AXI_wvalid(S_AXI_wvalid),
        .S_AXI_wready(S_AXI_wready),
        
        .S_AXI_bresp(S_AXI_bresp),
        .S_AXI_bvalid(S_AXI_bvalid),
        .S_AXI_bready(S_AXI_bready),
        
        .S_AXI_araddr(S_AXI_araddr),
        .S_AXI_arprot(S_AXI_arprot),
        .S_AXI_arvalid(S_AXI_arvalid),
        .S_AXI_arready(S_AXI_arready),
        
        .S_AXI_rdata(S_AXI_rdata),
        .S_AXI_rresp(S_AXI_rresp),
        .S_AXI_rvalid(S_AXI_rvalid),
        .S_AXI_rlast(S_AXI_rlast),
        .S_AXI_rready(S_AXI_rready)
    );

    // ========================================================================
    // Memory Initialization Note
    // ========================================================================
    // Memory is initialized from mem_init.hex file via INIT_HEX parameter
    // Note: Memory array signals may show X in wave window due to optimization
    // This is normal - you can verify memory contents by reading via AXI
    // The actual memory values will be visible through S_RDATA when reading

    // ========================================================================
    // Test Sequence
    // ========================================================================
    initial begin
        test_pass = 0;
        test_fail = 0;
        read_addr = 32'h0;
        read_data = 32'h0;
        read_req = 1'b0;
        expected_data = 32'h0;
        
        // Wait for reset release
        @(posedge ARESETN);
        #(CLK_PERIOD * 10);
        
        $display("\n========================================");
        $display("[TB] Starting AXI Read Test");
        $display("========================================\n");
        
        // Test 1: Read from address 0x00000000 (mem[0])
        $display("[TB] Test 1: Read from address 0x00000000");
        read_addr = 32'h00000000;  // Set address first
        expected_data = 32'hDEADBEEF;  // Test data from mem_init.hex
        @(posedge ACLK);  // Wait one clock
        read_req = 1'b1;  // Trigger read request
        @(posedge ACLK);  // Wait one clock for state machine to detect
        
        // Wait for state machine to complete read cycle
        // Wait until master is back in IDLE AND read_data has been updated
        wait(master_state == IDLE && read_data != 32'h0 || read_data == expected_data);
        @(posedge ACLK);  // Wait one more clock to ensure read_data is stable
        
        if (read_data === expected_data) begin
            $display("[TB] PASS: Read 0x%08h from address 0x%08h (expected 0x%08h)", 
                     read_data, read_addr, expected_data);
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: Expected 0x%08h, got 0x%08h from address 0x%08h", 
                     expected_data, read_data, read_addr);
            test_fail = test_fail + 1;
        end
        read_addr = 32'h0;  // Reset for next test
        read_req = 1'b0;
        repeat(5) @(posedge ACLK);
        
        // Test 2: Read from address 0x00000004 (mem[1])
        $display("[TB] Test 2: Read from address 0x00000004");
        read_addr = 32'h00000004;
        expected_data = 32'hCAFEBABE;  // Test data from mem_init.hex
        @(posedge ACLK);
        read_req = 1'b1;  // Trigger read request
        @(posedge ACLK);
        
        // Wait for state machine to complete read cycle
        wait(master_state == IDLE);
        // Wait until read_data changes from previous test value
        wait(read_data == expected_data || read_data != 32'hDEADBEEF);
        repeat(2) @(posedge ACLK);  // Extra clocks for stability
        
        if (read_data === expected_data) begin
            $display("[TB] PASS: Read 0x%08h from address 0x%08h (expected 0x%08h)", 
                     read_data, read_addr, expected_data);
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: Expected 0x%08h, got 0x%08h from address 0x%08h", 
                     expected_data, read_data, read_addr);
            test_fail = test_fail + 1;
        end
        read_addr = 32'h0;  // Reset for next test
        read_req = 1'b0;
        repeat(5) @(posedge ACLK);
        
        // Test 3: Read from address 0x00000008 (mem[2])
        $display("[TB] Test 3: Read from address 0x00000008");
        read_addr = 32'h00000008;
        expected_data = 32'h12345678;  // Test data from mem_init.hex
        @(posedge ACLK);
        read_req = 1'b1;  // Trigger read request
        @(posedge ACLK);
        
        // Wait for state machine to complete read cycle
        wait(master_state == IDLE);
        // Wait until read_data changes from previous test value
        wait(read_data == expected_data || read_data != 32'hCAFEBABE);
        repeat(2) @(posedge ACLK);  // Extra clocks for stability
        @(posedge ACLK);  // Extra clock for safety
        
        if (read_data === expected_data) begin
            $display("[TB] PASS: Read 0x%08h from address 0x%08h (expected 0x%08h)", 
                     read_data, read_addr, expected_data);
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: Expected 0x%08h, got 0x%08h from address 0x%08h", 
                     expected_data, read_data, read_addr);
            test_fail = test_fail + 1;
        end
        read_addr = 32'h0;
        read_req = 1'b0;
        repeat(5) @(posedge ACLK);
        
        // Test Summary
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
        
        #(CLK_PERIOD * 10);
        $finish;
    end

    // ========================================================================
    // Waveform Dump (optional, for debugging)
    // ========================================================================
    initial begin
        $dumpfile("simple_axi_read_tb.vcd");
        $dumpvars(0, simple_axi_read_tb);
    end

endmodule

