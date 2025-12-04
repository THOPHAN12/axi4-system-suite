/*
 * wb_to_axi_resp_handler.v - AXI Response to Wishbone Acknowledge Converter
 * 
 * Purpose: Reusable component for handling AXI write response (B channel)
 * Converts AXI BRESP to Wishbone ACK signal
 * 
 * Features:
 * - Handles write response handshake
 * - Error detection and reporting
 * - Configurable timeout
 */

module wb_to_axi_resp_handler #(
    parameter ID_WIDTH = 4,
    parameter ENABLE_ERROR_CHECK = 1'b1
) (
    input  wire                ACLK,
    input  wire                ARESETN,
    
    // Control signals
    input  wire                resp_expected,  // Expecting a response
    output reg                 resp_received,  // Response received
    output reg                 resp_error,     // Error occurred
    
    // AXI Write Response Channel (B)
    input  wire [ID_WIDTH-1:0] axi_bid,
    input  wire [1:0]          axi_bresp,
    input  wire                axi_bvalid,
    output reg                 axi_bready,
    
    // Wishbone Acknowledge
    output reg                 wb_ack
);

    // FSM States
    localparam IDLE      = 2'b00;
    localparam WAIT_RESP = 2'b01;
    localparam RESP_RCV  = 2'b10;
    localparam ERROR     = 2'b11;

    reg [1:0] state, next_state;
    reg [1:0] bresp_latch;

    // AXI Response codes
    localparam RESP_OKAY   = 2'b00;
    localparam RESP_EXOKAY = 2'b01;
    localparam RESP_SLVERR = 2'b10;
    localparam RESP_DECERR = 2'b11;

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
                if (resp_expected) begin
                    next_state = WAIT_RESP;
                end
            end
            
            WAIT_RESP: begin
                if (axi_bvalid) begin
                    if (ENABLE_ERROR_CHECK && (axi_bresp == RESP_SLVERR || axi_bresp == RESP_DECERR)) begin
                        next_state = ERROR;
                    end else begin
                        next_state = RESP_RCV;
                    end
                end
            end
            
            RESP_RCV: begin
                next_state = IDLE;
            end
            
            ERROR: begin
                next_state = IDLE;  // Return to idle after error
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Response latch
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            bresp_latch <= 2'b00;
        end else if (state == WAIT_RESP && axi_bvalid) begin
            bresp_latch <= axi_bresp;
        end
    end

    // AXI bready signal
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            axi_bready <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    axi_bready <= 1'b0;
                end
                
                WAIT_RESP: begin
                    axi_bready <= 1'b1;  // Ready to receive response
                end
                
                RESP_RCV, ERROR: begin
                    axi_bready <= 1'b0;
                end
                
                default: begin
                    axi_bready <= 1'b0;
                end
            endcase
        end
    end

    // Response received flag
    always @(*) begin
        resp_received = (state == RESP_RCV) || (state == ERROR);
    end

    // Error flag
    always @(*) begin
        resp_error = (state == ERROR);
    end

    // Wishbone acknowledge
    always @(*) begin
        wb_ack = (state == RESP_RCV);  // ACK when response received OK
    end

endmodule

