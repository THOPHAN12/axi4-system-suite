/*
 * wb_to_axilite_bridge.v - Generic Wishbone to AXI-Lite Bridge Core
 * 
 * Purpose: Complete, reusable bridge for any Wishbone CPU to AXI-Lite interconnect
 * 
 * Features:
 * - Single unified interface (easy to instantiate)
 * - Uses atomic components internally
 * - Supports read and write operations
 * - Configurable parameters
 * - Error handling
 * 
 * Architecture:
 *   Wishbone → [Address] → AXI AR/AW
 *            → [Data]    → AXI W/R
 *            → [Response]→ AXI B
 *            ← [ACK]    ← Combined
 * 
 * Usage Example:
 *   wb_to_axilite_bridge #(
 *       .ADDR_WIDTH(32),
 *       .DATA_WIDTH(32)
 *   ) u_bridge (
 *       .ACLK(clk),
 *       .ARESETN(rst_n),
 *       .wb_*(wb_*),      // Wishbone interface
 *       .M_AXI_*(axi_*)   // AXI-Lite master
 *   );
 */

module wb_to_axilite_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    // Clock and Reset
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ========================================================================
    // Wishbone Interface (Slave - from CPU)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   wb_adr,
    input  wire [DATA_WIDTH-1:0]   wb_dat_i,
    input  wire [3:0]              wb_sel,
    input  wire                    wb_we,
    input  wire                    wb_cyc,
    input  wire                    wb_stb,
    output wire [DATA_WIDTH-1:0]   wb_dat_o,
    output wire                    wb_ack,
    output wire                    wb_err,
    
    // ========================================================================
    // AXI-Lite Master Interface (to Interconnect)
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
    // Internal Signals
    // ========================================================================
    
    // Operation type
    wire is_write = wb_we && wb_cyc && wb_stb;
    wire is_read  = !wb_we && wb_cyc && wb_stb;
    
    // Component interconnect
    wire aw_addr_ready;
    wire ar_addr_ready;
    wire w_data_ready;
    wire r_data_ready;
    wire b_resp_received;
    wire b_resp_error;
    
    // Read data
    wire [DATA_WIDTH-1:0] rd_data;
    
    // Combined acknowledge
    wire write_ack = is_write && aw_addr_ready && w_data_ready && b_resp_received;
    wire read_ack  = is_read && ar_addr_ready && r_data_ready;
    
    assign wb_ack = write_ack || read_ack;
    assign wb_err = b_resp_error;
    assign wb_dat_o = rd_data;

    // ========================================================================
    // Component Instantiation
    // ========================================================================
    
    // Write Address Channel
    wb_to_axi_addr_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .CHANNEL("WRITE")
    ) u_aw_channel (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .wb_adr(wb_adr),
        .wb_cyc(is_write),
        .wb_stb(1'b1),
        .addr_ready(aw_addr_ready),
        .axi_axid(M_AXI_awid),
        .axi_axaddr(M_AXI_awaddr),
        .axi_axlen(M_AXI_awlen),
        .axi_axsize(M_AXI_awsize),
        .axi_axburst(M_AXI_awburst),
        .axi_axlock(M_AXI_awlock),
        .axi_axcache(M_AXI_awcache),
        .axi_axprot(M_AXI_awprot),
        .axi_axqos(M_AXI_awqos),
        .axi_axregion(M_AXI_awregion),
        .axi_axvalid(M_AXI_awvalid),
        .axi_axready(M_AXI_awready)
    );

    // Read Address Channel
    wb_to_axi_addr_channel #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .CHANNEL("READ")
    ) u_ar_channel (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .wb_adr(wb_adr),
        .wb_cyc(is_read),
        .wb_stb(1'b1),
        .addr_ready(ar_addr_ready),
        .axi_axid(M_AXI_arid),
        .axi_axaddr(M_AXI_araddr),
        .axi_axlen(M_AXI_arlen),
        .axi_axsize(M_AXI_arsize),
        .axi_axburst(M_AXI_arburst),
        .axi_axlock(M_AXI_arlock),
        .axi_axcache(M_AXI_arcache),
        .axi_axprot(M_AXI_arprot),
        .axi_axqos(M_AXI_arqos),
        .axi_axregion(M_AXI_arregion),
        .axi_axvalid(M_AXI_arvalid),
        .axi_axready(M_AXI_arready)
    );

    // Write Data Channel
    wb_to_axi_data_channel #(
        .DATA_WIDTH(DATA_WIDTH),
        .CHANNEL("WRITE")
    ) u_w_channel (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .wb_dat_i(wb_dat_i),
        .wb_sel(wb_sel),
        .wb_dat_o(),  // Not used in write mode
        .data_valid(is_write && aw_addr_ready),
        .data_ready(w_data_ready),
        .axi_wdata(M_AXI_wdata),
        .axi_wstrb(M_AXI_wstrb),
        .axi_wlast(M_AXI_wlast),
        .axi_wvalid(M_AXI_wvalid),
        .axi_wready(M_AXI_wready),
        .axi_rdata({DATA_WIDTH{1'b0}}),
        .axi_rresp(2'b00),
        .axi_rlast(1'b0),
        .axi_rvalid(1'b0),
        .axi_rready()  // Not used
    );

    // Read Data Channel
    wb_to_axi_data_channel #(
        .DATA_WIDTH(DATA_WIDTH),
        .CHANNEL("READ")
    ) u_r_channel (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .wb_dat_i({DATA_WIDTH{1'b0}}),  // Not used in read mode
        .wb_sel(4'h0),
        .wb_dat_o(rd_data),
        .data_valid(is_read && ar_addr_ready),
        .data_ready(r_data_ready),
        .axi_wdata(),    // Not used
        .axi_wstrb(),
        .axi_wlast(),
        .axi_wvalid(),
        .axi_wready(1'b0),
        .axi_rdata(M_AXI_rdata),
        .axi_rresp(M_AXI_rresp),
        .axi_rlast(M_AXI_rlast),
        .axi_rvalid(M_AXI_rvalid),
        .axi_rready(M_AXI_rready)
    );

    // Write Response Handler
    wb_to_axi_resp_handler #(
        .ID_WIDTH(ID_WIDTH),
        .ENABLE_ERROR_CHECK(1'b1)
    ) u_b_resp (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .resp_expected(is_write && w_data_ready),
        .resp_received(b_resp_received),
        .resp_error(b_resp_error),
        .axi_bid(M_AXI_bid),
        .axi_bresp(M_AXI_bresp),
        .axi_bvalid(M_AXI_bvalid),
        .axi_bready(M_AXI_bready),
        .wb_ack()  // Handled by combined logic above
    );

endmodule

