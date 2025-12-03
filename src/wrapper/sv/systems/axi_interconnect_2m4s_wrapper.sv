//=============================================================================
// axi_interconnect_2m4s_wrapper.sv
// 
// SystemVerilog version of AXI Interconnect Wrapper
// Wrapper module cho AXI_Interconnect_Full với 2 Master và 4 Slave
// Module này bọc AXI_Interconnect_Full với interface đầy đủ AXI4
// bao gồm tất cả các tín hiệu Read và Write channels.
// 
// Architecture:
// 
//     [Master 0]  [Master 1]
//     (S00_AXI)   (S01_AXI)
//         |            |
//         +-----+------+
//               |
//    [AXI_Interconnect_Full]
//               |
//         +-----+------+------+------+
//         |      |      |      |   |
//     [Slave 0] [Slave 1] [Slave 2] [Slave 3]
//     (M00_AXI) (M01_AXI) (M02_AXI) (M03_AXI)
//=============================================================================

`timescale 1ns/1ps

module axi_interconnect_2m4s_wrapper #(
    // ========================================================================
    // AXI Parameters
    // ========================================================================
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned ID_WIDTH = 4,
    
    // Master 0 (S00) Parameters
    parameter int unsigned S00_AW_LEN = 8,
    parameter int unsigned S00_AR_LEN = 8,
    parameter int unsigned S00_WRITE_DATA_WIDTH = 32,
    parameter int unsigned S00_READ_DATA_WIDTH = 32,
    
    // Master 1 (S01) Parameters
    parameter int unsigned S01_AW_LEN = 8,
    parameter int unsigned S01_AR_LEN = 8,
    parameter int unsigned S01_WRITE_DATA_WIDTH = 32,
    
    // Slave 0 (M00) Parameters
    parameter int unsigned M00_AW_LEN = 8,
    parameter int unsigned M00_AR_LEN = 8,
    parameter int unsigned M00_WRITE_DATA_WIDTH = 32,
    parameter int unsigned M00_READ_DATA_WIDTH = 32,
    
    // Slave 1 (M01) Parameters
    parameter int unsigned M01_AW_LEN = 8,
    parameter int unsigned M01_AR_LEN = 8,
    
    // Slave 2 (M02) Parameters
    parameter int unsigned M02_AR_LEN = 8,
    parameter int unsigned M02_READ_DATA_WIDTH = 32,
    
    // Slave 3 (M03) Parameters
    parameter int unsigned M03_AR_LEN = 8,
    parameter int unsigned M03_READ_DATA_WIDTH = 32,
    
    // Interconnect Parameters
    parameter int unsigned NUM_MASTERS = 2,
    parameter int unsigned NUM_SLAVES = 4,
    parameter int unsigned MASTER_ID_WIDTH = $clog2(NUM_MASTERS),
    parameter int unsigned SLAVES_ID_SIZE = $clog2(NUM_MASTERS),
    parameter int unsigned RESP_ID_WIDTH = 2,
    parameter int unsigned IS_MASTER_AXI_4 = 1,
    parameter int unsigned AXI4_AW_LEN = 8,
    parameter int unsigned AXI4_AR_LEN = 8,
    
    // Address Range Parameters
    parameter logic [31:0] SLAVE0_ADDR_START = 32'h0000_0000,
    parameter logic [31:0] SLAVE0_ADDR_END   = 32'h3FFF_FFFF,
    parameter logic [31:0] SLAVE1_ADDR_START = 32'h4000_0000,
    parameter logic [31:0] SLAVE1_ADDR_END   = 32'h7FFF_FFFF,
    parameter logic [31:0] SLAVE2_ADDR_START = 32'h8000_0000,
    parameter logic [31:0] SLAVE2_ADDR_END   = 32'hBFFF_FFFF,
    parameter logic [31:0] SLAVE3_ADDR_START = 32'hC000_0000,
    parameter logic [31:0] SLAVE3_ADDR_END   = 32'hFFFF_FFFF
) (
    // ========================================================================
    // Global Signals
    // ========================================================================
    input  logic                    ACLK,
    input  logic                    ARESETN,
    
    // ========================================================================
    // Master 0 Interface (S00_AXI) - Full AXI4
    // ========================================================================
    input  logic                    S00_ACLK,
    input  logic                    S00_ARESETN,
    
    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]   S00_AXI_awaddr,
    input  logic [S00_AW_LEN-1:0]    S00_AXI_awlen,
    input  logic [2:0]               S00_AXI_awsize,
    input  logic [1:0]               S00_AXI_awburst,
    input  logic [1:0]               S00_AXI_awlock,
    input  logic [3:0]               S00_AXI_awcache,
    input  logic [2:0]               S00_AXI_awprot,
    input  logic [3:0]               S00_AXI_awqos,
    input  logic                    S00_AXI_awvalid,
    output logic                    S00_AXI_awready,
    
    // Write Data Channel
    input  logic [S00_WRITE_DATA_WIDTH-1:0] S00_AXI_wdata,
    input  logic [(S00_WRITE_DATA_WIDTH/8)-1:0] S00_AXI_wstrb,
    input  logic                    S00_AXI_wlast,
    input  logic                    S00_AXI_wvalid,
    output logic                    S00_AXI_wready,
    
    // Write Response Channel
    output logic [1:0]              S00_AXI_bresp,
    output logic                    S00_AXI_bvalid,
    input  logic                    S00_AXI_bready,
    
    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]   S00_AXI_araddr,
    input  logic [S00_AR_LEN-1:0]    S00_AXI_arlen,
    input  logic [2:0]               S00_AXI_arsize,
    input  logic [1:0]               S00_AXI_arburst,
    input  logic [1:0]               S00_AXI_arlock,
    input  logic [3:0]               S00_AXI_arcache,
    input  logic [2:0]               S00_AXI_arprot,
    input  logic [3:0]               S00_AXI_arregion,
    input  logic [3:0]               S00_AXI_arqos,
    input  logic                    S00_AXI_arvalid,
    output logic                    S00_AXI_arready,
    
    // Read Data Channel
    output logic [S00_READ_DATA_WIDTH-1:0] S00_AXI_rdata,
    output logic [1:0]              S00_AXI_rresp,
    output logic                    S00_AXI_rlast,
    output logic                    S00_AXI_rvalid,
    input  logic                    S00_AXI_rready,
    
    // ========================================================================
    // Master 1 Interface (S01_AXI) - Full AXI4
    // ========================================================================
    input  logic                    S01_ACLK,
    input  logic                    S01_ARESETN,
    
    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]   S01_AXI_awaddr,
    input  logic [S01_AW_LEN-1:0]    S01_AXI_awlen,
    input  logic [2:0]               S01_AXI_awsize,
    input  logic [1:0]               S01_AXI_awburst,
    input  logic [1:0]               S01_AXI_awlock,
    input  logic [3:0]               S01_AXI_awcache,
    input  logic [2:0]               S01_AXI_awprot,
    input  logic [3:0]               S01_AXI_awqos,
    input  logic                    S01_AXI_awvalid,
    output logic                    S01_AXI_awready,
    
    // Write Data Channel
    input  logic [S01_WRITE_DATA_WIDTH-1:0] S01_AXI_wdata,
    input  logic [(S01_WRITE_DATA_WIDTH/8)-1:0] S01_AXI_wstrb,
    input  logic                    S01_AXI_wlast,
    input  logic                    S01_AXI_wvalid,
    output logic                    S01_AXI_wready,
    
    // Write Response Channel
    output logic [1:0]              S01_AXI_bresp,
    output logic                    S01_AXI_bvalid,
    input  logic                    S01_AXI_bready,
    
    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]   S01_AXI_araddr,
    input  logic [S01_AR_LEN-1:0]    S01_AXI_arlen,
    input  logic [2:0]               S01_AXI_arsize,
    input  logic [1:0]               S01_AXI_arburst,
    input  logic [1:0]               S01_AXI_arlock,
    input  logic [3:0]               S01_AXI_arcache,
    input  logic [2:0]               S01_AXI_arprot,
    input  logic [3:0]               S01_AXI_arregion,
    input  logic [3:0]               S01_AXI_arqos,
    input  logic                    S01_AXI_arvalid,
    output logic                    S01_AXI_arready,
    
    // Read Data Channel
    output logic [S00_READ_DATA_WIDTH-1:0] S01_AXI_rdata,
    output logic [1:0]              S01_AXI_rresp,
    output logic                    S01_AXI_rlast,
    output logic                    S01_AXI_rvalid,
    input  logic                    S01_AXI_rready,
    
    // ========================================================================
    // Slave 0 Interface (M00_AXI) - Full AXI4
    // ========================================================================
    input  logic                    M00_ACLK,
    input  logic                    M00_ARESETN,
    
    // Write Address Channel
    output logic [SLAVES_ID_SIZE-1:0] M00_AXI_awaddr_ID,
    output logic [ADDR_WIDTH-1:0]   M00_AXI_awaddr,
    output logic [M00_AW_LEN-1:0]    M00_AXI_awlen,
    output logic [2:0]               M00_AXI_awsize,
    output logic [1:0]               M00_AXI_awburst,
    output logic [1:0]               M00_AXI_awlock,
    output logic [3:0]               M00_AXI_awcache,
    output logic [2:0]               M00_AXI_awprot,
    output logic [3:0]               M00_AXI_awqos,
    output logic                    M00_AXI_awvalid,
    input  logic                    M00_AXI_awready,
    
    // Write Data Channel
    output logic [M00_WRITE_DATA_WIDTH-1:0] M00_AXI_wdata,
    output logic [(M00_WRITE_DATA_WIDTH/8)-1:0] M00_AXI_wstrb,
    output logic                    M00_AXI_wlast,
    output logic                    M00_AXI_wvalid,
    input  logic                    M00_AXI_wready,
    
    // Write Response Channel
    input  logic [MASTER_ID_WIDTH-1:0] M00_AXI_BID,
    input  logic [1:0]              M00_AXI_bresp,
    input  logic                    M00_AXI_bvalid,
    output logic                    M00_AXI_bready,
    
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]   M00_AXI_araddr,
    output logic [M00_AR_LEN-1:0]    M00_AXI_arlen,
    output logic [2:0]               M00_AXI_arsize,
    output logic [1:0]               M00_AXI_arburst,
    output logic [1:0]               M00_AXI_arlock,
    output logic [3:0]               M00_AXI_arcache,
    output logic [2:0]               M00_AXI_arprot,
    output logic [3:0]               M00_AXI_arregion,
    output logic [3:0]               M00_AXI_arqos,
    output logic                    M00_AXI_arvalid,
    input  logic                    M00_AXI_arready,
    
    // Read Data Channel
    input  logic [M00_READ_DATA_WIDTH-1:0] M00_AXI_rdata,
    input  logic [1:0]              M00_AXI_rresp,
    input  logic                    M00_AXI_rlast,
    input  logic                    M00_AXI_rvalid,
    output logic                    M00_AXI_rready,
    
    // ========================================================================
    // Slave 1 Interface (M01_AXI) - Full AXI4
    // ========================================================================
    input  logic                    M01_ACLK,
    input  logic                    M01_ARESETN,
    
    // Write Address Channel
    output logic [SLAVES_ID_SIZE-1:0] M01_AXI_awaddr_ID,
    output logic [ADDR_WIDTH-1:0]   M01_AXI_awaddr,
    output logic [M01_AW_LEN-1:0]    M01_AXI_awlen,
    output logic [2:0]               M01_AXI_awsize,
    output logic [1:0]               M01_AXI_awburst,
    output logic [1:0]               M01_AXI_awlock,
    output logic [3:0]               M01_AXI_awcache,
    output logic [2:0]               M01_AXI_awprot,
    output logic [3:0]               M01_AXI_awqos,
    output logic                    M01_AXI_awvalid,
    input  logic                    M01_AXI_awready,
    
    // Write Data Channel
    output logic [M00_WRITE_DATA_WIDTH-1:0] M01_AXI_wdata,
    output logic [(M00_WRITE_DATA_WIDTH/8)-1:0] M01_AXI_wstrb,
    output logic                    M01_AXI_wlast,
    output logic                    M01_AXI_wvalid,
    input  logic                    M01_AXI_wready,
    
    // Write Response Channel
    input  logic [MASTER_ID_WIDTH-1:0] M01_AXI_BID,
    input  logic [1:0]              M01_AXI_bresp,
    input  logic                    M01_AXI_bvalid,
    output logic                    M01_AXI_bready,
    
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]   M01_AXI_araddr,
    output logic [M01_AR_LEN-1:0]    M01_AXI_arlen,
    output logic [2:0]               M01_AXI_arsize,
    output logic [1:0]               M01_AXI_arburst,
    output logic [1:0]               M01_AXI_arlock,
    output logic [3:0]               M01_AXI_arcache,
    output logic [2:0]               M01_AXI_arprot,
    output logic [3:0]               M01_AXI_arregion,
    output logic [3:0]               M01_AXI_arqos,
    output logic                    M01_AXI_arvalid,
    input  logic                    M01_AXI_arready,
    
    // Read Data Channel
    input  logic [M00_READ_DATA_WIDTH-1:0] M01_AXI_rdata,
    input  logic [1:0]              M01_AXI_rresp,
    input  logic                    M01_AXI_rlast,
    input  logic                    M01_AXI_rvalid,
    output logic                    M01_AXI_rready,
    
    // ========================================================================
    // Slave 2 Interface (M02_AXI) - Read Only
    // ========================================================================
    input  logic                    M02_ACLK,
    input  logic                    M02_ARESETN,
    
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]   M02_AXI_araddr,
    output logic [M02_AR_LEN-1:0]    M02_AXI_arlen,
    output logic [2:0]               M02_AXI_arsize,
    output logic [1:0]               M02_AXI_arburst,
    output logic [1:0]               M02_AXI_arlock,
    output logic [3:0]               M02_AXI_arcache,
    output logic [2:0]               M02_AXI_arprot,
    output logic [3:0]               M02_AXI_arregion,
    output logic [3:0]               M02_AXI_arqos,
    output logic                    M02_AXI_arvalid,
    input  logic                    M02_AXI_arready,
    
    // Read Data Channel
    input  logic [M02_READ_DATA_WIDTH-1:0] M02_AXI_rdata,
    input  logic [1:0]              M02_AXI_rresp,
    input  logic                    M02_AXI_rlast,
    input  logic                    M02_AXI_rvalid,
    output logic                    M02_AXI_rready,
    
    // ========================================================================
    // Slave 3 Interface (M03_AXI) - Read Only
    // ========================================================================
    input  logic                    M03_ACLK,
    input  logic                    M03_ARESETN,
    
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0]   M03_AXI_araddr,
    output logic [M03_AR_LEN-1:0]    M03_AXI_arlen,
    output logic [2:0]               M03_AXI_arsize,
    output logic [1:0]               M03_AXI_arburst,
    output logic [1:0]               M03_AXI_arlock,
    output logic [3:0]               M03_AXI_arcache,
    output logic [2:0]               M03_AXI_arprot,
    output logic [3:0]               M03_AXI_arregion,
    output logic [3:0]               M03_AXI_arqos,
    output logic                    M03_AXI_arvalid,
    input  logic                    M03_AXI_arready,
    
    // Read Data Channel
    input  logic [M03_READ_DATA_WIDTH-1:0] M03_AXI_rdata,
    input  logic [1:0]              M03_AXI_rresp,
    input  logic                    M03_AXI_rlast,
    input  logic                    M03_AXI_rvalid,
    output logic                    M03_AXI_rready,
    
    // ========================================================================
    // Optional: Address Range Override
    // ========================================================================
    input  logic [ADDR_WIDTH-1:0]   slave0_addr1_override,
    input  logic [ADDR_WIDTH-1:0]   slave0_addr2_override,
    input  logic [ADDR_WIDTH-1:0]   slave1_addr1_override,
    input  logic [ADDR_WIDTH-1:0]   slave1_addr2_override,
    input  logic [ADDR_WIDTH-1:0]   slave2_addr1_override,
    input  logic [ADDR_WIDTH-1:0]   slave2_addr2_override,
    input  logic [ADDR_WIDTH-1:0]   slave3_addr1_override,
    input  logic [ADDR_WIDTH-1:0]   slave3_addr2_override,
    input  logic                    use_address_override
);

    // ========================================================================
    // Internal Signals
    // ========================================================================
    
    // Local parameters (calculated from parameters)
    localparam int unsigned S00_WRITE_DATA_BYTES = S00_WRITE_DATA_WIDTH / 8;
    localparam int unsigned M00_WRITE_DATA_BYTES = M00_WRITE_DATA_WIDTH / 8;
    
    // Address range selection
    logic [ADDR_WIDTH-1:0] slave0_addr1;
    logic [ADDR_WIDTH-1:0] slave0_addr2;
    logic [ADDR_WIDTH-1:0] slave1_addr1;
    logic [ADDR_WIDTH-1:0] slave1_addr2;
    logic [ADDR_WIDTH-1:0] slave2_addr1;
    logic [ADDR_WIDTH-1:0] slave2_addr2;
    logic [ADDR_WIDTH-1:0] slave3_addr1;
    logic [ADDR_WIDTH-1:0] slave3_addr2;
    
    // ========================================================================
    // Address Range Selection Logic (Combinational)
    // ========================================================================
    always_comb begin
        // Address range mux - using SystemVerilog always_comb
        slave0_addr1 = use_address_override ? slave0_addr1_override : SLAVE0_ADDR_START;
        slave0_addr2 = use_address_override ? slave0_addr2_override : SLAVE0_ADDR_END;
        slave1_addr1 = use_address_override ? slave1_addr1_override : SLAVE1_ADDR_START;
        slave1_addr2 = use_address_override ? slave1_addr2_override : SLAVE1_ADDR_END;
        slave2_addr1 = use_address_override ? slave2_addr1_override : SLAVE2_ADDR_START;
        slave2_addr2 = use_address_override ? slave2_addr2_override : SLAVE2_ADDR_END;
        slave3_addr1 = use_address_override ? slave3_addr1_override : SLAVE3_ADDR_START;
        slave3_addr2 = use_address_override ? slave3_addr2_override : SLAVE3_ADDR_END;
    end
    
    // ========================================================================
    // AXI_Interconnect_Full Instance
    // ========================================================================
    // Note: AXI_Interconnect_Full is still Verilog, so we use wire/reg compatible syntax
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

