//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
//Date        : Sun Dec 21 14:41:59 2025
//Host        : NGUYEN-HA-HAI running 64-bit major release  (build 9200)
//Command     : generate_target design_1.bd
//Design      : design_1
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=13,numReposBlks=13,numNonXlnxBlks=6,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=Hierarchical}" *) (* HW_HANDOFF = "design_1.hwdef" *) 
module design_1
   ();

  wire [15:0]axi_bram_ctrl_0_BRAM_PORTA_ADDR;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DIN;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DOUT;
  wire axi_bram_ctrl_0_BRAM_PORTA_EN;
  wire axi_bram_ctrl_0_BRAM_PORTA_RST;
  wire [3:0]axi_bram_ctrl_0_BRAM_PORTA_WE;
  wire [31:0]axi_interconnect_0_S0_ARADDR;
  wire [1:0]axi_interconnect_0_S0_ARBURST;
  wire [7:0]axi_interconnect_0_S0_ARLEN;
  wire axi_interconnect_0_S0_ARREADY;
  wire [2:0]axi_interconnect_0_S0_ARSIZE;
  wire axi_interconnect_0_S0_ARVALID;
  wire [31:0]axi_interconnect_0_S0_AWADDR;
  wire [1:0]axi_interconnect_0_S0_AWBURST;
  wire [7:0]axi_interconnect_0_S0_AWLEN;
  wire axi_interconnect_0_S0_AWREADY;
  wire [2:0]axi_interconnect_0_S0_AWSIZE;
  wire axi_interconnect_0_S0_AWVALID;
  wire axi_interconnect_0_S0_BREADY;
  wire [1:0]axi_interconnect_0_S0_BRESP;
  wire axi_interconnect_0_S0_BVALID;
  wire [31:0]axi_interconnect_0_S0_RDATA;
  wire axi_interconnect_0_S0_RLAST;
  wire axi_interconnect_0_S0_RREADY;
  wire [1:0]axi_interconnect_0_S0_RRESP;
  wire axi_interconnect_0_S0_RVALID;
  wire [31:0]axi_interconnect_0_S0_WDATA;
  wire axi_interconnect_0_S0_WLAST;
  wire axi_interconnect_0_S0_WREADY;
  wire [3:0]axi_interconnect_0_S0_WSTRB;
  wire axi_interconnect_0_S0_WVALID;
  wire [31:0]axi_interconnect_0_S1_ARADDR;
  wire [1:0]axi_interconnect_0_S1_ARBURST;
  wire [7:0]axi_interconnect_0_S1_ARLEN;
  wire axi_interconnect_0_S1_ARREADY;
  wire [2:0]axi_interconnect_0_S1_ARSIZE;
  wire axi_interconnect_0_S1_ARVALID;
  wire [31:0]axi_interconnect_0_S1_AWADDR;
  wire [1:0]axi_interconnect_0_S1_AWBURST;
  wire [7:0]axi_interconnect_0_S1_AWLEN;
  wire axi_interconnect_0_S1_AWREADY;
  wire [2:0]axi_interconnect_0_S1_AWSIZE;
  wire axi_interconnect_0_S1_AWVALID;
  wire axi_interconnect_0_S1_BREADY;
  wire [1:0]axi_interconnect_0_S1_BRESP;
  wire axi_interconnect_0_S1_BVALID;
  wire [31:0]axi_interconnect_0_S1_RDATA;
  wire axi_interconnect_0_S1_RLAST;
  wire axi_interconnect_0_S1_RREADY;
  wire [1:0]axi_interconnect_0_S1_RRESP;
  wire axi_interconnect_0_S1_RVALID;
  wire [31:0]axi_interconnect_0_S1_WDATA;
  wire axi_interconnect_0_S1_WLAST;
  wire axi_interconnect_0_S1_WREADY;
  wire [3:0]axi_interconnect_0_S1_WSTRB;
  wire axi_interconnect_0_S1_WVALID;
  wire [31:0]axi_interconnect_0_S2_ARADDR;
  wire [1:0]axi_interconnect_0_S2_ARBURST;
  wire [7:0]axi_interconnect_0_S2_ARLEN;
  wire axi_interconnect_0_S2_ARREADY;
  wire [2:0]axi_interconnect_0_S2_ARSIZE;
  wire axi_interconnect_0_S2_ARVALID;
  wire [31:0]axi_interconnect_0_S2_AWADDR;
  wire [1:0]axi_interconnect_0_S2_AWBURST;
  wire [7:0]axi_interconnect_0_S2_AWLEN;
  wire axi_interconnect_0_S2_AWREADY;
  wire [2:0]axi_interconnect_0_S2_AWSIZE;
  wire axi_interconnect_0_S2_AWVALID;
  wire axi_interconnect_0_S2_BREADY;
  wire [1:0]axi_interconnect_0_S2_BRESP;
  wire axi_interconnect_0_S2_BVALID;
  wire [31:0]axi_interconnect_0_S2_RDATA;
  wire axi_interconnect_0_S2_RLAST;
  wire axi_interconnect_0_S2_RREADY;
  wire [1:0]axi_interconnect_0_S2_RRESP;
  wire axi_interconnect_0_S2_RVALID;
  wire [31:0]axi_interconnect_0_S2_WDATA;
  wire axi_interconnect_0_S2_WLAST;
  wire axi_interconnect_0_S2_WREADY;
  wire [3:0]axi_interconnect_0_S2_WSTRB;
  wire axi_interconnect_0_S2_WVALID;
  wire [31:0]axi_interconnect_0_S3_ARADDR;
  wire [1:0]axi_interconnect_0_S3_ARBURST;
  wire [7:0]axi_interconnect_0_S3_ARLEN;
  wire axi_interconnect_0_S3_ARREADY;
  wire [2:0]axi_interconnect_0_S3_ARSIZE;
  wire axi_interconnect_0_S3_ARVALID;
  wire [31:0]axi_interconnect_0_S3_AWADDR;
  wire [1:0]axi_interconnect_0_S3_AWBURST;
  wire [7:0]axi_interconnect_0_S3_AWLEN;
  wire axi_interconnect_0_S3_AWREADY;
  wire [2:0]axi_interconnect_0_S3_AWSIZE;
  wire axi_interconnect_0_S3_AWVALID;
  wire axi_interconnect_0_S3_BREADY;
  wire [1:0]axi_interconnect_0_S3_BRESP;
  wire axi_interconnect_0_S3_BVALID;
  wire [31:0]axi_interconnect_0_S3_RDATA;
  wire axi_interconnect_0_S3_RLAST;
  wire axi_interconnect_0_S3_RREADY;
  wire [1:0]axi_interconnect_0_S3_RRESP;
  wire axi_interconnect_0_S3_RVALID;
  wire [31:0]axi_interconnect_0_S3_WDATA;
  wire axi_interconnect_0_S3_WLAST;
  wire axi_interconnect_0_S3_WREADY;
  wire [3:0]axi_interconnect_0_S3_WSTRB;
  wire axi_interconnect_0_S3_WVALID;
  wire [31:0]axi_master_bridge_0_m_axi_ARADDR;
  wire [1:0]axi_master_bridge_0_m_axi_ARBURST;
  wire [7:0]axi_master_bridge_0_m_axi_ARLEN;
  wire axi_master_bridge_0_m_axi_ARREADY;
  wire [2:0]axi_master_bridge_0_m_axi_ARSIZE;
  wire axi_master_bridge_0_m_axi_ARVALID;
  wire [31:0]axi_master_bridge_0_m_axi_AWADDR;
  wire [1:0]axi_master_bridge_0_m_axi_AWBURST;
  wire [7:0]axi_master_bridge_0_m_axi_AWLEN;
  wire axi_master_bridge_0_m_axi_AWREADY;
  wire [2:0]axi_master_bridge_0_m_axi_AWSIZE;
  wire axi_master_bridge_0_m_axi_AWVALID;
  wire axi_master_bridge_0_m_axi_BREADY;
  wire [1:0]axi_master_bridge_0_m_axi_BRESP;
  wire axi_master_bridge_0_m_axi_BVALID;
  wire [31:0]axi_master_bridge_0_m_axi_RDATA;
  wire axi_master_bridge_0_m_axi_RLAST;
  wire axi_master_bridge_0_m_axi_RREADY;
  wire [1:0]axi_master_bridge_0_m_axi_RRESP;
  wire axi_master_bridge_0_m_axi_RVALID;
  wire [31:0]axi_master_bridge_0_m_axi_WDATA;
  wire axi_master_bridge_0_m_axi_WLAST;
  wire axi_master_bridge_0_m_axi_WREADY;
  wire [3:0]axi_master_bridge_0_m_axi_WSTRB;
  wire axi_master_bridge_0_m_axi_WVALID;
  wire [31:0]axi_master_bridge_1_m_axi_ARADDR;
  wire [1:0]axi_master_bridge_1_m_axi_ARBURST;
  wire [7:0]axi_master_bridge_1_m_axi_ARLEN;
  wire axi_master_bridge_1_m_axi_ARREADY;
  wire [2:0]axi_master_bridge_1_m_axi_ARSIZE;
  wire axi_master_bridge_1_m_axi_ARVALID;
  wire [31:0]axi_master_bridge_1_m_axi_AWADDR;
  wire [1:0]axi_master_bridge_1_m_axi_AWBURST;
  wire [7:0]axi_master_bridge_1_m_axi_AWLEN;
  wire axi_master_bridge_1_m_axi_AWREADY;
  wire [2:0]axi_master_bridge_1_m_axi_AWSIZE;
  wire axi_master_bridge_1_m_axi_AWVALID;
  wire axi_master_bridge_1_m_axi_BREADY;
  wire [1:0]axi_master_bridge_1_m_axi_BRESP;
  wire axi_master_bridge_1_m_axi_BVALID;
  wire [31:0]axi_master_bridge_1_m_axi_RDATA;
  wire axi_master_bridge_1_m_axi_RLAST;
  wire axi_master_bridge_1_m_axi_RREADY;
  wire [1:0]axi_master_bridge_1_m_axi_RRESP;
  wire axi_master_bridge_1_m_axi_RVALID;
  wire [31:0]axi_master_bridge_1_m_axi_WDATA;
  wire axi_master_bridge_1_m_axi_WLAST;
  wire axi_master_bridge_1_m_axi_WREADY;
  wire [3:0]axi_master_bridge_1_m_axi_WSTRB;
  wire axi_master_bridge_1_m_axi_WVALID;
  wire [31:0]axi_slave_bridge_s1_m_axi_ARADDR;
  wire axi_slave_bridge_s1_m_axi_ARREADY;
  wire axi_slave_bridge_s1_m_axi_ARVALID;
  wire [31:0]axi_slave_bridge_s1_m_axi_AWADDR;
  wire axi_slave_bridge_s1_m_axi_AWREADY;
  wire axi_slave_bridge_s1_m_axi_AWVALID;
  wire axi_slave_bridge_s1_m_axi_BREADY;
  wire [1:0]axi_slave_bridge_s1_m_axi_BRESP;
  wire axi_slave_bridge_s1_m_axi_BVALID;
  wire [31:0]axi_slave_bridge_s1_m_axi_RDATA;
  wire axi_slave_bridge_s1_m_axi_RREADY;
  wire [1:0]axi_slave_bridge_s1_m_axi_RRESP;
  wire axi_slave_bridge_s1_m_axi_RVALID;
  wire [31:0]axi_slave_bridge_s1_m_axi_WDATA;
  wire axi_slave_bridge_s1_m_axi_WREADY;
  wire [3:0]axi_slave_bridge_s1_m_axi_WSTRB;
  wire axi_slave_bridge_s1_m_axi_WVALID;
  wire [31:0]axi_slave_bridge_s2_m_axi_ARADDR;
  wire axi_slave_bridge_s2_m_axi_ARREADY;
  wire axi_slave_bridge_s2_m_axi_ARVALID;
  wire [31:0]axi_slave_bridge_s2_m_axi_AWADDR;
  wire axi_slave_bridge_s2_m_axi_AWREADY;
  wire axi_slave_bridge_s2_m_axi_AWVALID;
  wire axi_slave_bridge_s2_m_axi_BREADY;
  wire [1:0]axi_slave_bridge_s2_m_axi_BRESP;
  wire axi_slave_bridge_s2_m_axi_BVALID;
  wire [31:0]axi_slave_bridge_s2_m_axi_RDATA;
  wire axi_slave_bridge_s2_m_axi_RREADY;
  wire [1:0]axi_slave_bridge_s2_m_axi_RRESP;
  wire axi_slave_bridge_s2_m_axi_RVALID;
  wire [31:0]axi_slave_bridge_s2_m_axi_WDATA;
  wire axi_slave_bridge_s2_m_axi_WREADY;
  wire [3:0]axi_slave_bridge_s2_m_axi_WSTRB;
  wire axi_slave_bridge_s2_m_axi_WVALID;
  wire [31:0]axi_slave_bridge_s3_m_axi_ARADDR;
  wire axi_slave_bridge_s3_m_axi_ARREADY;
  wire axi_slave_bridge_s3_m_axi_ARVALID;
  wire [31:0]axi_slave_bridge_s3_m_axi_AWADDR;
  wire axi_slave_bridge_s3_m_axi_AWREADY;
  wire axi_slave_bridge_s3_m_axi_AWVALID;
  wire axi_slave_bridge_s3_m_axi_BREADY;
  wire [1:0]axi_slave_bridge_s3_m_axi_BRESP;
  wire axi_slave_bridge_s3_m_axi_BVALID;
  wire [31:0]axi_slave_bridge_s3_m_axi_RDATA;
  wire axi_slave_bridge_s3_m_axi_RREADY;
  wire [1:0]axi_slave_bridge_s3_m_axi_RRESP;
  wire axi_slave_bridge_s3_m_axi_RVALID;
  wire [31:0]axi_slave_bridge_s3_m_axi_WDATA;
  wire axi_slave_bridge_s3_m_axi_WREADY;
  wire [3:0]axi_slave_bridge_s3_m_axi_WSTRB;
  wire axi_slave_bridge_s3_m_axi_WVALID;
  wire [0:0]rst_ps8_0_99M_interconnect_aresetn;
  wire [0:0]rst_ps8_0_99M_peripheral_aresetn;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARVALID;
  wire [39:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWADDR;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWBURST;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWCACHE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWID;
  wire [7:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLEN;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLOCK;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWPROT;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWQOS;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWREADY;
  wire [2:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWSIZE;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWUSER;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWVALID;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RDATA;
  wire [15:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RID;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RREADY;
  wire [1:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RRESP;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RVALID;
  wire [31:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WDATA;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WLAST;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WREADY;
  wire [3:0]zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WSTRB;
  wire zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WVALID;
  wire zynq_ultra_ps_e_0_pl_clk0;
  wire zynq_ultra_ps_e_0_pl_resetn0;

  design_1_axi_bram_ctrl_0_0 axi_bram_ctrl_0
       (.bram_addr_a(axi_bram_ctrl_0_BRAM_PORTA_ADDR),
        .bram_en_a(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .bram_rddata_a(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .bram_rst_a(axi_bram_ctrl_0_BRAM_PORTA_RST),
        .bram_we_a(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .bram_wrdata_a(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(axi_interconnect_0_S0_ARADDR[15:0]),
        .s_axi_arburst(axi_interconnect_0_S0_ARBURST),
        .s_axi_arcache({1'b0,1'b0,1'b1,1'b1}),
        .s_axi_aresetn(rst_ps8_0_99M_peripheral_aresetn),
        .s_axi_arlen(axi_interconnect_0_S0_ARLEN),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arready(axi_interconnect_0_S0_ARREADY),
        .s_axi_arsize(axi_interconnect_0_S0_ARSIZE),
        .s_axi_arvalid(axi_interconnect_0_S0_ARVALID),
        .s_axi_awaddr(axi_interconnect_0_S0_AWADDR[15:0]),
        .s_axi_awburst(axi_interconnect_0_S0_AWBURST),
        .s_axi_awcache({1'b0,1'b0,1'b1,1'b1}),
        .s_axi_awlen(axi_interconnect_0_S0_AWLEN),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awready(axi_interconnect_0_S0_AWREADY),
        .s_axi_awsize(axi_interconnect_0_S0_AWSIZE),
        .s_axi_awvalid(axi_interconnect_0_S0_AWVALID),
        .s_axi_bready(axi_interconnect_0_S0_BREADY),
        .s_axi_bresp(axi_interconnect_0_S0_BRESP),
        .s_axi_bvalid(axi_interconnect_0_S0_BVALID),
        .s_axi_rdata(axi_interconnect_0_S0_RDATA),
        .s_axi_rlast(axi_interconnect_0_S0_RLAST),
        .s_axi_rready(axi_interconnect_0_S0_RREADY),
        .s_axi_rresp(axi_interconnect_0_S0_RRESP),
        .s_axi_rvalid(axi_interconnect_0_S0_RVALID),
        .s_axi_wdata(axi_interconnect_0_S0_WDATA),
        .s_axi_wlast(axi_interconnect_0_S0_WLAST),
        .s_axi_wready(axi_interconnect_0_S0_WREADY),
        .s_axi_wstrb(axi_interconnect_0_S0_WSTRB),
        .s_axi_wvalid(axi_interconnect_0_S0_WVALID));
  design_1_axi_gpio_0_0 axi_gpio_0
       (.gpio_io_i({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(axi_slave_bridge_s1_m_axi_ARADDR[8:0]),
        .s_axi_aresetn(rst_ps8_0_99M_peripheral_aresetn),
        .s_axi_arready(axi_slave_bridge_s1_m_axi_ARREADY),
        .s_axi_arvalid(axi_slave_bridge_s1_m_axi_ARVALID),
        .s_axi_awaddr(axi_slave_bridge_s1_m_axi_AWADDR[8:0]),
        .s_axi_awready(axi_slave_bridge_s1_m_axi_AWREADY),
        .s_axi_awvalid(axi_slave_bridge_s1_m_axi_AWVALID),
        .s_axi_bready(axi_slave_bridge_s1_m_axi_BREADY),
        .s_axi_bresp(axi_slave_bridge_s1_m_axi_BRESP),
        .s_axi_bvalid(axi_slave_bridge_s1_m_axi_BVALID),
        .s_axi_rdata(axi_slave_bridge_s1_m_axi_RDATA),
        .s_axi_rready(axi_slave_bridge_s1_m_axi_RREADY),
        .s_axi_rresp(axi_slave_bridge_s1_m_axi_RRESP),
        .s_axi_rvalid(axi_slave_bridge_s1_m_axi_RVALID),
        .s_axi_wdata(axi_slave_bridge_s1_m_axi_WDATA),
        .s_axi_wready(axi_slave_bridge_s1_m_axi_WREADY),
        .s_axi_wstrb(axi_slave_bridge_s1_m_axi_WSTRB),
        .s_axi_wvalid(axi_slave_bridge_s1_m_axi_WVALID));
  design_1_axi_interconnect_0_0 axi_interconnect_0
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_99M_interconnect_aresetn),
        .M0_ARADDR(axi_master_bridge_0_m_axi_ARADDR),
        .M0_ARBURST(axi_master_bridge_0_m_axi_ARBURST),
        .M0_ARLEN(axi_master_bridge_0_m_axi_ARLEN),
        .M0_ARREADY(axi_master_bridge_0_m_axi_ARREADY),
        .M0_ARSIZE(axi_master_bridge_0_m_axi_ARSIZE),
        .M0_ARVALID(axi_master_bridge_0_m_axi_ARVALID),
        .M0_AWADDR(axi_master_bridge_0_m_axi_AWADDR),
        .M0_AWBURST(axi_master_bridge_0_m_axi_AWBURST),
        .M0_AWLEN(axi_master_bridge_0_m_axi_AWLEN),
        .M0_AWREADY(axi_master_bridge_0_m_axi_AWREADY),
        .M0_AWSIZE(axi_master_bridge_0_m_axi_AWSIZE),
        .M0_AWVALID(axi_master_bridge_0_m_axi_AWVALID),
        .M0_BREADY(axi_master_bridge_0_m_axi_BREADY),
        .M0_BRESP(axi_master_bridge_0_m_axi_BRESP),
        .M0_BVALID(axi_master_bridge_0_m_axi_BVALID),
        .M0_RDATA(axi_master_bridge_0_m_axi_RDATA),
        .M0_RLAST(axi_master_bridge_0_m_axi_RLAST),
        .M0_RREADY(axi_master_bridge_0_m_axi_RREADY),
        .M0_RRESP(axi_master_bridge_0_m_axi_RRESP),
        .M0_RVALID(axi_master_bridge_0_m_axi_RVALID),
        .M0_WDATA(axi_master_bridge_0_m_axi_WDATA),
        .M0_WLAST(axi_master_bridge_0_m_axi_WLAST),
        .M0_WREADY(axi_master_bridge_0_m_axi_WREADY),
        .M0_WSTRB(axi_master_bridge_0_m_axi_WSTRB),
        .M0_WVALID(axi_master_bridge_0_m_axi_WVALID),
        .M1_ARADDR(axi_master_bridge_1_m_axi_ARADDR),
        .M1_ARBURST(axi_master_bridge_1_m_axi_ARBURST),
        .M1_ARLEN(axi_master_bridge_1_m_axi_ARLEN),
        .M1_ARREADY(axi_master_bridge_1_m_axi_ARREADY),
        .M1_ARSIZE(axi_master_bridge_1_m_axi_ARSIZE),
        .M1_ARVALID(axi_master_bridge_1_m_axi_ARVALID),
        .M1_AWADDR(axi_master_bridge_1_m_axi_AWADDR),
        .M1_AWBURST(axi_master_bridge_1_m_axi_AWBURST),
        .M1_AWLEN(axi_master_bridge_1_m_axi_AWLEN),
        .M1_AWREADY(axi_master_bridge_1_m_axi_AWREADY),
        .M1_AWSIZE(axi_master_bridge_1_m_axi_AWSIZE),
        .M1_AWVALID(axi_master_bridge_1_m_axi_AWVALID),
        .M1_BREADY(axi_master_bridge_1_m_axi_BREADY),
        .M1_BRESP(axi_master_bridge_1_m_axi_BRESP),
        .M1_BVALID(axi_master_bridge_1_m_axi_BVALID),
        .M1_RDATA(axi_master_bridge_1_m_axi_RDATA),
        .M1_RLAST(axi_master_bridge_1_m_axi_RLAST),
        .M1_RREADY(axi_master_bridge_1_m_axi_RREADY),
        .M1_RRESP(axi_master_bridge_1_m_axi_RRESP),
        .M1_RVALID(axi_master_bridge_1_m_axi_RVALID),
        .M1_WDATA(axi_master_bridge_1_m_axi_WDATA),
        .M1_WLAST(axi_master_bridge_1_m_axi_WLAST),
        .M1_WREADY(axi_master_bridge_1_m_axi_WREADY),
        .M1_WSTRB(axi_master_bridge_1_m_axi_WSTRB),
        .M1_WVALID(axi_master_bridge_1_m_axi_WVALID),
        .S0_ARADDR(axi_interconnect_0_S0_ARADDR),
        .S0_ARBURST(axi_interconnect_0_S0_ARBURST),
        .S0_ARLEN(axi_interconnect_0_S0_ARLEN),
        .S0_ARREADY(axi_interconnect_0_S0_ARREADY),
        .S0_ARSIZE(axi_interconnect_0_S0_ARSIZE),
        .S0_ARVALID(axi_interconnect_0_S0_ARVALID),
        .S0_AWADDR(axi_interconnect_0_S0_AWADDR),
        .S0_AWBURST(axi_interconnect_0_S0_AWBURST),
        .S0_AWLEN(axi_interconnect_0_S0_AWLEN),
        .S0_AWREADY(axi_interconnect_0_S0_AWREADY),
        .S0_AWSIZE(axi_interconnect_0_S0_AWSIZE),
        .S0_AWVALID(axi_interconnect_0_S0_AWVALID),
        .S0_BREADY(axi_interconnect_0_S0_BREADY),
        .S0_BRESP(axi_interconnect_0_S0_BRESP),
        .S0_BVALID(axi_interconnect_0_S0_BVALID),
        .S0_RDATA(axi_interconnect_0_S0_RDATA),
        .S0_RLAST(axi_interconnect_0_S0_RLAST),
        .S0_RREADY(axi_interconnect_0_S0_RREADY),
        .S0_RRESP(axi_interconnect_0_S0_RRESP),
        .S0_RVALID(axi_interconnect_0_S0_RVALID),
        .S0_WDATA(axi_interconnect_0_S0_WDATA),
        .S0_WLAST(axi_interconnect_0_S0_WLAST),
        .S0_WREADY(axi_interconnect_0_S0_WREADY),
        .S0_WSTRB(axi_interconnect_0_S0_WSTRB),
        .S0_WVALID(axi_interconnect_0_S0_WVALID),
        .S1_ARADDR(axi_interconnect_0_S1_ARADDR),
        .S1_ARBURST(axi_interconnect_0_S1_ARBURST),
        .S1_ARLEN(axi_interconnect_0_S1_ARLEN),
        .S1_ARREADY(axi_interconnect_0_S1_ARREADY),
        .S1_ARSIZE(axi_interconnect_0_S1_ARSIZE),
        .S1_ARVALID(axi_interconnect_0_S1_ARVALID),
        .S1_AWADDR(axi_interconnect_0_S1_AWADDR),
        .S1_AWBURST(axi_interconnect_0_S1_AWBURST),
        .S1_AWLEN(axi_interconnect_0_S1_AWLEN),
        .S1_AWREADY(axi_interconnect_0_S1_AWREADY),
        .S1_AWSIZE(axi_interconnect_0_S1_AWSIZE),
        .S1_AWVALID(axi_interconnect_0_S1_AWVALID),
        .S1_BREADY(axi_interconnect_0_S1_BREADY),
        .S1_BRESP(axi_interconnect_0_S1_BRESP),
        .S1_BVALID(axi_interconnect_0_S1_BVALID),
        .S1_RDATA(axi_interconnect_0_S1_RDATA),
        .S1_RLAST(axi_interconnect_0_S1_RLAST),
        .S1_RREADY(axi_interconnect_0_S1_RREADY),
        .S1_RRESP(axi_interconnect_0_S1_RRESP),
        .S1_RVALID(axi_interconnect_0_S1_RVALID),
        .S1_WDATA(axi_interconnect_0_S1_WDATA),
        .S1_WLAST(axi_interconnect_0_S1_WLAST),
        .S1_WREADY(axi_interconnect_0_S1_WREADY),
        .S1_WSTRB(axi_interconnect_0_S1_WSTRB),
        .S1_WVALID(axi_interconnect_0_S1_WVALID),
        .S2_ARADDR(axi_interconnect_0_S2_ARADDR),
        .S2_ARBURST(axi_interconnect_0_S2_ARBURST),
        .S2_ARLEN(axi_interconnect_0_S2_ARLEN),
        .S2_ARREADY(axi_interconnect_0_S2_ARREADY),
        .S2_ARSIZE(axi_interconnect_0_S2_ARSIZE),
        .S2_ARVALID(axi_interconnect_0_S2_ARVALID),
        .S2_AWADDR(axi_interconnect_0_S2_AWADDR),
        .S2_AWBURST(axi_interconnect_0_S2_AWBURST),
        .S2_AWLEN(axi_interconnect_0_S2_AWLEN),
        .S2_AWREADY(axi_interconnect_0_S2_AWREADY),
        .S2_AWSIZE(axi_interconnect_0_S2_AWSIZE),
        .S2_AWVALID(axi_interconnect_0_S2_AWVALID),
        .S2_BREADY(axi_interconnect_0_S2_BREADY),
        .S2_BRESP(axi_interconnect_0_S2_BRESP),
        .S2_BVALID(axi_interconnect_0_S2_BVALID),
        .S2_RDATA(axi_interconnect_0_S2_RDATA),
        .S2_RLAST(axi_interconnect_0_S2_RLAST),
        .S2_RREADY(axi_interconnect_0_S2_RREADY),
        .S2_RRESP(axi_interconnect_0_S2_RRESP),
        .S2_RVALID(axi_interconnect_0_S2_RVALID),
        .S2_WDATA(axi_interconnect_0_S2_WDATA),
        .S2_WLAST(axi_interconnect_0_S2_WLAST),
        .S2_WREADY(axi_interconnect_0_S2_WREADY),
        .S2_WSTRB(axi_interconnect_0_S2_WSTRB),
        .S2_WVALID(axi_interconnect_0_S2_WVALID),
        .S3_ARADDR(axi_interconnect_0_S3_ARADDR),
        .S3_ARBURST(axi_interconnect_0_S3_ARBURST),
        .S3_ARLEN(axi_interconnect_0_S3_ARLEN),
        .S3_ARREADY(axi_interconnect_0_S3_ARREADY),
        .S3_ARSIZE(axi_interconnect_0_S3_ARSIZE),
        .S3_ARVALID(axi_interconnect_0_S3_ARVALID),
        .S3_AWADDR(axi_interconnect_0_S3_AWADDR),
        .S3_AWBURST(axi_interconnect_0_S3_AWBURST),
        .S3_AWLEN(axi_interconnect_0_S3_AWLEN),
        .S3_AWREADY(axi_interconnect_0_S3_AWREADY),
        .S3_AWSIZE(axi_interconnect_0_S3_AWSIZE),
        .S3_AWVALID(axi_interconnect_0_S3_AWVALID),
        .S3_BREADY(axi_interconnect_0_S3_BREADY),
        .S3_BRESP(axi_interconnect_0_S3_BRESP),
        .S3_BVALID(axi_interconnect_0_S3_BVALID),
        .S3_RDATA(axi_interconnect_0_S3_RDATA),
        .S3_RLAST(axi_interconnect_0_S3_RLAST),
        .S3_RREADY(axi_interconnect_0_S3_RREADY),
        .S3_RRESP(axi_interconnect_0_S3_RRESP),
        .S3_RVALID(axi_interconnect_0_S3_RVALID),
        .S3_WDATA(axi_interconnect_0_S3_WDATA),
        .S3_WLAST(axi_interconnect_0_S3_WLAST),
        .S3_WREADY(axi_interconnect_0_S3_WREADY),
        .S3_WSTRB(axi_interconnect_0_S3_WSTRB),
        .S3_WVALID(axi_interconnect_0_S3_WVALID));
  design_1_axi_master_bridge_0_0 axi_master_bridge_0
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_99M_peripheral_aresetn),
        .m_axi_araddr(axi_master_bridge_0_m_axi_ARADDR),
        .m_axi_arburst(axi_master_bridge_0_m_axi_ARBURST),
        .m_axi_arlen(axi_master_bridge_0_m_axi_ARLEN),
        .m_axi_arready(axi_master_bridge_0_m_axi_ARREADY),
        .m_axi_arsize(axi_master_bridge_0_m_axi_ARSIZE),
        .m_axi_arvalid(axi_master_bridge_0_m_axi_ARVALID),
        .m_axi_awaddr(axi_master_bridge_0_m_axi_AWADDR),
        .m_axi_awburst(axi_master_bridge_0_m_axi_AWBURST),
        .m_axi_awlen(axi_master_bridge_0_m_axi_AWLEN),
        .m_axi_awready(axi_master_bridge_0_m_axi_AWREADY),
        .m_axi_awsize(axi_master_bridge_0_m_axi_AWSIZE),
        .m_axi_awvalid(axi_master_bridge_0_m_axi_AWVALID),
        .m_axi_bready(axi_master_bridge_0_m_axi_BREADY),
        .m_axi_bresp(axi_master_bridge_0_m_axi_BRESP),
        .m_axi_bvalid(axi_master_bridge_0_m_axi_BVALID),
        .m_axi_rdata(axi_master_bridge_0_m_axi_RDATA),
        .m_axi_rlast(axi_master_bridge_0_m_axi_RLAST),
        .m_axi_rready(axi_master_bridge_0_m_axi_RREADY),
        .m_axi_rresp(axi_master_bridge_0_m_axi_RRESP),
        .m_axi_rvalid(axi_master_bridge_0_m_axi_RVALID),
        .m_axi_wdata(axi_master_bridge_0_m_axi_WDATA),
        .m_axi_wlast(axi_master_bridge_0_m_axi_WLAST),
        .m_axi_wready(axi_master_bridge_0_m_axi_WREADY),
        .m_axi_wstrb(axi_master_bridge_0_m_axi_WSTRB),
        .m_axi_wvalid(axi_master_bridge_0_m_axi_WVALID),
        .s_axi_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR[31:0]),
        .s_axi_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .s_axi_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .s_axi_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .s_axi_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .s_axi_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .s_axi_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .s_axi_arqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS),
        .s_axi_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .s_axi_aruser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER),
        .s_axi_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .s_axi_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR[31:0]),
        .s_axi_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .s_axi_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .s_axi_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .s_axi_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .s_axi_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .s_axi_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .s_axi_awqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS),
        .s_axi_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .s_axi_awuser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER),
        .s_axi_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .s_axi_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .s_axi_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .s_axi_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .s_axi_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .s_axi_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .s_axi_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .s_axi_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .s_axi_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .s_axi_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .s_axi_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .s_axi_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .s_axi_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .s_axi_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .s_axi_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .s_axi_wuser({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID));
  design_1_axi_master_bridge_1_0 axi_master_bridge_1
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_99M_peripheral_aresetn),
        .m_axi_araddr(axi_master_bridge_1_m_axi_ARADDR),
        .m_axi_arburst(axi_master_bridge_1_m_axi_ARBURST),
        .m_axi_arlen(axi_master_bridge_1_m_axi_ARLEN),
        .m_axi_arready(axi_master_bridge_1_m_axi_ARREADY),
        .m_axi_arsize(axi_master_bridge_1_m_axi_ARSIZE),
        .m_axi_arvalid(axi_master_bridge_1_m_axi_ARVALID),
        .m_axi_awaddr(axi_master_bridge_1_m_axi_AWADDR),
        .m_axi_awburst(axi_master_bridge_1_m_axi_AWBURST),
        .m_axi_awlen(axi_master_bridge_1_m_axi_AWLEN),
        .m_axi_awready(axi_master_bridge_1_m_axi_AWREADY),
        .m_axi_awsize(axi_master_bridge_1_m_axi_AWSIZE),
        .m_axi_awvalid(axi_master_bridge_1_m_axi_AWVALID),
        .m_axi_bready(axi_master_bridge_1_m_axi_BREADY),
        .m_axi_bresp(axi_master_bridge_1_m_axi_BRESP),
        .m_axi_bvalid(axi_master_bridge_1_m_axi_BVALID),
        .m_axi_rdata(axi_master_bridge_1_m_axi_RDATA),
        .m_axi_rlast(axi_master_bridge_1_m_axi_RLAST),
        .m_axi_rready(axi_master_bridge_1_m_axi_RREADY),
        .m_axi_rresp(axi_master_bridge_1_m_axi_RRESP),
        .m_axi_rvalid(axi_master_bridge_1_m_axi_RVALID),
        .m_axi_wdata(axi_master_bridge_1_m_axi_WDATA),
        .m_axi_wlast(axi_master_bridge_1_m_axi_WLAST),
        .m_axi_wready(axi_master_bridge_1_m_axi_WREADY),
        .m_axi_wstrb(axi_master_bridge_1_m_axi_WSTRB),
        .m_axi_wvalid(axi_master_bridge_1_m_axi_WVALID),
        .s_axi_araddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARADDR[31:0]),
        .s_axi_arburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARBURST),
        .s_axi_arcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARCACHE),
        .s_axi_arid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARID),
        .s_axi_arlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLEN),
        .s_axi_arlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLOCK),
        .s_axi_arprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARPROT),
        .s_axi_arqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARQOS),
        .s_axi_arready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARREADY),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARSIZE),
        .s_axi_aruser(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARUSER),
        .s_axi_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARVALID),
        .s_axi_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWADDR[31:0]),
        .s_axi_awburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWBURST),
        .s_axi_awcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWCACHE),
        .s_axi_awid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWID),
        .s_axi_awlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLEN),
        .s_axi_awlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLOCK),
        .s_axi_awprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWPROT),
        .s_axi_awqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWQOS),
        .s_axi_awready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWREADY),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWSIZE),
        .s_axi_awuser(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWUSER),
        .s_axi_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWVALID),
        .s_axi_bid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BID),
        .s_axi_bready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BREADY),
        .s_axi_bresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BRESP),
        .s_axi_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BVALID),
        .s_axi_rdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RDATA),
        .s_axi_rid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RID),
        .s_axi_rlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RLAST),
        .s_axi_rready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RREADY),
        .s_axi_rresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RRESP),
        .s_axi_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RVALID),
        .s_axi_wdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WDATA),
        .s_axi_wlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WLAST),
        .s_axi_wready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WREADY),
        .s_axi_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WSTRB),
        .s_axi_wuser({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WVALID));
  design_1_axi_quad_spi_0_0 axi_quad_spi_0
       (.ext_spi_clk(zynq_ultra_ps_e_0_pl_clk0),
        .io0_i(1'b0),
        .io1_i(1'b0),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(axi_slave_bridge_s3_m_axi_ARADDR[6:0]),
        .s_axi_aresetn(rst_ps8_0_99M_peripheral_aresetn),
        .s_axi_arready(axi_slave_bridge_s3_m_axi_ARREADY),
        .s_axi_arvalid(axi_slave_bridge_s3_m_axi_ARVALID),
        .s_axi_awaddr(axi_slave_bridge_s3_m_axi_AWADDR[6:0]),
        .s_axi_awready(axi_slave_bridge_s3_m_axi_AWREADY),
        .s_axi_awvalid(axi_slave_bridge_s3_m_axi_AWVALID),
        .s_axi_bready(axi_slave_bridge_s3_m_axi_BREADY),
        .s_axi_bresp(axi_slave_bridge_s3_m_axi_BRESP),
        .s_axi_bvalid(axi_slave_bridge_s3_m_axi_BVALID),
        .s_axi_rdata(axi_slave_bridge_s3_m_axi_RDATA),
        .s_axi_rready(axi_slave_bridge_s3_m_axi_RREADY),
        .s_axi_rresp(axi_slave_bridge_s3_m_axi_RRESP),
        .s_axi_rvalid(axi_slave_bridge_s3_m_axi_RVALID),
        .s_axi_wdata(axi_slave_bridge_s3_m_axi_WDATA),
        .s_axi_wready(axi_slave_bridge_s3_m_axi_WREADY),
        .s_axi_wstrb(axi_slave_bridge_s3_m_axi_WSTRB),
        .s_axi_wvalid(axi_slave_bridge_s3_m_axi_WVALID),
        .sck_i(1'b0),
        .ss_i(1'b0));
  design_1_axi_slave_bridge_s1_0 axi_slave_bridge_s1
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_99M_peripheral_aresetn),
        .m_axi_araddr(axi_slave_bridge_s1_m_axi_ARADDR),
        .m_axi_arready(axi_slave_bridge_s1_m_axi_ARREADY),
        .m_axi_arvalid(axi_slave_bridge_s1_m_axi_ARVALID),
        .m_axi_awaddr(axi_slave_bridge_s1_m_axi_AWADDR),
        .m_axi_awready(axi_slave_bridge_s1_m_axi_AWREADY),
        .m_axi_awvalid(axi_slave_bridge_s1_m_axi_AWVALID),
        .m_axi_bready(axi_slave_bridge_s1_m_axi_BREADY),
        .m_axi_bresp(axi_slave_bridge_s1_m_axi_BRESP),
        .m_axi_bvalid(axi_slave_bridge_s1_m_axi_BVALID),
        .m_axi_rdata(axi_slave_bridge_s1_m_axi_RDATA),
        .m_axi_rready(axi_slave_bridge_s1_m_axi_RREADY),
        .m_axi_rresp(axi_slave_bridge_s1_m_axi_RRESP),
        .m_axi_rvalid(axi_slave_bridge_s1_m_axi_RVALID),
        .m_axi_wdata(axi_slave_bridge_s1_m_axi_WDATA),
        .m_axi_wready(axi_slave_bridge_s1_m_axi_WREADY),
        .m_axi_wstrb(axi_slave_bridge_s1_m_axi_WSTRB),
        .m_axi_wvalid(axi_slave_bridge_s1_m_axi_WVALID),
        .s_axi_araddr(axi_interconnect_0_S1_ARADDR),
        .s_axi_arburst(axi_interconnect_0_S1_ARBURST),
        .s_axi_arlen(axi_interconnect_0_S1_ARLEN),
        .s_axi_arready(axi_interconnect_0_S1_ARREADY),
        .s_axi_arsize(axi_interconnect_0_S1_ARSIZE),
        .s_axi_arvalid(axi_interconnect_0_S1_ARVALID),
        .s_axi_awaddr(axi_interconnect_0_S1_AWADDR),
        .s_axi_awburst(axi_interconnect_0_S1_AWBURST),
        .s_axi_awlen(axi_interconnect_0_S1_AWLEN),
        .s_axi_awready(axi_interconnect_0_S1_AWREADY),
        .s_axi_awsize(axi_interconnect_0_S1_AWSIZE),
        .s_axi_awvalid(axi_interconnect_0_S1_AWVALID),
        .s_axi_bready(axi_interconnect_0_S1_BREADY),
        .s_axi_bresp(axi_interconnect_0_S1_BRESP),
        .s_axi_bvalid(axi_interconnect_0_S1_BVALID),
        .s_axi_rdata(axi_interconnect_0_S1_RDATA),
        .s_axi_rlast(axi_interconnect_0_S1_RLAST),
        .s_axi_rready(axi_interconnect_0_S1_RREADY),
        .s_axi_rresp(axi_interconnect_0_S1_RRESP),
        .s_axi_rvalid(axi_interconnect_0_S1_RVALID),
        .s_axi_wdata(axi_interconnect_0_S1_WDATA),
        .s_axi_wlast(axi_interconnect_0_S1_WLAST),
        .s_axi_wready(axi_interconnect_0_S1_WREADY),
        .s_axi_wstrb(axi_interconnect_0_S1_WSTRB),
        .s_axi_wvalid(axi_interconnect_0_S1_WVALID));
  design_1_axi_slave_bridge_s2_0 axi_slave_bridge_s2
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_99M_peripheral_aresetn),
        .m_axi_araddr(axi_slave_bridge_s2_m_axi_ARADDR),
        .m_axi_arready(axi_slave_bridge_s2_m_axi_ARREADY),
        .m_axi_arvalid(axi_slave_bridge_s2_m_axi_ARVALID),
        .m_axi_awaddr(axi_slave_bridge_s2_m_axi_AWADDR),
        .m_axi_awready(axi_slave_bridge_s2_m_axi_AWREADY),
        .m_axi_awvalid(axi_slave_bridge_s2_m_axi_AWVALID),
        .m_axi_bready(axi_slave_bridge_s2_m_axi_BREADY),
        .m_axi_bresp(axi_slave_bridge_s2_m_axi_BRESP),
        .m_axi_bvalid(axi_slave_bridge_s2_m_axi_BVALID),
        .m_axi_rdata(axi_slave_bridge_s2_m_axi_RDATA),
        .m_axi_rready(axi_slave_bridge_s2_m_axi_RREADY),
        .m_axi_rresp(axi_slave_bridge_s2_m_axi_RRESP),
        .m_axi_rvalid(axi_slave_bridge_s2_m_axi_RVALID),
        .m_axi_wdata(axi_slave_bridge_s2_m_axi_WDATA),
        .m_axi_wready(axi_slave_bridge_s2_m_axi_WREADY),
        .m_axi_wstrb(axi_slave_bridge_s2_m_axi_WSTRB),
        .m_axi_wvalid(axi_slave_bridge_s2_m_axi_WVALID),
        .s_axi_araddr(axi_interconnect_0_S2_ARADDR),
        .s_axi_arburst(axi_interconnect_0_S2_ARBURST),
        .s_axi_arlen(axi_interconnect_0_S2_ARLEN),
        .s_axi_arready(axi_interconnect_0_S2_ARREADY),
        .s_axi_arsize(axi_interconnect_0_S2_ARSIZE),
        .s_axi_arvalid(axi_interconnect_0_S2_ARVALID),
        .s_axi_awaddr(axi_interconnect_0_S2_AWADDR),
        .s_axi_awburst(axi_interconnect_0_S2_AWBURST),
        .s_axi_awlen(axi_interconnect_0_S2_AWLEN),
        .s_axi_awready(axi_interconnect_0_S2_AWREADY),
        .s_axi_awsize(axi_interconnect_0_S2_AWSIZE),
        .s_axi_awvalid(axi_interconnect_0_S2_AWVALID),
        .s_axi_bready(axi_interconnect_0_S2_BREADY),
        .s_axi_bresp(axi_interconnect_0_S2_BRESP),
        .s_axi_bvalid(axi_interconnect_0_S2_BVALID),
        .s_axi_rdata(axi_interconnect_0_S2_RDATA),
        .s_axi_rlast(axi_interconnect_0_S2_RLAST),
        .s_axi_rready(axi_interconnect_0_S2_RREADY),
        .s_axi_rresp(axi_interconnect_0_S2_RRESP),
        .s_axi_rvalid(axi_interconnect_0_S2_RVALID),
        .s_axi_wdata(axi_interconnect_0_S2_WDATA),
        .s_axi_wlast(axi_interconnect_0_S2_WLAST),
        .s_axi_wready(axi_interconnect_0_S2_WREADY),
        .s_axi_wstrb(axi_interconnect_0_S2_WSTRB),
        .s_axi_wvalid(axi_interconnect_0_S2_WVALID));
  design_1_axi_slave_bridge_s3_0 axi_slave_bridge_s3
       (.ACLK(zynq_ultra_ps_e_0_pl_clk0),
        .ARESETN(rst_ps8_0_99M_peripheral_aresetn),
        .m_axi_araddr(axi_slave_bridge_s3_m_axi_ARADDR),
        .m_axi_arready(axi_slave_bridge_s3_m_axi_ARREADY),
        .m_axi_arvalid(axi_slave_bridge_s3_m_axi_ARVALID),
        .m_axi_awaddr(axi_slave_bridge_s3_m_axi_AWADDR),
        .m_axi_awready(axi_slave_bridge_s3_m_axi_AWREADY),
        .m_axi_awvalid(axi_slave_bridge_s3_m_axi_AWVALID),
        .m_axi_bready(axi_slave_bridge_s3_m_axi_BREADY),
        .m_axi_bresp(axi_slave_bridge_s3_m_axi_BRESP),
        .m_axi_bvalid(axi_slave_bridge_s3_m_axi_BVALID),
        .m_axi_rdata(axi_slave_bridge_s3_m_axi_RDATA),
        .m_axi_rready(axi_slave_bridge_s3_m_axi_RREADY),
        .m_axi_rresp(axi_slave_bridge_s3_m_axi_RRESP),
        .m_axi_rvalid(axi_slave_bridge_s3_m_axi_RVALID),
        .m_axi_wdata(axi_slave_bridge_s3_m_axi_WDATA),
        .m_axi_wready(axi_slave_bridge_s3_m_axi_WREADY),
        .m_axi_wstrb(axi_slave_bridge_s3_m_axi_WSTRB),
        .m_axi_wvalid(axi_slave_bridge_s3_m_axi_WVALID),
        .s_axi_araddr(axi_interconnect_0_S3_ARADDR),
        .s_axi_arburst(axi_interconnect_0_S3_ARBURST),
        .s_axi_arlen(axi_interconnect_0_S3_ARLEN),
        .s_axi_arready(axi_interconnect_0_S3_ARREADY),
        .s_axi_arsize(axi_interconnect_0_S3_ARSIZE),
        .s_axi_arvalid(axi_interconnect_0_S3_ARVALID),
        .s_axi_awaddr(axi_interconnect_0_S3_AWADDR),
        .s_axi_awburst(axi_interconnect_0_S3_AWBURST),
        .s_axi_awlen(axi_interconnect_0_S3_AWLEN),
        .s_axi_awready(axi_interconnect_0_S3_AWREADY),
        .s_axi_awsize(axi_interconnect_0_S3_AWSIZE),
        .s_axi_awvalid(axi_interconnect_0_S3_AWVALID),
        .s_axi_bready(axi_interconnect_0_S3_BREADY),
        .s_axi_bresp(axi_interconnect_0_S3_BRESP),
        .s_axi_bvalid(axi_interconnect_0_S3_BVALID),
        .s_axi_rdata(axi_interconnect_0_S3_RDATA),
        .s_axi_rlast(axi_interconnect_0_S3_RLAST),
        .s_axi_rready(axi_interconnect_0_S3_RREADY),
        .s_axi_rresp(axi_interconnect_0_S3_RRESP),
        .s_axi_rvalid(axi_interconnect_0_S3_RVALID),
        .s_axi_wdata(axi_interconnect_0_S3_WDATA),
        .s_axi_wlast(axi_interconnect_0_S3_WLAST),
        .s_axi_wready(axi_interconnect_0_S3_WREADY),
        .s_axi_wstrb(axi_interconnect_0_S3_WSTRB),
        .s_axi_wvalid(axi_interconnect_0_S3_WVALID));
  design_1_axi_uartlite_0_0 axi_uartlite_0
       (.rx(1'b0),
        .s_axi_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .s_axi_araddr(axi_slave_bridge_s2_m_axi_ARADDR[3:0]),
        .s_axi_aresetn(rst_ps8_0_99M_peripheral_aresetn),
        .s_axi_arready(axi_slave_bridge_s2_m_axi_ARREADY),
        .s_axi_arvalid(axi_slave_bridge_s2_m_axi_ARVALID),
        .s_axi_awaddr(axi_slave_bridge_s2_m_axi_AWADDR[3:0]),
        .s_axi_awready(axi_slave_bridge_s2_m_axi_AWREADY),
        .s_axi_awvalid(axi_slave_bridge_s2_m_axi_AWVALID),
        .s_axi_bready(axi_slave_bridge_s2_m_axi_BREADY),
        .s_axi_bresp(axi_slave_bridge_s2_m_axi_BRESP),
        .s_axi_bvalid(axi_slave_bridge_s2_m_axi_BVALID),
        .s_axi_rdata(axi_slave_bridge_s2_m_axi_RDATA),
        .s_axi_rready(axi_slave_bridge_s2_m_axi_RREADY),
        .s_axi_rresp(axi_slave_bridge_s2_m_axi_RRESP),
        .s_axi_rvalid(axi_slave_bridge_s2_m_axi_RVALID),
        .s_axi_wdata(axi_slave_bridge_s2_m_axi_WDATA),
        .s_axi_wready(axi_slave_bridge_s2_m_axi_WREADY),
        .s_axi_wstrb(axi_slave_bridge_s2_m_axi_WSTRB),
        .s_axi_wvalid(axi_slave_bridge_s2_m_axi_WVALID));
  design_1_blk_mem_gen_0_0 blk_mem_gen_0
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axi_bram_ctrl_0_BRAM_PORTA_ADDR}),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(zynq_ultra_ps_e_0_pl_clk0),
        .clkb(zynq_ultra_ps_e_0_pl_clk0),
        .dina(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b1,1'b0,1'b0,1'b0}),
        .douta(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .ena(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .enb(1'b0),
        .rsta(axi_bram_ctrl_0_BRAM_PORTA_RST),
        .rstb(1'b0),
        .wea(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .web({1'b0,1'b0,1'b0,1'b0}));
  design_1_rst_ps8_0_99M_0 rst_ps8_0_99M
       (.aux_reset_in(1'b1),
        .dcm_locked(1'b1),
        .ext_reset_in(zynq_ultra_ps_e_0_pl_resetn0),
        .interconnect_aresetn(rst_ps8_0_99M_interconnect_aresetn),
        .mb_debug_sys_rst(1'b0),
        .peripheral_aresetn(rst_ps8_0_99M_peripheral_aresetn),
        .slowest_sync_clk(zynq_ultra_ps_e_0_pl_clk0));
  design_1_zynq_ultra_ps_e_0_0 zynq_ultra_ps_e_0
       (.maxigp0_araddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARADDR),
        .maxigp0_arburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARBURST),
        .maxigp0_arcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARCACHE),
        .maxigp0_arid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARID),
        .maxigp0_arlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLEN),
        .maxigp0_arlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARLOCK),
        .maxigp0_arprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARPROT),
        .maxigp0_arqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARQOS),
        .maxigp0_arready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARREADY),
        .maxigp0_arsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARSIZE),
        .maxigp0_aruser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARUSER),
        .maxigp0_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_ARVALID),
        .maxigp0_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWADDR),
        .maxigp0_awburst(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWBURST),
        .maxigp0_awcache(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWCACHE),
        .maxigp0_awid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWID),
        .maxigp0_awlen(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLEN),
        .maxigp0_awlock(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWLOCK),
        .maxigp0_awprot(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWPROT),
        .maxigp0_awqos(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWQOS),
        .maxigp0_awready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWREADY),
        .maxigp0_awsize(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWSIZE),
        .maxigp0_awuser(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWUSER),
        .maxigp0_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_AWVALID),
        .maxigp0_bid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BID),
        .maxigp0_bready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BREADY),
        .maxigp0_bresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BRESP),
        .maxigp0_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_BVALID),
        .maxigp0_rdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RDATA),
        .maxigp0_rid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RID),
        .maxigp0_rlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RLAST),
        .maxigp0_rready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RREADY),
        .maxigp0_rresp(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RRESP),
        .maxigp0_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_RVALID),
        .maxigp0_wdata(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WDATA),
        .maxigp0_wlast(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WLAST),
        .maxigp0_wready(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WREADY),
        .maxigp0_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WSTRB),
        .maxigp0_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM0_FPD_WVALID),
        .maxigp1_araddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARADDR),
        .maxigp1_arburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARBURST),
        .maxigp1_arcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARCACHE),
        .maxigp1_arid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARID),
        .maxigp1_arlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLEN),
        .maxigp1_arlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARLOCK),
        .maxigp1_arprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARPROT),
        .maxigp1_arqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARQOS),
        .maxigp1_arready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARREADY),
        .maxigp1_arsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARSIZE),
        .maxigp1_aruser(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARUSER),
        .maxigp1_arvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_ARVALID),
        .maxigp1_awaddr(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWADDR),
        .maxigp1_awburst(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWBURST),
        .maxigp1_awcache(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWCACHE),
        .maxigp1_awid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWID),
        .maxigp1_awlen(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLEN),
        .maxigp1_awlock(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWLOCK),
        .maxigp1_awprot(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWPROT),
        .maxigp1_awqos(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWQOS),
        .maxigp1_awready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWREADY),
        .maxigp1_awsize(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWSIZE),
        .maxigp1_awuser(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWUSER),
        .maxigp1_awvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_AWVALID),
        .maxigp1_bid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BID),
        .maxigp1_bready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BREADY),
        .maxigp1_bresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BRESP),
        .maxigp1_bvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_BVALID),
        .maxigp1_rdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RDATA),
        .maxigp1_rid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RID),
        .maxigp1_rlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RLAST),
        .maxigp1_rready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RREADY),
        .maxigp1_rresp(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RRESP),
        .maxigp1_rvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_RVALID),
        .maxigp1_wdata(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WDATA),
        .maxigp1_wlast(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WLAST),
        .maxigp1_wready(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WREADY),
        .maxigp1_wstrb(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WSTRB),
        .maxigp1_wvalid(zynq_ultra_ps_e_0_M_AXI_HPM1_FPD_WVALID),
        .maxihpm0_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .maxihpm1_fpd_aclk(zynq_ultra_ps_e_0_pl_clk0),
        .pl_clk0(zynq_ultra_ps_e_0_pl_clk0),
        .pl_resetn0(zynq_ultra_ps_e_0_pl_resetn0));
endmodule
