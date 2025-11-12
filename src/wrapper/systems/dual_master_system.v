/*
 * dual_master_system.v : Top-level System Integration
 * 
 * Integrates SERV RISC-V processor + ALU Master with 4 Slave Memories via AXI Interconnect
 * 
 * Architecture:
 * 
 *     [SERV RISC-V]    [ALU Master]
 *            |              |
 *     [serv_axi_wrapper]  [CPU_ALU_Master]
 *            |              |
 *       [M0_AXI]      [M1_AXI]
 *       (Inst)        (ALU)
 *            |              |
 *            +--------+--------+
 *                     |
 *          [AXI Interconnect]
 *                     |
 *        +------+-----+-----+------+
 *        |      |     |     |      |
 *    [M00]   [M01] [M02] [M03]
 *  (Slave0) (Slave1) (Slave2) (Slave3)
 *  (ROM)    (RAM)   (RAM)   (RAM)
 * 
 * Address Mapping:
 *   - Slave 0 (M00): 0x0000_0000 - 0x3FFF_FFFF (bits [31:30] = 00) - Instruction Memory
 *   - Slave 1 (M01): 0x4000_0000 - 0x7FFF_FFFF (bits [31:30] = 01) - Data Memory
 *   - Slave 2 (M02): 0x8000_0000 - 0xBFFF_FFFF (bits [31:30] = 10) - ALU Memory
 *   - Slave 3 (M03): 0xC000_0000 - 0xFFFF_FFFF (bits [31:30] = 11) - Reserved
 */

module dual_master_system #(
    // AXI Parameters
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    
    // SERV Parameters
    parameter WITH_CSR = 1,
    parameter W = 1,
    parameter PRE_REGISTER = 1,
    parameter RESET_STRATEGY = "MINI",
    parameter RESET_PC = 32'h0000_0000,
    parameter [0:0] DEBUG = 1'b0,
    parameter [0:0] MDU = 1'b0,
    parameter [0:0] COMPRESSED = 0,
    
    // Memory Parameters
    parameter MEM_SIZE = 256,  // 256 words = 1KB per slave
    
    // AXI Interconnect Parameters
    parameter Masters_Num = 2,
    parameter Address_width = 32,
    parameter S00_Aw_len = 8,
    parameter S00_Write_data_bus_width = 32,
    parameter S00_Write_data_bytes_num = 4,
    parameter S00_AR_len = 8,
    parameter S00_Read_data_bus_width = 32,
    parameter S01_Aw_len = 8,
    parameter S01_Write_data_bus_width = 32,
    parameter S01_AR_len = 8,
    parameter M00_Aw_len = 8,
    parameter M00_Write_data_bus_width = 32,
    parameter M00_Write_data_bytes_num = 4,
    parameter M00_AR_len = 8,
    parameter M00_Read_data_bus_width = 32,
    parameter M01_Aw_len = 8,
    parameter M01_AR_len = 8,
    parameter M02_Aw_len = 8,
    parameter M02_AR_len = 8,
    parameter M02_Read_data_bus_width = 32,
    parameter M03_Aw_len = 8,
    parameter M03_AR_len = 8,
    parameter M03_Read_data_bus_width = 32,
    parameter Is_Master_AXI_4 = 1'b1,
    parameter M1_ID = 0,
    parameter M2_ID = 1,
    parameter Resp_ID_width = 2,
    parameter Num_Of_Masters = 2,
    parameter Num_Of_Slaves = 4,
    parameter Master_ID_Width = 1,
    parameter AXI4_AR_len = 8,
    parameter AXI4_Aw_len = 8,
    
    // Address Mapping
    // Address ranges must match MSB bits [31:30] used by decoder
    parameter SLAVE0_ADDR1 = 32'h0000_0000,  // bits [31:30] = 00 - Instruction Memory
    parameter SLAVE0_ADDR2 = 32'h3FFF_FFFF,
    parameter SLAVE1_ADDR1 = 32'h4000_0000,  // bits [31:30] = 01 - Data Memory
    parameter SLAVE1_ADDR2 = 32'h7FFF_FFFF,
    parameter SLAVE2_ADDR1 = 32'h8000_0000,  // bits [31:30] = 10 - ALU Memory
    parameter SLAVE2_ADDR2 = 32'hBFFF_FFFF,
    parameter SLAVE3_ADDR1 = 32'hC000_0000,  // bits [31:30] = 11 - Reserved
    parameter SLAVE3_ADDR2 = 32'hFFFF_FFFF
) (
    // Global signals
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Timer interrupt (optional)
    input  wire                    i_timer_irq,
    
    // ALU Master Control
    input  wire                    alu_master_start,
    output wire                    alu_master_busy,
    output wire                    alu_master_done,
    
    // ========================================================================
    // Slave 0 Interface (Instruction Memory - Read-only)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]   M00_AXI_araddr,
    output wire [7:0]              M00_AXI_arlen,
    output wire [2:0]              M00_AXI_arsize,
    output wire [1:0]              M00_AXI_arburst,
    output wire [1:0]              M00_AXI_arlock,
    output wire [3:0]              M00_AXI_arcache,
    output wire [2:0]              M00_AXI_arprot,
    output wire [3:0]              M00_AXI_arregion,
    output wire [3:0]              M00_AXI_arqos,
    output wire                    M00_AXI_arvalid,
    input  wire                    M00_AXI_arready,
    
    input  wire [DATA_WIDTH-1:0]   M00_AXI_rdata,
    input  wire [1:0]              M00_AXI_rresp,
    input  wire                    M00_AXI_rlast,
    input  wire                    M00_AXI_rvalid,
    output wire                    M00_AXI_rready,
    
    // ========================================================================
    // Slave 1 Interface (Data Memory - Read-write)
    // ========================================================================
    output wire [ID_WIDTH-1:0]     M01_AXI_awid,
    output wire [ADDR_WIDTH-1:0]   M01_AXI_awaddr,
    output wire [7:0]              M01_AXI_awlen,
    output wire [2:0]              M01_AXI_awsize,
    output wire [1:0]              M01_AXI_awburst,
    output wire [1:0]              M01_AXI_awlock,
    output wire [3:0]              M01_AXI_awcache,
    output wire [2:0]              M01_AXI_awprot,
    output wire [3:0]              M01_AXI_awqos,
    output wire [3:0]              M01_AXI_awregion,
    output wire                    M01_AXI_awvalid,
    input  wire                    M01_AXI_awready,
    
    output wire [DATA_WIDTH-1:0]   M01_AXI_wdata,
    output wire [(DATA_WIDTH/8)-1:0] M01_AXI_wstrb,
    output wire                    M01_AXI_wlast,
    output wire                    M01_AXI_wvalid,
    input  wire                    M01_AXI_wready,
    
    input  wire [ID_WIDTH-1:0]     M01_AXI_bid,
    input  wire [1:0]              M01_AXI_bresp,
    input  wire                    M01_AXI_bvalid,
    output wire                    M01_AXI_bready,
    
    output wire [ID_WIDTH-1:0]     M01_AXI_arid,
    output wire [ADDR_WIDTH-1:0]   M01_AXI_araddr,
    output wire [7:0]              M01_AXI_arlen,
    output wire [2:0]              M01_AXI_arsize,
    output wire [1:0]              M01_AXI_arburst,
    output wire [1:0]              M01_AXI_arlock,
    output wire [3:0]              M01_AXI_arcache,
    output wire [2:0]              M01_AXI_arprot,
    output wire [3:0]              M01_AXI_arqos,
    output wire [3:0]              M01_AXI_arregion,
    output wire                    M01_AXI_arvalid,
    input  wire                    M01_AXI_arready,
    
    input  wire [ID_WIDTH-1:0]     M01_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M01_AXI_rdata,
    input  wire [1:0]              M01_AXI_rresp,
    input  wire                    M01_AXI_rlast,
    input  wire                    M01_AXI_rvalid,
    output wire                    M01_AXI_rready,
    
    // ========================================================================
    // Slave 2 Interface (ALU Memory - Read-write)
    // ========================================================================
    output wire [ID_WIDTH-1:0]     M02_AXI_awid,
    output wire [ADDR_WIDTH-1:0]   M02_AXI_awaddr,
    output wire [7:0]              M02_AXI_awlen,
    output wire [2:0]              M02_AXI_awsize,
    output wire [1:0]              M02_AXI_awburst,
    output wire [1:0]              M02_AXI_awlock,
    output wire [3:0]              M02_AXI_awcache,
    output wire [2:0]              M02_AXI_awprot,
    output wire [3:0]              M02_AXI_awqos,
    output wire [3:0]              M02_AXI_awregion,
    output wire                    M02_AXI_awvalid,
    input  wire                    M02_AXI_awready,
    
    output wire [DATA_WIDTH-1:0]   M02_AXI_wdata,
    output wire [(DATA_WIDTH/8)-1:0] M02_AXI_wstrb,
    output wire                    M02_AXI_wlast,
    output wire                    M02_AXI_wvalid,
    input  wire                    M02_AXI_wready,
    
    input  wire [ID_WIDTH-1:0]     M02_AXI_bid,
    input  wire [1:0]              M02_AXI_bresp,
    input  wire                    M02_AXI_bvalid,
    output wire                    M02_AXI_bready,
    
    output wire [ID_WIDTH-1:0]     M02_AXI_arid,
    output wire [ADDR_WIDTH-1:0]   M02_AXI_araddr,
    output wire [7:0]              M02_AXI_arlen,
    output wire [2:0]              M02_AXI_arsize,
    output wire [1:0]              M02_AXI_arburst,
    output wire [1:0]              M02_AXI_arlock,
    output wire [3:0]              M02_AXI_arcache,
    output wire [2:0]              M02_AXI_arprot,
    output wire [3:0]              M02_AXI_arqos,
    output wire [3:0]              M02_AXI_arregion,
    output wire                    M02_AXI_arvalid,
    input  wire                    M02_AXI_arready,
    
    input  wire [ID_WIDTH-1:0]     M02_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M02_AXI_rdata,
    input  wire [1:0]              M02_AXI_rresp,
    input  wire                    M02_AXI_rlast,
    input  wire                    M02_AXI_rvalid,
    output wire                    M02_AXI_rready,
    
    // ========================================================================
    // Slave 3 Interface (Reserved - Read-only for now)
    // ========================================================================
    output wire [ID_WIDTH-1:0]     M03_AXI_arid,
    output wire [ADDR_WIDTH-1:0]   M03_AXI_araddr,
    output wire [7:0]              M03_AXI_arlen,
    output wire [2:0]              M03_AXI_arsize,
    output wire [1:0]              M03_AXI_arburst,
    output wire [1:0]              M03_AXI_arlock,
    output wire [3:0]              M03_AXI_arcache,
    output wire [2:0]              M03_AXI_arprot,
    output wire [3:0]              M03_AXI_arqos,
    output wire [3:0]              M03_AXI_arregion,
    output wire                    M03_AXI_arvalid,
    input  wire                    M03_AXI_arready,
    
    input  wire [ID_WIDTH-1:0]     M03_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M03_AXI_rdata,
    input  wire [1:0]              M03_AXI_rresp,
    input  wire                    M03_AXI_rlast,
    input  wire                    M03_AXI_rvalid,
    output wire                    M03_AXI_rready
);

    // Internal AXI signals from SERV wrapper (Instruction + Data buses)
    wire [ID_WIDTH-1:0]     S00_AXI_arid;
    wire [ADDR_WIDTH-1:0]   S00_AXI_araddr;
    wire [7:0]              S00_AXI_arlen;
    wire [2:0]              S00_AXI_arsize;
    wire [1:0]              S00_AXI_arburst;
    wire [1:0]              S00_AXI_arlock;
    wire [3:0]              S00_AXI_arcache;
    wire [2:0]              S00_AXI_arprot;
    wire [3:0]              S00_AXI_arqos;
    wire [3:0]              S00_AXI_arregion;
    wire                    S00_AXI_arvalid;
    wire                    S00_AXI_arready;
    
    wire [ID_WIDTH-1:0]     S00_AXI_rid;
    wire [DATA_WIDTH-1:0]   S00_AXI_rdata;
    wire [1:0]              S00_AXI_rresp;
    wire                    S00_AXI_rlast;
    wire                    S00_AXI_rvalid;
    wire                    S00_AXI_rready;
    
    wire [ID_WIDTH-1:0]     S01_AXI_awid;
    wire [ADDR_WIDTH-1:0]   S01_AXI_awaddr;
    wire [7:0]              S01_AXI_awlen;
    wire [2:0]              S01_AXI_awsize;
    wire [1:0]              S01_AXI_awburst;
    wire [1:0]              S01_AXI_awlock;
    wire [3:0]              S01_AXI_awcache;
    wire [2:0]              S01_AXI_awprot;
    wire [3:0]              S01_AXI_awqos;
    wire [3:0]              S01_AXI_awregion;
    wire                    S01_AXI_awvalid;
    wire                    S01_AXI_awready;
    
    wire [DATA_WIDTH-1:0]   S01_AXI_wdata;
    wire [(DATA_WIDTH/8)-1:0] S01_AXI_wstrb;
    wire                    S01_AXI_wlast;
    wire                    S01_AXI_wvalid;
    wire                    S01_AXI_wready;
    
    wire [ID_WIDTH-1:0]     S01_AXI_bid;
    wire [1:0]              S01_AXI_bresp;
    wire                    S01_AXI_bvalid;
    wire                    S01_AXI_bready;
    
    wire [ID_WIDTH-1:0]     S01_AXI_arid;
    wire [ADDR_WIDTH-1:0]   S01_AXI_araddr;
    wire [7:0]              S01_AXI_arlen;
    wire [2:0]              S01_AXI_arsize;
    wire [1:0]              S01_AXI_arburst;
    wire [1:0]              S01_AXI_arlock;
    wire [3:0]              S01_AXI_arcache;
    wire [2:0]              S01_AXI_arprot;
    wire [3:0]              S01_AXI_arqos;
    wire [3:0]              S01_AXI_arregion;
    wire                    S01_AXI_arvalid;
    wire                    S01_AXI_arready;
    
    wire [ID_WIDTH-1:0]     S01_AXI_rid;
    wire [DATA_WIDTH-1:0]   S01_AXI_rdata;
    wire [1:0]              S01_AXI_rresp;
    wire                    S01_AXI_rlast;
    wire                    S01_AXI_rvalid;
    wire                    S01_AXI_rready;
    
    // Internal AXI signals from ALU Master
    wire [ADDR_WIDTH-1:0]   S02_AXI_awaddr;
    wire [7:0]              S02_AXI_awlen;
    wire [2:0]              S02_AXI_awsize;
    wire [1:0]              S02_AXI_awburst;
    wire [1:0]              S02_AXI_awlock;
    wire [3:0]              S02_AXI_awcache;
    wire [2:0]              S02_AXI_awprot;
    wire [3:0]              S02_AXI_awqos;
    wire [3:0]              S02_AXI_awregion;
    wire                    S02_AXI_awvalid;
    wire                    S02_AXI_awready;
    
    wire [DATA_WIDTH-1:0]   S02_AXI_wdata;
    wire [3:0]              S02_AXI_wstrb;
    wire                    S02_AXI_wlast;
    wire                    S02_AXI_wvalid;
    wire                    S02_AXI_wready;
    
    wire [1:0]              S02_AXI_bresp;
    wire                    S02_AXI_bvalid;
    wire                    S02_AXI_bready;
    
    wire [ADDR_WIDTH-1:0]   S02_AXI_araddr;
    wire [7:0]              S02_AXI_arlen;
    wire [2:0]              S02_AXI_arsize;
    wire [1:0]              S02_AXI_arburst;
    wire [1:0]              S02_AXI_arlock;
    wire [3:0]              S02_AXI_arcache;
    wire [2:0]              S02_AXI_arprot;
    wire [3:0]              S02_AXI_arqos;
    wire [3:0]              S02_AXI_arregion;
    wire                    S02_AXI_arvalid;
    wire                    S02_AXI_arready;
    
    wire [DATA_WIDTH-1:0]   S02_AXI_rdata;
    wire [1:0]              S02_AXI_rresp;
    wire                    S02_AXI_rlast;
    wire                    S02_AXI_rvalid;
    wire                    S02_AXI_rready;
    
    // ========================================================================
    // Tie-off wires
    // ========================================================================
    wire M00_AXI_bready_tie = 1'b0;  // Read-only slave
    
    // ========================================================================
    // SERV AXI Wrapper Instance
    // ========================================================================
    serv_axi_wrapper #(
        .ADDR_WIDTH     (ADDR_WIDTH),
        .DATA_WIDTH     (DATA_WIDTH),
        .ID_WIDTH       (ID_WIDTH),
        .WITH_CSR       (WITH_CSR),
        .W              (W),
        .PRE_REGISTER   (PRE_REGISTER),
        .RESET_STRATEGY (RESET_STRATEGY),
        .RESET_PC       (RESET_PC),
        .DEBUG          (DEBUG),
        .MDU            (MDU),
        .COMPRESSED     (COMPRESSED)
    ) u_serv_wrapper (
        .ACLK           (ACLK),
        .ARESETN        (ARESETN),
        .i_timer_irq    (i_timer_irq),
        
        // AXI Master 0 (Instruction Bus)
        .M0_AXI_arid    (S00_AXI_arid),
        .M0_AXI_araddr  (S00_AXI_araddr),
        .M0_AXI_arlen   (S00_AXI_arlen),
        .M0_AXI_arsize  (S00_AXI_arsize),
        .M0_AXI_arburst (S00_AXI_arburst),
        .M0_AXI_arlock  (S00_AXI_arlock),
        .M0_AXI_arcache (S00_AXI_arcache),
        .M0_AXI_arprot  (S00_AXI_arprot),
        .M0_AXI_arqos   (S00_AXI_arqos),
        .M0_AXI_arregion(S00_AXI_arregion),
        .M0_AXI_arvalid (S00_AXI_arvalid),
        .M0_AXI_arready (S00_AXI_arready),
        
        .M0_AXI_rid     (S00_AXI_rid),
        .M0_AXI_rdata   (S00_AXI_rdata),
        .M0_AXI_rresp   (S00_AXI_rresp),
        .M0_AXI_rlast   (S00_AXI_rlast),
        .M0_AXI_rvalid  (S00_AXI_rvalid),
        .M0_AXI_rready  (S00_AXI_rready),
        
        // AXI Master 1 (Data Bus)
        .M1_AXI_awid    (S01_AXI_awid),
        .M1_AXI_awaddr  (S01_AXI_awaddr),
        .M1_AXI_awlen   (S01_AXI_awlen),
        .M1_AXI_awsize  (S01_AXI_awsize),
        .M1_AXI_awburst (S01_AXI_awburst),
        .M1_AXI_awlock  (S01_AXI_awlock),
        .M1_AXI_awcache (S01_AXI_awcache),
        .M1_AXI_awprot  (S01_AXI_awprot),
        .M1_AXI_awqos   (S01_AXI_awqos),
        .M1_AXI_awregion(S01_AXI_awregion),
        .M1_AXI_awvalid (S01_AXI_awvalid),
        .M1_AXI_awready (S01_AXI_awready),
        
        .M1_AXI_wdata   (S01_AXI_wdata),
        .M1_AXI_wstrb   (S01_AXI_wstrb),
        .M1_AXI_wlast   (S01_AXI_wlast),
        .M1_AXI_wvalid  (S01_AXI_wvalid),
        .M1_AXI_wready  (S01_AXI_wready),
        
        .M1_AXI_bid     (S01_AXI_bid),
        .M1_AXI_bresp   (S01_AXI_bresp),
        .M1_AXI_bvalid  (S01_AXI_bvalid),
        .M1_AXI_bready  (S01_AXI_bready),
        
        .M1_AXI_arid    (S01_AXI_arid),
        .M1_AXI_araddr  (S01_AXI_araddr),
        .M1_AXI_arlen   (S01_AXI_arlen),
        .M1_AXI_arsize  (S01_AXI_arsize),
        .M1_AXI_arburst (S01_AXI_arburst),
        .M1_AXI_arlock  (S01_AXI_arlock),
        .M1_AXI_arcache (S01_AXI_arcache),
        .M1_AXI_arprot  (S01_AXI_arprot),
        .M1_AXI_arqos   (S01_AXI_arqos),
        .M1_AXI_arregion(S01_AXI_arregion),
        .M1_AXI_arvalid (S01_AXI_arvalid),
        .M1_AXI_arready (S01_AXI_arready),
        
        .M1_AXI_rid     (S01_AXI_rid),
        .M1_AXI_rdata   (S01_AXI_rdata),
        .M1_AXI_rresp   (S01_AXI_rresp),
        .M1_AXI_rlast   (S01_AXI_rlast),
        .M1_AXI_rvalid  (S01_AXI_rvalid),
        .M1_AXI_rready  (S01_AXI_rready)
    );
    
    // ========================================================================
    // ALU Master Instance
    // ========================================================================
    CPU_ALU_Master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu_master (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(alu_master_start),
        .busy(alu_master_busy),
        .done(alu_master_done),
        
        // AXI Master Interface
        .M_AXI_awaddr(S02_AXI_awaddr),
        .M_AXI_awlen(S02_AXI_awlen),
        .M_AXI_awsize(S02_AXI_awsize),
        .M_AXI_awburst(S02_AXI_awburst),
        .M_AXI_awlock(S02_AXI_awlock),
        .M_AXI_awcache(S02_AXI_awcache),
        .M_AXI_awprot(S02_AXI_awprot),
        .M_AXI_awregion(S02_AXI_awregion),
        .M_AXI_awqos(S02_AXI_awqos),
        .M_AXI_awvalid(S02_AXI_awvalid),
        .M_AXI_awready(S02_AXI_awready),
        .M_AXI_wdata(S02_AXI_wdata),
        .M_AXI_wstrb(S02_AXI_wstrb),
        .M_AXI_wlast(S02_AXI_wlast),
        .M_AXI_wvalid(S02_AXI_wvalid),
        .M_AXI_wready(S02_AXI_wready),
        .M_AXI_bresp(S02_AXI_bresp),
        .M_AXI_bvalid(S02_AXI_bvalid),
        .M_AXI_bready(S02_AXI_bready),
        .M_AXI_araddr(S02_AXI_araddr),
        .M_AXI_arlen(S02_AXI_arlen),
        .M_AXI_arsize(S02_AXI_arsize),
        .M_AXI_arburst(S02_AXI_arburst),
        .M_AXI_arlock(S02_AXI_arlock),
        .M_AXI_arcache(S02_AXI_arcache),
        .M_AXI_arprot(S02_AXI_arprot),
        .M_AXI_arregion(S02_AXI_arregion),
        .M_AXI_arqos(S02_AXI_arqos),
        .M_AXI_arvalid(S02_AXI_arvalid),
        .M_AXI_arready(S02_AXI_arready),
        .M_AXI_rdata(S02_AXI_rdata),
        .M_AXI_rresp(S02_AXI_rresp),
        .M_AXI_rlast(S02_AXI_rlast),
        .M_AXI_rvalid(S02_AXI_rvalid),
        .M_AXI_rready(S02_AXI_rready)
    );
    
    // ========================================================================
    // AXI Interconnect Instance
    // ========================================================================
    // Note: AXI_Interconnect_Full supports up to 2 masters (S00, S01)
    // We need to use S00 for SERV (both instruction and data) and S01 for ALU
    // But SERV has 2 buses (instruction + data), so we need to handle this differently
    
    // For now, we'll connect:
    // - S00: SERV Instruction Bus (read-only) -> routes to M00 (Slave 0)
    // - S01: SERV Data Bus (read-write) -> routes to M01 (Slave 1)
    // - ALU Master: We need to add as a third master, but interconnect only supports 2
    // Solution: Connect ALU to S01 and use address decoding to route to different slaves
    
    // Actually, let's use a different approach:
    // - S00: SERV Instruction Bus -> M00 (Slave 0)
    // - S01: SERV Data Bus -> M01 (Slave 1)  
    // - ALU Master: Connect directly to M02 (bypass interconnect for now)
    // OR: Use a wrapper that combines SERV data + ALU into one master port
    
    // Better solution: Create a simple mux/arbiter for ALU master
    // For simplicity, let's connect ALU directly to M02 for now
    
    // Temporary: Connect ALU directly to M02 (bypass interconnect)
    // TODO: Add proper interconnect support for 3 masters
    
    assign M02_AXI_awid = 4'h0;
    assign M02_AXI_awaddr = S02_AXI_awaddr;
    assign M02_AXI_awlen = S02_AXI_awlen;
    assign M02_AXI_awsize = S02_AXI_awsize;
    assign M02_AXI_awburst = S02_AXI_awburst;
    assign M02_AXI_awlock = S02_AXI_awlock;
    assign M02_AXI_awcache = S02_AXI_awcache;
    assign M02_AXI_awprot = S02_AXI_awprot;
    assign M02_AXI_awqos = S02_AXI_awqos;
    assign M02_AXI_awregion = S02_AXI_awregion;
    assign M02_AXI_awvalid = S02_AXI_awvalid;
    assign S02_AXI_awready = M02_AXI_awready;
    
    assign M02_AXI_wdata = S02_AXI_wdata;
    assign M02_AXI_wstrb = S02_AXI_wstrb;
    assign M02_AXI_wlast = S02_AXI_wlast;
    assign M02_AXI_wvalid = S02_AXI_wvalid;
    assign S02_AXI_wready = M02_AXI_wready;
    
    assign S02_AXI_bresp = M02_AXI_bresp;
    assign S02_AXI_bvalid = M02_AXI_bvalid;
    assign M02_AXI_bready = S02_AXI_bready;
    assign S02_AXI_bid = M02_AXI_bid;
    
    assign M02_AXI_arid = 4'h0;
    assign M02_AXI_araddr = S02_AXI_araddr;
    assign M02_AXI_arlen = S02_AXI_arlen;
    assign M02_AXI_arsize = S02_AXI_arsize;
    assign M02_AXI_arburst = S02_AXI_arburst;
    assign M02_AXI_arlock = S02_AXI_arlock;
    assign M02_AXI_arcache = S02_AXI_arcache;
    assign M02_AXI_arprot = S02_AXI_arprot;
    assign M02_AXI_arqos = S02_AXI_arqos;
    assign M02_AXI_arregion = S02_AXI_arregion;
    assign M02_AXI_arvalid = S02_AXI_arvalid;
    assign S02_AXI_arready = M02_AXI_arready;
    
    assign S02_AXI_rdata = M02_AXI_rdata;
    assign S02_AXI_rresp = M02_AXI_rresp;
    assign S02_AXI_rlast = M02_AXI_rlast;
    assign S02_AXI_rvalid = M02_AXI_rvalid;
    assign M02_AXI_rready = S02_AXI_rready;
    assign S02_AXI_rid = M02_AXI_rid;
    
    // AXI Interconnect for SERV (2 masters: Instruction + Data)
    AXI_Interconnect_Full #(
        .Masters_Num(Masters_Num),
        .Address_width(Address_width),
        .S00_Aw_len(S00_Aw_len),
        .S00_Write_data_bus_width(S00_Write_data_bus_width),
        .S00_Write_data_bytes_num(S00_Write_data_bytes_num),
        .S00_AR_len(S00_AR_len),
        .S00_Read_data_bus_width(S00_Read_data_bus_width),
        .S01_Aw_len(S01_Aw_len),
        .S01_Write_data_bus_width(S01_Write_data_bus_width),
        .S01_AR_len(S01_AR_len),
        .M00_Aw_len(M00_Aw_len),
        .M00_Write_data_bus_width(M00_Write_data_bus_width),
        .M00_Write_data_bytes_num(M00_Write_data_bytes_num),
        .M00_AR_len(M00_AR_len),
        .M00_Read_data_bus_width(M00_Read_data_bus_width),
        .M01_Aw_len(M01_Aw_len),
        .M01_AR_len(M01_AR_len),
        .M02_Aw_len(M02_Aw_len),
        .M02_AR_len(M02_AR_len),
        .M02_Read_data_bus_width(M02_Read_data_bus_width),
        .M03_Aw_len(M03_Aw_len),
        .M03_AR_len(M03_AR_len),
        .M03_Read_data_bus_width(M03_Read_data_bus_width),
        .Is_Master_AXI_4(Is_Master_AXI_4),
        .M1_ID(M1_ID),
        .M2_ID(M2_ID),
        .Resp_ID_width(Resp_ID_width),
        .Num_Of_Masters(Num_Of_Masters),
        .Num_Of_Slaves(Num_Of_Slaves),
        .Master_ID_Width(Master_ID_Width),
        .AXI4_AR_len(AXI4_AR_len),
        .AXI4_Aw_len(AXI4_Aw_len)
    ) u_axi_interconnect (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0 (SERV Instruction Bus - Read-only)
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S00_AXI_awaddr(32'h0),  // Read-only, tie off
        .S00_AXI_awlen(8'h0),
        .S00_AXI_awsize(3'h0),
        .S00_AXI_awburst(2'h0),
        .S00_AXI_awlock(2'h0),
        .S00_AXI_awcache(4'h0),
        .S00_AXI_awprot(3'h0),
        .S00_AXI_awqos(4'h0),
        .S00_AXI_awvalid(1'b0),
        .S00_AXI_awready(),
        .S00_AXI_wdata(32'h0),
        .S00_AXI_wstrb(4'h0),
        .S00_AXI_wlast(1'b0),
        .S00_AXI_wvalid(1'b0),
        .S00_AXI_wready(),
        .S00_AXI_bresp(),
        .S00_AXI_bvalid(),
        .S00_AXI_bready(1'b0),
        .S00_AXI_araddr(S00_AXI_araddr),
        .S00_AXI_arlen(S00_AXI_arlen),
        .S00_AXI_arsize(S00_AXI_arsize),
        .S00_AXI_arburst(S00_AXI_arburst),
        .S00_AXI_arlock(S00_AXI_arlock),
        .S00_AXI_arcache(S00_AXI_arcache),
        .S00_AXI_arprot(S00_AXI_arprot),
        .S00_AXI_arregion(S00_AXI_arregion),
        .S00_AXI_arqos(S00_AXI_arqos),
        .S00_AXI_arvalid(S00_AXI_arvalid),
        .S00_AXI_arready(S00_AXI_arready),
        .S00_AXI_rdata(S00_AXI_rdata),
        .S00_AXI_rresp(S00_AXI_rresp),
        .S00_AXI_rlast(S00_AXI_rlast),
        .S00_AXI_rvalid(S00_AXI_rvalid),
        .S00_AXI_rready(S00_AXI_rready),
        
        // Master 1 (SERV Data Bus - Read-write)
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        .S01_AXI_awaddr(S01_AXI_awaddr),
        .S01_AXI_awlen(S01_AXI_awlen),
        .S01_AXI_awsize(S01_AXI_awsize),
        .S01_AXI_awburst(S01_AXI_awburst),
        .S01_AXI_awlock(S01_AXI_awlock),
        .S01_AXI_awcache(S01_AXI_awcache),
        .S01_AXI_awprot(S01_AXI_awprot),
        .S01_AXI_awqos(S01_AXI_awqos),
        .S01_AXI_awvalid(S01_AXI_awvalid),
        .S01_AXI_awready(S01_AXI_awready),
        .S01_AXI_wdata(S01_AXI_wdata),
        .S01_AXI_wstrb(S01_AXI_wstrb),
        .S01_AXI_wlast(S01_AXI_wlast),
        .S01_AXI_wvalid(S01_AXI_wvalid),
        .S01_AXI_wready(S01_AXI_wready),
        .S01_AXI_bresp(S01_AXI_bresp),
        .S01_AXI_bvalid(S01_AXI_bvalid),
        .S01_AXI_bready(S01_AXI_bready),
        .S01_AXI_araddr(S01_AXI_araddr),
        .S01_AXI_arlen(S01_AXI_arlen),
        .S01_AXI_arsize(S01_AXI_arsize),
        .S01_AXI_arburst(S01_AXI_arburst),
        .S01_AXI_arlock(S01_AXI_arlock),
        .S01_AXI_arcache(S01_AXI_arcache),
        .S01_AXI_arprot(S01_AXI_arprot),
        .S01_AXI_arregion(4'b0),
        .S01_AXI_arqos(S01_AXI_arqos),
        .S01_AXI_arvalid(S01_AXI_arvalid),
        .S01_AXI_arready(S01_AXI_arready),
        .S01_AXI_rdata(S01_AXI_rdata),
        .S01_AXI_rresp(S01_AXI_rresp),
        .S01_AXI_rlast(S01_AXI_rlast),
        .S01_AXI_rvalid(S01_AXI_rvalid),
        .S01_AXI_rready(S01_AXI_rready),
        
        // Slave 0 (Instruction Memory - Read-only)
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        .M00_AXI_awaddr_ID(),
        .M00_AXI_awaddr(),
        .M00_AXI_awlen(),
        .M00_AXI_awsize(),
        .M00_AXI_awburst(),
        .M00_AXI_awlock(),
        .M00_AXI_awcache(),
        .M00_AXI_awprot(),
        .M00_AXI_awqos(),
        .M00_AXI_awvalid(),
        .M00_AXI_awready(1'b1),
        .M00_AXI_wdata(),
        .M00_AXI_wstrb(),
        .M00_AXI_wlast(),
        .M00_AXI_wvalid(),
        .M00_AXI_wready(1'b1),
        .M00_AXI_BID(),
        .M00_AXI_bresp(),
        .M00_AXI_bvalid(),
        .M00_AXI_bready(M00_AXI_bready_tie),
        .M00_AXI_araddr(M00_AXI_araddr),
        .M00_AXI_arlen(M00_AXI_arlen),
        .M00_AXI_arsize(M00_AXI_arsize),
        .M00_AXI_arburst(M00_AXI_arburst),
        .M00_AXI_arlock(M00_AXI_arlock),
        .M00_AXI_arcache(M00_AXI_arcache),
        .M00_AXI_arprot(M00_AXI_arprot),
        .M00_AXI_arregion(M00_AXI_arregion),
        .M00_AXI_arqos(M00_AXI_arqos),
        .M00_AXI_arvalid(M00_AXI_arvalid),
        .M00_AXI_arready(M00_AXI_arready),
        .M00_AXI_rdata(M00_AXI_rdata),
        .M00_AXI_rresp(M00_AXI_rresp),
        .M00_AXI_rlast(M00_AXI_rlast),
        .M00_AXI_rvalid(M00_AXI_rvalid),
        .M00_AXI_rready(M00_AXI_rready),
        
        // Slave 1 (Data Memory - Read-write)
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        .M01_AXI_awaddr_ID(M01_AXI_awid[0]),
        .M01_AXI_awaddr(M01_AXI_awaddr),
        .M01_AXI_awlen(M01_AXI_awlen),
        .M01_AXI_awsize(M01_AXI_awsize),
        .M01_AXI_awburst(M01_AXI_awburst),
        .M01_AXI_awlock(M01_AXI_awlock),
        .M01_AXI_awcache(M01_AXI_awcache),
        .M01_AXI_awprot(M01_AXI_awprot),
        .M01_AXI_awqos(M01_AXI_awqos),
        .M01_AXI_awvalid(M01_AXI_awvalid),
        .M01_AXI_awready(M01_AXI_awready),
        .M01_AXI_wdata(M01_AXI_wdata),
        .M01_AXI_wstrb(M01_AXI_wstrb),
        .M01_AXI_wlast(M01_AXI_wlast),
        .M01_AXI_wvalid(M01_AXI_wvalid),
        .M01_AXI_wready(M01_AXI_wready),
        .M01_AXI_BID(M01_AXI_bid[0]),
        .M01_AXI_bresp(M01_AXI_bresp),
        .M01_AXI_bvalid(M01_AXI_bvalid),
        .M01_AXI_bready(M01_AXI_bready),
        .M01_AXI_araddr(M01_AXI_araddr),
        .M01_AXI_arlen(M01_AXI_arlen),
        .M01_AXI_arsize(M01_AXI_arsize),
        .M01_AXI_arburst(M01_AXI_arburst),
        .M01_AXI_arlock(M01_AXI_arlock),
        .M01_AXI_arcache(M01_AXI_arcache),
        .M01_AXI_arprot(M01_AXI_arprot),
        .M01_AXI_arregion(M01_AXI_arregion),
        .M01_AXI_arqos(M01_AXI_arqos),
        .M01_AXI_arvalid(M01_AXI_arvalid),
        .M01_AXI_arready(M01_AXI_arready),
        .M01_AXI_rdata(M01_AXI_rdata),
        .M01_AXI_rresp(M01_AXI_rresp),
        .M01_AXI_rlast(M01_AXI_rlast),
        .M01_AXI_rvalid(M01_AXI_rvalid),
        .M01_AXI_rready(M01_AXI_rready),
        
        // Slave 2 (ALU Memory - Read-write) - Connected directly, bypass interconnect
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        .M02_AXI_araddr(),
        .M02_AXI_arlen(),
        .M02_AXI_arsize(),
        .M02_AXI_arburst(),
        .M02_AXI_arlock(),
        .M02_AXI_arcache(),
        .M02_AXI_arprot(),
        .M02_AXI_arregion(),
        .M02_AXI_arqos(),
        .M02_AXI_arvalid(),
        .M02_AXI_arready(1'b1),
        .M02_AXI_rdata(32'h0),
        .M02_AXI_rresp(2'b00),
        .M02_AXI_rlast(1'b1),
        .M02_AXI_rvalid(1'b0),
        .M02_AXI_rready(),
        
        // Slave 3 (Reserved - Read-only)
        .M03_ACLK(ACLK),
        .M03_ARESETN(ARESETN),
        .M03_AXI_araddr(M03_AXI_araddr),
        .M03_AXI_arlen(M03_AXI_arlen),
        .M03_AXI_arsize(M03_AXI_arsize),
        .M03_AXI_arburst(M03_AXI_arburst),
        .M03_AXI_arlock(M03_AXI_arlock),
        .M03_AXI_arcache(M03_AXI_arcache),
        .M03_AXI_arprot(M03_AXI_arprot),
        .M03_AXI_arregion(M03_AXI_arregion),
        .M03_AXI_arqos(M03_AXI_arqos),
        .M03_AXI_arvalid(M03_AXI_arvalid),
        .M03_AXI_arready(M03_AXI_arready),
        .M03_AXI_rdata(M03_AXI_rdata),
        .M03_AXI_rresp(M03_AXI_rresp),
        .M03_AXI_rlast(M03_AXI_rlast),
        .M03_AXI_rvalid(M03_AXI_rvalid),
        .M03_AXI_rready(M03_AXI_rready),
        
        // Address ranges for slaves
        .slave0_addr1(SLAVE0_ADDR1),
        .slave0_addr2(SLAVE0_ADDR2),
        .slave1_addr1(SLAVE1_ADDR1),
        .slave1_addr2(SLAVE1_ADDR2),
        .slave2_addr1(SLAVE2_ADDR1),
        .slave2_addr2(SLAVE2_ADDR2),
        .slave3_addr1(SLAVE3_ADDR1),
        .slave3_addr2(SLAVE3_ADDR2)
    );

endmodule

