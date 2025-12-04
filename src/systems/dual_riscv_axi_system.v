`timescale 1ns/1ps

module dual_riscv_axi_system #(
    parameter integer ADDR_WIDTH     = 32,
    parameter integer DATA_WIDTH     = 32,
    parameter integer ID_WIDTH       = 4,
    parameter integer RAM_WORDS      = 2048,
    parameter        RAM_INIT_HEX    = ""  // Empty for synthesis, set for simulation
) (
    input  wire                        ACLK,
    input  wire                        ARESETN,

    input  wire                        serv0_timer_irq,
    input  wire                        serv1_timer_irq,

    input  wire [31:0]                 gpio_in,
    output wire [31:0]                 gpio_out,

    output wire                        uart_tx_valid,
    output wire [7:0]                  uart_tx_byte,

    output wire                        spi_cs_n,
    output wire                        spi_sclk,
    output wire                        spi_mosi,
    input  wire                        spi_miso
);

    // =========================================================================
    // SERV Instance 0
    // =========================================================================
    wire [ID_WIDTH-1:0]     serv0_M0_arid;
    wire [ADDR_WIDTH-1:0]   serv0_M0_araddr;
    wire [7:0]              serv0_M0_arlen;
    wire [2:0]              serv0_M0_arsize;
    wire [1:0]              serv0_M0_arburst;
    wire [1:0]              serv0_M0_arlock;
    wire [3:0]              serv0_M0_arcache;
    wire [2:0]              serv0_M0_arprot;
    wire [3:0]              serv0_M0_arqos;
    wire [3:0]              serv0_M0_arregion;
    wire                    serv0_M0_arvalid;
    wire                    serv0_M0_arready;
    wire [ID_WIDTH-1:0]     serv0_M0_rid;
    wire [DATA_WIDTH-1:0]   serv0_M0_rdata;
    wire [1:0]              serv0_M0_rresp;
    wire                    serv0_M0_rlast;
    wire                    serv0_M0_rvalid;
    wire                    serv0_M0_rready;

    wire [ID_WIDTH-1:0]     serv0_M1_awid;
    wire [ADDR_WIDTH-1:0]   serv0_M1_awaddr;
    wire [7:0]              serv0_M1_awlen;
    wire [2:0]              serv0_M1_awsize;
    wire [1:0]              serv0_M1_awburst;
    wire [1:0]              serv0_M1_awlock;
    wire [3:0]              serv0_M1_awcache;
    wire [2:0]              serv0_M1_awprot;
    wire [3:0]              serv0_M1_awqos;
    wire [3:0]              serv0_M1_awregion;
    wire                    serv0_M1_awvalid;
    wire                    serv0_M1_awready;

    wire [DATA_WIDTH-1:0]   serv0_M1_wdata;
    wire [(DATA_WIDTH/8)-1:0] serv0_M1_wstrb;
    wire                    serv0_M1_wlast;
    wire                    serv0_M1_wvalid;
    wire                    serv0_M1_wready;

    wire [ID_WIDTH-1:0]     serv0_M1_bid;
    wire [1:0]              serv0_M1_bresp;
    wire                    serv0_M1_bvalid;
    wire                    serv0_M1_bready;

    wire [ID_WIDTH-1:0]     serv0_M1_arid;
    wire [ADDR_WIDTH-1:0]   serv0_M1_araddr;
    wire [7:0]              serv0_M1_arlen;
    wire [2:0]              serv0_M1_arsize;
    wire [1:0]              serv0_M1_arburst;
    wire [1:0]              serv0_M1_arlock;
    wire [3:0]              serv0_M1_arcache;
    wire [2:0]              serv0_M1_arprot;
    wire [3:0]              serv0_M1_arqos;
    wire [3:0]              serv0_M1_arregion;
    wire                    serv0_M1_arvalid;
    wire                    serv0_M1_arready;
    wire [ID_WIDTH-1:0]     serv0_M1_rid;
    wire [DATA_WIDTH-1:0]   serv0_M1_rdata;
    wire [1:0]              serv0_M1_rresp;
    wire                    serv0_M1_rlast;
    wire                    serv0_M1_rvalid;
    wire                    serv0_M1_rready;

    serv_axi_wrapper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) u_serv0 (
        .ACLK       (ACLK),
        .ARESETN    (ARESETN),
        .i_timer_irq(serv0_timer_irq),
        .M0_AXI_arid   (serv0_M0_arid),
        .M0_AXI_araddr (serv0_M0_araddr),
        .M0_AXI_arlen  (serv0_M0_arlen),
        .M0_AXI_arsize (serv0_M0_arsize),
        .M0_AXI_arburst(serv0_M0_arburst),
        .M0_AXI_arlock (serv0_M0_arlock),
        .M0_AXI_arcache(serv0_M0_arcache),
        .M0_AXI_arprot (serv0_M0_arprot),
        .M0_AXI_arqos  (serv0_M0_arqos),
        .M0_AXI_arregion(serv0_M0_arregion),
        .M0_AXI_arvalid(serv0_M0_arvalid),
        .M0_AXI_arready(serv0_M0_arready),
        .M0_AXI_rid    (serv0_M0_rid),
        .M0_AXI_rdata  (serv0_M0_rdata),
        .M0_AXI_rresp  (serv0_M0_rresp),
        .M0_AXI_rlast  (serv0_M0_rlast),
        .M0_AXI_rvalid (serv0_M0_rvalid),
        .M0_AXI_rready (serv0_M0_rready),
        .M1_AXI_awid   (serv0_M1_awid),
        .M1_AXI_awaddr (serv0_M1_awaddr),
        .M1_AXI_awlen  (serv0_M1_awlen),
        .M1_AXI_awsize (serv0_M1_awsize),
        .M1_AXI_awburst(serv0_M1_awburst),
        .M1_AXI_awlock (serv0_M1_awlock),
        .M1_AXI_awcache(serv0_M1_awcache),
        .M1_AXI_awprot (serv0_M1_awprot),
        .M1_AXI_awqos  (serv0_M1_awqos),
        .M1_AXI_awregion(serv0_M1_awregion),
        .M1_AXI_awvalid(serv0_M1_awvalid),
        .M1_AXI_awready(serv0_M1_awready),
        .M1_AXI_wdata  (serv0_M1_wdata),
        .M1_AXI_wstrb  (serv0_M1_wstrb),
        .M1_AXI_wlast  (serv0_M1_wlast),
        .M1_AXI_wvalid (serv0_M1_wvalid),
        .M1_AXI_wready (serv0_M1_wready),
        .M1_AXI_bid    (serv0_M1_bid),
        .M1_AXI_bresp  (serv0_M1_bresp),
        .M1_AXI_bvalid (serv0_M1_bvalid),
        .M1_AXI_bready (serv0_M1_bready),
        .M1_AXI_arid   (serv0_M1_arid),
        .M1_AXI_araddr (serv0_M1_araddr),
        .M1_AXI_arlen  (serv0_M1_arlen),
        .M1_AXI_arsize (serv0_M1_arsize),
        .M1_AXI_arburst(serv0_M1_arburst),
        .M1_AXI_arlock (serv0_M1_arlock),
        .M1_AXI_arcache(serv0_M1_arcache),
        .M1_AXI_arprot (serv0_M1_arprot),
        .M1_AXI_arqos  (serv0_M1_arqos),
        .M1_AXI_arregion(serv0_M1_arregion),
        .M1_AXI_arvalid(serv0_M1_arvalid),
        .M1_AXI_arready(serv0_M1_arready),
        .M1_AXI_rid    (serv0_M1_rid),
        .M1_AXI_rdata  (serv0_M1_rdata),
        .M1_AXI_rresp  (serv0_M1_rresp),
        .M1_AXI_rlast  (serv0_M1_rlast),
        .M1_AXI_rvalid (serv0_M1_rvalid),
        .M1_AXI_rready (serv0_M1_rready)
    );

    // =========================================================================
    // SERV Instance 1
    // =========================================================================
    wire [ID_WIDTH-1:0]     serv1_M0_arid;
    wire [ADDR_WIDTH-1:0]   serv1_M0_araddr;
    wire [7:0]              serv1_M0_arlen;
    wire [2:0]              serv1_M0_arsize;
    wire [1:0]              serv1_M0_arburst;
    wire [1:0]              serv1_M0_arlock;
    wire [3:0]              serv1_M0_arcache;
    wire [2:0]              serv1_M0_arprot;
    wire [3:0]              serv1_M0_arqos;
    wire [3:0]              serv1_M0_arregion;
    wire                    serv1_M0_arvalid;
    wire                    serv1_M0_arready;
    wire [ID_WIDTH-1:0]     serv1_M0_rid;
    wire [DATA_WIDTH-1:0]   serv1_M0_rdata;
    wire [1:0]              serv1_M0_rresp;
    wire                    serv1_M0_rlast;
    wire                    serv1_M0_rvalid;
    wire                    serv1_M0_rready;

    wire [ID_WIDTH-1:0]     serv1_M1_awid;
    wire [ADDR_WIDTH-1:0]   serv1_M1_awaddr;
    wire [7:0]              serv1_M1_awlen;
    wire [2:0]              serv1_M1_awsize;
    wire [1:0]              serv1_M1_awburst;
    wire [1:0]              serv1_M1_awlock;
    wire [3:0]              serv1_M1_awcache;
    wire [2:0]              serv1_M1_awprot;
    wire [3:0]              serv1_M1_awqos;
    wire [3:0]              serv1_M1_awregion;
    wire                    serv1_M1_awvalid;
    wire                    serv1_M1_awready;

    wire [DATA_WIDTH-1:0]   serv1_M1_wdata;
    wire [(DATA_WIDTH/8)-1:0] serv1_M1_wstrb;
    wire                    serv1_M1_wlast;
    wire                    serv1_M1_wvalid;
    wire                    serv1_M1_wready;

    wire [ID_WIDTH-1:0]     serv1_M1_bid;
    wire [1:0]              serv1_M1_bresp;
    wire                    serv1_M1_bvalid;
    wire                    serv1_M1_bready;

    wire [ID_WIDTH-1:0]     serv1_M1_arid;
    wire [ADDR_WIDTH-1:0]   serv1_M1_araddr;
    wire [7:0]              serv1_M1_arlen;
    wire [2:0]              serv1_M1_arsize;
    wire [1:0]              serv1_M1_arburst;
    wire [1:0]              serv1_M1_arlock;
    wire [3:0]              serv1_M1_arcache;
    wire [2:0]              serv1_M1_arprot;
    wire [3:0]              serv1_M1_arqos;
    wire [3:0]              serv1_M1_arregion;
    wire                    serv1_M1_arvalid;
    wire                    serv1_M1_arready;
    wire [ID_WIDTH-1:0]     serv1_M1_rid;
    wire [DATA_WIDTH-1:0]   serv1_M1_rdata;
    wire [1:0]              serv1_M1_rresp;
    wire                    serv1_M1_rlast;
    wire                    serv1_M1_rvalid;
    wire                    serv1_M1_rready;

    serv_axi_wrapper #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .RESET_PC (32'h0000_0000)  // Reset to RAM base address
    ) u_serv1 (
        .ACLK       (ACLK),
        .ARESETN    (ARESETN),
        .i_timer_irq(serv1_timer_irq),
        .M0_AXI_arid   (serv1_M0_arid),
        .M0_AXI_araddr (serv1_M0_araddr),
        .M0_AXI_arlen  (serv1_M0_arlen),
        .M0_AXI_arsize (serv1_M0_arsize),
        .M0_AXI_arburst(serv1_M0_arburst),
        .M0_AXI_arlock (serv1_M0_arlock),
        .M0_AXI_arcache(serv1_M0_arcache),
        .M0_AXI_arprot (serv1_M0_arprot),
        .M0_AXI_arqos  (serv1_M0_arqos),
        .M0_AXI_arregion(serv1_M0_arregion),
        .M0_AXI_arvalid(serv1_M0_arvalid),
        .M0_AXI_arready(serv1_M0_arready),
        .M0_AXI_rid    (serv1_M0_rid),
        .M0_AXI_rdata  (serv1_M0_rdata),
        .M0_AXI_rresp  (serv1_M0_rresp),
        .M0_AXI_rlast  (serv1_M0_rlast),
        .M0_AXI_rvalid (serv1_M0_rvalid),
        .M0_AXI_rready (serv1_M0_rready),
        .M1_AXI_awid   (serv1_M1_awid),
        .M1_AXI_awaddr (serv1_M1_awaddr),
        .M1_AXI_awlen  (serv1_M1_awlen),
        .M1_AXI_awsize (serv1_M1_awsize),
        .M1_AXI_awburst(serv1_M1_awburst),
        .M1_AXI_awlock (serv1_M1_awlock),
        .M1_AXI_awcache(serv1_M1_awcache),
        .M1_AXI_awprot (serv1_M1_awprot),
        .M1_AXI_awqos  (serv1_M1_awqos),
        .M1_AXI_awregion(serv1_M1_awregion),
        .M1_AXI_awvalid(serv1_M1_awvalid),
        .M1_AXI_awready(serv1_M1_awready),
        .M1_AXI_wdata  (serv1_M1_wdata),
        .M1_AXI_wstrb  (serv1_M1_wstrb),
        .M1_AXI_wlast  (serv1_M1_wlast),
        .M1_AXI_wvalid (serv1_M1_wvalid),
        .M1_AXI_wready (serv1_M1_wready),
        .M1_AXI_bid    (serv1_M1_bid),
        .M1_AXI_bresp  (serv1_M1_bresp),
        .M1_AXI_bvalid (serv1_M1_bvalid),
        .M1_AXI_bready (serv1_M1_bready),
        .M1_AXI_arid   (serv1_M1_arid),
        .M1_AXI_araddr (serv1_M1_araddr),
        .M1_AXI_arlen  (serv1_M1_arlen),
        .M1_AXI_arsize (serv1_M1_arsize),
        .M1_AXI_arburst(serv1_M1_arburst),
        .M1_AXI_arlock (serv1_M1_arlock),
        .M1_AXI_arcache(serv1_M1_arcache),
        .M1_AXI_arprot (serv1_M1_arprot),
        .M1_AXI_arqos  (serv1_M1_arqos),
        .M1_AXI_arregion(serv1_M1_arregion),
        .M1_AXI_arvalid(serv1_M1_arvalid),
        .M1_AXI_arready(serv1_M1_arready),
        .M1_AXI_rid    (serv1_M1_rid),
        .M1_AXI_rdata  (serv1_M1_rdata),
        .M1_AXI_rresp  (serv1_M1_rresp),
        .M1_AXI_rlast  (serv1_M1_rlast),
        .M1_AXI_rvalid (serv1_M1_rvalid),
        .M1_AXI_rready (serv1_M1_rready)
    );

    // =========================================================================
    // SERV AXI adapters (collapse dual bus into single AXI-Lite master)
    // =========================================================================
    wire [ADDR_WIDTH-1:0] serv0_axi_awaddr;
    wire [2:0]            serv0_axi_awprot;
    wire                  serv0_axi_awvalid;
    wire                  serv0_axi_awready;
    wire [DATA_WIDTH-1:0] serv0_axi_wdata;
    wire [(DATA_WIDTH/8)-1:0] serv0_axi_wstrb;
    wire                  serv0_axi_wvalid;
    wire                  serv0_axi_wready;
    wire [1:0]            serv0_axi_bresp;
    wire                  serv0_axi_bvalid;
    wire                  serv0_axi_bready;
    wire [ADDR_WIDTH-1:0] serv0_axi_araddr;
    wire [2:0]            serv0_axi_arprot;
    wire                  serv0_axi_arvalid;
    wire                  serv0_axi_arready;
    wire [DATA_WIDTH-1:0] serv0_axi_rdata;
    wire [1:0]            serv0_axi_rresp;
    wire                  serv0_axi_rvalid;
    wire                  serv0_axi_rlast;
    wire                  serv0_axi_rready;

    serv_axi_dualbus_adapter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH  (ID_WIDTH)
    ) u_serv0_adapter (
        .ACLK   (ACLK),
        .ARESETN(ARESETN),
        .inst_arid    (serv0_M0_arid),
        .inst_araddr  (serv0_M0_araddr),
        .inst_arlen   (serv0_M0_arlen),
        .inst_arsize  (serv0_M0_arsize),
        .inst_arburst (serv0_M0_arburst),
        .inst_arlock  (serv0_M0_arlock),
        .inst_arcache (serv0_M0_arcache),
        .inst_arprot  (serv0_M0_arprot),
        .inst_arqos   (serv0_M0_arqos),
        .inst_arregion(serv0_M0_arregion),
        .inst_arvalid (serv0_M0_arvalid),
        .inst_arready (serv0_M0_arready),
        .inst_rid     (serv0_M0_rid),
        .inst_rdata   (serv0_M0_rdata),
        .inst_rresp   (serv0_M0_rresp),
        .inst_rlast   (serv0_M0_rlast),
        .inst_rvalid  (serv0_M0_rvalid),
        .inst_rready  (serv0_M0_rready),
        .data_awid    (serv0_M1_awid),
        .data_awaddr  (serv0_M1_awaddr),
        .data_awlen   (serv0_M1_awlen),
        .data_awsize  (serv0_M1_awsize),
        .data_awburst (serv0_M1_awburst),
        .data_awlock  (serv0_M1_awlock),
        .data_awcache (serv0_M1_awcache),
        .data_awprot  (serv0_M1_awprot),
        .data_awqos   (serv0_M1_awqos),
        .data_awregion(serv0_M1_awregion),
        .data_awvalid (serv0_M1_awvalid),
        .data_awready (serv0_M1_awready),
        .data_wdata   (serv0_M1_wdata),
        .data_wstrb   (serv0_M1_wstrb),
        .data_wlast   (serv0_M1_wlast),
        .data_wvalid  (serv0_M1_wvalid),
        .data_wready  (serv0_M1_wready),
        .data_bid     (serv0_M1_bid),
        .data_bresp   (serv0_M1_bresp),
        .data_bvalid  (serv0_M1_bvalid),
        .data_bready  (serv0_M1_bready),
        .data_arid    (serv0_M1_arid),
        .data_araddr  (serv0_M1_araddr),
        .data_arlen   (serv0_M1_arlen),
        .data_arsize  (serv0_M1_arsize),
        .data_arburst (serv0_M1_arburst),
        .data_arlock  (serv0_M1_arlock),
        .data_arcache (serv0_M1_arcache),
        .data_arprot  (serv0_M1_arprot),
        .data_arqos   (serv0_M1_arqos),
        .data_arregion(serv0_M1_arregion),
        .data_arvalid (serv0_M1_arvalid),
        .data_arready (serv0_M1_arready),
        .data_rid     (serv0_M1_rid),
        .data_rdata   (serv0_M1_rdata),
        .data_rresp   (serv0_M1_rresp),
        .data_rlast   (serv0_M1_rlast),
        .data_rvalid  (serv0_M1_rvalid),
        .data_rready  (serv0_M1_rready),
        .AXI_awaddr   (serv0_axi_awaddr),
        .AXI_awprot   (serv0_axi_awprot),
        .AXI_awvalid  (serv0_axi_awvalid),
        .AXI_awready  (serv0_axi_awready),
        .AXI_wdata    (serv0_axi_wdata),
        .AXI_wstrb    (serv0_axi_wstrb),
        .AXI_wvalid   (serv0_axi_wvalid),
        .AXI_wready   (serv0_axi_wready),
        .AXI_bresp    (serv0_axi_bresp),
        .AXI_bvalid   (serv0_axi_bvalid),
        .AXI_bready   (serv0_axi_bready),
        .AXI_araddr   (serv0_axi_araddr),
        .AXI_arprot   (serv0_axi_arprot),
        .AXI_arvalid  (serv0_axi_arvalid),
        .AXI_arready  (serv0_axi_arready),
        .AXI_rdata    (serv0_axi_rdata),
        .AXI_rresp    (serv0_axi_rresp),
        .AXI_rvalid   (serv0_axi_rvalid),
        .AXI_rlast    (serv0_axi_rlast),
        .AXI_rready   (serv0_axi_rready)
    );

    wire [ADDR_WIDTH-1:0] serv1_axi_awaddr;
    wire [2:0]            serv1_axi_awprot;
    wire                  serv1_axi_awvalid;
    wire                  serv1_axi_awready;
    wire [DATA_WIDTH-1:0] serv1_axi_wdata;
    wire [(DATA_WIDTH/8)-1:0] serv1_axi_wstrb;
    wire                  serv1_axi_wvalid;
    wire                  serv1_axi_wready;
    wire [1:0]            serv1_axi_bresp;
    wire                  serv1_axi_bvalid;
    wire                  serv1_axi_bready;
    wire [ADDR_WIDTH-1:0] serv1_axi_araddr;
    wire [2:0]            serv1_axi_arprot;
    wire                  serv1_axi_arvalid;
    wire                  serv1_axi_arready;
    wire [DATA_WIDTH-1:0] serv1_axi_rdata;
    wire [1:0]            serv1_axi_rresp;
    wire                  serv1_axi_rvalid;
    wire                  serv1_axi_rlast;
    wire                  serv1_axi_rready;

    serv_axi_dualbus_adapter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH  (ID_WIDTH)
    ) u_serv1_adapter (
        .ACLK   (ACLK),
        .ARESETN(ARESETN),
        .inst_arid    (serv1_M0_arid),
        .inst_araddr  (serv1_M0_araddr),
        .inst_arlen   (serv1_M0_arlen),
        .inst_arsize  (serv1_M0_arsize),
        .inst_arburst (serv1_M0_arburst),
        .inst_arlock  (serv1_M0_arlock),
        .inst_arcache (serv1_M0_arcache),
        .inst_arprot  (serv1_M0_arprot),
        .inst_arqos   (serv1_M0_arqos),
        .inst_arregion(serv1_M0_arregion),
        .inst_arvalid (serv1_M0_arvalid),
        .inst_arready (serv1_M0_arready),
        .inst_rid     (serv1_M0_rid),
        .inst_rdata   (serv1_M0_rdata),
        .inst_rresp   (serv1_M0_rresp),
        .inst_rlast   (serv1_M0_rlast),
        .inst_rvalid  (serv1_M0_rvalid),
        .inst_rready  (serv1_M0_rready),
        .data_awid    (serv1_M1_awid),
        .data_awaddr  (serv1_M1_awaddr),
        .data_awlen   (serv1_M1_awlen),
        .data_awsize  (serv1_M1_awsize),
        .data_awburst (serv1_M1_awburst),
        .data_awlock  (serv1_M1_awlock),
        .data_awcache (serv1_M1_awcache),
        .data_awprot  (serv1_M1_awprot),
        .data_awqos   (serv1_M1_awqos),
        .data_awregion(serv1_M1_awregion),
        .data_awvalid (serv1_M1_awvalid),
        .data_awready (serv1_M1_awready),
        .data_wdata   (serv1_M1_wdata),
        .data_wstrb   (serv1_M1_wstrb),
        .data_wlast   (serv1_M1_wlast),
        .data_wvalid  (serv1_M1_wvalid),
        .data_wready  (serv1_M1_wready),
        .data_bid     (serv1_M1_bid),
        .data_bresp   (serv1_M1_bresp),
        .data_bvalid  (serv1_M1_bvalid),
        .data_bready  (serv1_M1_bready),
        .data_arid    (serv1_M1_arid),
        .data_araddr  (serv1_M1_araddr),
        .data_arlen   (serv1_M1_arlen),
        .data_arsize  (serv1_M1_arsize),
        .data_arburst (serv1_M1_arburst),
        .data_arlock  (serv1_M1_arlock),
        .data_arcache (serv1_M1_arcache),
        .data_arprot  (serv1_M1_arprot),
        .data_arqos   (serv1_M1_arqos),
        .data_arregion(serv1_M1_arregion),
        .data_arvalid (serv1_M1_arvalid),
        .data_arready (serv1_M1_arready),
        .data_rid     (serv1_M1_rid),
        .data_rdata   (serv1_M1_rdata),
        .data_rresp   (serv1_M1_rresp),
        .data_rlast   (serv1_M1_rlast),
        .data_rvalid  (serv1_M1_rvalid),
        .data_rready  (serv1_M1_rready),
        .AXI_awaddr   (serv1_axi_awaddr),
        .AXI_awprot   (serv1_axi_awprot),
        .AXI_awvalid  (serv1_axi_awvalid),
        .AXI_awready  (serv1_axi_awready),
        .AXI_wdata    (serv1_axi_wdata),
        .AXI_wstrb    (serv1_axi_wstrb),
        .AXI_wvalid   (serv1_axi_wvalid),
        .AXI_wready   (serv1_axi_wready),
        .AXI_bresp    (serv1_axi_bresp),
        .AXI_bvalid   (serv1_axi_bvalid),
        .AXI_bready   (serv1_axi_bready),
        .AXI_araddr   (serv1_axi_araddr),
        .AXI_arprot   (serv1_axi_arprot),
        .AXI_arvalid  (serv1_axi_arvalid),
        .AXI_arready  (serv1_axi_arready),
        .AXI_rdata    (serv1_axi_rdata),
        .AXI_rresp    (serv1_axi_rresp),
        .AXI_rvalid   (serv1_axi_rvalid),
        .AXI_rlast    (serv1_axi_rlast),
        .AXI_rready   (serv1_axi_rready)
    );

    // =========================================================================
    // Round-robin crossbar (2 masters -> 4 slaves)
    // =========================================================================
    wire [ADDR_WIDTH-1:0] S0_awaddr;
    wire [2:0]            S0_awprot;
    wire                  S0_awvalid;
    wire                  S0_awready;
    wire [DATA_WIDTH-1:0] S0_wdata;
    wire [(DATA_WIDTH/8)-1:0] S0_wstrb;
    wire                  S0_wvalid;
    wire                  S0_wready;
    wire [1:0]            S0_bresp;
    wire                  S0_bvalid;
    wire                  S0_bready;
    wire [ADDR_WIDTH-1:0] S0_araddr;
    wire [2:0]            S0_arprot;
    wire                  S0_arvalid;
    wire                  S0_arready;
    wire [DATA_WIDTH-1:0] S0_rdata;
    wire [1:0]            S0_rresp;
    wire                  S0_rvalid;
    wire                  S0_rlast;
    wire                  S0_rready;

    wire [ADDR_WIDTH-1:0] S1_awaddr;
    wire [2:0]            S1_awprot;
    wire                  S1_awvalid;
    wire                  S1_awready;
    wire [DATA_WIDTH-1:0] S1_wdata;
    wire [(DATA_WIDTH/8)-1:0] S1_wstrb;
    wire                  S1_wvalid;
    wire                  S1_wready;
    wire [1:0]            S1_bresp;
    wire                  S1_bvalid;
    wire                  S1_bready;
    wire [ADDR_WIDTH-1:0] S1_araddr;
    wire [2:0]            S1_arprot;
    wire                  S1_arvalid;
    wire                  S1_arready;
    wire [DATA_WIDTH-1:0] S1_rdata;
    wire [1:0]            S1_rresp;
    wire                  S1_rvalid;
    wire                  S1_rlast;
    wire                  S1_rready;

    wire [ADDR_WIDTH-1:0] S2_awaddr;
    wire [2:0]            S2_awprot;
    wire                  S2_awvalid;
    wire                  S2_awready;
    wire [DATA_WIDTH-1:0] S2_wdata;
    wire [(DATA_WIDTH/8)-1:0] S2_wstrb;
    wire                  S2_wvalid;
    wire                  S2_wready;
    wire [1:0]            S2_bresp;
    wire                  S2_bvalid;
    wire                  S2_bready;
    wire [ADDR_WIDTH-1:0] S2_araddr;
    wire [2:0]            S2_arprot;
    wire                  S2_arvalid;
    wire                  S2_arready;
    wire [DATA_WIDTH-1:0] S2_rdata;
    wire [1:0]            S2_rresp;
    wire                  S2_rvalid;
    wire                  S2_rlast;
    wire                  S2_rready;

    wire [ADDR_WIDTH-1:0] S3_awaddr;
    wire [2:0]            S3_awprot;
    wire                  S3_awvalid;
    wire                  S3_awready;
    wire [DATA_WIDTH-1:0] S3_wdata;
    wire [(DATA_WIDTH/8)-1:0] S3_wstrb;
    wire                  S3_wvalid;
    wire                  S3_wready;
    wire [1:0]            S3_bresp;
    wire                  S3_bvalid;
    wire                  S3_bready;
    wire [ADDR_WIDTH-1:0] S3_araddr;
    wire [2:0]            S3_arprot;
    wire                  S3_arvalid;
    wire                  S3_arready;
    wire [DATA_WIDTH-1:0] S3_rdata;
    wire [1:0]            S3_rresp;
    wire                  S3_rvalid;
    wire                  S3_rlast;
    wire                  S3_rready;

    AXI_Interconnect #(
        .ARBITRATION_MODE(1)  // 0=FIXED_PRIORITY, 1=ROUND_ROBIN, 2=QOS_BASED
    ) u_axi_interconnect (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        // Master 0 (SERV0) - Full AXI4
        .M0_AWADDR (serv0_axi_awaddr),
        .M0_AWLEN  (8'h00),                // AXI-Lite: single transfer
        .M0_AWSIZE (3'b010),               // 4 bytes
        .M0_AWBURST(2'b01),                // INCR
        .M0_AWVALID(serv0_axi_awvalid),
        .M0_AWREADY(serv0_axi_awready),
        .M0_WDATA  (serv0_axi_wdata),
        .M0_WSTRB  (serv0_axi_wstrb),
        .M0_WLAST  (1'b1),                 // Always last (single transfer)
        .M0_WVALID (serv0_axi_wvalid),
        .M0_WREADY (serv0_axi_wready),
        .M0_BRESP  (serv0_axi_bresp),
        .M0_BVALID (serv0_axi_bvalid),
        .M0_BREADY (serv0_axi_bready),
        .M0_ARADDR (serv0_axi_araddr),
        .M0_ARLEN  (8'h00),                // AXI-Lite: single transfer
        .M0_ARSIZE (3'b010),               // 4 bytes
        .M0_ARBURST(2'b01),                // INCR
        .M0_ARVALID(serv0_axi_arvalid),
        .M0_ARREADY(serv0_axi_arready),
        .M0_RDATA  (serv0_axi_rdata),
        .M0_RRESP  (serv0_axi_rresp),
        .M0_RLAST  (serv0_axi_rlast),
        .M0_RVALID (serv0_axi_rvalid),
        .M0_RREADY (serv0_axi_rready),
        // Master 1 (SERV1) - Full AXI4
        .M1_AWADDR (serv1_axi_awaddr),
        .M1_AWLEN  (8'h00),                // AXI-Lite: single transfer
        .M1_AWSIZE (3'b010),               // 4 bytes
        .M1_AWBURST(2'b01),                // INCR
        .M1_AWVALID(serv1_axi_awvalid),
        .M1_AWREADY(serv1_axi_awready),
        .M1_WDATA  (serv1_axi_wdata),
        .M1_WSTRB  (serv1_axi_wstrb),
        .M1_WLAST  (1'b1),                 // Always last (single transfer)
        .M1_WVALID (serv1_axi_wvalid),
        .M1_WREADY (serv1_axi_wready),
        .M1_BRESP  (serv1_axi_bresp),
        .M1_BVALID (serv1_axi_bvalid),
        .M1_BREADY (serv1_axi_bready),
        .M1_ARADDR (serv1_axi_araddr),
        .M1_ARLEN  (8'h00),                // AXI-Lite: single transfer
        .M1_ARSIZE (3'b010),               // 4 bytes
        .M1_ARBURST(2'b01),                // INCR
        .M1_ARVALID(serv1_axi_arvalid),
        .M1_ARREADY(serv1_axi_arready),
        .M1_RDATA  (serv1_axi_rdata),
        .M1_RRESP  (serv1_axi_rresp),
        .M1_RLAST  (serv1_axi_rlast),
        .M1_RVALID (serv1_axi_rvalid),
        .M1_RREADY (serv1_axi_rready),
        // Slave 0 (RAM)
        .S0_AWADDR (S0_awaddr),
        .S0_AWLEN  (),                     // Not used by slaves
        .S0_AWSIZE (),
        .S0_AWBURST(),
        .S0_AWVALID(S0_awvalid),
        .S0_AWREADY(S0_awready),
        .S0_WDATA  (S0_wdata),
        .S0_WSTRB  (S0_wstrb),
        .S0_WLAST  (),
        .S0_WVALID (S0_wvalid),
        .S0_WREADY (S0_wready),
        .S0_BRESP  (S0_bresp),
        .S0_BVALID (S0_bvalid),
        .S0_BREADY (S0_bready),
        .S0_ARADDR (S0_araddr),
        .S0_ARLEN  (),
        .S0_ARSIZE (),
        .S0_ARBURST(),
        .S0_ARVALID(S0_arvalid),
        .S0_ARREADY(S0_arready),
        .S0_RDATA  (S0_rdata),
        .S0_RRESP  (S0_rresp),
        .S0_RLAST  (S0_rlast),
        .S0_RVALID (S0_rvalid),
        .S0_RREADY (S0_rready),
        // Slave 1 (GPIO)
        .S1_AWADDR (S1_awaddr),
        .S1_AWLEN  (),
        .S1_AWSIZE (),
        .S1_AWBURST(),
        .S1_AWVALID(S1_awvalid),
        .S1_AWREADY(S1_awready),
        .S1_WDATA  (S1_wdata),
        .S1_WSTRB  (S1_wstrb),
        .S1_WLAST  (),
        .S1_WVALID (S1_wvalid),
        .S1_WREADY (S1_wready),
        .S1_BRESP  (S1_bresp),
        .S1_BVALID (S1_bvalid),
        .S1_BREADY (S1_bready),
        .S1_ARADDR (S1_araddr),
        .S1_ARLEN  (),
        .S1_ARSIZE (),
        .S1_ARBURST(),
        .S1_ARVALID(S1_arvalid),
        .S1_ARREADY(S1_arready),
        .S1_RDATA  (S1_rdata),
        .S1_RRESP  (S1_rresp),
        .S1_RLAST  (S1_rlast),
        .S1_RVALID (S1_rvalid),
        .S1_RREADY (S1_rready),
        // Slave 2 (UART)
        .S2_AWADDR (S2_awaddr),
        .S2_AWLEN  (),
        .S2_AWSIZE (),
        .S2_AWBURST(),
        .S2_AWVALID(S2_awvalid),
        .S2_AWREADY(S2_awready),
        .S2_WDATA  (S2_wdata),
        .S2_WSTRB  (S2_wstrb),
        .S2_WLAST  (),
        .S2_WVALID (S2_wvalid),
        .S2_WREADY (S2_wready),
        .S2_BRESP  (S2_bresp),
        .S2_BVALID (S2_bvalid),
        .S2_BREADY (S2_bready),
        .S2_ARADDR (S2_araddr),
        .S2_ARLEN  (),
        .S2_ARSIZE (),
        .S2_ARBURST(),
        .S2_ARVALID(S2_arvalid),
        .S2_ARREADY(S2_arready),
        .S2_RDATA  (S2_rdata),
        .S2_RRESP  (S2_rresp),
        .S2_RLAST  (S2_rlast),
        .S2_RVALID (S2_rvalid),
        .S2_RREADY (S2_rready),
        // Slave 3 (SPI)
        .S3_AWADDR (S3_awaddr),
        .S3_AWLEN  (),
        .S3_AWSIZE (),
        .S3_AWBURST(),
        .S3_AWVALID(S3_awvalid),
        .S3_AWREADY(S3_awready),
        .S3_WDATA  (S3_wdata),
        .S3_WSTRB  (S3_wstrb),
        .S3_WLAST  (),
        .S3_WVALID (S3_wvalid),
        .S3_WREADY (S3_wready),
        .S3_BRESP  (S3_bresp),
        .S3_BVALID (S3_bvalid),
        .S3_BREADY (S3_bready),
        .S3_ARADDR (S3_araddr),
        .S3_ARLEN  (),
        .S3_ARSIZE (),
        .S3_ARBURST(),
        .S3_ARVALID(S3_arvalid),
        .S3_ARREADY(S3_arready),
        .S3_RDATA  (S3_rdata),
        .S3_RRESP  (S3_rresp),
        .S3_RLAST  (S3_rlast),
        .S3_RVALID (S3_rvalid),
        .S3_RREADY (S3_rready)
    );

    // =========================================================================
    // Slave instantiations
    // =========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS (RAM_WORDS),
        .INIT_HEX  (RAM_INIT_HEX)
    ) u_sram (
        .ACLK        (ACLK),
        .ARESETN     (ARESETN),
        .S_AXI_awaddr(S0_awaddr),
        .S_AXI_awprot(S0_awprot),
        .S_AXI_awvalid(S0_awvalid),
        .S_AXI_awready(S0_awready),
        .S_AXI_wdata (S0_wdata),
        .S_AXI_wstrb (S0_wstrb),
        .S_AXI_wvalid(S0_wvalid),
        .S_AXI_wready(S0_wready),
        .S_AXI_bresp (S0_bresp),
        .S_AXI_bvalid(S0_bvalid),
        .S_AXI_bready(S0_bready),
        .S_AXI_araddr(S0_araddr),
        .S_AXI_arprot(S0_arprot),
        .S_AXI_arvalid(S0_arvalid),
        .S_AXI_arready(S0_arready),
        .S_AXI_rdata (S0_rdata),
        .S_AXI_rresp (S0_rresp),
        .S_AXI_rvalid(S0_rvalid),
        .S_AXI_rlast (S0_rlast),
        .S_AXI_rready(S0_rready)
    );

    axi_lite_gpio u_gpio (
        .ACLK        (ACLK),
        .ARESETN     (ARESETN),
        .S_AXI_awaddr(S1_awaddr),
        .S_AXI_awprot(S1_awprot),
        .S_AXI_awvalid(S1_awvalid),
        .S_AXI_awready(S1_awready),
        .S_AXI_wdata (S1_wdata),
        .S_AXI_wstrb (S1_wstrb),
        .S_AXI_wvalid(S1_wvalid),
        .S_AXI_wready(S1_wready),
        .S_AXI_bresp (S1_bresp),
        .S_AXI_bvalid(S1_bvalid),
        .S_AXI_bready(S1_bready),
        .S_AXI_araddr(S1_araddr),
        .S_AXI_arprot(S1_arprot),
        .S_AXI_arvalid(S1_arvalid),
        .S_AXI_arready(S1_arready),
        .S_AXI_rdata (S1_rdata),
        .S_AXI_rresp (S1_rresp),
        .S_AXI_rvalid(S1_rvalid),
        .S_AXI_rlast (S1_rlast),
        .S_AXI_rready(S1_rready),
        .gpio_in     (gpio_in),
        .gpio_out    (gpio_out)
    );

    axi_lite_uart u_uart (
        .ACLK        (ACLK),
        .ARESETN     (ARESETN),
        .S_AXI_awaddr(S2_awaddr),
        .S_AXI_awprot(S2_awprot),
        .S_AXI_awvalid(S2_awvalid),
        .S_AXI_awready(S2_awready),
        .S_AXI_wdata (S2_wdata),
        .S_AXI_wstrb (S2_wstrb),
        .S_AXI_wvalid(S2_wvalid),
        .S_AXI_wready(S2_wready),
        .S_AXI_bresp (S2_bresp),
        .S_AXI_bvalid(S2_bvalid),
        .S_AXI_bready(S2_bready),
        .S_AXI_araddr(S2_araddr),
        .S_AXI_arprot(S2_arprot),
        .S_AXI_arvalid(S2_arvalid),
        .S_AXI_arready(S2_arready),
        .S_AXI_rdata (S2_rdata),
        .S_AXI_rresp (S2_rresp),
        .S_AXI_rvalid(S2_rvalid),
        .S_AXI_rlast (S2_rlast),
        .S_AXI_rready(S2_rready),
        .tx_valid    (uart_tx_valid),
        .tx_byte     (uart_tx_byte)
    );

    axi_lite_spi u_spi (
        .ACLK        (ACLK),
        .ARESETN     (ARESETN),
        .S_AXI_awaddr(S3_awaddr),
        .S_AXI_awprot(S3_awprot),
        .S_AXI_awvalid(S3_awvalid),
        .S_AXI_awready(S3_awready),
        .S_AXI_wdata (S3_wdata),
        .S_AXI_wstrb (S3_wstrb),
        .S_AXI_wvalid(S3_wvalid),
        .S_AXI_wready(S3_wready),
        .S_AXI_bresp (S3_bresp),
        .S_AXI_bvalid(S3_bvalid),
        .S_AXI_bready(S3_bready),
        .S_AXI_araddr(S3_araddr),
        .S_AXI_arprot(S3_arprot),
        .S_AXI_arvalid(S3_arvalid),
        .S_AXI_arready(S3_arready),
        .S_AXI_rdata (S3_rdata),
        .S_AXI_rresp (S3_rresp),
        .S_AXI_rvalid(S3_rvalid),
        .S_AXI_rlast (S3_rlast),
        .S_AXI_rready(S3_rready),
        .spi_cs_n    (spi_cs_n),
        .spi_sclk    (spi_sclk),
        .spi_mosi    (spi_mosi),
        .spi_miso    (spi_miso)
    );

endmodule

