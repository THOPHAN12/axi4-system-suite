/*
 * axi_memory_slave.v : Simple AXI4 Memory Slave Model
 * 
 * Implements a simple memory slave for testing SERV + AXI system
 * Supports both read and write operations
 */

module axi_memory_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter MEM_SIZE   = 1024,  // Memory size in words (32-bit words)
    parameter MEM_INIT_FILE = ""  // Optional memory initialization file
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Write Address Channel
    input  wire [ID_WIDTH-1:0]    S_AXI_awid,
    input  wire [ADDR_WIDTH-1:0]  S_AXI_awaddr,
    input  wire [7:0]              S_AXI_awlen,
    input  wire [2:0]              S_AXI_awsize,
    input  wire [1:0]              S_AXI_awburst,
    input  wire [1:0]              S_AXI_awlock,
    input  wire [3:0]              S_AXI_awcache,
    input  wire [2:0]              S_AXI_awprot,
    input  wire [3:0]              S_AXI_awqos,
    input  wire [3:0]              S_AXI_awregion,
    input  wire                    S_AXI_awvalid,
    output reg                     S_AXI_awready,
    
    // Write Data Channel
    input  wire [DATA_WIDTH-1:0]  S_AXI_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] S_AXI_wstrb,
    input  wire                    S_AXI_wlast,
    input  wire                    S_AXI_wvalid,
    output reg                     S_AXI_wready,
    
    // Write Response Channel
    output reg  [ID_WIDTH-1:0]    S_AXI_bid,
    output reg  [1:0]              S_AXI_bresp,
    output reg                     S_AXI_bvalid,
    input  wire                    S_AXI_bready,
    
    // Read Address Channel
    input  wire [ID_WIDTH-1:0]     S_AXI_arid,
    input  wire [ADDR_WIDTH-1:0]  S_AXI_araddr,
    input  wire [7:0]              S_AXI_arlen,
    input  wire [2:0]              S_AXI_arsize,
    input  wire [1:0]              S_AXI_arburst,
    input  wire [1:0]              S_AXI_arlock,
    input  wire [3:0]              S_AXI_arcache,
    input  wire [2:0]              S_AXI_arprot,
    input  wire [3:0]              S_AXI_arqos,
    input  wire [3:0]              S_AXI_arregion,
    input  wire                    S_AXI_arvalid,
    output reg                     S_AXI_arready,
    
    // Read Data Channel
    output reg  [ID_WIDTH-1:0]    S_AXI_rid,
    output reg  [DATA_WIDTH-1:0]  S_AXI_rdata,
    output reg  [1:0]              S_AXI_rresp,
    output reg                     S_AXI_rlast,
    output reg                     S_AXI_rvalid,
    input  wire                    S_AXI_rready
);

// Memory array
localparam ADDR_BITS = $clog2(MEM_SIZE);
(* ramstyle = "M9K" *) reg [DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];

// Write FSM
localparam WR_IDLE      = 2'b00;
localparam WR_ADDR      = 2'b01;
localparam WR_DATA      = 2'b10;
localparam WR_RESP      = 2'b11;

reg [1:0] wr_state;
reg [ID_WIDTH-1:0] wr_id;
reg [ADDR_WIDTH-1:0] wr_addr;  // Intentional: stored but not read (may be used for debug/future)
reg [7:0] wr_len;               // Intentional: stored but not read (may be used for debug/future)
reg [7:0] wr_count;
reg [ADDR_WIDTH-1:0] wr_addr_current;

// Read FSM
localparam RD_IDLE      = 2'b00;
localparam RD_ADDR      = 2'b01;
localparam RD_DATA      = 2'b10;

reg [1:0] rd_state;
reg [ID_WIDTH-1:0] rd_id;
reg [ADDR_WIDTH-1:0] rd_addr;  // Intentional: stored but not read (may be used for debug/future)
reg [7:0] rd_len;               // Intentional: stored but not read (may be used for debug/future)
reg [7:0] rd_count;
reg [ADDR_WIDTH-1:0] rd_addr_current;

// Registered memory address for synchronous read
reg [ADDR_BITS-1:0] mem_rd_addr;
reg mem_rd_en;

// Memory initialization
integer i;
integer j;  // For loop variable in write data channel
initial begin
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        memory[i] = {DATA_WIDTH{1'b0}};
    end
    if (MEM_INIT_FILE != "") begin
        $readmemh(MEM_INIT_FILE, memory);
    end
end

// ========================================================================
// Write Channel FSM
// ========================================================================
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        wr_state <= WR_IDLE;
        S_AXI_awready <= 1'b0;
        S_AXI_wready <= 1'b0;
        S_AXI_bvalid <= 1'b0;
        wr_id <= {ID_WIDTH{1'b0}};
        wr_addr <= {ADDR_WIDTH{1'b0}};
        wr_len <= 8'h0;
        wr_count <= 8'h0;
        wr_addr_current <= {ADDR_WIDTH{1'b0}};
    end else begin
        case (wr_state)
            WR_IDLE: begin
                S_AXI_awready <= 1'b0;
                S_AXI_wready <= 1'b0;
                S_AXI_bvalid <= 1'b0;
                if (S_AXI_awvalid) begin
                    wr_state <= WR_ADDR;
                    S_AXI_awready <= 1'b1;
                    wr_id <= S_AXI_awid;
                    wr_addr <= S_AXI_awaddr;
                    wr_len <= S_AXI_awlen;
                    wr_count <= 8'h0;
                    wr_addr_current <= S_AXI_awaddr;
                end
            end
            
            WR_ADDR: begin
                S_AXI_awready <= 1'b0;
                if (S_AXI_awvalid && S_AXI_awready) begin
                    wr_state <= WR_DATA;
                    S_AXI_wready <= 1'b1;
                end
            end
            
            WR_DATA: begin
                if (S_AXI_wvalid && S_AXI_wready) begin
                    // Write to memory with byte enables
                    if (wr_addr_current[ADDR_BITS+1:2] < MEM_SIZE) begin
                        $display("[%0t] MEM_SLAVE[%m] WRITE_DEBUG: wr_addr_current=0x%08h word_addr=%0d S_AXI_wdata=0x%08h",
                                 $time, wr_addr_current, wr_addr_current[ADDR_BITS+1:2], S_AXI_wdata);
                        for (j = 0; j < (DATA_WIDTH/8); j = j + 1) begin
                            if (S_AXI_wstrb[j]) begin
                                memory[wr_addr_current[ADDR_BITS+1:2]][j*8 +: 8] <= 
                                    S_AXI_wdata[j*8 +: 8];
                            end
                        end
                        $display("[%0t] MEM_SLAVE[%m] WRITE: addr=%0d data=0x%08h (to memory[%0d])",
                                 $time,
                                 wr_addr_current[ADDR_BITS+1:2],
                                 S_AXI_wdata,
                                 wr_addr_current[ADDR_BITS+1:2]);
                    end
                    
                    if (S_AXI_wlast) begin
                        wr_state <= WR_RESP;
                        S_AXI_wready <= 1'b0;
                        S_AXI_bvalid <= 1'b1;
                        S_AXI_bid <= wr_id;
                        S_AXI_bresp <= 2'b00;  // OKAY
                    end else begin
                        wr_count <= wr_count + 8'd1;  // Explicit 8-bit addition to avoid truncation warning
                        // Increment address based on burst type
                        if (S_AXI_awburst == 2'b01) begin  // INCR
                            wr_addr_current <= wr_addr_current + (DATA_WIDTH/8);
                        end
                    end
                end
            end
            
            WR_RESP: begin
                if (S_AXI_bvalid && S_AXI_bready) begin
                    wr_state <= WR_IDLE;
                    S_AXI_bvalid <= 1'b0;
                end
            end
            
            default: wr_state <= WR_IDLE;
        endcase
    end
end

// ========================================================================
// Read Channel FSM
// ========================================================================
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        rd_state <= RD_IDLE;
        S_AXI_arready <= 1'b0;
        S_AXI_rvalid <= 1'b0;
        S_AXI_rlast <= 1'b0;
        rd_id <= {ID_WIDTH{1'b0}};
        rd_addr <= {ADDR_WIDTH{1'b0}};
        rd_len <= 8'h0;
        rd_count <= 8'h0;
        rd_addr_current <= {ADDR_WIDTH{1'b0}};
        mem_rd_addr <= {ADDR_BITS{1'b0}};
        mem_rd_en <= 1'b0;
    end else begin
        case (rd_state)
            RD_IDLE: begin
                S_AXI_arready <= 1'b0;
                S_AXI_rvalid <= 1'b0;
                S_AXI_rlast <= 1'b0;
                if (S_AXI_arvalid) begin
                    rd_state <= RD_ADDR;
                    S_AXI_arready <= 1'b1;
                    rd_id <= S_AXI_arid;
                    rd_addr <= S_AXI_araddr;
                    rd_len <= S_AXI_arlen;
                    rd_count <= 8'h0;
                    rd_addr_current <= S_AXI_araddr;
                end
            end
            
            RD_ADDR: begin
                S_AXI_arready <= 1'b0;
                if (S_AXI_arvalid && S_AXI_arready) begin
                    rd_state <= RD_DATA;
                    // Register memory address for synchronous read (data available next cycle)
                    if (rd_addr_current[ADDR_BITS+1:2] < MEM_SIZE) begin
                        mem_rd_addr <= rd_addr_current[ADDR_BITS+1:2];
                        mem_rd_en <= 1'b1;
                    end else begin
                        mem_rd_addr <= {ADDR_BITS{1'b0}};
                        mem_rd_en <= 1'b0;
                    end
                    S_AXI_rid <= rd_id;
                    S_AXI_rresp <= 2'b00;  // OKAY
                    S_AXI_rlast <= (rd_len == 8'h0);
                    // Note: S_AXI_rvalid will be set in RD_DATA state after data is ready
                end
            end
            
            RD_DATA: begin
                // Set rvalid after address is registered (data available)
                if (rd_state == RD_DATA && !S_AXI_rvalid) begin
                    S_AXI_rvalid <= 1'b1;
                end
                
                if (S_AXI_rvalid && S_AXI_rready) begin
                    if (S_AXI_rlast) begin
                        rd_state <= RD_IDLE;
                        S_AXI_rvalid <= 1'b0;
                        S_AXI_rlast <= 1'b0;
                        mem_rd_en <= 1'b0;
                    end else begin
                        rd_count <= rd_count + 8'd1;  // Explicit 8-bit addition to avoid truncation warning
                        // Increment address based on burst type
                        if (S_AXI_arburst == 2'b01) begin  // INCR
                            rd_addr_current <= rd_addr_current + (DATA_WIDTH/8);
                        end
                        // Register next memory address
                        if (rd_addr_current[ADDR_BITS+1:2] < MEM_SIZE) begin
                            mem_rd_addr <= rd_addr_current[ADDR_BITS+1:2];
                            mem_rd_en <= 1'b1;
                        end else begin
                            mem_rd_addr <= {ADDR_BITS{1'b0}};
                            mem_rd_en <= 1'b0;
                        end
                        S_AXI_rlast <= ((rd_count + 8'd1) == rd_len);  // Explicit 8-bit addition
                    end
                end
            end
            
            default: rd_state <= RD_IDLE;
        endcase
    end
end

// ========================================================================
// Synchronous Memory Read (for RAM inference)
// ========================================================================
// Separate always block for memory read to ensure synchronous read for RAM inference
always @(posedge ACLK) begin
    if (!ARESETN) begin
        S_AXI_rdata <= {DATA_WIDTH{1'b0}};
    end else begin
        if (mem_rd_en && mem_rd_addr < MEM_SIZE) begin
            S_AXI_rdata <= memory[mem_rd_addr];
            $display("[%0t] MEM_SLAVE[%m] READ: addr=%0d data=0x%08h (from memory[%0d])", $time, mem_rd_addr, memory[mem_rd_addr], mem_rd_addr);
        end else begin
            S_AXI_rdata <= {DATA_WIDTH{1'b0}};
            $display("[%0t] MEM_SLAVE[%m] READ: FAILED (mem_rd_en=%0b addr=%0d MEM_SIZE=%0d)", $time, mem_rd_en, mem_rd_addr, MEM_SIZE);
        end
    end
end

endmodule

