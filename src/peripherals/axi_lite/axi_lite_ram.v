`timescale 1ns/1ps

module axi_lite_ram #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32,
    parameter integer MEM_WORDS  = 1024,
    parameter        INIT_HEX    = ""
) (
    input  wire                        ACLK,
    input  wire                        ARESETN,

    input  wire [ADDR_WIDTH-1:0]       S_AXI_awaddr,
    input  wire [2:0]                  S_AXI_awprot,
    input  wire                        S_AXI_awvalid,
    output reg                         S_AXI_awready,

    input  wire [DATA_WIDTH-1:0]       S_AXI_wdata,
    input  wire [(DATA_WIDTH/8)-1:0]   S_AXI_wstrb,
    input  wire                        S_AXI_wvalid,
    output reg                         S_AXI_wready,

    output reg  [1:0]                  S_AXI_bresp,
    output reg                         S_AXI_bvalid,
    input  wire                        S_AXI_bready,

    input  wire [ADDR_WIDTH-1:0]       S_AXI_araddr,
    input  wire [2:0]                  S_AXI_arprot,
    input  wire                        S_AXI_arvalid,
    output wire                        S_AXI_arready,

    output reg  [DATA_WIDTH-1:0]       S_AXI_rdata,
    output reg  [1:0]                  S_AXI_rresp,
    output reg                         S_AXI_rvalid,
    output wire                        S_AXI_rlast,
    input  wire                        S_AXI_rready
);

    localparam integer ADDR_LSB = $clog2(DATA_WIDTH/8);
    localparam integer MEM_ADDR_WIDTH = $clog2(MEM_WORDS);

    reg [DATA_WIDTH-1:0] mem [0:MEM_WORDS-1];

    initial begin
        if (INIT_HEX != "") begin
            $display("[axi_lite_ram] Loading %s", INIT_HEX);
            $readmemh(INIT_HEX, mem);
            // Debug: Display first few memory locations
            $display("[axi_lite_ram] mem[0] = 0x%08h", mem[0]);
            $display("[axi_lite_ram] mem[1] = 0x%08h", mem[1]);
            $display("[axi_lite_ram] mem[2] = 0x%08h", mem[2]);
        end else begin
            $display("[axi_lite_ram] No initialization file specified");
        end
    end

    // Write channel
    reg write_busy;
    reg [ADDR_WIDTH-1:0] awaddr_q;

    integer byte_idx;
    integer mem_idx;  // For read address calculation

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            write_busy    <= 1'b0;
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;
            S_AXI_bvalid  <= 1'b0;
            S_AXI_bresp   <= 2'b00;
        end else begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;

            if (!write_busy && S_AXI_awvalid && S_AXI_wvalid) begin
                awaddr_q      <= S_AXI_awaddr;
                write_busy    <= 1'b1;
                S_AXI_awready <= 1'b1;
                S_AXI_wready  <= 1'b1;

                for (byte_idx = 0; byte_idx < DATA_WIDTH/8; byte_idx = byte_idx + 1) begin
                    if (S_AXI_wstrb[byte_idx]) begin
                        mem[(awaddr_q[ADDR_LSB +: MEM_ADDR_WIDTH])] [8*byte_idx +: 8] <=
                            S_AXI_wdata[8*byte_idx +: 8];
                    end
                end

                S_AXI_bvalid <= 1'b1;
                S_AXI_bresp  <= 2'b00;
            end else if (S_AXI_bvalid && S_AXI_bready) begin
                S_AXI_bvalid <= 1'b0;
                write_busy   <= 1'b0;
            end
        end
    end

    // Read channel - Simplified, always ready for fast response
    // This eliminates the read_busy bottleneck
    
    assign S_AXI_rlast = 1'b1;  // Always last beat (single-beat transfers)

    // Read channel state machine
    reg read_pending;
    reg [ADDR_WIDTH-1:0] araddr_q;
    
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            read_pending  <= 1'b0;
            S_AXI_rvalid  <= 1'b0;
            S_AXI_rresp   <= 2'b00;
            S_AXI_rdata   <= {DATA_WIDTH{1'b0}};
            araddr_q      <= {ADDR_WIDTH{1'b0}};
        end else begin
            // When R handshake completes, clear RVALID and allow new requests
            if (S_AXI_rvalid && S_AXI_rready) begin
                S_AXI_rvalid <= 1'b0;
                read_pending  <= 1'b0;
            end
            // When AR handshake occurs: capture address and respond in next cycle
            // Check arvalid and !read_pending (arready is combinational !read_pending)
            else if (S_AXI_arvalid && !read_pending) begin
                $display("[axi_lite_ram] AR handshake: addr=0x%08h, arready=%b", S_AXI_araddr, S_AXI_arready);
                araddr_q <= S_AXI_araddr;
                read_pending <= 1'b1;
            end
            // When we have a pending read, respond with data
            else if (read_pending && !S_AXI_rvalid) begin
                mem_idx = araddr_q[ADDR_LSB +: MEM_ADDR_WIDTH];
                S_AXI_rdata  <= mem[mem_idx];
                $display("[axi_lite_ram] Read: addr=0x%08h, mem_idx=%0d, data=0x%08h", 
                         araddr_q, mem_idx, mem[mem_idx]);
                S_AXI_rresp  <= 2'b00;  // OKAY response
                S_AXI_rvalid <= 1'b1;
            end
        end
    end
    
    // Combinational: always ready when not pending a read response
    assign S_AXI_arready = !read_pending;

endmodule

