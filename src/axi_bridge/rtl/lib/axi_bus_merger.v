/*
 * axi_bus_merger.v - AXI Bus Merger Component
 * 
 * Purpose: Merges two AXI master interfaces into one
 * Used for combining instruction and data buses
 * 
 * Features:
 * - Fixed priority arbitration (M1 > M0)
 * - Non-blocking operation
 * - Minimal latency
 * 
 * Priority: M1 (Data bus) has higher priority than M0 (Instruction bus)
 * Rationale: Data accesses are usually time-critical
 */

module axi_bus_merger #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // ========================================================================
    // Master 0 (Lower priority - typically instruction bus)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   M0_awaddr,
    input  wire                    M0_awvalid,
    output wire                    M0_awready,
    input  wire [DATA_WIDTH-1:0]   M0_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] M0_wstrb,
    input  wire                    M0_wvalid,
    output wire                    M0_wready,
    output wire                    M0_bvalid,
    input  wire                    M0_bready,
    input  wire [ADDR_WIDTH-1:0]   M0_araddr,
    input  wire                    M0_arvalid,
    output wire                    M0_arready,
    output wire [DATA_WIDTH-1:0]   M0_rdata,
    output wire                    M0_rvalid,
    input  wire                    M0_rready,
    
    // ========================================================================
    // Master 1 (Higher priority - typically data bus)
    // ========================================================================
    input  wire [ADDR_WIDTH-1:0]   M1_awaddr,
    input  wire                    M1_awvalid,
    output wire                    M1_awready,
    input  wire [DATA_WIDTH-1:0]   M1_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] M1_wstrb,
    input  wire                    M1_wvalid,
    output wire                    M1_wready,
    output wire                    M1_bvalid,
    input  wire                    M1_bready,
    input  wire [ADDR_WIDTH-1:0]   M1_araddr,
    input  wire                    M1_arvalid,
    output wire                    M1_arready,
    output wire [DATA_WIDTH-1:0]   M1_rdata,
    output wire                    M1_rvalid,
    input  wire                    M1_rready,
    
    // ========================================================================
    // Slave Output (Merged)
    // ========================================================================
    output wire [ADDR_WIDTH-1:0]   S_awaddr,
    output wire                    S_awvalid,
    input  wire                    S_awready,
    output wire [DATA_WIDTH-1:0]   S_wdata,
    output wire [(DATA_WIDTH/8)-1:0] S_wstrb,
    output wire                    S_wlast,
    output wire                    S_wvalid,
    input  wire                    S_wready,
    input  wire [1:0]              S_bresp,
    input  wire                    S_bvalid,
    output wire                    S_bready,
    output wire [ADDR_WIDTH-1:0]   S_araddr,
    output wire                    S_arvalid,
    input  wire                    S_arready,
    input  wire [DATA_WIDTH-1:0]   S_rdata,
    input  wire [1:0]              S_rresp,
    input  wire                    S_rlast,
    input  wire                    S_rvalid,
    output wire                    S_rready
);

    // ========================================================================
    // Arbitration Logic - Fixed Priority (M1 > M0)
    // ========================================================================
    
    // Write address channel - Priority to M1
    assign S_awaddr  = M1_awvalid ? M1_awaddr  : M0_awaddr;
    assign S_awvalid = M1_awvalid | M0_awvalid;
    assign M1_awready = M1_awvalid ? S_awready : 1'b0;
    assign M0_awready = M1_awvalid ? 1'b0 : S_awready;
    
    // Write data channel - Priority to M1
    assign S_wdata  = M1_wvalid ? M1_wdata : M0_wdata;
    assign S_wstrb  = M1_wvalid ? M1_wstrb : M0_wstrb;
    assign S_wlast  = 1'b1;  // Always single transfer
    assign S_wvalid = M1_wvalid | M0_wvalid;
    assign M1_wready = M1_wvalid ? S_wready : 1'b0;
    assign M0_wready = M1_wvalid ? 1'b0 : S_wready;
    
    // Write response channel - Route back to requesting master
    reg resp_to_m1;  // Track which master made the write request
    
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            resp_to_m1 <= 1'b0;
        end else if (S_awvalid && S_awready) begin
            resp_to_m1 <= M1_awvalid;  // Remember who made the request
        end
    end
    
    assign S_bready = resp_to_m1 ? M1_bready : M0_bready;
    assign M1_bvalid = resp_to_m1 ? S_bvalid : 1'b0;
    assign M0_bvalid = resp_to_m1 ? 1'b0 : S_bvalid;
    
    // Read address channel - Priority to M1
    assign S_araddr  = M1_arvalid ? M1_araddr : M0_araddr;
    assign S_arvalid = M1_arvalid | M0_arvalid;
    assign M1_arready = M1_arvalid ? S_arready : 1'b0;
    assign M0_arready = M1_arvalid ? 1'b0 : S_arready;
    
    // Read data channel - Route back to requesting master
    reg rdata_to_m1;  // Track which master made the read request
    
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            rdata_to_m1 <= 1'b0;
        end else if (S_arvalid && S_arready) begin
            rdata_to_m1 <= M1_arvalid;  // Remember who made the request
        end
    end
    
    assign S_rready = rdata_to_m1 ? M1_rready : M0_rready;
    assign M1_rvalid = rdata_to_m1 ? S_rvalid : 1'b0;
    assign M0_rvalid = rdata_to_m1 ? 1'b0 : S_rvalid;
    assign M1_rdata = S_rdata;
    assign M0_rdata = S_rdata;

endmodule

