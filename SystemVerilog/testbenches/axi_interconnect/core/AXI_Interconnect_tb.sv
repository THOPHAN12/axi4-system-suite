`timescale 1ns/1ps

//==============================================================================
// AXI_Interconnect_tb.sv
// Testbench for AXI_Interconnect top module (2 Masters × 4 Slaves)
// SystemVerilog version with AXI BFM and Slave Models
//==============================================================================

module AXI_Interconnect_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz clock
    parameter ARBITRATION_MODE = 1;  // 0=FIXED, 1=ROUND_ROBIN, 2=QOS

    // Clock and Reset
    logic ACLK = 0;
    logic ARESETN = 1;

    //==============================================================================
    // Master 0 AXI4 Signals
    //==============================================================================
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

    //==============================================================================
    // Master 1 AXI4 Signals
    //==============================================================================
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

    //==============================================================================
    // Slave 0 AXI4 Signals (RAM - 0x00000000 to 0x1FFFFFFF)
    //==============================================================================
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

    //==============================================================================
    // Slave 1 AXI4 Signals (GPIO - 0x40000000 to 0x5FFFFFFF)
    //==============================================================================
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
    // Slave 2 AXI4 Signals (UART - 0x80000000 to 0x9FFFFFFF)
    //==============================================================================
    logic [31:0]    S2_AWADDR;
    logic [7:0]     S2_AWLEN;
    logic [2:0]     S2_AWSIZE;
    logic [1:0]     S2_AWBURST;
    logic           S2_AWVALID;
    logic           S2_AWREADY;
    logic [31:0]    S2_WDATA;
    logic [3:0]     S2_WSTRB;
    logic           S2_WLAST;
    logic           S2_WVALID;
    logic           S2_WREADY;
    logic [1:0]     S2_BRESP;
    logic           S2_BVALID;
    logic           S2_BREADY;
    logic [31:0]    S2_ARADDR;
    logic [7:0]     S2_ARLEN;
    logic [2:0]     S2_ARSIZE;
    logic [1:0]     S2_ARBURST;
    logic           S2_ARVALID;
    logic           S2_ARREADY;
    logic [31:0]    S2_RDATA;
    logic [1:0]     S2_RRESP;
    logic           S2_RLAST;
    logic           S2_RVALID;
    logic           S2_RREADY;

    //==============================================================================
    // Slave 3 AXI4 Signals (SPI - 0xC0000000 to 0xDFFFFFFF)
    //==============================================================================
    logic [31:0]    S3_AWADDR;
    logic [7:0]     S3_AWLEN;
    logic [2:0]     S3_AWSIZE;
    logic [1:0]     S3_AWBURST;
    logic           S3_AWVALID;
    logic           S3_AWREADY;
    logic [31:0]    S3_WDATA;
    logic [3:0]     S3_WSTRB;
    logic           S3_WLAST;
    logic           S3_WVALID;
    logic           S3_WREADY;
    logic [1:0]     S3_BRESP;
    logic           S3_BVALID;
    logic           S3_BREADY;
    logic [31:0]    S3_ARADDR;
    logic [7:0]     S3_ARLEN;
    logic [2:0]     S3_ARSIZE;
    logic [1:0]     S3_ARBURST;
    logic           S3_ARVALID;
    logic           S3_ARREADY;
    logic [31:0]    S3_RDATA;
    logic [1:0]     S3_RRESP;
    logic           S3_RLAST;
    logic           S3_RVALID;
    logic           S3_RREADY;

    //==============================================================================
    // Clock Generation
    //==============================================================================
    always #(CLK_PERIOD/2) ACLK = ~ACLK;

    //==============================================================================
    // DUT Instantiation
    //==============================================================================
    AXI_Interconnect #(
        .ARBITRATION_MODE(ARBITRATION_MODE)
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
        
        // Slave 2
        .S2_AWADDR(S2_AWADDR),
        .S2_AWLEN(S2_AWLEN),
        .S2_AWSIZE(S2_AWSIZE),
        .S2_AWBURST(S2_AWBURST),
        .S2_AWVALID(S2_AWVALID),
        .S2_AWREADY(S2_AWREADY),
        .S2_WDATA(S2_WDATA),
        .S2_WSTRB(S2_WSTRB),
        .S2_WLAST(S2_WLAST),
        .S2_WVALID(S2_WVALID),
        .S2_WREADY(S2_WREADY),
        .S2_BRESP(S2_BRESP),
        .S2_BVALID(S2_BVALID),
        .S2_BREADY(S2_BREADY),
        .S2_ARADDR(S2_ARADDR),
        .S2_ARLEN(S2_ARLEN),
        .S2_ARSIZE(S2_ARSIZE),
        .S2_ARBURST(S2_ARBURST),
        .S2_ARVALID(S2_ARVALID),
        .S2_ARREADY(S2_ARREADY),
        .S2_RDATA(S2_RDATA),
        .S2_RRESP(S2_RRESP),
        .S2_RLAST(S2_RLAST),
        .S2_RVALID(S2_RVALID),
        .S2_RREADY(S2_RREADY),
        
        // Slave 3
        .S3_AWADDR(S3_AWADDR),
        .S3_AWLEN(S3_AWLEN),
        .S3_AWSIZE(S3_AWSIZE),
        .S3_AWBURST(S3_AWBURST),
        .S3_AWVALID(S3_AWVALID),
        .S3_AWREADY(S3_AWREADY),
        .S3_WDATA(S3_WDATA),
        .S3_WSTRB(S3_WSTRB),
        .S3_WLAST(S3_WLAST),
        .S3_WVALID(S3_WVALID),
        .S3_WREADY(S3_WREADY),
        .S3_BRESP(S3_BRESP),
        .S3_BVALID(S3_BVALID),
        .S3_BREADY(S3_BREADY),
        .S3_ARADDR(S3_ARADDR),
        .S3_ARLEN(S3_ARLEN),
        .S3_ARSIZE(S3_ARSIZE),
        .S3_ARBURST(S3_ARBURST),
        .S3_ARVALID(S3_ARVALID),
        .S3_ARREADY(S3_ARREADY),
        .S3_RDATA(S3_RDATA),
        .S3_RRESP(S3_RRESP),
        .S3_RLAST(S3_RLAST),
        .S3_RVALID(S3_RVALID),
        .S3_RREADY(S3_RREADY)
    );

    //==============================================================================
    // Simple AXI Slave Models
    //==============================================================================

    // Slave 0: Simple RAM Model
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

    // Slave 1: Simple GPIO Model
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

    // Slave 2: Simple UART Model
    axi_simple_slave_model #(
        .ADDR_BASE(32'h80000000),
        .ADDR_MASK(32'hE0000000)
    ) slave2 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .AWADDR(S2_AWADDR),
        .AWLEN(S2_AWLEN),
        .AWSIZE(S2_AWSIZE),
        .AWBURST(S2_AWBURST),
        .AWVALID(S2_AWVALID),
        .AWREADY(S2_AWREADY),
        .WDATA(S2_WDATA),
        .WSTRB(S2_WSTRB),
        .WLAST(S2_WLAST),
        .WVALID(S2_WVALID),
        .WREADY(S2_WREADY),
        .BRESP(S2_BRESP),
        .BVALID(S2_BVALID),
        .BREADY(S2_BREADY),
        .ARADDR(S2_ARADDR),
        .ARLEN(S2_ARLEN),
        .ARSIZE(S2_ARSIZE),
        .ARBURST(S2_ARBURST),
        .ARVALID(S2_ARVALID),
        .ARREADY(S2_ARREADY),
        .RDATA(S2_RDATA),
        .RRESP(S2_RRESP),
        .RLAST(S2_RLAST),
        .RVALID(S2_RVALID),
        .RREADY(S2_RREADY)
    );

    // Slave 3: Simple SPI Model
    axi_simple_slave_model #(
        .ADDR_BASE(32'hC0000000),
        .ADDR_MASK(32'hE0000000)
    ) slave3 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .AWADDR(S3_AWADDR),
        .AWLEN(S3_AWLEN),
        .AWSIZE(S3_AWSIZE),
        .AWBURST(S3_AWBURST),
        .AWVALID(S3_AWVALID),
        .AWREADY(S3_AWREADY),
        .WDATA(S3_WDATA),
        .WSTRB(S3_WSTRB),
        .WLAST(S3_WLAST),
        .WVALID(S3_WVALID),
        .WREADY(S3_WREADY),
        .BRESP(S3_BRESP),
        .BVALID(S3_BVALID),
        .BREADY(S3_BREADY),
        .ARADDR(S3_ARADDR),
        .ARLEN(S3_ARLEN),
        .ARSIZE(S3_ARSIZE),
        .ARBURST(S3_ARBURST),
        .ARVALID(S3_ARVALID),
        .ARREADY(S3_ARREADY),
        .RDATA(S3_RDATA),
        .RRESP(S3_RRESP),
        .RLAST(S3_RLAST),
        .RVALID(S3_RVALID),
        .RREADY(S3_RREADY)
    );

    //==============================================================================
    // AXI Master BFM Tasks
    //==============================================================================

    // Master 0 Write Task - Fixed to avoid deadlock
    task master0_write(input logic [31:0] addr, input logic [31:0] data);
        // Wait for clock edge
        @(posedge ACLK);
        
        // Setup Write Address Channel
        M0_AWADDR <= addr;
        M0_AWLEN <= 8'h0;  // Single transfer
        M0_AWSIZE <= 3'h2; // 4 bytes
        M0_AWBURST <= 2'h1; // INCR
        M0_AWVALID <= 1'b1;
        
        // Wait for AWREADY
        do @(posedge ACLK); while (!M0_AWREADY);
        M0_AWVALID <= 1'b0;
        
        // Setup Write Data Channel
        M0_WDATA <= data;
        M0_WSTRB <= 4'hF;
        M0_WLAST <= 1'b1;
        M0_WVALID <= 1'b1;
        
        // Wait for WREADY
        do @(posedge ACLK); while (!M0_WREADY);
        M0_WVALID <= 1'b0;
        M0_WLAST <= 1'b0;
        
        // Wait for Write Response
        M0_BREADY <= 1'b1;
        do @(posedge ACLK); while (!M0_BVALID);
        M0_BREADY <= 1'b0;
        
        // Wait a cycle
        @(posedge ACLK);
    endtask

    // Master 0 Read Task - Fixed to avoid deadlock
    task master0_read(input logic [31:0] addr, output logic [31:0] data);
        // Wait for clock edge
        @(posedge ACLK);
        
        // Setup Read Address Channel
        M0_ARADDR <= addr;
        M0_ARLEN <= 8'h0;  // Single transfer
        M0_ARSIZE <= 3'h2; // 4 bytes
        M0_ARBURST <= 2'h1; // INCR
        M0_ARVALID <= 1'b1;
        
        // Wait for ARREADY
        do @(posedge ACLK); while (!M0_ARREADY);
        M0_ARVALID <= 1'b0;
        
        // Wait for Read Data
        M0_RREADY <= 1'b1;
        do @(posedge ACLK); while (!M0_RVALID);
        data = M0_RDATA;
        M0_RREADY <= 1'b0;
        
        // Wait a cycle
        @(posedge ACLK);
    endtask

    // Master 1 Write Task - Fixed to avoid deadlock
    task master1_write(input logic [31:0] addr, input logic [31:0] data);
        // Wait for clock edge
        @(posedge ACLK);
        
        // Setup Write Address Channel
        M1_AWADDR <= addr;
        M1_AWLEN <= 8'h0;
        M1_AWSIZE <= 3'h2;
        M1_AWBURST <= 2'h1;
        M1_AWVALID <= 1'b1;
        
        // Wait for AWREADY
        do @(posedge ACLK); while (!M1_AWREADY);
        M1_AWVALID <= 1'b0;
        
        // Setup Write Data Channel
        M1_WDATA <= data;
        M1_WSTRB <= 4'hF;
        M1_WLAST <= 1'b1;
        M1_WVALID <= 1'b1;
        
        // Wait for WREADY
        do @(posedge ACLK); while (!M1_WREADY);
        M1_WVALID <= 1'b0;
        M1_WLAST <= 1'b0;
        
        // Wait for Write Response
        M1_BREADY <= 1'b1;
        do @(posedge ACLK); while (!M1_BVALID);
        M1_BREADY <= 1'b0;
        
        // Wait a cycle
        @(posedge ACLK);
    endtask

    // Master 1 Read Task - Fixed to avoid deadlock
    task master1_read(input logic [31:0] addr, output logic [31:0] data);
        // Wait for clock edge
        @(posedge ACLK);
        
        // Setup Read Address Channel
        M1_ARADDR <= addr;
        M1_ARLEN <= 8'h0;
        M1_ARSIZE <= 3'h2;
        M1_ARBURST <= 2'h1;
        M1_ARVALID <= 1'b1;
        
        // Wait for ARREADY
        do @(posedge ACLK); while (!M1_ARREADY);
        M1_ARVALID <= 1'b0;
        
        // Wait for Read Data
        M1_RREADY <= 1'b1;
        do @(posedge ACLK); while (!M1_RVALID);
        data = M1_RDATA;
        M1_RREADY <= 1'b0;
        
        // Wait a cycle
        @(posedge ACLK);
    endtask

    //==============================================================================
    // Test Sequence
    //==============================================================================
    initial begin
        $display("============================================================================");
        $display("AXI_Interconnect Testbench - SystemVerilog");
        $display("Configuration: 2 Masters × 4 Slaves");
        $display("Arbitration Mode: %0d (0=FIXED, 1=ROUND_ROBIN, 2=QOS)", ARBITRATION_MODE);
        $display("============================================================================");
        $display("");

        // Initialize signals
        M0_AWADDR <= 32'h0;
        M0_AWLEN <= 8'h0;
        M0_AWSIZE <= 3'h0;
        M0_AWBURST <= 2'h0;
        M0_AWVALID <= 1'b0;
        M0_WDATA <= 32'h0;
        M0_WSTRB <= 4'h0;
        M0_WLAST <= 1'b0;
        M0_WVALID <= 1'b0;
        M0_BREADY <= 1'b0;
        M0_ARADDR <= 32'h0;
        M0_ARLEN <= 8'h0;
        M0_ARSIZE <= 3'h0;
        M0_ARBURST <= 2'h0;
        M0_ARVALID <= 1'b0;
        M0_RREADY <= 1'b0;

        M1_AWADDR <= 32'h0;
        M1_AWLEN <= 8'h0;
        M1_AWSIZE <= 3'h0;
        M1_AWBURST <= 2'h0;
        M1_AWVALID <= 1'b0;
        M1_WDATA <= 32'h0;
        M1_WSTRB <= 4'h0;
        M1_WLAST <= 1'b0;
        M1_WVALID <= 1'b0;
        M1_BREADY <= 1'b0;
        M1_ARADDR <= 32'h0;
        M1_ARLEN <= 8'h0;
        M1_ARSIZE <= 3'h0;
        M1_ARBURST <= 2'h0;
        M1_ARVALID <= 1'b0;
        M1_RREADY <= 1'b0;

        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        ARESETN = 0;
        #(CLK_PERIOD * 5);
        ARESETN = 1;
        #(CLK_PERIOD * 2);
        $display("[%0t] Reset released", $time);
        $display("");

        // Test 1: Master 0 Write to Slave 0 (RAM)
        $display("[%0t] Test 1: Master 0 Write to Slave 0 (RAM @ 0x00000000)", $time);
        master0_write(32'h00000000, 32'hDEADBEEF);
        #(CLK_PERIOD * 2);
        $display("[%0t] [PASS] Write transaction completed", $time);
        $display("");

        // Test 2: Master 0 Read from Slave 0
        $display("[%0t] Test 2: Master 0 Read from Slave 0 (RAM @ 0x00000000)", $time);
        begin
            logic [31:0] read_data;
            master0_read(32'h00000000, read_data);
            $display("[%0t] Read data: 0x%08h", $time, read_data);
            if (read_data == 32'hDEADBEEF) begin
                $display("[%0t] [PASS] Read data matches written data", $time);
            end else begin
                $display("[%0t] [FAIL] Read data mismatch! Expected: 0xDEADBEEF, Got: 0x%08h", $time, read_data);
            end
        end
        $display("");

        // Test 3: Master 1 Write to Slave 1 (GPIO)
        $display("[%0t] Test 3: Master 1 Write to Slave 1 (GPIO @ 0x40000000)", $time);
        master1_write(32'h40000000, 32'h12345678);
        #(CLK_PERIOD * 2);
        $display("[%0t] [PASS] Write transaction completed", $time);
        $display("");

        // Test 4: Master 1 Read from Slave 1
        $display("[%0t] Test 4: Master 1 Read from Slave 1 (GPIO @ 0x40000000)", $time);
        begin
            logic [31:0] read_data;
            master1_read(32'h40000000, read_data);
            $display("[%0t] Read data: 0x%08h", $time, read_data);
            if (read_data == 32'h12345678) begin
                $display("[%0t] [PASS] Read data matches written data", $time);
            end else begin
                $display("[%0t] [FAIL] Read data mismatch! Expected: 0x12345678, Got: 0x%08h", $time, read_data);
            end
        end
        $display("");

        // Test 5: Master 0 Write to Slave 2 (UART)
        $display("[%0t] Test 5: Master 0 Write to Slave 2 (UART @ 0x80000000)", $time);
        master0_write(32'h80000000, 32'hABCDEF00);
        #(CLK_PERIOD * 2);
        $display("[%0t] [PASS] Write transaction completed", $time);
        $display("");

        // Test 6: Master 1 Write to Slave 3 (SPI)
        $display("[%0t] Test 6: Master 1 Write to Slave 3 (SPI @ 0xC0000000)", $time);
        master1_write(32'hC0000000, 32'hFEDCBA98);
        #(CLK_PERIOD * 2);
        $display("[%0t] [PASS] Write transaction completed", $time);
        $display("");

        // Test 7: Concurrent transactions (both masters)
        $display("[%0t] Test 7: Concurrent transactions from both masters", $time);
        fork
            begin
                master0_write(32'h00000004, 32'h11111111);
                $display("[%0t] Master 0: Write completed", $time);
            end
            begin
                #(CLK_PERIOD * 2);
                master1_write(32'h40000004, 32'h22222222);
                $display("[%0t] Master 1: Write completed", $time);
            end
        join
        $display("[%0t] [PASS] Concurrent transactions completed", $time);
        $display("");

        #(CLK_PERIOD * 10);
        $display("============================================================================");
        $display("Test Complete!");
        $display("============================================================================");
        $finish;
    end

endmodule

//==============================================================================
// Simple AXI Slave Model
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


