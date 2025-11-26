`timescale 1ns/1ps

module axi_lite_gpio #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32,
    parameter integer GPIO_WIDTH = 32
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

    input  wire [GPIO_WIDTH-1:0]       gpio_in,
    output reg  [GPIO_WIDTH-1:0]       gpio_out
);

    localparam integer ADDR_LSB = $clog2(DATA_WIDTH/8);
    reg [GPIO_WIDTH-1:0] gpio_dir;

    assign S_AXI_rlast = S_AXI_rvalid;

    // Write logic
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;
            S_AXI_bvalid  <= 1'b0;
            S_AXI_bresp   <= 2'b00;
            gpio_out      <= {GPIO_WIDTH{1'b0}};
            gpio_dir      <= {GPIO_WIDTH{1'b0}};
        end else begin
            S_AXI_awready <= 1'b0;
            S_AXI_wready  <= 1'b0;

            if (S_AXI_awvalid && S_AXI_wvalid && !S_AXI_bvalid) begin
                S_AXI_awready <= 1'b1;
                S_AXI_wready  <= 1'b1;
                case (S_AXI_awaddr[ADDR_LSB +: 2])
                    2'b00: gpio_out <= S_AXI_wdata[GPIO_WIDTH-1:0];
                    2'b01: gpio_dir <= S_AXI_wdata[GPIO_WIDTH-1:0];
                    default: ;
                endcase
                S_AXI_bvalid <= 1'b1;
                S_AXI_bresp  <= 2'b00;
            end else if (S_AXI_bvalid && S_AXI_bready) begin
                S_AXI_bvalid <= 1'b0;
            end
        end
    end

    wire [DATA_WIDTH-1:0] gpio_out_ext;
    wire [DATA_WIDTH-1:0] gpio_dir_ext;
    wire [DATA_WIDTH-1:0] gpio_in_ext;

generate
    if (DATA_WIDTH > GPIO_WIDTH) begin : gen_ext
        assign gpio_out_ext = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, gpio_out};
        assign gpio_dir_ext = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, gpio_dir};
        assign gpio_in_ext  = {{(DATA_WIDTH-GPIO_WIDTH){1'b0}}, gpio_in};
    end else begin : gen_trunc
        assign gpio_out_ext = gpio_out[DATA_WIDTH-1:0];
        assign gpio_dir_ext = gpio_dir[DATA_WIDTH-1:0];
        assign gpio_in_ext  = gpio_in[DATA_WIDTH-1:0];
    end
endgenerate

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
                    2'b00: S_AXI_rdata <= gpio_out_ext;
                    2'b01: S_AXI_rdata <= gpio_dir_ext;
                    2'b10: S_AXI_rdata <= gpio_in_ext;
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

