// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Dec 20 09:47:18 2025
// Host        : NGUYEN-HA-HAI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_1_axi_interconnect_0_0_stub.v
// Design      : design_1_axi_interconnect_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu5ev-sfvc784-1-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* CHECK_LICENSE_TYPE = "design_1_axi_interconnect_0_0,AXI_Interconnect,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "package_project" *) 
(* X_CORE_INFO = "AXI_Interconnect,Vivado 2024.2" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(ACLK, ARESETN, M0_AWADDR, M0_AWLEN, M0_AWSIZE, 
  M0_AWBURST, M0_AWVALID, M0_AWREADY, M0_WDATA, M0_WSTRB, M0_WLAST, M0_WVALID, M0_WREADY, M0_BRESP, 
  M0_BVALID, M0_BREADY, M0_ARADDR, M0_ARLEN, M0_ARSIZE, M0_ARBURST, M0_ARVALID, M0_ARREADY, 
  M0_RDATA, M0_RRESP, M0_RLAST, M0_RVALID, M0_RREADY, M1_AWADDR, M1_AWLEN, M1_AWSIZE, M1_AWBURST, 
  M1_AWVALID, M1_AWREADY, M1_WDATA, M1_WSTRB, M1_WLAST, M1_WVALID, M1_WREADY, M1_BRESP, M1_BVALID, 
  M1_BREADY, M1_ARADDR, M1_ARLEN, M1_ARSIZE, M1_ARBURST, M1_ARVALID, M1_ARREADY, M1_RDATA, 
  M1_RRESP, M1_RLAST, M1_RVALID, M1_RREADY, S0_AWADDR, S0_AWLEN, S0_AWSIZE, S0_AWBURST, S0_AWVALID, 
  S0_AWREADY, S0_WDATA, S0_WSTRB, S0_WLAST, S0_WVALID, S0_WREADY, S0_BRESP, S0_BVALID, S0_BREADY, 
  S0_ARADDR, S0_ARLEN, S0_ARSIZE, S0_ARBURST, S0_ARVALID, S0_ARREADY, S0_RDATA, S0_RRESP, S0_RLAST, 
  S0_RVALID, S0_RREADY, S1_AWADDR, S1_AWLEN, S1_AWSIZE, S1_AWBURST, S1_AWVALID, S1_AWREADY, 
  S1_WDATA, S1_WSTRB, S1_WLAST, S1_WVALID, S1_WREADY, S1_BRESP, S1_BVALID, S1_BREADY, S1_ARADDR, 
  S1_ARLEN, S1_ARSIZE, S1_ARBURST, S1_ARVALID, S1_ARREADY, S1_RDATA, S1_RRESP, S1_RLAST, S1_RVALID, 
  S1_RREADY, S2_AWADDR, S2_AWLEN, S2_AWSIZE, S2_AWBURST, S2_AWVALID, S2_AWREADY, S2_WDATA, 
  S2_WSTRB, S2_WLAST, S2_WVALID, S2_WREADY, S2_BRESP, S2_BVALID, S2_BREADY, S2_ARADDR, S2_ARLEN, 
  S2_ARSIZE, S2_ARBURST, S2_ARVALID, S2_ARREADY, S2_RDATA, S2_RRESP, S2_RLAST, S2_RVALID, 
  S2_RREADY, S3_AWADDR, S3_AWLEN, S3_AWSIZE, S3_AWBURST, S3_AWVALID, S3_AWREADY, S3_WDATA, 
  S3_WSTRB, S3_WLAST, S3_WVALID, S3_WREADY, S3_BRESP, S3_BVALID, S3_BREADY, S3_ARADDR, S3_ARLEN, 
  S3_ARSIZE, S3_ARBURST, S3_ARVALID, S3_ARREADY, S3_RDATA, S3_RRESP, S3_RLAST, S3_RVALID, 
  S3_RREADY)
/* synthesis syn_black_box black_box_pad_pin="ARESETN,M0_AWADDR[31:0],M0_AWLEN[7:0],M0_AWSIZE[2:0],M0_AWBURST[1:0],M0_AWVALID,M0_AWREADY,M0_WDATA[31:0],M0_WSTRB[3:0],M0_WLAST,M0_WVALID,M0_WREADY,M0_BRESP[1:0],M0_BVALID,M0_BREADY,M0_ARADDR[31:0],M0_ARLEN[7:0],M0_ARSIZE[2:0],M0_ARBURST[1:0],M0_ARVALID,M0_ARREADY,M0_RDATA[31:0],M0_RRESP[1:0],M0_RLAST,M0_RVALID,M0_RREADY,M1_AWADDR[31:0],M1_AWLEN[7:0],M1_AWSIZE[2:0],M1_AWBURST[1:0],M1_AWVALID,M1_AWREADY,M1_WDATA[31:0],M1_WSTRB[3:0],M1_WLAST,M1_WVALID,M1_WREADY,M1_BRESP[1:0],M1_BVALID,M1_BREADY,M1_ARADDR[31:0],M1_ARLEN[7:0],M1_ARSIZE[2:0],M1_ARBURST[1:0],M1_ARVALID,M1_ARREADY,M1_RDATA[31:0],M1_RRESP[1:0],M1_RLAST,M1_RVALID,M1_RREADY,S0_AWADDR[31:0],S0_AWLEN[7:0],S0_AWSIZE[2:0],S0_AWBURST[1:0],S0_AWVALID,S0_AWREADY,S0_WDATA[31:0],S0_WSTRB[3:0],S0_WLAST,S0_WVALID,S0_WREADY,S0_BRESP[1:0],S0_BVALID,S0_BREADY,S0_ARADDR[31:0],S0_ARLEN[7:0],S0_ARSIZE[2:0],S0_ARBURST[1:0],S0_ARVALID,S0_ARREADY,S0_RDATA[31:0],S0_RRESP[1:0],S0_RLAST,S0_RVALID,S0_RREADY,S1_AWADDR[31:0],S1_AWLEN[7:0],S1_AWSIZE[2:0],S1_AWBURST[1:0],S1_AWVALID,S1_AWREADY,S1_WDATA[31:0],S1_WSTRB[3:0],S1_WLAST,S1_WVALID,S1_WREADY,S1_BRESP[1:0],S1_BVALID,S1_BREADY,S1_ARADDR[31:0],S1_ARLEN[7:0],S1_ARSIZE[2:0],S1_ARBURST[1:0],S1_ARVALID,S1_ARREADY,S1_RDATA[31:0],S1_RRESP[1:0],S1_RLAST,S1_RVALID,S1_RREADY,S2_AWADDR[31:0],S2_AWLEN[7:0],S2_AWSIZE[2:0],S2_AWBURST[1:0],S2_AWVALID,S2_AWREADY,S2_WDATA[31:0],S2_WSTRB[3:0],S2_WLAST,S2_WVALID,S2_WREADY,S2_BRESP[1:0],S2_BVALID,S2_BREADY,S2_ARADDR[31:0],S2_ARLEN[7:0],S2_ARSIZE[2:0],S2_ARBURST[1:0],S2_ARVALID,S2_ARREADY,S2_RDATA[31:0],S2_RRESP[1:0],S2_RLAST,S2_RVALID,S2_RREADY,S3_AWADDR[31:0],S3_AWLEN[7:0],S3_AWSIZE[2:0],S3_AWBURST[1:0],S3_AWVALID,S3_AWREADY,S3_WDATA[31:0],S3_WSTRB[3:0],S3_WLAST,S3_WVALID,S3_WREADY,S3_BRESP[1:0],S3_BVALID,S3_BREADY,S3_ARADDR[31:0],S3_ARLEN[7:0],S3_ARSIZE[2:0],S3_ARBURST[1:0],S3_ARVALID,S3_ARREADY,S3_RDATA[31:0],S3_RRESP[1:0],S3_RLAST,S3_RVALID,S3_RREADY" */
/* synthesis syn_force_seq_prim="ACLK" */;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ACLK CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF M0:M1:S0:S1:S2:S3, ASSOCIATED_RESET ARESETN, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input ACLK /* synthesis syn_isclock = 1 */;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ARESETN RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input ARESETN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWADDR" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [31:0]M0_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWLEN" *) input [7:0]M0_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWSIZE" *) input [2:0]M0_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWBURST" *) input [1:0]M0_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWVALID" *) input M0_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWREADY" *) output M0_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WDATA" *) input [31:0]M0_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WSTRB" *) input [3:0]M0_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WLAST" *) input M0_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WVALID" *) input M0_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WREADY" *) output M0_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 BRESP" *) output [1:0]M0_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 BVALID" *) output M0_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 BREADY" *) input M0_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARADDR" *) input [31:0]M0_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARLEN" *) input [7:0]M0_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARSIZE" *) input [2:0]M0_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARBURST" *) input [1:0]M0_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARVALID" *) input M0_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARREADY" *) output M0_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RDATA" *) output [31:0]M0_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RRESP" *) output [1:0]M0_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RLAST" *) output M0_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RVALID" *) output M0_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RREADY" *) input M0_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWADDR" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M1, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [31:0]M1_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWLEN" *) input [7:0]M1_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWSIZE" *) input [2:0]M1_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWBURST" *) input [1:0]M1_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWVALID" *) input M1_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWREADY" *) output M1_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WDATA" *) input [31:0]M1_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WSTRB" *) input [3:0]M1_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WLAST" *) input M1_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WVALID" *) input M1_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WREADY" *) output M1_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 BRESP" *) output [1:0]M1_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 BVALID" *) output M1_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 BREADY" *) input M1_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARADDR" *) input [31:0]M1_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARLEN" *) input [7:0]M1_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARSIZE" *) input [2:0]M1_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARBURST" *) input [1:0]M1_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARVALID" *) input M1_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARREADY" *) output M1_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RDATA" *) output [31:0]M1_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RRESP" *) output [1:0]M1_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RLAST" *) output M1_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RVALID" *) output M1_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RREADY" *) input M1_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]S0_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWLEN" *) output [7:0]S0_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWSIZE" *) output [2:0]S0_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWBURST" *) output [1:0]S0_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWVALID" *) output S0_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWREADY" *) input S0_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WDATA" *) output [31:0]S0_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WSTRB" *) output [3:0]S0_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WLAST" *) output S0_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WVALID" *) output S0_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WREADY" *) input S0_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 BRESP" *) input [1:0]S0_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 BVALID" *) input S0_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 BREADY" *) output S0_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARADDR" *) output [31:0]S0_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARLEN" *) output [7:0]S0_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARSIZE" *) output [2:0]S0_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARBURST" *) output [1:0]S0_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARVALID" *) output S0_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARREADY" *) input S0_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RDATA" *) input [31:0]S0_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RRESP" *) input [1:0]S0_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RLAST" *) input S0_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RVALID" *) input S0_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RREADY" *) output S0_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S1, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]S1_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWLEN" *) output [7:0]S1_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWSIZE" *) output [2:0]S1_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWBURST" *) output [1:0]S1_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWVALID" *) output S1_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWREADY" *) input S1_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WDATA" *) output [31:0]S1_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WSTRB" *) output [3:0]S1_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WLAST" *) output S1_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WVALID" *) output S1_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WREADY" *) input S1_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 BRESP" *) input [1:0]S1_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 BVALID" *) input S1_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 BREADY" *) output S1_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARADDR" *) output [31:0]S1_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARLEN" *) output [7:0]S1_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARSIZE" *) output [2:0]S1_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARBURST" *) output [1:0]S1_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARVALID" *) output S1_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARREADY" *) input S1_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RDATA" *) input [31:0]S1_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RRESP" *) input [1:0]S1_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RLAST" *) input S1_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RVALID" *) input S1_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RREADY" *) output S1_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S2, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]S2_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWLEN" *) output [7:0]S2_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWSIZE" *) output [2:0]S2_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWBURST" *) output [1:0]S2_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWVALID" *) output S2_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWREADY" *) input S2_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WDATA" *) output [31:0]S2_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WSTRB" *) output [3:0]S2_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WLAST" *) output S2_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WVALID" *) output S2_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WREADY" *) input S2_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 BRESP" *) input [1:0]S2_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 BVALID" *) input S2_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 BREADY" *) output S2_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARADDR" *) output [31:0]S2_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARLEN" *) output [7:0]S2_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARSIZE" *) output [2:0]S2_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARBURST" *) output [1:0]S2_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARVALID" *) output S2_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARREADY" *) input S2_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RDATA" *) input [31:0]S2_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RRESP" *) input [1:0]S2_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RLAST" *) input S2_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RVALID" *) input S2_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RREADY" *) output S2_RREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWADDR" *) (* X_INTERFACE_MODE = "master" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S3, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output [31:0]S3_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWLEN" *) output [7:0]S3_AWLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWSIZE" *) output [2:0]S3_AWSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWBURST" *) output [1:0]S3_AWBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWVALID" *) output S3_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWREADY" *) input S3_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WDATA" *) output [31:0]S3_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WSTRB" *) output [3:0]S3_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WLAST" *) output S3_WLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WVALID" *) output S3_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WREADY" *) input S3_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 BRESP" *) input [1:0]S3_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 BVALID" *) input S3_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 BREADY" *) output S3_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARADDR" *) output [31:0]S3_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARLEN" *) output [7:0]S3_ARLEN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARSIZE" *) output [2:0]S3_ARSIZE;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARBURST" *) output [1:0]S3_ARBURST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARVALID" *) output S3_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARREADY" *) input S3_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RDATA" *) input [31:0]S3_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RRESP" *) input [1:0]S3_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RLAST" *) input S3_RLAST;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RVALID" *) input S3_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RREADY" *) output S3_RREADY;
endmodule
