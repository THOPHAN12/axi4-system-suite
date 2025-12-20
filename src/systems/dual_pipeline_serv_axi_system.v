// ==============================================================================
// Dual Pipeline + SERV AXI System
// ==============================================================================
// 1 × riscv-5stage-pipeline core (pipeline) + 1 × SERV core
// Mỗi core có 2 AXI-Lite masters (Instr, Data) => 4 masters
// Gộp qua 2 AXI Master Aggregators -> 2 masters, đưa vào dual_axi_shell (2M x 4S)
// Slaves: RAM, GPIO, UART, SPI (AXI-Lite)
// ==============================================================================

`timescale 1ns/1ps

// Note: All modules are already compiled into work library
// No need for include statements when compiling from GUI
// Make sure to compile dependencies first

module dual_pipeline_serv_axi_system #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter RAM_WORDS  = 2048,              // 8KB
    parameter RAM_INIT_HEX = "testdata/test_program.hex"
)(
    input wire ACLK,
    input wire ARESETN,

    // GPIO
    input  wire [31:0] gpio_in,
    output wire [31:0] gpio_out,

    // UART
    output wire uart_tx_valid,
    output wire [7:0] uart_tx_byte,

    // SPI
    output wire spi_cs_n,
    output wire spi_sclk,
    output wire spi_mosi,
    input  wire spi_miso,

    // Debug - Pipeline
    output wire [31:0] pipeline_debug_pc,
    output wire [31:0] pipeline_debug_r1,
    output wire [31:0] pipeline_debug_r2,

    // Debug - SERV
    output wire [31:0] serv_debug_pc,
    output wire [31:0] serv_debug_r1,
    output wire [31:0] serv_debug_r2
);

// ==============================================================================
// AXI signals from core wrappers (4 masters)
// ==============================================================================
// Pipeline core
wire [ADDR_WIDTH-1:0] P_M_ARADDR, P_M_AWADDR, P_M_WDATA, P_M_ARADDR_D;
wire [DATA_WIDTH-1:0] P_M_RDATA, P_M_RDATA_D, P_M_WDATA_D;
wire [3:0]            P_M_WSTRB_D;
wire [1:0]            P_M_RRESP, P_M_RRESP_D, P_M_BRESP_D;
wire                  P_M_ARVALID, P_M_ARREADY, P_M_RVALID, P_M_RREADY;
wire                  P_M_AWVALID_D, P_M_AWREADY_D, P_M_WVALID_D, P_M_WREADY_D;
wire                  P_M_BVALID_D, P_M_BREADY_D, P_M_ARVALID_D, P_M_ARREADY_D, P_M_RVALID_D, P_M_RREADY_D;

// SERV core
wire [ADDR_WIDTH-1:0] S_M_ARADDR, S_M_AWADDR, S_M_WDATA, S_M_ARADDR_D;
wire [DATA_WIDTH-1:0] S_M_RDATA, S_M_RDATA_D, S_M_WDATA_D;
wire [3:0]            S_M_WSTRB_D;
wire [1:0]            S_M_RRESP, S_M_RRESP_D, S_M_BRESP_D;
wire                  S_M_ARVALID, S_M_ARREADY, S_M_RVALID, S_M_RREADY;
wire                  S_M_AWVALID_D, S_M_AWREADY_D, S_M_WVALID_D, S_M_WREADY_D;
wire                  S_M_BVALID_D, S_M_BREADY_D, S_M_ARVALID_D, S_M_ARREADY_D, S_M_RVALID_D, S_M_RREADY_D;

// ==============================================================================
// Aggregated masters (2)
// ==============================================================================
wire [ADDR_WIDTH-1:0] AGG0_ARADDR, AGG1_ARADDR, AGG1_AWADDR, AGG1_WDATA;
wire [DATA_WIDTH-1:0] AGG0_RDATA, AGG1_RDATA;
wire [3:0]            AGG1_WSTRB;
wire [1:0]            AGG0_RRESP, AGG1_RRESP, AGG1_BRESP;
wire                  AGG0_ARVALID, AGG0_ARREADY, AGG0_RVALID, AGG0_RREADY, AGG0_RLAST;
wire                  AGG1_AWVALID, AGG1_AWREADY, AGG1_WVALID, AGG1_WREADY, AGG1_WLAST;
wire                  AGG1_ARVALID, AGG1_ARREADY, AGG1_RVALID, AGG1_RREADY, AGG1_RLAST;
wire                  AGG1_BVALID, AGG1_BREADY;
wire [7:0]            AGG0_ARLEN, AGG1_AWLEN, AGG1_ARLEN;
wire [2:0]            AGG0_ARSIZE, AGG1_AWSIZE, AGG1_ARSIZE;
wire [1:0]            AGG0_ARBURST, AGG1_AWBURST, AGG1_ARBURST;

// ==============================================================================
// Peripherals AXI-Lite signals
// ==============================================================================
wire [ADDR_WIDTH-1:0] S0_awaddr, S0_wdata, S0_araddr, S0_rdata;
wire [2:0]  S0_awprot, S0_arprot;
wire [3:0]  S0_wstrb;
wire [1:0]  S0_bresp, S0_rresp;
wire        S0_awvalid, S0_awready, S0_wvalid, S0_wready;
wire        S0_bvalid, S0_bready, S0_arvalid, S0_arready;
wire        S0_rvalid, S0_rready, S0_rlast;

wire [ADDR_WIDTH-1:0] S1_awaddr, S1_wdata, S1_araddr, S1_rdata;
wire [2:0]  S1_awprot, S1_arprot;
wire [3:0]  S1_wstrb;
wire [1:0]  S1_bresp, S1_rresp;
wire        S1_awvalid, S1_awready, S1_wvalid, S1_wready;
wire        S1_bvalid, S1_bready, S1_arvalid, S1_arready;
wire        S1_rvalid, S1_rready, S1_rlast;

wire [ADDR_WIDTH-1:0] S2_awaddr, S2_wdata, S2_araddr, S2_rdata;
wire [2:0]  S2_awprot, S2_arprot;
wire [3:0]  S2_wstrb;
wire [1:0]  S2_bresp, S2_rresp;
wire        S2_awvalid, S2_awready, S2_wvalid, S2_wready;
wire        S2_bvalid, S2_bready, S2_arvalid, S2_arready;
wire        S2_rvalid, S2_rready, S2_rlast;

wire [ADDR_WIDTH-1:0] S3_awaddr, S3_wdata, S3_araddr, S3_rdata;
wire [2:0]  S3_awprot, S3_arprot;
wire [3:0]  S3_wstrb;
wire [1:0]  S3_bresp, S3_rresp;
wire        S3_awvalid, S3_awready, S3_wvalid, S3_wready;
wire        S3_bvalid, S3_bready, S3_arvalid, S3_arready;
wire        S3_rvalid, S3_rready, S3_rlast;

// ==============================================================================
// Core wrappers
// ==============================================================================
riscv_pipeline_axi_wrapper #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_pipeline (
    .clk(ACLK),
    .rst_n(ARESETN),
    // Instruction (read-only)
    .m_axi_instr_araddr(P_M_ARADDR),
    .m_axi_instr_arprot(),
    .m_axi_instr_arvalid(P_M_ARVALID),
    .m_axi_instr_arready(P_M_ARREADY),
    .m_axi_instr_rdata(P_M_RDATA),
    .m_axi_instr_rresp(P_M_RRESP),
    .m_axi_instr_rvalid(P_M_RVALID),
    .m_axi_instr_rready(P_M_RREADY),
    // Data
    .m_axi_data_awaddr(P_M_AWADDR),
    .m_axi_data_awprot(),
    .m_axi_data_awvalid(P_M_AWVALID_D),
    .m_axi_data_awready(P_M_AWREADY_D),
    .m_axi_data_wdata(P_M_WDATA_D),
    .m_axi_data_wstrb(P_M_WSTRB_D),
    .m_axi_data_wvalid(P_M_WVALID_D),
    .m_axi_data_wready(P_M_WREADY_D),
    .m_axi_data_bresp(P_M_BRESP_D),
    .m_axi_data_bvalid(P_M_BVALID_D),
    .m_axi_data_bready(P_M_BREADY_D),
    .m_axi_data_araddr(P_M_ARADDR_D),
    .m_axi_data_arprot(),
    .m_axi_data_arvalid(P_M_ARVALID_D),
    .m_axi_data_arready(P_M_ARREADY_D),
    .m_axi_data_rdata(P_M_RDATA_D),
    .m_axi_data_rresp(P_M_RRESP_D),
    .m_axi_data_rvalid(P_M_RVALID_D),
    .m_axi_data_rready(P_M_RREADY_D),
    // Debug
    .debug_pc(pipeline_debug_pc),
    .debug_r1(pipeline_debug_r1),
    .debug_r2(pipeline_debug_r2),
    .debug_zero()
);

serv_axi_wrapper #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) u_serv (
    .clk(ACLK),
    .rst_n(ARESETN),
    // Instruction
    .m_axi_instr_araddr(S_M_ARADDR),
    .m_axi_instr_arprot(),
    .m_axi_instr_arvalid(S_M_ARVALID),
    .m_axi_instr_arready(S_M_ARREADY),
    .m_axi_instr_rdata(S_M_RDATA),
    .m_axi_instr_rresp(S_M_RRESP),
    .m_axi_instr_rvalid(S_M_RVALID),
    .m_axi_instr_rready(S_M_RREADY),
    // Data
    .m_axi_data_awaddr(S_M_AWADDR),
    .m_axi_data_awprot(),
    .m_axi_data_awvalid(S_M_AWVALID_D),
    .m_axi_data_awready(S_M_AWREADY_D),
    .m_axi_data_wdata(S_M_WDATA_D),
    .m_axi_data_wstrb(S_M_WSTRB_D),
    .m_axi_data_wvalid(S_M_WVALID_D),
    .m_axi_data_wready(S_M_WREADY_D),
    .m_axi_data_bresp(S_M_BRESP_D),
    .m_axi_data_bvalid(S_M_BVALID_D),
    .m_axi_data_bready(S_M_BREADY_D),
    .m_axi_data_araddr(S_M_ARADDR_D),
    .m_axi_data_arprot(),
    .m_axi_data_arvalid(S_M_ARVALID_D),
    .m_axi_data_arready(S_M_ARREADY_D),
    .m_axi_data_rdata(S_M_RDATA_D),
    .m_axi_data_rresp(S_M_RRESP_D),
    .m_axi_data_rvalid(S_M_RVALID_D),
    .m_axi_data_rready(S_M_RREADY_D),
    // Debug
    .debug_pc(serv_debug_pc),
    .debug_r1(serv_debug_r1),
    .debug_r2(serv_debug_r2),
    .debug_zero()
);

// ==============================================================================
// Aggregators: 4 masters -> 2 masters
// ==============================================================================
AXI_Master_Aggregator #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_MASTERS(2)
) u_instr_agg (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // M0 = pipeline instr
    .M0_ARADDR(P_M_ARADDR), .M0_ARPROT(3'b000), .M0_ARVALID(P_M_ARVALID), .M0_ARREADY(P_M_ARREADY),
    .M0_RDATA(P_M_RDATA), .M0_RRESP(P_M_RRESP), .M0_RVALID(P_M_RVALID), .M0_RREADY(P_M_RREADY),
    .M0_AWADDR(32'h0), .M0_AWPROT(3'b0), .M0_AWVALID(1'b0), .M0_AWREADY(),
    .M0_WDATA(32'h0), .M0_WSTRB(4'h0), .M0_WVALID(1'b0), .M0_WREADY(),
    .M0_BRESP(), .M0_BVALID(), .M0_BREADY(1'b0),
    // M1 = serv instr
    .M1_ARADDR(S_M_ARADDR), .M1_ARPROT(3'b000), .M1_ARVALID(S_M_ARVALID), .M1_ARREADY(S_M_ARREADY),
    .M1_RDATA(S_M_RDATA), .M1_RRESP(S_M_RRESP), .M1_RVALID(S_M_RVALID), .M1_RREADY(S_M_RREADY),
    .M1_AWADDR(32'h0), .M1_AWPROT(3'b0), .M1_AWVALID(1'b0), .M1_AWREADY(),
    .M1_WDATA(32'h0), .M1_WSTRB(4'h0), .M1_WVALID(1'b0), .M1_WREADY(),
    .M1_BRESP(), .M1_BVALID(), .M1_BREADY(1'b0),
    // Unused M2
    .M2_ARADDR(32'h0), .M2_ARPROT(3'b0), .M2_ARVALID(1'b0), .M2_ARREADY(),
    .M2_RDATA(), .M2_RRESP(), .M2_RVALID(), .M2_RREADY(1'b0),
    .M2_AWADDR(32'h0), .M2_AWPROT(3'b0), .M2_AWVALID(1'b0), .M2_AWREADY(),
    .M2_WDATA(32'h0), .M2_WSTRB(4'h0), .M2_WVALID(1'b0), .M2_WREADY(),
    .M2_BRESP(), .M2_BVALID(), .M2_BREADY(1'b0),
    // Out
    .M_ARADDR(AGG0_ARADDR),
    .M_ARPROT(),
    .M_ARVALID(AGG0_ARVALID),
    .M_ARREADY(AGG0_ARREADY),
    .M_RDATA(AGG0_RDATA),
    .M_RRESP(AGG0_RRESP),
    .M_RVALID(AGG0_RVALID),
    .M_RREADY(AGG0_RREADY),
    .M_AWADDR(), .M_AWPROT(), .M_AWVALID(), .M_AWREADY(1'b0),
    .M_WDATA(), .M_WSTRB(), .M_WVALID(), .M_WREADY(1'b0),
    .M_BRESP(2'b0), .M_BVALID(1'b0), .M_BREADY()
);

AXI_Master_Aggregator #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_MASTERS(2)
) u_data_agg (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // M0 = pipeline data
    .M0_ARADDR(P_M_ARADDR_D), .M0_ARPROT(3'b000), .M0_ARVALID(P_M_ARVALID_D), .M0_ARREADY(P_M_ARREADY_D),
    .M0_RDATA(P_M_RDATA_D), .M0_RRESP(P_M_RRESP_D), .M0_RVALID(P_M_RVALID_D), .M0_RREADY(P_M_RREADY_D),
    .M0_AWADDR(P_M_AWADDR), .M0_AWPROT(3'b000), .M0_AWVALID(P_M_AWVALID_D), .M0_AWREADY(P_M_AWREADY_D),
    .M0_WDATA(P_M_WDATA_D), .M0_WSTRB(P_M_WSTRB_D), .M0_WVALID(P_M_WVALID_D), .M0_WREADY(P_M_WREADY_D),
    .M0_BRESP(P_M_BRESP_D), .M0_BVALID(P_M_BVALID_D), .M0_BREADY(P_M_BREADY_D),
    // M1 = serv data
    .M1_ARADDR(S_M_ARADDR_D), .M1_ARPROT(3'b000), .M1_ARVALID(S_M_ARVALID_D), .M1_ARREADY(S_M_ARREADY_D),
    .M1_RDATA(S_M_RDATA_D), .M1_RRESP(S_M_RRESP_D), .M1_RVALID(S_M_RVALID_D), .M1_RREADY(S_M_RREADY_D),
    .M1_AWADDR(S_M_AWADDR), .M1_AWPROT(3'b000), .M1_AWVALID(S_M_AWVALID_D), .M1_AWREADY(S_M_AWREADY_D),
    .M1_WDATA(S_M_WDATA_D), .M1_WSTRB(S_M_WSTRB_D), .M1_WVALID(S_M_WVALID_D), .M1_WREADY(S_M_WREADY_D),
    .M1_BRESP(S_M_BRESP_D), .M1_BVALID(S_M_BVALID_D), .M1_BREADY(S_M_BREADY_D),
    // Unused M2
    .M2_ARADDR(32'h0), .M2_ARPROT(3'b0), .M2_ARVALID(1'b0), .M2_ARREADY(),
    .M2_RDATA(), .M2_RRESP(), .M2_RVALID(), .M2_RREADY(1'b0),
    .M2_AWADDR(32'h0), .M2_AWPROT(3'b0), .M2_AWVALID(1'b0), .M2_AWREADY(),
    .M2_WDATA(32'h0), .M2_WSTRB(4'h0), .M2_WVALID(1'b0), .M2_WREADY(),
    .M2_BRESP(), .M2_BVALID(), .M2_BREADY(1'b0),
    // Out
    .M_ARADDR(AGG1_ARADDR),
    .M_ARPROT(),
    .M_ARVALID(AGG1_ARVALID),
    .M_ARREADY(AGG1_ARREADY),
    .M_RDATA(AGG1_RDATA),
    .M_RRESP(AGG1_RRESP),
    .M_RVALID(AGG1_RVALID),
    .M_RREADY(AGG1_RREADY),
    .M_AWADDR(AGG1_AWADDR),
    .M_AWPROT(),
    .M_AWVALID(AGG1_AWVALID),
    .M_AWREADY(AGG1_AWREADY),
    .M_WDATA(AGG1_WDATA),
    .M_WSTRB(AGG1_WSTRB),
    .M_WVALID(AGG1_WVALID),
    .M_WREADY(AGG1_WREADY),
    .M_BRESP(AGG1_BRESP),
    .M_BVALID(AGG1_BVALID),
    .M_BREADY(AGG1_BREADY)
);

// ==============================================================================
// AXI-Lite defaults (burst/len/size, last)
// ==============================================================================
assign AGG0_ARLEN   = 8'h00;
assign AGG0_ARSIZE  = 3'b010;
assign AGG0_ARBURST = 2'b01;
assign AGG0_RLAST   = 1'b1;

assign AGG1_AWLEN   = 8'h00;
assign AGG1_AWSIZE  = 3'b010;
assign AGG1_AWBURST = 2'b01;
assign AGG1_WLAST   = 1'b1;
assign AGG1_ARLEN   = 8'h00;
assign AGG1_ARSIZE  = 3'b010;
assign AGG1_ARBURST = 2'b01;
assign AGG1_RLAST   = 1'b1;

// ==============================================================================
// dual_axi_shell (2M -> 4S)
// ==============================================================================
dual_axi_shell #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) u_dual_shell (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // Master 0 = AGG0 (Instr only)
    .M0_AWADDR(32'h0), .M0_AWLEN(8'h0), .M0_AWSIZE(3'b0), .M0_AWBURST(2'b0),
    .M0_AWVALID(1'b0), .M0_AWREADY(),
    .M0_WDATA(32'h0), .M0_WSTRB(4'h0), .M0_WLAST(1'b0), .M0_WVALID(1'b0), .M0_WREADY(),
    .M0_BRESP(), .M0_BVALID(), .M0_BREADY(1'b0),
    .M0_ARADDR(AGG0_ARADDR), .M0_ARLEN(AGG0_ARLEN), .M0_ARSIZE(AGG0_ARSIZE), .M0_ARBURST(AGG0_ARBURST),
    .M0_ARVALID(AGG0_ARVALID), .M0_ARREADY(AGG0_ARREADY),
    .M0_RDATA(AGG0_RDATA), .M0_RRESP(AGG0_RRESP), .M0_RLAST(AGG0_RLAST),
    .M0_RVALID(AGG0_RVALID), .M0_RREADY(AGG0_RREADY),
    // Master 1 = AGG1 (Data)
    .M1_AWADDR(AGG1_AWADDR), .M1_AWLEN(AGG1_AWLEN), .M1_AWSIZE(AGG1_AWSIZE), .M1_AWBURST(AGG1_AWBURST),
    .M1_AWVALID(AGG1_AWVALID), .M1_AWREADY(AGG1_AWREADY),
    .M1_WDATA(AGG1_WDATA), .M1_WSTRB(AGG1_WSTRB), .M1_WLAST(AGG1_WLAST), .M1_WVALID(AGG1_WVALID), .M1_WREADY(AGG1_WREADY),
    .M1_BRESP(AGG1_BRESP), .M1_BVALID(AGG1_BVALID), .M1_BREADY(AGG1_BREADY),
    .M1_ARADDR(AGG1_ARADDR), .M1_ARLEN(AGG1_ARLEN), .M1_ARSIZE(AGG1_ARSIZE), .M1_ARBURST(AGG1_ARBURST),
    .M1_ARVALID(AGG1_ARVALID), .M1_ARREADY(AGG1_ARREADY),
    .M1_RDATA(AGG1_RDATA), .M1_RRESP(AGG1_RRESP), .M1_RLAST(AGG1_RLAST),
    .M1_RVALID(AGG1_RVALID), .M1_RREADY(AGG1_RREADY),
    // Slaves passthrough to peripherals
    .S0_AWADDR(S0_awaddr), .S0_AWLEN(), .S0_AWSIZE(), .S0_AWBURST(), .S0_AWVALID(S0_awvalid), .S0_AWREADY(S0_awready),
    .S0_WDATA(S0_wdata), .S0_WSTRB(S0_wstrb), .S0_WLAST(), .S0_WVALID(S0_wvalid), .S0_WREADY(S0_wready),
    .S0_BRESP(S0_bresp), .S0_BVALID(S0_bvalid), .S0_BREADY(S0_bready),
    .S0_ARADDR(S0_araddr), .S0_ARLEN(), .S0_ARSIZE(), .S0_ARBURST(), .S0_ARVALID(S0_arvalid), .S0_ARREADY(S0_arready),
    .S0_RDATA(S0_rdata), .S0_RRESP(S0_rresp), .S0_RLAST(S0_rlast), .S0_RVALID(S0_rvalid), .S0_RREADY(S0_rready),

    .S1_AWADDR(S1_awaddr), .S1_AWLEN(), .S1_AWSIZE(), .S1_AWBURST(), .S1_AWVALID(S1_awvalid), .S1_AWREADY(S1_awready),
    .S1_WDATA(S1_wdata), .S1_WSTRB(S1_wstrb), .S1_WLAST(), .S1_WVALID(S1_wvalid), .S1_WREADY(S1_wready),
    .S1_BRESP(S1_bresp), .S1_BVALID(S1_bvalid), .S1_BREADY(S1_bready),
    .S1_ARADDR(S1_araddr), .S1_ARLEN(), .S1_ARSIZE(), .S1_ARBURST(), .S1_ARVALID(S1_arvalid), .S1_ARREADY(S1_arready),
    .S1_RDATA(S1_rdata), .S1_RRESP(S1_rresp), .S1_RLAST(S1_rlast), .S1_RVALID(S1_rvalid), .S1_RREADY(S1_rready),

    .S2_AWADDR(S2_awaddr), .S2_AWLEN(), .S2_AWSIZE(), .S2_AWBURST(), .S2_AWVALID(S2_awvalid), .S2_AWREADY(S2_awready),
    .S2_WDATA(S2_wdata), .S2_WSTRB(S2_wstrb), .S2_WLAST(), .S2_WVALID(S2_wvalid), .S2_WREADY(S2_wready),
    .S2_BRESP(S2_bresp), .S2_BVALID(S2_bvalid), .S2_BREADY(S2_bready),
    .S2_ARADDR(S2_araddr), .S2_ARLEN(), .S2_ARSIZE(), .S2_ARBURST(), .S2_ARVALID(S2_arvalid), .S2_ARREADY(S2_arready),
    .S2_RDATA(S2_rdata), .S2_RRESP(S2_rresp), .S2_RLAST(S2_rlast), .S2_RVALID(S2_rvalid), .S2_RREADY(S2_rready),

    .S3_AWADDR(S3_awaddr), .S3_AWLEN(), .S3_AWSIZE(), .S3_AWBURST(), .S3_AWVALID(S3_awvalid), .S3_AWREADY(S3_awready),
    .S3_WDATA(S3_wdata), .S3_WSTRB(S3_wstrb), .S3_WLAST(), .S3_WVALID(S3_wvalid), .S3_WREADY(S3_wready),
    .S3_BRESP(S3_bresp), .S3_BVALID(S3_bvalid), .S3_BREADY(S3_bready),
    .S3_ARADDR(S3_araddr), .S3_ARLEN(), .S3_ARSIZE(), .S3_ARBURST(), .S3_ARVALID(S3_arvalid), .S3_ARREADY(S3_arready),
    .S3_RDATA(S3_rdata), .S3_RRESP(S3_rresp), .S3_RLAST(S3_rlast), .S3_RVALID(S3_rvalid), .S3_RREADY(S3_rready)
);

// ==============================================================================
// Peripherals
// ==============================================================================
axi_lite_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .MEM_WORDS(RAM_WORDS),
    .INIT_HEX(RAM_INIT_HEX)
) u_sram (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .S_AXI_awaddr(S0_awaddr),
    .S_AXI_awprot(S0_awprot),
    .S_AXI_awvalid(S0_awvalid),
    .S_AXI_awready(S0_awready),
    .S_AXI_wdata(S0_wdata),
    .S_AXI_wstrb(S0_wstrb),
    .S_AXI_wvalid(S0_wvalid),
    .S_AXI_wready(S0_wready),
    .S_AXI_bresp(S0_bresp),
    .S_AXI_bvalid(S0_bvalid),
    .S_AXI_bready(S0_bready),
    .S_AXI_araddr(S0_araddr),
    .S_AXI_arprot(S0_arprot),
    .S_AXI_arvalid(S0_arvalid),
    .S_AXI_arready(S0_arready),
    .S_AXI_rdata(S0_rdata),
    .S_AXI_rresp(S0_rresp),
    .S_AXI_rvalid(S0_rvalid),
    .S_AXI_rlast(S0_rlast),
    .S_AXI_rready(S0_rready)
);

axi_lite_gpio u_gpio (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .S_AXI_awaddr(S1_awaddr),
    .S_AXI_awprot(S1_awprot),
    .S_AXI_awvalid(S1_awvalid),
    .S_AXI_awready(S1_awready),
    .S_AXI_wdata(S1_wdata),
    .S_AXI_wstrb(S1_wstrb),
    .S_AXI_wvalid(S1_wvalid),
    .S_AXI_wready(S1_wready),
    .S_AXI_bresp(S1_bresp),
    .S_AXI_bvalid(S1_bvalid),
    .S_AXI_bready(S1_bready),
    .S_AXI_araddr(S1_araddr),
    .S_AXI_arprot(S1_arprot),
    .S_AXI_arvalid(S1_arvalid),
    .S_AXI_arready(S1_arready),
    .S_AXI_rdata(S1_rdata),
    .S_AXI_rresp(S1_rresp),
    .S_AXI_rvalid(S1_rvalid),
    .S_AXI_rlast(S1_rlast),
    .S_AXI_rready(S1_rready),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out)
);

axi_lite_uart u_uart (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .S_AXI_awaddr(S2_awaddr),
    .S_AXI_awprot(S2_awprot),
    .S_AXI_awvalid(S2_awvalid),
    .S_AXI_awready(S2_awready),
    .S_AXI_wdata(S2_wdata),
    .S_AXI_wstrb(S2_wstrb),
    .S_AXI_wvalid(S2_wvalid),
    .S_AXI_wready(S2_wready),
    .S_AXI_bresp(S2_bresp),
    .S_AXI_bvalid(S2_bvalid),
    .S_AXI_bready(S2_bready),
    .S_AXI_araddr(S2_araddr),
    .S_AXI_arprot(S2_arprot),
    .S_AXI_arvalid(S2_arvalid),
    .S_AXI_arready(S2_arready),
    .S_AXI_rdata(S2_rdata),
    .S_AXI_rresp(S2_rresp),
    .S_AXI_rvalid(S2_rvalid),
    .S_AXI_rlast(S2_rlast),
    .S_AXI_rready(S2_rready),
    .tx_valid(uart_tx_valid),
    .tx_byte(uart_tx_byte)
);

axi_lite_spi u_spi (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .S_AXI_awaddr(S3_awaddr),
    .S_AXI_awprot(S3_awprot),
    .S_AXI_awvalid(S3_awvalid),
    .S_AXI_awready(S3_awready),
    .S_AXI_wdata(S3_wdata),
    .S_AXI_wstrb(S3_wstrb),
    .S_AXI_wvalid(S3_wvalid),
    .S_AXI_wready(S3_wready),
    .S_AXI_bresp(S3_bresp),
    .S_AXI_bvalid(S3_bvalid),
    .S_AXI_bready(S3_bready),
    .S_AXI_araddr(S3_araddr),
    .S_AXI_arprot(S3_arprot),
    .S_AXI_arvalid(S3_arvalid),
    .S_AXI_arready(S3_arready),
    .S_AXI_rdata(S3_rdata),
    .S_AXI_rresp(S3_rresp),
    .S_AXI_rvalid(S3_rvalid),
    .S_AXI_rlast(S3_rlast),
    .S_AXI_rready(S3_rready),
    .spi_cs_n(spi_cs_n),
    .spi_sclk(spi_sclk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso)
);

endmodule

