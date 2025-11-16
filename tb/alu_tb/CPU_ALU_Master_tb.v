`timescale 1ns/1ps

//============================================================================
// Testbench for CPU ALU Master and Simple Memory Slave
// Tests basic ALU operations: ADD, SUB, AND, OR, XOR, NOT, SHIFT
//============================================================================
module CPU_ALU_Master_tb #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) ();

    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    
    // CPU Control signals
    reg  cpu_start;
    wire cpu_busy;
    wire cpu_done;
    
    // ========================================================================
    // CPU Master AXI Interface
    // ========================================================================
    // Write Address Channel
    wire [ADDR_WIDTH-1:0] M_AXI_awaddr;
    wire [7:0]            M_AXI_awlen;
    wire [2:0]            M_AXI_awsize;
    wire [1:0]            M_AXI_awburst;
    wire [1:0]            M_AXI_awlock;
    wire [3:0]            M_AXI_awcache;
    wire [2:0]            M_AXI_awprot;
    wire [3:0]            M_AXI_awregion;
    wire [3:0]            M_AXI_awqos;
    wire                  M_AXI_awvalid;
    wire                  M_AXI_awready;
    
    // Write Data Channel
    wire [DATA_WIDTH-1:0] M_AXI_wdata;
    wire [3:0]            M_AXI_wstrb;
    wire                  M_AXI_wlast;
    wire                  M_AXI_wvalid;
    wire                  M_AXI_wready;
    
    // Write Response Channel
    wire [1:0]            M_AXI_bresp;
    wire                  M_AXI_bvalid;
    wire                  M_AXI_bready;
    
    // Read Address Channel
    wire [ADDR_WIDTH-1:0] M_AXI_araddr;
    wire [7:0]            M_AXI_arlen;
    wire [2:0]            M_AXI_arsize;
    wire [1:0]            M_AXI_arburst;
    wire [1:0]            M_AXI_arlock;
    wire [3:0]            M_AXI_arcache;
    wire [2:0]            M_AXI_arprot;
    wire [3:0]            M_AXI_arregion;
    wire [3:0]            M_AXI_arqos;
    wire                  M_AXI_arvalid;
    wire                  M_AXI_arready;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] M_AXI_rdata;
    wire [1:0]            M_AXI_rresp;
    wire                  M_AXI_rlast;
    wire                  M_AXI_rvalid;
    wire                  M_AXI_rready;
    
    // ========================================================================
    // Memory Slave AXI Interface
    // ========================================================================
    // Write Address Channel
    wire [ADDR_WIDTH-1:0] S_AXI_awaddr;
    wire [7:0]            S_AXI_awlen;
    wire [2:0]            S_AXI_awsize;
    wire [1:0]            S_AXI_awburst;
    wire [1:0]            S_AXI_awlock;
    wire [3:0]            S_AXI_awcache;
    wire [2:0]            S_AXI_awprot;
    wire [3:0]            S_AXI_awregion;
    wire [3:0]            S_AXI_awqos;
    wire                  S_AXI_awvalid;
    wire                  S_AXI_awready;
    
    // Write Data Channel
    wire [DATA_WIDTH-1:0] S_AXI_wdata;
    wire [3:0]            S_AXI_wstrb;
    wire                  S_AXI_wlast;
    wire                  S_AXI_wvalid;
    wire                  S_AXI_wready;
    
    // Write Response Channel
    wire [1:0]            S_AXI_bresp;
    wire                  S_AXI_bvalid;
    wire                  S_AXI_bready;
    
    // Read Address Channel
    wire [ADDR_WIDTH-1:0] S_AXI_araddr;
    wire [7:0]            S_AXI_arlen;
    wire [2:0]            S_AXI_arsize;
    wire [1:0]            S_AXI_arburst;
    wire [1:0]            S_AXI_arlock;
    wire [3:0]            S_AXI_arcache;
    wire [2:0]            S_AXI_arprot;
    wire [3:0]            S_AXI_arregion;
    wire [3:0]            S_AXI_arqos;
    wire                  S_AXI_arvalid;
    wire                  S_AXI_arready;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] S_AXI_rdata;
    wire [1:0]            S_AXI_rresp;
    wire                  S_AXI_rlast;
    wire                  S_AXI_rvalid;
    wire                  S_AXI_rready;
    
    // ========================================================================
    // Initialization Master AXI Interface (for memory initialization)
    // ========================================================================
    reg  [ADDR_WIDTH-1:0] init_awaddr;
    reg                   init_awvalid;
    reg  [DATA_WIDTH-1:0] init_wdata;
    reg                   init_wlast;
    reg                   init_wvalid;
    reg                   init_bready;
    
    // Init read signals for verification
    reg  [ADDR_WIDTH-1:0] init_araddr;
    reg                   init_arvalid;
    reg                   init_rready;
    reg  [DATA_WIDTH-1:0] init_rdata;
    
    // Multiplexer signals for initialization vs CPU access
    reg init_mode;  // 1 = initialization mode, 0 = CPU mode
    
    // Connect CPU Master or Init Master to Memory Slave
    assign S_AXI_awaddr   = init_mode ? init_awaddr : M_AXI_awaddr;
    assign S_AXI_awlen    = init_mode ? 8'h0 : M_AXI_awlen;
    assign S_AXI_awsize   = init_mode ? 3'b010 : M_AXI_awsize;
    assign S_AXI_awburst  = init_mode ? 2'b01 : M_AXI_awburst;
    assign S_AXI_awlock   = init_mode ? 2'b00 : M_AXI_awlock;
    assign S_AXI_awcache  = init_mode ? 4'b0000 : M_AXI_awcache;
    assign S_AXI_awprot   = init_mode ? 3'b000 : M_AXI_awprot;
    assign S_AXI_awregion = init_mode ? 4'b0000 : M_AXI_awregion;
    assign S_AXI_awqos    = init_mode ? 4'b0000 : M_AXI_awqos;
    assign S_AXI_awvalid  = init_mode ? init_awvalid : M_AXI_awvalid;
    assign M_AXI_awready  = init_mode ? 1'b0 : S_AXI_awready;
    
    assign S_AXI_wdata    = init_mode ? init_wdata : M_AXI_wdata;
    assign S_AXI_wstrb    = init_mode ? 4'hF : M_AXI_wstrb;
    assign S_AXI_wlast    = init_mode ? init_wlast : M_AXI_wlast;
    assign S_AXI_wvalid   = init_mode ? init_wvalid : M_AXI_wvalid;
    assign M_AXI_wready   = init_mode ? 1'b0 : S_AXI_wready;
    
    assign M_AXI_bresp    = init_mode ? 2'b00 : S_AXI_bresp;
    assign M_AXI_bvalid   = init_mode ? 1'b0 : S_AXI_bvalid;
    assign S_AXI_bready   = init_mode ? init_bready : M_AXI_bready;
    
    assign S_AXI_araddr   = init_mode ? init_araddr : M_AXI_araddr;
    assign S_AXI_arlen    = init_mode ? 8'h0 : M_AXI_arlen;
    assign S_AXI_arsize   = init_mode ? 3'b010 : M_AXI_arsize;
    assign S_AXI_arburst  = init_mode ? 2'b01 : M_AXI_arburst;
    assign S_AXI_arlock   = init_mode ? 2'b00 : M_AXI_arlock;
    assign S_AXI_arcache  = init_mode ? 4'b0000 : M_AXI_arcache;
    assign S_AXI_arprot   = init_mode ? 3'b000 : M_AXI_arprot;
    assign S_AXI_arregion = init_mode ? 4'b0000 : M_AXI_arregion;
    assign S_AXI_arqos    = init_mode ? 4'b0000 : M_AXI_arqos;
    assign S_AXI_arvalid  = init_mode ? init_arvalid : M_AXI_arvalid;
    assign M_AXI_arready  = init_mode ? 1'b0 : S_AXI_arready;
    
    assign M_AXI_rdata    = init_mode ? 32'h0 : S_AXI_rdata;
    assign M_AXI_rresp    = init_mode ? 2'b00 : S_AXI_rresp;
    assign M_AXI_rlast    = init_mode ? 1'b0 : S_AXI_rlast;
    assign M_AXI_rvalid   = init_mode ? 1'b0 : S_AXI_rvalid;
    assign S_AXI_rready   = init_mode ? init_rready : M_AXI_rready;
    
    // Instantiate CPU ALU Master
    CPU_ALU_Master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_cpu (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(cpu_start),
        .busy(cpu_busy),
        .done(cpu_done),
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awlock(M_AXI_awlock),
        .M_AXI_awcache(M_AXI_awcache),
        .M_AXI_awprot(M_AXI_awprot),
        .M_AXI_awregion(M_AXI_awregion),
        .M_AXI_awqos(M_AXI_awqos),
        .M_AXI_awvalid(M_AXI_awvalid),
        .M_AXI_awready(M_AXI_awready),
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wlast(M_AXI_wlast),
        .M_AXI_wvalid(M_AXI_wvalid),
        .M_AXI_wready(M_AXI_wready),
        .M_AXI_bresp(M_AXI_bresp),
        .M_AXI_bvalid(M_AXI_bvalid),
        .M_AXI_bready(M_AXI_bready),
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arlen(M_AXI_arlen),
        .M_AXI_arsize(M_AXI_arsize),
        .M_AXI_arburst(M_AXI_arburst),
        .M_AXI_arlock(M_AXI_arlock),
        .M_AXI_arcache(M_AXI_arcache),
        .M_AXI_arprot(M_AXI_arprot),
        .M_AXI_arregion(M_AXI_arregion),
        .M_AXI_arqos(M_AXI_arqos),
        .M_AXI_arvalid(M_AXI_arvalid),
        .M_AXI_arready(M_AXI_arready),
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rresp(M_AXI_rresp),
        .M_AXI_rlast(M_AXI_rlast),
        .M_AXI_rvalid(M_AXI_rvalid),
        .M_AXI_rready(M_AXI_rready)
    );
    
    // Instantiate Simple Memory Slave
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(256)
    ) u_memory (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(S_AXI_awaddr),
        .S_AXI_awlen(S_AXI_awlen),
        .S_AXI_awsize(S_AXI_awsize),
        .S_AXI_awburst(S_AXI_awburst),
        .S_AXI_awlock(S_AXI_awlock),
        .S_AXI_awcache(S_AXI_awcache),
        .S_AXI_awprot(S_AXI_awprot),
        .S_AXI_awregion(S_AXI_awregion),
        .S_AXI_awqos(S_AXI_awqos),
        .S_AXI_awvalid(S_AXI_awvalid),
        .S_AXI_awready(S_AXI_awready),
        .S_AXI_wdata(S_AXI_wdata),
        .S_AXI_wstrb(S_AXI_wstrb),
        .S_AXI_wlast(S_AXI_wlast),
        .S_AXI_wvalid(S_AXI_wvalid),
        .S_AXI_wready(S_AXI_wready),
        .S_AXI_bresp(S_AXI_bresp),
        .S_AXI_bvalid(S_AXI_bvalid),
        .S_AXI_bready(S_AXI_bready),
        .S_AXI_araddr(S_AXI_araddr),
        .S_AXI_arlen(S_AXI_arlen),
        .S_AXI_arsize(S_AXI_arsize),
        .S_AXI_arburst(S_AXI_arburst),
        .S_AXI_arlock(S_AXI_arlock),
        .S_AXI_arcache(S_AXI_arcache),
        .S_AXI_arprot(S_AXI_arprot),
        .S_AXI_arregion(S_AXI_arregion),
        .S_AXI_arqos(S_AXI_arqos),
        .S_AXI_arvalid(S_AXI_arvalid),
        .S_AXI_arready(S_AXI_arready),
        .S_AXI_rdata(S_AXI_rdata),
        .S_AXI_rresp(S_AXI_rresp),
        .S_AXI_rlast(S_AXI_rlast),
        .S_AXI_rvalid(S_AXI_rvalid),
        .S_AXI_rready(S_AXI_rready)
    );
    
    // Clock generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;  // 100MHz clock (10ns period)
    end
    
    // Task to write to memory via AXI (simplified - direct memory access for initialization)
    // Since we can't directly access memory array, we'll use a simple AXI write sequence
    task write_memory_axi;
        input [31:0] addr;
        input [31:0] data;
        begin
            // Write Address Channel
            @(posedge ACLK);
            init_awaddr = addr;
            init_awvalid = 1'b1;
            wait(S_AXI_awready);
            @(posedge ACLK);
            init_awvalid = 1'b0;
            
            // Write Data Channel
            init_wdata = data;
            init_wlast = 1'b1;
            init_wvalid = 1'b1;
            wait(S_AXI_wready);
            @(posedge ACLK);
            init_wvalid = 1'b0;
            init_wlast = 1'b0;
            
            // Write Response Channel
            init_bready = 1'b1;
            wait(S_AXI_bvalid);
            @(posedge ACLK);
            init_bready = 1'b0;
        end
    endtask
    
    // Task to read from memory via AXI (for verification)
    task read_memory_axi;
        input [31:0] addr;
        output [31:0] data;
        begin
            // Read Address Channel
            @(posedge ACLK);
            init_araddr = addr;
            init_arvalid = 1'b1;
            wait(S_AXI_arready);
            @(posedge ACLK);
            init_arvalid = 1'b0;
            
            // Read Data Channel
            init_rready = 1'b1;
            wait(S_AXI_rvalid);
            @(posedge ACLK);
            data = S_AXI_rdata;
            init_rready = 1'b0;
            #10;
        end
    endtask
    
    // Task to run a single test case
    task run_testcase;
        input [31:0] instruction;
        input [31:0] operand1;
        input [31:0] operand2;
        input [31:0] expected_result;
        input [7:0]  op1_addr;
        input [7:0]  op2_addr;
        input [7:0]  dst_addr;
        input [31:0] pc_addr;
        input [3:0]  opcode;
        input [79:0] test_name;
        reg [31:0] read_result;
        begin
            $display("\n========================================");
            $display("Test: %s", test_name);
            $display("========================================");
            
            // Switch to init mode
            init_mode = 1;
            #20;
            
            // Write instruction and operands
            write_memory_axi(pc_addr, instruction);
            write_memory_axi({24'h0, op1_addr}, operand1);
            if (opcode != 4'b0101) begin  // NOT doesn't need operand2
                write_memory_axi({24'h0, op2_addr}, operand2);
            end
            
            $display("  Instruction: 0x%08X at addr 0x%08X", instruction, pc_addr);
            $display("  Operand1:    0x%08X (%0d) at addr 0x%02X", operand1, operand1, op1_addr);
            if (opcode != 4'b0101) begin
                $display("  Operand2:    0x%08X (%0d) at addr 0x%02X", operand2, operand2, op2_addr);
            end
            $display("  Expected:    0x%08X (%0d) at addr 0x%02X", expected_result, expected_result, dst_addr);
            
            // Switch to CPU mode
            #50;
            init_mode = 0;
            #50;
            
            // Reset CPU briefly to reset PC to 0
            ARESETN = 0;
            #20;
            ARESETN = 1;
            #30;
            
            // Start CPU execution
            cpu_start = 1;
            #10;
            cpu_start = 0;
            
            // Wait for completion
            wait(cpu_done);
            #100;
            
            // Verify result
            init_mode = 1;
            #20;
            read_memory_axi({24'h0, dst_addr}, read_result);
            #20;
            init_mode = 0;
            
            if (read_result == expected_result) begin
                $display("  *** PASS *** Got: 0x%08X (%0d)", read_result, read_result);
            end else begin
                $display("  *** FAIL *** Expected: 0x%08X (%0d), Got: 0x%08X (%0d)", 
                         expected_result, expected_result, read_result, read_result);
            end
            
            #100;
        end
    endtask
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("CPU ALU Master Testbench Started");
        $display("Testing all ALU operations");
        $display("========================================");
        
        // Initialize signals
        ARESETN = 0;
        cpu_start = 0;
        init_mode = 1;  // Start in initialization mode
        init_awvalid = 0;
        init_wvalid = 0;
        init_bready = 0;
        
        // Reset sequence
        #100;
        ARESETN = 1;
        #50;
        
        $display("\n[Time %0t] Reset released", $time);
        
        // Test 1: ADD (10 + 5 = 15)
        // Instruction format: [opcode(31:28)][src1(23:16)][src2(15:8)][dst(7:0)]
        // run_testcase(instruction, operand1, operand2, expected_result, op1_addr, op2_addr, dst_addr, pc_addr, opcode, test_name)
        run_testcase(32'h00101420, 32'h0000000A, 32'h00000005, 32'h0000000F, 8'h10, 8'h14, 8'h20, 32'h00000000, 4'h0, "ADD: 10 + 5 = 15");
        
        // Test 2: SUB (10 - 5 = 5)
        run_testcase(32'h10101424, 32'h0000000A, 32'h00000005, 32'h00000005, 8'h10, 8'h14, 8'h24, 32'h00000000, 4'h1, "SUB: 10 - 5 = 5");
        
        // Test 3: AND (0x0F & 0x03 = 0x03)
        run_testcase(32'h20101428, 32'h0000000F, 32'h00000003, 32'h00000003, 8'h10, 8'h14, 8'h28, 32'h00000000, 4'h2, "AND: 0x0F & 0x03 = 0x03");
        
        // Test 4: OR (0x0F | 0x03 = 0x0F)
        run_testcase(32'h3010142C, 32'h0000000F, 32'h00000003, 32'h0000000F, 8'h10, 8'h14, 8'h2C, 32'h00000000, 4'h3, "OR: 0x0F | 0x03 = 0x0F");
        
        // Test 5: XOR (0x0F ^ 0x03 = 0x0C)
        run_testcase(32'h40101430, 32'h0000000F, 32'h00000003, 32'h0000000C, 8'h10, 8'h14, 8'h30, 32'h00000000, 4'h4, "XOR: 0x0F ^ 0x03 = 0x0C");
        
        // Test 6: NOT (~0x0F = 0xFFFFFFF0)
        run_testcase(32'h50100034, 32'h0000000F, 32'h00000000, 32'hFFFFFFF0, 8'h10, 8'h14, 8'h34, 32'h00000000, 4'h5, "NOT: ~0x0F = 0xFFFFFFF0");
        
        // Test 7: SHIFT_LEFT (0x01 << 3 = 0x08)
        run_testcase(32'h60101438, 32'h00000001, 32'h00000003, 32'h00000008, 8'h10, 8'h14, 8'h38, 32'h00000000, 4'h6, "SHIFT_LEFT: 0x01 << 3 = 0x08");
        
        // Test 8: SHIFT_RIGHT (0x08 >> 3 = 0x01)
        run_testcase(32'h7010143C, 32'h00000008, 32'h00000003, 32'h00000001, 8'h10, 8'h14, 8'h3C, 32'h00000000, 4'h7, "SHIFT_RIGHT: 0x08 >> 3 = 0x01");
        
        // Additional test cases
        // Test 9: ADD with larger numbers (100 + 200 = 300)
        run_testcase(32'h00101440, 32'h00000064, 32'h000000C8, 32'h0000012C, 8'h10, 8'h14, 8'h40, 32'h00000000, 4'h0, "ADD: 100 + 200 = 300");
        
        // Test 10: SUB with borrow (5 - 10 = -5 = 0xFFFFFFFB)
        run_testcase(32'h10101444, 32'h00000005, 32'h0000000A, 32'hFFFFFFFB, 8'h10, 8'h14, 8'h44, 32'h00000000, 4'h1, "SUB: 5 - 10 = -5 (0xFFFFFFFB)");
        
        // Test 11: AND with all bits (0xFFFFFFFF & 0x0000FFFF = 0x0000FFFF)
        run_testcase(32'h20101448, 32'hFFFFFFFF, 32'h0000FFFF, 32'h0000FFFF, 8'h10, 8'h14, 8'h48, 32'h00000000, 4'h2, "AND: 0xFFFFFFFF & 0x0000FFFF = 0x0000FFFF");
        
        // Test 12: SHIFT_LEFT with larger shift (0x01 << 8 = 0x0100)
        run_testcase(32'h6010144C, 32'h00000001, 32'h00000008, 32'h00000100, 8'h10, 8'h14, 8'h4C, 32'h00000000, 4'h6, "SHIFT_LEFT: 0x01 << 8 = 0x0100");
        
        $display("\n========================================");
        $display("All Test Cases Completed");
        $display("========================================");
        #200;
        $finish;
    end
    
    // Monitor signals
    always @(posedge ACLK) begin
        if (cpu_start) begin
            $display("[Time %0t] CPU started", $time);
        end
        if (cpu_done) begin
            $display("[Time %0t] CPU done", $time);
        end
    end

endmodule

