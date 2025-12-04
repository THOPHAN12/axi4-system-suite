/*
 * riscv_axi_bridge_ip.v - RISC-V to AXI Bridge IP Core
 * 
 * IP Name: RISCV_AXI_BRIDGE_IP
 * Version: 1.0
 * Vendor: Custom
 * Category: CPU Interface / Protocol Converter
 * 
 * Description:
 *   Complete IP core for connecting RISC-V processors to AXI4-Lite interconnect.
 *   Optimized for Harvard architecture (separate instruction and data buses).
 *   Works with ANY RISC-V core: SERV, PicoRV32, VexRiscv, NEORV32, etc.
 * 
 * Features:
 *   - Dual Wishbone bus input (I-bus + D-bus)
 *   - Single AXI-Lite master output (merged)
 *   - Automatic arbitration (Data priority > Instruction)
 *   - Error handling
 *   - Configurable for Harvard or Von Neumann architecture
 * 
 * Use Cases:
 *   - Connect RISC-V cores to AXI systems
 *   - CPU subsystem integration
 *   - Multi-core systems
 * 
 * Usage:
 *   Instantiate between RISC-V core and AXI interconnect.
 *   Handles all protocol conversion automatically!
 * 
 * Dependencies:
 *   - ../../lib/wb_to_axi_*.v (components)
 *   - ./rtl/wb_to_axilite_bridge.v (internal core)
 *   - ../lib/axi_bus_merger.v
 */

module riscv_axi_bridge_ip #(
    // IP Configuration Parameters
    parameter ADDR_WIDTH  = 32,
    parameter DATA_WIDTH  = 32,
    parameter ID_WIDTH    = 4,
    parameter DUAL_BUS    = 1,      // 1=Harvard (I/D separate), 0=Von Neumann
    parameter MERGE_OUTPUT = 1      // 1=Single AXI, 0=Dual AXI outputs
) (
    // ========================================================================
    // Clock and Reset
    // ========================================================================
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ========================================================================
    // RISC-V Instruction Bus (Wishbone - Read-Only)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   IBUS_ADR_I,
    input  wire                    IBUS_CYC_I,
    input  wire                    IBUS_STB_I,
    output wire [DATA_WIDTH-1:0]   IBUS_DAT_O,
    output wire                    IBUS_ACK_O,
    
    // ========================================================================
    // RISC-V Data Bus (Wishbone - Read-Write)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   DBUS_ADR_I,
    input  wire [DATA_WIDTH-1:0]   DBUS_DAT_I,
    input  wire [3:0]              DBUS_SEL_I,
    input  wire                    DBUS_WE_I,
    input  wire                    DBUS_CYC_I,
    input  wire                    DBUS_STB_I,
    output wire [DATA_WIDTH-1:0]   DBUS_DAT_O,
    output wire                    DBUS_ACK_O,
    output wire                    DBUS_ERR_O,
    
    // ========================================================================
    // AXI4-Lite Master Interface (to Interconnect)
    // ========================================================================
    
    // Write Address Channel
    output wire [ID_WIDTH-1:0]     M_AXI_AWID,
    output wire [ADDR_WIDTH-1:0]   M_AXI_AWADDR,
    output wire [7:0]              M_AXI_AWLEN,
    output wire [2:0]              M_AXI_AWSIZE,
    output wire [1:0]              M_AXI_AWBURST,
    output wire [1:0]              M_AXI_AWLOCK,
    output wire [3:0]              M_AXI_AWCACHE,
    output wire [2:0]              M_AXI_AWPROT,
    output wire [3:0]              M_AXI_AWQOS,
    output wire [3:0]              M_AXI_AWREGION,
    output wire                    M_AXI_AWVALID,
    input  wire                    M_AXI_AWREADY,
    
    // Write Data Channel
    output wire [DATA_WIDTH-1:0]   M_AXI_WDATA,
    output wire [(DATA_WIDTH/8)-1:0] M_AXI_WSTRB,
    output wire                    M_AXI_WLAST,
    output wire                    M_AXI_WVALID,
    input  wire                    M_AXI_WREADY,
    
    // Write Response Channel
    input  wire [ID_WIDTH-1:0]     M_AXI_BID,
    input  wire [1:0]              M_AXI_BRESP,
    input  wire                    M_AXI_BVALID,
    output wire                    M_AXI_BREADY,
    
    // Read Address Channel
    output wire [ID_WIDTH-1:0]     M_AXI_ARID,
    output wire [ADDR_WIDTH-1:0]   M_AXI_ARADDR,
    output wire [7:0]              M_AXI_ARLEN,
    output wire [2:0]              M_AXI_ARSIZE,
    output wire [1:0]              M_AXI_ARBURST,
    output wire [1:0]              M_AXI_ARLOCK,
    output wire [3:0]              M_AXI_ARCACHE,
    output wire [2:0]              M_AXI_ARPROT,
    output wire [3:0]              M_AXI_ARQOS,
    output wire [3:0]              M_AXI_ARREGION,
    output wire                    M_AXI_ARVALID,
    input  wire                    M_AXI_ARREADY,
    
    // Read Data Channel
    input  wire [ID_WIDTH-1:0]     M_AXI_RID,
    input  wire [DATA_WIDTH-1:0]   M_AXI_RDATA,
    input  wire [1:0]              M_AXI_RRESP,
    input  wire                    M_AXI_RLAST,
    input  wire                    M_AXI_RVALID,
    output wire                    M_AXI_RREADY
);

    // ========================================================================
    // IP Core Implementation
    // Instantiate riscv_to_axi_bridge from rtl/
    // ========================================================================
    
    riscv_to_axi_bridge #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .DUAL_BUS(DUAL_BUS),
        .MERGE_OUTPUT(MERGE_OUTPUT)
    ) u_bridge_core (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // RISC-V Instruction Bus
        .ibus_adr(IBUS_ADR_I),
        .ibus_cyc(IBUS_CYC_I),
        .ibus_stb(IBUS_STB_I),
        .ibus_rdt(IBUS_DAT_O),
        .ibus_ack(IBUS_ACK_O),
        
        // RISC-V Data Bus
        .dbus_adr(DBUS_ADR_I),
        .dbus_dat_i(DBUS_DAT_I),
        .dbus_sel(DBUS_SEL_I),
        .dbus_we(DBUS_WE_I),
        .dbus_cyc(DBUS_CYC_I),
        .dbus_stb(DBUS_STB_I),
        .dbus_rdt(DBUS_DAT_O),
        .dbus_ack(DBUS_ACK_O),
        .dbus_err(DBUS_ERR_O),
        
        // AXI Master (merged output)
        .M_AXI_awid(M_AXI_AWID),
        .M_AXI_awaddr(M_AXI_AWADDR),
        .M_AXI_awlen(M_AXI_AWLEN),
        .M_AXI_awsize(M_AXI_AWSIZE),
        .M_AXI_awburst(M_AXI_AWBURST),
        .M_AXI_awlock(M_AXI_AWLOCK),
        .M_AXI_awcache(M_AXI_AWCACHE),
        .M_AXI_awprot(M_AXI_AWPROT),
        .M_AXI_awqos(M_AXI_AWQOS),
        .M_AXI_awregion(M_AXI_AWREGION),
        .M_AXI_awvalid(M_AXI_AWVALID),
        .M_AXI_awready(M_AXI_AWREADY),
        .M_AXI_wdata(M_AXI_WDATA),
        .M_AXI_wstrb(M_AXI_WSTRB),
        .M_AXI_wlast(M_AXI_WLAST),
        .M_AXI_wvalid(M_AXI_WVALID),
        .M_AXI_wready(M_AXI_WREADY),
        .M_AXI_bid(M_AXI_BID),
        .M_AXI_bresp(M_AXI_BRESP),
        .M_AXI_bvalid(M_AXI_BVALID),
        .M_AXI_bready(M_AXI_BREADY),
        .M_AXI_arid(M_AXI_ARID),
        .M_AXI_araddr(M_AXI_ARADDR),
        .M_AXI_arlen(M_AXI_ARLEN),
        .M_AXI_arsize(M_AXI_ARSIZE),
        .M_AXI_arburst(M_AXI_ARBURST),
        .M_AXI_arlock(M_AXI_ARLOCK),
        .M_AXI_arcache(M_AXI_ARCACHE),
        .M_AXI_arprot(M_AXI_ARPROT),
        .M_AXI_arqos(M_AXI_ARQOS),
        .M_AXI_arregion(M_AXI_ARREGION),
        .M_AXI_arvalid(M_AXI_ARVALID),
        .M_AXI_arready(M_AXI_ARREADY),
        .M_AXI_rid(M_AXI_RID),
        .M_AXI_rdata(M_AXI_RDATA),
        .M_AXI_rresp(M_AXI_RRESP),
        .M_AXI_rlast(M_AXI_RLAST),
        .M_AXI_rvalid(M_AXI_RVALID),
        .M_AXI_rready(M_AXI_RREADY)
    );

endmodule

