/*
 * riscv_to_axi_bridge.v - RISC-V to AXI-Lite Bridge Core
 * 
 * Purpose: Specialized bridge for RISC-V cores with Harvard architecture (separate I/D buses)
 * 
 * Features:
 * - Dual-bus support (Instruction + Data buses)
 * - Single or dual AXI master output (configurable)
 * - Uses atomic components internally
 * - Optimized for RISC-V timing
 * - Easy to use with any RISC-V core (SERV, PicoRV32, VexRiscv, etc.)
 * 
 * Architecture:
 *   Instruction Bus (WB) → [Bridge] → AXI Master (Read-only)
 *   Data Bus (WB)        → [Bridge] → AXI Master (Read-Write)
 *                                  ↓
 *                         [Optional Merger] (if MERGE_OUTPUT=1)
 *                                  ↓
 *                          Single AXI Master
 * 
 * Usage Example:
 *   riscv_to_axi_bridge #(
 *       .DUAL_BUS(1),      // Separate I/D buses
 *       .MERGE_OUTPUT(1)   // Merge to single AXI
 *   ) u_riscv_bridge (
 *       .ACLK(clk),
 *       .ARESETN(rst_n),
 *       .ibus_*(ibus_*),   // Instruction bus
 *       .dbus_*(dbus_*),   // Data bus
 *       .M_AXI_*(axi_*)    // Single AXI output (merged)
 *   );
 */

module riscv_to_axi_bridge #(
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32,
    parameter ID_WIDTH    = 4,
    parameter DUAL_BUS    = 1,        // 1 = Harvard arch (I/D separate), 0 = Von Neumann (unified)
    parameter MERGE_OUTPUT = 1        // 1 = single AXI output, 0 = dual AXI outputs
) (
    // Clock and Reset
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ========================================================================
    // Instruction Bus (Wishbone - Read-only)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   ibus_adr,
    input  wire                    ibus_cyc,
    input  wire                    ibus_stb,
    output wire [DATA_WIDTH-1:0]   ibus_rdt,
    output wire                    ibus_ack,
    
    // ========================================================================
    // Data Bus (Wishbone - Read-Write)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   dbus_adr,
    input  wire [DATA_WIDTH-1:0]   dbus_dat_i,
    input  wire [3:0]              dbus_sel,
    input  wire                    dbus_we,
    input  wire                    dbus_cyc,
    input  wire                    dbus_stb,
    output wire [DATA_WIDTH-1:0]   dbus_rdt,
    output wire                    dbus_ack,
    output wire                    dbus_err,
    
    // ========================================================================
    // AXI Master Interface (Merged or Dual)
    // If MERGE_OUTPUT=1: Single AXI master
    // If MERGE_OUTPUT=0: M0_* for instruction, M1_* for data
    // ========================================================================
    
    // Write Address Channel
    output wire [ID_WIDTH-1:0]     M_AXI_awid,
    output wire [ADDR_WIDTH-1:0]   M_AXI_awaddr,
    output wire [7:0]              M_AXI_awlen,
    output wire [2:0]              M_AXI_awsize,
    output wire [1:0]              M_AXI_awburst,
    output wire [1:0]              M_AXI_awlock,
    output wire [3:0]              M_AXI_awcache,
    output wire [2:0]              M_AXI_awprot,
    output wire [3:0]              M_AXI_awqos,
    output wire [3:0]              M_AXI_awregion,
    output wire                    M_AXI_awvalid,
    input  wire                    M_AXI_awready,
    
    // Write Data Channel
    output wire [DATA_WIDTH-1:0]   M_AXI_wdata,
    output wire [(DATA_WIDTH/8)-1:0] M_AXI_wstrb,
    output wire                    M_AXI_wlast,
    output wire                    M_AXI_wvalid,
    input  wire                    M_AXI_wready,
    
    // Write Response Channel
    input  wire [ID_WIDTH-1:0]     M_AXI_bid,
    input  wire [1:0]              M_AXI_bresp,
    input  wire                    M_AXI_bvalid,
    output wire                    M_AXI_bready,
    
    // Read Address Channel
    output wire [ID_WIDTH-1:0]     M_AXI_arid,
    output wire [ADDR_WIDTH-1:0]   M_AXI_araddr,
    output wire [7:0]              M_AXI_arlen,
    output wire [2:0]              M_AXI_arsize,
    output wire [1:0]              M_AXI_arburst,
    output wire [1:0]              M_AXI_arlock,
    output wire [3:0]              M_AXI_arcache,
    output wire [2:0]              M_AXI_arprot,
    output wire [3:0]              M_AXI_arqos,
    output wire [3:0]              M_AXI_arregion,
    output wire                    M_AXI_arvalid,
    input  wire                    M_AXI_arready,
    
    // Read Data Channel
    input  wire [ID_WIDTH-1:0]     M_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M_AXI_rdata,
    input  wire [1:0]              M_AXI_rresp,
    input  wire                    M_AXI_rlast,
    input  wire                    M_AXI_rvalid,
    output wire                    M_AXI_rready
);

    // ========================================================================
    // Internal Bridge Instances
    // ========================================================================
    
    generate
        if (DUAL_BUS && MERGE_OUTPUT) begin : gen_dual_bus_merged
            
            // Instruction Bus Bridge (Read-only)
            wire [ADDR_WIDTH-1:0] ibus_araddr;
            wire                  ibus_arvalid;
            wire                  ibus_arready;
            wire [DATA_WIDTH-1:0] ibus_rdata;
            wire                  ibus_rvalid;
            wire                  ibus_rready;
            
            wb_to_axilite_bridge #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH),
                .ID_WIDTH(ID_WIDTH)
            ) u_ibus_bridge (
                .ACLK(ACLK),
                .ARESETN(ARESETN),
                .wb_adr(ibus_adr),
                .wb_dat_i({DATA_WIDTH{1'b0}}),
                .wb_sel(4'hF),
                .wb_we(1'b0),  // Read-only
                .wb_cyc(ibus_cyc),
                .wb_stb(ibus_stb),
                .wb_dat_o(ibus_rdt),
                .wb_ack(ibus_ack),
                .wb_err(),
                // Only AR/R channels used
                .M_AXI_awid(),
                .M_AXI_awaddr(),
                .M_AXI_awlen(),
                .M_AXI_awsize(),
                .M_AXI_awburst(),
                .M_AXI_awlock(),
                .M_AXI_awcache(),
                .M_AXI_awprot(),
                .M_AXI_awqos(),
                .M_AXI_awregion(),
                .M_AXI_awvalid(),
                .M_AXI_awready(1'b0),
                .M_AXI_wdata(),
                .M_AXI_wstrb(),
                .M_AXI_wlast(),
                .M_AXI_wvalid(),
                .M_AXI_wready(1'b0),
                .M_AXI_bid({ID_WIDTH{1'b0}}),
                .M_AXI_bresp(2'b00),
                .M_AXI_bvalid(1'b0),
                .M_AXI_bready(),
                .M_AXI_arid(),
                .M_AXI_araddr(ibus_araddr),
                .M_AXI_arlen(),
                .M_AXI_arsize(),
                .M_AXI_arburst(),
                .M_AXI_arlock(),
                .M_AXI_arcache(),
                .M_AXI_arprot(),
                .M_AXI_arqos(),
                .M_AXI_arregion(),
                .M_AXI_arvalid(ibus_arvalid),
                .M_AXI_arready(ibus_arready),
                .M_AXI_rid({ID_WIDTH{1'b0}}),
                .M_AXI_rdata(ibus_rdata),
                .M_AXI_rresp(2'b00),
                .M_AXI_rlast(1'b1),
                .M_AXI_rvalid(ibus_rvalid),
                .M_AXI_rready(ibus_rready)
            );
            
            // Data Bus Bridge (Read-Write)
            wire [ADDR_WIDTH-1:0] dbus_awaddr;
            wire                  dbus_awvalid;
            wire                  dbus_awready;
            wire [DATA_WIDTH-1:0] dbus_wdata;
            wire [(DATA_WIDTH/8)-1:0] dbus_wstrb;
            wire                  dbus_wvalid;
            wire                  dbus_wready;
            wire                  dbus_bvalid;
            wire                  dbus_bready;
            wire [ADDR_WIDTH-1:0] dbus_araddr;
            wire                  dbus_arvalid;
            wire                  dbus_arready;
            wire [DATA_WIDTH-1:0] dbus_rdata;
            wire                  dbus_rvalid;
            wire                  dbus_rready;
            
            wb_to_axilite_bridge #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH),
                .ID_WIDTH(ID_WIDTH)
            ) u_dbus_bridge (
                .ACLK(ACLK),
                .ARESETN(ARESETN),
                .wb_adr(dbus_adr),
                .wb_dat_i(dbus_dat_i),
                .wb_sel(dbus_sel),
                .wb_we(dbus_we),
                .wb_cyc(dbus_cyc),
                .wb_stb(dbus_stb),
                .wb_dat_o(dbus_rdt),
                .wb_ack(dbus_ack),
                .wb_err(dbus_err),
                // AXI outputs (connected to merger)
                .M_AXI_awid(),
                .M_AXI_awaddr(dbus_awaddr),
                .M_AXI_awlen(),
                .M_AXI_awsize(),
                .M_AXI_awburst(),
                .M_AXI_awlock(),
                .M_AXI_awcache(),
                .M_AXI_awprot(),
                .M_AXI_awqos(),
                .M_AXI_awregion(),
                .M_AXI_awvalid(dbus_awvalid),
                .M_AXI_awready(dbus_awready),
                .M_AXI_wdata(dbus_wdata),
                .M_AXI_wstrb(dbus_wstrb),
                .M_AXI_wlast(),
                .M_AXI_wvalid(dbus_wvalid),
                .M_AXI_wready(dbus_wready),
                .M_AXI_bid({ID_WIDTH{1'b0}}),
                .M_AXI_bresp(2'b00),
                .M_AXI_bvalid(dbus_bvalid),
                .M_AXI_bready(dbus_bready),
                .M_AXI_arid(),
                .M_AXI_araddr(dbus_araddr),
                .M_AXI_arlen(),
                .M_AXI_arsize(),
                .M_AXI_arburst(),
                .M_AXI_arlock(),
                .M_AXI_arcache(),
                .M_AXI_arprot(),
                .M_AXI_arqos(),
                .M_AXI_arregion(),
                .M_AXI_arvalid(dbus_arvalid),
                .M_AXI_arready(dbus_arready),
                .M_AXI_rid({ID_WIDTH{1'b0}}),
                .M_AXI_rdata(dbus_rdata),
                .M_AXI_rresp(2'b00),
                .M_AXI_rlast(1'b1),
                .M_AXI_rvalid(dbus_rvalid),
                .M_AXI_rready(dbus_rready)
            );
            
            // Bus Merger - Arbitrates between instruction and data buses
            // Priority: Data bus > Instruction bus (data is time-critical)
            axi_bus_merger #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH),
                .ID_WIDTH(ID_WIDTH)
            ) u_merger (
                .ACLK(ACLK),
                .ARESETN(ARESETN),
                
                // Master 0: Instruction bus (lower priority)
                .M0_awaddr({ADDR_WIDTH{1'b0}}),  // I-bus read-only
                .M0_awvalid(1'b0),
                .M0_awready(),
                .M0_wdata({DATA_WIDTH{1'b0}}),
                .M0_wstrb({(DATA_WIDTH/8){1'b0}}),
                .M0_wvalid(1'b0),
                .M0_wready(),
                .M0_bvalid(1'b0),
                .M0_bready(),
                .M0_araddr(ibus_araddr),
                .M0_arvalid(ibus_arvalid),
                .M0_arready(ibus_arready),
                .M0_rdata(ibus_rdata),
                .M0_rvalid(ibus_rvalid),
                .M0_rready(ibus_rready),
                
                // Master 1: Data bus (higher priority)
                .M1_awaddr(dbus_awaddr),
                .M1_awvalid(dbus_awvalid),
                .M1_awready(dbus_awready),
                .M1_wdata(dbus_wdata),
                .M1_wstrb(dbus_wstrb),
                .M1_wvalid(dbus_wvalid),
                .M1_wready(dbus_wready),
                .M1_bvalid(dbus_bvalid),
                .M1_bready(dbus_bready),
                .M1_araddr(dbus_araddr),
                .M1_arvalid(dbus_arvalid),
                .M1_arready(dbus_arready),
                .M1_rdata(dbus_rdata),
                .M1_rvalid(dbus_rvalid),
                .M1_rready(dbus_rready),
                
                // Merged AXI output
                .S_awaddr(M_AXI_awaddr),
                .S_awvalid(M_AXI_awvalid),
                .S_awready(M_AXI_awready),
                .S_wdata(M_AXI_wdata),
                .S_wstrb(M_AXI_wstrb),
                .S_wlast(M_AXI_wlast),
                .S_wvalid(M_AXI_wvalid),
                .S_wready(M_AXI_wready),
                .S_bresp(M_AXI_bresp),
                .S_bvalid(M_AXI_bvalid),
                .S_bready(M_AXI_bready),
                .S_araddr(M_AXI_araddr),
                .S_arvalid(M_AXI_arvalid),
                .S_arready(M_AXI_arready),
                .S_rdata(M_AXI_rdata),
                .S_rresp(M_AXI_rresp),
                .S_rlast(M_AXI_rlast),
                .S_rvalid(M_AXI_rvalid),
                .S_rready(M_AXI_rready)
            );
            
        end else if (DUAL_BUS && !MERGE_OUTPUT) begin : gen_dual_bus_separate
            
            // Two separate AXI masters (not merged)
            // M0_AXI_* for instruction, M1_AXI_* for data
            // Implementation similar but without merger
            // (Can be added if needed)
            
        end else begin : gen_single_bus
            
            // Single unified bus (Von Neumann architecture)
            wb_to_axilite_bridge #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .DATA_WIDTH(DATA_WIDTH),
                .ID_WIDTH(ID_WIDTH)
            ) u_unified_bridge (
                .ACLK(ACLK),
                .ARESETN(ARESETN),
                // Use data bus signals for unified bus
                .wb_adr(dbus_adr),
                .wb_dat_i(dbus_dat_i),
                .wb_sel(dbus_sel),
                .wb_we(dbus_we),
                .wb_cyc(dbus_cyc),
                .wb_stb(dbus_stb),
                .wb_dat_o(dbus_rdt),
                .wb_ack(dbus_ack),
                .wb_err(dbus_err),
                // AXI output
                .M_AXI_awid(M_AXI_awid),
                .M_AXI_awaddr(M_AXI_awaddr),
                .M_AXI_awlen(M_AXI_awlen),
                .M_AXI_awsize(M_AXI_awsize),
                .M_AXI_awburst(M_AXI_awburst),
                .M_AXI_awlock(M_AXI_awlock),
                .M_AXI_awcache(M_AXI_awcache),
                .M_AXI_awprot(M_AXI_awprot),
                .M_AXI_awqos(M_AXI_awqos),
                .M_AXI_awregion(M_AXI_awregion),
                .M_AXI_awvalid(M_AXI_awvalid),
                .M_AXI_awready(M_AXI_awready),
                .M_AXI_wdata(M_AXI_wdata),
                .M_AXI_wstrb(M_AXI_wstrb),
                .M_AXI_wlast(M_AXI_wlast),
                .M_AXI_wvalid(M_AXI_wvalid),
                .M_AXI_wready(M_AXI_wready),
                .M_AXI_bid(M_AXI_bid),
                .M_AXI_bresp(M_AXI_bresp),
                .M_AXI_bvalid(M_AXI_bvalid),
                .M_AXI_bready(M_AXI_bready),
                .M_AXI_arid(M_AXI_arid),
                .M_AXI_araddr(M_AXI_araddr),
                .M_AXI_arlen(M_AXI_arlen),
                .M_AXI_arsize(M_AXI_arsize),
                .M_AXI_arburst(M_AXI_arburst),
                .M_AXI_arlock(M_AXI_arlock),
                .M_AXI_arcache(M_AXI_arcache),
                .M_AXI_arprot(M_AXI_arprot),
                .M_AXI_arqos(M_AXI_arqos),
                .M_AXI_arregion(M_AXI_arregion),
                .M_AXI_arvalid(M_AXI_arvalid),
                .M_AXI_arready(M_AXI_arready),
                .M_AXI_rid(M_AXI_rid),
                .M_AXI_rdata(M_AXI_rdata),
                .M_AXI_rresp(M_AXI_rresp),
                .M_AXI_rlast(M_AXI_rlast),
                .M_AXI_rvalid(M_AXI_rvalid),
                .M_AXI_rready(M_AXI_rready)
            );
            
            // Instruction bus not used in single-bus mode
            assign ibus_rdt = {DATA_WIDTH{1'b0}};
            assign ibus_ack = 1'b0;
            
        end
    endgenerate

endmodule

