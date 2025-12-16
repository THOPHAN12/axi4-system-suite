//------------------------------------------------------------------------------
// AXI_Interconnect_Full_RW_Wrapper.v
//
// Full Read/Write Wrapper for AXI_Interconnect_Full
// 2 Masters × 2 Slaves with complete AXI4 R/W support
//
// This is the SIMPLIFIED wrapper with full functionality - no unused pins!
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module AXI_Interconnect #(
    parameter integer ARBITRATION_MODE = 1  // 0=FIXED, 1=ROUND_ROBIN, 2=QOS
) (
    // Global signals
    input logic           ACLK,
    input logic           ARESETN,

    // ========================================================================
    // Master 0 - FULL Read/Write AXI4 interface
    // ========================================================================
    // Write Address Channel
    input logic [31:0]    M0_AWADDR,
    input logic [7:0]     M0_AWLEN,
    input logic [2:0]     M0_AWSIZE,
    input logic [1:0]     M0_AWBURST,
    input logic           M0_AWVALID,
    output logic           M0_AWREADY,
    // Write Data Channel
    input logic [31:0]    M0_WDATA,
    input logic [3:0]     M0_WSTRB,
    input logic           M0_WLAST,
    input logic           M0_WVALID,
    output logic           M0_WREADY,
    // Write Response Channel
    output logic [1:0]     M0_BRESP,
    output logic           M0_BVALID,
    input logic           M0_BREADY,
    // Read Address Channel
    input logic [31:0]    M0_ARADDR,
    input logic [7:0]     M0_ARLEN,
    input logic [2:0]     M0_ARSIZE,
    input logic [1:0]     M0_ARBURST,
    input logic           M0_ARVALID,
    output logic           M0_ARREADY,
    // Read Data Channel
    output logic [31:0]    M0_RDATA,
    output logic [1:0]     M0_RRESP,
    output logic           M0_RLAST,
    output logic           M0_RVALID,
    input logic           M0_RREADY,

    // ========================================================================
    // Master 1 - FULL Read/Write AXI4 interface
    // ========================================================================
    // Write Address Channel
    input logic [31:0]    M1_AWADDR,
    input logic [7:0]     M1_AWLEN,
    input logic [2:0]     M1_AWSIZE,
    input logic [1:0]     M1_AWBURST,
    input logic           M1_AWVALID,
    output logic           M1_AWREADY,
    // Write Data Channel
    input logic [31:0]    M1_WDATA,
    input logic [3:0]     M1_WSTRB,
    input logic           M1_WLAST,
    input logic           M1_WVALID,
    output logic           M1_WREADY,
    // Write Response Channel
    output logic [1:0]     M1_BRESP,
    output logic           M1_BVALID,
    input logic           M1_BREADY,
    // Read Address Channel
    input logic [31:0]    M1_ARADDR,
    input logic [7:0]     M1_ARLEN,
    input logic [2:0]     M1_ARSIZE,
    input logic [1:0]     M1_ARBURST,
    input logic           M1_ARVALID,
    output logic           M1_ARREADY,
    // Read Data Channel
    output logic [31:0]    M1_RDATA,
    output logic [1:0]     M1_RRESP,
    output logic           M1_RLAST,
    output logic           M1_RVALID,
    input logic           M1_RREADY,

    // ========================================================================
    // Slave 0 - FULL Read/Write AXI4 interface
    // ========================================================================
    // Write Address Channel
    output logic [31:0]    S0_AWADDR,
    output logic [7:0]     S0_AWLEN,
    output logic [2:0]     S0_AWSIZE,
    output logic [1:0]     S0_AWBURST,
    output logic           S0_AWVALID,
    input logic           S0_AWREADY,
    // Write Data Channel
    output logic [31:0]    S0_WDATA,
    output logic [3:0]     S0_WSTRB,
    output logic           S0_WLAST,
    output logic           S0_WVALID,
    input logic           S0_WREADY,
    // Write Response Channel
    input logic [1:0]     S0_BRESP,
    input logic           S0_BVALID,
    output logic           S0_BREADY,
    // Read Address Channel
    output logic [31:0]    S0_ARADDR,
    output logic [7:0]     S0_ARLEN,
    output logic [2:0]     S0_ARSIZE,
    output logic [1:0]     S0_ARBURST,
    output logic           S0_ARVALID,
    input logic           S0_ARREADY,
    // Read Data Channel
    input logic [31:0]    S0_RDATA,
    input logic [1:0]     S0_RRESP,
    input logic           S0_RLAST,
    input logic           S0_RVALID,
    output logic           S0_RREADY,

    // ========================================================================
    // Slave 1 - FULL Read/Write AXI4 interface
    // ========================================================================
    // Write Address Channel
    output logic [31:0]    S1_AWADDR,
    output logic [7:0]     S1_AWLEN,
    output logic [2:0]     S1_AWSIZE,
    output logic [1:0]     S1_AWBURST,
    output logic           S1_AWVALID,
    input logic           S1_AWREADY,
    // Write Data Channel
    output logic [31:0]    S1_WDATA,
    output logic [3:0]     S1_WSTRB,
    output logic           S1_WLAST,
    output logic           S1_WVALID,
    input logic           S1_WREADY,
    // Write Response Channel
    input logic [1:0]     S1_BRESP,
    input logic           S1_BVALID,
    output logic           S1_BREADY,
    // Read Address Channel
    output logic [31:0]    S1_ARADDR,
    output logic [7:0]     S1_ARLEN,
    output logic [2:0]     S1_ARSIZE,
    output logic [1:0]     S1_ARBURST,
    output logic           S1_ARVALID,
    input logic           S1_ARREADY,
    // Read Data Channel
    input logic [31:0]    S1_RDATA,
    input logic [1:0]     S1_RRESP,
    input logic           S1_RLAST,
    input logic           S1_RVALID,
    output logic           S1_RREADY,

    // ========================================================================
    // Slave 2 - FULL Read/Write AXI4 interface
    // ========================================================================
    // Write Address Channel
    output logic [31:0]    S2_AWADDR,
    output logic [7:0]     S2_AWLEN,
    output logic [2:0]     S2_AWSIZE,
    output logic [1:0]     S2_AWBURST,
    output logic           S2_AWVALID,
    input logic           S2_AWREADY,
    // Write Data Channel
    output logic [31:0]    S2_WDATA,
    output logic [3:0]     S2_WSTRB,
    output logic           S2_WLAST,
    output logic           S2_WVALID,
    input logic           S2_WREADY,
    // Write Response Channel
    input logic [1:0]     S2_BRESP,
    input logic           S2_BVALID,
    output logic           S2_BREADY,
    // Read Address Channel
    output logic [31:0]    S2_ARADDR,
    output logic [7:0]     S2_ARLEN,
    output logic [2:0]     S2_ARSIZE,
    output logic [1:0]     S2_ARBURST,
    output logic           S2_ARVALID,
    input logic           S2_ARREADY,
    // Read Data Channel
    input logic [31:0]    S2_RDATA,
    input logic [1:0]     S2_RRESP,
    input logic           S2_RLAST,
    input logic           S2_RVALID,
    output logic           S2_RREADY,

    // ========================================================================
    // Slave 3 - FULL Read/Write AXI4 interface
    // ========================================================================
    // Write Address Channel
    output logic [31:0]    S3_AWADDR,
    output logic [7:0]     S3_AWLEN,
    output logic [2:0]     S3_AWSIZE,
    output logic [1:0]     S3_AWBURST,
    output logic           S3_AWVALID,
    input logic           S3_AWREADY,
    // Write Data Channel
    output logic [31:0]    S3_WDATA,
    output logic [3:0]     S3_WSTRB,
    output logic           S3_WLAST,
    output logic           S3_WVALID,
    input logic           S3_WREADY,
    // Write Response Channel
    input logic [1:0]     S3_BRESP,
    input logic           S3_BVALID,
    output logic           S3_BREADY,
    // Read Address Channel
    output logic [31:0]    S3_ARADDR,
    output logic [7:0]     S3_ARLEN,
    output logic [2:0]     S3_ARSIZE,
    output logic [1:0]     S3_ARBURST,
    output logic           S3_ARVALID,
    input logic           S3_ARREADY,
    // Read Data Channel
    input logic [31:0]    S3_RDATA,
    input logic [1:0]     S3_RRESP,
    input logic           S3_RLAST,
    input logic           S3_RVALID,
    output logic           S3_RREADY
);

    // Default values for optional AXI4 signals
    logic [1:0]  default_lock = 2'h0;
    logic [3:0]  default_cache = 4'h0;
    logic [2:0]  default_prot = 3'h0;
    logic [3:0]  default_qos = 4'h0;
    logic [3:0]  default_region = 4'h0;

    // Unused outputs from M02, M03 (not connected in this 2S wrapper)
    logic [0:0]  unused_awaddr_id_m2, unused_awaddr_id_m3;
    logic [31:0] unused_awaddr_m2, unused_awaddr_m3, unused_araddr_m2, unused_araddr_m3;
    logic [7:0]  unused_awlen_m2, unused_awlen_m3, unused_arlen_m2, unused_arlen_m3;
    logic [2:0]  unused_awsize_m2, unused_awsize_m3, unused_arsize_m2, unused_arsize_m3;
    logic [1:0]  unused_awburst_m2, unused_awburst_m3, unused_arburst_m2, unused_arburst_m3;
    logic [1:0]  unused_awlock_m2, unused_awlock_m3;
    logic [3:0]  unused_awcache_m2, unused_awcache_m3, unused_arregion_m2, unused_arregion_m3;
    logic [2:0]  unused_awprot_m2, unused_awprot_m3;
    logic [3:0]  unused_awqos_m2, unused_awqos_m3;
    logic unused_awvalid_m2, unused_awvalid_m3, unused_arvalid_m2, unused_arvalid_m3;
    logic [31:0] unused_wdata_m2, unused_wdata_m3, unused_rdata_m2, unused_rdata_m3;
    logic [3:0]  unused_wstrb_m2, unused_wstrb_m3;
    logic unused_wlast_m2, unused_wlast_m3, unused_rlast_m2, unused_rlast_m3;
    logic unused_wvalid_m2, unused_wvalid_m3, unused_rvalid_m2, unused_rvalid_m3;
    logic [0:0]  unused_bid_m2, unused_bid_m3;
    logic [1:0]  unused_bresp_m2, unused_bresp_m3, unused_rresp_m2, unused_rresp_m3;
    logic unused_bvalid_m2, unused_bvalid_m3;

    // Instantiate AXI_Interconnect_Full with complete port mapping
    AXI_Interconnect_Full #(
        .ARBITRATION_MODE(ARBITRATION_MODE)
    ) u_full_interconnect (
        // Global
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // ==== S00 (Master 0 input) ====
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        // Write Address
        .S00_AXI_awaddr(M0_AWADDR),
        .S00_AXI_awlen(M0_AWLEN),
        .S00_AXI_awsize(M0_AWSIZE),
        .S00_AXI_awburst(M0_AWBURST),
        .S00_AXI_awlock(default_lock),
        .S00_AXI_awcache(default_cache),
        .S00_AXI_awprot(default_prot),
        .S00_AXI_awqos(default_qos),
        .S00_AXI_awvalid(M0_AWVALID),
        .S00_AXI_awready(M0_AWREADY),
        // Write Data
        .S00_AXI_wdata(M0_WDATA),
        .S00_AXI_wstrb(M0_WSTRB),
        .S00_AXI_wlast(M0_WLAST),
        .S00_AXI_wvalid(M0_WVALID),
        .S00_AXI_wready(M0_WREADY),
        // Write Response
        .S00_AXI_bresp(M0_BRESP),
        .S00_AXI_bvalid(M0_BVALID),
        .S00_AXI_bready(M0_BREADY),
        // Read Address
        .S00_AXI_araddr(M0_ARADDR),
        .S00_AXI_arlen(M0_ARLEN),
        .S00_AXI_arsize(M0_ARSIZE),
        .S00_AXI_arburst(M0_ARBURST),
        .S00_AXI_arlock(default_lock),
        .S00_AXI_arcache(default_cache),
        .S00_AXI_arprot(default_prot),
        .S00_AXI_arqos(default_qos),
        .S00_AXI_arvalid(M0_ARVALID),
        .S00_AXI_arready(M0_ARREADY),
        // Read Data
        .S00_AXI_rdata(M0_RDATA),
        .S00_AXI_rresp(M0_RRESP),
        .S00_AXI_rlast(M0_RLAST),
        .S00_AXI_rvalid(M0_RVALID),
        .S00_AXI_rready(M0_RREADY),
        
        // ==== S01 (Master 1 input) ====
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        // Write Address
        .S01_AXI_awaddr(M1_AWADDR),
        .S01_AXI_awlen(M1_AWLEN),
        .S01_AXI_awsize(M1_AWSIZE),
        .S01_AXI_awburst(M1_AWBURST),
        .S01_AXI_awlock(default_lock),
        .S01_AXI_awcache(default_cache),
        .S01_AXI_awprot(default_prot),
        .S01_AXI_awqos(default_qos),
        .S01_AXI_awvalid(M1_AWVALID),
        .S01_AXI_awready(M1_AWREADY),
        // Write Data
        .S01_AXI_wdata(M1_WDATA),
        .S01_AXI_wstrb(M1_WSTRB),
        .S01_AXI_wlast(M1_WLAST),
        .S01_AXI_wvalid(M1_WVALID),
        .S01_AXI_wready(M1_WREADY),
        // Write Response
        .S01_AXI_bresp(M1_BRESP),
        .S01_AXI_bvalid(M1_BVALID),
        .S01_AXI_bready(M1_BREADY),
        // Read Address
        .S01_AXI_araddr(M1_ARADDR),
        .S01_AXI_arlen(M1_ARLEN),
        .S01_AXI_arsize(M1_ARSIZE),
        .S01_AXI_arburst(M1_ARBURST),
        .S01_AXI_arlock(default_lock),
        .S01_AXI_arcache(default_cache),
        .S01_AXI_arprot(default_prot),
        .S01_AXI_arregion(default_region),
        .S01_AXI_arqos(default_qos),
        .S01_AXI_arvalid(M1_ARVALID),
        .S01_AXI_arready(M1_ARREADY),
        // Read Data
        .S01_AXI_rdata(M1_RDATA),
        .S01_AXI_rresp(M1_RRESP),
        .S01_AXI_rlast(M1_RLAST),
        .S01_AXI_rvalid(M1_RVALID),
        .S01_AXI_rready(M1_RREADY),
        
        // ==== M00 (Slave 0 output) ====
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        // Write Address
        .M00_AXI_awaddr_ID(),
        .M00_AXI_awaddr(S0_AWADDR),
        .M00_AXI_awlen(S0_AWLEN),
        .M00_AXI_awsize(S0_AWSIZE),
        .M00_AXI_awburst(S0_AWBURST),
        .M00_AXI_awlock(),
        .M00_AXI_awcache(),
        .M00_AXI_awprot(),
        .M00_AXI_awqos(),
        .M00_AXI_awvalid(S0_AWVALID),
        .M00_AXI_awready(S0_AWREADY),
        // Write Data
        .M00_AXI_wdata(S0_WDATA),
        .M00_AXI_wstrb(S0_WSTRB),
        .M00_AXI_wlast(S0_WLAST),
        .M00_AXI_wvalid(S0_WVALID),
        .M00_AXI_wready(S0_WREADY),
        // Write Response
        .M00_AXI_BID(1'b0),
        .M00_AXI_bresp(S0_BRESP),
        .M00_AXI_bvalid(S0_BVALID),
        .M00_AXI_bready(S0_BREADY),
        // Read Address
        .M00_AXI_araddr(S0_ARADDR),
        .M00_AXI_arlen(S0_ARLEN),
        .M00_AXI_arsize(S0_ARSIZE),
        .M00_AXI_arburst(S0_ARBURST),
        .M00_AXI_arlock(),
        .M00_AXI_arcache(),
        .M00_AXI_arprot(),
        .M00_AXI_arregion(),
        .M00_AXI_arqos(),
        .M00_AXI_arvalid(S0_ARVALID),
        .M00_AXI_arready(S0_ARREADY),
        // Read Data
        .M00_AXI_rdata(S0_RDATA),
        .M00_AXI_rresp(S0_RRESP),
        .M00_AXI_rlast(S0_RLAST),
        .M00_AXI_rvalid(S0_RVALID),
        .M00_AXI_rready(S0_RREADY),
        
        // ==== M01 (Slave 1 output) ====
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        // Write Address
        .M01_AXI_awaddr_ID(),
        .M01_AXI_awaddr(S1_AWADDR),
        .M01_AXI_awlen(S1_AWLEN),
        .M01_AXI_awsize(S1_AWSIZE),
        .M01_AXI_awburst(S1_AWBURST),
        .M01_AXI_awlock(),
        .M01_AXI_awcache(),
        .M01_AXI_awprot(),
        .M01_AXI_awqos(),
        .M01_AXI_awvalid(S1_AWVALID),
        .M01_AXI_awready(S1_AWREADY),
        // Write Data
        .M01_AXI_wdata(S1_WDATA),
        .M01_AXI_wstrb(S1_WSTRB),
        .M01_AXI_wlast(S1_WLAST),
        .M01_AXI_wvalid(S1_WVALID),
        .M01_AXI_wready(S1_WREADY),
        // Write Response
        .M01_AXI_BID(1'b0),
        .M01_AXI_bresp(S1_BRESP),
        .M01_AXI_bvalid(S1_BVALID),
        .M01_AXI_bready(S1_BREADY),
        // Read Address
        .M01_AXI_araddr(S1_ARADDR),
        .M01_AXI_arlen(S1_ARLEN),
        .M01_AXI_arsize(S1_ARSIZE),
        .M01_AXI_arburst(S1_ARBURST),
        .M01_AXI_arlock(),
        .M01_AXI_arcache(),
        .M01_AXI_arprot(),
        .M01_AXI_arregion(),
        .M01_AXI_arqos(),
        .M01_AXI_arvalid(S1_ARVALID),
        .M01_AXI_arready(S1_ARREADY),
        // Read Data
        .M01_AXI_rdata(S1_RDATA),
        .M01_AXI_rresp(S1_RRESP),
        .M01_AXI_rlast(S1_RLAST),
        .M01_AXI_rvalid(S1_RVALID),
        .M01_AXI_rready(S1_RREADY),
        
        // ==== M02 (Slave 2 output) ====
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        // Write Address
        .M02_AXI_awaddr_ID(),
        .M02_AXI_awaddr(S2_AWADDR),
        .M02_AXI_awlen(S2_AWLEN),
        .M02_AXI_awsize(S2_AWSIZE),
        .M02_AXI_awburst(S2_AWBURST),
        .M02_AXI_awlock(),
        .M02_AXI_awcache(),
        .M02_AXI_awprot(),
        .M02_AXI_awqos(),
        .M02_AXI_awvalid(S2_AWVALID),
        .M02_AXI_awready(S2_AWREADY),
        // Write Data
        .M02_AXI_wdata(S2_WDATA),
        .M02_AXI_wstrb(S2_WSTRB),
        .M02_AXI_wlast(S2_WLAST),
        .M02_AXI_wvalid(S2_WVALID),
        .M02_AXI_wready(S2_WREADY),
        // Write Response
        .M02_AXI_BID(1'b0),
        .M02_AXI_bresp(S2_BRESP),
        .M02_AXI_bvalid(S2_BVALID),
        .M02_AXI_bready(S2_BREADY),
        // Read Address
        .M02_AXI_araddr(S2_ARADDR),
        .M02_AXI_arlen(S2_ARLEN),
        .M02_AXI_arsize(S2_ARSIZE),
        .M02_AXI_arburst(S2_ARBURST),
        .M02_AXI_arlock(),
        .M02_AXI_arcache(),
        .M02_AXI_arprot(),
        .M02_AXI_arregion(),
        .M02_AXI_arqos(),
        .M02_AXI_arvalid(S2_ARVALID),
        .M02_AXI_arready(S2_ARREADY),
        // Read Data
        .M02_AXI_rdata(S2_RDATA),
        .M02_AXI_rresp(S2_RRESP),
        .M02_AXI_rlast(S2_RLAST),
        .M02_AXI_rvalid(S2_RVALID),
        .M02_AXI_rready(S2_RREADY),
        
        // ==== M03 (Slave 3 output) ====
        .M03_ACLK(ACLK),
        .M03_ARESETN(ARESETN),
        // Write Address
        .M03_AXI_awaddr_ID(),
        .M03_AXI_awaddr(S3_AWADDR),
        .M03_AXI_awlen(S3_AWLEN),
        .M03_AXI_awsize(S3_AWSIZE),
        .M03_AXI_awburst(S3_AWBURST),
        .M03_AXI_awlock(),
        .M03_AXI_awcache(),
        .M03_AXI_awprot(),
        .M03_AXI_awqos(),
        .M03_AXI_awvalid(S3_AWVALID),
        .M03_AXI_awready(S3_AWREADY),
        // Write Data
        .M03_AXI_wdata(S3_WDATA),
        .M03_AXI_wstrb(S3_WSTRB),
        .M03_AXI_wlast(S3_WLAST),
        .M03_AXI_wvalid(S3_WVALID),
        .M03_AXI_wready(S3_WREADY),
        // Write Response
        .M03_AXI_BID(1'b0),
        .M03_AXI_bresp(S3_BRESP),
        .M03_AXI_bvalid(S3_BVALID),
        .M03_AXI_bready(S3_BREADY),
        // Read Address
        .M03_AXI_araddr(S3_ARADDR),
        .M03_AXI_arlen(S3_ARLEN),
        .M03_AXI_arsize(S3_ARSIZE),
        .M03_AXI_arburst(S3_ARBURST),
        .M03_AXI_arlock(),
        .M03_AXI_arcache(),
        .M03_AXI_arprot(),
        .M03_AXI_arregion(),
        .M03_AXI_arqos(),
        .M03_AXI_arvalid(S3_ARVALID),
        .M03_AXI_arready(S3_ARREADY),
        // Read Data
        .M03_AXI_rdata(S3_RDATA),
        .M03_AXI_rresp(S3_RRESP),
        .M03_AXI_rlast(S3_RLAST),
        .M03_AXI_rvalid(S3_RVALID),
        .M03_AXI_rready(S3_RREADY),
        
        // Address ranges - configurable at instantiation  
        .slave0_addr1(32'h00000000),
        .slave0_addr2(32'h1FFFFFFF),
        .slave1_addr1(32'h40000000),
        .slave1_addr2(32'h5FFFFFFF)
    );

endmodule

