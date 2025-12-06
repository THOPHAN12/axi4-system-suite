// ==============================================================================
// RV32I Pipeline AXI System - Complete Integration
// ==============================================================================
// 1 × RV32I CPU (2 AXI masters) + AXI Interconnect + 4 Peripherals
// Based on verified dual_riscv_axi_system.v pattern
//
// Date: December 5, 2025
// ==============================================================================

module riscv_pipeline_axi_system #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter RAM_WORDS  = 2048,  // 8KB
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
    
    // Debug
    output wire [31:0] debug_pc,
    output wire [31:0] debug_r1,
    output wire [31:0] debug_r2
);

// ==============================================================================
// RV32I to Interconnect Signals
// ==============================================================================
// Instruction Master (M0)
wire [31:0] riscv_instr_araddr;
wire [2:0]  riscv_instr_arprot;
wire        riscv_instr_arvalid;
wire        riscv_instr_arready;
wire [31:0] riscv_instr_rdata;
wire [1:0]  riscv_instr_rresp;
wire        riscv_instr_rvalid;
wire        riscv_instr_rready;

// Data Master (M1)
wire [31:0] riscv_data_awaddr;
wire [2:0]  riscv_data_awprot;
wire        riscv_data_awvalid;
wire        riscv_data_awready;
wire [31:0] riscv_data_wdata;
wire [3:0]  riscv_data_wstrb;
wire        riscv_data_wvalid;
wire        riscv_data_wready;
wire [1:0]  riscv_data_bresp;
wire        riscv_data_bvalid;
wire        riscv_data_bready;
wire [31:0] riscv_data_araddr;
wire [2:0]  riscv_data_arprot;
wire        riscv_data_arvalid;
wire        riscv_data_arready;
wire [31:0] riscv_data_rdata;
wire [1:0]  riscv_data_rresp;
wire        riscv_data_rvalid;
wire        riscv_data_rready;

// ==============================================================================
// RV32I Pipeline with AXI Wrapper
// ==============================================================================
riscv_pipeline_axi_wrapper u_riscv_cpu (
    .clk(ACLK),
    .rst_n(ARESETN),
    
    // Instruction AXI
    .m_axi_instr_araddr(riscv_instr_araddr),
    .m_axi_instr_arprot(riscv_instr_arprot),
    .m_axi_instr_arvalid(riscv_instr_arvalid),
    .m_axi_instr_arready(riscv_instr_arready),
    .m_axi_instr_rdata(riscv_instr_rdata),
    .m_axi_instr_rresp(riscv_instr_rresp),
    .m_axi_instr_rvalid(riscv_instr_rvalid),
    .m_axi_instr_rready(riscv_instr_rready),
    
    // Data AXI
    .m_axi_data_awaddr(riscv_data_awaddr),
    .m_axi_data_awprot(riscv_data_awprot),
    .m_axi_data_awvalid(riscv_data_awvalid),
    .m_axi_data_awready(riscv_data_awready),
    .m_axi_data_wdata(riscv_data_wdata),
    .m_axi_data_wstrb(riscv_data_wstrb),
    .m_axi_data_wvalid(riscv_data_wvalid),
    .m_axi_data_wready(riscv_data_wready),
    .m_axi_data_bresp(riscv_data_bresp),
    .m_axi_data_bvalid(riscv_data_bvalid),
    .m_axi_data_bready(riscv_data_bready),
    .m_axi_data_araddr(riscv_data_araddr),
    .m_axi_data_arprot(riscv_data_arprot),
    .m_axi_data_arvalid(riscv_data_arvalid),
    .m_axi_data_arready(riscv_data_arready),
    .m_axi_data_rdata(riscv_data_rdata),
    .m_axi_data_rresp(riscv_data_rresp),
    .m_axi_data_rvalid(riscv_data_rvalid),
    .m_axi_data_rready(riscv_data_rready),
    
    // Debug
    .debug_pc(debug_pc),
    .debug_r1(debug_r1),
    .debug_r2(debug_r2),
    .debug_zero()
);

// ==============================================================================
// Interconnect to Slave Signals
// ==============================================================================
// Slave 0 (RAM)
wire [31:0] S0_awaddr, S0_wdata, S0_araddr, S0_rdata;
wire [2:0]  S0_awprot, S0_arprot;
wire [3:0]  S0_wstrb;
wire [1:0]  S0_bresp, S0_rresp;
wire        S0_awvalid, S0_awready, S0_wvalid, S0_wready;
wire        S0_bvalid, S0_bready, S0_arvalid, S0_arready;
wire        S0_rvalid, S0_rready, S0_rlast;

// Slave 1 (GPIO)
wire [31:0] S1_awaddr, S1_wdata, S1_araddr, S1_rdata;
wire [2:0]  S1_awprot, S1_arprot;
wire [3:0]  S1_wstrb;
wire [1:0]  S1_bresp, S1_rresp;
wire        S1_awvalid, S1_awready, S1_wvalid, S1_wready;
wire        S1_bvalid, S1_bready, S1_arvalid, S1_arready;
wire        S1_rvalid, S1_rready, S1_rlast;

// Slave 2 (UART)
wire [31:0] S2_awaddr, S2_wdata, S2_araddr, S2_rdata;
wire [2:0]  S2_awprot, S2_arprot;
wire [3:0]  S2_wstrb;
wire [1:0]  S2_bresp, S2_rresp;
wire        S2_awvalid, S2_awready, S2_wvalid, S2_wready;
wire        S2_bvalid, S2_bready, S2_arvalid, S2_arready;
wire        S2_rvalid, S2_rready, S2_rlast;

// Slave 3 (SPI)
wire [31:0] S3_awaddr, S3_wdata, S3_araddr, S3_rdata;
wire [2:0]  S3_awprot, S3_arprot;
wire [3:0]  S3_wstrb;
wire [1:0]  S3_bresp, S3_rresp;
wire        S3_awvalid, S3_awready, S3_wvalid, S3_wready;
wire        S3_bvalid, S3_bready, S3_arvalid, S3_arready;
wire        S3_rvalid, S3_rready, S3_rlast;

// ==============================================================================
// AXI Interconnect (2M × 4S) - FIXED ARBITRATION!
// ==============================================================================
AXI_Interconnect #(
    .ARBITRATION_MODE(1)  // Round-Robin (verified 50/50!)
) u_axi_interconnect (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    
    // ========================================================================
    // Master 0: RV32I Instruction (Read-only)
    // ========================================================================
    .M0_AWADDR(32'h0),
    .M0_AWLEN(8'h00),
    .M0_AWSIZE(3'b010),
    .M0_AWBURST(2'b01),
    .M0_AWVALID(1'b0),
    .M0_AWREADY(),
    .M0_WDATA(32'h0),
    .M0_WSTRB(4'h0),
    .M0_WLAST(1'b1),
    .M0_WVALID(1'b0),
    .M0_WREADY(),
    .M0_BRESP(),
    .M0_BVALID(),
    .M0_BREADY(1'b0),
    .M0_ARADDR(riscv_instr_araddr),
    .M0_ARLEN(8'h00),
    .M0_ARSIZE(3'b010),
    .M0_ARBURST(2'b01),
    .M0_ARVALID(riscv_instr_arvalid),
    .M0_ARREADY(riscv_instr_arready),
    .M0_RDATA(riscv_instr_rdata),
    .M0_RRESP(riscv_instr_rresp),
    .M0_RLAST(),
    .M0_RVALID(riscv_instr_rvalid),
    .M0_RREADY(riscv_instr_rready),
    
    // ========================================================================
    // Master 1: RV32I Data (Read/Write)
    // ========================================================================
    .M1_AWADDR(riscv_data_awaddr),
    .M1_AWLEN(8'h00),
    .M1_AWSIZE(3'b010),
    .M1_AWBURST(2'b01),
    .M1_AWVALID(riscv_data_awvalid),
    .M1_AWREADY(riscv_data_awready),
    .M1_WDATA(riscv_data_wdata),
    .M1_WSTRB(riscv_data_wstrb),
    .M1_WLAST(1'b1),
    .M1_WVALID(riscv_data_wvalid),
    .M1_WREADY(riscv_data_wready),
    .M1_BRESP(riscv_data_bresp),
    .M1_BVALID(riscv_data_bvalid),
    .M1_BREADY(riscv_data_bready),
    .M1_ARADDR(riscv_data_araddr),
    .M1_ARLEN(8'h00),
    .M1_ARSIZE(3'b010),
    .M1_ARBURST(2'b01),
    .M1_ARVALID(riscv_data_arvalid),
    .M1_ARREADY(riscv_data_arready),
    .M1_RDATA(riscv_data_rdata),
    .M1_RRESP(riscv_data_rresp),
    .M1_RLAST(),
    .M1_RVALID(riscv_data_rvalid),
    .M1_RREADY(riscv_data_rready),
    
    // ========================================================================
    // Slave 0: RAM
    // ========================================================================
    .S0_AWADDR(S0_awaddr),
    .S0_AWLEN(),
    .S0_AWSIZE(),
    .S0_AWBURST(),
    .S0_AWVALID(S0_awvalid),
    .S0_AWREADY(S0_awready),
    .S0_WDATA(S0_wdata),
    .S0_WSTRB(S0_wstrb),
    .S0_WLAST(),
    .S0_WVALID(S0_wvalid),
    .S0_WREADY(S0_wready),
    .S0_BRESP(S0_bresp),
    .S0_BVALID(S0_bvalid),
    .S0_BREADY(S0_bready),
    .S0_ARADDR(S0_araddr),
    .S0_ARLEN(),
    .S0_ARSIZE(),
    .S0_ARBURST(),
    .S0_ARVALID(S0_arvalid),
    .S0_ARREADY(S0_arready),
    .S0_RDATA(S0_rdata),
    .S0_RRESP(S0_rresp),
    .S0_RLAST(S0_rlast),
    .S0_RVALID(S0_rvalid),
    .S0_RREADY(S0_rready),
    
    // ========================================================================
    // Slave 1: GPIO
    // ========================================================================
    .S1_AWADDR(S1_awaddr),
    .S1_AWLEN(),
    .S1_AWSIZE(),
    .S1_AWBURST(),
    .S1_AWVALID(S1_awvalid),
    .S1_AWREADY(S1_awready),
    .S1_WDATA(S1_wdata),
    .S1_WSTRB(S1_wstrb),
    .S1_WLAST(),
    .S1_WVALID(S1_wvalid),
    .S1_WREADY(S1_wready),
    .S1_BRESP(S1_bresp),
    .S1_BVALID(S1_bvalid),
    .S1_BREADY(S1_bready),
    .S1_ARADDR(S1_araddr),
    .S1_ARLEN(),
    .S1_ARSIZE(),
    .S1_ARBURST(),
    .S1_ARVALID(S1_arvalid),
    .S1_ARREADY(S1_arready),
    .S1_RDATA(S1_rdata),
    .S1_RRESP(S1_rresp),
    .S1_RLAST(S1_rlast),
    .S1_RVALID(S1_rvalid),
    .S1_RREADY(S1_rready),
    
    // ========================================================================
    // Slave 2: UART
    // ========================================================================
    .S2_AWADDR(S2_awaddr),
    .S2_AWLEN(),
    .S2_AWSIZE(),
    .S2_AWBURST(),
    .S2_AWVALID(S2_awvalid),
    .S2_AWREADY(S2_awready),
    .S2_WDATA(S2_wdata),
    .S2_WSTRB(S2_wstrb),
    .S2_WLAST(),
    .S2_WVALID(S2_wvalid),
    .S2_WREADY(S2_wready),
    .S2_BRESP(S2_bresp),
    .S2_BVALID(S2_bvalid),
    .S2_BREADY(S2_bready),
    .S2_ARADDR(S2_araddr),
    .S2_ARLEN(),
    .S2_ARSIZE(),
    .S2_ARBURST(),
    .S2_ARVALID(S2_arvalid),
    .S2_ARREADY(S2_arready),
    .S2_RDATA(S2_rdata),
    .S2_RRESP(S2_rresp),
    .S2_RLAST(S2_rlast),
    .S2_RVALID(S2_rvalid),
    .S2_RREADY(S2_rready),
    
    // ========================================================================
    // Slave 3: SPI
    // ========================================================================
    .S3_AWADDR(S3_awaddr),
    .S3_AWLEN(),
    .S3_AWSIZE(),
    .S3_AWBURST(),
    .S3_AWVALID(S3_awvalid),
    .S3_AWREADY(S3_awready),
    .S3_WDATA(S3_wdata),
    .S3_WSTRB(S3_wstrb),
    .S3_WLAST(),
    .S3_WVALID(S3_wvalid),
    .S3_WREADY(S3_wready),
    .S3_BRESP(S3_bresp),
    .S3_BVALID(S3_bvalid),
    .S3_BREADY(S3_bready),
    .S3_ARADDR(S3_araddr),
    .S3_ARLEN(),
    .S3_ARSIZE(),
    .S3_ARBURST(),
    .S3_ARVALID(S3_arvalid),
    .S3_ARREADY(S3_arready),
    .S3_RDATA(S3_rdata),
    .S3_RRESP(S3_rresp),
    .S3_RLAST(S3_rlast),
    .S3_RVALID(S3_rvalid),
    .S3_RREADY(S3_rready)
);

// ==============================================================================
// Peripheral Instances
// ==============================================================================

// Slave 0: RAM
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

// Slave 1: GPIO
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

// Slave 2: UART
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

// Slave 3: SPI
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
