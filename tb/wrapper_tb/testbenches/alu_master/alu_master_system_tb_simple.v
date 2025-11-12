`timescale 1ns/1ps

/*
 * alu_master_system_tb_simple.v : Simple Testbench for ALU Master System
 * 
 * Sử dụng Simple_AXI_Master_Test thay vì CPU_ALU_Master để test routing
 * Tests:
 *   - Master 0 → Slave 0: Write và Read
 *   - Master 1 → Slave 2: Write và Read  
 *   - Verify address routing đúng
 *   - Verify data integrity
 */

module alu_master_system_tb_simple;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Clock and Reset
    reg ACLK;
    reg ARESETN;
    
    // Master 0 Control (Simple AXI Master)
    reg  master0_start;
    reg  [ADDR_WIDTH-1:0] master0_base_addr;
    wire master0_busy;
    wire master0_done;
    
    // Master 1 Control (Simple AXI Master)
    reg  master1_start;
    reg  [ADDR_WIDTH-1:0] master1_base_addr;
    wire master1_busy;
    wire master1_done;
    
    // ========================================================================
    // Test Results
    // ========================================================================
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // ========================================================================
    // Internal AXI Signals để kết nối với wrapper
    // ========================================================================
    // Master 0 AXI signals
    wire [ADDR_WIDTH-1:0] S00_AXI_awaddr;
    wire [7:0]           S00_AXI_awlen;
    wire [2:0]           S00_AXI_awsize;
    wire [1:0]           S00_AXI_awburst;
    wire [1:0]           S00_AXI_awlock;
    wire [3:0]           S00_AXI_awcache;
    wire [2:0]           S00_AXI_awprot;
    wire [3:0]           S00_AXI_awregion;
    wire [3:0]           S00_AXI_awqos;
    wire                 S00_AXI_awvalid;
    wire                 S00_AXI_awready;
    wire [DATA_WIDTH-1:0] S00_AXI_wdata;
    wire [3:0]           S00_AXI_wstrb;
    wire                 S00_AXI_wlast;
    wire                 S00_AXI_wvalid;
    wire                 S00_AXI_wready;
    wire [1:0]           S00_AXI_bresp;
    wire                 S00_AXI_bvalid;
    wire                 S00_AXI_bready;
    wire [ADDR_WIDTH-1:0] S00_AXI_araddr;
    wire [7:0]           S00_AXI_arlen;
    wire [2:0]           S00_AXI_arsize;
    wire [1:0]           S00_AXI_arburst;
    wire [1:0]           S00_AXI_arlock;
    wire [3:0]           S00_AXI_arcache;
    wire [2:0]           S00_AXI_arprot;
    wire [3:0]           S00_AXI_arregion;
    wire [3:0]           S00_AXI_arqos;
    wire                 S00_AXI_arvalid;
    wire                 S00_AXI_arready;
    wire [DATA_WIDTH-1:0] S00_AXI_rdata;
    wire [1:0]           S00_AXI_rresp;
    wire                 S00_AXI_rlast;
    wire                 S00_AXI_rvalid;
    wire                 S00_AXI_rready;
    
    // Master 1 AXI signals
    wire [ADDR_WIDTH-1:0] S01_AXI_awaddr;
    wire [7:0]           S01_AXI_awlen;
    wire [2:0]           S01_AXI_awsize;
    wire [1:0]           S01_AXI_awburst;
    wire [1:0]           S01_AXI_awlock;
    wire [3:0]           S01_AXI_awcache;
    wire [2:0]           S01_AXI_awprot;
    wire [3:0]           S01_AXI_awregion;
    wire [3:0]           S01_AXI_awqos;
    wire                 S01_AXI_awvalid;
    wire                 S01_AXI_awready;
    wire [DATA_WIDTH-1:0] S01_AXI_wdata;
    wire [3:0]           S01_AXI_wstrb;
    wire                 S01_AXI_wlast;
    wire                 S01_AXI_wvalid;
    wire                 S01_AXI_wready;
    wire [1:0]           S01_AXI_bresp;
    wire                 S01_AXI_bvalid;
    wire                 S01_AXI_bready;
    wire [ADDR_WIDTH-1:0] S01_AXI_araddr;
    wire [7:0]           S01_AXI_arlen;
    wire [2:0]           S01_AXI_arsize;
    wire [1:0]           S01_AXI_arburst;
    wire [1:0]           S01_AXI_arlock;
    wire [3:0]           S01_AXI_arcache;
    wire [2:0]           S01_AXI_arprot;
    wire [3:0]           S01_AXI_arregion;
    wire [3:0]           S01_AXI_arqos;
    wire                 S01_AXI_arvalid;
    wire                 S01_AXI_arready;
    wire [DATA_WIDTH-1:0] S01_AXI_rdata;
    wire [1:0]           S01_AXI_rresp;
    wire                 S01_AXI_rlast;
    wire                 S01_AXI_rvalid;
    wire                 S01_AXI_rready;
    
    // ========================================================================
    // Simple AXI Master Test Instances
    // ========================================================================
    Simple_AXI_Master_Test #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_master0_test (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(master0_start),
        .base_address(master0_base_addr),
        .busy(master0_busy),
        .done(master0_done),
        .M_AXI_awaddr(S00_AXI_awaddr),
        .M_AXI_awlen(S00_AXI_awlen),
        .M_AXI_awsize(S00_AXI_awsize),
        .M_AXI_awburst(S00_AXI_awburst),
        .M_AXI_awlock(S00_AXI_awlock),
        .M_AXI_awcache(S00_AXI_awcache),
        .M_AXI_awprot(S00_AXI_awprot),
        .M_AXI_awregion(S00_AXI_awregion),
        .M_AXI_awqos(S00_AXI_awqos),
        .M_AXI_awvalid(S00_AXI_awvalid),
        .M_AXI_awready(S00_AXI_awready),
        .M_AXI_wdata(S00_AXI_wdata),
        .M_AXI_wstrb(S00_AXI_wstrb),
        .M_AXI_wlast(S00_AXI_wlast),
        .M_AXI_wvalid(S00_AXI_wvalid),
        .M_AXI_wready(S00_AXI_wready),
        .M_AXI_bresp(S00_AXI_bresp),
        .M_AXI_bvalid(S00_AXI_bvalid),
        .M_AXI_bready(S00_AXI_bready),
        .M_AXI_araddr(S00_AXI_araddr),
        .M_AXI_arlen(S00_AXI_arlen),
        .M_AXI_arsize(S00_AXI_arsize),
        .M_AXI_arburst(S00_AXI_arburst),
        .M_AXI_arlock(S00_AXI_arlock),
        .M_AXI_arcache(S00_AXI_arcache),
        .M_AXI_arprot(S00_AXI_arprot),
        .M_AXI_arregion(S00_AXI_arregion),
        .M_AXI_arqos(S00_AXI_arqos),
        .M_AXI_arvalid(S00_AXI_arvalid),
        .M_AXI_arready(S00_AXI_arready),
        .M_AXI_rdata(S00_AXI_rdata),
        .M_AXI_rresp(S00_AXI_rresp),
        .M_AXI_rlast(S00_AXI_rlast),
        .M_AXI_rvalid(S00_AXI_rvalid),
        .M_AXI_rready(S00_AXI_rready)
    );
    
    Simple_AXI_Master_Test #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_master1_test (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(master1_start),
        .base_address(master1_base_addr),
        .busy(master1_busy),
        .done(master1_done),
        .M_AXI_awaddr(S01_AXI_awaddr),
        .M_AXI_awlen(S01_AXI_awlen),
        .M_AXI_awsize(S01_AXI_awsize),
        .M_AXI_awburst(S01_AXI_awburst),
        .M_AXI_awlock(S01_AXI_awlock),
        .M_AXI_awcache(S01_AXI_awcache),
        .M_AXI_awprot(S01_AXI_awprot),
        .M_AXI_awregion(S01_AXI_arregion),
        .M_AXI_awqos(S01_AXI_awqos),
        .M_AXI_awvalid(S01_AXI_awvalid),
        .M_AXI_awready(S01_AXI_awready),
        .M_AXI_wdata(S01_AXI_wdata),
        .M_AXI_wstrb(S01_AXI_wstrb),
        .M_AXI_wlast(S01_AXI_wlast),
        .M_AXI_wvalid(S01_AXI_wvalid),
        .M_AXI_wready(S01_AXI_wready),
        .M_AXI_bresp(S01_AXI_bresp),
        .M_AXI_bvalid(S01_AXI_bvalid),
        .M_AXI_bready(S01_AXI_bready),
        .M_AXI_araddr(S01_AXI_araddr),
        .M_AXI_arlen(S01_AXI_arlen),
        .M_AXI_arsize(S01_AXI_arsize),
        .M_AXI_arburst(S01_AXI_arburst),
        .M_AXI_arlock(S01_AXI_arlock),
        .M_AXI_arcache(S01_AXI_arcache),
        .M_AXI_arprot(S01_AXI_arprot),
        .M_AXI_arregion(S01_AXI_arregion),
        .M_AXI_arqos(S01_AXI_arqos),
        .M_AXI_arvalid(S01_AXI_arvalid),
        .M_AXI_arready(S01_AXI_arready),
        .M_AXI_rdata(S01_AXI_rdata),
        .M_AXI_rresp(S01_AXI_rresp),
        .M_AXI_rlast(S01_AXI_rlast),
        .M_AXI_rvalid(S01_AXI_rvalid),
        .M_AXI_rready(S01_AXI_rready)
    );
    
    // ========================================================================
    // Interconnect to Slave Wires
    // ========================================================================
    // Slave 0 (M00) wires
    wire [ADDR_WIDTH-1:0] M00_AXI_awaddr;
    wire [7:0]           M00_AXI_awlen;
    wire [2:0]           M00_AXI_awsize;
    wire [1:0]           M00_AXI_awburst;
    wire [1:0]           M00_AXI_awlock;
    wire [3:0]           M00_AXI_awcache;
    wire [2:0]           M00_AXI_awprot;
    wire [3:0]           M00_AXI_awqos;
    wire                 M00_AXI_awvalid;
    wire                 M00_AXI_awready;
    wire [DATA_WIDTH-1:0] M00_AXI_wdata;
    wire [3:0]           M00_AXI_wstrb;
    wire                 M00_AXI_wlast;
    wire                 M00_AXI_wvalid;
    wire                 M00_AXI_wready;
    wire [1:0]           M00_AXI_bresp;
    wire                 M00_AXI_bvalid;
    wire                 M00_AXI_bready;
    wire [ADDR_WIDTH-1:0] M00_AXI_araddr;
    wire [7:0]           M00_AXI_arlen;
    wire [2:0]           M00_AXI_arsize;
    wire [1:0]           M00_AXI_arburst;
    wire [1:0]           M00_AXI_arlock;
    wire [3:0]           M00_AXI_arcache;
    wire [2:0]           M00_AXI_arprot;
    wire [3:0]           M00_AXI_arregion;
    wire [3:0]           M00_AXI_arqos;
    wire                 M00_AXI_arvalid;
    wire                 M00_AXI_arready;
    wire [DATA_WIDTH-1:0] M00_AXI_rdata;
    wire [1:0]           M00_AXI_rresp;
    wire                 M00_AXI_rlast;
    wire                 M00_AXI_rvalid;
    wire                 M00_AXI_rready;
    
    // Slave 1 (M01) wires
    wire [ADDR_WIDTH-1:0] M01_AXI_awaddr;
    wire [7:0]           M01_AXI_awlen;
    wire [2:0]           M01_AXI_awsize;
    wire [1:0]           M01_AXI_awburst;
    wire [1:0]           M01_AXI_awlock;
    wire [3:0]           M01_AXI_awcache;
    wire [2:0]           M01_AXI_awprot;
    wire [3:0]           M01_AXI_awqos;
    wire                 M01_AXI_awvalid;
    wire                 M01_AXI_awready;
    wire [DATA_WIDTH-1:0] M01_AXI_wdata;
    wire [3:0]           M01_AXI_wstrb;
    wire                 M01_AXI_wlast;
    wire                 M01_AXI_wvalid;
    wire                 M01_AXI_wready;
    wire [1:0]           M01_AXI_bresp;
    wire                 M01_AXI_bvalid;
    wire                 M01_AXI_bready;
    wire [ADDR_WIDTH-1:0] M01_AXI_araddr;
    wire [7:0]           M01_AXI_arlen;
    wire [2:0]           M01_AXI_arsize;
    wire [1:0]           M01_AXI_arburst;
    wire [1:0]           M01_AXI_arlock;
    wire [3:0]           M01_AXI_arcache;
    wire [2:0]           M01_AXI_arprot;
    wire [3:0]           M01_AXI_arregion;
    wire [3:0]           M01_AXI_arqos;
    wire                 M01_AXI_arvalid;
    wire                 M01_AXI_arready;
    wire [DATA_WIDTH-1:0] M01_AXI_rdata;
    wire [1:0]           M01_AXI_rresp;
    wire                 M01_AXI_rlast;
    wire                 M01_AXI_rvalid;
    wire                 M01_AXI_rready;
    
    // Slave 2 (M02) wires (read-only)
    wire [ADDR_WIDTH-1:0] M02_AXI_araddr;
    wire [7:0]           M02_AXI_arlen;
    wire [2:0]           M02_AXI_arsize;
    wire [1:0]           M02_AXI_arburst;
    wire [1:0]           M02_AXI_arlock;
    wire [3:0]           M02_AXI_arcache;
    wire [2:0]           M02_AXI_arprot;
    wire [3:0]           M02_AXI_arregion;
    wire [3:0]           M02_AXI_arqos;
    wire                 M02_AXI_arvalid;
    wire                 M02_AXI_arready;
    wire [DATA_WIDTH-1:0] M02_AXI_rdata;
    wire [1:0]           M02_AXI_rresp;
    wire                 M02_AXI_rlast;
    wire                 M02_AXI_rvalid;
    wire                 M02_AXI_rready;
    
    // Slave 3 (M03) wires (read-only)
    wire [ADDR_WIDTH-1:0] M03_AXI_araddr;
    wire [7:0]           M03_AXI_arlen;
    wire [2:0]           M03_AXI_arsize;
    wire [1:0]           M03_AXI_arburst;
    wire [1:0]           M03_AXI_arlock;
    wire [3:0]           M03_AXI_arcache;
    wire [2:0]           M03_AXI_arprot;
    wire [3:0]           M03_AXI_arregion;
    wire [3:0]           M03_AXI_arqos;
    wire                 M03_AXI_arvalid;
    wire                 M03_AXI_arready;
    wire [DATA_WIDTH-1:0] M03_AXI_rdata;
    wire [1:0]           M03_AXI_rresp;
    wire                 M03_AXI_rlast;
    wire                 M03_AXI_rvalid;
    wire                 M03_AXI_rready;
    
    // ========================================================================
    // AXI Interconnect Instantiation
    // ========================================================================
    AXI_Interconnect_Full #(
        .Masters_Num(2),
        .Address_width(32),
        .S00_Aw_len(8),
        .S00_Write_data_bus_width(32),
        .S00_Write_data_bytes_num(4),
        .S00_AR_len(8),
        .S00_Read_data_bus_width(32),
        .S01_Aw_len(8),
        .S01_Write_data_bus_width(32),
        .S01_AR_len(8),
        .M00_Aw_len(8),
        .M00_Write_data_bus_width(32),
        .M00_Write_data_bytes_num(4),
        .M00_AR_len(8),
        .M00_Read_data_bus_width(32),
        .M01_Aw_len(8),
        .M01_AR_len(8),
        .M02_Aw_len(8),
        .M02_AR_len(8),
        .M02_Read_data_bus_width(32),
        .M03_Aw_len(8),
        .M03_AR_len(8),
        .M03_Read_data_bus_width(32),
        .Is_Master_AXI_4(1'b1),
        .M1_ID(0),
        .M2_ID(1),
        .Resp_ID_width(2),
        .Num_Of_Masters(2),
        .Num_Of_Slaves(4),
        .Master_ID_Width(1),
        .AXI4_AR_len(8),
        .AXI4_Aw_len(8)
    ) u_interconnect (
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        .S01_AXI_awaddr(S01_AXI_awaddr),
        .S01_AXI_awlen(S01_AXI_awlen),
        .S01_AXI_awsize(S01_AXI_awsize),
        .S01_AXI_awburst(S01_AXI_awburst),
        .S01_AXI_awlock(S01_AXI_awlock),
        .S01_AXI_awcache(S01_AXI_awcache),
        .S01_AXI_awprot(S01_AXI_awprot),
        .S01_AXI_awqos(S01_AXI_awqos),
        .S01_AXI_awvalid(S01_AXI_awvalid),
        .S01_AXI_awready(S01_AXI_awready),
        .S01_AXI_wdata(S01_AXI_wdata),
        .S01_AXI_wstrb(S01_AXI_wstrb),
        .S01_AXI_wlast(S01_AXI_wlast),
        .S01_AXI_wvalid(S01_AXI_wvalid),
        .S01_AXI_wready(S01_AXI_wready),
        .S01_AXI_bresp(S01_AXI_bresp),
        .S01_AXI_bvalid(S01_AXI_bvalid),
        .S01_AXI_bready(S01_AXI_bready),
        .S01_AXI_araddr(S01_AXI_araddr),
        .S01_AXI_arlen(S01_AXI_arlen),
        .S01_AXI_arsize(S01_AXI_arsize),
        .S01_AXI_arburst(S01_AXI_arburst),
        .S01_AXI_arlock(S01_AXI_arlock),
        .S01_AXI_arcache(S01_AXI_arcache),
        .S01_AXI_arprot(S01_AXI_arprot),
        .S01_AXI_arregion(4'b0),
        .S01_AXI_arqos(S01_AXI_arqos),
        .S01_AXI_arvalid(S01_AXI_arvalid),
        .S01_AXI_arready(S01_AXI_arready),
        .S01_AXI_rdata(S01_AXI_rdata),
        .S01_AXI_rresp(S01_AXI_rresp),
        .S01_AXI_rlast(S01_AXI_rlast),
        .S01_AXI_rvalid(S01_AXI_rvalid),
        .S01_AXI_rready(S01_AXI_rready),
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S00_AXI_awaddr(S00_AXI_awaddr),
        .S00_AXI_awlen(S00_AXI_awlen),
        .S00_AXI_awsize(S00_AXI_awsize),
        .S00_AXI_awburst(S00_AXI_awburst),
        .S00_AXI_awlock(S00_AXI_awlock),
        .S00_AXI_awcache(S00_AXI_awcache),
        .S00_AXI_awprot(S00_AXI_awprot),
        .S00_AXI_awqos(S00_AXI_awqos),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S00_AXI_awready(S00_AXI_awready),
        .S00_AXI_wdata(S00_AXI_wdata),
        .S00_AXI_wstrb(S00_AXI_wstrb),
        .S00_AXI_wlast(S00_AXI_wlast),
        .S00_AXI_wvalid(S00_AXI_wvalid),
        .S00_AXI_wready(S00_AXI_wready),
        .S00_AXI_bresp(S00_AXI_bresp),
        .S00_AXI_bvalid(S00_AXI_bvalid),
        .S00_AXI_bready(S00_AXI_bready),
        .S00_AXI_araddr(S00_AXI_araddr),
        .S00_AXI_arlen(S00_AXI_arlen),
        .S00_AXI_arsize(S00_AXI_arsize),
        .S00_AXI_arburst(S00_AXI_arburst),
        .S00_AXI_arlock(S00_AXI_arlock),
        .S00_AXI_arcache(S00_AXI_arcache),
        .S00_AXI_arprot(S00_AXI_arprot),
        .S00_AXI_arregion(4'b0),
        .S00_AXI_arqos(S00_AXI_arqos),
        .S00_AXI_arvalid(S00_AXI_arvalid),
        .S00_AXI_arready(S00_AXI_arready),
        .S00_AXI_rdata(S00_AXI_rdata),
        .S00_AXI_rresp(S00_AXI_rresp),
        .S00_AXI_rlast(S00_AXI_rlast),
        .S00_AXI_rvalid(S00_AXI_rvalid),
        .S00_AXI_rready(S00_AXI_rready),
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        .M00_AXI_awaddr_ID(),
        .M00_AXI_awaddr(M00_AXI_awaddr),
        .M00_AXI_awlen(M00_AXI_awlen),
        .M00_AXI_awsize(M00_AXI_awsize),
        .M00_AXI_awburst(M00_AXI_awburst),
        .M00_AXI_awlock(M00_AXI_awlock),
        .M00_AXI_awcache(M00_AXI_awcache),
        .M00_AXI_awprot(M00_AXI_awprot),
        .M00_AXI_awqos(M00_AXI_awqos),
        .M00_AXI_awvalid(M00_AXI_awvalid),
        .M00_AXI_awready(M00_AXI_awready),
        .M00_AXI_wdata(M00_AXI_wdata),
        .M00_AXI_wstrb(M00_AXI_wstrb),
        .M00_AXI_wlast(M00_AXI_wlast),
        .M00_AXI_wvalid(M00_AXI_wvalid),
        .M00_AXI_wready(M00_AXI_wready),
        .M00_AXI_BID(),
        .M00_AXI_bresp(M00_AXI_bresp),
        .M00_AXI_bvalid(M00_AXI_bvalid),
        .M00_AXI_bready(M00_AXI_bready),
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
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        .M01_AXI_awaddr_ID(),
        .M01_AXI_awaddr(M01_AXI_awaddr),
        .M01_AXI_awlen(M01_AXI_awlen),
        .M01_AXI_awsize(M01_AXI_awsize),
        .M01_AXI_awburst(M01_AXI_awburst),
        .M01_AXI_awlock(M01_AXI_awlock),
        .M01_AXI_awcache(M01_AXI_awcache),
        .M01_AXI_awprot(M01_AXI_awprot),
        .M01_AXI_awqos(M01_AXI_awqos),
        .M01_AXI_awvalid(M01_AXI_awvalid),
        .M01_AXI_awready(M01_AXI_awready),
        .M01_AXI_wdata(M01_AXI_wdata),
        .M01_AXI_wstrb(M01_AXI_wstrb),
        .M01_AXI_wlast(M01_AXI_wlast),
        .M01_AXI_wvalid(M01_AXI_wvalid),
        .M01_AXI_wready(M01_AXI_wready),
        .M01_AXI_BID(),
        .M01_AXI_bresp(M01_AXI_bresp),
        .M01_AXI_bvalid(M01_AXI_bvalid),
        .M01_AXI_bready(M01_AXI_bready),
        .M01_AXI_araddr(M01_AXI_araddr),
        .M01_AXI_arlen(M01_AXI_arlen),
        .M01_AXI_arsize(M01_AXI_arsize),
        .M01_AXI_arburst(M01_AXI_arburst),
        .M01_AXI_arlock(M01_AXI_arlock),
        .M01_AXI_arcache(M01_AXI_arcache),
        .M01_AXI_arprot(M01_AXI_arprot),
        .M01_AXI_arregion(M01_AXI_arregion),
        .M01_AXI_arqos(M01_AXI_arqos),
        .M01_AXI_arvalid(M01_AXI_arvalid),
        .M01_AXI_arready(M01_AXI_arready),
        .M01_AXI_rdata(M01_AXI_rdata),
        .M01_AXI_rresp(M01_AXI_rresp),
        .M01_AXI_rlast(M01_AXI_rlast),
        .M01_AXI_rvalid(M01_AXI_rvalid),
        .M01_AXI_rready(M01_AXI_rready),
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        .M02_AXI_araddr(M02_AXI_araddr),
        .M02_AXI_arlen(M02_AXI_arlen),
        .M02_AXI_arsize(M02_AXI_arsize),
        .M02_AXI_arburst(M02_AXI_arburst),
        .M02_AXI_arlock(M02_AXI_arlock),
        .M02_AXI_arcache(M02_AXI_arcache),
        .M02_AXI_arprot(M02_AXI_arprot),
        .M02_AXI_arregion(M02_AXI_arregion),
        .M02_AXI_arqos(M02_AXI_arqos),
        .M02_AXI_arvalid(M02_AXI_arvalid),
        .M02_AXI_arready(M02_AXI_arready),
        .M02_AXI_rdata(M02_AXI_rdata),
        .M02_AXI_rresp(M02_AXI_rresp),
        .M02_AXI_rlast(M02_AXI_rlast),
        .M02_AXI_rvalid(M02_AXI_rvalid),
        .M02_AXI_rready(M02_AXI_rready),
        .M03_ACLK(ACLK),
        .M03_ARESETN(ARESETN),
        .M03_AXI_araddr(M03_AXI_araddr),
        .M03_AXI_arlen(M03_AXI_arlen),
        .M03_AXI_arsize(M03_AXI_arsize),
        .M03_AXI_arburst(M03_AXI_arburst),
        .M03_AXI_arlock(M03_AXI_arlock),
        .M03_AXI_arcache(M03_AXI_arcache),
        .M03_AXI_arprot(M03_AXI_arprot),
        .M03_AXI_arregion(M03_AXI_arregion),
        .M03_AXI_arqos(M03_AXI_arqos),
        .M03_AXI_arvalid(M03_AXI_arvalid),
        .M03_AXI_arready(M03_AXI_arready),
        .M03_AXI_rdata(M03_AXI_rdata),
        .M03_AXI_rresp(M03_AXI_rresp),
        .M03_AXI_rlast(M03_AXI_rlast),
        .M03_AXI_rvalid(M03_AXI_rvalid),
        .M03_AXI_rready(M03_AXI_rready),
        .slave0_addr1(32'h0000_0000),
        .slave0_addr2(32'h3FFF_FFFF),
        .slave1_addr1(32'h4000_0000),
        .slave1_addr2(32'h7FFF_FFFF),
        .slave2_addr1(32'h8000_0000),
        .slave2_addr2(32'hBFFF_FFFF),
        .slave3_addr1(32'hC000_0000),
        .slave3_addr2(32'hFFFF_FFFF)
    );
    
    // ========================================================================
    // Slave Memory Instances
    // ========================================================================
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(256)
    ) u_slave0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(M00_AXI_awaddr),
        .S_AXI_awlen(M00_AXI_awlen),
        .S_AXI_awsize(M00_AXI_awsize),
        .S_AXI_awburst(M00_AXI_awburst),
        .S_AXI_awlock(M00_AXI_awlock),
        .S_AXI_awcache(M00_AXI_awcache),
        .S_AXI_awprot(M00_AXI_awprot),
        .S_AXI_awregion(M00_AXI_arregion),
        .S_AXI_awqos(M00_AXI_awqos),
        .S_AXI_awvalid(M00_AXI_awvalid),
        .S_AXI_awready(M00_AXI_awready),
        .S_AXI_wdata(M00_AXI_wdata),
        .S_AXI_wstrb(M00_AXI_wstrb),
        .S_AXI_wlast(M00_AXI_wlast),
        .S_AXI_wvalid(M00_AXI_wvalid),
        .S_AXI_wready(M00_AXI_wready),
        .S_AXI_bresp(M00_AXI_bresp),
        .S_AXI_bvalid(M00_AXI_bvalid),
        .S_AXI_bready(M00_AXI_bready),
        .S_AXI_araddr(M00_AXI_araddr),
        .S_AXI_arlen(M00_AXI_arlen),
        .S_AXI_arsize(M00_AXI_arsize),
        .S_AXI_arburst(M00_AXI_arburst),
        .S_AXI_arlock(M00_AXI_arlock),
        .S_AXI_arcache(M00_AXI_arcache),
        .S_AXI_arprot(M00_AXI_arprot),
        .S_AXI_arregion(M00_AXI_arregion),
        .S_AXI_arqos(M00_AXI_arqos),
        .S_AXI_arvalid(M00_AXI_arvalid),
        .S_AXI_arready(M00_AXI_arready),
        .S_AXI_rdata(M00_AXI_rdata),
        .S_AXI_rresp(M00_AXI_rresp),
        .S_AXI_rlast(M00_AXI_rlast),
        .S_AXI_rvalid(M00_AXI_rvalid),
        .S_AXI_rready(M00_AXI_rready)
    );
    
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(256)
    ) u_slave1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(M01_AXI_awaddr),
        .S_AXI_awlen(M01_AXI_awlen),
        .S_AXI_awsize(M01_AXI_awsize),
        .S_AXI_awburst(M01_AXI_awburst),
        .S_AXI_awlock(M01_AXI_awlock),
        .S_AXI_awcache(M01_AXI_awcache),
        .S_AXI_awprot(M01_AXI_awprot),
        .S_AXI_awregion(M01_AXI_arregion),
        .S_AXI_awqos(M01_AXI_awqos),
        .S_AXI_awvalid(M01_AXI_awvalid),
        .S_AXI_awready(M01_AXI_awready),
        .S_AXI_wdata(M01_AXI_wdata),
        .S_AXI_wstrb(M01_AXI_wstrb),
        .S_AXI_wlast(M01_AXI_wlast),
        .S_AXI_wvalid(M01_AXI_wvalid),
        .S_AXI_wready(M01_AXI_wready),
        .S_AXI_bresp(M01_AXI_bresp),
        .S_AXI_bvalid(M01_AXI_bvalid),
        .S_AXI_bready(M01_AXI_bready),
        .S_AXI_araddr(M01_AXI_araddr),
        .S_AXI_arlen(M01_AXI_arlen),
        .S_AXI_arsize(M01_AXI_arsize),
        .S_AXI_arburst(M01_AXI_arburst),
        .S_AXI_arlock(M01_AXI_arlock),
        .S_AXI_arcache(M01_AXI_arcache),
        .S_AXI_arprot(M01_AXI_arprot),
        .S_AXI_arregion(M01_AXI_arregion),
        .S_AXI_arqos(M01_AXI_arqos),
        .S_AXI_arvalid(M01_AXI_arvalid),
        .S_AXI_arready(M01_AXI_arready),
        .S_AXI_rdata(M01_AXI_rdata),
        .S_AXI_rresp(M01_AXI_rresp),
        .S_AXI_rlast(M01_AXI_rlast),
        .S_AXI_rvalid(M01_AXI_rvalid),
        .S_AXI_rready(M01_AXI_rready)
    );
    
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(256)
    ) u_slave2 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(32'h0),
        .S_AXI_awlen(8'h0),
        .S_AXI_awsize(3'h0),
        .S_AXI_awburst(2'h0),
        .S_AXI_awlock(2'h0),
        .S_AXI_awcache(4'h0),
        .S_AXI_awprot(3'h0),
        .S_AXI_awregion(4'h0),
        .S_AXI_awqos(4'h0),
        .S_AXI_awvalid(1'b0),
        .S_AXI_awready(),
        .S_AXI_wdata(32'h0),
        .S_AXI_wstrb(4'h0),
        .S_AXI_wlast(1'b0),
        .S_AXI_wvalid(1'b0),
        .S_AXI_wready(),
        .S_AXI_bresp(),
        .S_AXI_bvalid(),
        .S_AXI_bready(1'b0),
        .S_AXI_araddr(M02_AXI_araddr),
        .S_AXI_arlen(M02_AXI_arlen),
        .S_AXI_arsize(M02_AXI_arsize),
        .S_AXI_arburst(M02_AXI_arburst),
        .S_AXI_arlock(M02_AXI_arlock),
        .S_AXI_arcache(M02_AXI_arcache),
        .S_AXI_arprot(M02_AXI_arprot),
        .S_AXI_arregion(M02_AXI_arregion),
        .S_AXI_arqos(M02_AXI_arqos),
        .S_AXI_arvalid(M02_AXI_arvalid),
        .S_AXI_arready(M02_AXI_arready),
        .S_AXI_rdata(M02_AXI_rdata),
        .S_AXI_rresp(M02_AXI_rresp),
        .S_AXI_rlast(M02_AXI_rlast),
        .S_AXI_rvalid(M02_AXI_rvalid),
        .S_AXI_rready(M02_AXI_rready)
    );
    
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(256)
    ) u_slave3 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(32'h0),
        .S_AXI_awlen(8'h0),
        .S_AXI_awsize(3'h0),
        .S_AXI_awburst(2'h0),
        .S_AXI_awlock(2'h0),
        .S_AXI_awcache(4'h0),
        .S_AXI_awprot(3'h0),
        .S_AXI_awregion(4'h0),
        .S_AXI_awqos(4'h0),
        .S_AXI_awvalid(1'b0),
        .S_AXI_awready(),
        .S_AXI_wdata(32'h0),
        .S_AXI_wstrb(4'h0),
        .S_AXI_wlast(1'b0),
        .S_AXI_wvalid(1'b0),
        .S_AXI_wready(),
        .S_AXI_bresp(),
        .S_AXI_bvalid(),
        .S_AXI_bready(1'b0),
        .S_AXI_araddr(M03_AXI_araddr),
        .S_AXI_arlen(M03_AXI_arlen),
        .S_AXI_arsize(M03_AXI_arsize),
        .S_AXI_arburst(M03_AXI_arburst),
        .S_AXI_arlock(M03_AXI_arlock),
        .S_AXI_arcache(M03_AXI_arcache),
        .S_AXI_arprot(M03_AXI_arprot),
        .S_AXI_arregion(M03_AXI_arregion),
        .S_AXI_arqos(M03_AXI_arqos),
        .S_AXI_arvalid(M03_AXI_arvalid),
        .S_AXI_arready(M03_AXI_arready),
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
        master0_start = 0;
        master0_base_addr = 32'h0;
        master1_start = 0;
        master1_base_addr = 32'h0;
        #(CLK_PERIOD * 10);
        ARESETN = 1;
        #(CLK_PERIOD * 5);
        $display("[%0t] Reset released", $time);
    end
    
    // ========================================================================
    // Monitor AXI Transactions
    // ========================================================================
    always @(posedge ACLK) begin
        if (ARESETN) begin
            // Monitor Master 0 Write
            if (S00_AXI_awvalid && S00_AXI_awready) begin
                $display("[%0t] M0->AW: addr=0x%08h -> Slave %0d", 
                    $time, S00_AXI_awaddr, S00_AXI_awaddr[31:30]);
            end
            if (S00_AXI_wvalid && S00_AXI_wready) begin
                $display("[%0t] M0->WD: data=0x%08h", $time, S00_AXI_wdata);
            end
            if (S00_AXI_bvalid && S00_AXI_bready) begin
                $display("[%0t] M0<-BR: resp=%0d", $time, S00_AXI_bresp);
            end
            
            // Monitor Master 0 Read
            if (S00_AXI_arvalid && S00_AXI_arready) begin
                $display("[%0t] M0->AR: addr=0x%08h -> Slave %0d", 
                    $time, S00_AXI_araddr, S00_AXI_araddr[31:30]);
            end
            if (S00_AXI_rvalid && S00_AXI_rready) begin
                $display("[%0t] M0<-RD: data=0x%08h", $time, S00_AXI_rdata);
            end
            
            // Monitor Master 1 Write
            if (S01_AXI_awvalid && S01_AXI_awready) begin
                $display("[%0t] M1->AW: addr=0x%08h -> Slave %0d", 
                    $time, S01_AXI_awaddr, S01_AXI_awaddr[31:30]);
            end
            if (S01_AXI_wvalid && S01_AXI_wready) begin
                $display("[%0t] M1->WD: data=0x%08h", $time, S01_AXI_wdata);
            end
            if (S01_AXI_bvalid && S01_AXI_bready) begin
                $display("[%0t] M1<-BR: resp=%0d", $time, S01_AXI_bresp);
            end
            
            // Monitor Master 1 Read
            if (S01_AXI_arvalid && S01_AXI_arready) begin
                $display("[%0t] M1->AR: addr=0x%08h -> Slave %0d", 
                    $time, S01_AXI_araddr, S01_AXI_araddr[31:30]);
            end
            if (S01_AXI_rvalid && S01_AXI_rready) begin
                $display("[%0t] M1<-RD: data=0x%08h", $time, S01_AXI_rdata);
            end
        end
    end
    
    // ========================================================================
    // Test Functions
    // ========================================================================
    task check_master_done;
        input integer master_num;
        input integer timeout_cycles;
        integer cycles;
        reg done_signal;
        begin
            cycles = 0;
            if (master_num == 0) begin
                done_signal = master0_done;
            end else begin
                done_signal = master1_done;
            end
            
            while (!done_signal && cycles < timeout_cycles) begin
                @(posedge ACLK);
                cycles = cycles + 1;
                if (master_num == 0) begin
                    done_signal = master0_done;
                end else begin
                    done_signal = master1_done;
                end
            end
            
            if (done_signal) begin
                $display("[%0t] ✓ Master %0d completed successfully", $time, master_num);
                pass_count = pass_count + 1;
            end else begin
                $display("[%0t] ✗ Master %0d TIMEOUT after %0d cycles", 
                    $time, master_num, timeout_cycles);
                fail_count = fail_count + 1;
            end
            test_count = test_count + 1;
        end
    endtask
    
    // ========================================================================
    // Test Sequence
    // ========================================================================
    initial begin
        $display("\n============================================================================");
        $display("ALU Master System Simple Testbench Started");
        $display("============================================================================");
        
        // Wait for reset release
        wait(ARESETN);
        #(CLK_PERIOD * 10);
        
        // Test 1: Master 0 → Slave 0 (address 0x0000_0000)
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 1: Master 0 → Slave 0 (0x0000_0000)", $time);
        $display("[%0t] ========================================", $time);
        master0_base_addr = 32'h0000_0000;  // Slave 0 address range
        master0_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        
        check_master_done(0, 5000);
        #(CLK_PERIOD * 10);
        
        // Test 2: Master 1 → Slave 2 (address 0x8000_0000)
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 2: Master 1 → Slave 2 (0x8000_0000)", $time);
        $display("[%0t] ========================================", $time);
        master1_base_addr = 32'h8000_0000;  // Slave 2 address range
        master1_start = 1;
        #(CLK_PERIOD);
        master1_start = 0;
        
        check_master_done(1, 5000);
        #(CLK_PERIOD * 10);
        
        // Test 3: Master 0 → Slave 1 (address 0x4000_0000)
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 3: Master 0 → Slave 1 (0x4000_0000)", $time);
        $display("[%0t] ========================================", $time);
        master0_base_addr = 32'h4000_0000;  // Slave 1 address range
        master0_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        
        check_master_done(0, 5000);
        #(CLK_PERIOD * 10);
        
        // Test 4: Master 1 → Slave 3 (address 0xC000_0000)
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 4: Master 1 → Slave 3 (0xC000_0000)", $time);
        $display("[%0t] ========================================", $time);
        master1_base_addr = 32'hC000_0000;  // Slave 3 address range
        master1_start = 1;
        #(CLK_PERIOD);
        master1_start = 0;
        
        check_master_done(1, 5000);
        #(CLK_PERIOD * 10);
        
        // Test 5: Both masters simultaneously
        $display("\n[%0t] ========================================", $time);
        $display("[%0t] Test 5: Both masters simultaneously", $time);
        $display("[%0t] ========================================", $time);
        master0_base_addr = 32'h0000_0000;
        master1_base_addr = 32'h8000_0000;
        master0_start = 1;
        master1_start = 1;
        #(CLK_PERIOD);
        master0_start = 0;
        master1_start = 0;
        
        fork
            check_master_done(0, 5000);
            check_master_done(1, 5000);
        join
        #(CLK_PERIOD * 10);
        
        // Print Summary
        $display("\n============================================================================");
        $display("Test Summary");
        $display("============================================================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        if (fail_count == 0) begin
            $display("Status:      ✓ ALL TESTS PASSED");
        end else begin
            $display("Status:      ✗ SOME TESTS FAILED");
        end
        $display("============================================================================");
        
        #(CLK_PERIOD * 10);
        $finish;
    end
    
    // ========================================================================
    // Timeout Check
    // ========================================================================
    initial begin
        #(100000 * CLK_PERIOD);  // 100us timeout
        $display("\n[%0t] ERROR: Testbench timeout!", $time);
        $display("Test Summary: %0d tests, %0d passed, %0d failed", 
            test_count, pass_count, fail_count);
        $finish;
    end
    
    // ========================================================================
    // Waveform Dump
    // ========================================================================
    initial begin
        $dumpfile("alu_master_system_tb_simple.vcd");
        $dumpvars(0, alu_master_system_tb_simple);
    end

endmodule

