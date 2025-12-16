// ==============================================================================
// AXI Master 1 - Dependency Master
// ==============================================================================
// This master waits for M0 to complete, reads result from S0, and sends to S1
// Features:
//   - Wait for M0 to complete (external signal)
//   - Read result from S0[0]
//   - Use result as address offset
//   - Write data to S1 at (S1_BASE + offset)
//   - Output busy signal when not in IDLE
// ==============================================================================

`timescale 1ns/1ps

module axi_master_1 #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter SLAVE0_BASE = 32'h00000000,
    parameter SLAVE1_BASE = 32'h40000000
)(
    input wire ACLK,
    input wire ARESETN,
    
    // Control signals
    input  wire start,
    input  wire m0_completed,  // Signal from M0 indicating completion
    output reg  completed,
    output wire busy,
    
    // AXI4-Lite Master Interface
    // Read Address Channel (to S0)
    output reg  [ADDR_WIDTH-1:0] M_AXI_araddr,
    output reg  [2:0]            M_AXI_arprot,
    output reg                   M_AXI_arvalid,
    input  wire                  M_AXI_arready,
    
    // Read Data Channel (from S0)
    input  wire [DATA_WIDTH-1:0] M_AXI_rdata,
    input  wire [1:0]            M_AXI_rresp,
    input  wire                  M_AXI_rvalid,
    output reg                   M_AXI_rready,
    
    // Write Address Channel (to S1)
    output reg  [ADDR_WIDTH-1:0] M_AXI_awaddr,
    output reg  [2:0]            M_AXI_awprot,
    output reg                   M_AXI_awvalid,
    input  wire                  M_AXI_awready,
    
    // Write Data Channel (to S1)
    output reg  [DATA_WIDTH-1:0] M_AXI_wdata,
    output reg  [DATA_WIDTH/8-1:0] M_AXI_wstrb,
    output reg                   M_AXI_wvalid,
    input  wire                  M_AXI_wready,
    
    // Write Response Channel (from S1)
    input  wire [1:0]            M_AXI_bresp,
    input  wire                  M_AXI_bvalid,
    output reg                   M_AXI_bready,
    
    // Internal signals
    output reg  [31:0] address_offset
);

    // State machine
    reg [2:0] state;
    localparam IDLE        = 3'b000;
    localparam WAIT_M0     = 3'b001;
    localparam READ_S0_REQ = 3'b010;
    localparam READ_S0_WAIT = 3'b011;
    localparam SEND_REQ    = 3'b100;
    localparam SEND_WAIT   = 3'b101;
    localparam DONE        = 3'b110;
    
    // Flags to track AW and W handshake completion
    reg aw_handshake_done;
    reg w_handshake_done;
    
    // Busy signal: high when not in IDLE state
    assign busy = (state != IDLE);
    
    // State machine
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
            M_AXI_araddr <= 32'h0;
            M_AXI_arprot <= 3'b000;
            M_AXI_arvalid <= 1'b0;
            M_AXI_rready <= 1'b0;
            M_AXI_awaddr <= 32'h0;
            M_AXI_awprot <= 3'b000;
            M_AXI_awvalid <= 1'b0;
            M_AXI_wdata <= 32'h0;
            M_AXI_wstrb <= 4'b0000;
            M_AXI_wvalid <= 1'b0;
            M_AXI_bready <= 1'b0;
            address_offset <= 32'h0;
            completed <= 1'b0;
            aw_handshake_done <= 1'b0;
            w_handshake_done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_rready <= 1'b0;
                    M_AXI_awvalid <= 1'b0;
                    M_AXI_wvalid <= 1'b0;
                    M_AXI_bready <= 1'b0;
                    completed <= 1'b0;
                    aw_handshake_done <= 1'b0;
                    w_handshake_done <= 1'b0;
                    if (start) begin
                        state <= WAIT_M0;
                    end
                end
                
                WAIT_M0: begin
                    if (m0_completed) begin
                        state <= READ_S0_REQ;
                    end
                end
                
                READ_S0_REQ: begin
                    M_AXI_araddr <= SLAVE0_BASE + 32'h00000000;  // Read result from S0[0]
                    M_AXI_arprot <= 3'b000;
                    M_AXI_arvalid <= 1'b1;
                    if (M_AXI_arready) begin
                        state <= READ_S0_WAIT;
                        M_AXI_arvalid <= 1'b0;
                    end
                end
                
                READ_S0_WAIT: begin
                    M_AXI_rready <= 1'b1;
                    if (M_AXI_rvalid && M_AXI_rready) begin
                        address_offset <= M_AXI_rdata;
                        state <= SEND_REQ;
                        M_AXI_rready <= 1'b0;
                    end
                end
                
                SEND_REQ: begin
                    // Use address_offset as offset to S1 base address
                    // Set address and data on first cycle, keep valid high until handshake
                    if (!aw_handshake_done) begin
                        M_AXI_awaddr <= SLAVE1_BASE + address_offset;
                        M_AXI_awprot <= 3'b000;
                        M_AXI_awvalid <= 1'b1;
                    end else begin
                        M_AXI_awvalid <= 1'b0;
                    end
                    
                    if (!w_handshake_done) begin
                        M_AXI_wdata <= 32'hCAFEBABE;  // Test data
                        M_AXI_wstrb <= 4'b1111;
                        M_AXI_wvalid <= 1'b1;
                    end else begin
                        M_AXI_wvalid <= 1'b0;
                    end
                    
                    // Track AW handshake completion
                    if (M_AXI_awvalid && M_AXI_awready && !aw_handshake_done) begin
                        aw_handshake_done <= 1'b1;
                    end
                    
                    // Track W handshake completion
                    if (M_AXI_wvalid && M_AXI_wready && !w_handshake_done) begin
                        w_handshake_done <= 1'b1;
                    end
                    
                    // Move to next state when both handshakes are complete
                    if (aw_handshake_done && w_handshake_done) begin
                        state <= SEND_WAIT;
                    end
                end
                
                SEND_WAIT: begin
                    M_AXI_bready <= 1'b1;
                    if (M_AXI_bvalid && M_AXI_bready) begin
                        state <= DONE;
                        M_AXI_bready <= 1'b0;
                    end
                end
                
                DONE: begin
                    state <= IDLE;
                    completed <= 1'b1;
                end
            endcase
        end
    end

endmodule










