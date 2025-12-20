// ==============================================================================
// AXI Master Aggregator
// ==============================================================================
// Aggregates multiple AXI4-Lite masters into a single master
// Uses round-robin arbitration to select which master gets access
//
// Architecture:
//   - Input: N AXI4-Lite masters (parameter NUM_MASTERS)
//   - Output: 1 AXI4-Lite master
//   - Arbitration: Round-Robin
// ==============================================================================

`timescale 1ns/1ps

module AXI_Master_Aggregator #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_MASTERS = 3  // Number of input masters to aggregate
)(
    input logic ACLK,
    input logic ARESETN,
    
    // ========================================================================
    // Input Masters (NUM_MASTERS masters)
    // ========================================================================
    // Master 0
    input logic [ADDR_WIDTH-1:0] M0_ARADDR,
    input logic [2:0]            M0_ARPROT,
    input logic                  M0_ARVALID,
    output logic                  M0_ARREADY,
    output logic [DATA_WIDTH-1:0] M0_RDATA,
    output logic [1:0]            M0_RRESP,
    output logic                  M0_RVALID,
    input logic                  M0_RREADY,
    
    input logic [ADDR_WIDTH-1:0] M0_AWADDR,
    input logic [2:0]            M0_AWPROT,
    input logic                  M0_AWVALID,
    output logic                  M0_AWREADY,
    input logic [DATA_WIDTH-1:0] M0_WDATA,
    input logic [DATA_WIDTH/8-1:0] M0_WSTRB,
    input logic                  M0_WVALID,
    output logic                  M0_WREADY,
    output logic [1:0]            M0_BRESP,
    output logic                  M0_BVALID,
    input logic                  M0_BREADY,
    
    // Master 1 (if NUM_MASTERS > 1)
    input logic [ADDR_WIDTH-1:0] M1_ARADDR,
    input logic [2:0]            M1_ARPROT,
    input logic                  M1_ARVALID,
    output logic                  M1_ARREADY,
    output logic [DATA_WIDTH-1:0] M1_RDATA,
    output logic [1:0]            M1_RRESP,
    output logic                  M1_RVALID,
    input logic                  M1_RREADY,
    
    input logic [ADDR_WIDTH-1:0] M1_AWADDR,
    input logic [2:0]            M1_AWPROT,
    input logic                  M1_AWVALID,
    output logic                  M1_AWREADY,
    input logic [DATA_WIDTH-1:0] M1_WDATA,
    input logic [DATA_WIDTH/8-1:0] M1_WSTRB,
    input logic                  M1_WVALID,
    output logic                  M1_WREADY,
    output logic [1:0]            M1_BRESP,
    output logic                  M1_BVALID,
    input logic                  M1_BREADY,
    
    // Master 2 (if NUM_MASTERS > 2)
    input logic [ADDR_WIDTH-1:0] M2_ARADDR,
    input logic [2:0]            M2_ARPROT,
    input logic                  M2_ARVALID,
    output logic                  M2_ARREADY,
    output logic [DATA_WIDTH-1:0] M2_RDATA,
    output logic [1:0]            M2_RRESP,
    output logic                  M2_RVALID,
    input logic                  M2_RREADY,
    
    input logic [ADDR_WIDTH-1:0] M2_AWADDR,
    input logic [2:0]            M2_AWPROT,
    input logic                  M2_AWVALID,
    output logic                  M2_AWREADY,
    input logic [DATA_WIDTH-1:0] M2_WDATA,
    input logic [DATA_WIDTH/8-1:0] M2_WSTRB,
    input logic                  M2_WVALID,
    output logic                  M2_WREADY,
    output logic [1:0]            M2_BRESP,
    output logic                  M2_BVALID,
    input logic                  M2_BREADY,
    
    // ========================================================================
    // Output Master (Single aggregated master)
    // ========================================================================
    // Read Address Channel
    output logic [ADDR_WIDTH-1:0] M_ARADDR,
    output logic [2:0]            M_ARPROT,
    output logic                  M_ARVALID,
    input logic                  M_ARREADY,
    // Read Data Channel
    input logic [DATA_WIDTH-1:0] M_RDATA,
    input logic [1:0]            M_RRESP,
    input logic                  M_RVALID,
    output logic                  M_RREADY,
    
    // Write Address Channel
    output logic [ADDR_WIDTH-1:0] M_AWADDR,
    output logic [2:0]            M_AWPROT,
    output logic                  M_AWVALID,
    input logic                  M_AWREADY,
    // Write Data Channel
    output logic [DATA_WIDTH-1:0] M_WDATA,
    output logic [DATA_WIDTH/8-1:0] M_WSTRB,
    output logic                  M_WVALID,
    input logic                  M_WREADY,
    // Write Response Channel
    input logic [1:0]            M_BRESP,
    input logic                  M_BVALID,
    output logic                  M_BREADY
);

// ==============================================================================
// Internal Signals
// ==============================================================================
// Read arbitration
logic [$clog2(NUM_MASTERS)-1:0] read_arb_sel;
logic read_transaction_active;
logic [$clog2(NUM_MASTERS)-1:0] read_master_id;

// Write arbitration
logic [$clog2(NUM_MASTERS)-1:0] write_arb_sel;
logic write_transaction_active;
logic [$clog2(NUM_MASTERS)-1:0] write_master_id;

// ==============================================================================
// Read Address Channel Arbitration (Round-Robin)
// ==============================================================================
always_ff @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        read_arb_sel <= 0;
        read_transaction_active <= 1'b0;
        read_master_id <= 0;
    end else begin
        if (!read_transaction_active) begin
            // Check for read requests in round-robin order
            if (M0_ARVALID) begin
                read_master_id <= 0;
                read_transaction_active <= 1'b1;
            end else if (NUM_MASTERS > 1 && M1_ARVALID) begin
                read_master_id <= 1;
                read_transaction_active <= 1'b1;
            end else if (NUM_MASTERS > 2 && M2_ARVALID) begin
                read_master_id <= 2;
                read_transaction_active <= 1'b1;
            end
            
            // Update round-robin pointer
            if (M0_ARVALID || (NUM_MASTERS > 1 && M1_ARVALID) || (NUM_MASTERS > 2 && M2_ARVALID)) begin
                read_arb_sel <= (read_arb_sel + 1) % NUM_MASTERS;
            end
        end else if (M_ARREADY && M_ARVALID) begin
            read_transaction_active <= 1'b0;
        end
    end
end

// Read Address Mux
assign M_ARADDR = (read_master_id == 0) ? M0_ARADDR :
                  (read_master_id == 1) ? M1_ARADDR :
                  M2_ARADDR;
assign M_ARPROT = (read_master_id == 0) ? M0_ARPROT :
                  (read_master_id == 1) ? M1_ARPROT :
                  M2_ARPROT;
assign M_ARVALID = (read_master_id == 0) ? M0_ARVALID :
                   (read_master_id == 1) ? M1_ARVALID :
                   (read_master_id == 2) ? M2_ARVALID : 1'b0;

assign M0_ARREADY = (read_master_id == 0) ? M_ARREADY : 1'b0;
assign M1_ARREADY = (read_master_id == 1) ? M_ARREADY : 1'b0;
assign M2_ARREADY = (read_master_id == 2) ? M_ARREADY : 1'b0;

// Read Data Demux
assign M0_RDATA = (read_master_id == 0) ? M_RDATA : {DATA_WIDTH{1'b0}};
assign M1_RDATA = (read_master_id == 1) ? M_RDATA : {DATA_WIDTH{1'b0}};
assign M2_RDATA = (read_master_id == 2) ? M_RDATA : {DATA_WIDTH{1'b0}};
assign M0_RRESP = (read_master_id == 0) ? M_RRESP : 2'b0;
assign M1_RRESP = (read_master_id == 1) ? M_RRESP : 2'b0;
assign M2_RRESP = (read_master_id == 2) ? M_RRESP : 2'b0;
assign M0_RVALID = (read_master_id == 0) ? M_RVALID : 1'b0;
assign M1_RVALID = (read_master_id == 1) ? M_RVALID : 1'b0;
assign M2_RVALID = (read_master_id == 2) ? M_RVALID : 1'b0;
assign M_RREADY = (read_master_id == 0) ? M0_RREADY :
                  (read_master_id == 1) ? M1_RREADY :
                  (read_master_id == 2) ? M2_RREADY : 1'b0;

// ==============================================================================
// Write Address Channel Arbitration (Round-Robin)
// ==============================================================================
always_ff @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        write_arb_sel <= 0;
        write_transaction_active <= 1'b0;
        write_master_id <= 0;
    end else begin
        if (!write_transaction_active) begin
            // Check for write requests in round-robin order
            if (M0_AWVALID && M0_WVALID) begin
                write_master_id <= 0;
                write_transaction_active <= 1'b1;
            end else if (NUM_MASTERS > 1 && M1_AWVALID && M1_WVALID) begin
                write_master_id <= 1;
                write_transaction_active <= 1'b1;
            end else if (NUM_MASTERS > 2 && M2_AWVALID && M2_WVALID) begin
                write_master_id <= 2;
                write_transaction_active <= 1'b1;
            end
            
            // Update round-robin pointer
            if ((M0_AWVALID && M0_WVALID) || 
                (NUM_MASTERS > 1 && M1_AWVALID && M1_WVALID) ||
                (NUM_MASTERS > 2 && M2_AWVALID && M2_WVALID)) begin
                write_arb_sel <= (write_arb_sel + 1) % NUM_MASTERS;
            end
        end else if (M_AWREADY && M_AWVALID && M_WREADY && M_WVALID) begin
            write_transaction_active <= 1'b0;
        end
    end
end

// Write Address Mux
assign M_AWADDR = (write_master_id == 0) ? M0_AWADDR :
                  (write_master_id == 1) ? M1_AWADDR :
                  M2_AWADDR;
assign M_AWPROT = (write_master_id == 0) ? M0_AWPROT :
                  (write_master_id == 1) ? M1_AWPROT :
                  M2_AWPROT;
assign M_AWVALID = (write_master_id == 0) ? M0_AWVALID :
                   (write_master_id == 1) ? M1_AWVALID :
                   (write_master_id == 2) ? M2_AWVALID : 1'b0;

assign M0_AWREADY = (write_master_id == 0) ? M_AWREADY : 1'b0;
assign M1_AWREADY = (write_master_id == 1) ? M_AWREADY : 1'b0;
assign M2_AWREADY = (write_master_id == 2) ? M_AWREADY : 1'b0;

// Write Data Mux
assign M_WDATA = (write_master_id == 0) ? M0_WDATA :
                 (write_master_id == 1) ? M1_WDATA :
                 M2_WDATA;
assign M_WSTRB = (write_master_id == 0) ? M0_WSTRB :
                 (write_master_id == 1) ? M1_WSTRB :
                 M2_WSTRB;
assign M_WVALID = (write_master_id == 0) ? M0_WVALID :
                  (write_master_id == 1) ? M1_WVALID :
                  (write_master_id == 2) ? M2_WVALID : 1'b0;

assign M0_WREADY = (write_master_id == 0) ? M_WREADY : 1'b0;
assign M1_WREADY = (write_master_id == 1) ? M_WREADY : 1'b0;
assign M2_WREADY = (write_master_id == 2) ? M_WREADY : 1'b0;

// Write Response Demux
assign M0_BRESP = (write_master_id == 0) ? M_BRESP : 2'b0;
assign M1_BRESP = (write_master_id == 1) ? M_BRESP : 2'b0;
assign M2_BRESP = (write_master_id == 2) ? M_BRESP : 2'b0;
assign M0_BVALID = (write_master_id == 0) ? M_BVALID : 1'b0;
assign M1_BVALID = (write_master_id == 1) ? M_BVALID : 1'b0;
assign M2_BVALID = (write_master_id == 2) ? M_BVALID : 1'b0;
assign M_BREADY = (write_master_id == 0) ? M0_BREADY :
                  (write_master_id == 1) ? M1_BREADY :
                  (write_master_id == 2) ? M2_BREADY : 1'b0;

endmodule

