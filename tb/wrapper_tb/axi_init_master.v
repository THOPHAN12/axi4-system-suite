`timescale 1ns/1ps

/*
 * axi_init_master.v : Simple AXI Master for Memory Initialization
 * 
 * A simple AXI master that can write data to memory for initialization
 */

module axi_init_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Control
    input  wire                    start,
    input  wire [ADDR_WIDTH-1:0]   init_addr,
    input  wire [DATA_WIDTH-1:0]   init_data,
    output reg                     done,
    
    // AXI Write Address Channel
    output reg  [ADDR_WIDTH-1:0]   M_AXI_awaddr,
    output reg  [7:0]              M_AXI_awlen,
    output reg  [2:0]              M_AXI_awsize,
    output reg  [1:0]              M_AXI_awburst,
    output reg  [1:0]              M_AXI_awlock,
    output reg  [3:0]              M_AXI_awcache,
    output reg  [2:0]              M_AXI_awprot,
    output reg  [3:0]              M_AXI_awregion,
    output reg  [3:0]              M_AXI_awqos,
    output reg                     M_AXI_awvalid,
    input  wire                    M_AXI_awready,
    
    // AXI Write Data Channel
    output reg  [DATA_WIDTH-1:0]   M_AXI_wdata,
    output reg  [(DATA_WIDTH/8)-1:0] M_AXI_wstrb,
    output reg                     M_AXI_wlast,
    output reg                     M_AXI_wvalid,
    input  wire                    M_AXI_wready,
    
    // AXI Write Response Channel
    input  wire [1:0]              M_AXI_bresp,
    input  wire                    M_AXI_bvalid,
    output reg                     M_AXI_bready
);

    localparam IDLE = 2'b00;
    localparam WRITE_ADDR = 2'b01;
    localparam WRITE_DATA = 2'b10;
    localparam WRITE_RESP = 2'b11;
    
    reg [1:0] state;
    reg [1:0] next_state;
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always @(*) begin
        next_state = state;
        done = 1'b0;
        M_AXI_awvalid = 1'b0;
        M_AXI_wvalid = 1'b0;
        M_AXI_wlast = 1'b0;
        M_AXI_bready = 1'b0;
        
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = WRITE_ADDR;
                end
            end
            
            WRITE_ADDR: begin
                M_AXI_awvalid = 1'b1;
                if (M_AXI_awready) begin
                    next_state = WRITE_DATA;
                end
            end
            
            WRITE_DATA: begin
                M_AXI_wvalid = 1'b1;
                M_AXI_wlast = 1'b1;
                if (M_AXI_wready) begin
                    next_state = WRITE_RESP;
                end
            end
            
            WRITE_RESP: begin
                M_AXI_bready = 1'b1;
                if (M_AXI_bvalid) begin
                    next_state = IDLE;
                    done = 1'b1;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M_AXI_awaddr <= 32'h0;
            M_AXI_awlen <= 8'h0;
            M_AXI_awsize <= 3'b010;  // 4 bytes
            M_AXI_awburst <= 2'b01;  // INCR
            M_AXI_awlock <= 2'b00;
            M_AXI_awcache <= 4'b0000;
            M_AXI_awprot <= 3'b000;
            M_AXI_awregion <= 4'h0;
            M_AXI_awqos <= 4'h0;
            M_AXI_wdata <= 32'h0;
            M_AXI_wstrb <= 4'hF;
        end else begin
            if (state == IDLE && start) begin
                M_AXI_awaddr <= init_addr;
                M_AXI_wdata <= init_data;
            end
        end
    end

endmodule

