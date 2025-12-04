/*
 * wb_to_axi_data_channel.v - Wishbone to AXI Data Channel Converter
 * 
 * Purpose: Reusable component for handling AXI data channels
 * Supports both READ (R channel) and WRITE (W channel)
 * 
 * Features:
 * - Data buffering and forwarding
 * - Handshake management
 * - Configurable for read or write
 */

module wb_to_axi_data_channel #(
    parameter DATA_WIDTH = 32,
    parameter CHANNEL    = "READ"  // "READ" for R channel, "WRITE" for W channel
) (
    input  wire                      ACLK,
    input  wire                      ARESETN,
    
    // Wishbone Data Interface
    input  wire [DATA_WIDTH-1:0]     wb_dat_i,      // Write data (for WRITE mode)
    input  wire [3:0]                wb_sel,        // Byte select (for WRITE mode)
    output reg  [DATA_WIDTH-1:0]     wb_dat_o,      // Read data (for READ mode)
    input  wire                      data_valid,    // Data phase active
    output reg                       data_ready,    // Data accepted
    
    // AXI Write Data Channel (W) - for WRITE mode
    output reg  [DATA_WIDTH-1:0]     axi_wdata,
    output reg  [(DATA_WIDTH/8)-1:0] axi_wstrb,
    output reg                       axi_wlast,
    output reg                       axi_wvalid,
    input  wire                      axi_wready,
    
    // AXI Read Data Channel (R) - for READ mode
    input  wire [DATA_WIDTH-1:0]     axi_rdata,
    input  wire [1:0]                axi_rresp,
    input  wire                      axi_rlast,
    input  wire                      axi_rvalid,
    output reg                       axi_rready
);

    // ========================================================================
    // Write Channel Logic (W channel)
    // ========================================================================
    generate
        if (CHANNEL == "WRITE") begin : gen_write_channel
            
            // Write data FSM
            localparam W_IDLE = 2'b00;
            localparam W_DATA = 2'b01;
            localparam W_WAIT = 2'b10;
            
            reg [1:0] w_state, w_next_state;
            reg [DATA_WIDTH-1:0] wdata_latch;
            reg [3:0] wstrb_latch;
            
            always @(posedge ACLK or negedge ARESETN) begin
                if (!ARESETN) begin
                    w_state <= W_IDLE;
                end else begin
                    w_state <= w_next_state;
                end
            end
            
            always @(*) begin
                w_next_state = w_state;
                case (w_state)
                    W_IDLE: begin
                        if (data_valid) begin
                            w_next_state = W_DATA;
                        end
                    end
                    
                    W_DATA: begin
                        if (axi_wready) begin
                            w_next_state = W_IDLE;
                        end else begin
                            w_next_state = W_WAIT;
                        end
                    end
                    
                    W_WAIT: begin
                        if (axi_wready) begin
                            w_next_state = W_IDLE;
                        end
                    end
                    
                    default: w_next_state = W_IDLE;
                endcase
            end
            
            // Data latch
            always @(posedge ACLK or negedge ARESETN) begin
                if (!ARESETN) begin
                    wdata_latch <= {DATA_WIDTH{1'b0}};
                    wstrb_latch <= 4'h0;
                end else if (w_state == W_IDLE && data_valid) begin
                    wdata_latch <= wb_dat_i;
                    wstrb_latch <= wb_sel;
                end
            end
            
            // AXI W channel outputs
            always @(posedge ACLK or negedge ARESETN) begin
                if (!ARESETN) begin
                    axi_wdata  <= {DATA_WIDTH{1'b0}};
                    axi_wstrb  <= {(DATA_WIDTH/8){1'b0}};
                    axi_wlast  <= 1'b0;
                    axi_wvalid <= 1'b0;
                end else begin
                    case (w_state)
                        W_IDLE: begin
                            axi_wvalid <= 1'b0;
                            if (data_valid) begin
                                axi_wdata  <= wb_dat_i;
                                axi_wstrb  <= wb_sel;
                                axi_wlast  <= 1'b1;  // Single transfer
                                axi_wvalid <= 1'b1;
                            end
                        end
                        
                        W_DATA, W_WAIT: begin
                            axi_wdata  <= wdata_latch;
                            axi_wstrb  <= wstrb_latch;
                            axi_wlast  <= 1'b1;
                            axi_wvalid <= 1'b1;
                            if (axi_wready) begin
                                axi_wvalid <= 1'b0;
                            end
                        end
                        
                        default: begin
                            axi_wvalid <= 1'b0;
                        end
                    endcase
                end
            end
            
            // Data ready signal
            always @(*) begin
                data_ready = (w_state == W_DATA && axi_wready) || 
                             (w_state == W_WAIT && axi_wready);
            end
            
            // Read data output (not used in write mode)
            always @(*) begin
                wb_dat_o = {DATA_WIDTH{1'b0}};
            end
            
            // AXI R channel (not used in write mode)
            always @(*) begin
                axi_rready = 1'b0;
            end
            
        end
    endgenerate

    // ========================================================================
    // Read Channel Logic (R channel)
    // ========================================================================
    generate
        if (CHANNEL == "READ") begin : gen_read_channel
            
            // Read data FSM
            localparam R_IDLE = 2'b00;
            localparam R_WAIT = 2'b01;
            localparam R_DATA = 2'b10;
            
            reg [1:0] r_state, r_next_state;
            
            always @(posedge ACLK or negedge ARESETN) begin
                if (!ARESETN) begin
                    r_state <= R_IDLE;
                end else begin
                    r_state <= r_next_state;
                end
            end
            
            always @(*) begin
                r_next_state = r_state;
                case (r_state)
                    R_IDLE: begin
                        if (data_valid) begin
                            r_next_state = R_WAIT;
                        end
                    end
                    
                    R_WAIT: begin
                        if (axi_rvalid) begin
                            r_next_state = R_DATA;
                        end
                    end
                    
                    R_DATA: begin
                        r_next_state = R_IDLE;
                    end
                    
                    default: r_next_state = R_IDLE;
                endcase
            end
            
            // AXI R channel ready
            always @(posedge ACLK or negedge ARESETN) begin
                if (!ARESETN) begin
                    axi_rready <= 1'b0;
                end else begin
                    case (r_state)
                        R_IDLE: begin
                            axi_rready <= 1'b0;
                        end
                        
                        R_WAIT: begin
                            axi_rready <= 1'b1;  // Ready to receive
                        end
                        
                        R_DATA: begin
                            axi_rready <= 1'b0;  // Data received
                        end
                        
                        default: begin
                            axi_rready <= 1'b0;
                        end
                    endcase
                end
            end
            
            // Read data output
            always @(posedge ACLK or negedge ARESETN) begin
                if (!ARESETN) begin
                    wb_dat_o <= {DATA_WIDTH{1'b0}};
                end else if (r_state == R_WAIT && axi_rvalid) begin
                    wb_dat_o <= axi_rdata;
                end
            end
            
            // Data ready signal
            always @(*) begin
                data_ready = (r_state == R_DATA);
            end
            
            // AXI W channel (not used in read mode)
            always @(*) begin
                axi_wdata  = {DATA_WIDTH{1'b0}};
                axi_wstrb  = {(DATA_WIDTH/8){1'b0}};
                axi_wlast  = 1'b0;
                axi_wvalid = 1'b0;
            end
            
        end
    endgenerate

endmodule

