//------------------------------------------------------------------------------
// axi_rr_interconnect_2x4.v (Verilog-2001)
//
// 2-master / 4-slave AXI4-Lite round-robin interconnect. Provides fairness
// using a simple toggle pointer and assumes at most one outstanding read and
// one outstanding write transaction at a time.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module axi_rr_interconnect_2x4 #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32
) (
    input  wire                       ACLK,
    input  wire                       ARESETN,

    // Master 0
    input  wire [ADDR_WIDTH-1:0]      M0_AWADDR,
    input  wire [2:0]                 M0_AWPROT,
    input  wire                       M0_AWVALID,
    output wire                       M0_AWREADY,
    input  wire [DATA_WIDTH-1:0]      M0_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0]  M0_WSTRB,
    input  wire                       M0_WVALID,
    output wire                       M0_WREADY,
    output wire [1:0]                 M0_BRESP,
    output wire                       M0_BVALID,
    input  wire                       M0_BREADY,
    input  wire [ADDR_WIDTH-1:0]      M0_ARADDR,
    input  wire [2:0]                 M0_ARPROT,
    input  wire                       M0_ARVALID,
    output wire                       M0_ARREADY,
    output wire [DATA_WIDTH-1:0]      M0_RDATA,
    output wire [1:0]                 M0_RRESP,
    output wire                       M0_RVALID,
    output wire                       M0_RLAST,
    input  wire                       M0_RREADY,

    // Master 1
    input  wire [ADDR_WIDTH-1:0]      M1_AWADDR,
    input  wire [2:0]                 M1_AWPROT,
    input  wire                       M1_AWVALID,
    output wire                       M1_AWREADY,
    input  wire [DATA_WIDTH-1:0]      M1_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0]  M1_WSTRB,
    input  wire                       M1_WVALID,
    output wire                       M1_WREADY,
    output wire [1:0]                 M1_BRESP,
    output wire                       M1_BVALID,
    input  wire                       M1_BREADY,
    input  wire [ADDR_WIDTH-1:0]      M1_ARADDR,
    input  wire [2:0]                 M1_ARPROT,
    input  wire                       M1_ARVALID,
    output wire                       M1_ARREADY,
    output wire [DATA_WIDTH-1:0]      M1_RDATA,
    output wire [1:0]                 M1_RRESP,
    output wire                       M1_RVALID,
    output wire                       M1_RLAST,
    input  wire                       M1_RREADY,

    // Slave 0 (00)
    output wire [ADDR_WIDTH-1:0]      S0_AWADDR,
    output wire [2:0]                 S0_AWPROT,
    output wire                       S0_AWVALID,
    input  wire                       S0_AWREADY,
    output wire [DATA_WIDTH-1:0]      S0_WDATA,
    output wire [(DATA_WIDTH/8)-1:0]  S0_WSTRB,
    output wire                       S0_WVALID,
    input  wire                       S0_WREADY,
    input  wire [1:0]                 S0_BRESP,
    input  wire                       S0_BVALID,
    output wire                       S0_BREADY,
    output wire [ADDR_WIDTH-1:0]      S0_ARADDR,
    output wire [2:0]                 S0_ARPROT,
    output wire                       S0_ARVALID,
    input  wire                       S0_ARREADY,
    input  wire [DATA_WIDTH-1:0]      S0_RDATA,
    input  wire [1:0]                 S0_RRESP,
    input  wire                       S0_RVALID,
    input  wire                       S0_RLAST,
    output wire                       S0_RREADY,

    // Slave 1 (01)
    output wire [ADDR_WIDTH-1:0]      S1_AWADDR,
    output wire [2:0]                 S1_AWPROT,
    output wire                       S1_AWVALID,
    input  wire                       S1_AWREADY,
    output wire [DATA_WIDTH-1:0]      S1_WDATA,
    output wire [(DATA_WIDTH/8)-1:0]  S1_WSTRB,
    output wire                       S1_WVALID,
    input  wire                       S1_WREADY,
    input  wire [1:0]                 S1_BRESP,
    input  wire                       S1_BVALID,
    output wire                       S1_BREADY,
    output wire [ADDR_WIDTH-1:0]      S1_ARADDR,
    output wire [2:0]                 S1_ARPROT,
    output wire                       S1_ARVALID,
    input  wire                       S1_ARREADY,
    input  wire [DATA_WIDTH-1:0]      S1_RDATA,
    input  wire [1:0]                 S1_RRESP,
    input  wire                       S1_RVALID,
    input  wire                       S1_RLAST,
    output wire                       S1_RREADY,

    // Slave 2 (10)
    output wire [ADDR_WIDTH-1:0]      S2_AWADDR,
    output wire [2:0]                 S2_AWPROT,
    output wire                       S2_AWVALID,
    input  wire                       S2_AWREADY,
    output wire [DATA_WIDTH-1:0]      S2_WDATA,
    output wire [(DATA_WIDTH/8)-1:0]  S2_WSTRB,
    output wire                       S2_WVALID,
    input  wire                       S2_WREADY,
    input  wire [1:0]                 S2_BRESP,
    input  wire                       S2_BVALID,
    output wire                       S2_BREADY,
    output wire [ADDR_WIDTH-1:0]      S2_ARADDR,
    output wire [2:0]                 S2_ARPROT,
    output wire                       S2_ARVALID,
    input  wire                       S2_ARREADY,
    input  wire [DATA_WIDTH-1:0]      S2_RDATA,
    input  wire [1:0]                 S2_RRESP,
    input  wire                       S2_RVALID,
    input  wire                       S2_RLAST,
    output wire                       S2_RREADY,

    // Slave 3 (11)
    output wire [ADDR_WIDTH-1:0]      S3_AWADDR,
    output wire [2:0]                 S3_AWPROT,
    output wire                       S3_AWVALID,
    input  wire                       S3_AWREADY,
    output wire [DATA_WIDTH-1:0]      S3_WDATA,
    output wire [(DATA_WIDTH/8)-1:0]  S3_WSTRB,
    output wire                       S3_WVALID,
    input  wire                       S3_WREADY,
    input  wire [1:0]                 S3_BRESP,
    input  wire                       S3_BVALID,
    output wire                       S3_BREADY,
    output wire [ADDR_WIDTH-1:0]      S3_ARADDR,
    output wire [2:0]                 S3_ARPROT,
    output wire                       S3_ARVALID,
    input  wire                       S3_ARREADY,
    input  wire [DATA_WIDTH-1:0]      S3_RDATA,
    input  wire [1:0]                 S3_RRESP,
    input  wire                       S3_RVALID,
    input  wire                       S3_RLAST,
    output wire                       S3_RREADY
);

    localparam integer STRB_WIDTH = DATA_WIDTH/8;
    localparam [1:0] SLV0 = 2'd0;
    localparam [1:0] SLV1 = 2'd1;
    localparam [1:0] SLV2 = 2'd2;
    localparam [1:0] SLV3 = 2'd3;
    localparam       MAST0 = 1'b0;
    localparam       MAST1 = 1'b1;

    // -------------------------------------------------------------------------
    // Helper functions (non-automatic for Verilog-2001)
    // -------------------------------------------------------------------------
    function [1:0] decode_slave;
        input [ADDR_WIDTH-1:0] addr;
        begin
            decode_slave = addr[ADDR_WIDTH-1 -: 2];
        end
    endfunction

    function slave_awready;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_awready = S0_AWREADY;
                SLV1: slave_awready = S1_AWREADY;
                SLV2: slave_awready = S2_AWREADY;
                default: slave_awready = S3_AWREADY;
            endcase
        end
    endfunction

    function slave_wready;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_wready = S0_WREADY;
                SLV1: slave_wready = S1_WREADY;
                SLV2: slave_wready = S2_WREADY;
                default: slave_wready = S3_WREADY;
            endcase
        end
    endfunction

    function slave_bvalid;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_bvalid = S0_BVALID;
                SLV1: slave_bvalid = S1_BVALID;
                SLV2: slave_bvalid = S2_BVALID;
                default: slave_bvalid = S3_BVALID;
            endcase
        end
    endfunction

    function [1:0] slave_bresp;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_bresp = S0_BRESP;
                SLV1: slave_bresp = S1_BRESP;
                SLV2: slave_bresp = S2_BRESP;
                default: slave_bresp = S3_BRESP;
            endcase
        end
    endfunction

    function slave_arready;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_arready = S0_ARREADY;
                SLV1: slave_arready = S1_ARREADY;
                SLV2: slave_arready = S2_ARREADY;
                default: slave_arready = S3_ARREADY;
            endcase
        end
    endfunction

    function slave_rvalid;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_rvalid = S0_RVALID;
                SLV1: slave_rvalid = S1_RVALID;
                SLV2: slave_rvalid = S2_RVALID;
                default: slave_rvalid = S3_RVALID;
            endcase
        end
    endfunction

    function [DATA_WIDTH-1:0] slave_rdata;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_rdata = S0_RDATA;
                SLV1: slave_rdata = S1_RDATA;
                SLV2: slave_rdata = S2_RDATA;
                default: slave_rdata = S3_RDATA;
            endcase
        end
    endfunction

    function [1:0] slave_rresp;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_rresp = S0_RRESP;
                SLV1: slave_rresp = S1_RRESP;
                SLV2: slave_rresp = S2_RRESP;
                default: slave_rresp = S3_RRESP;
            endcase
        end
    endfunction

    function slave_rlast;
        input [1:0] sel;
        begin
            case (sel)
                SLV0: slave_rlast = S0_RLAST;
                SLV1: slave_rlast = S1_RLAST;
                SLV2: slave_rlast = S2_RLAST;
                default: slave_rlast = S3_RLAST;
            endcase
        end
    endfunction

    // -------------------------------------------------------------------------
    // Write channel control
    // -------------------------------------------------------------------------
    reg        wr_turn;
    reg        write_active;
    reg        write_master;
    reg [1:0]  write_slave;

    wire       m0_aw_req = !write_active && M0_AWVALID;
    wire       m1_aw_req = !write_active && M1_AWVALID;
    wire       grant_m0  = m0_aw_req && (!m1_aw_req || (m1_aw_req && wr_turn == MAST0));
    wire       grant_m1  = m1_aw_req && (!m0_aw_req || (m0_aw_req && wr_turn == MAST1));

    wire [1:0] m0_aw_sel = decode_slave(M0_AWADDR);
    wire [1:0] m1_aw_sel = decode_slave(M1_AWADDR);

    wire       m0_awhandshake = grant_m0 && slave_awready(m0_aw_sel);
    wire       m1_awhandshake = grant_m1 && slave_awready(m1_aw_sel);

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            wr_turn      <= MAST1;
            write_active <= 1'b0;
            write_master <= MAST0;
            write_slave  <= SLV0;
        end else begin
            if (!write_active) begin
                if (m0_awhandshake) begin
                    write_active <= 1'b1;
                    write_master <= MAST0;
                    write_slave  <= m0_aw_sel;
                    wr_turn      <= MAST1;
                end else if (m1_awhandshake) begin
                    write_active <= 1'b1;
                    write_master <= MAST1;
                    write_slave  <= m1_aw_sel;
                    wr_turn      <= MAST0;
                end
            end else if (slave_bvalid(write_slave) &&
                         ((write_master == MAST0 && M0_BREADY) ||
                          (write_master == MAST1 && M1_BREADY))) begin
                write_active <= 1'b0;
            end
        end
    end

    assign M0_AWREADY = grant_m0 ? slave_awready(m0_aw_sel) : 1'b0;
    assign M1_AWREADY = grant_m1 ? slave_awready(m1_aw_sel) : 1'b0;

    assign S0_AWVALID = (grant_m0 && m0_aw_sel == SLV0 && M0_AWVALID) ||
                        (grant_m1 && m1_aw_sel == SLV0 && M1_AWVALID);
    assign S1_AWVALID = (grant_m0 && m0_aw_sel == SLV1 && M0_AWVALID) ||
                        (grant_m1 && m1_aw_sel == SLV1 && M1_AWVALID);
    assign S2_AWVALID = (grant_m0 && m0_aw_sel == SLV2 && M0_AWVALID) ||
                        (grant_m1 && m1_aw_sel == SLV2 && M1_AWVALID);
    assign S3_AWVALID = (grant_m0 && m0_aw_sel == SLV3 && M0_AWVALID) ||
                        (grant_m1 && m1_aw_sel == SLV3 && M1_AWVALID);

    assign S0_AWADDR  = (grant_m0 && m0_aw_sel == SLV0) ? M0_AWADDR :
                        (grant_m1 && m1_aw_sel == SLV0) ? M1_AWADDR : {ADDR_WIDTH{1'b0}};
    assign S1_AWADDR  = (grant_m0 && m0_aw_sel == SLV1) ? M0_AWADDR :
                        (grant_m1 && m1_aw_sel == SLV1) ? M1_AWADDR : {ADDR_WIDTH{1'b0}};
    assign S2_AWADDR  = (grant_m0 && m0_aw_sel == SLV2) ? M0_AWADDR :
                        (grant_m1 && m1_aw_sel == SLV2) ? M1_AWADDR : {ADDR_WIDTH{1'b0}};
    assign S3_AWADDR  = (grant_m0 && m0_aw_sel == SLV3) ? M0_AWADDR :
                        (grant_m1 && m1_aw_sel == SLV3) ? M1_AWADDR : {ADDR_WIDTH{1'b0}};

    assign S0_AWPROT  = (grant_m0 && m0_aw_sel == SLV0) ? M0_AWPROT :
                        (grant_m1 && m1_aw_sel == SLV0) ? M1_AWPROT : 3'b000;
    assign S1_AWPROT  = (grant_m0 && m0_aw_sel == SLV1) ? M0_AWPROT :
                        (grant_m1 && m1_aw_sel == SLV1) ? M1_AWPROT : 3'b000;
    assign S2_AWPROT  = (grant_m0 && m0_aw_sel == SLV2) ? M0_AWPROT :
                        (grant_m1 && m1_aw_sel == SLV2) ? M1_AWPROT : 3'b000;
    assign S3_AWPROT  = (grant_m0 && m0_aw_sel == SLV3) ? M0_AWPROT :
                        (grant_m1 && m1_aw_sel == SLV3) ? M1_AWPROT : 3'b000;

    wire slave_wready_sel = slave_wready(write_slave);

    assign M0_WREADY = (write_active && write_master == MAST0) ? slave_wready_sel : 1'b0;
    assign M1_WREADY = (write_active && write_master == MAST1) ? slave_wready_sel : 1'b0;

    assign S0_WVALID = (write_active && write_slave == SLV0) &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));
    assign S1_WVALID = (write_active && write_slave == SLV1) &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));
    assign S2_WVALID = (write_active && write_slave == SLV2) &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));
    assign S3_WVALID = (write_active && write_slave == SLV3) &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));

    assign S0_WDATA  = (write_active && write_slave == SLV0) ?
                       ((write_master == MAST0) ? M0_WDATA : M1_WDATA) : {DATA_WIDTH{1'b0}};
    assign S1_WDATA  = (write_active && write_slave == SLV1) ?
                       ((write_master == MAST0) ? M0_WDATA : M1_WDATA) : {DATA_WIDTH{1'b0}};
    assign S2_WDATA  = (write_active && write_slave == SLV2) ?
                       ((write_master == MAST0) ? M0_WDATA : M1_WDATA) : {DATA_WIDTH{1'b0}};
    assign S3_WDATA  = (write_active && write_slave == SLV3) ?
                       ((write_master == MAST0) ? M0_WDATA : M1_WDATA) : {DATA_WIDTH{1'b0}};

    assign S0_WSTRB  = (write_active && write_slave == SLV0) ?
                       ((write_master == MAST0) ? M0_WSTRB : M1_WSTRB) : {STRB_WIDTH{1'b0}};
    assign S1_WSTRB  = (write_active && write_slave == SLV1) ?
                       ((write_master == MAST0) ? M0_WSTRB : M1_WSTRB) : {STRB_WIDTH{1'b0}};
    assign S2_WSTRB  = (write_active && write_slave == SLV2) ?
                       ((write_master == MAST0) ? M0_WSTRB : M1_WSTRB) : {STRB_WIDTH{1'b0}};
    assign S3_WSTRB  = (write_active && write_slave == SLV3) ?
                       ((write_master == MAST0) ? M0_WSTRB : M1_WSTRB) : {STRB_WIDTH{1'b0}};

    assign S0_BREADY = (write_active && write_slave == SLV0) ?
                       ((write_master == MAST0) ? M0_BREADY : M1_BREADY) : 1'b0;
    assign S1_BREADY = (write_active && write_slave == SLV1) ?
                       ((write_master == MAST0) ? M0_BREADY : M1_BREADY) : 1'b0;
    assign S2_BREADY = (write_active && write_slave == SLV2) ?
                       ((write_master == MAST0) ? M0_BREADY : M1_BREADY) : 1'b0;
    assign S3_BREADY = (write_active && write_slave == SLV3) ?
                       ((write_master == MAST0) ? M0_BREADY : M1_BREADY) : 1'b0;

    assign M0_BVALID = (write_active && write_master == MAST0) ? slave_bvalid(write_slave) : 1'b0;
    assign M1_BVALID = (write_active && write_master == MAST1) ? slave_bvalid(write_slave) : 1'b0;

    assign M0_BRESP  = slave_bresp(write_slave);
    assign M1_BRESP  = slave_bresp(write_slave);

    // -------------------------------------------------------------------------
    // Read channel control
    // -------------------------------------------------------------------------
    reg        rd_turn;
    reg        read_active;
    reg        read_master;
    reg [1:0]  read_slave;

    wire       m0_ar_req = !read_active && M0_ARVALID;
    wire       m1_ar_req = !read_active && M1_ARVALID;
    wire       grant_r_m0 = m0_ar_req && (!m1_ar_req || (m1_ar_req && rd_turn == MAST0));
    wire       grant_r_m1 = m1_ar_req && (!m0_ar_req || (m0_ar_req && rd_turn == MAST1));

    wire [1:0] m0_ar_sel = decode_slave(M0_ARADDR);
    wire [1:0] m1_ar_sel = decode_slave(M1_ARADDR);

    wire       m0_ar_handshake = grant_r_m0 && slave_arready(m0_ar_sel);
    wire       m1_ar_handshake = grant_r_m1 && slave_arready(m1_ar_sel);

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            rd_turn     <= MAST1;
            read_active <= 1'b0;
            read_master <= MAST0;
            read_slave  <= SLV0;
        end else begin
            if (!read_active) begin
                if (m0_ar_handshake) begin
                    read_active <= 1'b1;
                    read_master <= MAST0;
                    read_slave  <= m0_ar_sel;
                    rd_turn     <= MAST1;
                end else if (m1_ar_handshake) begin
                    read_active <= 1'b1;
                    read_master <= MAST1;
                    read_slave  <= m1_ar_sel;
                    rd_turn     <= MAST0;
                end
            end else if (slave_rvalid(read_slave) && slave_rlast(read_slave) &&
                         ((read_master == MAST0 && M0_RREADY) ||
                          (read_master == MAST1 && M1_RREADY))) begin
                read_active <= 1'b0;
            end
        end
    end

    assign M0_ARREADY = grant_r_m0 ? slave_arready(m0_ar_sel) : 1'b0;
    assign M1_ARREADY = grant_r_m1 ? slave_arready(m1_ar_sel) : 1'b0;

    assign S0_ARVALID = (grant_r_m0 && m0_ar_sel == SLV0 && M0_ARVALID) ||
                        (grant_r_m1 && m1_ar_sel == SLV0 && M1_ARVALID);
    assign S1_ARVALID = (grant_r_m0 && m0_ar_sel == SLV1 && M0_ARVALID) ||
                        (grant_r_m1 && m1_ar_sel == SLV1 && M1_ARVALID);
    assign S2_ARVALID = (grant_r_m0 && m0_ar_sel == SLV2 && M0_ARVALID) ||
                        (grant_r_m1 && m1_ar_sel == SLV2 && M1_ARVALID);
    assign S3_ARVALID = (grant_r_m0 && m0_ar_sel == SLV3 && M0_ARVALID) ||
                        (grant_r_m1 && m1_ar_sel == SLV3 && M1_ARVALID);

    assign S0_ARADDR  = (grant_r_m0 && m0_ar_sel == SLV0) ? M0_ARADDR :
                        (grant_r_m1 && m1_ar_sel == SLV0) ? M1_ARADDR : {ADDR_WIDTH{1'b0}};
    assign S1_ARADDR  = (grant_r_m0 && m0_ar_sel == SLV1) ? M0_ARADDR :
                        (grant_r_m1 && m1_ar_sel == SLV1) ? M1_ARADDR : {ADDR_WIDTH{1'b0}};
    assign S2_ARADDR  = (grant_r_m0 && m0_ar_sel == SLV2) ? M0_ARADDR :
                        (grant_r_m1 && m1_ar_sel == SLV2) ? M1_ARADDR : {ADDR_WIDTH{1'b0}};
    assign S3_ARADDR  = (grant_r_m0 && m0_ar_sel == SLV3) ? M0_ARADDR :
                        (grant_r_m1 && m1_ar_sel == SLV3) ? M1_ARADDR : {ADDR_WIDTH{1'b0}};

    assign S0_ARPROT  = (grant_r_m0 && m0_ar_sel == SLV0) ? M0_ARPROT :
                        (grant_r_m1 && m1_ar_sel == SLV0) ? M1_ARPROT : 3'b000;
    assign S1_ARPROT  = (grant_r_m0 && m0_ar_sel == SLV1) ? M0_ARPROT :
                        (grant_r_m1 && m1_ar_sel == SLV1) ? M1_ARPROT : 3'b000;
    assign S2_ARPROT  = (grant_r_m0 && m0_ar_sel == SLV2) ? M0_ARPROT :
                        (grant_r_m1 && m1_ar_sel == SLV2) ? M1_ARPROT : 3'b000;
    assign S3_ARPROT  = (grant_r_m0 && m0_ar_sel == SLV3) ? M0_ARPROT :
                        (grant_r_m1 && m1_ar_sel == SLV3) ? M1_ARPROT : 3'b000;

    assign S0_RREADY = (read_active && read_slave == SLV0) ?
                       ((read_master == MAST0) ? M0_RREADY : M1_RREADY) : 1'b0;
    assign S1_RREADY = (read_active && read_slave == SLV1) ?
                       ((read_master == MAST0) ? M0_RREADY : M1_RREADY) : 1'b0;
    assign S2_RREADY = (read_active && read_slave == SLV2) ?
                       ((read_master == MAST0) ? M0_RREADY : M1_RREADY) : 1'b0;
    assign S3_RREADY = (read_active && read_slave == SLV3) ?
                       ((read_master == MAST0) ? M0_RREADY : M1_RREADY) : 1'b0;

    assign M0_RVALID = (read_active && read_master == MAST0) ?
                       slave_rvalid(read_slave) : 1'b0;
    assign M1_RVALID = (read_active && read_master == MAST1) ?
                       slave_rvalid(read_slave) : 1'b0;

    assign M0_RDATA  = slave_rdata(read_slave);
    assign M1_RDATA  = slave_rdata(read_slave);
    assign M0_RRESP  = slave_rresp(read_slave);
    assign M1_RRESP  = slave_rresp(read_slave);
    assign M0_RLAST  = slave_rlast(read_slave);
    assign M1_RLAST  = slave_rlast(read_slave);

endmodule

