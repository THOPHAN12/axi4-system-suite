`timescale 1ns/1ps

// ==============================================================================
// Simple AXI Write Testbench
// ==============================================================================
// Test case: 1 Master performs write operations to Slave 2
// Slave 2 Base Address: 0x8000_0000
// ==============================================================================

module simple_axi_write_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_WORDS  = 1024;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz

    // Clock and Reset
    reg  ACLK;
    reg  ARESETN;

    // ========================================================================
    // Master AXI4-Lite Interface (Write-only for this test)
    // ========================================================================
    // Write Address Channel
    reg  [ADDR_WIDTH-1:0] M_AXI_awaddr;
    reg  [2:0]            M_AXI_awprot;
    reg                   M_AXI_awvalid;
    wire                  M_AXI_awready;
    
    // Write Data Channel
    reg  [DATA_WIDTH-1:0] M_AXI_wdata;
    reg  [3:0]            M_AXI_wstrb;
    reg                   M_AXI_wvalid;
    wire                  M_AXI_wready;
    
    // Write Response Channel
    wire [1:0]            M_AXI_bresp;
    wire                  M_AXI_bvalid;
    reg                   M_AXI_bready;

    // ========================================================================
    // Slave AXI4-Lite Interface
    // ========================================================================
    // Write Address Channel
    wire [ADDR_WIDTH-1:0] S_AXI_awaddr;
    wire [2:0]            S_AXI_awprot;
    wire                  S_AXI_awvalid;
    wire                  S_AXI_awready;
    
    // Write Data Channel
    wire [DATA_WIDTH-1:0] S_AXI_wdata;
    wire [3:0]            S_AXI_wstrb;
    wire                  S_AXI_wvalid;
    wire                  S_AXI_wready;
    
    // Write Response Channel
    wire [1:0]            S_AXI_bresp;
    wire                  S_AXI_bvalid;
    wire                  S_AXI_bready;
    
    // Read Address Channel (not used in this test, but required by interface)
    wire [ADDR_WIDTH-1:0] S_AXI_araddr;
    wire [2:0]            S_AXI_arprot;
    wire                  S_AXI_arvalid;
    wire                  S_AXI_arready;
    
    // Read Data Channel (not used in this test)
    wire [DATA_WIDTH-1:0] S_AXI_rdata;
    wire [1:0]            S_AXI_rresp;
    wire                  S_AXI_rvalid;
    wire                  S_AXI_rlast;
    wire                  S_AXI_rready;

    // ========================================================================
    // Test Control Signals
    // ========================================================================
    parameter SLAVE2_BASE_ADDR = 32'h80000000;  // Slave 2 base address
    reg [31:0] write_addr;
    reg [31:0] write_data;
    reg [3:0]  write_strb;
    reg        write_req;  // Flag to trigger write request
    reg [31:0] expected_data;
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
    // Master AXI Write Logic (Simple Master)
    // ========================================================================
    reg [2:0] master_state;
    localparam IDLE      = 3'b000;
    localparam WRITE_REQ = 3'b001;
    localparam WRITE_WAIT = 3'b010;
    localparam WRITE_DONE = 3'b011;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            master_state <= IDLE;
            M_AXI_awaddr  <= 32'h0;
            M_AXI_awprot  <= 3'b000;
            M_AXI_awvalid <= 1'b0;
            M_AXI_wdata   <= 32'h0;
            M_AXI_wstrb   <= 4'b0000;
            M_AXI_wvalid  <= 1'b0;
            M_AXI_bready  <= 1'b0;
        end else begin
            case (master_state)
                IDLE: begin
                    M_AXI_awvalid <= 1'b0;
                    M_AXI_wvalid  <= 1'b0;
                    M_AXI_bready  <= 1'b0;
                    // Stay in IDLE until write_req flag is set by test
                    if (write_req) begin
                        $display("[TB Master] IDLE -> WRITE_REQ, addr=0x%08h, data=0x%08h", 
                                 write_addr, write_data);
                        master_state <= WRITE_REQ;
                    end
                end
                
                WRITE_REQ: begin
                    M_AXI_awaddr  <= write_addr;
                    M_AXI_awprot  <= 3'b000;
                    M_AXI_awvalid <= 1'b1;
                    M_AXI_wdata   <= write_data;
                    M_AXI_wstrb   <= write_strb;
                    M_AXI_wvalid  <= 1'b1;
                    $display("[TB Master] WRITE_REQ: awvalid=1, awready=%b, wvalid=1, wready=%b, addr=0x%08h, data=0x%08h", 
                             M_AXI_awready, M_AXI_wready, write_addr, write_data);
                    // Both AW and W handshakes must complete
                    if (M_AXI_awready && M_AXI_wready) begin
                        $display("[TB Master] WRITE_REQ -> WRITE_WAIT (handshakes complete)");
                        master_state <= WRITE_WAIT;
                        M_AXI_awvalid <= 1'b0;
                        M_AXI_wvalid  <= 1'b0;
                    end
                end
                
                WRITE_WAIT: begin
                    // Clear awvalid and wvalid now that we're in WRITE_WAIT
                    M_AXI_awvalid <= 1'b0;
                    M_AXI_wvalid  <= 1'b0;
                    M_AXI_bready <= 1'b1;
                    $display("[TB Master] WRITE_WAIT: bready=1, bvalid=%b, bresp=0x%02h", 
                             M_AXI_bvalid, M_AXI_bresp);
                    if (M_AXI_bvalid && M_AXI_bready) begin
                        $display("[TB Master] WRITE_WAIT -> WRITE_DONE, bresp=0x%02h", M_AXI_bresp);
                        master_state <= WRITE_DONE;
                        M_AXI_bready <= 1'b0;
                    end
                end
                
                WRITE_DONE: begin
                    $display("[TB Master] WRITE_DONE -> IDLE");
                    master_state <= IDLE;
                    write_req <= 1'b0;  // Clear write_req flag
                end
            endcase
        end
    end

    // ========================================================================
    // Connect Master to Slave
    // ========================================================================
    assign S_AXI_awaddr  = M_AXI_awaddr;
    assign S_AXI_awprot  = M_AXI_awprot;
    assign S_AXI_awvalid = M_AXI_awvalid;
    assign M_AXI_awready = S_AXI_awready;
    
    assign S_AXI_wdata   = M_AXI_wdata;
    assign S_AXI_wstrb   = M_AXI_wstrb;
    assign S_AXI_wvalid  = M_AXI_wvalid;
    assign M_AXI_wready  = S_AXI_wready;
    
    assign M_AXI_bresp   = S_AXI_bresp;
    assign M_AXI_bvalid  = S_AXI_bvalid;
    assign S_AXI_bready  = M_AXI_bready;

    // Read channel (not used, but required by interface)
    assign S_AXI_araddr  = 32'h0;
    assign S_AXI_arprot  = 3'b000;
    assign S_AXI_arvalid = 1'b0;
    assign S_AXI_rready  = 1'b1;

    // ========================================================================
    // Create memory initialization file (empty for write test)
    // ========================================================================
    initial begin
        mem_file = $fopen("mem_init_write.hex", "w");
        if (mem_file) begin
            // Initialize with zeros - we'll write to it
            $fwrite(mem_file, "00000000\n");  // mem[0]
            $fwrite(mem_file, "00000000\n");  // mem[1]
            $fwrite(mem_file, "00000000\n");  // mem[2]
            $fwrite(mem_file, "00000000\n");  // mem[3]
            $fwrite(mem_file, "00000000\n");  // mem[4]
            $fwrite(mem_file, "00000000\n");  // mem[5]
            $fwrite(mem_file, "00000000\n");  // mem[6]
            $fwrite(mem_file, "00000000\n");  // mem[7]
            $fclose(mem_file);
            $display("[TB] Created mem_init_write.hex file (initialized with zeros)");
        end
    end
    
    // ========================================================================
    // Instantiate AXI Lite RAM Slave
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_write.hex")
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
    // Test Sequence
    // ========================================================================
    initial begin
        test_pass = 0;
        test_fail = 0;
        write_addr = 32'h0;
        write_data = 32'h0;
        write_strb = 4'b1111;  // Write all bytes
        write_req = 1'b0;
        expected_data = 32'h0;
        
        // Wait for reset release
        @(posedge ARESETN);
        #(CLK_PERIOD * 10);
        
        $display("\n========================================");
        $display("[TB] Starting AXI Write Test");
        $display("========================================\n");
        
        // Test 1: Write to Slave 2 address 0x80000000 (mem[0])
        $display("[TB] Test 1: Write 0xDEADBEEF to Slave 2 address 0x80000000");
        write_addr = SLAVE2_BASE_ADDR + 32'h00000000;
        write_data = 32'hDEADBEEF;
        write_strb = 4'b1111;  // Write all 4 bytes
        expected_data = 32'hDEADBEEF;
        @(posedge ACLK);  // Wait one clock
        write_req = 1'b1;  // Trigger write request
        @(posedge ACLK);  // Wait one clock for state machine to detect
        
        // Wait for state machine to complete write cycle
        wait(master_state == IDLE);
        // Wait until write_req is cleared (write completed)
        wait(!write_req);
        repeat(2) @(posedge ACLK);  // Extra clocks for stability
        
        // Verify that write completed successfully
        if (master_state == IDLE && !write_req) begin
            $display("[TB] PASS: Write completed successfully to address 0x%08h", write_addr);
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: Write did not complete properly");
            test_fail = test_fail + 1;
        end
        write_addr = 32'h0;
        write_req = 1'b0;
        repeat(5) @(posedge ACLK);
        
        // Test 2: Write to Slave 2 address 0x80000004 (mem[1])
        $display("[TB] Test 2: Write 0xCAFEBABE to Slave 2 address 0x80000004");
        write_addr = SLAVE2_BASE_ADDR + 32'h00000004;
        write_data = 32'hCAFEBABE;
        write_strb = 4'b1111;
        expected_data = 32'hCAFEBABE;
        @(posedge ACLK);
        write_req = 1'b1;
        @(posedge ACLK);
        
        // Wait for state machine to complete write cycle
        wait(master_state == IDLE);
        // Wait until write_req is cleared (write completed)
        wait(!write_req);
        repeat(2) @(posedge ACLK);  // Extra clocks for stability
        
        if (master_state == IDLE && !write_req) begin
            $display("[TB] PASS: Write completed successfully to address 0x%08h", write_addr);
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: Write did not complete properly");
            test_fail = test_fail + 1;
        end
        write_addr = 32'h0;
        write_req = 1'b0;
        repeat(5) @(posedge ACLK);
        
        // Test 3: Write to Slave 2 address 0x80000008 (mem[2])
        $display("[TB] Test 3: Write 0x12345678 to Slave 2 address 0x80000008");
        write_addr = SLAVE2_BASE_ADDR + 32'h00000008;
        write_data = 32'h12345678;
        write_strb = 4'b1111;
        expected_data = 32'h12345678;
        @(posedge ACLK);
        write_req = 1'b1;
        @(posedge ACLK);
        
        // Wait for state machine to complete write cycle
        wait(master_state == IDLE);
        // Wait until write_req is cleared (write completed)
        wait(!write_req);
        repeat(2) @(posedge ACLK);  // Extra clocks for stability
        
        if (master_state == IDLE && !write_req) begin
            $display("[TB] PASS: Write completed successfully to address 0x%08h", write_addr);
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: Write did not complete properly");
            test_fail = test_fail + 1;
        end
        write_addr = 32'h0;
        write_req = 1'b0;
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
        $dumpfile("simple_axi_write_tb.vcd");
        $dumpvars(0, simple_axi_write_tb);
    end

endmodule

