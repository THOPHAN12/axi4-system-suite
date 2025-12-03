/*
 * serv_axi_wrapper.v : SERV RISC-V to AXI4 Wrapper
 * 
 * Top-level wrapper that connects SERV RISC-V processor to AXI4 Interconnect
 * - SERV Instruction Bus (read-only) -> AXI4 Master Port 0 (Read-only)
 * - SERV Data Bus (read-write) -> AXI4 Master Port 1 (Read-write)
 * 
 * Architecture:
 * 
 *     [SERV RISC-V Core]
 *            |
 *       +----+----+
 *       |         |
 *   [Instruction] [Data Bus]
 *   [Bus (RO)]    [RW]
 *       |         |
 *   [wb2axi_  ] [wb2axi_  ]
 *   [read]     [write]
 *       |         |
 *   [AXI Master] [AXI Master]
 *   [Port 0]     [Port 1]
 *       |         |
 *       +----+----+
 *            |
 *   [AXI Interconnect]
 * 
 */

module serv_axi_wrapper #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    
    // SERV Parameters
    parameter WITH_CSR = 1,
    parameter W = 1,
    parameter B = W-1,
    parameter PRE_REGISTER = 1,
    parameter RESET_STRATEGY = "MINI",
    parameter RESET_PC = 32'd0,
    parameter [0:0] DEBUG = 1'b0,
    parameter [0:0] MDU = 1'b0,
    parameter [0:0] COMPRESSED = 0,
    parameter [0:0] ALIGN = COMPRESSED
) (
    // Clock and Reset
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Timer interrupt (optional)
    input  wire                    i_timer_irq,
    
    // AXI4 Master Port 0 (Instruction Bus - Read-only)
    // Read Address Channel
    output wire [ID_WIDTH-1:0]     M0_AXI_arid,
    output wire [ADDR_WIDTH-1:0]   M0_AXI_araddr,
    output wire [7:0]              M0_AXI_arlen,
    output wire [2:0]              M0_AXI_arsize,
    output wire [1:0]              M0_AXI_arburst,
    output wire [1:0]              M0_AXI_arlock,
    output wire [3:0]              M0_AXI_arcache,
    output wire [2:0]              M0_AXI_arprot,
    output wire [3:0]              M0_AXI_arqos,
    output wire [3:0]              M0_AXI_arregion,
    output wire                    M0_AXI_arvalid,
    input  wire                    M0_AXI_arready,
    
    // Read Data Channel
    input  wire [ID_WIDTH-1:0]     M0_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M0_AXI_rdata,
    input  wire [1:0]              M0_AXI_rresp,
    input  wire                    M0_AXI_rlast,
    input  wire                    M0_AXI_rvalid,
    output wire                    M0_AXI_rready,
    
    // AXI4 Master Port 1 (Data Bus - Read-write)
    // Write Address Channel
    output wire [ID_WIDTH-1:0]     M1_AXI_awid,
    output wire [ADDR_WIDTH-1:0]   M1_AXI_awaddr,
    output wire [7:0]              M1_AXI_awlen,
    output wire [2:0]              M1_AXI_awsize,
    output wire [1:0]              M1_AXI_awburst,
    output wire [1:0]              M1_AXI_awlock,
    output wire [3:0]              M1_AXI_awcache,
    output wire [2:0]              M1_AXI_awprot,
    output wire [3:0]              M1_AXI_awqos,
    output wire [3:0]              M1_AXI_awregion,
    output wire                    M1_AXI_awvalid,
    input  wire                    M1_AXI_awready,
    
    // Write Data Channel
    output wire [DATA_WIDTH-1:0]   M1_AXI_wdata,
    output wire [(DATA_WIDTH/8)-1:0] M1_AXI_wstrb,
    output wire                    M1_AXI_wlast,
    output wire                    M1_AXI_wvalid,
    input  wire                    M1_AXI_wready,
    
    // Write Response Channel
    input  wire [ID_WIDTH-1:0]     M1_AXI_bid,
    input  wire [1:0]              M1_AXI_bresp,
    input  wire                    M1_AXI_bvalid,
    output wire                    M1_AXI_bready,
    
    // Read Address Channel
    output wire [ID_WIDTH-1:0]     M1_AXI_arid,
    output wire [ADDR_WIDTH-1:0]   M1_AXI_araddr,
    output wire [7:0]              M1_AXI_arlen,
    output wire [2:0]              M1_AXI_arsize,
    output wire [1:0]              M1_AXI_arburst,
    output wire [1:0]              M1_AXI_arlock,
    output wire [3:0]              M1_AXI_arcache,
    output wire [2:0]              M1_AXI_arprot,
    output wire [3:0]              M1_AXI_arqos,
    output wire [3:0]              M1_AXI_arregion,
    output wire                    M1_AXI_arvalid,
    input  wire                    M1_AXI_arready,
    
    // Read Data Channel
    input  wire [ID_WIDTH-1:0]     M1_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M1_AXI_rdata,
    input  wire [1:0]              M1_AXI_rresp,
    input  wire                    M1_AXI_rlast,
    input  wire                    M1_AXI_rvalid,
    output wire                    M1_AXI_rready
);

// Internal Wishbone signals for SERV
wire [31:0] wb_ibus_adr;
wire        wb_ibus_cyc;
wire [31:0] wb_ibus_rdt;
wire        wb_ibus_ack;

wire [31:0] wb_dbus_adr;
wire [31:0] wb_dbus_dat;
wire [3:0]  wb_dbus_sel;
wire        wb_dbus_we;
wire        wb_dbus_cyc;
wire [31:0] wb_dbus_rdt;
wire        wb_dbus_ack;

// Extension signals (MDU not implemented yet)
wire [2:0]  ext_funct3;
wire        ext_ready;
wire [31:0] ext_rd;
wire [31:0] ext_rs1;
wire [31:0] ext_rs2;

// MDU signals
wire        mdu_valid;

// Extension (MDU) - not implemented yet
assign ext_ready = 1'b0;
assign ext_rd = 32'h0;

// Counter done signal (for bit-serial mode address capture)
wire serv_cnt_done;

// SERV Core with Register File Instance
// Using serv_rf_top which includes RF implementation
serv_rf_top #(
    .WITH_CSR        (WITH_CSR),
    .W               (W),
    .PRE_REGISTER    (PRE_REGISTER),
    .RESET_STRATEGY  (RESET_STRATEGY),
    .RESET_PC        (RESET_PC),
    .DEBUG           (DEBUG),
    .MDU             (MDU),
    .COMPRESSED      (COMPRESSED),
    .ALIGN           (ALIGN)
) u_serv_core (
    .clk             (ACLK),
    .i_rst           (~ARESETN),  // SERV uses active-high reset, convert from AXI active-low
    .i_timer_irq     (i_timer_irq),
    
    // Instruction Bus (Wishbone)
    .o_ibus_adr      (wb_ibus_adr),
    .o_ibus_cyc      (wb_ibus_cyc),
    .i_ibus_rdt      (wb_ibus_rdt),
    .i_ibus_ack      (wb_ibus_ack),
    
    // Data Bus (Wishbone)
    .o_dbus_adr      (wb_dbus_adr),
    .o_dbus_dat      (wb_dbus_dat),
    .o_dbus_sel      (wb_dbus_sel),
    .o_dbus_we       (wb_dbus_we),
    .o_dbus_cyc      (wb_dbus_cyc),
    .i_dbus_rdt      (wb_dbus_rdt),
    .i_dbus_ack      (wb_dbus_ack),
    
    // Extension
    .o_ext_funct3    (ext_funct3),
    .i_ext_ready     (ext_ready),
    .i_ext_rd        (ext_rd),
    .o_ext_rs1       (ext_rs1),
    .o_ext_rs2       (ext_rs2),
    
    // MDU
    .o_mdu_valid     (mdu_valid),
    // Counter done signal (for bit-serial mode address capture)
    .o_cnt_done      (serv_cnt_done)
);

// Wishbone to AXI4 Converter for Instruction Bus (Read-only)
wb2axi_read #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH)
) u_wb2axi_inst (
    .ACLK              (ACLK),
    .ARESETN           (ARESETN),
    
    // Wishbone Interface
    .wb_adr            (wb_ibus_adr),
    .wb_cyc            (wb_ibus_cyc),
    // Counter done signal (for bit-serial mode address capture)
    .i_cnt_done        (serv_cnt_done),
    .wb_rdt            (wb_ibus_rdt),
    .wb_ack            (wb_ibus_ack),
    
    // AXI4 Read Address Channel
    .M_AXI_arid        (M0_AXI_arid),
    .M_AXI_araddr      (M0_AXI_araddr),
    .M_AXI_arlen       (M0_AXI_arlen),
    .M_AXI_arsize      (M0_AXI_arsize),
    .M_AXI_arburst     (M0_AXI_arburst),
    .M_AXI_arlock      (M0_AXI_arlock),
    .M_AXI_arcache     (M0_AXI_arcache),
    .M_AXI_arprot      (M0_AXI_arprot),
    .M_AXI_arqos       (M0_AXI_arqos),
    .M_AXI_arregion    (M0_AXI_arregion),
    .M_AXI_arvalid     (M0_AXI_arvalid),
    .M_AXI_arready     (M0_AXI_arready),
    
    // AXI4 Read Data Channel
    .M_AXI_rid         (M0_AXI_rid),
    .M_AXI_rdata       (M0_AXI_rdata),
    .M_AXI_rresp       (M0_AXI_rresp),
    .M_AXI_rlast       (M0_AXI_rlast),
    .M_AXI_rvalid      (M0_AXI_rvalid),
    .M_AXI_rready      (M0_AXI_rready)
);

// Wishbone to AXI4 Converter for Data Bus (Read-write)
wb2axi_write #(
    .ADDR_WIDTH (ADDR_WIDTH),
    .DATA_WIDTH (DATA_WIDTH),
    .ID_WIDTH   (ID_WIDTH)
) u_wb2axi_data (
    .ACLK              (ACLK),
    .ARESETN           (ARESETN),
    
    // Wishbone Interface
    .wb_adr            (wb_dbus_adr),
    .wb_dat            (wb_dbus_dat),
    .wb_sel            (wb_dbus_sel),
    .wb_we             (wb_dbus_we),
    .wb_cyc            (wb_dbus_cyc),
    .wb_rdt            (wb_dbus_rdt),
    .wb_ack            (wb_dbus_ack),
    
    // AXI4 Write Address Channel
    .M_AXI_awid        (M1_AXI_awid),
    .M_AXI_awaddr      (M1_AXI_awaddr),
    .M_AXI_awlen       (M1_AXI_awlen),
    .M_AXI_awsize      (M1_AXI_awsize),
    .M_AXI_awburst     (M1_AXI_awburst),
    .M_AXI_awlock      (M1_AXI_awlock),
    .M_AXI_awcache     (M1_AXI_awcache),
    .M_AXI_awprot      (M1_AXI_awprot),
    .M_AXI_awqos       (M1_AXI_awqos),
    .M_AXI_awregion    (M1_AXI_awregion),
    .M_AXI_awvalid     (M1_AXI_awvalid),
    .M_AXI_awready     (M1_AXI_awready),
    
    // AXI4 Write Data Channel
    .M_AXI_wdata       (M1_AXI_wdata),
    .M_AXI_wstrb       (M1_AXI_wstrb),
    .M_AXI_wlast       (M1_AXI_wlast),
    .M_AXI_wvalid      (M1_AXI_wvalid),
    .M_AXI_wready      (M1_AXI_wready),
    
    // AXI4 Write Response Channel
    .M_AXI_bid         (M1_AXI_bid),
    .M_AXI_bresp       (M1_AXI_bresp),
    .M_AXI_bvalid      (M1_AXI_bvalid),
    .M_AXI_bready      (M1_AXI_bready),
    
    // AXI4 Read Address Channel
    .M_AXI_arid        (M1_AXI_arid),
    .M_AXI_araddr      (M1_AXI_araddr),
    .M_AXI_arlen       (M1_AXI_arlen),
    .M_AXI_arsize      (M1_AXI_arsize),
    .M_AXI_arburst     (M1_AXI_arburst),
    .M_AXI_arlock      (M1_AXI_arlock),
    .M_AXI_arcache     (M1_AXI_arcache),
    .M_AXI_arprot      (M1_AXI_arprot),
    .M_AXI_arqos       (M1_AXI_arqos),
    .M_AXI_arregion    (M1_AXI_arregion),
    .M_AXI_arvalid     (M1_AXI_arvalid),
    .M_AXI_arready     (M1_AXI_arready),
    
    // AXI4 Read Data Channel
    .M_AXI_rid         (M1_AXI_rid),
    .M_AXI_rdata       (M1_AXI_rdata),
    .M_AXI_rresp       (M1_AXI_rresp),
    .M_AXI_rlast       (M1_AXI_rlast),
    .M_AXI_rvalid      (M1_AXI_rvalid),
    .M_AXI_rready      (M1_AXI_rready)
);

endmodule
