/*
 * axi_rom_slave.v : Read-Only Memory (ROM) AXI4 Slave Model
 * 
 * Implements a read-only memory slave for instruction memory
 */

module axi_rom_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4,
    parameter MEM_SIZE   = 1024,  // Memory size in words (32-bit words)
    parameter MEM_INIT_FILE = ""  // Memory initialization file (hex format)
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Read Address Channel
    input  wire [ID_WIDTH-1:0]     S_AXI_arid,
    input  wire [ADDR_WIDTH-1:0]   S_AXI_araddr,
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
    output reg  [ID_WIDTH-1:0]     S_AXI_rid,
    output reg  [DATA_WIDTH-1:0]  S_AXI_rdata,
    output reg  [1:0]              S_AXI_rresp,
    output reg                     S_AXI_rlast,
    output reg                     S_AXI_rvalid,
    input  wire                    S_AXI_rready
);

// Memory array
localparam ADDR_BITS = $clog2(MEM_SIZE);
(* ramstyle = "M9K" *) reg [DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];

// Read FSM
localparam RD_IDLE      = 2'b00;
localparam RD_ADDR      = 2'b01;
localparam RD_DATA      = 2'b10;

reg [1:0] rd_state;
reg [ID_WIDTH-1:0] rd_id;
reg [ADDR_WIDTH-1:0] rd_addr;
reg [7:0] rd_len;
reg [7:0] rd_count;
reg [ADDR_WIDTH-1:0] rd_addr_current;

// Registered memory address for synchronous read
reg [ADDR_BITS-1:0] mem_rd_addr;
reg mem_rd_en;

// Memory initialization
integer i;
initial begin
    for (i = 0; i < MEM_SIZE; i = i + 1) begin
        memory[i] = {DATA_WIDTH{1'b0}};
    end
    if (MEM_INIT_FILE != "") begin
        $readmemh(MEM_INIT_FILE, memory);
        $display("INFO: Loaded memory from file: %s", MEM_INIT_FILE);
        // Debug: Print first few memory locations
        $display("INFO: Memory[0] = 0x%08h, Memory[1] = 0x%08h, Memory[2] = 0x%08h", 
                 memory[0], memory[1], memory[2]);
    end else begin
        $display("INFO: Memory initialized to 0x00000000 (no init file specified)");
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
                    // Calculate address index and register it
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
                    // Note: S_AXI_rvalid will be set, but data will be available next cycle
                    // This requires a 1-cycle delay in AXI response
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
                        rd_count <= rd_count + 1;
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
                        S_AXI_rlast <= (rd_count + 1 == rd_len);
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
            $display("[%0t] Memory Read: addr=0x%08h, mem_idx=%0d, data=0x%08h", 
                     $time, rd_addr_current, mem_rd_addr, memory[mem_rd_addr]);
        end else begin
            S_AXI_rdata <= {DATA_WIDTH{1'b0}};
        end
    end
end

endmodule

