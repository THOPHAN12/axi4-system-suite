`timescale 1ns/1ps

/*
 * axi_interconnect_wrapper.v
 * 
 * Wrapper module cho AXI_Interconnect để cung cấp interface đơn giản hóa
 * và tích hợp dễ dàng vào các hệ thống lớn hơn.
 * 
 * Module này bọc AXI_Interconnect với:
 * - Interface đơn giản hóa cho Master và Slave
 * - Tự động xử lý các tín hiệu không sử dụng
 * - Hỗ trợ cấu hình address range
 * - Clock và reset domain management
 * 
 * Architecture:
 * 
 *     [Master 0]  [Master 1]
 *         |            |
 *         +-----+------+
 *               |
 *    [AXI_Interconnect_Wrapper]
 *               |
 *         +-----+------+
 *         |            |
 *     [Slave 0]   [Slave 1]
 */

module axi_interconnect_wrapper #(
    // Address Configuration Parameters
    parameter [31:0] SLAVE0_ADDR_START = 32'h0000_0000,
    parameter [31:0] SLAVE0_ADDR_END   = 32'h3FFF_FFFF,
    parameter [31:0] SLAVE1_ADDR_START = 32'h4000_0000,
    parameter [31:0] SLAVE1_ADDR_END   = 32'h7FFF_FFFF,
    
    // Data Width Parameters
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ARLEN_WIDTH = 4,
    parameter ARSIZE_WIDTH = 3,
    parameter ARBURST_WIDTH = 2,
    parameter RRESP_WIDTH = 2
) (
    // ========================================================================
    // Global Signals
    // ========================================================================
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ========================================================================
    // Master 0 Interface (Read Only)
    // ========================================================================
    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0]   M0_ARADDR,
    input  wire [ARLEN_WIDTH-1:0]  M0_ARLEN,
    input  wire [ARSIZE_WIDTH-1:0] M0_ARSIZE,
    input  wire [ARBURST_WIDTH-1:0] M0_ARBURST,
    input  wire                    M0_ARVALID,
    output wire                    M0_ARREADY,
    
    // Read Data Channel
    output wire [DATA_WIDTH-1:0]   M0_RDATA,
    output wire [RRESP_WIDTH-1:0]   M0_RRESP,
    output wire                    M0_RLAST,
    output wire                    M0_RVALID,
    input  wire                    M0_RREADY,
    
    // ========================================================================
    // Master 1 Interface (Read Only)
    // ========================================================================
    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0]   M1_ARADDR,
    input  wire [ARLEN_WIDTH-1:0]  M1_ARLEN,
    input  wire [ARSIZE_WIDTH-1:0] M1_ARSIZE,
    input  wire [ARBURST_WIDTH-1:0] M1_ARBURST,
    input  wire                    M1_ARVALID,
    output wire                    M1_ARREADY,
    
    // Read Data Channel
    output wire [DATA_WIDTH-1:0]   M1_RDATA,
    output wire [RRESP_WIDTH-1:0]   M1_RRESP,
    output wire                    M1_RLAST,
    output wire                    M1_RVALID,
    input  wire                    M1_RREADY,
    
    // ========================================================================
    // Slave 0 Interface (Read Only)
    // ========================================================================
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]   S0_ARADDR,
    output wire [ARLEN_WIDTH-1:0]  S0_ARLEN,
    output wire [ARSIZE_WIDTH-1:0] S0_ARSIZE,
    output wire [ARBURST_WIDTH-1:0] S0_ARBURST,
    output wire                    S0_ARVALID,
    input  wire                    S0_ARREADY,
    
    // Read Data Channel
    input  wire [DATA_WIDTH-1:0]   S0_RDATA,
    input  wire [RRESP_WIDTH-1:0]   S0_RRESP,
    input  wire                    S0_RLAST,
    input  wire                    S0_RVALID,
    output wire                    S0_RREADY,
    
    // ========================================================================
    // Slave 1 Interface (Read Only)
    // ========================================================================
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]   S1_ARADDR,
    output wire [ARLEN_WIDTH-1:0]  S1_ARLEN,
    output wire [ARSIZE_WIDTH-1:0] S1_ARSIZE,
    output wire [ARBURST_WIDTH-1:0] S1_ARBURST,
    output wire                    S1_ARVALID,
    input  wire                    S1_ARREADY,
    
    // Read Data Channel
    input  wire [DATA_WIDTH-1:0]   S1_RDATA,
    input  wire [RRESP_WIDTH-1:0]   S1_RRESP,
    input  wire                    S1_RLAST,
    input  wire                    S1_RVALID,
    output wire                    S1_RREADY,
    
    // ========================================================================
    // Optional: Address Range Override (if needed)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   slave0_addr1_override,  // Optional override
    input  wire [ADDR_WIDTH-1:0]   slave0_addr2_override,  // Optional override
    input  wire [ADDR_WIDTH-1:0]   slave1_addr1_override,  // Optional override
    input  wire [ADDR_WIDTH-1:0]   slave1_addr2_override,  // Optional override
    input  wire                    use_address_override     // Enable override
);

    // ========================================================================
    // Internal Signals
    // ========================================================================
    
    // Address range selection
    wire [ADDR_WIDTH-1:0] slave0_addr1;
    wire [ADDR_WIDTH-1:0] slave0_addr2;
    wire [ADDR_WIDTH-1:0] slave1_addr1;
    wire [ADDR_WIDTH-1:0] slave1_addr2;
    
    // Address range mux
    assign slave0_addr1 = use_address_override ? slave0_addr1_override : SLAVE0_ADDR_START;
    assign slave0_addr2 = use_address_override ? slave0_addr2_override : SLAVE0_ADDR_END;
    assign slave1_addr1 = use_address_override ? slave1_addr1_override : SLAVE1_ADDR_START;
    assign slave1_addr2 = use_address_override ? slave1_addr2_override : SLAVE1_ADDR_END;
    
    // Reset signal conversion (ARESETN active low -> G_reset active high)
    wire G_reset = ~ARESETN;
    
    // ========================================================================
    // AXI_Interconnect Instance
    // ========================================================================
    AXI_Interconnect u_axi_interconnect (
        // Global signals
        .G_clk           (ACLK),
        .G_reset         (G_reset),
        
        // Master 0 Interface
        .M0_RREADY       (M0_RREADY),
        .M0_ARADDR       (M0_ARADDR),
        .M0_ARLEN        (M0_ARLEN),
        .M0_ARSIZE       (M0_ARSIZE),
        .M0_ARBURST      (M0_ARBURST),
        .M0_ARVALID      (M0_ARVALID),
        .ARREADY_M0      (M0_ARREADY),
        .RVALID_M0       (M0_RVALID),
        .RLAST_M0        (M0_RLAST),
        .RRESP_M0        (M0_RRESP),
        .RDATA_M0        (M0_RDATA),
        
        // Master 1 Interface
        .M1_RREADY       (M1_RREADY),
        .M1_ARADDR       (M1_ARADDR),
        .M1_ARLEN        (M1_ARLEN),
        .M1_ARSIZE       (M1_ARSIZE),
        .M1_ARBURST      (M1_ARBURST),
        .M1_ARVALID      (M1_ARVALID),
        .ARREADY_M1      (M1_ARREADY),
        .RVALID_M1       (M1_RVALID),
        .RLAST_M1        (M1_RLAST),
        .RRESP_M1        (M1_RRESP),
        .RDATA_M1        (M1_RDATA),
        
        // Slave 0 Interface
        .S0_ARREADY      (S0_ARREADY),
        .S0_RVALID       (S0_RVALID),
        .S0_RLAST        (S0_RLAST),
        .S0_RRESP        (S0_RRESP),
        .S0_RDATA        (S0_RDATA),
        .ARADDR_S0       (S0_ARADDR),
        .ARLEN_S0        (S0_ARLEN),
        .ARSIZE_S0       (S0_ARSIZE),
        .ARBURST_S0      (S0_ARBURST),
        .ARVALID_S0      (S0_ARVALID),
        .RREADY_S0       (S0_RREADY),
        
        // Slave 1 Interface
        .S1_ARREADY      (S1_ARREADY),
        .S1_RVALID       (S1_RVALID),
        .S1_RLAST        (S1_RLAST),
        .S1_RRESP        (S1_RRESP),
        .S1_RDATA        (S1_RDATA),
        .ARADDR_S1       (S1_ARADDR),
        .ARLEN_S1        (S1_ARLEN),
        .ARSIZE_S1       (S1_ARSIZE),
        .ARBURST_S1      (S1_ARBURST),
        .ARVALID_S1      (S1_ARVALID),
        .RREADY_S1       (S1_RREADY),
        
        // Address ranges
        .slave0_addr1    (slave0_addr1),
        .slave0_addr2    (slave0_addr2),
        .slave1_addr1    (slave1_addr1),
        .slave1_addr2    (slave1_addr2)
    );

endmodule

