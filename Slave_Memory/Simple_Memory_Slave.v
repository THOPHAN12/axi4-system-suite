`timescale 1ns/1ps

//============================================================================
// Simple Memory Slave with AXI4 Slave Interface
// Purpose: Provide a simple memory for CPU ALU to read/write data
// Memory Size: 256 words (32-bit each) = 1KB
//============================================================================
module Simple_Memory_Slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE   = 256  // 256 words = 1KB
) (
    // Global signals
    input  wire                          ACLK,
    input  wire                          ARESETN,
    
    // ========================================================================
    // AXI4 Write Address Channel
    // ========================================================================
    input  wire  [ADDR_WIDTH-1:0]        S_AXI_awaddr,
    input  wire  [7:0]                   S_AXI_awlen,
    input  wire  [2:0]                   S_AXI_awsize,
    input  wire  [1:0]                   S_AXI_awburst,
    input  wire  [1:0]                   S_AXI_awlock,
    input  wire  [3:0]                   S_AXI_awcache,
    input  wire  [2:0]                   S_AXI_awprot,
    input  wire  [3:0]                   S_AXI_awregion,
    input  wire  [3:0]                   S_AXI_awqos,
    input  wire                          S_AXI_awvalid,
    output reg                           S_AXI_awready,
    
    // ========================================================================
    // AXI4 Write Data Channel
    // ========================================================================
    input  wire  [DATA_WIDTH-1:0]        S_AXI_wdata,
    input  wire  [(DATA_WIDTH/8)-1:0]    S_AXI_wstrb,
    input  wire                          S_AXI_wlast,
    input  wire                          S_AXI_wvalid,
    output reg                           S_AXI_wready,
    
    // ========================================================================
    // AXI4 Write Response Channel
    // ========================================================================
    output reg   [1:0]                   S_AXI_bresp,
    output reg                           S_AXI_bvalid,
    input  wire                          S_AXI_bready,
    
    // ========================================================================
    // AXI4 Read Address Channel
    // ========================================================================
    input  wire  [ADDR_WIDTH-1:0]        S_AXI_araddr,
    input  wire  [7:0]                   S_AXI_arlen,
    input  wire  [2:0]                   S_AXI_arsize,
    input  wire  [1:0]                   S_AXI_arburst,
    input  wire  [1:0]                   S_AXI_arlock,
    input  wire  [3:0]                   S_AXI_arcache,
    input  wire  [2:0]                   S_AXI_arprot,
    input  wire  [3:0]                   S_AXI_arregion,
    input  wire  [3:0]                   S_AXI_arqos,
    input  wire                          S_AXI_arvalid,
    output reg                           S_AXI_arready,
    
    // ========================================================================
    // AXI4 Read Data Channel
    // ========================================================================
    output reg   [DATA_WIDTH-1:0]        S_AXI_rdata,
    output reg   [1:0]                   S_AXI_rresp,
    output reg                           S_AXI_rlast,
    output reg                           S_AXI_rvalid,
    input  wire                          S_AXI_rready
);

    // Internal memory array
    reg [DATA_WIDTH-1:0] memory [0:MEM_SIZE-1];
    
    // Write address channel state
    reg [ADDR_WIDTH-1:0] write_addr;
    reg [7:0]            write_len;
    reg                  write_addr_received;
    
    // Write data channel state
    reg                  write_data_received;
    reg [7:0]            write_count;
    
    // Read address channel state
    reg [ADDR_WIDTH-1:0] read_addr;
    reg [7:0]            read_len;
    reg                  read_addr_received;
    
    // Read data channel state
    reg [7:0]            read_count;
    
    // Address calculation (word address, not byte address)
    wire [7:0] write_word_addr;
    wire [7:0] read_word_addr;
    
    assign write_word_addr = write_addr[9:2];  // Convert byte address to word address (bits [9:2])
    assign read_word_addr  = read_addr[9:2];   // Convert byte address to word address (bits [9:2])
    
    // ========================================================================
    // Write Address Channel
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_awready <= 1'b0;
            write_addr <= 32'h0;
            write_len <= 8'h0;
            write_addr_received <= 1'b0;
        end else begin
            if (S_AXI_awvalid && !write_addr_received) begin
                S_AXI_awready <= 1'b1;
                write_addr <= S_AXI_awaddr;
                write_len <= S_AXI_awlen;
                write_addr_received <= 1'b1;
            end else if (write_addr_received && write_data_received && S_AXI_bready && S_AXI_bvalid) begin
                // Reset after write response is accepted
                S_AXI_awready <= 1'b0;
                write_addr_received <= 1'b0;
            end else begin
                S_AXI_awready <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Write Data Channel
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_wready <= 1'b0;
            write_data_received <= 1'b0;
            write_count <= 8'h0;
        end else begin
            if (S_AXI_wvalid && write_addr_received && !write_data_received) begin
                S_AXI_wready <= 1'b1;
                // Write data to memory
                if (write_word_addr < MEM_SIZE) begin
                    if (S_AXI_wstrb[0]) memory[write_word_addr][7:0]   <= S_AXI_wdata[7:0];
                    if (S_AXI_wstrb[1]) memory[write_word_addr][15:8]  <= S_AXI_wdata[15:8];
                    if (S_AXI_wstrb[2]) memory[write_word_addr][23:16] <= S_AXI_wdata[23:16];
                    if (S_AXI_wstrb[3]) memory[write_word_addr][31:24] <= S_AXI_wdata[31:24];
                end
                write_count <= write_count + 8'h1;
                if (S_AXI_wlast) begin
                    write_data_received <= 1'b1;
                    write_count <= 8'h0;
                end
            end else if (write_data_received && S_AXI_bready && S_AXI_bvalid) begin
                // Reset after write response is accepted
                S_AXI_wready <= 1'b0;
                write_data_received <= 1'b0;
            end else begin
                S_AXI_wready <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Write Response Channel
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_bvalid <= 1'b0;
            S_AXI_bresp <= 2'b00;  // OKAY response
        end else begin
            if (write_addr_received && write_data_received && !S_AXI_bvalid) begin
                S_AXI_bvalid <= 1'b1;
                S_AXI_bresp <= 2'b00;  // OKAY response
            end else if (S_AXI_bvalid && S_AXI_bready) begin
                S_AXI_bvalid <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Read Address Channel
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_arready <= 1'b1;  // Ready to accept address after reset
            read_addr <= 32'h0;
            read_len <= 8'h0;
        end else begin
            if (S_AXI_arvalid && S_AXI_arready) begin
                // Handshake complete, latch address and deassert arready
                read_addr <= S_AXI_araddr;
                read_len <= S_AXI_arlen;
                S_AXI_arready <= 1'b0;  // Not ready until current transaction completes
            end else if (!read_addr_received && !S_AXI_rvalid) begin
                // Ready to accept new address when no transaction in progress
                S_AXI_arready <= 1'b1;
            end else begin
                S_AXI_arready <= 1'b0;
            end
        end
    end
    
    // ========================================================================
    // Read Data Channel
    // ========================================================================
    // Internal signal to detect address handshake
    wire ar_handshake;
    assign ar_handshake = S_AXI_arvalid && S_AXI_arready;
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_rvalid <= 1'b0;
            S_AXI_rdata <= 32'h0;
            S_AXI_rresp <= 2'b00;
            S_AXI_rlast <= 1'b0;
            read_count <= 8'h0;
            read_addr_received <= 1'b0;
        end else begin
            // Set read_addr_received when address handshake completes
            if (ar_handshake) begin
                read_addr_received <= 1'b1;
                read_count <= 8'h0;
            end
            // Provide read data when address is received (next cycle after handshake)
            else if (read_addr_received && !S_AXI_rvalid) begin
                S_AXI_rvalid <= 1'b1;
                if (read_word_addr < MEM_SIZE) begin
                    S_AXI_rdata <= memory[read_word_addr];
                    S_AXI_rresp <= 2'b00;  // OKAY response
                end else begin
                    S_AXI_rdata <= 32'h0;
                    S_AXI_rresp <= 2'b10;  // SLVERR - address out of range
                end
                S_AXI_rlast <= 1'b1;   // Single transfer for now
            end 
            // Reset after read data is accepted
            else if (S_AXI_rvalid && S_AXI_rready) begin
                S_AXI_rvalid <= 1'b0;
                S_AXI_rlast <= 1'b0;
                read_addr_received <= 1'b0;
                read_count <= 8'h0;
            end
        end
    end
    
    // Initialize memory with zeros
    integer i;
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            memory[i] = 32'h0;
        end
    end

endmodule

