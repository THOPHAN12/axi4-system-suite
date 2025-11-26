`timescale 1ns/1ps

module dual_riscv_axi_system_tb;

    localparam CLK_PERIOD = 10ns;

    logic clk;
    logic rst_n;

    logic serv0_irq;
    logic serv1_irq;

    logic [31:0] gpio_in;
    wire  [31:0] gpio_out;

    wire         uart_tx_valid;
    wire  [7:0]  uart_tx_byte;

    wire         spi_cs_n;
    wire         spi_sclk;
    wire         spi_mosi;
    logic        spi_miso;

    dual_riscv_axi_system #(
        .RAM_INIT_HEX("D:/AXI/sim/modelsim/test_program_simple.hex")
    ) dut (
        .ACLK          (clk),
        .ARESETN       (rst_n),
        .serv0_timer_irq(serv0_irq),
        .serv1_timer_irq(serv1_irq),
        .gpio_in       (gpio_in),
        .gpio_out      (gpio_out),
        .uart_tx_valid (uart_tx_valid),
        .uart_tx_byte  (uart_tx_byte),
        .spi_cs_n      (spi_cs_n),
        .spi_sclk      (spi_sclk),
        .spi_mosi      (spi_mosi),
        .spi_miso      (spi_miso)
    );

    // Clock / reset generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        serv0_irq = 1'b0;
        serv1_irq = 1'b0;
        gpio_in   = 32'h0000_0000;
        spi_miso  = 1'b0;
        repeat (10) @(posedge clk);
        rst_n = 1'b1;
    end

    // Stimulus
    always @(posedge clk) begin
        if (rst_n) begin
            gpio_in <= gpio_in + 1;
            spi_miso <= $random;
        end
    end

    // Logging
    always @(posedge clk) begin
        if (uart_tx_valid) begin
            $display("[%0t] UART_TX: 0x%02x (%c)", $time, uart_tx_byte,
                     (uart_tx_byte >= 8'h20 && uart_tx_byte <= 8'h7E) ? uart_tx_byte : "." );
        end
    end

    initial begin
        $dumpfile("dual_riscv_axi_system_tb.vcd");
        $dumpvars(0, dual_riscv_axi_system_tb);
        #(5000us);
        $display("Simulation completed");
        $finish;
    end

endmodule

