`timescale 1ns/1ps

/*
 * axi_interconnect_2m4s_wrapper.v
 * 
 * Wrapper module cho AXI_Interconnect_Full với 2 Master và 4 Slave
 * Module này bọc AXI_Interconnect_Full với interface đầy đủ AXI4
 * bao gồm tất cả các tín hiệu Read và Write channels.
 * 
 * Architecture:
 * 
 *     [Master 0]  [Master 1]
 *     (S00_AXI)   (S01_AXI)
 *         |            |
 *         +-----+------+
 *               |
 *    [AXI_Interconnect_Full]
 *               |
 *         +-----+------+------+------+
 *         |      |      |      |   |
 *     [Slave 0] [Slave 1] [Slave 2] [Slave 3]
 *     (M00_AXI) (M01_AXI) (M02_AXI) (M03_AXI)
 */

module axi_interconnect_2m4s_wrapper #(
    // ========================================================================
    // AXI Parameters
    // ========================================================================
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4,
    
    // Master 0 (S00) Parameters
    parameter S00_AW_LEN = 8,
    parameter S00_AR_LEN = 8,
    parameter S00_WRITE_DATA_WIDTH = 32,
    parameter S00_READ_DATA_WIDTH = 32,
    
    // Master 1 (S01) Parameters
    parameter S01_AW_LEN = 8,
    parameter S01_AR_LEN = 8,
    parameter S01_WRITE_DATA_WIDTH = 32,
    
    // Slave 0 (M00) Parameters
    parameter M00_AW_LEN = 8,
    parameter M00_AR_LEN = 8,
    parameter M00_WRITE_DATA_WIDTH = 32,
    parameter M00_READ_DATA_WIDTH = 32,
    
    // Slave 1 (M01) Parameters
    parameter M01_AW_LEN = 8,
    parameter M01_AR_LEN = 8,
    
    // Slave 2 (M02) Parameters
    parameter M02_AR_LEN = 8,
    parameter M02_READ_DATA_WIDTH = 32,
    
    // Slave 3 (M03) Parameters
    parameter M03_AR_LEN = 8,
    parameter M03_READ_DATA_WIDTH = 32,
    
    // Interconnect Parameters
    parameter NUM_MASTERS = 2,
    parameter NUM_SLAVES = 4,
    parameter MASTER_ID_WIDTH = $clog2(NUM_MASTERS),
    parameter SLAVES_ID_SIZE = $clog2(NUM_MASTERS),
    parameter RESP_ID_WIDTH = 2,
    parameter IS_MASTER_AXI_4 = 1,
    parameter AXI4_AW_LEN = 8,
    parameter AXI4_AR_LEN = 8,
    
    // Address Range Parameters
    parameter [31:0] SLAVE0_ADDR_START = 32'h0000_0000,
    parameter [31:0] SLAVE0_ADDR_END   = 32'h3FFF_FFFF,
    parameter [31:0] SLAVE1_ADDR_START = 32'h4000_0000,
    parameter [31:0] SLAVE1_ADDR_END   = 32'h7FFF_FFFF,
    parameter [31:0] SLAVE2_ADDR_START = 32'h8000_0000,
    parameter [31:0] SLAVE2_ADDR_END   = 32'hBFFF_FFFF,
    parameter [31:0] SLAVE3_ADDR_START = 32'hC000_0000,
    parameter [31:0] SLAVE3_ADDR_END   = 32'hFFFF_FFFF
) (
    // ========================================================================
    // Global Signals
    // ========================================================================
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ========================================================================
    // Master 0 Interface (S00_AXI) - Full AXI4
    // ========================================================================
    input  wire                    S00_ACLK,
    input  wire                    S00_ARESETN,
    
    // Write Address Channel
    input  wire [ADDR_WIDTH-1:0]   S00_AXI_awaddr,
    input  wire [S00_AW_LEN-1:0]   S00_AXI_awlen,
    input  wire [2:0]              S00_AXI_awsize,
    input  wire [1:0]              S00_AXI_awburst,
    input  wire [1:0]              S00_AXI_awlock,
    input  wire [3:0]              S00_AXI_awcache,
    input  wire [2:0]              S00_AXI_awprot,
    input  wire [3:0]              S00_AXI_awqos,
    input  wire                    S00_AXI_awvalid,
    output wire                    S00_AXI_awready,
    
    // Write Data Channel
    input  wire [S00_WRITE_DATA_WIDTH-1:0] S00_AXI_wdata,
    input  wire [(S00_WRITE_DATA_WIDTH/8)-1:0] S00_AXI_wstrb,
    input  wire                    S00_AXI_wlast,
    input  wire                    S00_AXI_wvalid,
    output wire                    S00_AXI_wready,
    
    // Write Response Channel
    output wire [1:0]              S00_AXI_bresp,
    output wire                    S00_AXI_bvalid,
    input  wire                    S00_AXI_bready,
    
    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0]   S00_AXI_araddr,
    input  wire [S00_AR_LEN-1:0]   S00_AXI_arlen,
    input  wire [2:0]              S00_AXI_arsize,
    input  wire [1:0]              S00_AXI_arburst,
    input  wire [1:0]              S00_AXI_arlock,
    input  wire [3:0]              S00_AXI_arcache,
    input  wire [2:0]              S00_AXI_arprot,
    input  wire [3:0]              S00_AXI_arregion,
    input  wire [3:0]              S00_AXI_arqos,
    input  wire                    S00_AXI_arvalid,
    output wire                    S00_AXI_arready,
    
    // Read Data Channel
    output wire [S00_READ_DATA_WIDTH-1:0] S00_AXI_rdata,
    output wire [1:0]              S00_AXI_rresp,
    output wire                    S00_AXI_rlast,
    output wire                    S00_AXI_rvalid,
    input  wire                    S00_AXI_rready,
    
    // ========================================================================
    // Master 1 Interface (S01_AXI) - Full AXI4
    // ========================================================================
    input  wire                    S01_ACLK,
    input  wire                    S01_ARESETN,
    
    // Write Address Channel
    input  wire [ADDR_WIDTH-1:0]   S01_AXI_awaddr,
    input  wire [S01_AW_LEN-1:0]   S01_AXI_awlen,
    input  wire [2:0]              S01_AXI_awsize,
    input  wire [1:0]              S01_AXI_awburst,
    input  wire [1:0]              S01_AXI_awlock,
    input  wire [3:0]              S01_AXI_awcache,
    input  wire [2:0]              S01_AXI_awprot,
    input  wire [3:0]              S01_AXI_awqos,
    input  wire                    S01_AXI_awvalid,
    output wire                    S01_AXI_awready,
    
    // Write Data Channel
    input  wire [S01_WRITE_DATA_WIDTH-1:0] S01_AXI_wdata,
    input  wire [(S01_WRITE_DATA_WIDTH/8)-1:0] S01_AXI_wstrb,
    input  wire                    S01_AXI_wlast,
    input  wire                    S01_AXI_wvalid,
    output wire                    S01_AXI_wready,
    
    // Write Response Channel
    output wire [1:0]              S01_AXI_bresp,
    output wire                    S01_AXI_bvalid,
    input  wire                    S01_AXI_bready,
    
    // Read Address Channel
    input  wire [ADDR_WIDTH-1:0]   S01_AXI_araddr,
    input  wire [S01_AR_LEN-1:0]   S01_AXI_arlen,
    input  wire [2:0]              S01_AXI_arsize,
    input  wire [1:0]              S01_AXI_arburst,
    input  wire [1:0]              S01_AXI_arlock,
    input  wire [3:0]              S01_AXI_arcache,
    input  wire [2:0]              S01_AXI_arprot,
    input  wire [3:0]              S01_AXI_arregion,
    input  wire [3:0]              S01_AXI_arqos,
    input  wire                    S01_AXI_arvalid,
    output wire                    S01_AXI_arready,
    
    // Read Data Channel
    output wire [S00_READ_DATA_WIDTH-1:0] S01_AXI_rdata,
    output wire [1:0]              S01_AXI_rresp,
    output wire                    S01_AXI_rlast,
    output wire                    S01_AXI_rvalid,
    input  wire                    S01_AXI_rready,
    
    // ========================================================================
    // Slave 0 Interface (M00_AXI) - Full AXI4
    // ========================================================================
    input  wire                    M00_ACLK,
    input  wire                    M00_ARESETN,
    
    // Write Address Channel
    output wire [SLAVES_ID_SIZE-1:0] M00_AXI_awaddr_ID,
    output wire [ADDR_WIDTH-1:0]   M00_AXI_awaddr,
    output wire [M00_AW_LEN-1:0]   M00_AXI_awlen,
    output wire [2:0]              M00_AXI_awsize,
    output wire [1:0]              M00_AXI_awburst,
    output wire [1:0]              M00_AXI_awlock,
    output wire [3:0]              M00_AXI_awcache,
    output wire [2:0]              M00_AXI_awprot,
    output wire [3:0]              M00_AXI_awqos,
    output wire                    M00_AXI_awvalid,
    input  wire                    M00_AXI_awready,
    
    // Write Data Channel
    output wire [M00_WRITE_DATA_WIDTH-1:0] M00_AXI_wdata,
    output wire [(M00_WRITE_DATA_WIDTH/8)-1:0] M00_AXI_wstrb,
    output wire                    M00_AXI_wlast,
    output wire                    M00_AXI_wvalid,
    input  wire                    M00_AXI_wready,
    
    // Write Response Channel
    input  wire [MASTER_ID_WIDTH-1:0] M00_AXI_BID,
    input  wire [1:0]              M00_AXI_bresp,
    input  wire                    M00_AXI_bvalid,
    output wire                    M00_AXI_bready,
    
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]   M00_AXI_araddr,
    output wire [M00_AR_LEN-1:0]   M00_AXI_arlen,
    output wire [2:0]              M00_AXI_arsize,
    output wire [1:0]              M00_AXI_arburst,
    output wire [1:0]              M00_AXI_arlock,
    output wire [3:0]              M00_AXI_arcache,
    output wire [2:0]              M00_AXI_arprot,
    output wire [3:0]              M00_AXI_arregion,
    output wire [3:0]              M00_AXI_arqos,
    output wire                    M00_AXI_arvalid,
    input  wire                    M00_AXI_arready,
    
    // Read Data Channel
    input  wire [M00_READ_DATA_WIDTH-1:0] M00_AXI_rdata,
    input  wire [1:0]              M00_AXI_rresp,
    input  wire                    M00_AXI_rlast,
    input  wire                    M00_AXI_rvalid,
    output wire                    M00_AXI_rready,
    
    // ========================================================================
    // Slave 1 Interface (M01_AXI) - Full AXI4
    // ========================================================================
    input  wire                    M01_ACLK,
    input  wire                    M01_ARESETN,
    
    // Write Address Channel
    output wire [SLAVES_ID_SIZE-1:0] M01_AXI_awaddr_ID,
    output wire [ADDR_WIDTH-1:0]   M01_AXI_awaddr,
    output wire [M01_AW_LEN-1:0]   M01_AXI_awlen,
    output wire [2:0]              M01_AXI_awsize,
    output wire [1:0]              M01_AXI_awburst,
    output wire [1:0]              M01_AXI_awlock,
    output wire [3:0]              M01_AXI_awcache,
    output wire [2:0]              M01_AXI_awprot,
    output wire [3:0]              M01_AXI_awqos,
    output wire                    M01_AXI_awvalid,
    input  wire                    M01_AXI_awready,
    
    // Write Data Channel
    output wire [M00_WRITE_DATA_WIDTH-1:0] M01_AXI_wdata,
    output wire [(M00_WRITE_DATA_WIDTH/8)-1:0] M01_AXI_wstrb,
    output wire                    M01_AXI_wlast,
    output wire                    M01_AXI_wvalid,
    input  wire                    M01_AXI_wready,
    
    // Write Response Channel
    input  wire [MASTER_ID_WIDTH-1:0] M01_AXI_BID,
    input  wire [1:0]              M01_AXI_bresp,
    input  wire                    M01_AXI_bvalid,
    output wire                    M01_AXI_bready,
    
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]   M01_AXI_araddr,
    output wire [M01_AR_LEN-1:0]   M01_AXI_arlen,
    output wire [2:0]              M01_AXI_arsize,
    output wire [1:0]              M01_AXI_arburst,
    output wire [1:0]              M01_AXI_arlock,
    output wire [3:0]              M01_AXI_arcache,
    output wire [2:0]              M01_AXI_arprot,
    output wire [3:0]              M01_AXI_arregion,
    output wire [3:0]              M01_AXI_arqos,
    output wire                    M01_AXI_arvalid,
    input  wire                    M01_AXI_arready,
    
    // Read Data Channel
    input  wire [M00_READ_DATA_WIDTH-1:0] M01_AXI_rdata,
    input  wire [1:0]              M01_AXI_rresp,
    input  wire                    M01_AXI_rlast,
    input  wire                    M01_AXI_rvalid,
    output wire                    M01_AXI_rready,
    
    // ========================================================================
    // Slave 2 Interface (M02_AXI) - Read Only
    // ========================================================================
    input  wire                    M02_ACLK,
    input  wire                    M02_ARESETN,
    
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]   M02_AXI_araddr,
    output wire [M02_AR_LEN-1:0]   M02_AXI_arlen,
    output wire [2:0]              M02_AXI_arsize,
    output wire [1:0]              M02_AXI_arburst,
    output wire [1:0]              M02_AXI_arlock,
    output wire [3:0]              M02_AXI_arcache,
    output wire [2:0]              M02_AXI_arprot,
    output wire [3:0]              M02_AXI_arregion,
    output wire [3:0]              M02_AXI_arqos,
    output wire                    M02_AXI_arvalid,
    input  wire                    M02_AXI_arready,
    
    // Read Data Channel
    input  wire [M02_READ_DATA_WIDTH-1:0] M02_AXI_rdata,
    input  wire [1:0]              M02_AXI_rresp,
    input  wire                    M02_AXI_rlast,
    input  wire                    M02_AXI_rvalid,
    output wire                    M02_AXI_rready,
    
    // ========================================================================
    // Slave 3 Interface (M03_AXI) - Read Only
    // ========================================================================
    input  wire                    M03_ACLK,
    input  wire                    M03_ARESETN,
    
    // Read Address Channel
    output wire [ADDR_WIDTH-1:0]   M03_AXI_araddr,
    output wire [M03_AR_LEN-1:0]   M03_AXI_arlen,
    output wire [2:0]              M03_AXI_arsize,
    output wire [1:0]              M03_AXI_arburst,
    output wire [1:0]              M03_AXI_arlock,
    output wire [3:0]              M03_AXI_arcache,
    output wire [2:0]              M03_AXI_arprot,
    output wire [3:0]              M03_AXI_arregion,
    output wire [3:0]              M03_AXI_arqos,
    output wire                    M03_AXI_arvalid,
    input  wire                    M03_AXI_arready,
    
    // Read Data Channel
    input  wire [M03_READ_DATA_WIDTH-1:0] M03_AXI_rdata,
    input  wire [1:0]              M03_AXI_rresp,
    input  wire                    M03_AXI_rlast,
    input  wire                    M03_AXI_rvalid,
    output wire                    M03_AXI_rready,
    
    // ========================================================================
    // Optional: Address Range Override
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]  slave0_addr1_override,
    input  wire [ADDR_WIDTH-1:0]  slave0_addr2_override,
    input  wire [ADDR_WIDTH-1:0]  slave1_addr1_override,
    input  wire [ADDR_WIDTH-1:0]  slave1_addr2_override,
    input  wire [ADDR_WIDTH-1:0]  slave2_addr1_override,
    input  wire [ADDR_WIDTH-1:0]  slave2_addr2_override,
    input  wire [ADDR_WIDTH-1:0]  slave3_addr1_override,
    input  wire [ADDR_WIDTH-1:0]  slave3_addr2_override,
    input  wire                    use_address_override
);

    // ========================================================================
    // Internal Signals
    // ========================================================================
    
    // Local parameters (calculated from parameters)
    localparam S00_WRITE_DATA_BYTES = S00_WRITE_DATA_WIDTH / 8;
    localparam M00_WRITE_DATA_BYTES = M00_WRITE_DATA_WIDTH / 8;
    
    // Address range selection
    wire [ADDR_WIDTH-1:0] slave0_addr1;
    wire [ADDR_WIDTH-1:0] slave0_addr2;
    wire [ADDR_WIDTH-1:0] slave1_addr1;
    wire [ADDR_WIDTH-1:0] slave1_addr2;
    wire [ADDR_WIDTH-1:0] slave2_addr1;
    wire [ADDR_WIDTH-1:0] slave2_addr2;
    wire [ADDR_WIDTH-1:0] slave3_addr1;
    wire [ADDR_WIDTH-1:0] slave3_addr2;
    
    // Address range mux
    assign slave0_addr1 = use_address_override ? slave0_addr1_override : SLAVE0_ADDR_START;
    assign slave0_addr2 = use_address_override ? slave0_addr2_override : SLAVE0_ADDR_END;
    assign slave1_addr1 = use_address_override ? slave1_addr1_override : SLAVE1_ADDR_START;
    assign slave1_addr2 = use_address_override ? slave1_addr2_override : SLAVE1_ADDR_END;
    assign slave2_addr1 = use_address_override ? slave2_addr1_override : SLAVE2_ADDR_START;
    assign slave2_addr2 = use_address_override ? slave2_addr2_override : SLAVE2_ADDR_END;
    assign slave3_addr1 = use_address_override ? slave3_addr1_override : SLAVE3_ADDR_START;
    assign slave3_addr2 = use_address_override ? slave3_addr2_override : SLAVE3_ADDR_END;
    
    // ========================================================================
    // AXI_Interconnect_Full Instance
    // ========================================================================
    AXI_Interconnect_Full #(
        .Masters_Num              (NUM_MASTERS),
        .Slaves_ID_Size           (SLAVES_ID_SIZE),
        .Address_width            (ADDR_WIDTH),
        .S00_Aw_len               (S00_AW_LEN),
        .S00_Write_data_bus_width (S00_WRITE_DATA_WIDTH),
        .S00_Write_data_bytes_num (S00_WRITE_DATA_BYTES),
        .S00_AR_len               (S00_AR_LEN),
        .S00_Read_data_bus_width  (S00_READ_DATA_WIDTH),
        .S01_Aw_len               (S01_AW_LEN),
        .S01_AR_len               (S01_AR_LEN),
        .S01_Write_data_bus_width (S01_WRITE_DATA_WIDTH),
        .AXI4_Aw_len              (AXI4_AW_LEN),
        .M00_Aw_len               (M00_AW_LEN),
        .M00_Write_data_bus_width (M00_WRITE_DATA_WIDTH),
        .M00_Write_data_bytes_num (M00_WRITE_DATA_BYTES),
        .M00_AR_len               (M00_AR_LEN),
        .M00_Read_data_bus_width  (M00_READ_DATA_WIDTH),
        .M01_Aw_len               (M01_AW_LEN),
        .M01_AR_len               (M01_AR_LEN),
        .M02_Aw_len               (8),  // Not used for read-only
        .M02_AR_len               (M02_AR_LEN),
        .M02_Read_data_bus_width  (M02_READ_DATA_WIDTH),
        .M03_Aw_len               (8),  // Not used for read-only
        .M03_AR_len               (M03_AR_LEN),
        .M03_Read_data_bus_width  (M03_READ_DATA_WIDTH),
        .Is_Master_AXI_4          (IS_MASTER_AXI_4),
        .M1_ID                    (0),
        .M2_ID                    (1),
        .Resp_ID_width            (RESP_ID_WIDTH),
        .Num_Of_Masters           (NUM_MASTERS),
        .Num_Of_Slaves            (NUM_SLAVES),
        .Master_ID_Width          (MASTER_ID_WIDTH),
        .AXI4_AR_len              (AXI4_AR_LEN)
    ) u_axi_interconnect_full (
        // Global
        .ACLK                     (ACLK),
        .ARESETN                  (ARESETN),
        
        // Master 0 (S00)
        .S00_ACLK                 (S00_ACLK),
        .S00_ARESETN              (S00_ARESETN),
        .S00_AXI_awaddr           (S00_AXI_awaddr),
        .S00_AXI_awlen            (S00_AXI_awlen),
        .S00_AXI_awsize           (S00_AXI_awsize),
        .S00_AXI_awburst          (S00_AXI_awburst),
        .S00_AXI_awlock           (S00_AXI_awlock),
        .S00_AXI_awcache          (S00_AXI_awcache),
        .S00_AXI_awprot           (S00_AXI_awprot),
        .S00_AXI_awqos            (S00_AXI_awqos),
        .S00_AXI_awvalid          (S00_AXI_awvalid),
        .S00_AXI_awready          (S00_AXI_awready),
        .S00_AXI_wdata            (S00_AXI_wdata),
        .S00_AXI_wstrb            (S00_AXI_wstrb),
        .S00_AXI_wlast            (S00_AXI_wlast),
        .S00_AXI_wvalid           (S00_AXI_wvalid),
        .S00_AXI_wready           (S00_AXI_wready),
        .S00_AXI_bresp            (S00_AXI_bresp),
        .S00_AXI_bvalid           (S00_AXI_bvalid),
        .S00_AXI_bready           (S00_AXI_bready),
        .S00_AXI_araddr           (S00_AXI_araddr),
        .S00_AXI_arlen            (S00_AXI_arlen),
        .S00_AXI_arsize           (S00_AXI_arsize),
        .S00_AXI_arburst          (S00_AXI_arburst),
        .S00_AXI_arlock           (S00_AXI_arlock),
        .S00_AXI_arcache          (S00_AXI_arcache),
        .S00_AXI_arprot           (S00_AXI_arprot),
        .S00_AXI_arregion         (S00_AXI_arregion),
        .S00_AXI_arqos            (S00_AXI_arqos),
        .S00_AXI_arvalid          (S00_AXI_arvalid),
        .S00_AXI_arready          (S00_AXI_arready),
        .S00_AXI_rdata            (S00_AXI_rdata),
        .S00_AXI_rresp            (S00_AXI_rresp),
        .S00_AXI_rlast            (S00_AXI_rlast),
        .S00_AXI_rvalid           (S00_AXI_rvalid),
        .S00_AXI_rready           (S00_AXI_rready),
        
        // Master 1 (S01)
        .S01_ACLK                 (S01_ACLK),
        .S01_ARESETN              (S01_ARESETN),
        .S01_AXI_awaddr           (S01_AXI_awaddr),
        .S01_AXI_awlen            (S01_AXI_awlen),
        .S01_AXI_awsize           (S01_AXI_awsize),
        .S01_AXI_awburst          (S01_AXI_awburst),
        .S01_AXI_awlock           (S01_AXI_awlock),
        .S01_AXI_awcache          (S01_AXI_awcache),
        .S01_AXI_awprot           (S01_AXI_awprot),
        .S01_AXI_awqos            (S01_AXI_awqos),
        .S01_AXI_awvalid          (S01_AXI_awvalid),
        .S01_AXI_awready          (S01_AXI_awready),
        .S01_AXI_wdata            (S01_AXI_wdata),
        .S01_AXI_wstrb            (S01_AXI_wstrb),
        .S01_AXI_wlast            (S01_AXI_wlast),
        .S01_AXI_wvalid           (S01_AXI_wvalid),
        .S01_AXI_wready           (S01_AXI_wready),
        .S01_AXI_bresp            (S01_AXI_bresp),
        .S01_AXI_bvalid           (S01_AXI_bvalid),
        .S01_AXI_bready           (S01_AXI_bready),
        .S01_AXI_araddr           (S01_AXI_araddr),
        .S01_AXI_arlen            (S01_AXI_arlen),
        .S01_AXI_arsize           (S01_AXI_arsize),
        .S01_AXI_arburst          (S01_AXI_arburst),
        .S01_AXI_arlock           (S01_AXI_arlock),
        .S01_AXI_arcache          (S01_AXI_arcache),
        .S01_AXI_arprot           (S01_AXI_arprot),
        .S01_AXI_arregion         (S01_AXI_arregion),
        .S01_AXI_arqos            (S01_AXI_arqos),
        .S01_AXI_arvalid          (S01_AXI_arvalid),
        .S01_AXI_arready          (S01_AXI_arready),
        .S01_AXI_rdata            (S01_AXI_rdata),
        .S01_AXI_rresp            (S01_AXI_rresp),
        .S01_AXI_rlast            (S01_AXI_rlast),
        .S01_AXI_rvalid           (S01_AXI_rvalid),
        .S01_AXI_rready           (S01_AXI_rready),
        
        // Slave 0 (M00)
        .M00_ACLK                 (M00_ACLK),
        .M00_ARESETN              (M00_ARESETN),
        .M00_AXI_awaddr_ID        (M00_AXI_awaddr_ID),
        .M00_AXI_awaddr           (M00_AXI_awaddr),
        .M00_AXI_awlen            (M00_AXI_awlen),
        .M00_AXI_awsize           (M00_AXI_awsize),
        .M00_AXI_awburst          (M00_AXI_awburst),
        .M00_AXI_awlock           (M00_AXI_awlock),
        .M00_AXI_awcache          (M00_AXI_awcache),
        .M00_AXI_awprot           (M00_AXI_awprot),
        .M00_AXI_awqos            (M00_AXI_awqos),
        .M00_AXI_awvalid          (M00_AXI_awvalid),
        .M00_AXI_awready          (M00_AXI_awready),
        .M00_AXI_wdata            (M00_AXI_wdata),
        .M00_AXI_wstrb            (M00_AXI_wstrb),
        .M00_AXI_wlast            (M00_AXI_wlast),
        .M00_AXI_wvalid           (M00_AXI_wvalid),
        .M00_AXI_wready           (M00_AXI_wready),
        .M00_AXI_BID              (M00_AXI_BID),
        .M00_AXI_bresp            (M00_AXI_bresp),
        .M00_AXI_bvalid           (M00_AXI_bvalid),
        .M00_AXI_bready           (M00_AXI_bready),
        .M00_AXI_araddr           (M00_AXI_araddr),
        .M00_AXI_arlen            (M00_AXI_arlen),
        .M00_AXI_arsize           (M00_AXI_arsize),
        .M00_AXI_arburst          (M00_AXI_arburst),
        .M00_AXI_arlock           (M00_AXI_arlock),
        .M00_AXI_arcache          (M00_AXI_arcache),
        .M00_AXI_arprot           (M00_AXI_arprot),
        .M00_AXI_arregion         (M00_AXI_arregion),
        .M00_AXI_arqos            (M00_AXI_arqos),
        .M00_AXI_arvalid          (M00_AXI_arvalid),
        .M00_AXI_arready          (M00_AXI_arready),
        .M00_AXI_rdata            (M00_AXI_rdata),
        .M00_AXI_rresp            (M00_AXI_rresp),
        .M00_AXI_rlast            (M00_AXI_rlast),
        .M00_AXI_rvalid           (M00_AXI_rvalid),
        .M00_AXI_rready           (M00_AXI_rready),
        
        // Slave 1 (M01)
        .M01_ACLK                 (M01_ACLK),
        .M01_ARESETN              (M01_ARESETN),
        .M01_AXI_awaddr_ID        (M01_AXI_awaddr_ID),
        .M01_AXI_awaddr           (M01_AXI_awaddr),
        .M01_AXI_awlen            (M01_AXI_awlen),
        .M01_AXI_awsize           (M01_AXI_awsize),
        .M01_AXI_awburst          (M01_AXI_awburst),
        .M01_AXI_awlock           (M01_AXI_awlock),
        .M01_AXI_awcache          (M01_AXI_awcache),
        .M01_AXI_awprot           (M01_AXI_awprot),
        .M01_AXI_awqos            (M01_AXI_awqos),
        .M01_AXI_awvalid          (M01_AXI_awvalid),
        .M01_AXI_awready          (M01_AXI_awready),
        .M01_AXI_wdata            (M01_AXI_wdata),
        .M01_AXI_wstrb            (M01_AXI_wstrb),
        .M01_AXI_wlast            (M01_AXI_wlast),
        .M01_AXI_wvalid           (M01_AXI_wvalid),
        .M01_AXI_wready           (M01_AXI_wready),
        .M01_AXI_BID              (M01_AXI_BID),
        .M01_AXI_bresp            (M01_AXI_bresp),
        .M01_AXI_bvalid           (M01_AXI_bvalid),
        .M01_AXI_bready           (M01_AXI_bready),
        .M01_AXI_araddr           (M01_AXI_araddr),
        .M01_AXI_arlen            (M01_AXI_arlen),
        .M01_AXI_arsize           (M01_AXI_arsize),
        .M01_AXI_arburst          (M01_AXI_arburst),
        .M01_AXI_arlock           (M01_AXI_arlock),
        .M01_AXI_arcache          (M01_AXI_arcache),
        .M01_AXI_arprot           (M01_AXI_arprot),
        .M01_AXI_arregion         (M01_AXI_arregion),
        .M01_AXI_arqos            (M01_AXI_arqos),
        .M01_AXI_arvalid          (M01_AXI_arvalid),
        .M01_AXI_arready          (M01_AXI_arready),
        .M01_AXI_rdata            (M01_AXI_rdata),
        .M01_AXI_rresp            (M01_AXI_rresp),
        .M01_AXI_rlast            (M01_AXI_rlast),
        .M01_AXI_rvalid           (M01_AXI_rvalid),
        .M01_AXI_rready           (M01_AXI_rready),
        
        // Slave 2 (M02) - Read Only
        .M02_ACLK                 (M02_ACLK),
        .M02_ARESETN              (M02_ARESETN),
        .M02_AXI_araddr           (M02_AXI_araddr),
        .M02_AXI_arlen            (M02_AXI_arlen),
        .M02_AXI_arsize           (M02_AXI_arsize),
        .M02_AXI_arburst          (M02_AXI_arburst),
        .M02_AXI_arlock           (M02_AXI_arlock),
        .M02_AXI_arcache          (M02_AXI_arcache),
        .M02_AXI_arprot           (M02_AXI_arprot),
        .M02_AXI_arregion         (M02_AXI_arregion),
        .M02_AXI_arqos            (M02_AXI_arqos),
        .M02_AXI_arvalid          (M02_AXI_arvalid),
        .M02_AXI_arready          (M02_AXI_arready),
        .M02_AXI_rdata            (M02_AXI_rdata),
        .M02_AXI_rresp            (M02_AXI_rresp),
        .M02_AXI_rlast            (M02_AXI_rlast),
        .M02_AXI_rvalid           (M02_AXI_rvalid),
        .M02_AXI_rready           (M02_AXI_rready),
        
        // Slave 3 (M03) - Read Only
        .M03_ACLK                 (M03_ACLK),
        .M03_ARESETN              (M03_ARESETN),
        .M03_AXI_araddr           (M03_AXI_araddr),
        .M03_AXI_arlen            (M03_AXI_arlen),
        .M03_AXI_arsize           (M03_AXI_arsize),
        .M03_AXI_arburst          (M03_AXI_arburst),
        .M03_AXI_arlock           (M03_AXI_arlock),
        .M03_AXI_arcache          (M03_AXI_arcache),
        .M03_AXI_arprot           (M03_AXI_arprot),
        .M03_AXI_arregion         (M03_AXI_arregion),
        .M03_AXI_arqos            (M03_AXI_arqos),
        .M03_AXI_arvalid          (M03_AXI_arvalid),
        .M03_AXI_arready          (M03_AXI_arready),
        .M03_AXI_rdata            (M03_AXI_rdata),
        .M03_AXI_rresp            (M03_AXI_rresp),
        .M03_AXI_rlast            (M03_AXI_rlast),
        .M03_AXI_rvalid           (M03_AXI_rvalid),
        .M03_AXI_rready           (M03_AXI_rready),
        
        // Address ranges
        .slave0_addr1             (slave0_addr1),
        .slave0_addr2             (slave0_addr2),
        .slave1_addr1             (slave1_addr1),
        .slave1_addr2             (slave1_addr2),
        .slave2_addr1             (slave2_addr1),
        .slave2_addr2             (slave2_addr2),
        .slave3_addr1             (slave3_addr1),
        .slave3_addr2             (slave3_addr2)
    );

endmodule

