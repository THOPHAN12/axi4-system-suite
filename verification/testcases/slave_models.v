`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////////////
// Simple AXI Slave Models for Testing
////////////////////////////////////////////////////////////////////////////////

// RAM Slave Model
module axi_ram_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4,
    parameter RAM_WORDS = 2048
) (
    input wire ACLK,
    input wire ARESETN,
    
    // AXI Read Address Channel
    input wire [ID_WIDTH-1:0]     S_AXI_arid,
    input wire [ADDR_WIDTH-1:0]   S_AXI_araddr,
    input wire [7:0]              S_AXI_arlen,
    input wire [2:0]              S_AXI_arsize,
    input wire [1:0]              S_AXI_arburst,
    input wire                    S_AXI_arvalid,
    output reg                    S_AXI_arready,
    
    // AXI Read Data Channel
    output reg [ID_WIDTH-1:0]     S_AXI_rid,
    output reg [DATA_WIDTH-1:0]   S_AXI_rdata,
    output reg [1:0]              S_AXI_rresp,
    output reg                    S_AXI_rlast,
    output reg                    S_AXI_rvalid,
    input wire                    S_AXI_rready
);

    reg [DATA_WIDTH-1:0] ram [0:RAM_WORDS-1];
    reg [7:0] read_count;
    reg [ADDR_WIDTH-1:0] read_addr;
    reg [ID_WIDTH-1:0] read_id;
    
    integer i;
    initial begin
        for (i = 0; i < RAM_WORDS; i = i + 1) begin
            ram[i] = 32'h00000000 + i;
        end
        ram[0] = 32'hDEADBEEF;
        ram[1] = 32'hCAFEBABE;
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_arready <= 1'b0;
            S_AXI_rvalid <= 1'b0;
            S_AXI_rlast <= 1'b0;
            read_count <= 8'h0;
        end else begin
            // Address channel
            if (S_AXI_arvalid && !S_AXI_arready) begin
                S_AXI_arready <= 1'b1;
                read_addr <= S_AXI_araddr;
                read_count <= S_AXI_arlen + 1;
                read_id <= S_AXI_arid;
            end else begin
                S_AXI_arready <= 1'b0;
            end
            
            // Data channel
            if (S_AXI_rvalid && S_AXI_rready) begin
                if (read_count > 1) begin
                    read_count <= read_count - 1;
                    read_addr <= read_addr + 4;
                    S_AXI_rdata <= ram[read_addr[13:2] + 1];
                    S_AXI_rlast <= (read_count == 2);
                end else begin
                    S_AXI_rvalid <= 1'b0;
                    S_AXI_rlast <= 1'b0;
                end
            end else if (S_AXI_arready && S_AXI_arvalid) begin
                S_AXI_rvalid <= 1'b1;
                S_AXI_rlast <= (read_count == 1);
                S_AXI_rid <= read_id;
                S_AXI_rdata <= ram[read_addr[13:2]];
                S_AXI_rresp <= 2'b00;  // OKAY
            end
        end
    end

endmodule

// GPIO Slave Model
module axi_gpio_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4
) (
    input wire ACLK,
    input wire ARESETN,
    
    // AXI Read Address Channel
    input wire [ID_WIDTH-1:0]     S_AXI_arid,
    input wire [ADDR_WIDTH-1:0]   S_AXI_araddr,
    input wire [7:0]              S_AXI_arlen,
    input wire [2:0]              S_AXI_arsize,
    input wire [1:0]              S_AXI_arburst,
    input wire                    S_AXI_arvalid,
    output reg                    S_AXI_arready,
    
    // AXI Read Data Channel
    output reg [ID_WIDTH-1:0]     S_AXI_rid,
    output reg [DATA_WIDTH-1:0]   S_AXI_rdata,
    output reg [1:0]              S_AXI_rresp,
    output reg                    S_AXI_rlast,
    output reg                    S_AXI_rvalid,
    input wire                    S_AXI_rready
);

    reg [DATA_WIDTH-1:0] gpio_reg;
    
    initial begin
        gpio_reg = 32'h12345678;
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_arready <= 1'b0;
            S_AXI_rvalid <= 1'b0;
            S_AXI_rlast <= 1'b0;
        end else begin
            if (S_AXI_arvalid && !S_AXI_arready) begin
                S_AXI_arready <= 1'b1;
            end else begin
                S_AXI_arready <= 1'b0;
            end
            
            if (S_AXI_arready && S_AXI_arvalid) begin
                S_AXI_rvalid <= 1'b1;
                S_AXI_rlast <= 1'b1;
                S_AXI_rid <= S_AXI_arid;
                S_AXI_rdata <= gpio_reg;
                S_AXI_rresp <= 2'b00;
            end else if (S_AXI_rvalid && S_AXI_rready) begin
                S_AXI_rvalid <= 1'b0;
                S_AXI_rlast <= 1'b0;
            end
        end
    end

endmodule

// UART Slave Model
module axi_uart_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4
) (
    input wire ACLK,
    input wire ARESETN,
    
    // AXI Read Address Channel
    input wire [ID_WIDTH-1:0]     S_AXI_arid,
    input wire [ADDR_WIDTH-1:0]   S_AXI_araddr,
    input wire [7:0]              S_AXI_arlen,
    input wire [2:0]              S_AXI_arsize,
    input wire [1:0]              S_AXI_arburst,
    input wire                    S_AXI_arvalid,
    output reg                    S_AXI_arready,
    
    // AXI Read Data Channel
    output reg [ID_WIDTH-1:0]     S_AXI_rid,
    output reg [DATA_WIDTH-1:0]   S_AXI_rdata,
    output reg [1:0]              S_AXI_rresp,
    output reg                    S_AXI_rlast,
    output reg                    S_AXI_rvalid,
    input wire                    S_AXI_rready
);

    reg [DATA_WIDTH-1:0] uart_status;
    
    initial begin
        uart_status = 32'h00000001;  // TX ready
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_arready <= 1'b0;
            S_AXI_rvalid <= 1'b0;
            S_AXI_rlast <= 1'b0;
        end else begin
            if (S_AXI_arvalid && !S_AXI_arready) begin
                S_AXI_arready <= 1'b1;
            end else begin
                S_AXI_arready <= 1'b0;
            end
            
            if (S_AXI_arready && S_AXI_arvalid) begin
                S_AXI_rvalid <= 1'b1;
                S_AXI_rlast <= 1'b1;
                S_AXI_rid <= S_AXI_arid;
                S_AXI_rdata <= uart_status;
                S_AXI_rresp <= 2'b00;
            end else if (S_AXI_rvalid && S_AXI_rready) begin
                S_AXI_rvalid <= 1'b0;
                S_AXI_rlast <= 1'b0;
            end
        end
    end

endmodule

// SPI Slave Model
module axi_spi_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4
) (
    input wire ACLK,
    input wire ARESETN,
    
    // AXI Read Address Channel
    input wire [ID_WIDTH-1:0]     S_AXI_arid,
    input wire [ADDR_WIDTH-1:0]   S_AXI_araddr,
    input wire [7:0]              S_AXI_arlen,
    input wire [2:0]              S_AXI_arsize,
    input wire [1:0]              S_AXI_arburst,
    input wire                    S_AXI_arvalid,
    output reg                    S_AXI_arready,
    
    // AXI Read Data Channel
    output reg [ID_WIDTH-1:0]     S_AXI_rid,
    output reg [DATA_WIDTH-1:0]   S_AXI_rdata,
    output reg [1:0]              S_AXI_rresp,
    output reg                    S_AXI_rlast,
    output reg                    S_AXI_rvalid,
    input wire                    S_AXI_rready
);

    reg [DATA_WIDTH-1:0] spi_status;
    
    initial begin
        spi_status = 32'h00000002;  // SPI ready
    end
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            S_AXI_arready <= 1'b0;
            S_AXI_rvalid <= 1'b0;
            S_AXI_rlast <= 1'b0;
        end else begin
            if (S_AXI_arvalid && !S_AXI_arready) begin
                S_AXI_arready <= 1'b1;
            end else begin
                S_AXI_arready <= 1'b0;
            end
            
            if (S_AXI_arready && S_AXI_arvalid) begin
                S_AXI_rvalid <= 1'b1;
                S_AXI_rlast <= 1'b1;
                S_AXI_rid <= S_AXI_arid;
                S_AXI_rdata <= spi_status;
                S_AXI_rresp <= 2'b00;
            end else if (S_AXI_rvalid && S_AXI_rready) begin
                S_AXI_rvalid <= 1'b0;
                S_AXI_rlast <= 1'b0;
            end
        end
    end

endmodule

