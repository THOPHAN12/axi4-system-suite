// Extracted aggregators block for dual_pipeline_serv_axi_system
// 4 masters (pipeline + serv, instr/data) -> 2 masters (AGG0 instr, AGG1 data)

`timescale 1ns/1ps
`include "../axi_interconnect/rtl/core/AXI_Master_Aggregator.v"

module dual_pipeline_serv_aggregators #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESETN,
    // Inputs from cores
    // Pipeline instr
    input  wire [ADDR_WIDTH-1:0] P_M_ARADDR,
    input  wire                  P_M_ARVALID,
    output wire                  P_M_ARREADY,
    output wire [DATA_WIDTH-1:0] P_M_RDATA,
    output wire [1:0]            P_M_RRESP,
    output wire                  P_M_RVALID,
    input  wire                  P_M_RREADY,
    // Pipeline data
    input  wire [ADDR_WIDTH-1:0] P_M_AWADDR,
    input  wire [DATA_WIDTH-1:0] P_M_WDATA,
    input  wire [3:0]            P_M_WSTRB,
    input  wire                  P_M_AWVALID,
    output wire                  P_M_AWREADY,
    input  wire                  P_M_WVALID,
    output wire                  P_M_WREADY,
    output wire [1:0]            P_M_BRESP,
    output wire                  P_M_BVALID,
    input  wire                  P_M_BREADY,
    input  wire [ADDR_WIDTH-1:0] P_M_ARADDR_D,
    input  wire                  P_M_ARVALID_D,
    output wire                  P_M_ARREADY_D,
    output wire [DATA_WIDTH-1:0] P_M_RDATA_D,
    output wire [1:0]            P_M_RRESP_D,
    output wire                  P_M_RVALID_D,
    input  wire                  P_M_RREADY_D,
    // Serv instr
    input  wire [ADDR_WIDTH-1:0] S_M_ARADDR,
    input  wire                  S_M_ARVALID,
    output wire                  S_M_ARREADY,
    output wire [DATA_WIDTH-1:0] S_M_RDATA,
    output wire [1:0]            S_M_RRESP,
    output wire                  S_M_RVALID,
    input  wire                  S_M_RREADY,
    // Serv data
    input  wire [ADDR_WIDTH-1:0] S_M_AWADDR,
    input  wire [DATA_WIDTH-1:0] S_M_WDATA,
    input  wire [3:0]            S_M_WSTRB,
    input  wire                  S_M_AWVALID,
    output wire                  S_M_AWREADY,
    input  wire                  S_M_WVALID,
    output wire                  S_M_WREADY,
    output wire [1:0]            S_M_BRESP,
    output wire                  S_M_BVALID,
    input  wire                  S_M_BREADY,
    input  wire [ADDR_WIDTH-1:0] S_M_ARADDR_D,
    input  wire                  S_M_ARVALID_D,
    output wire                  S_M_ARREADY_D,
    output wire [DATA_WIDTH-1:0] S_M_RDATA_D,
    output wire [1:0]            S_M_RRESP_D,
    output wire                  S_M_RVALID_D,
    input  wire                  S_M_RREADY_D,

    // Outputs aggregated
    output wire [ADDR_WIDTH-1:0] AGG0_ARADDR,
    output wire                  AGG0_ARVALID,
    input  wire                  AGG0_ARREADY,
    input  wire [DATA_WIDTH-1:0] AGG0_RDATA,
    input  wire [1:0]            AGG0_RRESP,
    input  wire                  AGG0_RVALID,
    output wire                  AGG0_RREADY,

    output wire [ADDR_WIDTH-1:0] AGG1_AWADDR,
    output wire [DATA_WIDTH-1:0] AGG1_WDATA,
    output wire [3:0]            AGG1_WSTRB,
    output wire                  AGG1_AWVALID,
    input  wire                  AGG1_AWREADY,
    output wire                  AGG1_WVALID,
    input  wire                  AGG1_WREADY,
    input  wire [1:0]            AGG1_BRESP,
    input  wire                  AGG1_BVALID,
    output wire                  AGG1_BREADY,
    output wire [ADDR_WIDTH-1:0] AGG1_ARADDR,
    output wire                  AGG1_ARVALID,
    input  wire                  AGG1_ARREADY,
    input  wire [DATA_WIDTH-1:0] AGG1_RDATA,
    input  wire [1:0]            AGG1_RRESP,
    input  wire                  AGG1_RVALID,
    output wire                  AGG1_RREADY
);

// Instr aggregator: 2->1 (AGG0)
AXI_Master_Aggregator #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_MASTERS(2)
) u_instr_agg (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // M0 = pipeline instr
    .M0_ARADDR(P_M_ARADDR), .M0_ARPROT(3'b000), .M0_ARVALID(P_M_ARVALID), .M0_ARREADY(P_M_ARREADY),
    .M0_RDATA(P_M_RDATA), .M0_RRESP(P_M_RRESP), .M0_RVALID(P_M_RVALID), .M0_RREADY(P_M_RREADY),
    .M0_AWADDR(32'h0), .M0_AWPROT(3'b0), .M0_AWVALID(1'b0), .M0_AWREADY(),
    .M0_WDATA(32'h0), .M0_WSTRB(4'h0), .M0_WVALID(1'b0), .M0_WREADY(),
    .M0_BRESP(), .M0_BVALID(), .M0_BREADY(1'b0),
    // M1 = serv instr
    .M1_ARADDR(S_M_ARADDR), .M1_ARPROT(3'b000), .M1_ARVALID(S_M_ARVALID), .M1_ARREADY(S_M_ARREADY),
    .M1_RDATA(S_M_RDATA), .M1_RRESP(S_M_RRESP), .M1_RVALID(S_M_RVALID), .M1_RREADY(S_M_RREADY),
    .M1_AWADDR(32'h0), .M1_AWPROT(3'b0), .M1_AWVALID(1'b0), .M1_AWREADY(),
    .M1_WDATA(32'h0), .M1_WSTRB(4'h0), .M1_WVALID(1'b0), .M1_WREADY(),
    .M1_BRESP(), .M1_BVALID(), .M1_BREADY(1'b0),
    // Unused M2
    .M2_ARADDR(32'h0), .M2_ARPROT(3'b0), .M2_ARVALID(1'b0), .M2_ARREADY(),
    .M2_RDATA(), .M2_RRESP(), .M2_RVALID(), .M2_RREADY(1'b0),
    .M2_AWADDR(32'h0), .M2_AWPROT(3'b0), .M2_AWVALID(1'b0), .M2_AWREADY(),
    .M2_WDATA(32'h0), .M2_WSTRB(4'h0), .M2_WVALID(1'b0), .M2_WREADY(),
    .M2_BRESP(), .M2_BVALID(), .M2_BREADY(1'b0),
    // Out
    .M_ARADDR(AGG0_ARADDR),
    .M_ARPROT(),
    .M_ARVALID(AGG0_ARVALID),
    .M_ARREADY(AGG0_ARREADY),
    .M_RDATA(AGG0_RDATA),
    .M_RRESP(AGG0_RRESP),
    .M_RVALID(AGG0_RVALID),
    .M_RREADY(AGG0_RREADY),
    .M_AWADDR(), .M_AWPROT(), .M_AWVALID(), .M_AWREADY(1'b0),
    .M_WDATA(), .M_WSTRB(), .M_WVALID(), .M_WREADY(1'b0),
    .M_BRESP(2'b0), .M_BVALID(1'b0), .M_BREADY()
);

// Data aggregator: 2->1 (AGG1)
AXI_Master_Aggregator #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUM_MASTERS(2)
) u_data_agg (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // M0 = pipeline data
    .M0_ARADDR(P_M_ARADDR_D), .M0_ARPROT(3'b000), .M0_ARVALID(P_M_ARVALID_D), .M0_ARREADY(P_M_ARREADY_D),
    .M0_RDATA(P_M_RDATA_D), .M0_RRESP(P_M_RRESP_D), .M0_RVALID(P_M_RVALID_D), .M0_RREADY(P_M_RREADY_D),
    .M0_AWADDR(P_M_AWADDR), .M0_AWPROT(3'b000), .M0_AWVALID(P_M_AWVALID_D), .M0_AWREADY(P_M_AWREADY_D),
    .M0_WDATA(P_M_WDATA_D), .M0_WSTRB(P_M_WSTRB_D), .M0_WVALID(P_M_WVALID_D), .M0_WREADY(P_M_WREADY_D),
    .M0_BRESP(P_M_BRESP_D), .M0_BVALID(P_M_BVALID_D), .M0_BREADY(P_M_BREADY_D),
    // M1 = serv data
    .M1_ARADDR(S_M_ARADDR_D), .M1_ARPROT(3'b000), .M1_ARVALID(S_M_ARVALID_D), .M1_ARREADY(S_M_ARREADY_D),
    .M1_RDATA(S_M_RDATA_D), .M1_RRESP(S_M_RRESP_D), .M1_RVALID(S_M_RVALID_D), .M1_RREADY(S_M_RREADY_D),
    .M1_AWADDR(S_M_AWADDR), .M1_AWPROT(3'b000), .M1_AWVALID(S_M_AWVALID_D), .M1_AWREADY(S_M_AWREADY_D),
    .M1_WDATA(S_M_WDATA_D), .M1_WSTRB(S_M_WSTRB_D), .M1_WVALID(S_M_WVALID_D), .M1_WREADY(S_M_WREADY_D),
    .M1_BRESP(S_M_BRESP_D), .M1_BVALID(S_M_BVALID_D), .M1_BREADY(S_M_BREADY_D),
    // Unused M2
    .M2_ARADDR(32'h0), .M2_ARPROT(3'b0), .M2_ARVALID(1'b0), .M2_ARREADY(),
    .M2_RDATA(), .M2_RRESP(), .M2_RVALID(), .M2_RREADY(1'b0),
    .M2_AWADDR(32'h0), .M2_AWPROT(3'b0), .M2_AWVALID(1'b0), .M2_AWREADY(),
    .M2_WDATA(32'h0), .M2_WSTRB(4'h0), .M2_WVALID(1'b0), .M2_WREADY(),
    .M2_BRESP(), .M2_BVALID(), .M2_BREADY(1'b0),
    // Out
    .M_ARADDR(AGG1_ARADDR),
    .M_ARPROT(),
    .M_ARVALID(AGG1_ARVALID),
    .M_ARREADY(AGG1_ARREADY),
    .M_RDATA(AGG1_RDATA),
    .M_RRESP(AGG1_RRESP),
    .M_RVALID(AGG1_RVALID),
    .M_RREADY(AGG1_RREADY),
    .M_AWADDR(AGG1_AWADDR),
    .M_AWPROT(),
    .M_AWVALID(AGG1_AWVALID),
    .M_AWREADY(AGG1_AWREADY),
    .M_WDATA(AGG1_WDATA),
    .M_WSTRB(AGG1_WSTRB),
    .M_WVALID(AGG1_WVALID),
    .M_WREADY(AGG1_WREADY),
    .M_BRESP(AGG1_BRESP),
    .M_BVALID(AGG1_BVALID),
    .M_BREADY(AGG1_BREADY)
);

endmodule

