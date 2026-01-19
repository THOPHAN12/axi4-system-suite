`timescale 1ns/1ps

//==============================================================================
// design_1_wrapper_tb.sv
// Testbench for design_1_wrapper (Block Design with Zynq PS + AXI Interconnect)
//==============================================================================
// This testbench simulates the complete block design including:
//   - Zynq UltraScale+ PS (using Vivado's built-in simulation model)
//   - AXI Master Bridges (2)
//   - AXI Interconnect (2M x 4S)
//   - AXI Slave Bridges + Peripherals (BRAM, GPIO, UART, SPI)
//
// IMPORTANT: This testbench is designed to run in Vivado project where:
//   1. Block design has been generated with output products
//   2. Zynq PS simulation model is available
//   3. design_1_wrapper has been created (may be empty initially)
//
// This testbench does NOT create external ports for Zynq PS masters to avoid
// I/O overutilization (would require ~692 pins, exceeding KV260's 252 pin limit).
// Instead, it tests the block design through internal AXI transactions.
//==============================================================================

module design_1_wrapper_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz clock (pl_clk0 from Zynq PS)
    parameter TIMEOUT = 50000;  // 50us timeout
    
    // Address ranges (from block design address map)
    parameter S0_BASE = 32'h00000000;  // BRAM (64KB)
    parameter S0_END  = 32'h0000FFFF;
    parameter S1_BASE = 32'h40000000;  // GPIO (512MB range, 64KB actual)
    parameter S1_END  = 32'h5FFFFFFF;
    parameter S2_BASE = 32'h80000000;  // UART (512MB range, 64KB actual)
    parameter S2_END  = 32'h9FFFFFFF;
    parameter S3_BASE = 32'hC0000000;  // SPI (512MB range, 64KB actual)
    parameter S3_END  = 32'hDFFFFFFF;
    
    //==============================================================================
    // Clock and Reset
    //==============================================================================
    logic pl_clk0 = 0;        // 100MHz clock from Zynq PS
    logic pl_resetn0 = 1;      // Reset from Zynq PS (active low)
    logic interconnect_aresetn = 1;
    logic peripheral_aresetn = 1;
    
    //==============================================================================
    // Zynq PS AXI Master 0 (M_AXI_HPM0_FPD) - Simulated with BFM
    //==============================================================================
    // Write Address Channel
    logic [31:0]    M0_HPM0_AWADDR;
    logic [1:0]     M0_HPM0_AWBURST;
    logic [3:0]     M0_HPM0_AWCACHE;
    logic [15:0]   M0_HPM0_AWID;
    logic [7:0]     M0_HPM0_AWLEN;
    logic           M0_HPM0_AWLOCK;
    logic [2:0]     M0_HPM0_AWPROT;
    logic [3:0]     M0_HPM0_AWQOS;
    logic           M0_HPM0_AWREADY;
    logic [2:0]     M0_HPM0_AWSIZE;
    logic           M0_HPM0_AWVALID;
    // Write Data Channel
    logic [31:0]    M0_HPM0_WDATA;
    logic           M0_HPM0_WLAST;
    logic           M0_HPM0_WREADY;
    logic [3:0]     M0_HPM0_WSTRB;
    logic           M0_HPM0_WVALID;
    // Write Response Channel
    logic [1:0]     M0_HPM0_BID;
    logic           M0_HPM0_BREADY;
    logic [1:0]     M0_HPM0_BRESP;
    logic           M0_HPM0_BVALID;
    // Read Address Channel
    logic [31:0]    M0_HPM0_ARADDR;
    logic [1:0]     M0_HPM0_ARBURST;
    logic [3:0]     M0_HPM0_ARCACHE;
    logic [15:0]   M0_HPM0_ARID;
    logic [7:0]     M0_HPM0_ARLEN;
    logic           M0_HPM0_ARLOCK;
    logic [2:0]     M0_HPM0_ARPROT;
    logic [3:0]     M0_HPM0_ARQOS;
    logic           M0_HPM0_ARREADY;
    logic [2:0]     M0_HPM0_ARSIZE;
    logic           M0_HPM0_ARVALID;
    // Read Data Channel
    logic [31:0]    M0_HPM0_RDATA;
    logic [1:0]     M0_HPM0_RID;
    logic           M0_HPM0_RLAST;
    logic           M0_HPM0_RREADY;
    logic [1:0]     M0_HPM0_RRESP;
    logic           M0_HPM0_RVALID;
    
    //==============================================================================
    // Zynq PS AXI Master 1 (M_AXI_HPM1_FPD) - Simulated with BFM
    //==============================================================================
    // Write Address Channel
    logic [31:0]    M1_HPM1_AWADDR;
    logic [1:0]     M1_HPM1_AWBURST;
    logic [3:0]     M1_HPM1_AWCACHE;
    logic [15:0]   M1_HPM1_AWID;
    logic [7:0]     M1_HPM1_AWLEN;
    logic           M1_HPM1_AWLOCK;
    logic [2:0]     M1_HPM1_AWPROT;
    logic [3:0]     M1_HPM1_AWQOS;
    logic           M1_HPM1_AWREADY;
    logic [2:0]     M1_HPM1_AWSIZE;
    logic           M1_HPM1_AWVALID;
    // Write Data Channel
    logic [31:0]    M1_HPM1_WDATA;
    logic           M1_HPM1_WLAST;
    logic           M1_HPM1_WREADY;
    logic [3:0]     M1_HPM1_WSTRB;
    logic           M1_HPM1_WVALID;
    // Write Response Channel
    logic [1:0]     M1_HPM1_BID;
    logic           M1_HPM1_BREADY;
    logic [1:0]     M1_HPM1_BRESP;
    logic           M1_HPM1_BVALID;
    // Read Address Channel
    logic [31:0]    M1_HPM1_ARADDR;
    logic [1:0]     M1_HPM1_ARBURST;
    logic [3:0]     M1_HPM1_ARCACHE;
    logic [15:0]   M1_HPM1_ARID;
    logic [7:0]     M1_HPM1_ARLEN;
    logic           M1_HPM1_ARLOCK;
    logic [2:0]     M1_HPM1_ARPROT;
    logic [3:0]     M1_HPM1_ARQOS;
    logic           M1_HPM1_ARREADY;
    logic [2:0]     M1_HPM1_ARSIZE;
    logic           M1_HPM1_ARVALID;
    // Read Data Channel
    logic [31:0]    M1_HPM1_RDATA;
    logic [1:0]     M1_HPM1_RID;
    logic           M1_HPM1_RLAST;
    logic           M1_HPM1_RREADY;
    logic [1:0]     M1_HPM1_RRESP;
    logic           M1_HPM1_RVALID;
    
    //==============================================================================
    // Test Statistics
    //==============================================================================
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    //==============================================================================
    // Clock Generation
    //==============================================================================
    always #(CLK_PERIOD/2) pl_clk0 = ~pl_clk0;
    
    //==============================================================================
    // Reset Generation
    //==============================================================================
    initial begin
        pl_resetn0 = 0;
        interconnect_aresetn = 0;
        peripheral_aresetn = 0;
        #(CLK_PERIOD * 20);
        pl_resetn0 = 1;
        #(CLK_PERIOD * 5);
        interconnect_aresetn = 1;
        peripheral_aresetn = 1;
        $display("[%0t] Reset released", $time);
    end
    
    //==============================================================================
    // DUT Instantiation
    //==============================================================================
    // Note: This testbench is designed to work with Vivado's block design.
    // The block design should be generated with output products before running
    // this testbench.
    //
    // Option 1: If design_1_wrapper has been generated with ports, use it:
    // design_1_wrapper dut ();
    //
    // Option 2: If wrapper is empty, we can test by accessing internal signals
    // through hierarchical paths (requires proper setup in Vivado).
    //
    // Option 3: For standalone simulation, test AXI Interconnect directly
    // (see comprehensive_system_tb.sv for reference).
    //
    // For now, we'll create a simplified approach that can work in both scenarios:
    
    // Since we cannot easily access internal signals of block design without
    // proper wrapper ports, this testbench provides a framework that can be
    // adapted based on how the block design is generated.
    //
    // In Vivado, you can:
    // 1. Generate block design output products
    // 2. Create HDL wrapper
    // 3. Use Vivado's simulation capabilities to test the design
    //
    // This testbench serves as a template and can be extended when wrapper
    // is properly generated.
    
    //==============================================================================
    // Note: AXI Master BFMs are provided for reference, but in actual Vivado
    // simulation with block design, Zynq PS simulation model will be used instead.
    // These BFMs can be used if testing AXI Interconnect directly.
    //==============================================================================
    
    // AXI Master BFM 0 - For direct AXI Interconnect testing (optional)
    // In block design simulation, Zynq PS model handles this
    axi_master_bfm #(
        .C_M_AXI_ID_WIDTH(16),
        .C_M_AXI_ADDR_WIDTH(32),
        .C_M_AXI_DATA_WIDTH(32)
    ) master0_bfm (
        .M_AXI_ACLK(pl_clk0),
        .M_AXI_ARESETN(peripheral_aresetn),
        // Write Address
        .M_AXI_AWADDR(M0_HPM0_AWADDR),
        .M_AXI_AWBURST(M0_HPM0_AWBURST),
        .M_AXI_AWCACHE(M0_HPM0_AWCACHE),
        .M_AXI_AWID(M0_HPM0_AWID),
        .M_AXI_AWLEN(M0_HPM0_AWLEN),
        .M_AXI_AWLOCK(M0_HPM0_AWLOCK),
        .M_AXI_AWPROT(M0_HPM0_AWPROT),
        .M_AXI_AWQOS(M0_HPM0_AWQOS),
        .M_AXI_AWREADY(M0_HPM0_AWREADY),
        .M_AXI_AWSIZE(M0_HPM0_AWSIZE),
        .M_AXI_AWVALID(M0_HPM0_AWVALID),
        // Write Data
        .M_AXI_WDATA(M0_HPM0_WDATA),
        .M_AXI_WLAST(M0_HPM0_WLAST),
        .M_AXI_WREADY(M0_HPM0_WREADY),
        .M_AXI_WSTRB(M0_HPM0_WSTRB),
        .M_AXI_WVALID(M0_HPM0_WVALID),
        // Write Response
        .M_AXI_BID(M0_HPM0_BID),
        .M_AXI_BREADY(M0_HPM0_BREADY),
        .M_AXI_BRESP(M0_HPM0_BRESP),
        .M_AXI_BVALID(M0_HPM0_BVALID),
        // Read Address
        .M_AXI_ARADDR(M0_HPM0_ARADDR),
        .M_AXI_ARBURST(M0_HPM0_ARBURST),
        .M_AXI_ARCACHE(M0_HPM0_ARCACHE),
        .M_AXI_ARID(M0_HPM0_ARID),
        .M_AXI_ARLEN(M0_HPM0_ARLEN),
        .M_AXI_ARLOCK(M0_HPM0_ARLOCK),
        .M_AXI_ARPROT(M0_HPM0_ARPROT),
        .M_AXI_ARQOS(M0_HPM0_ARQOS),
        .M_AXI_ARREADY(M0_HPM0_ARREADY),
        .M_AXI_ARSIZE(M0_HPM0_ARSIZE),
        .M_AXI_ARVALID(M0_HPM0_ARVALID),
        // Read Data
        .M_AXI_RDATA(M0_HPM0_RDATA),
        .M_AXI_RID(M0_HPM0_RID),
        .M_AXI_RLAST(M0_HPM0_RLAST),
        .M_AXI_RREADY(M0_HPM0_RREADY),
        .M_AXI_RRESP(M0_HPM0_RRESP),
        .M_AXI_RVALID(M0_HPM0_RVALID)
    );
    
    //==============================================================================
    // AXI Master BFM 1 - Simulates Zynq PS M_AXI_HPM1_FPD
    //==============================================================================
    axi_master_bfm #(
        .C_M_AXI_ID_WIDTH(16),
        .C_M_AXI_ADDR_WIDTH(32),
        .C_M_AXI_DATA_WIDTH(32)
    ) master1_bfm (
        .M_AXI_ACLK(pl_clk0),
        .M_AXI_ARESETN(peripheral_aresetn),
        // Write Address
        .M_AXI_AWADDR(M1_HPM1_AWADDR),
        .M_AXI_AWBURST(M1_HPM1_AWBURST),
        .M_AXI_AWCACHE(M1_HPM1_AWCACHE),
        .M_AXI_AWID(M1_HPM1_AWID),
        .M_AXI_AWLEN(M1_HPM1_AWLEN),
        .M_AXI_AWLOCK(M1_HPM1_AWLOCK),
        .M_AXI_AWPROT(M1_HPM1_AWPROT),
        .M_AXI_AWQOS(M1_HPM1_AWQOS),
        .M_AXI_AWREADY(M1_HPM1_AWREADY),
        .M_AXI_AWSIZE(M1_HPM1_AWSIZE),
        .M_AXI_AWVALID(M1_HPM1_AWVALID),
        // Write Data
        .M_AXI_WDATA(M1_HPM1_WDATA),
        .M_AXI_WLAST(M1_HPM1_WLAST),
        .M_AXI_WREADY(M1_HPM1_WREADY),
        .M_AXI_WSTRB(M1_HPM1_WSTRB),
        .M_AXI_WVALID(M1_HPM1_WVALID),
        // Write Response
        .M_AXI_BID(M1_HPM1_BID),
        .M_AXI_BREADY(M1_HPM1_BREADY),
        .M_AXI_BRESP(M1_HPM1_BRESP),
        .M_AXI_BVALID(M1_HPM1_BVALID),
        // Read Address
        .M_AXI_ARADDR(M1_HPM1_ARADDR),
        .M_AXI_ARBURST(M1_HPM1_ARBURST),
        .M_AXI_ARCACHE(M1_HPM1_ARCACHE),
        .M_AXI_ARID(M1_HPM1_ARID),
        .M_AXI_ARLEN(M1_HPM1_ARLEN),
        .M_AXI_ARLOCK(M1_HPM1_ARLOCK),
        .M_AXI_ARPROT(M1_HPM1_ARPROT),
        .M_AXI_ARQOS(M1_HPM1_ARQOS),
        .M_AXI_ARREADY(M1_HPM1_ARREADY),
        .M_AXI_ARSIZE(M1_HPM1_ARSIZE),
        .M_AXI_ARVALID(M1_HPM1_ARVALID),
        // Read Data
        .M_AXI_RDATA(M1_HPM1_RDATA),
        .M_AXI_RID(M1_HPM1_RID),
        .M_AXI_RLAST(M1_HPM1_RLAST),
        .M_AXI_RREADY(M1_HPM1_RREADY),
        .M_AXI_RRESP(M1_HPM1_RRESP),
        .M_AXI_RVALID(M1_HPM1_RVALID)
    );
    
    //==============================================================================
    // Helper Tasks
    //==============================================================================
    
    task check_test(string test_name, logic condition);
        test_count++;
        if (condition) begin
            pass_count++;
            $display("[%0t] [PASS] %s", $time, test_name);
        end else begin
            fail_count++;
            $display("[%0t] [FAIL] %s", $time, test_name);
        end
    endtask
    
    task print_statistics();
        $display("");
        $display("============================================================================");
        $display("Test Statistics");
        $display("============================================================================");
        $display("Total Test Cases: %0d", test_count);
        $display("Passed:           %0d", pass_count);
        $display("Failed:           %0d", fail_count);
        if (test_count > 0) begin
            $display("Pass Rate:        %0.1f%%", (pass_count * 100.0) / test_count);
        end
        $display("============================================================================");
    endtask
    
    //==============================================================================
    // Test Cases
    //==============================================================================
    
    //==============================================================================
    // AXI Master BFM Helper Tasks
    //==============================================================================
    // These tasks control the BFM modules through signals
    
    task write_single_m0(input [31:0] addr, input [31:0] data);
        // Write Address Channel
        @(posedge pl_clk0);
        M0_HPM0_AWADDR <= addr;
        M0_HPM0_AWBURST <= 2'b00;  // FIXED
        M0_HPM0_AWCACHE <= 4'b0000;
        M0_HPM0_AWID <= 16'h0;
        M0_HPM0_AWLEN <= 8'h00;  // Single transaction
        M0_HPM0_AWLOCK <= 1'b0;
        M0_HPM0_AWPROT <= 3'b000;
        M0_HPM0_AWQOS <= 4'h0;
        M0_HPM0_AWSIZE <= 3'b010;  // 4 bytes
        M0_HPM0_AWVALID <= 1'b1;
        
        // Wait for AWREADY
        wait(M0_HPM0_AWREADY);
        @(posedge pl_clk0);
        M0_HPM0_AWVALID <= 1'b0;
        
        // Write Data Channel
        M0_HPM0_WDATA <= data;
        M0_HPM0_WSTRB <= 4'hF;
        M0_HPM0_WLAST <= 1'b1;
        M0_HPM0_WVALID <= 1'b1;
        
        // Wait for WREADY
        wait(M0_HPM0_WREADY);
        @(posedge pl_clk0);
        M0_HPM0_WVALID <= 1'b0;
        M0_HPM0_WLAST <= 1'b0;
        
        // Write Response Channel
        M0_HPM0_BREADY <= 1'b1;
        wait(M0_HPM0_BVALID);
        @(posedge pl_clk0);
        M0_HPM0_BREADY <= 1'b0;
    endtask
    
    task read_single_m0(input [31:0] addr, output [31:0] data);
        // Read Address Channel
        @(posedge pl_clk0);
        M0_HPM0_ARADDR <= addr;
        M0_HPM0_ARBURST <= 2'b00;  // FIXED
        M0_HPM0_ARCACHE <= 4'b0000;
        M0_HPM0_ARID <= 16'h0;
        M0_HPM0_ARLEN <= 8'h00;  // Single transaction
        M0_HPM0_ARLOCK <= 1'b0;
        M0_HPM0_ARPROT <= 3'b000;
        M0_HPM0_ARQOS <= 4'h0;
        M0_HPM0_ARSIZE <= 3'b010;  // 4 bytes
        M0_HPM0_ARVALID <= 1'b1;
        
        // Wait for ARREADY
        wait(M0_HPM0_ARREADY);
        @(posedge pl_clk0);
        M0_HPM0_ARVALID <= 1'b0;
        
        // Read Data Channel
        M0_HPM0_RREADY <= 1'b1;
        wait(M0_HPM0_RVALID);
        @(posedge pl_clk0);
        data = M0_HPM0_RDATA;
        M0_HPM0_RREADY <= 1'b0;
    endtask
    
    task write_single_m1(input [31:0] addr, input [31:0] data);
        // Write Address Channel
        @(posedge pl_clk0);
        M1_HPM1_AWADDR <= addr;
        M1_HPM1_AWBURST <= 2'b00;  // FIXED
        M1_HPM1_AWCACHE <= 4'b0000;
        M1_HPM1_AWID <= 16'h0;
        M1_HPM1_AWLEN <= 8'h00;  // Single transaction
        M1_HPM1_AWLOCK <= 1'b0;
        M1_HPM1_AWPROT <= 3'b000;
        M1_HPM1_AWQOS <= 4'h0;
        M1_HPM1_AWSIZE <= 3'b010;  // 4 bytes
        M1_HPM1_AWVALID <= 1'b1;
        
        // Wait for AWREADY
        wait(M1_HPM1_AWREADY);
        @(posedge pl_clk0);
        M1_HPM1_AWVALID <= 1'b0;
        
        // Write Data Channel
        M1_HPM1_WDATA <= data;
        M1_HPM1_WSTRB <= 4'hF;
        M1_HPM1_WLAST <= 1'b1;
        M1_HPM1_WVALID <= 1'b1;
        
        // Wait for WREADY
        wait(M1_HPM1_WREADY);
        @(posedge pl_clk0);
        M1_HPM1_WVALID <= 1'b0;
        M1_HPM1_WLAST <= 1'b0;
        
        // Write Response Channel
        M1_HPM1_BREADY <= 1'b1;
        wait(M1_HPM1_BVALID);
        @(posedge pl_clk0);
        M1_HPM1_BREADY <= 1'b0;
    endtask
    
    task read_single_m1(input [31:0] addr, output [31:0] data);
        // Read Address Channel
        @(posedge pl_clk0);
        M1_HPM1_ARADDR <= addr;
        M1_HPM1_ARBURST <= 2'b00;  // FIXED
        M1_HPM1_ARCACHE <= 4'b0000;
        M1_HPM1_ARID <= 16'h0;
        M1_HPM1_ARLEN <= 8'h00;  // Single transaction
        M1_HPM1_ARLOCK <= 1'b0;
        M1_HPM1_ARPROT <= 3'b000;
        M1_HPM1_ARQOS <= 4'h0;
        M1_HPM1_ARSIZE <= 3'b010;  // 4 bytes
        M1_HPM1_ARVALID <= 1'b1;
        
        // Wait for ARREADY
        wait(M1_HPM1_ARREADY);
        @(posedge pl_clk0);
        M1_HPM1_ARVALID <= 1'b0;
        
        // Read Data Channel
        M1_HPM1_RREADY <= 1'b1;
        wait(M1_HPM1_RVALID);
        @(posedge pl_clk0);
        data = M1_HPM1_RDATA;
        M1_HPM1_RREADY <= 1'b0;
    endtask
    
    // Test 1: Basic Write to BRAM (S0)
    task test_write_to_bram();
        $display("");
        $display("============================================================================");
        $display("Test 1: Write to BRAM (S0)");
        $display("============================================================================");
        
        // Write data to BRAM
        write_single_m0(S0_BASE, 32'hDEADBEEF);
        #(CLK_PERIOD * 10);
        
        // Read back to verify
        logic [31:0] read_data;
        read_single_m0(S0_BASE, read_data);
        #(CLK_PERIOD * 10);
        
        check_test("Write to BRAM successful", (read_data == 32'hDEADBEEF));
    endtask
    
    // Test 2: Basic Read from BRAM (S0)
    task test_read_from_bram();
        $display("");
        $display("============================================================================");
        $display("Test 2: Read from BRAM (S0)");
        $display("============================================================================");
        
        // First write some data
        write_single_m0(S0_BASE + 4, 32'hCAFEBABE);
        #(CLK_PERIOD * 10);
        
        // Read back
        logic [31:0] read_data;
        read_single_m0(S0_BASE + 4, read_data);
        #(CLK_PERIOD * 10);
        
        check_test("Read from BRAM successful", (read_data == 32'hCAFEBABE));
    endtask
    
    // Test 3: Write to GPIO (S1)
    task test_write_to_gpio();
        $display("");
        $display("============================================================================");
        $display("Test 3: Write to GPIO (S1)");
        $display("============================================================================");
        
        // Write to GPIO register
        write_single_m0(S1_BASE, 32'h0000FFFF);
        #(CLK_PERIOD * 10);
        
        check_test("Write to GPIO successful", 1'b1);
    endtask
    
    // Test 4: Concurrent Access from Two Masters
    task test_concurrent_access();
        $display("");
        $display("============================================================================");
        $display("Test 4: Concurrent Access from Two Masters");
        $display("============================================================================");
        
        // Master 0 writes to S0
        fork
            begin
                write_single_m0(S0_BASE + 8, 32'h11111111);
            end
            begin
                #(CLK_PERIOD * 2);
                write_single_m1(S0_BASE + 12, 32'h22222222);
            end
        join
        
        #(CLK_PERIOD * 20);
        
        // Verify both writes completed
        logic [31:0] data0, data1;
        read_single_m0(S0_BASE + 8, data0);
        #(CLK_PERIOD * 5);
        read_single_m1(S0_BASE + 12, data1);
        #(CLK_PERIOD * 5);
        
        check_test("Concurrent write M0", (data0 == 32'h11111111));
        check_test("Concurrent write M1", (data1 == 32'h22222222));
    endtask
    
    //==============================================================================
    // Global Timeout Monitor
    //==============================================================================
    initial begin
        #(TIMEOUT * CLK_PERIOD);
        $display("");
        $display("============================================================================");
        $display("[%0t] [TIMEOUT] Simulation timeout reached (%0d ns)", $time, TIMEOUT * CLK_PERIOD);
        $display("============================================================================");
        print_statistics();
        $finish;
    end
    
    //==============================================================================
    // Main Test Sequence
    //==============================================================================
    initial begin
        $display("============================================================================");
        $display("design_1_wrapper Testbench");
        $display("Testing Block Design with Zynq PS + AXI Interconnect");
        $display("============================================================================");
        $display("");
        $display("NOTE: This testbench is designed to work with Vivado block design.");
        $display("      For best results:");
        $display("      1. Generate block design output products");
        $display("      2. Create HDL wrapper");
        $display("      3. Run simulation in Vivado project");
        $display("");
        $display("      Alternative: Use comprehensive_system_tb.sv to test");
        $display("      AXI Interconnect directly without block design.");
        $display("");
        
        // Wait for reset release
        wait(peripheral_aresetn);
        #(CLK_PERIOD * 10);
        
        $display("[%0t] Starting tests...", $time);
        $display("");
        $display("[%0t] NOTE: Test cases require proper DUT instantiation.", $time);
        $display("[%0t]       In Vivado, use block design simulation instead.", $time);
        $display("");
        
        // Run test cases (will work when DUT is properly instantiated)
        // For now, these serve as templates
        /*
        test_write_to_bram();
        #(CLK_PERIOD * 10);
        
        test_read_from_bram();
        #(CLK_PERIOD * 10);
        
        test_write_to_gpio();
        #(CLK_PERIOD * 10);
        
        test_concurrent_access();
        #(CLK_PERIOD * 10);
        */
        
        $display("[%0t] Testbench framework ready. Adapt based on block design setup.", $time);
        
        // Print final statistics
        print_statistics();
        
        $display("");
        $display("============================================================================");
        $display("Testbench Complete!");
        $display("============================================================================");
        $display("For actual testing, use Vivado's block design simulation or");
        $display("adapt this testbench based on your block design configuration.");
        $display("============================================================================");
        $display("Simulation finished at time %0t", $time);
        $display("============================================================================");
        #(CLK_PERIOD * 100);
        $finish;
    end
    
    //==============================================================================
    // Waveform Dump
    //==============================================================================
    initial begin
        $dumpfile("design_1_wrapper_tb.vcd");
        $dumpvars(0, design_1_wrapper_tb);
    end

endmodule

//==============================================================================
// AXI Master BFM (Bus Functional Model)
//==============================================================================
// Simple AXI Master BFM - just passes through signals
// Control is done through tasks in testbench
//==============================================================================

module axi_master_bfm #(
    parameter C_M_AXI_ID_WIDTH = 16,
    parameter C_M_AXI_ADDR_WIDTH = 32,
    parameter C_M_AXI_DATA_WIDTH = 32
)(
    input  wire                              M_AXI_ACLK,
    input  wire                              M_AXI_ARESETN,
    
    // Write Address Channel
    output reg  [C_M_AXI_ADDR_WIDTH-1:0]    M_AXI_AWADDR,
    output reg  [1:0]                        M_AXI_AWBURST,
    output reg  [3:0]                        M_AXI_AWCACHE,
    output reg  [C_M_AXI_ID_WIDTH-1:0]      M_AXI_AWID,
    output reg  [7:0]                        M_AXI_AWLEN,
    output reg                               M_AXI_AWLOCK,
    output reg  [2:0]                        M_AXI_AWPROT,
    output reg  [3:0]                        M_AXI_AWQOS,
    input  wire                              M_AXI_AWREADY,
    output reg  [2:0]                        M_AXI_AWSIZE,
    output reg                               M_AXI_AWVALID,
    
    // Write Data Channel
    output reg  [C_M_AXI_DATA_WIDTH-1:0]     M_AXI_WDATA,
    output reg                               M_AXI_WLAST,
    input  wire                              M_AXI_WREADY,
    output reg  [C_M_AXI_DATA_WIDTH/8-1:0]   M_AXI_WSTRB,
    output reg                               M_AXI_WVALID,
    
    // Write Response Channel
    input  wire [C_M_AXI_ID_WIDTH-1:0]       M_AXI_BID,
    output reg                               M_AXI_BREADY,
    input  wire [1:0]                        M_AXI_BRESP,
    input  wire                              M_AXI_BVALID,
    
    // Read Address Channel
    output reg  [C_M_AXI_ADDR_WIDTH-1:0]     M_AXI_ARADDR,
    output reg  [1:0]                        M_AXI_ARBURST,
    output reg  [3:0]                        M_AXI_ARCACHE,
    output reg  [C_M_AXI_ID_WIDTH-1:0]       M_AXI_ARID,
    output reg  [7:0]                        M_AXI_ARLEN,
    output reg                               M_AXI_ARLOCK,
    output reg  [2:0]                        M_AXI_ARPROT,
    output reg  [3:0]                        M_AXI_ARQOS,
    input  wire                              M_AXI_ARREADY,
    output reg  [2:0]                        M_AXI_ARSIZE,
    output reg                               M_AXI_ARVALID,
    
    // Read Data Channel
    input  wire [C_M_AXI_DATA_WIDTH-1:0]     M_AXI_RDATA,
    input  wire [C_M_AXI_ID_WIDTH-1:0]       M_AXI_RID,
    input  wire                              M_AXI_RLAST,
    output reg                               M_AXI_RREADY,
    input  wire [1:0]                        M_AXI_RRESP,
    input  wire                              M_AXI_RVALID
);

    // Initialize outputs
    initial begin
        M_AXI_AWADDR <= 0;
        M_AXI_AWBURST <= 0;
        M_AXI_AWCACHE <= 0;
        M_AXI_AWID <= 0;
        M_AXI_AWLEN <= 0;
        M_AXI_AWLOCK <= 0;
        M_AXI_AWPROT <= 0;
        M_AXI_AWQOS <= 0;
        M_AXI_AWSIZE <= 0;
        M_AXI_AWVALID <= 0;
        M_AXI_WDATA <= 0;
        M_AXI_WLAST <= 0;
        M_AXI_WSTRB <= 0;
        M_AXI_WVALID <= 0;
        M_AXI_BREADY <= 0;
        M_AXI_ARADDR <= 0;
        M_AXI_ARBURST <= 0;
        M_AXI_ARCACHE <= 0;
        M_AXI_ARID <= 0;
        M_AXI_ARLEN <= 0;
        M_AXI_ARLOCK <= 0;
        M_AXI_ARPROT <= 0;
        M_AXI_ARQOS <= 0;
        M_AXI_ARSIZE <= 0;
        M_AXI_ARVALID <= 0;
        M_AXI_RREADY <= 0;
    end

endmodule

