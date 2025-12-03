`timescale 1ns/1ps

module axi_lite_spi #(
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

    output reg                         spi_cs_n,
    output reg                         spi_sclk,
    output reg                         spi_mosi,
    input  wire                        spi_miso
);

    localparam integer ADDR_LSB = $clog2(DATA_WIDTH/8);

    reg [7:0] tx_data;
    reg [7:0] rx_data;
    reg [7:0] control_reg;
    reg       busy;

    assign S_AXI_rlast = S_AXI_rvalid;

    integer bit_idx;

    // Simple SPI transfer emulation
    task automatic do_transfer(input [7:0] data_in);
        begin
            spi_cs_n <= 1'b0;
            busy     <= 1'b1;
            for (bit_idx = 7; bit_idx >= 0; bit_idx = bit_idx - 1) begin
                spi_sclk <= 1'b0;
                spi_mosi <= data_in[bit_idx];
                #1;
                spi_sclk <= 1'b1;
                rx_data[bit_idx] <= spi_miso;
                #1;
            end
            spi_sclk <= 1'b0;
            spi_cs_n <= 1'b1;
            busy     <= 1'b0;
            $display("[axi_lite_spi] TX=0x%02x RX=0x%02x", data_in, rx_data);
        end
    endtask

    // Write logic
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;
            S_AXI_bvalid  <= 1'b0;
            S_AXI_bresp   <= 2'b00;
            tx_data       <= 8'h00;
            control_reg   <= 8'h01;
            busy          <= 1'b0;
            spi_cs_n      <= 1'b1;
            spi_sclk      <= 1'b0;
            spi_mosi      <= 1'b0;
        end else begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;

            if (S_AXI_awvalid && S_AXI_wvalid && !S_AXI_bvalid) begin
                S_AXI_awready <= 1'b1;
                S_AXI_wready  <= 1'b1;
                case (S_AXI_awaddr[ADDR_LSB +: 2])
                    2'b00: begin
                        tx_data <= S_AXI_wdata[7:0];
                        do_transfer(S_AXI_wdata[7:0]);
                    end
                    2'b01: control_reg <= S_AXI_wdata[7:0];
                    default: ;
                endcase
                S_AXI_bvalid <= 1'b1;
                S_AXI_bresp  <= 2'b00;
            end else if (S_AXI_bvalid && S_AXI_bready) begin
                S_AXI_bvalid <= 1'b0;
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
                    2'b00: S_AXI_rdata <= {24'h0, tx_data};
                    2'b01: S_AXI_rdata <= {24'h0, control_reg};
                    2'b10: S_AXI_rdata <= {24'h0, rx_data};
                    2'b11: S_AXI_rdata <= {31'h0, busy};
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

