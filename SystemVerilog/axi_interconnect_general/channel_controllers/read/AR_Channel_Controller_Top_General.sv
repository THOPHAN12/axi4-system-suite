// AR_Channel_Controller_Top_General.sv - General read address channel controller

`timescale 1ns/1ps

module AR_Channel_Controller_Top_General #(
    parameter int unsigned Masters_Num   = 2,
    parameter int unsigned Address_width = 32,
    parameter int unsigned AXI4_AR_len   = 8,
    parameter int unsigned Num_Of_Slaves = 4
) (
    input  logic ACLK,
    input  logic ARESETN,

    // Masters side (arrays)
    input  logic [Masters_Num-1:0][Address_width-1:0]  S_AXI_araddr,
    input  logic [Masters_Num-1:0][AXI4_AR_len-1:0]    S_AXI_arlen,
    input  logic [Masters_Num-1:0][2:0]                S_AXI_arsize,
    input  logic [Masters_Num-1:0][1:0]                S_AXI_arburst,
    input  logic [Masters_Num-1:0][1:0]                S_AXI_arlock,
    input  logic [Masters_Num-1:0][3:0]                S_AXI_arcache,
    input  logic [Masters_Num-1:0][2:0]                S_AXI_arprot,
    input  logic [Masters_Num-1:0][3:0]                S_AXI_arqos,
    input  logic [Masters_Num-1:0][3:0]                S_AXI_arregion,
    input  logic [Masters_Num-1:0]                     S_AXI_arvalid,
    output logic [Masters_Num-1:0]                     S_AXI_arready,

    // Slaves side (arrays)
    output logic [Num_Of_Slaves-1:0][Address_width-1:0]  M_AXI_araddr,
    output logic [Num_Of_Slaves-1:0][AXI4_AR_len-1:0]    M_AXI_arlen,
    output logic [Num_Of_Slaves-1:0][2:0]                M_AXI_arsize,
    output logic [Num_Of_Slaves-1:0][1:0]                M_AXI_arburst,
    output logic [Num_Of_Slaves-1:0][1:0]                M_AXI_arlock,
    output logic [Num_Of_Slaves-1:0][3:0]                M_AXI_arcache,
    output logic [Num_Of_Slaves-1:0][2:0]                M_AXI_arprot,
    output logic [Num_Of_Slaves-1:0][3:0]                M_AXI_arqos,
    output logic [Num_Of_Slaves-1:0][3:0]                M_AXI_arregion,
    output logic [Num_Of_Slaves-1:0]                     M_AXI_arvalid,
    input  logic [Num_Of_Slaves-1:0]                     M_AXI_arready
);

    localparam int Masters_ID_Size = (Masters_Num > 1) ? $clog2(Masters_Num) : 1;

    // Arbiter inputs
    logic [Masters_Num-1:0]      m_valid;
    logic [Masters_Num-1:0][3:0] m_qos;

    // Arbiter outputs
    logic                        channel_req;
    logic [Masters_ID_Size-1:0]  sel_master;

    // Simple channel-grant and token model (always grant, no split)
    logic channel_granted;
    logic token;

    assign channel_granted = 1'b1;
    assign token           = 1'b0;

    // Connect arbiter inputs
    assign m_valid = S_AXI_arvalid;
    for (genvar i = 0; i < Masters_Num; i++) begin : gen_qos
        assign m_qos[i] = S_AXI_arqos[i];
    end

    // Instantiate general arbiter
    Read_Arbiter_General #(
        .Masters_Num(Masters_Num)
    ) u_read_arbiter_general (
        .ACLK            (ACLK),
        .ARESETN         (ARESETN),
        .M_arvalid       (m_valid),
        .M_arqos         (m_qos),
        .Channel_Granted (channel_granted),
        .Token           (token),
        .Channel_Request (channel_req),
        .Selected_Master (sel_master)
    );

    // Decode selected master's address to slaves
    logic [Address_width-1:0] sel_araddr;
    logic [AXI4_AR_len-1:0]   sel_arlen;
    logic [2:0]               sel_arsize;
    logic [1:0]               sel_arburst;
    logic [1:0]               sel_arlock;
    logic [3:0]               sel_arcache;
    logic [2:0]               sel_arprot;
    logic [3:0]               sel_arqos;
    logic [3:0]               sel_arregion;
    logic                     sel_arvalid;

    // Multiplex selected master signals
    always_comb begin
        sel_araddr   = '0;
        sel_arlen    = '0;
        sel_arsize   = '0;
        sel_arburst  = '0;
        sel_arlock   = '0;
        sel_arcache  = '0;
        sel_arprot   = '0;
        sel_arqos    = '0;
        sel_arregion = '0;
        sel_arvalid  = 1'b0;

        if (channel_req) begin
            sel_araddr   = S_AXI_araddr[sel_master];
            sel_arlen    = S_AXI_arlen[sel_master];
            sel_arsize   = S_AXI_arsize[sel_master];
            sel_arburst  = S_AXI_arburst[sel_master];
            sel_arlock   = S_AXI_arlock[sel_master];
            sel_arcache  = S_AXI_arcache[sel_master];
            sel_arprot   = S_AXI_arprot[sel_master];
            sel_arqos    = S_AXI_arqos[sel_master];
            sel_arregion = S_AXI_arregion[sel_master];
            sel_arvalid  = 1'b1;
        end
    end

    // Use general decoder to route to slaves
    Read_Addr_Channel_Dec_General #(
        .Address_width (Address_width),
        .AXI4_AR_len   (AXI4_AR_len),
        .Num_Of_Slaves (Num_Of_Slaves)
    ) u_read_addr_channel_dec_general (
        .araddr    (sel_araddr),
        .arlen     (sel_arlen),
        .arsize    (sel_arsize),
        .arburst   (sel_arburst),
        .arlock    (sel_arlock),
        .arcache   (sel_arcache),
        .arprot    (sel_arprot),
        .arqos     (sel_arqos),
        .arregion  (sel_arregion),
        .arvalid   (sel_arvalid),
        .S_arvalid (M_AXI_arvalid),
        .S_araddr  (M_AXI_araddr),
        .S_arlen   (M_AXI_arlen),
        .S_arsize  (M_AXI_arsize),
        .S_arburst (M_AXI_arburst),
        .S_arlock  (M_AXI_arlock),
        .S_arcache (M_AXI_arcache),
        .S_arprot  (M_AXI_arprot),
        .S_arqos   (M_AXI_arqos),
        .S_arregion(M_AXI_arregion),
        .Q_Enables (/* unused outside, equivalent to M_AXI_arvalid */)
    );

    // Simple ready signalling: broadcast OR of slave ready to all masters
    // (for real design, this should be replaced by full handshake tracking)
    always_comb begin
        S_AXI_arready = '0;
        if (channel_req) begin
            S_AXI_arready[sel_master] = |M_AXI_arready;
        end
    end

endmodule




















