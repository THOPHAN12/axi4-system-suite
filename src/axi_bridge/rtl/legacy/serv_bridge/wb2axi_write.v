/*
 * wb2axi_write.v : Wishbone to AXI4 Write Converter
 * 
 * Converts Wishbone Classic write interface to AXI4 Write channels (AW + W + B)
 * Used for SERV data bus (read-write)
 * 
 * Wishbone Interface:
 *   - o_dbus_adr[31:0]  : Address
 *   - o_dbus_dat[31:0]  : Write data
 *   - o_dbus_sel[3:0]   : Byte select
 *   - o_dbus_we         : Write enable
 *   - o_dbus_cyc        : Cycle (valid request)
 *   - i_dbus_rdt[31:0]  : Read data (for read operations)
 *   - i_dbus_ack        : Acknowledge
 * 
 * AXI4 Interface:
 *   - AW Channel: Address Write
 *   - W Channel: Write Data
 *   - B Channel: Write Response
 *   - AR Channel: Address Read (for read operations)
 *   - R Channel: Read Data (for read operations)
 */

module wb2axi_write #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Wishbone Interface (Master side - connected to SERV)
    input  wire [ADDR_WIDTH-1:0]   wb_adr,
    input  wire [DATA_WIDTH-1:0]   wb_dat,
    input  wire [3:0]              wb_sel,
    input  wire                    wb_we,
    input  wire                    wb_cyc,
    output reg  [DATA_WIDTH-1:0]   wb_rdt,
    output reg                     wb_ack,
    
    // AXI4 Write Address Channel
    output reg  [ID_WIDTH-1:0]     M_AXI_awid,
    output reg  [ADDR_WIDTH-1:0]   M_AXI_awaddr,
    output reg  [7:0]              M_AXI_awlen,
    output reg  [2:0]              M_AXI_awsize,
    output reg  [1:0]              M_AXI_awburst,
    output reg  [1:0]              M_AXI_awlock,
    output reg  [3:0]              M_AXI_awcache,
    output reg  [2:0]              M_AXI_awprot,
    output reg  [3:0]              M_AXI_awqos,
    output reg  [3:0]              M_AXI_awregion,
    output reg                     M_AXI_awvalid,
    input  wire                    M_AXI_awready,
    
    // AXI4 Write Data Channel
    output reg  [DATA_WIDTH-1:0]   M_AXI_wdata,
    output reg  [(DATA_WIDTH/8)-1:0] M_AXI_wstrb,
    output reg                     M_AXI_wlast,
    output reg                     M_AXI_wvalid,
    input  wire                    M_AXI_wready,
    
    // AXI4 Write Response Channel
    input  wire [ID_WIDTH-1:0]     M_AXI_bid,
    input  wire [1:0]              M_AXI_bresp,
    input  wire                    M_AXI_bvalid,
    output reg                     M_AXI_bready,
    
    // AXI4 Read Address Channel (for read operations)
    output reg  [ID_WIDTH-1:0]     M_AXI_arid,
    output reg  [ADDR_WIDTH-1:0]   M_AXI_araddr,
    output reg  [7:0]              M_AXI_arlen,
    output reg  [2:0]              M_AXI_arsize,
    output reg  [1:0]              M_AXI_arburst,
    output reg  [1:0]              M_AXI_arlock,
    output reg  [3:0]              M_AXI_arcache,
    output reg  [2:0]              M_AXI_arprot,
    output reg  [3:0]              M_AXI_arqos,
    output reg  [3:0]              M_AXI_arregion,
    output reg                     M_AXI_arvalid,
    input  wire                    M_AXI_arready,
    
    // AXI4 Read Data Channel (for read operations)
    input  wire [ID_WIDTH-1:0]     M_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M_AXI_rdata,
    input  wire [1:0]              M_AXI_rresp,
    input  wire                    M_AXI_rlast,
    input  wire                    M_AXI_rvalid,
    output reg                     M_AXI_rready
);

// FSM States
localparam IDLE          = 3'b000;
localparam WRITE_ADDR    = 3'b001;
localparam WRITE_DATA    = 3'b010;
localparam WRITE_RESP    = 3'b011;
localparam READ_ADDR     = 3'b100;
localparam READ_DATA     = 3'b101;

reg [2:0] state;
reg [2:0] next_state;

// Latch signals
reg [ADDR_WIDTH-1:0] addr_latch_write;  // For write operations
reg [ADDR_WIDTH-1:0] addr_latch_read;   // For read operations
reg [DATA_WIDTH-1:0] data_latch;
reg [3:0]            sel_latch;
reg                  write_op;

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        IDLE: begin
            if (wb_cyc && !wb_ack) begin
                if (wb_we) begin
                    next_state = WRITE_ADDR;
                end else begin
                    next_state = READ_ADDR;
                end
            end
        end
        
        WRITE_ADDR: begin
            if (M_AXI_awvalid && M_AXI_awready) begin
                next_state = WRITE_DATA;
            end
        end
        
        WRITE_DATA: begin
            if (M_AXI_wvalid && M_AXI_wready) begin
                next_state = WRITE_RESP;
            end
        end
        
        WRITE_RESP: begin
            if (M_AXI_bvalid && M_AXI_bready) begin
                next_state = IDLE;
            end
        end
        
        READ_ADDR: begin
            if (M_AXI_arvalid && M_AXI_arready) begin
                next_state = READ_DATA;
            end
        end
        
        READ_DATA: begin
            if (M_AXI_rvalid && M_AXI_rready) begin
                next_state = IDLE;
            end
        end
        
        default: next_state = IDLE;
    endcase
end

// Write Address Channel
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_awvalid <= 1'b0;
        M_AXI_awaddr  <= 32'h0;
        M_AXI_awlen   <= 8'h0;
        M_AXI_awsize  <= 3'b010;  // 4 bytes
        M_AXI_awburst <= 2'b01;   // INCR
        M_AXI_awlock  <= 2'b00;
        M_AXI_awcache <= 4'b0011;
        M_AXI_awprot  <= 3'b000;
        M_AXI_awqos   <= 4'h0;
        M_AXI_awregion <= 4'h0;
        M_AXI_awid    <= {ID_WIDTH{1'b0}};
        addr_latch_write <= 32'h0;
        data_latch    <= 32'h0;
        sel_latch     <= 4'h0;
        write_op      <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                // Default assignments to avoid latches
                M_AXI_awsize  <= 3'b010;  // 4 bytes
                M_AXI_awburst <= 2'b01;   // INCR
                M_AXI_awlock  <= 2'b00;
                M_AXI_awcache <= 4'b0011;
                M_AXI_awprot  <= 3'b000;
                M_AXI_awqos   <= 4'h0;
                M_AXI_awregion <= 4'h0;
                M_AXI_awid    <= {ID_WIDTH{1'b0}};
                
                if (wb_cyc && !wb_ack) begin
                    addr_latch_write <= wb_adr;
                    data_latch <= wb_dat;
                    sel_latch  <= wb_sel;
                    write_op   <= wb_we;
                    
                    if (wb_we) begin
                        M_AXI_awvalid <= 1'b1;
                        M_AXI_awaddr  <= wb_adr;
                        M_AXI_awlen   <= 8'h0;  // Single write
                    end else begin
                        M_AXI_awvalid <= 1'b0;
                        M_AXI_awaddr  <= 32'h0;
                        M_AXI_awlen   <= 8'h0;
                    end
                end else begin
                    M_AXI_awvalid <= 1'b0;
                    M_AXI_awaddr  <= 32'h0;
                    M_AXI_awlen   <= 8'h0;
                end
            end
            
            WRITE_ADDR: begin
                // Default assignments to avoid latches
                M_AXI_awsize  <= 3'b010;
                M_AXI_awburst <= 2'b01;
                M_AXI_awlock  <= 2'b00;
                M_AXI_awcache <= 4'b0011;
                M_AXI_awprot  <= 3'b000;
                M_AXI_awqos   <= 4'h0;
                M_AXI_awregion <= 4'h0;
                M_AXI_awid    <= {ID_WIDTH{1'b0}};
                M_AXI_awaddr  <= addr_latch_write;
                M_AXI_awlen   <= 8'h0;
                
                if (M_AXI_awvalid && M_AXI_awready) begin
                    M_AXI_awvalid <= 1'b0;
                end
            end
            
            default: begin
                M_AXI_awvalid <= 1'b0;
                M_AXI_awaddr  <= 32'h0;
                M_AXI_awlen   <= 8'h0;
                M_AXI_awsize  <= 3'b010;
                M_AXI_awburst <= 2'b01;
                M_AXI_awlock  <= 2'b00;
                M_AXI_awcache <= 4'b0011;
                M_AXI_awprot  <= 3'b000;
                M_AXI_awqos   <= 4'h0;
                M_AXI_awregion <= 4'h0;
                M_AXI_awid    <= {ID_WIDTH{1'b0}};
            end
        endcase
    end
end

// Write Data Channel
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_wvalid <= 1'b0;
        M_AXI_wdata  <= 32'h0;
        M_AXI_wstrb  <= 4'h0;
        M_AXI_wlast  <= 1'b0;
    end else begin
        case (state)
            WRITE_ADDR: begin
                if (M_AXI_awvalid && M_AXI_awready) begin
                    M_AXI_wvalid <= 1'b1;
                    M_AXI_wdata  <= data_latch;
                    M_AXI_wstrb  <= sel_latch;
                    M_AXI_wlast  <= 1'b1;
                end
            end
            
            WRITE_DATA: begin
                if (M_AXI_wvalid && M_AXI_wready) begin
                    M_AXI_wvalid <= 1'b0;
                    M_AXI_wlast  <= 1'b0;
                end
            end
            
            default: begin
                M_AXI_wvalid <= 1'b0;
                M_AXI_wlast  <= 1'b0;
            end
        endcase
    end
end

// Write Response Channel
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_bready <= 1'b0;
    end else begin
        case (state)
            WRITE_DATA: begin
                if (M_AXI_wvalid && M_AXI_wready) begin
                    M_AXI_bready <= 1'b1;
                end
            end
            
            WRITE_RESP: begin
                if (M_AXI_bvalid && M_AXI_bready) begin
                    M_AXI_bready <= 1'b0;
                end
            end
            
            default: begin
                M_AXI_bready <= 1'b0;
            end
        endcase
    end
end

// Read Address Channel
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_arvalid <= 1'b0;
        M_AXI_araddr  <= 32'h0;
        M_AXI_arlen   <= 8'h0;
        M_AXI_arsize  <= 3'b010;  // 4 bytes
        M_AXI_arburst <= 2'b01;   // INCR
        M_AXI_arlock  <= 2'b00;
        M_AXI_arcache <= 4'b0011;
        M_AXI_arprot  <= 3'b000;
        M_AXI_arqos   <= 4'h0;
        M_AXI_arregion <= 4'h0;
        M_AXI_arid    <= {ID_WIDTH{1'b0}};
        addr_latch_read <= 32'h0;
    end else begin
        case (state)
            IDLE: begin
                // Default assignments to avoid latches
                M_AXI_arsize  <= 3'b010;  // 4 bytes
                M_AXI_arburst <= 2'b01;   // INCR
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
                
                if (wb_cyc && !wb_ack && !write_op) begin
                    M_AXI_arvalid <= 1'b1;
                    M_AXI_araddr  <= wb_adr;
                    addr_latch_read <= wb_adr;
                    M_AXI_arlen   <= 8'h0;  // Single read
                end else begin
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_araddr  <= 32'h0;
                    M_AXI_arlen   <= 8'h0;
                end
            end
            
            READ_ADDR: begin
                // Default assignments to avoid latches
                M_AXI_arsize  <= 3'b010;
                M_AXI_arburst <= 2'b01;
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
                M_AXI_araddr  <= addr_latch_read;
                M_AXI_arlen   <= 8'h0;
                
                if (M_AXI_arvalid && M_AXI_arready) begin
                    M_AXI_arvalid <= 1'b0;
                end
            end
            
            default: begin
                M_AXI_arvalid <= 1'b0;
                M_AXI_araddr  <= 32'h0;
                M_AXI_arlen   <= 8'h0;
                M_AXI_arsize  <= 3'b010;
                M_AXI_arburst <= 2'b01;
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
            end
        endcase
    end
end

// Read Data Channel
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_rready <= 1'b0;
        wb_rdt <= 32'h0;
    end else begin
        case (state)
            READ_ADDR: begin
                if (M_AXI_arvalid && M_AXI_arready) begin
                    M_AXI_rready <= 1'b1;
                end
            end
            
            READ_DATA: begin
                if (M_AXI_rvalid && M_AXI_rready) begin
                    wb_rdt <= M_AXI_rdata;
                    M_AXI_rready <= 1'b0;
                end
            end
            
            default: begin
                M_AXI_rready <= 1'b0;
            end
        endcase
    end
end

// Combined ACK generation (for both read and write operations)
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        wb_ack <= 1'b0;
    end else begin
        // ACK for write operation or read operation, clear when cycle deasserted
        if (state == WRITE_RESP && M_AXI_bvalid && M_AXI_bready) begin
            wb_ack <= 1'b1;
        end else if (state == READ_DATA && M_AXI_rvalid && M_AXI_rready) begin
            wb_ack <= 1'b1;
        end else if (!wb_cyc) begin
            wb_ack <= 1'b0;
        end
    end
end

endmodule
