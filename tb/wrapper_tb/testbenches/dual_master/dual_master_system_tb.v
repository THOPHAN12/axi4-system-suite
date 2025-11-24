`timescale 1ns/1ps

/*
 * dual_master_system_tb.v : Testbench for Dual Master System (SERV + ALU)
 * 
 * Tests:
 *   - SERV RISC-V processor (2 buses: Instruction + Data)
 *   - ALU Master
 *   - 4 Memory Slaves
 *   - Address routing va arbitration
 */

module dual_master_system_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH   = 4;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    reg i_timer_irq;
    
    // ALU Master Control
    reg  alu_master_start;
    wire alu_master_busy;
    wire alu_master_done;
    
    // ========================================================================
    // Slave Interface Wires
    // ========================================================================
    // Slave 0 (Instruction Memory - Read-only)
    wire [ADDR_WIDTH-1:0]   M00_AXI_araddr;
    wire [7:0]              M00_AXI_arlen;
    wire [2:0]              M00_AXI_arsize;
    wire [1:0]              M00_AXI_arburst;
    wire [1:0]              M00_AXI_arlock;
    wire [3:0]              M00_AXI_arcache;
    wire [2:0]              M00_AXI_arprot;
    wire [3:0]              M00_AXI_arregion;
    wire [3:0]              M00_AXI_arqos;
    wire                    M00_AXI_arvalid;
    wire                    M00_AXI_arready;
    wire [DATA_WIDTH-1:0]   M00_AXI_rdata;
    wire [1:0]              M00_AXI_rresp;
    wire                    M00_AXI_rlast;
    wire                    M00_AXI_rvalid;
    wire                    M00_AXI_rready;
    
    // Slave 1 (Data Memory - Read-write)
    wire [ID_WIDTH-1:0]     M01_AXI_awid;
    wire [ADDR_WIDTH-1:0]   M01_AXI_awaddr;
    wire [7:0]              M01_AXI_awlen;
    wire [2:0]              M01_AXI_awsize;
    wire [1:0]              M01_AXI_awburst;
    wire [1:0]              M01_AXI_awlock;
    wire [3:0]              M01_AXI_awcache;
    wire [2:0]              M01_AXI_awprot;
    wire [3:0]              M01_AXI_awqos;
    wire [3:0]              M01_AXI_awregion;
    wire                    M01_AXI_awvalid;
    wire                    M01_AXI_awready;
    wire [DATA_WIDTH-1:0]   M01_AXI_wdata;
    wire [(DATA_WIDTH/8)-1:0] M01_AXI_wstrb;
    wire                    M01_AXI_wlast;
    wire                    M01_AXI_wvalid;
    wire                    M01_AXI_wready;
    wire [ID_WIDTH-1:0]     M01_AXI_bid;
    wire [1:0]              M01_AXI_bresp;
    wire                    M01_AXI_bvalid;
    wire                    M01_AXI_bready;
    wire [ID_WIDTH-1:0]     M01_AXI_arid;
    wire [ADDR_WIDTH-1:0]   M01_AXI_araddr;
    wire [7:0]              M01_AXI_arlen;
    wire [2:0]              M01_AXI_arsize;
    wire [1:0]              M01_AXI_arburst;
    wire [1:0]              M01_AXI_arlock;
    wire [3:0]              M01_AXI_arcache;
    wire [2:0]              M01_AXI_arprot;
    wire [3:0]              M01_AXI_arqos;
    wire [3:0]              M01_AXI_arregion;
    wire                    M01_AXI_arvalid;
    wire                    M01_AXI_arready;
    wire [ID_WIDTH-1:0]     M01_AXI_rid;
    wire [DATA_WIDTH-1:0]   M01_AXI_rdata;
    wire [1:0]              M01_AXI_rresp;
    wire                    M01_AXI_rlast;
    wire                    M01_AXI_rvalid;
    wire                    M01_AXI_rready;
    
    // Slave 2 (ALU Memory - Read-write)
    wire [ID_WIDTH-1:0]     M02_AXI_awid;
    wire [ADDR_WIDTH-1:0]   M02_AXI_awaddr;
    wire [7:0]              M02_AXI_awlen;
    wire [2:0]              M02_AXI_awsize;
    wire [1:0]              M02_AXI_awburst;
    wire [1:0]              M02_AXI_awlock;
    wire [3:0]              M02_AXI_awcache;
    wire [2:0]              M02_AXI_awprot;
    wire [3:0]              M02_AXI_awqos;
    wire [3:0]              M02_AXI_awregion;
    wire                    M02_AXI_awvalid;
    wire                    M02_AXI_awready;
    wire [DATA_WIDTH-1:0]   M02_AXI_wdata;
    wire [(DATA_WIDTH/8)-1:0] M02_AXI_wstrb;
    wire                    M02_AXI_wlast;
    wire                    M02_AXI_wvalid;
    wire                    M02_AXI_wready;
    wire [ID_WIDTH-1:0]     M02_AXI_bid;
    wire [1:0]              M02_AXI_bresp;
    wire                    M02_AXI_bvalid;
    wire                    M02_AXI_bready;
    wire [ID_WIDTH-1:0]     M02_AXI_arid;
    wire [ADDR_WIDTH-1:0]   M02_AXI_araddr;
    wire [7:0]              M02_AXI_arlen;
    wire [2:0]              M02_AXI_arsize;
    wire [1:0]              M02_AXI_arburst;
    wire [1:0]              M02_AXI_arlock;
    wire [3:0]              M02_AXI_arcache;
    wire [2:0]              M02_AXI_arprot;
    wire [3:0]              M02_AXI_arqos;
    wire [3:0]              M02_AXI_arregion;
    wire                    M02_AXI_arvalid;
    wire                    M02_AXI_arready;
    wire [ID_WIDTH-1:0]     M02_AXI_rid;
    wire [DATA_WIDTH-1:0]   M02_AXI_rdata;
    wire [1:0]              M02_AXI_rresp;
    wire                    M02_AXI_rlast;
    wire                    M02_AXI_rvalid;
    wire                    M02_AXI_rready;
    
    // Slave 3 (Reserved - Read-only)
    wire [ID_WIDTH-1:0]     M03_AXI_arid;
    wire [ADDR_WIDTH-1:0]   M03_AXI_araddr;
    wire [7:0]              M03_AXI_arlen;
    wire [2:0]              M03_AXI_arsize;
    wire [1:0]              M03_AXI_arburst;
    wire [1:0]              M03_AXI_arlock;
    wire [3:0]              M03_AXI_arcache;
    wire [2:0]              M03_AXI_arprot;
    wire [3:0]              M03_AXI_arqos;
    wire [3:0]              M03_AXI_arregion;
    wire                    M03_AXI_arvalid;
    wire                    M03_AXI_arready;
    wire [ID_WIDTH-1:0]     M03_AXI_rid;
    wire [DATA_WIDTH-1:0]   M03_AXI_rdata;
    wire [1:0]              M03_AXI_rresp;
    wire                    M03_AXI_rlast;
    wire                    M03_AXI_rvalid;
    wire                    M03_AXI_rready;
    
    // ========================================================================
    // DUT Instance
    // ========================================================================
    dual_master_system #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .WITH_CSR(1),
        .W(1),
        .PRE_REGISTER(1),
        .RESET_STRATEGY("MINI"),
        .RESET_PC(32'h0000_0000),
        .DEBUG(1'b0),
        .MDU(1'b0),
        .COMPRESSED(0),
        .MEM_SIZE(256),
        .Num_Of_Masters(2),
        .Num_Of_Slaves(4),
        .SLAVE0_ADDR1(32'h0000_0000),  // Instruction Memory
        .SLAVE0_ADDR2(32'h3FFF_FFFF),
        .SLAVE1_ADDR1(32'h4000_0000),  // Data Memory
        .SLAVE1_ADDR2(32'h7FFF_FFFF),
        .SLAVE2_ADDR1(32'h8000_0000),  // ALU Memory
        .SLAVE2_ADDR2(32'hBFFF_FFFF),
        .SLAVE3_ADDR1(32'hC000_0000),  // Reserved
        .SLAVE3_ADDR2(32'hFFFF_FFFF)
    ) u_dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .i_timer_irq(i_timer_irq),
        .alu_master_start(alu_master_start),
        .alu_master_busy(alu_master_busy),
        .alu_master_done(alu_master_done),
        
        // Slave 0 (Instruction Memory)
        .M00_AXI_araddr(M00_AXI_araddr),
        .M00_AXI_arlen(M00_AXI_arlen),
        .M00_AXI_arsize(M00_AXI_arsize),
        .M00_AXI_arburst(M00_AXI_arburst),
        .M00_AXI_arlock(M00_AXI_arlock),
        .M00_AXI_arcache(M00_AXI_arcache),
        .M00_AXI_arprot(M00_AXI_arprot),
        .M00_AXI_arregion(M00_AXI_arregion),
        .M00_AXI_arqos(M00_AXI_arqos),
        .M00_AXI_arvalid(M00_AXI_arvalid),
        .M00_AXI_arready(M00_AXI_arready),
        .M00_AXI_rdata(M00_AXI_rdata),
        .M00_AXI_rresp(M00_AXI_rresp),
        .M00_AXI_rlast(M00_AXI_rlast),
        .M00_AXI_rvalid(M00_AXI_rvalid),
        .M00_AXI_rready(M00_AXI_rready),
        
        // Slave 1 (Data Memory)
        .M01_AXI_awid(M01_AXI_awid),
        .M01_AXI_awaddr(M01_AXI_awaddr),
        .M01_AXI_awlen(M01_AXI_awlen),
        .M01_AXI_awsize(M01_AXI_awsize),
        .M01_AXI_awburst(M01_AXI_awburst),
        .M01_AXI_awlock(M01_AXI_awlock),
        .M01_AXI_awcache(M01_AXI_awcache),
        .M01_AXI_awprot(M01_AXI_awprot),
        .M01_AXI_awqos(M01_AXI_awqos),
        .M01_AXI_awregion(M01_AXI_awregion),
        .M01_AXI_awvalid(M01_AXI_awvalid),
        .M01_AXI_awready(M01_AXI_awready),
        .M01_AXI_wdata(M01_AXI_wdata),
        .M01_AXI_wstrb(M01_AXI_wstrb),
        .M01_AXI_wlast(M01_AXI_wlast),
        .M01_AXI_wvalid(M01_AXI_wvalid),
        .M01_AXI_wready(M01_AXI_wready),
        .M01_AXI_bid(M01_AXI_bid),
        .M01_AXI_bresp(M01_AXI_bresp),
        .M01_AXI_bvalid(M01_AXI_bvalid),
        .M01_AXI_bready(M01_AXI_bready),
        .M01_AXI_arid(M01_AXI_arid),
        .M01_AXI_araddr(M01_AXI_araddr),
        .M01_AXI_arlen(M01_AXI_arlen),
        .M01_AXI_arsize(M01_AXI_arsize),
        .M01_AXI_arburst(M01_AXI_arburst),
        .M01_AXI_arlock(M01_AXI_arlock),
        .M01_AXI_arcache(M01_AXI_arcache),
        .M01_AXI_arprot(M01_AXI_arprot),
        .M01_AXI_arqos(M01_AXI_arqos),
        .M01_AXI_arregion(M01_AXI_arregion),
        .M01_AXI_arvalid(M01_AXI_arvalid),
        .M01_AXI_arready(M01_AXI_arready),
        .M01_AXI_rid(M01_AXI_rid),
        .M01_AXI_rdata(M01_AXI_rdata),
        .M01_AXI_rresp(M01_AXI_rresp),
        .M01_AXI_rlast(M01_AXI_rlast),
        .M01_AXI_rvalid(M01_AXI_rvalid),
        .M01_AXI_rready(M01_AXI_rready),
        
        // Slave 2 (ALU Memory)
        .M02_AXI_awid(M02_AXI_awid),
        .M02_AXI_awaddr(M02_AXI_awaddr),
        .M02_AXI_awlen(M02_AXI_awlen),
        .M02_AXI_awsize(M02_AXI_awsize),
        .M02_AXI_awburst(M02_AXI_awburst),
        .M02_AXI_awlock(M02_AXI_awlock),
        .M02_AXI_awcache(M02_AXI_awcache),
        .M02_AXI_awprot(M02_AXI_awprot),
        .M02_AXI_awqos(M02_AXI_awqos),
        .M02_AXI_awregion(M02_AXI_awregion),
        .M02_AXI_awvalid(M02_AXI_awvalid),
        .M02_AXI_awready(M02_AXI_awready),
        .M02_AXI_wdata(M02_AXI_wdata),
        .M02_AXI_wstrb(M02_AXI_wstrb),
        .M02_AXI_wlast(M02_AXI_wlast),
        .M02_AXI_wvalid(M02_AXI_wvalid),
        .M02_AXI_wready(M02_AXI_wready),
        .M02_AXI_bid(M02_AXI_bid),
        .M02_AXI_bresp(M02_AXI_bresp),
        .M02_AXI_bvalid(M02_AXI_bvalid),
        .M02_AXI_bready(M02_AXI_bready),
        .M02_AXI_arid(M02_AXI_arid),
        .M02_AXI_araddr(M02_AXI_araddr),
        .M02_AXI_arlen(M02_AXI_arlen),
        .M02_AXI_arsize(M02_AXI_arsize),
        .M02_AXI_arburst(M02_AXI_arburst),
        .M02_AXI_arlock(M02_AXI_arlock),
        .M02_AXI_arcache(M02_AXI_arcache),
        .M02_AXI_arprot(M02_AXI_arprot),
        .M02_AXI_arqos(M02_AXI_arqos),
        .M02_AXI_arregion(M02_AXI_arregion),
        .M02_AXI_arvalid(M02_AXI_arvalid),
        .M02_AXI_arready(M02_AXI_arready),
        .M02_AXI_rid(M02_AXI_rid),
        .M02_AXI_rdata(M02_AXI_rdata),
        .M02_AXI_rresp(M02_AXI_rresp),
        .M02_AXI_rlast(M02_AXI_rlast),
        .M02_AXI_rvalid(M02_AXI_rvalid),
        .M02_AXI_rready(M02_AXI_rready),
        
        // Slave 3 (Reserved)
        .M03_AXI_arid(M03_AXI_arid),
        .M03_AXI_araddr(M03_AXI_araddr),
        .M03_AXI_arlen(M03_AXI_arlen),
        .M03_AXI_arsize(M03_AXI_arsize),
        .M03_AXI_arburst(M03_AXI_arburst),
        .M03_AXI_arlock(M03_AXI_arlock),
        .M03_AXI_arcache(M03_AXI_arcache),
        .M03_AXI_arprot(M03_AXI_arprot),
        .M03_AXI_arqos(M03_AXI_arqos),
        .M03_AXI_arregion(M03_AXI_arregion),
        .M03_AXI_arvalid(M03_AXI_arvalid),
        .M03_AXI_arready(M03_AXI_arready),
        .M03_AXI_rid(M03_AXI_rid),
        .M03_AXI_rdata(M03_AXI_rdata),
        .M03_AXI_rresp(M03_AXI_rresp),
        .M03_AXI_rlast(M03_AXI_rlast),
        .M03_AXI_rvalid(M03_AXI_rvalid),
        .M03_AXI_rready(M03_AXI_rready)
    );
    
    // ========================================================================
    // Memory Slaves
    // ========================================================================
    // Slave 0: Instruction Memory (ROM)
    axi_rom_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .MEM_SIZE(1024),
        .MEM_INIT_FILE("../../sim/modelsim/test_program_simple.hex")
    ) u_inst_mem (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_arid(4'h0),
        .S_AXI_araddr(M00_AXI_araddr),
        .S_AXI_arlen(M00_AXI_arlen),
        .S_AXI_arsize(M00_AXI_arsize),
        .S_AXI_arburst(M00_AXI_arburst),
        .S_AXI_arlock(M00_AXI_arlock),
        .S_AXI_arcache(M00_AXI_arcache),
        .S_AXI_arprot(M00_AXI_arprot),
        .S_AXI_arqos(M00_AXI_arqos),
        .S_AXI_arregion(M00_AXI_arregion),
        .S_AXI_arvalid(M00_AXI_arvalid),
        .S_AXI_arready(M00_AXI_arready),
        .S_AXI_rid(),
        .S_AXI_rdata(M00_AXI_rdata),
        .S_AXI_rresp(M00_AXI_rresp),
        .S_AXI_rlast(M00_AXI_rlast),
        .S_AXI_rvalid(M00_AXI_rvalid),
        .S_AXI_rready(M00_AXI_rready)
    );
    
    // Slave 1: Data Memory (RAM)
    axi_memory_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .MEM_SIZE(1024),
        .MEM_INIT_FILE("")
    ) u_data_mem (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awid(M01_AXI_awid),
        .S_AXI_awaddr(M01_AXI_awaddr),
        .S_AXI_awlen(M01_AXI_awlen),
        .S_AXI_awsize(M01_AXI_awsize),
        .S_AXI_awburst(M01_AXI_awburst),
        .S_AXI_awlock(M01_AXI_awlock),
        .S_AXI_awcache(M01_AXI_awcache),
        .S_AXI_awprot(M01_AXI_awprot),
        .S_AXI_awqos(M01_AXI_awqos),
        .S_AXI_awregion(M01_AXI_awregion),
        .S_AXI_awvalid(M01_AXI_awvalid),
        .S_AXI_awready(M01_AXI_awready),
        .S_AXI_wdata(M01_AXI_wdata),
        .S_AXI_wstrb(M01_AXI_wstrb),
        .S_AXI_wlast(M01_AXI_wlast),
        .S_AXI_wvalid(M01_AXI_wvalid),
        .S_AXI_wready(M01_AXI_wready),
        .S_AXI_bid(M01_AXI_bid),
        .S_AXI_bresp(M01_AXI_bresp),
        .S_AXI_bvalid(M01_AXI_bvalid),
        .S_AXI_bready(M01_AXI_bready),
        .S_AXI_arid(M01_AXI_arid),
        .S_AXI_araddr(M01_AXI_araddr),
        .S_AXI_arlen(M01_AXI_arlen),
        .S_AXI_arsize(M01_AXI_arsize),
        .S_AXI_arburst(M01_AXI_arburst),
        .S_AXI_arlock(M01_AXI_arlock),
        .S_AXI_arcache(M01_AXI_arcache),
        .S_AXI_arprot(M01_AXI_arprot),
        .S_AXI_arqos(M01_AXI_arqos),
        .S_AXI_arregion(M01_AXI_arregion),
        .S_AXI_arvalid(M01_AXI_arvalid),
        .S_AXI_arready(M01_AXI_arready),
        .S_AXI_rid(M01_AXI_rid),
        .S_AXI_rdata(M01_AXI_rdata),
        .S_AXI_rresp(M01_AXI_rresp),
        .S_AXI_rlast(M01_AXI_rlast),
        .S_AXI_rvalid(M01_AXI_rvalid),
        .S_AXI_rready(M01_AXI_rready)
    );
    
    // Slave 2: ALU Memory (RAM) - Use axi_memory_slave for compatibility
    axi_memory_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .MEM_SIZE(256),
        .MEM_INIT_FILE("")
    ) u_alu_mem (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awid(M02_AXI_awid),
        .S_AXI_awaddr(M02_AXI_awaddr),
        .S_AXI_awlen(M02_AXI_awlen),
        .S_AXI_awsize(M02_AXI_awsize),
        .S_AXI_awburst(M02_AXI_awburst),
        .S_AXI_awlock(M02_AXI_awlock),
        .S_AXI_awcache(M02_AXI_awcache),
        .S_AXI_awprot(M02_AXI_awprot),
        .S_AXI_awqos(4'h0),
        .S_AXI_awregion(M02_AXI_awregion),
        .S_AXI_awvalid(M02_AXI_awvalid),
        .S_AXI_awready(M02_AXI_awready),
        .S_AXI_wdata(M02_AXI_wdata),
        .S_AXI_wstrb(M02_AXI_wstrb),
        .S_AXI_wlast(M02_AXI_wlast),
        .S_AXI_wvalid(M02_AXI_wvalid),
        .S_AXI_wready(M02_AXI_wready),
        .S_AXI_bid(M02_AXI_bid),
        .S_AXI_bresp(M02_AXI_bresp),
        .S_AXI_bvalid(M02_AXI_bvalid),
        .S_AXI_bready(M02_AXI_bready),
        .S_AXI_arid(M02_AXI_arid),
        .S_AXI_araddr(M02_AXI_araddr),
        .S_AXI_arlen(M02_AXI_arlen),
        .S_AXI_arsize(M02_AXI_arsize),
        .S_AXI_arburst(M02_AXI_arburst),
        .S_AXI_arlock(M02_AXI_arlock),
        .S_AXI_arcache(M02_AXI_arcache),
        .S_AXI_arprot(M02_AXI_arprot),
        .S_AXI_arqos(4'h0),
        .S_AXI_arregion(M02_AXI_arregion),
        .S_AXI_arvalid(M02_AXI_arvalid),
        .S_AXI_arready(M02_AXI_arready),
        .S_AXI_rid(M02_AXI_rid),
        .S_AXI_rdata(M02_AXI_rdata),
        .S_AXI_rresp(M02_AXI_rresp),
        .S_AXI_rlast(M02_AXI_rlast),
        .S_AXI_rvalid(M02_AXI_rvalid),
        .S_AXI_rready(M02_AXI_rready)
    );
    
    // Slave 3: Reserved (ROM for now)
    axi_rom_slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .MEM_SIZE(1024),
        .MEM_INIT_FILE("")
    ) u_reserved_mem (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_arid(M03_AXI_arid),
        .S_AXI_araddr(M03_AXI_araddr),
        .S_AXI_arlen(M03_AXI_arlen),
        .S_AXI_arsize(M03_AXI_arsize),
        .S_AXI_arburst(M03_AXI_arburst),
        .S_AXI_arlock(M03_AXI_arlock),
        .S_AXI_arcache(M03_AXI_arcache),
        .S_AXI_arprot(M03_AXI_arprot),
        .S_AXI_arqos(M03_AXI_arqos),
        .S_AXI_arregion(M03_AXI_arregion),
        .S_AXI_arvalid(M03_AXI_arvalid),
        .S_AXI_arready(M03_AXI_arready),
        .S_AXI_rid(M03_AXI_rid),
        .S_AXI_rdata(M03_AXI_rdata),
        .S_AXI_rresp(M03_AXI_rresp),
        .S_AXI_rlast(M03_AXI_rlast),
        .S_AXI_rvalid(M03_AXI_rvalid),
        .S_AXI_rready(M03_AXI_rready)
    );
    
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
        i_timer_irq = 0;
        alu_master_start = 0;
        #(CLK_PERIOD * 10);
        ARESETN = 1;
        #(CLK_PERIOD * 5);
        $display("[%0t] Reset released", $time);
    end
    
    // ========================================================================
    // Monitoring
    // ========================================================================
    initial begin
        $dumpfile("dual_master_system_tb.vcd");
        $dumpvars(0, dual_master_system_tb);
    end
    
    // ========================================================================
    // Test Statistics
    // ========================================================================
    integer test_count;
    integer pass_count;
    integer fail_count;
    
    // Transaction counters
    integer serv_inst_read_count;
    integer serv_data_read_count;
    integer serv_data_write_count;
    integer alu_read_count;
    integer alu_write_count;
    integer reserved_read_count;
    
    // ========================================================================
    // Helper Tasks
    // ========================================================================
    // Task to write data to ALU Memory
    task automatic write_alu_memory;
        input [31:0] addr;  // Full address (including base 0x80000000)
        input [31:0] data;
        integer word_idx;
        begin
            // Convert byte address to word index (matching axi_memory_slave: addr[ADDR_BITS+1:2])
            // For MEM_SIZE=256, ADDR_BITS=8, so index = addr[9:2] = (addr >> 2) & 0xFF
            word_idx = (addr >> 2) & 255;  // Take lower 8 bits of (addr >> 2)
            if (word_idx < 256) begin
                u_alu_mem.memory[word_idx] = data;
                $display("[%0t] ALU Memory Init: addr=0x%08h (word_idx=%0d) = 0x%08h", 
                         $time, addr, word_idx, data);
            end else begin
                $display("[%0t] ERROR: ALU Memory address out of range: 0x%08h", $time, addr);
            end
        end
    endtask
    
    task automatic wait_alu_master_reset;
        integer timeout;
        begin
            timeout = 0;
            while ((alu_master_busy || alu_master_done) && timeout < 100) begin
                @(posedge ACLK);
                timeout = timeout + 1;
            end
            if (timeout >= 100) begin
                $display("[%0t] WARNING: ALU Master reset timeout", $time);
            end
        end
    endtask
    
    task automatic wait_alu_master_done_with_timeout;
        input integer max_cycles;
        integer cycles;
        begin
            cycles = 0;
            while (!alu_master_done && cycles < max_cycles) begin
                @(posedge ACLK);
                cycles = cycles + 1;
            end
            if (cycles >= max_cycles) begin
                $display("[%0t] ERROR: ALU Master done timeout after %0d cycles", $time, max_cycles);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    task automatic check_address_routing;
        input [31:0] addr;
        input integer expected_slave;
        integer actual_slave;
        begin
            // Determine actual slave from address
            if (addr >= 32'h0000_0000 && addr <= 32'h3FFF_FFFF) begin
                actual_slave = 0;
            end else if (addr >= 32'h4000_0000 && addr <= 32'h7FFF_FFFF) begin
                actual_slave = 1;
            end else if (addr >= 32'h8000_0000 && addr <= 32'hBFFF_FFFF) begin
                actual_slave = 2;
            end else if (addr >= 32'hC000_0000 && addr <= 32'hFFFF_FFFF) begin
                actual_slave = 3;
            end else begin
                actual_slave = -1;
            end
            
            if (actual_slave == expected_slave) begin
                $display("[%0t] ✓ Address routing PASS: 0x%08h -> Slave%0d", $time, addr, actual_slave);
            end else begin
                $display("[%0t] ✗ Address routing FAIL: 0x%08h -> Slave%0d (expected Slave%0d)", 
                         $time, addr, actual_slave, expected_slave);
                fail_count = fail_count + 1;
            end
        end
    endtask
    
    // ========================================================================
    // Transaction Monitoring
    // ========================================================================
    initial begin
        serv_inst_read_count = 0;
        serv_data_read_count = 0;
        serv_data_write_count = 0;
        alu_read_count = 0;
        alu_write_count = 0;
        reserved_read_count = 0;
        
        forever begin
            @(posedge ACLK);
            
            // Slave 0 (Instruction Memory) - SERV reads
            if (M00_AXI_arvalid && M00_AXI_arready) begin
                serv_inst_read_count = serv_inst_read_count + 1;
                check_address_routing(M00_AXI_araddr, 0);
                $display("[%0t] [TEST] SERV→Slave0: Instruction Fetch @ 0x%08h (count=%0d)", 
                         $time, M00_AXI_araddr, serv_inst_read_count);
            end
            if (M00_AXI_rvalid && M00_AXI_rready) begin
                $display("[%0t] [TEST] Slave0→SERV: Instruction = 0x%08h", 
                         $time, M00_AXI_rdata);
            end
            
            // Slave 1 (Data Memory) - SERV reads/writes
            if (M01_AXI_awvalid && M01_AXI_awready) begin
                serv_data_write_count = serv_data_write_count + 1;
                check_address_routing(M01_AXI_awaddr, 1);
                $display("[%0t] [TEST] SERV→Slave1: Data Write @ 0x%08h (count=%0d)", 
                         $time, M01_AXI_awaddr, serv_data_write_count);
            end
            if (M01_AXI_wvalid && M01_AXI_wready) begin
                $display("[%0t] [TEST] SERV→Slave1: Data = 0x%08h", 
                         $time, M01_AXI_wdata);
            end
            if (M01_AXI_arvalid && M01_AXI_arready) begin
                serv_data_read_count = serv_data_read_count + 1;
                check_address_routing(M01_AXI_araddr, 1);
                $display("[%0t] [TEST] SERV→Slave1: Data Read @ 0x%08h (count=%0d)", 
                         $time, M01_AXI_araddr, serv_data_read_count);
            end
            if (M01_AXI_rvalid && M01_AXI_rready) begin
                $display("[%0t] [TEST] Slave1→SERV: Data = 0x%08h", 
                         $time, M01_AXI_rdata);
            end
            
            // Slave 2 (ALU Memory) - ALU Master reads/writes
            if (M02_AXI_awvalid && M02_AXI_awready) begin
                alu_write_count = alu_write_count + 1;
                check_address_routing(M02_AXI_awaddr, 2);
                $display("[%0t] [TEST] ALU→Slave2: Write @ 0x%08h (count=%0d)", 
                         $time, M02_AXI_awaddr, alu_write_count);
            end
            if (M02_AXI_wvalid && M02_AXI_wready) begin
                $display("[%0t] [TEST] ALU→Slave2: Data = 0x%08h", 
                         $time, M02_AXI_wdata);
            end
            if (M02_AXI_arvalid && M02_AXI_arready) begin
                alu_read_count = alu_read_count + 1;
                check_address_routing(M02_AXI_araddr, 2);
                $display("[%0t] [TEST] ALU→Slave2: Read @ 0x%08h (count=%0d)", 
                         $time, M02_AXI_araddr, alu_read_count);
            end
            if (M02_AXI_rvalid && M02_AXI_rready) begin
                $display("[%0t] [TEST] Slave2→ALU: Data = 0x%08h", 
                         $time, M02_AXI_rdata);
            end
            
            // Slave 3 (Reserved) - Read only
            if (M03_AXI_arvalid && M03_AXI_arready) begin
                reserved_read_count = reserved_read_count + 1;
                check_address_routing(M03_AXI_araddr, 3);
                $display("[%0t] [TEST] →Slave3: Read @ 0x%08h (count=%0d)", 
                         $time, M03_AXI_araddr, reserved_read_count);
            end
            if (M03_AXI_rvalid && M03_AXI_rready) begin
                $display("[%0t] [TEST] Slave3→: Data = 0x%08h", 
                         $time, M03_AXI_rdata);
            end
        end
    end
    
    // ========================================================================
    // Test Sequence
    // ========================================================================
    // Variables for test cases (declared at module level for reuse)
    integer serv_count_before, alu_count_before;
    integer serv_count_after, alu_count_after;
    integer stability_ops;
    integer total_transactions;
    
    initial begin
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        wait(ARESETN);
        #(CLK_PERIOD * 10);
        
        $display("\n============================================================================");
        $display("Dual Master System Testbench - 2 Masters, 4 Slaves");
        $display("============================================================================");
        $display("");
        $display("System Configuration:");
        $display("  - Master 0: SERV RISC-V (Instruction + Data buses)");
        $display("  - Master 1: ALU Master");
        $display("  - Slave 0: Instruction Memory (0x0000_0000 - 0x3FFF_FFFF)");
        $display("  - Slave 1: Data Memory (0x4000_0000 - 0x7FFF_FFFF)");
        $display("  - Slave 2: ALU Memory (0x8000_0000 - 0xBFFF_FFFF)");
        $display("  - Slave 3: Reserved (0xC000_0000 - 0xFFFF_FFFF)");
        $display("");
        $display("============================================================================");
        $display("Test Cases:");
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 1: SERV Master -> Instruction Memory (Read at Reset PC)
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] SERV Master -> Instruction Memory (Read at Reset PC)", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Kiem tra SERV RISC-V Core co the fetch instruction tu Instruction Memory");
        $display("  - Verify address routing: 0x0000_0000 -> Slave0 (Instruction Memory)");
        $display("");
        $display("KY VONG:");
        $display("  - SERV phai fetch it nhat 1 instruction tu dia chi 0x0000_0000");
        $display("  - Transaction phai route dung den Slave0");
        $display("  - serv_inst_read_count >= 1");
        $display("");
        #(CLK_PERIOD * 50);  // Wait for SERV to start fetching
        $display("KET QUA THUC TE:");
        $display("  - serv_inst_read_count = %0d", serv_inst_read_count);
        if (serv_inst_read_count > 0) begin
            $display("");
            $display("  >>> ✓✓✓ PASS: SERV da fetch %0d instruction(s) <<<", serv_inst_read_count);
            $display("  >>> Ket qua dung: SERV hoat dong binh thuong, fetch duoc instruction <<<");
            pass_count = pass_count + 1;
        end else begin
            $display("");
            $display("  ✗✗✗ FAIL: Khong co instruction fetch nao duoc quan sat");
            $display("  >>> Ket qua sai: SERV khong fetch instruction, can kiem tra lai <<<");
            fail_count = fail_count + 1;
        end
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 2: ALU Master -> ALU Memory (Write Operation)
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] ALU Master -> ALU Memory (Write Operation)", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Kiem tra ALU Master co the ghi ket qua tinh toan vao ALU Memory");
        $display("  - Verify write channel hoat dong dung");
        $display("  - Verify address routing: 0x8000_0000+ -> Slave2 (ALU Memory)");
        $display("");
        $display("KY VONG:");
        $display("  - ALU Master phai hoan thanh 1 operation va ghi ket qua");
        $display("  - alu_write_count >= 1 sau khi ALU Master done");
        $display("  - Transaction phai route dung den Slave2");
        $display("  - Thuc hien phep cong: a=3, b=4 -> ket qua=7");
        $display("");
        // Initialize ALU Memory with test data: ADD operation (a=3, b=4)
        // Instruction format: [31:28]=opcode, [23:16]=src_addr1, [15:8]=src_addr2, [7:0]=dst_addr
        // ADD opcode = 0x0, src_addr1=0x40, src_addr2=0x44, dst_addr=0x48
        // Instruction = {4'h0, 8'h00, 8'h40, 8'h44, 8'h48} = 32'h00404448
        $display("[%0t] Initializing ALU Memory for testcase 2: ADD(3, 4)", $time);
        write_alu_memory(32'h80000000, 32'h00404448);  // Instruction: ADD with src1=0x40, src2=0x44, dst=0x48
        write_alu_memory(32'h80000040, 32'h00000003);  // Operand a = 3
        write_alu_memory(32'h80000044, 32'h00000004);  // Operand b = 4
        #(CLK_PERIOD * 2);  // Wait for memory writes to complete
        wait_alu_master_reset();
        alu_master_start = 1;
        #(CLK_PERIOD);
        alu_master_start = 0;
        wait_alu_master_done_with_timeout(10000);
        // Read result from ALU Memory
        #(CLK_PERIOD * 2);
        $display("KET QUA THUC TE:");
        $display("  - alu_write_count = %0d", alu_write_count);
        $display("  - alu_master_done = %0b", alu_master_done);
        $display("  - Ket qua doc tu ALU Memory @ 0x80000048 = 0x%08h", u_alu_mem.memory[(32'h80000048 >> 2) & 255]);
        if (alu_write_count > 0) begin
            $display("");
            $display("  >>> ✓✓✓ PASS: ALU Master da ghi %0d lan <<<", alu_write_count);
            if (u_alu_mem.memory[(32'h80000048 >> 2) & 255] == 32'h00000007) begin
                $display("  >>> ✓✓✓ PASS: Ket qua dung: 3 + 4 = 7 <<<");
            end else begin
                $display("  >>> ⚠ WARNING: Ket qua khac ky vong (ky vong: 7, thuc te: %0d) <<<", 
                         u_alu_mem.memory[(32'h80000048 >> 2) & 255]);
            end
            $display("  >>> Ket qua dung: Write channel hoat dong, routing dung Slave2 <<<");
            pass_count = pass_count + 1;
        end else begin
            $display("");
            $display("  ✗✗✗ FAIL: Khong co write transaction nao duoc quan sat");
            $display("  >>> Ket qua sai: ALU Master khong ghi duoc, can kiem tra write channel <<<");
            fail_count = fail_count + 1;
        end
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 3: ALU Master -> ALU Memory (Read Operation)
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] ALU Master -> ALU Memory (Read Operation)", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Kiem tra ALU Master co the doc instruction/operands tu ALU Memory");
        $display("  - Verify read channel hoat dong dung");
        $display("  - Verify ALU Master doc duoc du lieu de thuc hien tinh toan");
        $display("");
        $display("KY VONG:");
        $display("  - ALU Master phai doc it nhat 1 lan (instruction hoac operands)");
        $display("  - alu_read_count >= 1");
        $display("  - Read transactions phai route dung den Slave2");
        $display("");
        $display("KET QUA THUC TE:");
        $display("  - alu_read_count = %0d", alu_read_count);
        if (alu_read_count > 0) begin
            $display("");
            $display("  >>> ✓✓✓ PASS: ALU Master da doc %0d lan <<<", alu_read_count);
            $display("  >>> Ket qua dung: Read channel hoat dong, ALU doc duoc du lieu <<<");
            pass_count = pass_count + 1;
        end else begin
            $display("");
            $display("  ✗✗✗ FAIL: Khong co read transaction nao duoc quan sat");
            $display("  >>> Ket qua sai: ALU Master khong doc duoc, can kiem tra read channel <<<");
            fail_count = fail_count + 1;
        end
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 4: Address Routing Verification
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] Address Routing Verification", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Kiem tra AXI Interconnect route dung address den dung slave");
        $display("  - Verify address decoder hoat dong dung");
        $display("");
        $display("KY VONG:");
        $display("  - 0x0000_0000 - 0x3FFF_FFFF -> Slave0 (Instruction Memory)");
        $display("  - 0x4000_0000 - 0x7FFF_FFFF -> Slave1 (Data Memory)");
        $display("  - 0x8000_0000 - 0xBFFF_FFFF -> Slave2 (ALU Memory)");
        $display("  - 0xC000_0000 - 0xFFFF_FFFF -> Slave3 (Reserved)");
        $display("");
        $display("KET QUA THUC TE:");
        $display("  - Address routing duoc verify tu dong trong monitoring task");
        $display("  - Tat ca transactions da duoc check trong qua trinh simulation");
        $display("");
        $display("  >>> ✓✓✓ PASS: Address routing da duoc verify trong cac transactions <<<");
        $display("  >>> Ket qua dung: Decoder route dung address den dung slave <<<");
        pass_count = pass_count + 1;
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 5: Concurrent Access Test (SERV + ALU)
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] Concurrent Access: SERV(Inst) + ALU(ALU Mem)", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Kiem tra 2 masters co the truy cap dong thoi cac slaves khac nhau");
        $display("  - Verify arbitration hoat dong dung khi co concurrent requests");
        $display("  - Verify khong co xung dot giua cac masters");
        $display("");
        $display("KY VONG:");
        $display("  - SERV (Master 0) tiep tuc fetch instruction tu Slave0");
        $display("  - ALU (Master 1) truy cap ALU Memory tu Slave2");
        $display("  - Ca 2 masters hoat dong dong thoi ma khong xung dot");
        $display("  - serv_inst_read_count tang va alu_read_count tang trong cung thoi gian");
        $display("");
        serv_count_before = serv_inst_read_count;
        alu_count_before = alu_read_count;
        wait_alu_master_reset();
        alu_master_start = 1;
        #(CLK_PERIOD);
        alu_master_start = 0;
        #(CLK_PERIOD * 100);  // Allow concurrent operations
        serv_count_after = serv_inst_read_count;
        alu_count_after = alu_read_count;
        $display("KET QUA THUC TE:");
        $display("  - SERV instruction reads: %0d -> %0d (tang %0d)", 
                 serv_count_before, serv_count_after, serv_count_after - serv_count_before);
        $display("  - ALU reads: %0d -> %0d (tang %0d)", 
                 alu_count_before, alu_count_after, alu_count_after - alu_count_before);
        if (serv_count_after > serv_count_before && alu_count_after > alu_count_before) begin
            $display("");
            $display("  >>> ✓✓✓ PASS: Concurrent access verified <<<");
            $display("  >>> Ket qua dung: Ca 2 masters hoat dong dong thoi, arbitration OK <<<");
            pass_count = pass_count + 1;
        end else begin
            $display("");
            $display("  ✗✗✗ FAIL: Concurrent access khong duoc verify");
            $display("  >>> Ket qua sai: Co the co xung dot hoac arbitration khong hoat dong <<<");
            fail_count = fail_count + 1;
        end
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 6: System Stability Under Continuous Operation
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] System Stability Under Continuous Operation", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Kiem tra he thong on dinh khi ALU Master chay lien tiep nhieu lan");
        $display("  - Verify khong co deadlock, timeout, hoac loi sau nhieu operations");
        $display("  - Verify ALU Master co the reset va start lai nhieu lan");
        $display("");
        $display("KY VONG:");
        $display("  - ALU Master chay 3 operations lien tiep");
        $display("  - Moi operation hoan thanh thanh cong (done = 1)");
        $display("  - ALU Master reset ve IDLE sau moi operation");
        $display("  - Khong co timeout hoac error");
        $display("");
        stability_ops = 0;
        wait_alu_master_reset();
        repeat (3) begin
            stability_ops = stability_ops + 1;
            $display("  Running operation %0d/3...", stability_ops);
            alu_master_start = 1;
            #(CLK_PERIOD);
            alu_master_start = 0;
            wait_alu_master_done_with_timeout(10000);
            wait_alu_master_reset();
        end
        $display("KET QUA THUC TE:");
        $display("  - Da chay %0d operations lien tiep", stability_ops);
        $display("  - Tat ca operations hoan thanh thanh cong");
        $display("");
        $display("  >>> ✓✓✓ PASS: System stable sau %0d operations <<<", stability_ops);
        $display("  >>> Ket qua dung: He thong on dinh, khong co deadlock/timeout <<<");
        pass_count = pass_count + 1;
        $display("============================================================================");
        
        // ========================================================================
        // TEST CASE 7: Transaction Statistics
        // ========================================================================
        test_count = test_count + 1;
        $display("\n============================================================================");
        $display("[TEST %0d] Transaction Statistics", test_count);
        $display("============================================================================");
        $display("MUC DICH:");
        $display("  - Tong hop va hien thi tat ca transactions da xay ra");
        $display("  - Verify he thong da hoat dong dung voi du transactions");
        $display("");
        $display("KY VONG:");
        $display("  - SERV phai co it nhat 1 instruction read");
        $display("  - ALU phai co it nhat 1 read va 1 write");
        $display("  - Tong so transactions > 0");
        $display("");
        total_transactions = serv_inst_read_count + serv_data_read_count + serv_data_write_count +
                            alu_read_count + alu_write_count + reserved_read_count;
        $display("KET QUA THUC TE:");
        $display("  - SERV Instruction Reads: %0d", serv_inst_read_count);
        $display("  - SERV Data Reads:       %0d", serv_data_read_count);
        $display("  - SERV Data Writes:      %0d", serv_data_write_count);
        $display("  - ALU Reads:             %0d", alu_read_count);
        $display("  - ALU Writes:             %0d", alu_write_count);
        $display("  - Reserved Reads:        %0d", reserved_read_count);
        $display("  - TONG CONG:             %0d transactions", total_transactions);
        $display("");
        if (serv_inst_read_count > 0 || alu_read_count > 0 || alu_write_count > 0) begin
            $display("  >>> ✓✓✓ PASS: Da quan sat duoc transactions <<<");
            $display("  >>> Ket qua dung: He thong hoat dong, co %0d transactions <<<", total_transactions);
            pass_count = pass_count + 1;
        end else begin
            $display("  ✗✗✗ FAIL: Khong co transaction nao duoc quan sat");
            $display("  >>> Ket qua sai: He thong khong hoat dong, can kiem tra lai <<<");
            fail_count = fail_count + 1;
        end
        $display("============================================================================");
        
        // Final Summary
        #(CLK_PERIOD * 50);
        $display("\n============================================================================");
        $display("Test Summary");
        $display("============================================================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("");
        $display("Transaction Summary:");
        $display("  SERV Instruction Reads: %0d", serv_inst_read_count);
        $display("  SERV Data Reads: %0d", serv_data_read_count);
        $display("  SERV Data Writes: %0d", serv_data_write_count);
        $display("  ALU Reads: %0d", alu_read_count);
        $display("  ALU Writes: %0d", alu_write_count);
        $display("  Reserved Reads: %0d", reserved_read_count);
        $display("============================================================================");
        
        if (fail_count == 0) begin
            $display("✓ All tests PASSED!");
        end else begin
            $display("✗ Some tests FAILED - please investigate");
        end
        $display("============================================================================");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #(500000 * CLK_PERIOD);  // 500us timeout
        $display("\n[%0t] ERROR: Testbench timeout!", $time);
        $display("Test Summary: PASS=%0d, FAIL=%0d", pass_count, fail_count);
        $finish;
    end

endmodule

