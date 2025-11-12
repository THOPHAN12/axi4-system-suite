/*
 * serv_axi_system_ip.v : Complete SERV RISC-V System IP
 * 
 * Complete IP module integrating:
 * - SERV RISC-V Core
 * - AXI Interconnect
 * - Instruction Memory (ROM)
 * - Data Memory (RAM)
 * 
 * Architecture:
 * 
 *     [SERV RISC-V Core]
 *            |
 *     [serv_axi_wrapper]
 *            |
 *       +----+----+
 *       |         |
 *   [M0_AXI]  [M1_AXI]
 *   (Inst)     (Data)
 *       |         |
 *       +----+----+
 *            |
 *   [AXI Interconnect]
 *            |
 *       +----+----+
 *       |         |
 *   [ROM Slave] [RAM Slave]
 *   (Inst Mem)  (Data Mem)
 */

module serv_axi_system_ip #(
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
    
    // AXI Interconnect Parameters
    parameter Num_Of_Slaves = 2,
    parameter S00_Aw_len = 8,
    parameter S00_Write_data_bus_width = 32,
    parameter S00_AR_len = 8,
    parameter S00_Read_data_bus_width = 32,
    parameter S01_Aw_len = 8,
    parameter S01_Write_data_bus_width = 32,
    parameter S01_AR_len = 8,
    parameter M00_Aw_len = 8,
    parameter M00_Write_data_bus_width = 32,
    parameter M00_AR_len = 8,
    parameter M00_Read_data_bus_width = 32,
    parameter M01_Aw_len = 8,
    parameter M01_AR_len = 8,
    parameter Is_Master_AXI_4 = 1'b1,
    parameter Num_Of_Masters = 2,
    parameter Master_ID_Width = 1,
    parameter AXI4_AR_len = 8,
    
    // Address Mapping
    parameter SLAVE0_ADDR1 = 32'h0000_0000,  // Instruction memory start
    parameter SLAVE0_ADDR2 = 32'h3FFF_FFFF,  // Instruction memory end
    parameter SLAVE1_ADDR1 = 32'h4000_0000,  // Data memory start
    parameter SLAVE1_ADDR2 = 32'h7FFF_FFFF,  // Data memory end
    
    // Memory Parameters
    // Note: Reduced default sizes for smaller devices. Increase if device has more resources.
    parameter INST_MEM_SIZE = 256,            // Instruction memory size (words) - default 256 for resource optimization
    parameter DATA_MEM_SIZE = 256,            // Data memory size (words) - default 256 for resource optimization
    parameter INST_MEM_INIT_FILE = "",        // Instruction memory init file (hex)
    parameter DATA_MEM_INIT_FILE = ""         // Data memory init file (hex)
) (
    // Global signals
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Timer interrupt (optional)
    input  wire                    i_timer_irq,
    
    // Optional: Memory access ports for external access (if needed)
    // These can be used for debugging or external memory access
    output wire                    inst_mem_ready,
    output wire                    data_mem_ready
);

    // ========================================================================
    // Internal AXI signals between Interconnect and Memory Slaves
    // ========================================================================
    
    // Slave 0 (Instruction Memory) AXI signals
    wire [ADDR_WIDTH-1:0]   M00_AXI_araddr;
    wire [7:0]              M00_AXI_arlen;
    wire [2:0]              M00_AXI_arsize;
    wire [1:0]              M00_AXI_arburst;
    wire [1:0]              M00_AXI_arlock;
    wire [3:0]              M00_AXI_arcache;
    wire [2:0]              M00_AXI_arprot;
    wire [3:0]              M00_AXI_arregion;
    wire [3:0]              M00_AXI_arqos;
    wire                    M00_AXI_arvalid;
    wire                    M00_AXI_arready;
    
    wire [DATA_WIDTH-1:0]   M00_AXI_rdata;
    wire [1:0]              M00_AXI_rresp;
    wire                    M00_AXI_rlast;
    wire                    M00_AXI_rvalid;
    wire                    M00_AXI_rready;
    
    // Slave 1 (Data Memory) AXI signals
    wire [ID_WIDTH-1:0]     M01_AXI_awid;
    wire [ADDR_WIDTH-1:0]   M01_AXI_awaddr;
    wire [7:0]              M01_AXI_awlen;
    wire [2:0]              M01_AXI_awsize;
    wire [1:0]              M01_AXI_awburst;
    wire [1:0]              M01_AXI_awlock;
    wire [3:0]              M01_AXI_awcache;
    wire [2:0]              M01_AXI_awprot;
    wire [3:0]              M01_AXI_awqos;
    wire [3:0]              M01_AXI_awregion;
    wire                    M01_AXI_awvalid;
    wire                    M01_AXI_awready;
    
    wire [DATA_WIDTH-1:0]   M01_AXI_wdata;
    wire [(DATA_WIDTH/8)-1:0] M01_AXI_wstrb;
    wire                    M01_AXI_wlast;
    wire                    M01_AXI_wvalid;
    wire                    M01_AXI_wready;
    
    wire [ID_WIDTH-1:0]     M01_AXI_bid;
    wire [1:0]              M01_AXI_bresp;
    wire                    M01_AXI_bvalid;
    wire                    M01_AXI_bready;
    
    wire [ID_WIDTH-1:0]     M01_AXI_arid;
    wire [ADDR_WIDTH-1:0]   M01_AXI_araddr;
    wire [7:0]              M01_AXI_arlen;
    wire [2:0]              M01_AXI_arsize;
    wire [1:0]              M01_AXI_arburst;
    wire [1:0]              M01_AXI_arlock;
    wire [3:0]              M01_AXI_arcache;
    wire [2:0]              M01_AXI_arprot;
    wire [3:0]              M01_AXI_arqos;
    wire [3:0]              M01_AXI_arregion;
    wire                    M01_AXI_arvalid;
    wire                    M01_AXI_arready;
    
    wire [ID_WIDTH-1:0]     M01_AXI_rid;
    wire [DATA_WIDTH-1:0]   M01_AXI_rdata;
    wire [1:0]              M01_AXI_rresp;
    wire                    M01_AXI_rlast;
    wire                    M01_AXI_rvalid;
    wire                    M01_AXI_rready;
    
    // Internal AXI signals from SERV wrapper
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
    
    // Tie-off wires
    wire M00_AXI_bready_tie = 1'b0;  // Read-only slave, tie off bready
    wire M02_AXI_rready_tie = 1'b0;  // Unused slave, tie off rready
    wire M03_AXI_rready_tie = 1'b0;  // Unused slave, tie off rready
    
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
        .M1_AXI_awregion (S01_AXI_awregion),
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
    // AXI Interconnect Instance
    // ========================================================================
    AXI_Interconnect_Full #(
        .Num_Of_Slaves              (Num_Of_Slaves),
        .S00_Aw_len                 (S00_Aw_len),
        .S00_Write_data_bus_width   (S00_Write_data_bus_width),
        .S00_AR_len                 (S00_AR_len),
        .S00_Read_data_bus_width    (S00_Read_data_bus_width),
        .S01_Aw_len                 (S01_Aw_len),
        .S01_Write_data_bus_width   (S01_Write_data_bus_width),
        .S01_AR_len                 (S01_AR_len),
        .M00_Aw_len                 (M00_Aw_len),
        .M00_Write_data_bus_width   (M00_Write_data_bus_width),
        .M00_AR_len                 (M00_AR_len),
        .M00_Read_data_bus_width    (M00_Read_data_bus_width),
        .M01_Aw_len                 (M01_Aw_len),
        .M01_AR_len                 (M01_AR_len),
        .Is_Master_AXI_4            (Is_Master_AXI_4),
        .Num_Of_Masters             (Num_Of_Masters),
        .Master_ID_Width            (Master_ID_Width),
        .AXI4_AR_len                (AXI4_AR_len)
    ) u_axi_interconnect (
        .ACLK                       (ACLK),
        .ARESETN                    (ARESETN),
        
        // Master 0 (Instruction Bus - Read-only)
        .S00_ACLK                   (ACLK),
        .S00_ARESETN                (ARESETN),
        .S00_AXI_awaddr             (32'h0),  // Read-only, tie off
        .S00_AXI_awlen              (8'h0),
        .S00_AXI_awsize             (3'h0),
        .S00_AXI_awburst            (2'h0),
        .S00_AXI_awlock             (2'h0),
        .S00_AXI_awcache            (4'h0),
        .S00_AXI_awprot             (3'h0),
        .S00_AXI_awqos              (4'h0),
        .S00_AXI_awvalid            (1'b0),
        .S00_AXI_awready            (),
        .S00_AXI_wdata              (32'h0),
        .S00_AXI_wstrb              (4'h0),
        .S00_AXI_wlast              (1'b0),
        .S00_AXI_wvalid             (1'b0),
        .S00_AXI_wready             (),
        .S00_AXI_bresp              (),
        .S00_AXI_bvalid             (),
        .S00_AXI_bready             (1'b0),
        .S00_AXI_araddr             (S00_AXI_araddr),
        .S00_AXI_arlen              (S00_AXI_arlen),
        .S00_AXI_arsize             (S00_AXI_arsize),
        .S00_AXI_arburst            (S00_AXI_arburst),
        .S00_AXI_arlock             (S00_AXI_arlock),
        .S00_AXI_arcache            (S00_AXI_arcache),
        .S00_AXI_arprot             (S00_AXI_arprot),
        .S00_AXI_arregion           (S00_AXI_arregion),
        .S00_AXI_arqos              (S00_AXI_arqos),
        .S00_AXI_arvalid            (S00_AXI_arvalid),
        .S00_AXI_arready            (S00_AXI_arready),
        .S00_AXI_rdata              (S00_AXI_rdata),
        .S00_AXI_rresp              (S00_AXI_rresp),
        .S00_AXI_rlast              (S00_AXI_rlast),
        .S00_AXI_rvalid             (S00_AXI_rvalid),
        .S00_AXI_rready             (S00_AXI_rready),
        
        // Master 1 (Data Bus - Read-write)
        .S01_ACLK                   (ACLK),
        .S01_ARESETN                (ARESETN),
        .S01_AXI_awaddr             (S01_AXI_awaddr),
        .S01_AXI_awlen              (S01_AXI_awlen),
        .S01_AXI_awsize             (S01_AXI_awsize),
        .S01_AXI_awburst            (S01_AXI_awburst),
        .S01_AXI_awlock             (S01_AXI_awlock),
        .S01_AXI_awcache            (S01_AXI_awcache),
        .S01_AXI_awprot             (S01_AXI_awprot),
        .S01_AXI_awqos              (S01_AXI_awqos),
        .S01_AXI_awvalid            (S01_AXI_awvalid),
        .S01_AXI_awready            (S01_AXI_awready),
        .S01_AXI_wdata              (S01_AXI_wdata),
        .S01_AXI_wstrb              (S01_AXI_wstrb),
        .S01_AXI_wlast              (S01_AXI_wlast),
        .S01_AXI_wvalid             (S01_AXI_wvalid),
        .S01_AXI_wready             (S01_AXI_wready),
        .S01_AXI_bresp              (S01_AXI_bresp),
        .S01_AXI_bvalid             (S01_AXI_bvalid),
        .S01_AXI_bready             (S01_AXI_bready),
        .S01_AXI_araddr             (S01_AXI_araddr),
        .S01_AXI_arlen              (S01_AXI_arlen),
        .S01_AXI_arsize             (S01_AXI_arsize),
        .S01_AXI_arburst            (S01_AXI_arburst),
        .S01_AXI_arlock             (S01_AXI_arlock),
        .S01_AXI_arcache            (S01_AXI_arcache),
        .S01_AXI_arprot             (S01_AXI_arprot),
        .S01_AXI_arregion           (S01_AXI_arregion),
        .S01_AXI_arqos              (S01_AXI_arqos),
        .S01_AXI_arvalid            (S01_AXI_arvalid),
        .S01_AXI_arready            (S01_AXI_arready),
        .S01_AXI_rdata              (S01_AXI_rdata),
        .S01_AXI_rresp              (S01_AXI_rresp),
        .S01_AXI_rlast              (S01_AXI_rlast),
        .S01_AXI_rvalid             (S01_AXI_rvalid),
        .S01_AXI_rready             (S01_AXI_rready),
        
        // Slave 0 (Instruction Memory - Read-only)
        .M00_ACLK                   (ACLK),
        .M00_ARESETN                (ARESETN),
        .M00_AXI_awaddr_ID          (),
        .M00_AXI_awaddr             (),
        .M00_AXI_awlen              (),
        .M00_AXI_awsize             (),
        .M00_AXI_awburst            (),
        .M00_AXI_awlock             (),
        .M00_AXI_awcache            (),
        .M00_AXI_awprot             (),
        .M00_AXI_awqos              (),
        .M00_AXI_awvalid            (),
        .M00_AXI_awready            (1'b1),  // Read-only, tie ready
        .M00_AXI_wdata              (),
        .M00_AXI_wstrb              (),
        .M00_AXI_wlast              (),
        .M00_AXI_wvalid             (),
        .M00_AXI_wready             (1'b1),  // Read-only, tie ready
        .M00_AXI_BID                (),
        .M00_AXI_bresp              (),
        .M00_AXI_bvalid             (),
        .M00_AXI_bready             (M00_AXI_bready_tie),  // Read-only, tie off
        .M00_AXI_araddr             (M00_AXI_araddr),
        .M00_AXI_arlen              (M00_AXI_arlen),
        .M00_AXI_arsize             (M00_AXI_arsize),
        .M00_AXI_arburst            (M00_AXI_arburst),
        .M00_AXI_arlock             (M00_AXI_arlock),
        .M00_AXI_arcache            (M00_AXI_arcache),
        .M00_AXI_arprot             (M00_AXI_arprot),
        .M00_AXI_arregion           (M00_AXI_arregion),
        .M00_AXI_arqos              (M00_AXI_arqos),
        .M00_AXI_arvalid            (M00_AXI_arvalid),
        .M00_AXI_arready            (M00_AXI_arready),
        .M00_AXI_rdata              (M00_AXI_rdata),
        .M00_AXI_rresp              (M00_AXI_rresp),
        .M00_AXI_rlast              (M00_AXI_rlast),
        .M00_AXI_rvalid             (M00_AXI_rvalid),
        .M00_AXI_rready             (M00_AXI_rready),
        
        // Slave 1 (Data Memory - Read-write)
        .M01_ACLK                   (ACLK),
        .M01_ARESETN                (ARESETN),
        .M01_AXI_awaddr_ID          (M01_AXI_awid[0]),  // Slice to 1 bit
        .M01_AXI_awaddr             (M01_AXI_awaddr),
        .M01_AXI_awlen              (M01_AXI_awlen),
        .M01_AXI_awsize             (M01_AXI_awsize),
        .M01_AXI_awburst            (M01_AXI_awburst),
        .M01_AXI_awlock             (M01_AXI_awlock),
        .M01_AXI_awcache            (M01_AXI_awcache),
        .M01_AXI_awprot             (M01_AXI_awprot),
        .M01_AXI_awqos              (M01_AXI_awqos),
        .M01_AXI_awvalid            (M01_AXI_awvalid),
        .M01_AXI_awready            (M01_AXI_awready),
        .M01_AXI_wdata              (M01_AXI_wdata),
        .M01_AXI_wstrb              (M01_AXI_wstrb),
        .M01_AXI_wlast              (M01_AXI_wlast),
        .M01_AXI_wvalid             (M01_AXI_wvalid),
        .M01_AXI_wready             (M01_AXI_wready),
        .M01_AXI_BID                (M01_AXI_bid[0]),  // Slice to 1 bit
        .M01_AXI_bresp              (M01_AXI_bresp),
        .M01_AXI_bvalid             (M01_AXI_bvalid),
        .M01_AXI_bready             (M01_AXI_bready),
        .M01_AXI_araddr             (M01_AXI_araddr),
        .M01_AXI_arlen              (M01_AXI_arlen),
        .M01_AXI_arsize             (M01_AXI_arsize),
        .M01_AXI_arburst            (M01_AXI_arburst),
        .M01_AXI_arlock             (M01_AXI_arlock),
        .M01_AXI_arcache            (M01_AXI_arcache),
        .M01_AXI_arprot             (M01_AXI_arprot),
        .M01_AXI_arregion           (M01_AXI_arregion),
        .M01_AXI_arqos              (M01_AXI_arqos),
        .M01_AXI_arvalid            (M01_AXI_arvalid),
        .M01_AXI_arready            (M01_AXI_arready),
        .M01_AXI_rdata              (M01_AXI_rdata),
        .M01_AXI_rresp              (M01_AXI_rresp),
        .M01_AXI_rlast              (M01_AXI_rlast),
        .M01_AXI_rvalid             (M01_AXI_rvalid),
        .M01_AXI_rready             (M01_AXI_rready),
        
        // Unused slaves (tie off)
        .M02_ACLK                   (ACLK),
        .M02_ARESETN                (ARESETN),
        .M02_AXI_araddr             (),
        .M02_AXI_arlen              (),
        .M02_AXI_arsize             (),
        .M02_AXI_arburst            (),
        .M02_AXI_arlock             (),
        .M02_AXI_arcache            (),
        .M02_AXI_arprot             (),
        .M02_AXI_arregion           (),
        .M02_AXI_arqos              (),
        .M02_AXI_arvalid            (),
        .M02_AXI_arready            (1'b1),
        .M02_AXI_rdata              (32'h0),
        .M02_AXI_rresp              (),
        .M02_AXI_rlast              (),
        .M02_AXI_rvalid             (1'b0),
        .M02_AXI_rready             (M02_AXI_rready_tie),
        
        .M03_ACLK                   (ACLK),
        .M03_ARESETN                (ARESETN),
        .M03_AXI_araddr             (),
        .M03_AXI_arlen              (),
        .M03_AXI_arsize             (),
        .M03_AXI_arburst            (),
        .M03_AXI_arlock             (),
        .M03_AXI_arcache            (),
        .M03_AXI_arprot             (),
        .M03_AXI_arregion           (),
        .M03_AXI_arqos              (),
        .M03_AXI_arvalid            (),
        .M03_AXI_arready            (1'b1),
        .M03_AXI_rdata              (32'h0),
        .M03_AXI_rresp              (),
        .M03_AXI_rlast              (),
        .M03_AXI_rvalid             (1'b0),
        .M03_AXI_rready             (M03_AXI_rready_tie),
        
        // Address Decoder Configuration
        .slave0_addr1               (SLAVE0_ADDR1),
        .slave0_addr2               (SLAVE0_ADDR2),
        .slave1_addr1               (SLAVE1_ADDR1),
        .slave1_addr2               (SLAVE1_ADDR2),
        .slave2_addr1               (32'h0),
        .slave2_addr2               (32'h0),
        .slave3_addr1               (32'h0),
        .slave3_addr2               (32'h0)
    );
    
    // ========================================================================
    // Instruction Memory (ROM) Slave Instance
    // ========================================================================
    axi_rom_slave #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DATA_WIDTH         (DATA_WIDTH),
        .ID_WIDTH           (ID_WIDTH),
        .MEM_SIZE           (INST_MEM_SIZE),
        .MEM_INIT_FILE      (INST_MEM_INIT_FILE)
    ) u_inst_mem (
        .ACLK               (ACLK),
        .ARESETN            (ARESETN),
        .S_AXI_arid         (4'h0),  // Not used for read-only
        .S_AXI_araddr       (M00_AXI_araddr),
        .S_AXI_arlen        (M00_AXI_arlen),
        .S_AXI_arsize       (M00_AXI_arsize),
        .S_AXI_arburst      (M00_AXI_arburst),
        .S_AXI_arlock       (M00_AXI_arlock),
        .S_AXI_arcache      (M00_AXI_arcache),
        .S_AXI_arprot       (M00_AXI_arprot),
        .S_AXI_arqos        (M00_AXI_arqos),
        .S_AXI_arregion     (M00_AXI_arregion),
        .S_AXI_arvalid      (M00_AXI_arvalid),
        .S_AXI_arready      (M00_AXI_arready),
        .S_AXI_rid          (),
        .S_AXI_rdata        (M00_AXI_rdata),
        .S_AXI_rresp        (M00_AXI_rresp),
        .S_AXI_rlast        (M00_AXI_rlast),
        .S_AXI_rvalid       (M00_AXI_rvalid),
        .S_AXI_rready       (M00_AXI_rready)
    );
    
    // ========================================================================
    // Data Memory (RAM) Slave Instance
    // ========================================================================
    axi_memory_slave #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DATA_WIDTH         (DATA_WIDTH),
        .ID_WIDTH           (ID_WIDTH),
        .MEM_SIZE           (DATA_MEM_SIZE),
        .MEM_INIT_FILE      (DATA_MEM_INIT_FILE)
    ) u_data_mem (
        .ACLK               (ACLK),
        .ARESETN            (ARESETN),
        .S_AXI_awid         (M01_AXI_awid),
        .S_AXI_awaddr       (M01_AXI_awaddr),
        .S_AXI_awlen        (M01_AXI_awlen),
        .S_AXI_awsize       (M01_AXI_awsize),
        .S_AXI_awburst      (M01_AXI_awburst),
        .S_AXI_awlock       (M01_AXI_awlock),
        .S_AXI_awcache      (M01_AXI_awcache),
        .S_AXI_awprot       (M01_AXI_awprot),
        .S_AXI_awqos        (M01_AXI_awqos),
        .S_AXI_awregion     (M01_AXI_awregion),
        .S_AXI_awvalid      (M01_AXI_awvalid),
        .S_AXI_awready      (M01_AXI_awready),
        .S_AXI_wdata        (M01_AXI_wdata),
        .S_AXI_wstrb        (M01_AXI_wstrb),
        .S_AXI_wlast        (M01_AXI_wlast),
        .S_AXI_wvalid       (M01_AXI_wvalid),
        .S_AXI_wready       (M01_AXI_wready),
        .S_AXI_bid          (M01_AXI_bid),
        .S_AXI_bresp        (M01_AXI_bresp),
        .S_AXI_bvalid       (M01_AXI_bvalid),
        .S_AXI_bready       (M01_AXI_bready),
        .S_AXI_arid         (M01_AXI_arid),
        .S_AXI_araddr       (M01_AXI_araddr),
        .S_AXI_arlen        (M01_AXI_arlen),
        .S_AXI_arsize       (M01_AXI_arsize),
        .S_AXI_arburst      (M01_AXI_arburst),
        .S_AXI_arlock       (M01_AXI_arlock),
        .S_AXI_arcache      (M01_AXI_arcache),
        .S_AXI_arprot       (M01_AXI_arprot),
        .S_AXI_arqos        (M01_AXI_arqos),
        .S_AXI_arregion     (M01_AXI_arregion),
        .S_AXI_arvalid      (M01_AXI_arvalid),
        .S_AXI_arready      (M01_AXI_arready),
        .S_AXI_rid          (M01_AXI_rid),
        .S_AXI_rdata        (M01_AXI_rdata),
        .S_AXI_rresp        (M01_AXI_rresp),
        .S_AXI_rlast        (M01_AXI_rlast),
        .S_AXI_rvalid       (M01_AXI_rvalid),
        .S_AXI_rready       (M01_AXI_rready)
    );
    
    // Status outputs (optional)
    assign inst_mem_ready = M00_AXI_arready;
    assign data_mem_ready = M01_AXI_awready | M01_AXI_arready;
    
endmodule

