`timescale 1ns/1ps

module axi_lite_uart #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32
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
    output reg                         S_AXI_arready,

    output reg  [DATA_WIDTH-1:0]       S_AXI_rdata,
    output reg  [1:0]                  S_AXI_rresp,
    output reg                         S_AXI_rvalid,
    output wire                        S_AXI_rlast,
    input  wire                        S_AXI_rready,

    output reg                         tx_valid,
    output reg  [7:0]                  tx_byte
);

    localparam integer ADDR_LSB = $clog2(DATA_WIDTH/8);

    reg [15:0] baud_divider;
    reg        tx_busy;

    assign S_AXI_rlast = S_AXI_rvalid;

    // Write logic
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;
            S_AXI_bvalid  <= 1'b0;
            S_AXI_bresp   <= 2'b00;
            baud_divider  <= 16'd868; // default for 115200 @ 100MHz
            tx_valid      <= 1'b0;
            tx_byte       <= 8'h00;
            tx_busy       <= 1'b0;
        end else begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;
            tx_valid      <= 1'b0;

            if (S_AXI_awvalid && S_AXI_wvalid && !S_AXI_bvalid) begin
                S_AXI_awready <= 1'b1;
                S_AXI_wready  <= 1'b1;
                case (S_AXI_awaddr[ADDR_LSB +: 2])
                    2'b00: begin
                        tx_byte  <= S_AXI_wdata[7:0];
                        tx_valid <= 1'b1;
                        tx_busy  <= 1'b1;
                        $display("[axi_lite_uart] TX: %0d (0x%02x) '%c'",
                                 S_AXI_wdata[7:0], S_AXI_wdata[7:0],
                                 (S_AXI_wdata[7:0] >= 8'h20 && S_AXI_wdata[7:0] <= 8'h7E) ? S_AXI_wdata[7:0] : 8'h2E);
                    end
                    2'b01: baud_divider <= S_AXI_wdata[15:0];
                    default: ;
                endcase
                S_AXI_bvalid <= 1'b1;
                S_AXI_bresp  <= 2'b00;
            end else if (S_AXI_bvalid && S_AXI_bready) begin
                S_AXI_bvalid <= 1'b0;
            end

            if (tx_busy) begin
                tx_busy <= 1'b0;
            end
        end
    end

    // Read logic
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_arready <= 1'b0;
            S_AXI_rvalid  <= 1'b0;
            S_AXI_rresp   <= 2'b00;
            S_AXI_rdata   <= {DATA_WIDTH{1'b0}};
        end else begin
            S_AXI_arready <= 1'b0;

            if (S_AXI_arvalid && !S_AXI_rvalid) begin
                S_AXI_arready <= 1'b1;
                case (S_AXI_araddr[ADDR_LSB +: 2])
                    2'b00: S_AXI_rdata <= {24'h0, tx_byte};
                    2'b01: S_AXI_rdata <= {16'h0, baud_divider};
                    2'b10: S_AXI_rdata <= {31'h0, tx_busy};
                    default: S_AXI_rdata <= {DATA_WIDTH{1'b0}};
                endcase
                S_AXI_rresp  <= 2'b00;
                S_AXI_rvalid <= 1'b1;
            end else if (S_AXI_rvalid && S_AXI_rready) begin
                S_AXI_rvalid <= 1'b0;
            end
        end
    end

endmodule

