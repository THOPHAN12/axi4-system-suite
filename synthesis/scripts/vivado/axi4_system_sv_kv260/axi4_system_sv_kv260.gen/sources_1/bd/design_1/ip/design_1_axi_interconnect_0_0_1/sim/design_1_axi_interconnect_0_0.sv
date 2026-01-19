// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2025 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: user.org:user:axi_interconnect_2m4s:1.0
// IP Revision: 1

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_1_axi_interconnect_0_0 (
  ACLK,
  ARESETN,
  M0_AWADDR,
  M0_AWLEN,
  M0_AWSIZE,
  M0_AWBURST,
  M0_AWVALID,
  M0_AWREADY,
  M0_WDATA,
  M0_WSTRB,
  M0_WLAST,
  M0_WVALID,
  M0_WREADY,
  M0_BRESP,
  M0_BVALID,
  M0_BREADY,
  M0_ARADDR,
  M0_ARLEN,
  M0_ARSIZE,
  M0_ARBURST,
  M0_ARVALID,
  M0_ARREADY,
  M0_RDATA,
  M0_RRESP,
  M0_RLAST,
  M0_RVALID,
  M0_RREADY,
  M1_AWADDR,
  M1_AWLEN,
  M1_AWSIZE,
  M1_AWBURST,
  M1_AWVALID,
  M1_AWREADY,
  M1_WDATA,
  M1_WSTRB,
  M1_WLAST,
  M1_WVALID,
  M1_WREADY,
  M1_BRESP,
  M1_BVALID,
  M1_BREADY,
  M1_ARADDR,
  M1_ARLEN,
  M1_ARSIZE,
  M1_ARBURST,
  M1_ARVALID,
  M1_ARREADY,
  M1_RDATA,
  M1_RRESP,
  M1_RLAST,
  M1_RVALID,
  M1_RREADY,
  S0_AWADDR,
  S0_AWLEN,
  S0_AWSIZE,
  S0_AWBURST,
  S0_AWVALID,
  S0_AWREADY,
  S0_WDATA,
  S0_WSTRB,
  S0_WLAST,
  S0_WVALID,
  S0_WREADY,
  S0_BRESP,
  S0_BVALID,
  S0_BREADY,
  S0_ARADDR,
  S0_ARLEN,
  S0_ARSIZE,
  S0_ARBURST,
  S0_ARVALID,
  S0_ARREADY,
  S0_RDATA,
  S0_RRESP,
  S0_RLAST,
  S0_RVALID,
  S0_RREADY,
  S1_AWADDR,
  S1_AWLEN,
  S1_AWSIZE,
  S1_AWBURST,
  S1_AWVALID,
  S1_AWREADY,
  S1_WDATA,
  S1_WSTRB,
  S1_WLAST,
  S1_WVALID,
  S1_WREADY,
  S1_BRESP,
  S1_BVALID,
  S1_BREADY,
  S1_ARADDR,
  S1_ARLEN,
  S1_ARSIZE,
  S1_ARBURST,
  S1_ARVALID,
  S1_ARREADY,
  S1_RDATA,
  S1_RRESP,
  S1_RLAST,
  S1_RVALID,
  S1_RREADY,
  S2_AWADDR,
  S2_AWLEN,
  S2_AWSIZE,
  S2_AWBURST,
  S2_AWVALID,
  S2_AWREADY,
  S2_WDATA,
  S2_WSTRB,
  S2_WLAST,
  S2_WVALID,
  S2_WREADY,
  S2_BRESP,
  S2_BVALID,
  S2_BREADY,
  S2_ARADDR,
  S2_ARLEN,
  S2_ARSIZE,
  S2_ARBURST,
  S2_ARVALID,
  S2_ARREADY,
  S2_RDATA,
  S2_RRESP,
  S2_RLAST,
  S2_RVALID,
  S2_RREADY,
  S3_AWADDR,
  S3_AWLEN,
  S3_AWSIZE,
  S3_AWBURST,
  S3_AWVALID,
  S3_AWREADY,
  S3_WDATA,
  S3_WSTRB,
  S3_WLAST,
  S3_WVALID,
  S3_WREADY,
  S3_BRESP,
  S3_BVALID,
  S3_BREADY,
  S3_ARADDR,
  S3_ARLEN,
  S3_ARSIZE,
  S3_ARBURST,
  S3_ARVALID,
  S3_ARREADY,
  S3_RDATA,
  S3_RRESP,
  S3_RLAST,
  S3_RVALID,
  S3_RREADY
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ACLK CLK" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF M0:M1:S0:S1:S2:S3, ASSOCIATED_RESET ARESETN, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
input wire ACLK;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ARESETN RST" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
input wire ARESETN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWADDR" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRIT\
E_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
input wire [31 : 0] M0_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWLEN" *)
input wire [7 : 0] M0_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWSIZE" *)
input wire [2 : 0] M0_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWBURST" *)
input wire [1 : 0] M0_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWVALID" *)
input wire M0_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 AWREADY" *)
output wire M0_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WDATA" *)
input wire [31 : 0] M0_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WSTRB" *)
input wire [3 : 0] M0_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WLAST" *)
input wire M0_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WVALID" *)
input wire M0_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 WREADY" *)
output wire M0_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 BRESP" *)
output wire [1 : 0] M0_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 BVALID" *)
output wire M0_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 BREADY" *)
input wire M0_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARADDR" *)
input wire [31 : 0] M0_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARLEN" *)
input wire [7 : 0] M0_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARSIZE" *)
input wire [2 : 0] M0_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARBURST" *)
input wire [1 : 0] M0_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARVALID" *)
input wire M0_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 ARREADY" *)
output wire M0_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RDATA" *)
output wire [31 : 0] M0_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RRESP" *)
output wire [1 : 0] M0_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RLAST" *)
output wire M0_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RVALID" *)
output wire M0_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M0 RREADY" *)
input wire M0_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWADDR" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M1, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRIT\
E_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
input wire [31 : 0] M1_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWLEN" *)
input wire [7 : 0] M1_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWSIZE" *)
input wire [2 : 0] M1_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWBURST" *)
input wire [1 : 0] M1_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWVALID" *)
input wire M1_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 AWREADY" *)
output wire M1_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WDATA" *)
input wire [31 : 0] M1_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WSTRB" *)
input wire [3 : 0] M1_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WLAST" *)
input wire M1_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WVALID" *)
input wire M1_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 WREADY" *)
output wire M1_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 BRESP" *)
output wire [1 : 0] M1_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 BVALID" *)
output wire M1_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 BREADY" *)
input wire M1_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARADDR" *)
input wire [31 : 0] M1_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARLEN" *)
input wire [7 : 0] M1_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARSIZE" *)
input wire [2 : 0] M1_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARBURST" *)
input wire [1 : 0] M1_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARVALID" *)
input wire M1_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 ARREADY" *)
output wire M1_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RDATA" *)
output wire [31 : 0] M1_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RRESP" *)
output wire [1 : 0] M1_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RLAST" *)
output wire M1_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RVALID" *)
output wire M1_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M1 RREADY" *)
input wire M1_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWADDR" *)
(* X_INTERFACE_MODE = "master" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRIT\
E_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
output wire [31 : 0] S0_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWLEN" *)
output wire [7 : 0] S0_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWSIZE" *)
output wire [2 : 0] S0_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWBURST" *)
output wire [1 : 0] S0_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWVALID" *)
output wire S0_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 AWREADY" *)
input wire S0_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WDATA" *)
output wire [31 : 0] S0_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WSTRB" *)
output wire [3 : 0] S0_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WLAST" *)
output wire S0_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WVALID" *)
output wire S0_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 WREADY" *)
input wire S0_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 BRESP" *)
input wire [1 : 0] S0_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 BVALID" *)
input wire S0_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 BREADY" *)
output wire S0_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARADDR" *)
output wire [31 : 0] S0_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARLEN" *)
output wire [7 : 0] S0_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARSIZE" *)
output wire [2 : 0] S0_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARBURST" *)
output wire [1 : 0] S0_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARVALID" *)
output wire S0_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 ARREADY" *)
input wire S0_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RDATA" *)
input wire [31 : 0] S0_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RRESP" *)
input wire [1 : 0] S0_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RLAST" *)
input wire S0_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RVALID" *)
input wire S0_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S0 RREADY" *)
output wire S0_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWADDR" *)
(* X_INTERFACE_MODE = "master" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S1, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRIT\
E_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
output wire [31 : 0] S1_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWLEN" *)
output wire [7 : 0] S1_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWSIZE" *)
output wire [2 : 0] S1_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWBURST" *)
output wire [1 : 0] S1_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWVALID" *)
output wire S1_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 AWREADY" *)
input wire S1_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WDATA" *)
output wire [31 : 0] S1_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WSTRB" *)
output wire [3 : 0] S1_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WLAST" *)
output wire S1_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WVALID" *)
output wire S1_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 WREADY" *)
input wire S1_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 BRESP" *)
input wire [1 : 0] S1_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 BVALID" *)
input wire S1_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 BREADY" *)
output wire S1_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARADDR" *)
output wire [31 : 0] S1_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARLEN" *)
output wire [7 : 0] S1_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARSIZE" *)
output wire [2 : 0] S1_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARBURST" *)
output wire [1 : 0] S1_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARVALID" *)
output wire S1_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 ARREADY" *)
input wire S1_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RDATA" *)
input wire [31 : 0] S1_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RRESP" *)
input wire [1 : 0] S1_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RLAST" *)
input wire S1_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RVALID" *)
input wire S1_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S1 RREADY" *)
output wire S1_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWADDR" *)
(* X_INTERFACE_MODE = "master" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S2, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRIT\
E_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
output wire [31 : 0] S2_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWLEN" *)
output wire [7 : 0] S2_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWSIZE" *)
output wire [2 : 0] S2_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWBURST" *)
output wire [1 : 0] S2_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWVALID" *)
output wire S2_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 AWREADY" *)
input wire S2_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WDATA" *)
output wire [31 : 0] S2_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WSTRB" *)
output wire [3 : 0] S2_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WLAST" *)
output wire S2_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WVALID" *)
output wire S2_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 WREADY" *)
input wire S2_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 BRESP" *)
input wire [1 : 0] S2_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 BVALID" *)
input wire S2_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 BREADY" *)
output wire S2_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARADDR" *)
output wire [31 : 0] S2_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARLEN" *)
output wire [7 : 0] S2_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARSIZE" *)
output wire [2 : 0] S2_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARBURST" *)
output wire [1 : 0] S2_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARVALID" *)
output wire S2_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 ARREADY" *)
input wire S2_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RDATA" *)
input wire [31 : 0] S2_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RRESP" *)
input wire [1 : 0] S2_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RLAST" *)
input wire S2_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RVALID" *)
input wire S2_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S2 RREADY" *)
output wire S2_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWADDR" *)
(* X_INTERFACE_MODE = "master" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S3, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRIT\
E_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
output wire [31 : 0] S3_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWLEN" *)
output wire [7 : 0] S3_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWSIZE" *)
output wire [2 : 0] S3_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWBURST" *)
output wire [1 : 0] S3_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWVALID" *)
output wire S3_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 AWREADY" *)
input wire S3_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WDATA" *)
output wire [31 : 0] S3_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WSTRB" *)
output wire [3 : 0] S3_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WLAST" *)
output wire S3_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WVALID" *)
output wire S3_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 WREADY" *)
input wire S3_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 BRESP" *)
input wire [1 : 0] S3_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 BVALID" *)
input wire S3_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 BREADY" *)
output wire S3_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARADDR" *)
output wire [31 : 0] S3_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARLEN" *)
output wire [7 : 0] S3_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARSIZE" *)
output wire [2 : 0] S3_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARBURST" *)
output wire [1 : 0] S3_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARVALID" *)
output wire S3_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 ARREADY" *)
input wire S3_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RDATA" *)
input wire [31 : 0] S3_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RRESP" *)
input wire [1 : 0] S3_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RLAST" *)
input wire S3_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RVALID" *)
input wire S3_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S3 RREADY" *)
output wire S3_RREADY;

  AXI_Interconnect #(
    .ARBITRATION_MODE(1)
  ) inst (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
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
endmodule
