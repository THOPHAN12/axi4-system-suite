/*
 * wb_to_axi_addr_channel.v - Wishbone to AXI Address Channel Converter
 * 
 * Purpose: Reusable component for converting Wishbone address phase to AXI address channel
 * Can be used for both AR (Read) and AW (Write) channels
 * 
 * Features:
 * - Handles address handshake
 * - Supports burst configuration
 * - Configurable for READ or WRITE channel
 * - Lightweight FSM
 */

module wb_to_axi_addr_channel #(
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter CHANNEL    = "READ"  // "READ" for AR channel, "WRITE" for AW channel
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Wishbone Address Interface (from CPU)
    input  wire [ADDR_WIDTH-1:0]   wb_adr,
    input  wire                    wb_cyc,
    input  wire                    wb_stb,
    output reg                     addr_ready,   // Address accepted
    
    // AXI Address Channel (AR or AW)
    output reg  [ID_WIDTH-1:0]     axi_axid,
    output reg  [ADDR_WIDTH-1:0]   axi_axaddr,
    output reg  [7:0]              axi_axlen,    // Burst length
    output reg  [2:0]              axi_axsize,   // Burst size
    output reg  [1:0]              axi_axburst,  // Burst type
    output reg  [1:0]              axi_axlock,   // Lock type
    output reg  [3:0]              axi_axcache,  // Cache type
    output reg  [2:0]              axi_axprot,   // Protection type
    output reg  [3:0]              axi_axqos,    // QoS
    output reg  [3:0]              axi_axregion, // Region
    output reg                     axi_axvalid,
    input  wire                    axi_axready
);

    // FSM States
    localparam IDLE     = 2'b00;
    localparam ADDR_REQ = 2'b01;
    localparam WAIT_ACK = 2'b10;

    reg [1:0] state, next_state;
    reg [ADDR_WIDTH-1:0] addr_latch;

    // State register
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (wb_cyc && wb_stb) begin
                    next_state = ADDR_REQ;
                end
            end
            
            ADDR_REQ: begin
                if (axi_axready) begin
                    next_state = IDLE;
                end else begin
                    next_state = WAIT_ACK;
                end
            end
            
            WAIT_ACK: begin
                if (axi_axready) begin
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Address latch
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            addr_latch <= {ADDR_WIDTH{1'b0}};
        end else if (state == IDLE && wb_cyc && wb_stb) begin
            addr_latch <= wb_adr;
        end
    end

    // AXI Address Channel outputs
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            axi_axid     <= {ID_WIDTH{1'b0}};
            axi_axaddr   <= {ADDR_WIDTH{1'b0}};
            axi_axlen    <= 8'h00;       // Single transfer
            axi_axsize   <= 3'b010;      // 4 bytes (32-bit)
            axi_axburst  <= 2'b01;       // INCR
            axi_axlock   <= 2'b00;       // Normal
            axi_axcache  <= 4'b0011;     // Bufferable
            axi_axprot   <= 3'b000;      // Data, secure, unprivileged
            axi_axqos    <= 4'h0;        // No QoS
            axi_axregion <= 4'h0;        // Default region
            axi_axvalid  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    axi_axvalid <= 1'b0;
                    if (wb_cyc && wb_stb) begin
                        axi_axaddr  <= wb_adr;
                        axi_axvalid <= 1'b1;
                    end
                end
                
                ADDR_REQ: begin
                    axi_axaddr  <= addr_latch;
                    axi_axvalid <= 1'b1;
                    if (axi_axready) begin
                        axi_axvalid <= 1'b0;
                    end
                end
                
                WAIT_ACK: begin
                    axi_axaddr  <= addr_latch;
                    axi_axvalid <= 1'b1;
                    if (axi_axready) begin
                        axi_axvalid <= 1'b0;
                    end
                end
                
                default: begin
                    axi_axvalid <= 1'b0;
                end
            endcase
        end
    end

    // Address ready signal (to upper level)
    always @(*) begin
        addr_ready = (state == ADDR_REQ && axi_axready) || 
                     (state == WAIT_ACK && axi_axready);
    end

endmodule

