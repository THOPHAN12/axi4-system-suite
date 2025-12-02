//------------------------------------------------------------------------------
// axi_rr_interconnect_2x4.sv
//
// Lightweight 2-master, 4-slave AXI4-Lite crossbar with configurable arbitration.
// - Designed for simulation/bring-up use cases where only a single outstanding
//   read and write transaction are required.
// - Address decoding uses the upper two address bits [31:30] to select one of
//   four slaves (00, 01, 10, 11).
// - Arbitration modes:
//   * "FIXED"      : Master 0 has higher priority than Master 1
//   * "ROUND_ROBIN": Fair alternating arbitration (default)
//   * "QOS"        : Priority based on awqos/arqos signals
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module axi_rr_interconnect_2x4 #(
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned DATA_WIDTH = 32,
    parameter string       ARBITRATION_MODE = "ROUND_ROBIN"  // "FIXED", "ROUND_ROBIN", "QOS"
) (
    input  logic                       ACLK,
    input  logic                       ARESETN,

    // -------------------------------------------------------------------------
    // Master 0 Interface
    // -------------------------------------------------------------------------
    input  logic [ADDR_WIDTH-1:0]      M0_AWADDR,
    input  logic [2:0]                 M0_AWPROT,
    input  logic [3:0]                 M0_AWQOS,      // QoS for arbitration (used in "QOS" mode)
    input  logic                       M0_AWVALID,
    output logic                       M0_AWREADY,

    input  logic [DATA_WIDTH-1:0]      M0_WDATA,
    input  logic [(DATA_WIDTH/8)-1:0]  M0_WSTRB,
    input  logic                       M0_WVALID,
    output logic                       M0_WREADY,

    output logic [1:0]                 M0_BRESP,
    output logic                       M0_BVALID,
    input  logic                       M0_BREADY,

    input  logic [ADDR_WIDTH-1:0]      M0_ARADDR,
    input  logic [2:0]                 M0_ARPROT,
    input  logic [3:0]                 M0_ARQOS,      // QoS for arbitration (used in "QOS" mode)
    input  logic                       M0_ARVALID,
    output logic                       M0_ARREADY,

    output logic [DATA_WIDTH-1:0]      M0_RDATA,
    output logic [1:0]                 M0_RRESP,
    output logic                       M0_RVALID,
    output logic                       M0_RLAST,
    input  logic                       M0_RREADY,

    // -------------------------------------------------------------------------
    // Master 1 Interface
    // -------------------------------------------------------------------------
    input  logic [ADDR_WIDTH-1:0]      M1_AWADDR,
    input  logic [2:0]                 M1_AWPROT,
    input  logic [3:0]                 M1_AWQOS,      // QoS for arbitration (used in "QOS" mode)
    input  logic                       M1_AWVALID,
    output logic                       M1_AWREADY,

    input  logic [DATA_WIDTH-1:0]      M1_WDATA,
    input  logic [(DATA_WIDTH/8)-1:0]  M1_WSTRB,
    input  logic                       M1_WVALID,
    output logic                       M1_WREADY,

    output logic [1:0]                 M1_BRESP,
    output logic                       M1_BVALID,
    input  logic                       M1_BREADY,

    input  logic [ADDR_WIDTH-1:0]      M1_ARADDR,
    input  logic [2:0]                 M1_ARPROT,
    input  logic [3:0]                 M1_ARQOS,      // QoS for arbitration (used in "QOS" mode)
    input  logic                       M1_ARVALID,
    output logic                       M1_ARREADY,

    output logic [DATA_WIDTH-1:0]      M1_RDATA,
    output logic [1:0]                 M1_RRESP,
    output logic                       M1_RVALID,
    output logic                       M1_RLAST,
    input  logic                       M1_RREADY,

    // -------------------------------------------------------------------------
    // Slave 0 Interface (address bits [31:30] = 2'b00)
    // -------------------------------------------------------------------------
    output logic [ADDR_WIDTH-1:0]      S0_AWADDR,
    output logic [2:0]                 S0_AWPROT,
    output logic                       S0_AWVALID,
    input  logic                       S0_AWREADY,

    output logic [DATA_WIDTH-1:0]      S0_WDATA,
    output logic [(DATA_WIDTH/8)-1:0]  S0_WSTRB,
    output logic                       S0_WVALID,
    input  logic                       S0_WREADY,

    input  logic [1:0]                 S0_BRESP,
    input  logic                       S0_BVALID,
    output logic                       S0_BREADY,

    output logic [ADDR_WIDTH-1:0]      S0_ARADDR,
    output logic [2:0]                 S0_ARPROT,
    output logic                       S0_ARVALID,
    input  logic                       S0_ARREADY,

    input  logic [DATA_WIDTH-1:0]      S0_RDATA,
    input  logic [1:0]                 S0_RRESP,
    input  logic                       S0_RVALID,
    input  logic                       S0_RLAST,
    output logic                       S0_RREADY,

    // -------------------------------------------------------------------------
    // Slave 1 Interface (address bits [31:30] = 2'b01)
    // -------------------------------------------------------------------------
    output logic [ADDR_WIDTH-1:0]      S1_AWADDR,
    output logic [2:0]                 S1_AWPROT,
    output logic                       S1_AWVALID,
    input  logic                       S1_AWREADY,

    output logic [DATA_WIDTH-1:0]      S1_WDATA,
    output logic [(DATA_WIDTH/8)-1:0]  S1_WSTRB,
    output logic                       S1_WVALID,
    input  logic                       S1_WREADY,

    input  logic [1:0]                 S1_BRESP,
    input  logic                       S1_BVALID,
    output logic                       S1_BREADY,

    output logic [ADDR_WIDTH-1:0]      S1_ARADDR,
    output logic [2:0]                 S1_ARPROT,
    output logic                       S1_ARVALID,
    input  logic                       S1_ARREADY,

    input  logic [DATA_WIDTH-1:0]      S1_RDATA,
    input  logic [1:0]                 S1_RRESP,
    input  logic                       S1_RVALID,
    input  logic                       S1_RLAST,
    output logic                       S1_RREADY,

    // -------------------------------------------------------------------------
    // Slave 2 Interface (address bits [31:30] = 2'b10)
    // -------------------------------------------------------------------------
    output logic [ADDR_WIDTH-1:0]      S2_AWADDR,
    output logic [2:0]                 S2_AWPROT,
    output logic                       S2_AWVALID,
    input  logic                       S2_AWREADY,

    output logic [DATA_WIDTH-1:0]      S2_WDATA,
    output logic [(DATA_WIDTH/8)-1:0]  S2_WSTRB,
    output logic                       S2_WVALID,
    input  logic                       S2_WREADY,

    input  logic [1:0]                 S2_BRESP,
    input  logic                       S2_BVALID,
    output logic                       S2_BREADY,

    output logic [ADDR_WIDTH-1:0]      S2_ARADDR,
    output logic [2:0]                 S2_ARPROT,
    output logic                       S2_ARVALID,
    input  logic                       S2_ARREADY,

    input  logic [DATA_WIDTH-1:0]      S2_RDATA,
    input  logic [1:0]                 S2_RRESP,
    input  logic                       S2_RVALID,
    input  logic                       S2_RLAST,
    output logic                       S2_RREADY,

    // -------------------------------------------------------------------------
    // Slave 3 Interface (address bits [31:30] = 2'b11)
    // -------------------------------------------------------------------------
    output logic [ADDR_WIDTH-1:0]      S3_AWADDR,
    output logic [2:0]                 S3_AWPROT,
    output logic                       S3_AWVALID,
    input  logic                       S3_AWREADY,

    output logic [DATA_WIDTH-1:0]      S3_WDATA,
    output logic [(DATA_WIDTH/8)-1:0]  S3_WSTRB,
    output logic                       S3_WVALID,
    input  logic                       S3_WREADY,

    input  logic [1:0]                 S3_BRESP,
    input  logic                       S3_BVALID,
    output logic                       S3_BREADY,

    output logic [ADDR_WIDTH-1:0]      S3_ARADDR,
    output logic [2:0]                 S3_ARPROT,
    output logic                       S3_ARVALID,
    input  logic                       S3_ARREADY,

    input  logic [DATA_WIDTH-1:0]      S3_RDATA,
    input  logic [1:0]                 S3_RRESP,
    input  logic                       S3_RVALID,
    input  logic                       S3_RLAST,
    output logic                       S3_RREADY
);

    typedef enum logic [1:0] {SLV0 = 2'd0, SLV1 = 2'd1, SLV2 = 2'd2, SLV3 = 2'd3} slave_sel_t;
    typedef enum logic       {MAST0 = 1'b0, MAST1 = 1'b1} master_sel_t;

    // Helper functions -------------------------------------------------------
    function automatic slave_sel_t decode_slave(input logic [ADDR_WIDTH-1:0] addr);
        decode_slave = slave_sel_t'(addr[ADDR_WIDTH-1 -: 2]);
    endfunction

    function automatic logic slave_awready(slave_sel_t sel);
        case (sel)
            SLV0: slave_awready = S0_AWREADY;
            SLV1: slave_awready = S1_AWREADY;
            SLV2: slave_awready = S2_AWREADY;
            default: slave_awready = S3_AWREADY;
        endcase
    endfunction

    function automatic logic slave_wready(slave_sel_t sel);
        case (sel)
            SLV0: slave_wready = S0_WREADY;
            SLV1: slave_wready = S1_WREADY;
            SLV2: slave_wready = S2_WREADY;
            default: slave_wready = S3_WREADY;
        endcase
    endfunction

    function automatic logic slave_bvalid(slave_sel_t sel);
        case (sel)
            SLV0: slave_bvalid = S0_BVALID;
            SLV1: slave_bvalid = S1_BVALID;
            SLV2: slave_bvalid = S2_BVALID;
            default: slave_bvalid = S3_BVALID;
        endcase
    endfunction

    function automatic logic [1:0] slave_bresp(slave_sel_t sel);
        case (sel)
            SLV0: slave_bresp = S0_BRESP;
            SLV1: slave_bresp = S1_BRESP;
            SLV2: slave_bresp = S2_BRESP;
            default: slave_bresp = S3_BRESP;
        endcase
    endfunction

    function automatic logic slave_arready(slave_sel_t sel);
        case (sel)
            SLV0: slave_arready = S0_ARREADY;
            SLV1: slave_arready = S1_ARREADY;
            SLV2: slave_arready = S2_ARREADY;
            default: slave_arready = S3_ARREADY;
        endcase
    endfunction

    function automatic logic slave_rvalid(slave_sel_t sel);
        case (sel)
            SLV0: slave_rvalid = S0_RVALID;
            SLV1: slave_rvalid = S1_RVALID;
            SLV2: slave_rvalid = S2_RVALID;
            default: slave_rvalid = S3_RVALID;
        endcase
    endfunction

    function automatic logic [DATA_WIDTH-1:0] slave_rdata(slave_sel_t sel);
        case (sel)
            SLV0: slave_rdata = S0_RDATA;
            SLV1: slave_rdata = S1_RDATA;
            SLV2: slave_rdata = S2_RDATA;
            default: slave_rdata = S3_RDATA;
        endcase
    endfunction

    function automatic logic [1:0] slave_rresp(slave_sel_t sel);
        case (sel)
            SLV0: slave_rresp = S0_RRESP;
            SLV1: slave_rresp = S1_RRESP;
            SLV2: slave_rresp = S2_RRESP;
            default: slave_rresp = S3_RRESP;
        endcase
    endfunction

    function automatic logic slave_rlast(slave_sel_t sel);
        case (sel)
            SLV0: slave_rlast = S0_RLAST;
            SLV1: slave_rlast = S1_RLAST;
            SLV2: slave_rlast = S2_RLAST;
            default: slave_rlast = S3_RLAST;
        endcase
    endfunction

    // -------------------------------------------------------------------------
    // Write channel control
    // -------------------------------------------------------------------------
    logic        wr_turn;
    logic        write_active;
    master_sel_t write_master;
    slave_sel_t  write_slave;

    wire         m0_aw_req = !write_active && M0_AWVALID;
    wire         m1_aw_req = !write_active && M1_AWVALID;
    
    // -------------------------------------------------------------------------
    // Write Arbitration Logic - Configurable
    // -------------------------------------------------------------------------
    wire         grant_m0, grant_m1;
    
    generate
        if (ARBITRATION_MODE == "FIXED") begin : gen_fixed_write_arb
            // Fixed Priority: M0 > M1
            assign grant_m0 = m0_aw_req;
            assign grant_m1 = m1_aw_req && !m0_aw_req;
            
        end else if (ARBITRATION_MODE == "QOS") begin : gen_qos_write_arb
            // QoS-based: Higher QoS wins, M0 wins on tie
            wire m0_higher_qos = (M0_AWQOS >= M1_AWQOS);
            assign grant_m0 = m0_aw_req && (!m1_aw_req || m0_higher_qos);
            assign grant_m1 = m1_aw_req && (!m0_aw_req || !m0_higher_qos);
            
        end else begin : gen_rr_write_arb  // Default: ROUND_ROBIN
            // Round-Robin: Fair alternating based on wr_turn
            assign grant_m0 = m0_aw_req && (!m1_aw_req || (m1_aw_req && wr_turn == MAST0));
            assign grant_m1 = m1_aw_req && (!m0_aw_req || (m0_aw_req && wr_turn == MAST1));
        end
    endgenerate

    slave_sel_t  m0_aw_sel = decode_slave(M0_AWADDR);
    slave_sel_t  m1_aw_sel = decode_slave(M1_AWADDR);

    wire         m0_awhandshake = grant_m0 && slave_awready(m0_aw_sel);
    wire         m1_awhandshake = grant_m1 && slave_awready(m1_aw_sel);

    always_ff @(posedge ACLK or negedge ARESETN) begin
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
                    // Update turn pointer only for Round-Robin mode
                    if (ARBITRATION_MODE == "ROUND_ROBIN") begin
                        wr_turn <= MAST1;
                    end
                end else if (m1_awhandshake) begin
                    write_active <= 1'b1;
                    write_master <= MAST1;
                    write_slave  <= m1_aw_sel;
                    // Update turn pointer only for Round-Robin mode
                    if (ARBITRATION_MODE == "ROUND_ROBIN") begin
                        wr_turn <= MAST0;
                    end
                end
            end else if (slave_bvalid(write_slave) &&
                         ((write_master == MAST0 && M0_BREADY) ||
                          (write_master == MAST1 && M1_BREADY))) begin
                write_active <= 1'b0;
            end
        end
    end

    // AW channel forwarding
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

    assign S0_AWADDR  = grant_m0 && m0_aw_sel == SLV0 ? M0_AWADDR :
                        grant_m1 && m1_aw_sel == SLV0 ? M1_AWADDR : '0;
    assign S1_AWADDR  = grant_m0 && m0_aw_sel == SLV1 ? M0_AWADDR :
                        grant_m1 && m1_aw_sel == SLV1 ? M1_AWADDR : '0;
    assign S2_AWADDR  = grant_m0 && m0_aw_sel == SLV2 ? M0_AWADDR :
                        grant_m1 && m1_aw_sel == SLV2 ? M1_AWADDR : '0;
    assign S3_AWADDR  = grant_m0 && m0_aw_sel == SLV3 ? M0_AWADDR :
                        grant_m1 && m1_aw_sel == SLV3 ? M1_AWADDR : '0;

    assign S0_AWPROT  = grant_m0 && m0_aw_sel == SLV0 ? M0_AWPROT :
                        grant_m1 && m1_aw_sel == SLV0 ? M1_AWPROT : 3'b000;
    assign S1_AWPROT  = grant_m0 && m0_aw_sel == SLV1 ? M0_AWPROT :
                        grant_m1 && m1_aw_sel == SLV1 ? M1_AWPROT : 3'b000;
    assign S2_AWPROT  = grant_m0 && m0_aw_sel == SLV2 ? M0_AWPROT :
                        grant_m1 && m1_aw_sel == SLV2 ? M1_AWPROT : 3'b000;
    assign S3_AWPROT  = grant_m0 && m0_aw_sel == SLV3 ? M0_AWPROT :
                        grant_m1 && m1_aw_sel == SLV3 ? M1_AWPROT : 3'b000;

    // W channel
    wire slave_wready_sel = slave_wready(write_slave);

    assign M0_WREADY = write_active && write_master == MAST0 ? slave_wready_sel : 1'b0;
    assign M1_WREADY = write_active && write_master == MAST1 ? slave_wready_sel : 1'b0;

    assign S0_WVALID = write_active && write_slave == SLV0 &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));
    assign S1_WVALID = write_active && write_slave == SLV1 &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));
    assign S2_WVALID = write_active && write_slave == SLV2 &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));
    assign S3_WVALID = write_active && write_slave == SLV3 &&
                       ((write_master == MAST0 && M0_WVALID) ||
                        (write_master == MAST1 && M1_WVALID));

    assign S0_WDATA  = write_active && write_slave == SLV0 ?
                       (write_master == MAST0 ? M0_WDATA : M1_WDATA) : '0;
    assign S1_WDATA  = write_active && write_slave == SLV1 ?
                       (write_master == MAST0 ? M0_WDATA : M1_WDATA) : '0;
    assign S2_WDATA  = write_active && write_slave == SLV2 ?
                       (write_master == MAST0 ? M0_WDATA : M1_WDATA) : '0;
    assign S3_WDATA  = write_active && write_slave == SLV3 ?
                       (write_master == MAST0 ? M0_WDATA : M1_WDATA) : '0;

    assign S0_WSTRB  = write_active && write_slave == SLV0 ?
                       (write_master == MAST0 ? M0_WSTRB : M1_WSTRB) : '0;
    assign S1_WSTRB  = write_active && write_slave == SLV1 ?
                       (write_master == MAST0 ? M0_WSTRB : M1_WSTRB) : '0;
    assign S2_WSTRB  = write_active && write_slave == SLV2 ?
                       (write_master == MAST0 ? M0_WSTRB : M1_WSTRB) : '0;
    assign S3_WSTRB  = write_active && write_slave == SLV3 ?
                       (write_master == MAST0 ? M0_WSTRB : M1_WSTRB) : '0;

    assign S0_BREADY = write_active && write_slave == SLV0 ?
                       (write_master == MAST0 ? M0_BREADY : M1_BREADY) : 1'b0;
    assign S1_BREADY = write_active && write_slave == SLV1 ?
                       (write_master == MAST0 ? M0_BREADY : M1_BREADY) : 1'b0;
    assign S2_BREADY = write_active && write_slave == SLV2 ?
                       (write_master == MAST0 ? M0_BREADY : M1_BREADY) : 1'b0;
    assign S3_BREADY = write_active && write_slave == SLV3 ?
                       (write_master == MAST0 ? M0_BREADY : M1_BREADY) : 1'b0;

    assign M0_BVALID = write_active && write_master == MAST0 ?
                       slave_bvalid(write_slave) : 1'b0;
    assign M1_BVALID = write_active && write_master == MAST1 ?
                       slave_bvalid(write_slave) : 1'b0;

    assign M0_BRESP  = slave_bresp(write_slave);
    assign M1_BRESP  = slave_bresp(write_slave);

    // -------------------------------------------------------------------------
    // Read channel control
    // -------------------------------------------------------------------------
    logic        rd_turn;
    logic        read_active;
    master_sel_t read_master;
    slave_sel_t  read_slave;

    wire         m0_ar_req = !read_active && M0_ARVALID;
    wire         m1_ar_req = !read_active && M1_ARVALID;
    
    // -------------------------------------------------------------------------
    // Read Arbitration Logic - Configurable
    // -------------------------------------------------------------------------
    wire         grant_r_m0, grant_r_m1;
    
    generate
        if (ARBITRATION_MODE == "FIXED") begin : gen_fixed_read_arb
            // Fixed Priority: M0 > M1
            assign grant_r_m0 = m0_ar_req;
            assign grant_r_m1 = m1_ar_req && !m0_ar_req;
            
        end else if (ARBITRATION_MODE == "QOS") begin : gen_qos_read_arb
            // QoS-based: Higher QoS wins, M0 wins on tie
            wire m0_higher_qos_r = (M0_ARQOS >= M1_ARQOS);
            assign grant_r_m0 = m0_ar_req && (!m1_ar_req || m0_higher_qos_r);
            assign grant_r_m1 = m1_ar_req && (!m0_ar_req || !m0_higher_qos_r);
            
        end else begin : gen_rr_read_arb  // Default: ROUND_ROBIN
            // Round-Robin: Fair alternating based on rd_turn
            assign grant_r_m0 = m0_ar_req && (!m1_ar_req || (m1_ar_req && rd_turn == MAST0));
            assign grant_r_m1 = m1_ar_req && (!m0_ar_req || (m0_ar_req && rd_turn == MAST1));
        end
    endgenerate

    slave_sel_t  m0_ar_sel = decode_slave(M0_ARADDR);
    slave_sel_t  m1_ar_sel = decode_slave(M1_ARADDR);

    wire         m0_ar_handshake = grant_r_m0 && slave_arready(m0_ar_sel);
    wire         m1_ar_handshake = grant_r_m1 && slave_arready(m1_ar_sel);

    always_ff @(posedge ACLK or negedge ARESETN) begin
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
                    // Update turn pointer only for Round-Robin mode
                    if (ARBITRATION_MODE == "ROUND_ROBIN") begin
                        rd_turn <= MAST1;
                    end
                end else if (m1_ar_handshake) begin
                    read_active <= 1'b1;
                    read_master <= MAST1;
                    read_slave  <= m1_ar_sel;
                    // Update turn pointer only for Round-Robin mode
                    if (ARBITRATION_MODE == "ROUND_ROBIN") begin
                        rd_turn <= MAST0;
                    end
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

    assign S0_ARADDR  = grant_r_m0 && m0_ar_sel == SLV0 ? M0_ARADDR :
                        grant_r_m1 && m1_ar_sel == SLV0 ? M1_ARADDR : '0;
    assign S1_ARADDR  = grant_r_m0 && m0_ar_sel == SLV1 ? M0_ARADDR :
                        grant_r_m1 && m1_ar_sel == SLV1 ? M1_ARADDR : '0;
    assign S2_ARADDR  = grant_r_m0 && m0_ar_sel == SLV2 ? M0_ARADDR :
                        grant_r_m1 && m1_ar_sel == SLV2 ? M1_ARADDR : '0;
    assign S3_ARADDR  = grant_r_m0 && m0_ar_sel == SLV3 ? M0_ARADDR :
                        grant_r_m1 && m1_ar_sel == SLV3 ? M1_ARADDR : '0;

    assign S0_ARPROT  = grant_r_m0 && m0_ar_sel == SLV0 ? M0_ARPROT :
                        grant_r_m1 && m1_ar_sel == SLV0 ? M1_ARPROT : 3'b000;
    assign S1_ARPROT  = grant_r_m0 && m0_ar_sel == SLV1 ? M0_ARPROT :
                        grant_r_m1 && m1_ar_sel == SLV1 ? M1_ARPROT : 3'b000;
    assign S2_ARPROT  = grant_r_m0 && m0_ar_sel == SLV2 ? M0_ARPROT :
                        grant_r_m1 && m1_ar_sel == SLV2 ? M1_ARPROT : 3'b000;
    assign S3_ARPROT  = grant_r_m0 && m0_ar_sel == SLV3 ? M0_ARPROT :
                        grant_r_m1 && m1_ar_sel == SLV3 ? M1_ARPROT : 3'b000;

    assign S0_RREADY = read_active && read_slave == SLV0 ?
                       (read_master == MAST0 ? M0_RREADY : M1_RREADY) : 1'b0;
    assign S1_RREADY = read_active && read_slave == SLV1 ?
                       (read_master == MAST0 ? M0_RREADY : M1_RREADY) : 1'b0;
    assign S2_RREADY = read_active && read_slave == SLV2 ?
                       (read_master == MAST0 ? M0_RREADY : M1_RREADY) : 1'b0;
    assign S3_RREADY = read_active && read_slave == SLV3 ?
                       (read_master == MAST0 ? M0_RREADY : M1_RREADY) : 1'b0;

    assign M0_RVALID = read_active && read_master == MAST0 ?
                       slave_rvalid(read_slave) : 1'b0;
    assign M1_RVALID = read_active && read_master == MAST1 ?
                       slave_rvalid(read_slave) : 1'b0;

    assign M0_RDATA  = slave_rdata(read_slave);
    assign M1_RDATA  = slave_rdata(read_slave);
    assign M0_RRESP  = slave_rresp(read_slave);
    assign M1_RRESP  = slave_rresp(read_slave);
    assign M0_RLAST  = slave_rlast(read_slave);
    assign M1_RLAST  = slave_rlast(read_slave);

endmodule

