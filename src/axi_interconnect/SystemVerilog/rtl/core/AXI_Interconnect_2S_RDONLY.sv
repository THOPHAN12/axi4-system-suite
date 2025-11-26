//=============================================================================
// AXI_Interconnect_2S_RDONLY.sv - SystemVerilog
// 2-Master, 2-Slave, Read-Only AXI Interconnect Wrapper
// Purpose: Reduce I/O count for FPGA synthesis on EP2C35F672C6
//=============================================================================

`timescale 1ns/1ps

module AXI_Interconnect_2S_RDONLY (
    // Global signals
    input  logic                          ACLK,
    input  logic                          ARESETN,
    
    // ========================================================================
    // Master 0 Interface - READ ONLY
    // ========================================================================
    input  logic [31:0]                  S00_AXI_araddr,
    input  logic [7:0]                   S00_AXI_arlen,
    input  logic [2:0]                   S00_AXI_arsize,
    input  logic [1:0]                   S00_AXI_arburst,
    input  logic [1:0]                   S00_AXI_arlock,
    input  logic [3:0]                   S00_AXI_arcache,
    input  logic [2:0]                   S00_AXI_arprot,
    input  logic [3:0]                   S00_AXI_arregion,
    input  logic [3:0]                   S00_AXI_arqos,
    input  logic                         S00_AXI_arvalid,
    output logic                         S00_AXI_arready,
    
    output logic [31:0]                  S00_AXI_rdata,
    output logic [1:0]                   S00_AXI_rresp,
    output logic                         S00_AXI_rlast,
    output logic                         S00_AXI_rvalid,
    input  logic                         S00_AXI_rready,
    
    // ========================================================================
    // Master 1 Interface - READ ONLY
    // ========================================================================
    input  logic [31:0]                  S01_AXI_araddr,
    input  logic [7:0]                   S01_AXI_arlen,
    input  logic [2:0]                   S01_AXI_arsize,
    input  logic [1:0]                   S01_AXI_arburst,
    input  logic [1:0]                   S01_AXI_arlock,
    input  logic [3:0]                   S01_AXI_arcache,
    input  logic [2:0]                   S01_AXI_arprot,
    input  logic [3:0]                   S01_AXI_arregion,
    input  logic [3:0]                   S01_AXI_arqos,
    input  logic                         S01_AXI_arvalid,
    output logic                         S01_AXI_arready,
    
    output logic [31:0]                  S01_AXI_rdata,
    output logic [1:0]                   S01_AXI_rresp,
    output logic                         S01_AXI_rlast,
    output logic                         S01_AXI_rvalid,
    input  logic                         S01_AXI_rready,
    
    // ========================================================================
    // Slave 0 Interface - READ ONLY
    // ========================================================================
    output logic [31:0]                  M00_AXI_araddr,
    output logic [7:0]                   M00_AXI_arlen,
    output logic [2:0]                   M00_AXI_arsize,
    output logic [1:0]                   M00_AXI_arburst,
    output logic [1:0]                   M00_AXI_arlock,
    output logic [3:0]                   M00_AXI_arcache,
    output logic [2:0]                   M00_AXI_arprot,
    output logic [3:0]                   M00_AXI_arregion,
    output logic [3:0]                   M00_AXI_arqos,
    output logic                         M00_AXI_arvalid,
    input  logic                         M00_AXI_arready,
    
    input  logic [31:0]                  M00_AXI_rdata,
    input  logic [1:0]                   M00_AXI_rresp,
    input  logic                         M00_AXI_rlast,
    input  logic                         M00_AXI_rvalid,
    output logic                         M00_AXI_rready,
    
    // ========================================================================
    // Slave 1 Interface - READ ONLY
    // ========================================================================
    output logic [31:0]                  M01_AXI_araddr,
    output logic [7:0]                   M01_AXI_arlen,
    output logic [2:0]                   M01_AXI_arsize,
    output logic [1:0]                   M01_AXI_arburst,
    output logic [1:0]                   M01_AXI_arlock,
    output logic [3:0]                   M01_AXI_arcache,
    output logic [2:0]                   M01_AXI_arprot,
    output logic [3:0]                   M01_AXI_arregion,
    output logic [3:0]                   M01_AXI_arqos,
    output logic                         M01_AXI_arvalid,
    input  logic                         M01_AXI_arready,
    
    input  logic [31:0]                  M01_AXI_rdata,
    input  logic [1:0]                   M01_AXI_rresp,
    input  logic                         M01_AXI_rlast,
    input  logic                         M01_AXI_rvalid,
    output logic                         M01_AXI_rready,
    
    // ========================================================================
    // Configuration
    // ========================================================================
    input  logic [31:0]                  slave0_addr1,
    input  logic [31:0]                  slave0_addr2,
    input  logic [31:0]                  slave1_addr1,
    input  logic [31:0]                  slave1_addr2
);

    // Tie Write channels to default values internally
    logic [31:0] tie_wdata   = 32'h0;
    logic [3:0]  tie_wstrb   = 4'h0;
    logic        tie_wlast   = 1'b0;
    logic        tie_wvalid  = 1'b0;
    logic        tie_bready  = 1'b0;
    logic [31:0] tie_awaddr  = 32'h0;
    logic [7:0]  tie_awlen   = 8'h0;
    logic [2:0]  tie_awsize  = 3'h0;
    logic [1:0]  tie_awburst = 2'h0;
    logic [1:0]  tie_awlock  = 2'h0;
    logic [3:0]  tie_awcache = 4'h0;
    logic [2:0]  tie_awprot  = 3'h0;
    logic [3:0]  tie_awqos   = 4'h0;
    logic        tie_awvalid = 1'b0;
    logic [3:0]  tie_awregion = 4'h0;
    // Additional tie-off signals for Write channels (used for M00 and M01)
    logic        tie_awready = 1'b1;
    logic        tie_wready  = 1'b1;
    logic [0:0]   tie_bid     = 1'b0;
    logic [1:0]   tie_bresp   = 2'b00;
    logic         tie_bvalid  = 1'b0;

    // Instantiate Full AXI Interconnect with Write channels tied off
    AXI_Interconnect_Full #(
        .Num_Of_Slaves(2),  // 2 Slaves only for I/O reduction
        .S00_Aw_len(8),
        .S00_Write_data_bus_width(32),
        .S00_AR_len(8),
        .S00_Read_data_bus_width(32),
        .S01_Aw_len(8),
        .S01_Write_data_bus_width(32),
        .S01_AR_len(8),
        .M00_Aw_len(8),
        .M00_Write_data_bus_width(32),
        .M00_AR_len(8),
        .M00_Read_data_bus_width(32),
        .M01_Aw_len(8),
        .M01_AR_len(8),
        .M01_Read_data_bus_width(32),
        .Is_Master_AXI_4(1),
        .Num_Of_Masters(2),
        .Master_ID_Width(1),
        .AXI4_AR_len(8)
    ) u_axi_interconnect (
        // Global
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // ================================================================
        // Master 0 (S00) - READ ONLY, Write channels tied off
        // ================================================================
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S00_AXI_awaddr(tie_awaddr),
        .S00_AXI_awlen(tie_awlen),
        .S00_AXI_awsize(tie_awsize),
        .S00_AXI_awburst(tie_awburst),
        .S00_AXI_awlock(tie_awlock),
        .S00_AXI_awcache(tie_awcache),
        .S00_AXI_awprot(tie_awprot),
        .S00_AXI_awqos(tie_awqos),
        .S00_AXI_awvalid(tie_awvalid),
        .S00_AXI_awready(),  // Unused
        .S00_AXI_wdata(tie_wdata),
        .S00_AXI_wstrb(tie_wstrb),
        .S00_AXI_wlast(tie_wlast),
        .S00_AXI_wvalid(tie_wvalid),
        .S00_AXI_wready(),   // Unused
        .S00_AXI_bresp(),    // Unused
        .S00_AXI_bvalid(),   // Unused
        .S00_AXI_bready(tie_bready),
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
        
        // ================================================================
        // Master 1 (S01) - READ ONLY, Write channels tied off
        // ================================================================
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        .S01_AXI_awaddr(tie_awaddr),
        .S01_AXI_awlen(tie_awlen),
        .S01_AXI_awsize(tie_awsize),
        .S01_AXI_awburst(tie_awburst),
        .S01_AXI_awlock(tie_awlock),
        .S01_AXI_awcache(tie_awcache),
        .S01_AXI_awprot(tie_awprot),
        .S01_AXI_awqos(tie_awqos),
        .S01_AXI_awvalid(tie_awvalid),
        .S01_AXI_awready(),  // Unused
        .S01_AXI_wdata(tie_wdata),
        .S01_AXI_wstrb(tie_wstrb),
        .S01_AXI_wlast(tie_wlast),
        .S01_AXI_wvalid(tie_wvalid),
        .S01_AXI_wready(),   // Unused
        .S01_AXI_bresp(),    // Unused
        .S01_AXI_bvalid(),   // Unused
        .S01_AXI_bready(tie_bready),
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
        
        // ================================================================
        // Slave 0 (M00) - READ ONLY, Write channels tied off
        // ================================================================
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        .M00_AXI_awaddr_ID(),   // Unused output
        .M00_AXI_awaddr(),      // Unused
        .M00_AXI_awlen(),       // Unused
        .M00_AXI_awsize(),      // Unused
        .M00_AXI_awburst(),     // Unused
        .M00_AXI_awlock(),      // Unused
        .M00_AXI_awcache(),     // Unused
        .M00_AXI_awprot(),      // Unused
        .M00_AXI_awqos(),       // Unused
        .M00_AXI_awvalid(),     // Unused
        .M00_AXI_awready(tie_awready),  // Tie to 1'b1
        .M00_AXI_wdata(),       // Unused
        .M00_AXI_wstrb(),       // Unused
        .M00_AXI_wlast(),       // Unused
        .M00_AXI_wvalid(),      // Unused
        .M00_AXI_wready(tie_wready),    // Tie to 1'b1
        .M00_AXI_BID(tie_bid),          // Tie to 1'b0
        .M00_AXI_bresp(tie_bresp),      // Tie to 2'b00
        .M00_AXI_bvalid(tie_bvalid),    // Tie to 1'b0
        .M00_AXI_bready(),      // Unused
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
        
        // ================================================================
        // Slave 1 (M01) - READ ONLY, Write channels tied off
        // ================================================================
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        .M01_AXI_awaddr_ID(),   // Unused output
        .M01_AXI_awaddr(),      // Unused
        .M01_AXI_awlen(),       // Unused
        .M01_AXI_awsize(),      // Unused
        .M01_AXI_awburst(),     // Unused
        .M01_AXI_awlock(),      // Unused
        .M01_AXI_awcache(),     // Unused
        .M01_AXI_awprot(),      // Unused
        .M01_AXI_awqos(),       // Unused
        .M01_AXI_awvalid(),     // Unused
        .M01_AXI_awready(tie_awready),
        .M01_AXI_wdata(),       // Unused
        .M01_AXI_wstrb(),       // Unused
        .M01_AXI_wlast(),       // Unused
        .M01_AXI_wvalid(),      // Unused
        .M01_AXI_wready(tie_wready),
        .M01_AXI_BID(tie_bid),
        .M01_AXI_bresp(tie_bresp),
        .M01_AXI_bvalid(tie_bvalid),
        .M01_AXI_bready(),      // Unused
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
        
        // ================================================================
        // Slave 2 & 3 - Not used (2-Slave only wrapper)
        // M02, M03 only have Read channels, no Write channels
        // ================================================================
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        .M02_AXI_araddr(32'h0),
        .M02_AXI_arlen(8'h0),
        .M02_AXI_arsize(3'h0),
        .M02_AXI_arburst(2'h0),
        .M02_AXI_arlock(2'h0),
        .M02_AXI_arcache(4'h0),
        .M02_AXI_arprot(3'h0),
        .M02_AXI_arregion(4'h0),
        .M02_AXI_arqos(4'h0),
        .M02_AXI_arvalid(1'b0),
        .M02_AXI_arready(),
        .M02_AXI_rdata(32'h0),
        .M02_AXI_rresp(2'h0),
        .M02_AXI_rlast(1'b0),
        .M02_AXI_rvalid(1'b0),
        .M02_AXI_rready(1'b0),
        
        .M03_ACLK(ACLK),
        .M03_ARESETN(ARESETN),
        .M03_AXI_araddr(32'h0),
        .M03_AXI_arlen(8'h0),
        .M03_AXI_arsize(3'h0),
        .M03_AXI_arburst(2'h0),
        .M03_AXI_arlock(2'h0),
        .M03_AXI_arcache(4'h0),
        .M03_AXI_arprot(3'h0),
        .M03_AXI_arregion(4'h0),
        .M03_AXI_arqos(4'h0),
        .M03_AXI_arvalid(1'b0),
        .M03_AXI_arready(),
        .M03_AXI_rdata(32'h0),
        .M03_AXI_rresp(2'h0),
        .M03_AXI_rlast(1'b0),
        .M03_AXI_rvalid(1'b0),
        .M03_AXI_rready(1'b0),
        
        // ================================================================
        // Configuration
        // ================================================================
        .slave0_addr1(slave0_addr1),
        .slave0_addr2(slave0_addr2),
        .slave1_addr1(slave1_addr1),
        .slave1_addr2(slave1_addr2),
        .slave2_addr1(32'h0),  // Not used
        .slave2_addr2(32'h0),
        .slave3_addr1(32'h0),
        .slave3_addr2(32'h0)
    );

endmodule

