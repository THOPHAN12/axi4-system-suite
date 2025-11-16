`timescale 1ns/1ps

//============================================================================
// Simple Memory Slave with AXI4 Slave Interface
// Purpose: Provide a simple memory for CPU/ALU to read/write data
// Memory Size: 256 words (32-bit each) = 1KB
// This module is intended to be used as a real AXI slave IP,
// not only for testbenches.
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
    
    // Read address channel state
    reg [ADDR_WIDTH-1:0] read_addr;
    reg [7:0]            read_len;
    reg                  read_addr_received;
    
    integer i;
    integer j;
    
    // Initialize memory and outputs
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            memory[i] = {DATA_WIDTH{1'b0}};
        end
    end
    
    // Write Address Channel
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_awready        <= 1'b0;
            write_addr           <= {ADDR_WIDTH{1'b0}};
            write_len            <= 8'd0;
            write_addr_received  <= 1'b0;
        end else begin
            if (!write_addr_received) begin
                if (S_AXI_awvalid && !S_AXI_awready) begin
                    S_AXI_awready       <= 1'b1;
                    write_addr          <= S_AXI_awaddr;
                    write_len           <= S_AXI_awlen;
                    write_addr_received <= 1'b1;
                end else begin
                    S_AXI_awready <= 1'b0;
                end
            end else begin
                // Address already latched, no new AW until burst completes
                S_AXI_awready <= 1'b0;
            end
        end
    end
    
    // Write Data Channel
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_wready <= 1'b0;
            S_AXI_bvalid <= 1'b0;
            S_AXI_bresp  <= 2'b00;
        end else begin
            if (write_addr_received && !S_AXI_bvalid) begin
                if (S_AXI_wvalid && !S_AXI_wready) begin
                    S_AXI_wready <= 1'b1;
                end else begin
                    S_AXI_wready <= 1'b0;
                end
                
                if (S_AXI_wvalid && S_AXI_wready) begin
                    // Write to memory with byte enables
                    if (write_addr[ADDR_WIDTH-1:2] < MEM_SIZE) begin
                        for (j = 0; j < (DATA_WIDTH/8); j = j + 1) begin
                            if (S_AXI_wstrb[j]) begin
                                memory[write_addr[ADDR_WIDTH-1:2]][j*8 +: 8] <=
                                    S_AXI_wdata[j*8 +: 8];
                            end
                        end
                    end
                    
                    // Increment address for next beat in burst
                    if (!S_AXI_wlast) begin
                        write_addr <= write_addr + (DATA_WIDTH/8);
                    end else begin
                        // Last beat of burst
                        S_AXI_bvalid          <= 1'b1;
                        S_AXI_bresp           <= 2'b00; // OKAY
                        write_addr_received   <= 1'b0;
                    end
                end
            end else begin
                S_AXI_wready <= 1'b0;
            end
            
            // Write response handshake
            if (S_AXI_bvalid && S_AXI_bready) begin
                S_AXI_bvalid <= 1'b0;
            end
        end
    end
    
    // Read Address Channel
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_arready       <= 1'b0;
            read_addr           <= {ADDR_WIDTH{1'b0}};
            read_len            <= 8'd0;
            read_addr_received  <= 1'b0;
        end else begin
            if (!read_addr_received) begin
                if (S_AXI_arvalid && !S_AXI_arready) begin
                    S_AXI_arready      <= 1'b1;
                    read_addr          <= S_AXI_araddr;
                    read_len           <= S_AXI_arlen;
                    read_addr_received <= 1'b1;
                end else begin
                    S_AXI_arready <= 1'b0;
                end
            end else begin
                // Address already latched, no new AR until burst completes
                S_AXI_arready <= 1'b0;
            end
        end
    end
    
    // Read Data Channel
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_rdata  <= {DATA_WIDTH{1'b0}};
            S_AXI_rvalid <= 1'b0;
            S_AXI_rlast  <= 1'b0;
            S_AXI_rresp  <= 2'b00;
        end else begin
            if (read_addr_received) begin
                if (!S_AXI_rvalid || (S_AXI_rvalid && S_AXI_rready)) begin
                    // Provide read data
                    if (read_addr[ADDR_WIDTH-1:2] < MEM_SIZE) begin
                        S_AXI_rdata <= memory[read_addr[ADDR_WIDTH-1:2]];
                    end else begin
                        S_AXI_rdata <= {DATA_WIDTH{1'b0}};
                    end
                    S_AXI_rvalid <= 1'b1;
                    S_AXI_rresp  <= 2'b00; // OKAY
                    
                    if (read_len == 8'd0) begin
                        S_AXI_rlast         <= 1'b1;
                        read_addr_received  <= 1'b0;
                    end else begin
                        S_AXI_rlast <= 1'b0;
                        read_len    <= read_len - 1'b1;
                        read_addr   <= read_addr + (DATA_WIDTH/8);
                    end
                end
            end else begin
                if (S_AXI_rvalid && S_AXI_rready) begin
                    S_AXI_rvalid <= 1'b0;
                    S_AXI_rlast  <= 1'b0;
                end
            end
        end
    end
    
endmodule


