/*
 * alu_master_system.v : Top-level System Integration
 * 
 * Integrates 2 ALU Masters with 4 Slave Memories via AXI Interconnect
 * 
 * Architecture:
 * 
 *     [ALU Master 0]    [ALU Master 1]
 *            |                 |
 *       [S00_AXI]        [S01_AXI]
 *            |                 |
 *            +--------+--------+
 *                     |
 *          [AXI Interconnect]
 *                     |
 *        +------+-----+-----+------+
 *        |      |     |     |      |
 *    [M00]   [M01] [M02] [M03]
 *  (Slave0) (Slave1) (Slave2) (Slave3)
 *  (Memory) (Memory) (Memory) (Memory)
 * 
 * Address Mapping:
 *   - Slave 0 (M00): 0x0000_0000 - 0x3FFF_FFFF (bits [31:30] = 00)
 *   - Slave 1 (M01): 0x4000_0000 - 0x7FFF_FFFF (bits [31:30] = 01)
 *   - Slave 2 (M02): 0x8000_0000 - 0xBFFF_FFFF (bits [31:30] = 10)
 *   - Slave 3 (M03): 0xC000_0000 - 0xFFFF_FFFF (bits [31:30] = 11)
 */

module alu_master_system #(
    // AXI Parameters
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    
    // Memory Parameters
    parameter MEM_SIZE = 256,  // 256 words = 1KB per slave
    
    // AXI Interconnect Parameters
    parameter Masters_Num = 2,
    parameter Slaves_ID_Size = 1,  // $clog2(Masters_Num)
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
    parameter SLAVE0_ADDR1 = 32'h0000_0000,  // bits [31:30] = 00
    parameter SLAVE0_ADDR2 = 32'h3FFF_FFFF,
    parameter SLAVE1_ADDR1 = 32'h4000_0000,  // bits [31:30] = 01
    parameter SLAVE1_ADDR2 = 32'h7FFF_FFFF,
    parameter SLAVE2_ADDR1 = 32'h8000_0000,  // bits [31:30] = 10
    parameter SLAVE2_ADDR2 = 32'hBFFF_FFFF,
    parameter SLAVE3_ADDR1 = 32'hC000_0000,  // bits [31:30] = 11
    parameter SLAVE3_ADDR2 = 32'hFFFF_FFFF
) (
    // Global signals
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ALU Master 0 Control
    input  wire                    master0_start,
    output wire                    master0_busy,
    output wire                    master0_done,
    
    // ALU Master 1 Control
    input  wire                    master1_start,
    output wire                    master1_busy,
    output wire                    master1_done
);

    // ========================================================================
    // Internal AXI Signals - Master 0 to Interconnect (S00)
    // ========================================================================
    wire [ADDR_WIDTH-1:0]          S00_AXI_awaddr;
    wire [7:0]                     S00_AXI_awlen;
    wire [2:0]                     S00_AXI_awsize;
    wire [1:0]                     S00_AXI_awburst;
    wire [1:0]                     S00_AXI_awlock;
    wire [3:0]                     S00_AXI_awcache;
    wire [2:0]                     S00_AXI_awprot;
    wire [3:0]                     S00_AXI_awregion;  // Not connected to interconnect
    wire [3:0]                     S00_AXI_awqos;
    wire                           S00_AXI_awvalid;
    wire                           S00_AXI_awready;
    wire [DATA_WIDTH-1:0]          S00_AXI_wdata;
    wire [3:0]                     S00_AXI_wstrb;
    wire                           S00_AXI_wlast;
    wire                           S00_AXI_wvalid;
    wire                           S00_AXI_wready;
    wire [1:0]                     S00_AXI_bresp;
    wire                           S00_AXI_bvalid;
    wire                           S00_AXI_bready;
    wire [ADDR_WIDTH-1:0]          S00_AXI_araddr;
    wire [7:0]                     S00_AXI_arlen;
    wire [2:0]                     S00_AXI_arsize;
    wire [1:0]                     S00_AXI_arburst;
    wire [1:0]                     S00_AXI_arlock;
    wire [3:0]                     S00_AXI_arcache;
    wire [2:0]                     S00_AXI_arprot;
    wire [3:0]                     S00_AXI_arregion;
    wire [3:0]                     S00_AXI_arqos;
    wire                           S00_AXI_arvalid;
    wire                           S00_AXI_arready;
    wire [DATA_WIDTH-1:0]          S00_AXI_rdata;
    wire [1:0]                     S00_AXI_rresp;
    wire                           S00_AXI_rlast;
    wire                           S00_AXI_rvalid;
    wire                           S00_AXI_rready;
    
    // ========================================================================
    // Internal AXI Signals - Master 1 to Interconnect (S01)
    // ========================================================================
    wire [ADDR_WIDTH-1:0]          S01_AXI_awaddr;
    wire [7:0]                     S01_AXI_awlen;
    wire [2:0]                     S01_AXI_awsize;
    wire [1:0]                     S01_AXI_awburst;
    wire [1:0]                     S01_AXI_awlock;
    wire [3:0]                     S01_AXI_awcache;
    wire [2:0]                     S01_AXI_awprot;
    wire [3:0]                     S01_AXI_awregion;  // Not connected to interconnect
    wire [3:0]                     S01_AXI_awqos;
    wire                           S01_AXI_awvalid;
    wire                           S01_AXI_awready;
    wire [DATA_WIDTH-1:0]          S01_AXI_wdata;
    wire [3:0]                     S01_AXI_wstrb;
    wire                           S01_AXI_wlast;
    wire                           S01_AXI_wvalid;
    wire                           S01_AXI_wready;
    wire [1:0]                     S01_AXI_bresp;
    wire                           S01_AXI_bvalid;
    wire                           S01_AXI_bready;
    wire [ADDR_WIDTH-1:0]          S01_AXI_araddr;
    wire [7:0]                     S01_AXI_arlen;
    wire [2:0]                     S01_AXI_arsize;
    wire [1:0]                     S01_AXI_arburst;
    wire [1:0]                     S01_AXI_arlock;
    wire [3:0]                     S01_AXI_arcache;
    wire [2:0]                     S01_AXI_arprot;
    wire [3:0]                     S01_AXI_arregion;
    wire [3:0]                     S01_AXI_arqos;
    wire                           S01_AXI_arvalid;
    wire                           S01_AXI_arready;
    wire [DATA_WIDTH-1:0]          S01_AXI_rdata;
    wire [1:0]                     S01_AXI_rresp;
    wire                           S01_AXI_rlast;
    wire                           S01_AXI_rvalid;
    wire                           S01_AXI_rready;
    
    // ========================================================================
    // Internal AXI Signals - Interconnect to Slave 0 (M00)
    // ========================================================================
    wire [Slaves_ID_Size-1:0]      M00_AXI_awaddr_ID;
    wire [ADDR_WIDTH-1:0]          M00_AXI_awaddr;
    wire [7:0]                     M00_AXI_awlen;
    wire [2:0]                     M00_AXI_awsize;
    wire [1:0]                     M00_AXI_awburst;
    wire [1:0]                     M00_AXI_awlock;
    wire [3:0]                     M00_AXI_awcache;
    wire [2:0]                     M00_AXI_awprot;
    wire [3:0]                     M00_AXI_awqos;
    wire                           M00_AXI_awvalid;
    wire                           M00_AXI_awready;
    wire [DATA_WIDTH-1:0]          M00_AXI_wdata;
    wire [3:0]                     M00_AXI_wstrb;
    wire                           M00_AXI_wlast;
    wire                           M00_AXI_wvalid;
    wire                           M00_AXI_wready;
    wire [Master_ID_Width-1:0]     M00_AXI_BID;
    wire [1:0]                     M00_AXI_bresp;
    wire                           M00_AXI_bvalid;
    wire                           M00_AXI_bready;
    wire [ADDR_WIDTH-1:0]          M00_AXI_araddr;
    wire [7:0]                     M00_AXI_arlen;
    wire [2:0]                     M00_AXI_arsize;
    wire [1:0]                     M00_AXI_arburst;
    wire [1:0]                     M00_AXI_arlock;
    wire [3:0]                     M00_AXI_arcache;
    wire [2:0]                     M00_AXI_arprot;
    wire [3:0]                     M00_AXI_arregion;
    wire [3:0]                     M00_AXI_arqos;
    wire                           M00_AXI_arvalid;
    wire                           M00_AXI_arready;
    wire [DATA_WIDTH-1:0]          M00_AXI_rdata;
    wire [1:0]                     M00_AXI_rresp;
    wire                           M00_AXI_rlast;
    wire                           M00_AXI_rvalid;
    wire                           M00_AXI_rready;
    
    // ========================================================================
    // Internal AXI Signals - Interconnect to Slave 1 (M01)
    // ========================================================================
    wire [Slaves_ID_Size-1:0]      M01_AXI_awaddr_ID;
    wire [ADDR_WIDTH-1:0]          M01_AXI_awaddr;
    wire [7:0]                     M01_AXI_awlen;
    wire [2:0]                     M01_AXI_awsize;
    wire [1:0]                     M01_AXI_awburst;
    wire [1:0]                     M01_AXI_awlock;
    wire [3:0]                     M01_AXI_awcache;
    wire [2:0]                     M01_AXI_awprot;
    wire [3:0]                     M01_AXI_awqos;
    wire                           M01_AXI_awvalid;
    wire                           M01_AXI_awready;
    wire [DATA_WIDTH-1:0]          M01_AXI_wdata;
    wire [3:0]                     M01_AXI_wstrb;
    wire                           M01_AXI_wlast;
    wire                           M01_AXI_wvalid;
    wire                           M01_AXI_wready;
    wire [Master_ID_Width-1:0]     M01_AXI_BID;
    wire [1:0]                     M01_AXI_bresp;
    wire                           M01_AXI_bvalid;
    wire                           M01_AXI_bready;
    wire [ADDR_WIDTH-1:0]          M01_AXI_araddr;
    wire [7:0]                     M01_AXI_arlen;
    wire [2:0]                     M01_AXI_arsize;
    wire [1:0]                     M01_AXI_arburst;
    wire [1:0]                     M01_AXI_arlock;
    wire [3:0]                     M01_AXI_arcache;
    wire [2:0]                     M01_AXI_arprot;
    wire [3:0]                     M01_AXI_arregion;
    wire [3:0]                     M01_AXI_arqos;
    wire                           M01_AXI_arvalid;
    wire                           M01_AXI_arready;
    wire [DATA_WIDTH-1:0]          M01_AXI_rdata;
    wire [1:0]                     M01_AXI_rresp;
    wire                           M01_AXI_rlast;
    wire                           M01_AXI_rvalid;
    wire                           M01_AXI_rready;
    
    // ========================================================================
    // Internal AXI Signals - Interconnect to Slave 2 (M02)
    // ========================================================================
    wire [ADDR_WIDTH-1:0]          M02_AXI_araddr;
    wire [7:0]                     M02_AXI_arlen;
    wire [2:0]                     M02_AXI_arsize;
    wire [1:0]                     M02_AXI_arburst;
    wire [1:0]                     M02_AXI_arlock;
    wire [3:0]                     M02_AXI_arcache;
    wire [2:0]                     M02_AXI_arprot;
    wire [3:0]                     M02_AXI_arregion;
    wire [3:0]                     M02_AXI_arqos;
    wire                           M02_AXI_arvalid;
    wire                           M02_AXI_arready;
    wire [DATA_WIDTH-1:0]          M02_AXI_rdata;
    wire [1:0]                     M02_AXI_rresp;
    wire                           M02_AXI_rlast;
    wire                           M02_AXI_rvalid;
    wire                           M02_AXI_rready;
    
    // ========================================================================
    // Internal AXI Signals - Interconnect to Slave 3 (M03)
    // ========================================================================
    wire [ADDR_WIDTH-1:0]          M03_AXI_araddr;
    wire [7:0]                     M03_AXI_arlen;
    wire [2:0]                     M03_AXI_arsize;
    wire [1:0]                     M03_AXI_arburst;
    wire [1:0]                     M03_AXI_arlock;
    wire [3:0]                     M03_AXI_arcache;
    wire [2:0]                     M03_AXI_arprot;
    wire [3:0]                     M03_AXI_arregion;
    wire [3:0]                     M03_AXI_arqos;
    wire                           M03_AXI_arvalid;
    wire                           M03_AXI_arready;
    wire [DATA_WIDTH-1:0]          M03_AXI_rdata;
    wire [1:0]                     M03_AXI_rresp;
    wire                           M03_AXI_rlast;
    wire                           M03_AXI_rvalid;
    wire                           M03_AXI_rready;
    
    // ========================================================================
    // ALU Master 0 Instantiation
    // ========================================================================
    CPU_ALU_Master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_master0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(master0_start),
        .busy(master0_busy),
        .done(master0_done),
        // Write Address Channel
        .M_AXI_awaddr(S00_AXI_awaddr),
        .M_AXI_awlen(S00_AXI_awlen),
        .M_AXI_awsize(S00_AXI_awsize),
        .M_AXI_awburst(S00_AXI_awburst),
        .M_AXI_awlock(S00_AXI_awlock),
        .M_AXI_awcache(S00_AXI_awcache),
        .M_AXI_awprot(S00_AXI_awprot),
        .M_AXI_awregion(S00_AXI_awregion),
        .M_AXI_awqos(S00_AXI_awqos),
        .M_AXI_awvalid(S00_AXI_awvalid),
        .M_AXI_awready(S00_AXI_awready),
        // Write Data Channel
        .M_AXI_wdata(S00_AXI_wdata),
        .M_AXI_wstrb(S00_AXI_wstrb),
        .M_AXI_wlast(S00_AXI_wlast),
        .M_AXI_wvalid(S00_AXI_wvalid),
        .M_AXI_wready(S00_AXI_wready),
        // Write Response Channel
        .M_AXI_bresp(S00_AXI_bresp),
        .M_AXI_bvalid(S00_AXI_bvalid),
        .M_AXI_bready(S00_AXI_bready),
        // Read Address Channel
        .M_AXI_araddr(S00_AXI_araddr),
        .M_AXI_arlen(S00_AXI_arlen),
        .M_AXI_arsize(S00_AXI_arsize),
        .M_AXI_arburst(S00_AXI_arburst),
        .M_AXI_arlock(S00_AXI_arlock),
        .M_AXI_arcache(S00_AXI_arcache),
        .M_AXI_arprot(S00_AXI_arprot),
        .M_AXI_arregion(S00_AXI_arregion),
        .M_AXI_arqos(S00_AXI_arqos),
        .M_AXI_arvalid(S00_AXI_arvalid),
        .M_AXI_arready(S00_AXI_arready),
        // Read Data Channel
        .M_AXI_rdata(S00_AXI_rdata),
        .M_AXI_rresp(S00_AXI_rresp),
        .M_AXI_rlast(S00_AXI_rlast),
        .M_AXI_rvalid(S00_AXI_rvalid),
        .M_AXI_rready(S00_AXI_rready)
    );
    
    // ========================================================================
    // ALU Master 1 Instantiation
    // ========================================================================
    CPU_ALU_Master #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_master1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(master1_start),
        .busy(master1_busy),
        .done(master1_done),
        // Write Address Channel
        .M_AXI_awaddr(S01_AXI_awaddr),
        .M_AXI_awlen(S01_AXI_awlen),
        .M_AXI_awsize(S01_AXI_awsize),
        .M_AXI_awburst(S01_AXI_awburst),
        .M_AXI_awlock(S01_AXI_awlock),
        .M_AXI_awcache(S01_AXI_awcache),
        .M_AXI_awprot(S01_AXI_awprot),
        .M_AXI_awregion(S01_AXI_awregion),
        .M_AXI_awqos(S01_AXI_awqos),
        .M_AXI_awvalid(S01_AXI_awvalid),
        .M_AXI_awready(S01_AXI_awready),
        // Write Data Channel
        .M_AXI_wdata(S01_AXI_wdata),
        .M_AXI_wstrb(S01_AXI_wstrb),
        .M_AXI_wlast(S01_AXI_wlast),
        .M_AXI_wvalid(S01_AXI_wvalid),
        .M_AXI_wready(S01_AXI_wready),
        // Write Response Channel
        .M_AXI_bresp(S01_AXI_bresp),
        .M_AXI_bvalid(S01_AXI_bvalid),
        .M_AXI_bready(S01_AXI_bready),
        // Read Address Channel
        .M_AXI_araddr(S01_AXI_araddr),
        .M_AXI_arlen(S01_AXI_arlen),
        .M_AXI_arsize(S01_AXI_arsize),
        .M_AXI_arburst(S01_AXI_arburst),
        .M_AXI_arlock(S01_AXI_arlock),
        .M_AXI_arcache(S01_AXI_arcache),
        .M_AXI_arprot(S01_AXI_arprot),
        .M_AXI_arregion(S01_AXI_arregion),
        .M_AXI_arqos(S01_AXI_arqos),
        .M_AXI_arvalid(S01_AXI_arvalid),
        .M_AXI_arready(S01_AXI_arready),
        // Read Data Channel
        .M_AXI_rdata(S01_AXI_rdata),
        .M_AXI_rresp(S01_AXI_rresp),
        .M_AXI_rlast(S01_AXI_rlast),
        .M_AXI_rvalid(S01_AXI_rvalid),
        .M_AXI_rready(S01_AXI_rready)
    );
    
    // ========================================================================
    // AXI Interconnect Instantiation
    // ========================================================================
    AXI_Interconnect_Full #(
        .Masters_Num(Masters_Num),
        .Slaves_ID_Size(Slaves_ID_Size),
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
    ) u_interconnect (
        // Global signals
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0 (S00) - ALU Master 0
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S00_AXI_awaddr(S00_AXI_awaddr),
        .S00_AXI_awlen(S00_AXI_awlen),
        .S00_AXI_awsize(S00_AXI_awsize),
        .S00_AXI_awburst(S00_AXI_awburst),
        .S00_AXI_awlock(S00_AXI_awlock),
        .S00_AXI_awcache(S00_AXI_awcache),
        .S00_AXI_awprot(S00_AXI_awprot),
        .S00_AXI_awqos(S00_AXI_awqos),
        .S00_AXI_awvalid(S00_AXI_awvalid),
        .S00_AXI_awready(S00_AXI_awready),
        .S00_AXI_wdata(S00_AXI_wdata),
        .S00_AXI_wstrb(S00_AXI_wstrb),
        .S00_AXI_wlast(S00_AXI_wlast),
        .S00_AXI_wvalid(S00_AXI_wvalid),
        .S00_AXI_wready(S00_AXI_wready),
        .S00_AXI_bresp(S00_AXI_bresp),
        .S00_AXI_bvalid(S00_AXI_bvalid),
        .S00_AXI_bready(S00_AXI_bready),
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
        
        // Master 1 (S01) - ALU Master 1
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
        .S01_AXI_arregion(S01_AXI_arregion),
        .S01_AXI_arqos(S01_AXI_arqos),
        .S01_AXI_arvalid(S01_AXI_arvalid),
        .S01_AXI_arready(S01_AXI_arready),
        .S01_AXI_rdata(S01_AXI_rdata),
        .S01_AXI_rresp(S01_AXI_rresp),
        .S01_AXI_rlast(S01_AXI_rlast),
        .S01_AXI_rvalid(S01_AXI_rvalid),
        .S01_AXI_rready(S01_AXI_rready),
        
        // Slave 0 (M00) - Memory Slave 0
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        .M00_AXI_awaddr_ID(M00_AXI_awaddr_ID),
        .M00_AXI_awaddr(M00_AXI_awaddr),
        .M00_AXI_awlen(M00_AXI_awlen),
        .M00_AXI_awsize(M00_AXI_awsize),
        .M00_AXI_awburst(M00_AXI_awburst),
        .M00_AXI_awlock(M00_AXI_awlock),
        .M00_AXI_awcache(M00_AXI_awcache),
        .M00_AXI_awprot(M00_AXI_awprot),
        .M00_AXI_awqos(M00_AXI_awqos),
        .M00_AXI_awvalid(M00_AXI_awvalid),
        .M00_AXI_awready(M00_AXI_awready),
        .M00_AXI_wdata(M00_AXI_wdata),
        .M00_AXI_wstrb(M00_AXI_wstrb),
        .M00_AXI_wlast(M00_AXI_wlast),
        .M00_AXI_wvalid(M00_AXI_wvalid),
        .M00_AXI_wready(M00_AXI_wready),
        .M00_AXI_BID(M00_AXI_BID),
        .M00_AXI_bresp(M00_AXI_bresp),
        .M00_AXI_bvalid(M00_AXI_bvalid),
        .M00_AXI_bready(M00_AXI_bready),
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
        
        // Slave 1 (M01) - Memory Slave 1
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        .M01_AXI_awaddr_ID(M01_AXI_awaddr_ID),
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
        .M01_AXI_BID(M01_AXI_BID),
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
        
        // Slave 2 (M02) - Memory Slave 2 (Read-only based on interconnect)
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        .M02_AXI_araddr(M02_AXI_araddr),
        .M02_AXI_arlen(M02_AXI_arlen),
        .M02_AXI_arsize(M02_AXI_arsize),
        .M02_AXI_arburst(M02_AXI_arburst),
        .M02_AXI_arlock(M02_AXI_arlock),
        .M02_AXI_arcache(M02_AXI_arcache),
        .M02_AXI_arprot(M02_AXI_arprot),
        .M02_AXI_arregion(M02_AXI_arregion),
        .M02_AXI_arqos(M02_AXI_arqos),
        .M02_AXI_arvalid(M02_AXI_arvalid),
        .M02_AXI_arready(M02_AXI_arready),
        .M02_AXI_rdata(M02_AXI_rdata),
        .M02_AXI_rresp(M02_AXI_rresp),
        .M02_AXI_rlast(M02_AXI_rlast),
        .M02_AXI_rvalid(M02_AXI_rvalid),
        .M02_AXI_rready(M02_AXI_rready),
        
        // Slave 3 (M03) - Memory Slave 3 (Read-only based on interconnect)
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
    
    // ========================================================================
    // Slave Memory 0 Instantiation (M00)
    // ========================================================================
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(Master_ID_Width),
        .MEM_SIZE(MEM_SIZE)
    ) u_slave0 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        // Write Address Channel
        .S_AXI_awid(M00_AXI_awaddr_ID),  // Master ID from interconnect
        .S_AXI_awaddr(M00_AXI_awaddr),
        .S_AXI_awlen(M00_AXI_awlen),
        .S_AXI_awsize(M00_AXI_awsize),
        .S_AXI_awburst(M00_AXI_awburst),
        .S_AXI_awlock(M00_AXI_awlock),
        .S_AXI_awcache(M00_AXI_awcache),
        .S_AXI_awprot(M00_AXI_awprot),
        .S_AXI_awregion(4'h0),
        .S_AXI_awqos(M00_AXI_awqos),
        .S_AXI_awvalid(M00_AXI_awvalid),
        .S_AXI_awready(M00_AXI_awready),
        // Write Data Channel
        .S_AXI_wdata(M00_AXI_wdata),
        .S_AXI_wstrb(M00_AXI_wstrb),
        .S_AXI_wlast(M00_AXI_wlast),
        .S_AXI_wvalid(M00_AXI_wvalid),
        .S_AXI_wready(M00_AXI_wready),
        // Write Response Channel
        .S_AXI_bid(M00_AXI_BID),  // Echo back Master ID to interconnect
        .S_AXI_bresp(M00_AXI_bresp),
        .S_AXI_bvalid(M00_AXI_bvalid),
        .S_AXI_bready(M00_AXI_bready),
        // Read Address Channel
        .S_AXI_araddr(M00_AXI_araddr),
        .S_AXI_arlen(M00_AXI_arlen),
        .S_AXI_arsize(M00_AXI_arsize),
        .S_AXI_arburst(M00_AXI_arburst),
        .S_AXI_arlock(M00_AXI_arlock),
        .S_AXI_arcache(M00_AXI_arcache),
        .S_AXI_arprot(M00_AXI_arprot),
        .S_AXI_arregion(M00_AXI_arregion),
        .S_AXI_arqos(M00_AXI_arqos),
        .S_AXI_arvalid(M00_AXI_arvalid),
        .S_AXI_arready(M00_AXI_arready),
        // Read Data Channel
        .S_AXI_rdata(M00_AXI_rdata),
        .S_AXI_rresp(M00_AXI_rresp),
        .S_AXI_rlast(M00_AXI_rlast),
        .S_AXI_rvalid(M00_AXI_rvalid),
        .S_AXI_rready(M00_AXI_rready)
    );
    
    // ========================================================================
    // Slave Memory 1 Instantiation (M01)
    // ========================================================================
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(Master_ID_Width),
        .MEM_SIZE(MEM_SIZE)
    ) u_slave1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        // Write Address Channel
        .S_AXI_awid(M01_AXI_awaddr_ID),  // Master ID from interconnect
        .S_AXI_awaddr(M01_AXI_awaddr),
        .S_AXI_awlen(M01_AXI_awlen),
        .S_AXI_awsize(M01_AXI_awsize),
        .S_AXI_awburst(M01_AXI_awburst),
        .S_AXI_awlock(M01_AXI_awlock),
        .S_AXI_awcache(M01_AXI_awcache),
        .S_AXI_awprot(M01_AXI_awprot),
        .S_AXI_awregion(4'h0),
        .S_AXI_awqos(M01_AXI_awqos),
        .S_AXI_awvalid(M01_AXI_awvalid),
        .S_AXI_awready(M01_AXI_awready),
        // Write Data Channel
        .S_AXI_wdata(M01_AXI_wdata),
        .S_AXI_wstrb(M01_AXI_wstrb),
        .S_AXI_wlast(M01_AXI_wlast),
        .S_AXI_wvalid(M01_AXI_wvalid),
        .S_AXI_wready(M01_AXI_wready),
        // Write Response Channel
        .S_AXI_bid(M01_AXI_BID),  // Echo back Master ID to interconnect
        .S_AXI_bresp(M01_AXI_bresp),
        .S_AXI_bvalid(M01_AXI_bvalid),
        .S_AXI_bready(M01_AXI_bready),
        // Read Address Channel
        .S_AXI_araddr(M01_AXI_araddr),
        .S_AXI_arlen(M01_AXI_arlen),
        .S_AXI_arsize(M01_AXI_arsize),
        .S_AXI_arburst(M01_AXI_arburst),
        .S_AXI_arlock(M01_AXI_arlock),
        .S_AXI_arcache(M01_AXI_arcache),
        .S_AXI_arprot(M01_AXI_arprot),
        .S_AXI_arregion(M01_AXI_arregion),
        .S_AXI_arqos(M01_AXI_arqos),
        .S_AXI_arvalid(M01_AXI_arvalid),
        .S_AXI_arready(M01_AXI_arready),
        // Read Data Channel
        .S_AXI_rdata(M01_AXI_rdata),
        .S_AXI_rresp(M01_AXI_rresp),
        .S_AXI_rlast(M01_AXI_rlast),
        .S_AXI_rvalid(M01_AXI_rvalid),
        .S_AXI_rready(M01_AXI_rready)
    );
    
    // ========================================================================
    // Slave Memory 2 Instantiation (M02)
    // Note: M02 and M03 may only support read in interconnect, but we connect
    // write channels anyway in case they are supported
    // ========================================================================
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) u_slave2 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        // Write Address Channel - Connect to ground if not supported
        .S_AXI_awaddr(32'h0),
        .S_AXI_awlen(8'h0),
        .S_AXI_awsize(3'h0),
        .S_AXI_awburst(2'h0),
        .S_AXI_awlock(2'h0),
        .S_AXI_awcache(4'h0),
        .S_AXI_awprot(3'h0),
        .S_AXI_awregion(4'h0),
        .S_AXI_awqos(4'h0),
        .S_AXI_awvalid(1'b0),
        .S_AXI_awready(),
        // Write Data Channel - Connect to ground if not supported
        .S_AXI_wdata(32'h0),
        .S_AXI_wstrb(4'h0),
        .S_AXI_wlast(1'b0),
        .S_AXI_wvalid(1'b0),
        .S_AXI_wready(),
        // Write Response Channel - Connect to ground if not supported
        .S_AXI_bresp(),
        .S_AXI_bvalid(),
        .S_AXI_bready(1'b0),
        // Read Address Channel
        .S_AXI_araddr(M02_AXI_araddr),
        .S_AXI_arlen(M02_AXI_arlen),
        .S_AXI_arsize(M02_AXI_arsize),
        .S_AXI_arburst(M02_AXI_arburst),
        .S_AXI_arlock(M02_AXI_arlock),
        .S_AXI_arcache(M02_AXI_arcache),
        .S_AXI_arprot(M02_AXI_arprot),
        .S_AXI_arregion(M02_AXI_arregion),
        .S_AXI_arqos(M02_AXI_arqos),
        .S_AXI_arvalid(M02_AXI_arvalid),
        .S_AXI_arready(M02_AXI_arready),
        // Read Data Channel
        .S_AXI_rdata(M02_AXI_rdata),
        .S_AXI_rresp(M02_AXI_rresp),
        .S_AXI_rlast(M02_AXI_rlast),
        .S_AXI_rvalid(M02_AXI_rvalid),
        .S_AXI_rready(M02_AXI_rready)
    );
    
    // ========================================================================
    // Slave Memory 3 Instantiation (M03)
    // ========================================================================
    Simple_Memory_Slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_SIZE(MEM_SIZE)
    ) u_slave3 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        // Write Address Channel - Connect to ground if not supported
        .S_AXI_awaddr(32'h0),
        .S_AXI_awlen(8'h0),
        .S_AXI_awsize(3'h0),
        .S_AXI_awburst(2'h0),
        .S_AXI_awlock(2'h0),
        .S_AXI_awcache(4'h0),
        .S_AXI_awprot(3'h0),
        .S_AXI_awregion(4'h0),
        .S_AXI_awqos(4'h0),
        .S_AXI_awvalid(1'b0),
        .S_AXI_awready(),
        // Write Data Channel - Connect to ground if not supported
        .S_AXI_wdata(32'h0),
        .S_AXI_wstrb(4'h0),
        .S_AXI_wlast(1'b0),
        .S_AXI_wvalid(1'b0),
        .S_AXI_wready(),
        // Write Response Channel - Connect to ground if not supported
        .S_AXI_bresp(),
        .S_AXI_bvalid(),
        .S_AXI_bready(1'b0),
        // Read Address Channel
        .S_AXI_araddr(M03_AXI_araddr),
        .S_AXI_arlen(M03_AXI_arlen),
        .S_AXI_arsize(M03_AXI_arsize),
        .S_AXI_arburst(M03_AXI_arburst),
        .S_AXI_arlock(M03_AXI_arlock),
        .S_AXI_arcache(M03_AXI_arcache),
        .S_AXI_arprot(M03_AXI_arprot),
        .S_AXI_arregion(M03_AXI_arregion),
        .S_AXI_arqos(M03_AXI_arqos),
        .S_AXI_arvalid(M03_AXI_arvalid),
        .S_AXI_arready(M03_AXI_arready),
        // Read Data Channel
        .S_AXI_rdata(M03_AXI_rdata),
        .S_AXI_rresp(M03_AXI_rresp),
        .S_AXI_rlast(M03_AXI_rlast),
        .S_AXI_rvalid(M03_AXI_rvalid),
        .S_AXI_rready(M03_AXI_rready)
    );

endmodule

