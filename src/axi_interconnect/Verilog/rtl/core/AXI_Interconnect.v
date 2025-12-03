`timescale 1ns/1ps

// Wrapper module to provide simple interface for test cases
// This wrapper translates simple read-only interface to full AXI4 protocol
module AXI_Interconnect (
    // Global signals
    input  wire           G_clk,
    input  wire           G_reset,

    // Master 0 simplified interface (Read only)
    input  wire           M0_RREADY,
    input  wire [31:0]    M0_ARADDR,
    input  wire [3:0]     M0_ARLEN,
    input  wire [2:0]     M0_ARSIZE,
    input  wire [1:0]     M0_ARBURST,
    input  wire           M0_ARVALID,

    // Master 1 simplified interface (Read only)
    input  wire           M1_RREADY,
    input  wire [31:0]    M1_ARADDR,
    input  wire [3:0]     M1_ARLEN,
    input  wire [2:0]     M1_ARSIZE,
    input  wire [1:0]     M1_ARBURST,
    input  wire           M1_ARVALID,

    // Slave 0 simplified interface (Read only)
    input  wire           S0_ARREADY,
    input  wire           S0_RVALID,
    input  wire           S0_RLAST,
    input  wire [1:0]     S0_RRESP,
    input  wire [31:0]    S0_RDATA,

    // Slave 1 simplified interface (Read only)
    input  wire           S1_ARREADY,
    input  wire           S1_RVALID,
    input  wire           S1_RLAST,
    input  wire [1:0]     S1_RRESP,
    input  wire [31:0]    S1_RDATA,

    // Address ranges for slaves
    input  wire [31:0]    slave0_addr1,
    input  wire [31:0]    slave0_addr2,
    input  wire [31:0]    slave1_addr1,
    input  wire [31:0]    slave1_addr2,

    // Master 0 outputs
    output wire           ARREADY_M0,
    output wire           RVALID_M0,
    output wire           RLAST_M0,
    output wire [1:0]     RRESP_M0,
    output wire [31:0]    RDATA_M0,

    // Master 1 outputs
    output wire           ARREADY_M1,
    output wire           RVALID_M1,
    output wire           RLAST_M1,
    output wire [1:0]     RRESP_M1,
    output wire [31:0]    RDATA_M1,

    // Slave 0 outputs
    output wire [31:0]    ARADDR_S0,
    output wire [3:0]     ARLEN_S0,
    output wire [2:0]     ARSIZE_S0,
    output wire [1:0]     ARBURST_S0,
    output wire           ARVALID_S0,
    output wire           RREADY_S0,

    // Slave 1 outputs
    output wire [31:0]    ARADDR_S1,
    output wire [3:0]     ARLEN_S1,
    output wire [2:0]     ARSIZE_S1,
    output wire [1:0]     ARBURST_S1,
    output wire           ARVALID_S1,
    output wire           RREADY_S1
);

    // Internal signals for unused write channels
    // These are tied to safe default values since test cases only use read channels
    
    // Unused write signals - all tied to inactive/default values
    wire [31:0] unused_wdata = 32'h0;
    wire [3:0]  unused_wstrb = 4'h0;
    wire        unused_wlast = 1'b0;
    wire        unused_wvalid = 1'b0;
    wire        unused_bready = 1'b0;
    wire [31:0] unused_awaddr = 32'h0;
    wire [7:0]  unused_awlen = 8'h0;
    wire [2:0]  unused_awsize = 3'h0;
    wire [1:0]  unused_awburst = 2'h0;
    wire        unused_awvalid = 1'b0;
    wire [1:0]  unused_awlock = 2'h0;
    wire [3:0]  unused_awcache = 4'h0;
    wire [2:0]  unused_awprot = 3'h0;
    wire [3:0]  unused_awqos = 4'h0;
    wire [1:0]  unused_arlock = 2'h0;
    wire [3:0]  unused_arcache = 4'h0;
    wire [2:0]  unused_arprot = 3'h0;
    wire [3:0]  unused_arqos = 4'h0;

    // Unused outputs from interconnect (write channels)
    wire        unused_awready_m0, unused_awready_m1;
    wire        unused_wready_m0, unused_wready_m1;
    wire [1:0]  unused_bresp_m0, unused_bresp_m1;
    wire        unused_bvalid_m0, unused_bvalid_m1;
    wire        unused_awready_s0, unused_awready_s1;
    wire        unused_wready_s0, unused_wready_s1;
    wire [1:0]  unused_bresp_s0, unused_bresp_s1;
    wire        unused_bvalid_s0, unused_bvalid_s1;
    wire [0:0]  unused_awaddr_id_m0, unused_awaddr_id_m1;
    wire [31:0] unused_awaddr_m0, unused_awaddr_m1;
    wire [7:0]  unused_awlen_m0, unused_awlen_m1;
    wire [2:0]  unused_awsize_m0, unused_awsize_m1;
    wire [1:0]  unused_awburst_m0, unused_awburst_m1;
    wire [1:0]  unused_awlock_m0, unused_awlock_m1;
    wire [3:0]  unused_awcache_m0, unused_awcache_m1;
    wire [2:0]  unused_awprot_m0, unused_awprot_m1;
    wire [3:0]  unused_awqos_m0, unused_awqos_m1;
    wire        unused_awvalid_m0, unused_awvalid_m1;
    wire [31:0] unused_wdata_m0, unused_wdata_m1;
    wire [3:0]  unused_wstrb_m0, unused_wstrb_m1;
    wire        unused_wlast_m0, unused_wlast_m1;
    wire        unused_wvalid_m0, unused_wvalid_m1;
    wire [0:0]  unused_bid_m0, unused_bid_m1;
    wire [3:0]  unused_arregion_m0, unused_arregion_m1;

    // Extended ARLEN signals (8-bit for AXI4, but test uses 4-bit)
    wire [7:0] M0_ARLEN_extended = {4'b0, M0_ARLEN};
    wire [7:0] M1_ARLEN_extended = {4'b0, M1_ARLEN};
    
    // Internal wires for ARLEN from interconnect (8-bit) to slaves (4-bit)
    wire [7:0] ARLEN_S0_full;
    wire [7:0] ARLEN_S1_full;
    
    // Extract lower 4 bits for testcase interface
    assign ARLEN_S0 = ARLEN_S0_full[3:0];
    assign ARLEN_S1 = ARLEN_S1_full[3:0];

    // Instantiate the actual AXI_Interconnect module with full AXI4 interface
    AXI_Interconnect_Full u_axi_interconnect (
        // Slave S01 ports (connected to Master 1 from testcase)
        .S01_ACLK           (G_clk),
        .S01_ARESETN        (G_reset),
        // Write address channel - unused
        .S01_AXI_awaddr     (unused_awaddr),
        .S01_AXI_awlen      (unused_awlen),
        .S01_AXI_awsize     (unused_awsize),
        .S01_AXI_awburst    (unused_awburst),
        .S01_AXI_awlock     (unused_awlock),
        .S01_AXI_awcache    (unused_awcache),
        .S01_AXI_awprot     (unused_awprot),
        .S01_AXI_awqos      (unused_awqos),
        .S01_AXI_awvalid    (unused_awvalid),
        .S01_AXI_awready    (unused_awready_s1),
        // Write data channel - unused
        .S01_AXI_wdata      (unused_wdata),
        .S01_AXI_wstrb      (unused_wstrb),
        .S01_AXI_wlast      (unused_wlast),
        .S01_AXI_wvalid     (unused_wvalid),
        .S01_AXI_wready     (unused_wready_s1),
        // Write response channel - unused
        .S01_AXI_bresp      (unused_bresp_s1),
        .S01_AXI_bvalid     (unused_bvalid_s1),
        .S01_AXI_bready     (unused_bready),
        // Read address channel - active
        .S01_AXI_araddr     (M1_ARADDR),
        .S01_AXI_arlen      (M1_ARLEN_extended),
        .S01_AXI_arsize     (M1_ARSIZE),
        .S01_AXI_arburst    (M1_ARBURST),
        .S01_AXI_arlock     (unused_arlock),
        .S01_AXI_arcache    (unused_arcache),
        .S01_AXI_arprot     (unused_arprot),
        .S01_AXI_arqos      (unused_arqos),
        .S01_AXI_arvalid    (M1_ARVALID),
        .S01_AXI_arready    (ARREADY_M1),
        // Read data channel - active
        .S01_AXI_rdata      (RDATA_M1),
        .S01_AXI_rresp      (RRESP_M1),
        .S01_AXI_rlast      (RLAST_M1),
        .S01_AXI_rvalid     (RVALID_M1),
        .S01_AXI_rready     (M1_RREADY),

        // Interconnect global
        .ACLK               (G_clk),
        .ARESETN            (G_reset),

        // Slave S00 ports (connected to Master 0 from testcase)
        .S00_ACLK           (G_clk),
        .S00_ARESETN        (G_reset),
        // Write address channel - unused
        .S00_AXI_awaddr     (unused_awaddr),
        .S00_AXI_awlen      (unused_awlen),
        .S00_AXI_awsize     (unused_awsize),
        .S00_AXI_awburst    (unused_awburst),
        .S00_AXI_awlock     (unused_awlock),
        .S00_AXI_awcache    (unused_awcache),
        .S00_AXI_awprot     (unused_awprot),
        .S00_AXI_awqos      (unused_awqos),
        .S00_AXI_awvalid    (unused_awvalid),
        .S00_AXI_awready    (unused_awready_s0),
        // Write data channel - unused
        .S00_AXI_wdata      (unused_wdata),
        .S00_AXI_wstrb      (unused_wstrb),
        .S00_AXI_wlast      (unused_wlast),
        .S00_AXI_wvalid     (unused_wvalid),
        .S00_AXI_wready     (unused_wready_s0),
        // Write response channel - unused
        .S00_AXI_bresp      (unused_bresp_s0),
        .S00_AXI_bvalid     (unused_bvalid_s0),
        .S00_AXI_bready     (unused_bready),
        // Read address channel - active
        .S00_AXI_araddr     (M0_ARADDR),
        .S00_AXI_arlen      (M0_ARLEN_extended),
        .S00_AXI_arsize     (M0_ARSIZE),
        .S00_AXI_arburst    (M0_ARBURST),
        .S00_AXI_arlock     (unused_arlock),
        .S00_AXI_arcache    (unused_arcache),
        .S00_AXI_arprot     (unused_arprot),
        .S00_AXI_arqos      (unused_arqos),
        .S00_AXI_arvalid    (M0_ARVALID),
        .S00_AXI_arready    (ARREADY_M0),
        // Read data channel - active
        .S00_AXI_rdata      (RDATA_M0),
        .S00_AXI_rresp      (RRESP_M0),
        .S00_AXI_rlast      (RLAST_M0),
        .S00_AXI_rvalid     (RVALID_M0),
        .S00_AXI_rready     (M0_RREADY),

        // Master M00 ports (connected to Slave 0 from testcase)
        .M00_ACLK           (G_clk),
        .M00_ARESETN        (G_reset),
        // Write address channel - unused
        .M00_AXI_awaddr_ID  (unused_awaddr_id_m0),
        .M00_AXI_awaddr     (unused_awaddr_m0),
        .M00_AXI_awlen      (unused_awlen_m0),
        .M00_AXI_awsize     (unused_awsize_m0),
        .M00_AXI_awburst    (unused_awburst_m0),
        .M00_AXI_awlock     (unused_awlock_m0),
        .M00_AXI_awcache    (unused_awcache_m0),
        .M00_AXI_awprot     (unused_awprot_m0),
        .M00_AXI_awqos      (unused_awqos_m0),
        .M00_AXI_awvalid    (unused_awvalid_m0),
        .M00_AXI_awready    (1'b0),
        // Write data channel - unused
        .M00_AXI_wdata      (unused_wdata_m0),
        .M00_AXI_wstrb      (unused_wstrb_m0),
        .M00_AXI_wlast      (unused_wlast_m0),
        .M00_AXI_wvalid     (unused_wvalid_m0),
        .M00_AXI_wready     (1'b0),
        // Write response channel - unused
        .M00_AXI_BID        (1'b0),
        .M00_AXI_bresp      (unused_bresp_m0),
        .M00_AXI_bvalid     (unused_bvalid_m0),
        .M00_AXI_bready     (),
        // Read address channel - active
        .M00_AXI_araddr     (ARADDR_S0),
        .M00_AXI_arlen      (ARLEN_S0_full),
        .M00_AXI_arsize     (ARSIZE_S0),
        .M00_AXI_arburst    (ARBURST_S0),
        .M00_AXI_arlock     (),
        .M00_AXI_arcache    (),
        .M00_AXI_arprot     (),
        .M00_AXI_arregion   (unused_arregion_m0),
        .M00_AXI_arqos      (),
        .M00_AXI_arvalid    (ARVALID_S0),
        .M00_AXI_arready    (S0_ARREADY),
        // Read data channel - active
        .M00_AXI_rdata      (S0_RDATA),
        .M00_AXI_rresp      (S0_RRESP),
        .M00_AXI_rlast      (S0_RLAST),
        .M00_AXI_rvalid     (S0_RVALID),
        .M00_AXI_rready     (RREADY_S0),

        // Master M01 ports (connected to Slave 1 from testcase)
        .M01_ACLK           (G_clk),
        .M01_ARESETN        (G_reset),
        // Write address channel - unused
        .M01_AXI_awaddr_ID  (unused_awaddr_id_m1),
        .M01_AXI_awaddr     (unused_awaddr_m1),
        .M01_AXI_awlen      (unused_awlen_m1),
        .M01_AXI_awsize     (unused_awsize_m1),
        .M01_AXI_awburst    (unused_awburst_m1),
        .M01_AXI_awlock     (unused_awlock_m1),
        .M01_AXI_awcache    (unused_awcache_m1),
        .M01_AXI_awprot     (unused_awprot_m1),
        .M01_AXI_awqos      (unused_awqos_m1),
        .M01_AXI_awvalid    (unused_awvalid_m1),
        .M01_AXI_awready    (1'b0),
        // Write data channel - unused
        .M01_AXI_wdata      (unused_wdata_m1),
        .M01_AXI_wstrb      (unused_wstrb_m1),
        .M01_AXI_wlast      (unused_wlast_m1),
        .M01_AXI_wvalid     (unused_wvalid_m1),
        .M01_AXI_wready     (1'b0),
        // Write response channel - unused
        .M01_AXI_BID        (1'b0),
        .M01_AXI_bresp      (unused_bresp_m1),
        .M01_AXI_bvalid     (unused_bvalid_m1),
        .M01_AXI_bready     (),
        // Read address channel - active
        .M01_AXI_araddr     (ARADDR_S1),
        .M01_AXI_arlen      (ARLEN_S1_full),
        .M01_AXI_arsize     (ARSIZE_S1),
        .M01_AXI_arburst    (ARBURST_S1),
        .M01_AXI_arlock     (),
        .M01_AXI_arcache    (),
        .M01_AXI_arprot     (),
        .M01_AXI_arregion   (unused_arregion_m1),
        .M01_AXI_arqos      (),
        .M01_AXI_arvalid    (ARVALID_S1),
        .M01_AXI_arready    (S1_ARREADY),
        // Read data channel - active
        .M01_AXI_rdata      (S1_RDATA),
        .M01_AXI_rresp      (S1_RRESP),
        .M01_AXI_rlast      (S1_RLAST),
        .M01_AXI_rvalid     (S1_RVALID),
        .M01_AXI_rready     (RREADY_S1),

        // Address ranges
        .slave0_addr1       (slave0_addr1),
        .slave0_addr2       (slave0_addr2),
        .slave1_addr1       (slave1_addr1),
        .slave1_addr2       (slave1_addr2)
    );

endmodule


