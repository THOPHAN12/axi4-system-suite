#==============================================================================
# wave_dual_riscv_clean.do
# Clean waveform configuration for dual_riscv_axi_system
# Shows only important signals for easy debugging
#==============================================================================

# Clear existing waves
delete_wave -all

#==============================================================================
# Clock & Reset
#==============================================================================
add_wave -divider "Clock & Reset"
add_wave /dual_riscv_system_tb/ACLK
add_wave /dual_riscv_system_tb/ARESETN

#==============================================================================
# GPIO
#==============================================================================
add_wave -divider "GPIO"
add_wave -radix hex /dual_riscv_system_tb/gpio_out
add_wave -radix hex /dual_riscv_system_tb/gpio_in

#==============================================================================
# UART
#==============================================================================
add_wave -divider "UART"
add_wave /dual_riscv_system_tb/uart_tx_valid
add_wave -radix hex /dual_riscv_system_tb/uart_tx_byte

#==============================================================================
# SPI
#==============================================================================
add_wave -divider "SPI"
add_wave /dual_riscv_system_tb/spi_cs_n
add_wave /dual_riscv_system_tb/spi_sclk
add_wave /dual_riscv_system_tb/spi_mosi
add_wave /dual_riscv_system_tb/spi_miso

#==============================================================================
# SERV Core 0 - AXI Read (Instruction Fetch)
#==============================================================================
add_wave -divider "SERV 0 - Instruction Fetch (M0)"
add_wave /dual_riscv_system_tb/dut/serv0_M0_arvalid
add_wave /dual_riscv_system_tb/dut/serv0_M0_arready
add_wave -radix hex /dual_riscv_system_tb/dut/serv0_M0_araddr
add_wave /dual_riscv_system_tb/dut/serv0_M0_rvalid
add_wave /dual_riscv_system_tb/dut/serv0_M0_rready
add_wave -radix hex /dual_riscv_system_tb/dut/serv0_M0_rdata

#==============================================================================
# SERV Core 0 - AXI Write (Data Store)
#==============================================================================
add_wave -divider "SERV 0 - Data Write (M1)"
add_wave /dual_riscv_system_tb/dut/serv0_M1_awvalid
add_wave /dual_riscv_system_tb/dut/serv0_M1_awready
add_wave -radix hex /dual_riscv_system_tb/dut/serv0_M1_awaddr
add_wave /dual_riscv_system_tb/dut/serv0_M1_wvalid
add_wave /dual_riscv_system_tb/dut/serv0_M1_wready
add_wave -radix hex /dual_riscv_system_tb/dut/serv0_M1_wdata

#==============================================================================
# SERV Core 1 - AXI Read (Instruction Fetch)
#==============================================================================
add_wave -divider "SERV 1 - Instruction Fetch (M0)"
add_wave /dual_riscv_system_tb/dut/serv1_M0_arvalid
add_wave /dual_riscv_system_tb/dut/serv1_M0_arready
add_wave -radix hex /dual_riscv_system_tb/dut/serv1_M0_araddr
add_wave /dual_riscv_system_tb/dut/serv1_M0_rvalid
add_wave /dual_riscv_system_tb/dut/serv1_M0_rready
add_wave -radix hex /dual_riscv_system_tb/dut/serv1_M0_rdata

#==============================================================================
# SERV Core 1 - AXI Write (Data Store)
#==============================================================================
add_wave -divider "SERV 1 - Data Write (M1)"
add_wave /dual_riscv_system_tb/dut/serv1_M1_awvalid
add_wave /dual_riscv_system_tb/dut/serv1_M1_awready
add_wave -radix hex /dual_riscv_system_tb/dut/serv1_M1_awaddr
add_wave /dual_riscv_system_tb/dut/serv1_M1_wvalid
add_wave /dual_riscv_system_tb/dut/serv1_M1_wready
add_wave -radix hex /dual_riscv_system_tb/dut/serv1_M1_wdata

#==============================================================================
# AXI Interconnect - Slave 0 (RAM)
#==============================================================================
add_wave -divider "Slave 0 - RAM"
add_wave /dual_riscv_system_tb/dut/S0_arvalid
add_wave /dual_riscv_system_tb/dut/S0_arready
add_wave -radix hex /dual_riscv_system_tb/dut/S0_araddr
add_wave /dual_riscv_system_tb/dut/S0_rvalid
add_wave /dual_riscv_system_tb/dut/S0_rready
add_wave -radix hex /dual_riscv_system_tb/dut/S0_rdata
add_wave /dual_riscv_system_tb/dut/S0_awvalid
add_wave /dual_riscv_system_tb/dut/S0_awready
add_wave -radix hex /dual_riscv_system_tb/dut/S0_awaddr
add_wave /dual_riscv_system_tb/dut/S0_wvalid
add_wave /dual_riscv_system_tb/dut/S0_wready
add_wave -radix hex /dual_riscv_system_tb/dut/S0_wdata

#==============================================================================
# AXI Interconnect - Slave 1 (GPIO)
#==============================================================================
add_wave -divider "Slave 1 - GPIO"
add_wave /dual_riscv_system_tb/dut/S1_awvalid
add_wave /dual_riscv_system_tb/dut/S1_awready
add_wave -radix hex /dual_riscv_system_tb/dut/S1_awaddr
add_wave /dual_riscv_system_tb/dut/S1_wvalid
add_wave /dual_riscv_system_tb/dut/S1_wready
add_wave -radix hex /dual_riscv_system_tb/dut/S1_wdata

#==============================================================================
# AXI Interconnect - Slave 2 (UART)
#==============================================================================
add_wave -divider "Slave 2 - UART"
add_wave /dual_riscv_system_tb/dut/S2_awvalid
add_wave /dual_riscv_system_tb/dut/S2_awready
add_wave -radix hex /dual_riscv_system_tb/dut/S2_awaddr
add_wave /dual_riscv_system_tb/dut/S2_wvalid
add_wave /dual_riscv_system_tb/dut/S2_wready
add_wave -radix hex /dual_riscv_system_tb/dut/S2_wdata

#==============================================================================
# AXI Interconnect - Slave 3 (SPI)
#==============================================================================
add_wave -divider "Slave 3 - SPI"
add_wave /dual_riscv_system_tb/dut/S3_awvalid
add_wave /dual_riscv_system_tb/dut/S3_awready
add_wave -radix hex /dual_riscv_system_tb/dut/S3_awaddr
add_wave /dual_riscv_system_tb/dut/S3_wvalid
add_wave /dual_riscv_system_tb/dut/S3_wready
add_wave -radix hex /dual_riscv_system_tb/dut/S3_wdata

# Zoom to fit
wave zoom full

puts "Waveform configuration loaded successfully!"
puts "Useful commands:"
puts "  run 10us    - Run for 10 microseconds"
puts "  run -all    - Run until finish"
puts "  restart     - Restart simulation"



