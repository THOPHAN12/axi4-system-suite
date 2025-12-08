# ==============================================================================
# ModelSim TCL Script - Run Simulation
# ==============================================================================
# This script runs the simulation after compiling all files
# ==============================================================================

# Source the add_all_files.tcl script first
source add_all_files.tcl

# Start simulation
puts "\n=========================================="
puts "Starting Simulation"
puts "=========================================="

# Run simulation with testbench
vsim -voptargs="+acc" triple_riscv_axi_system_tb

# Add waves
add wave -divider "Clock and Reset"
add wave -radix hex /triple_riscv_axi_system_tb/ACLK
add wave -radix hex /triple_riscv_axi_system_tb/ARESETN

add wave -divider "GPIO"
add wave -radix hex /triple_riscv_axi_system_tb/gpio_in
add wave -radix hex /triple_riscv_axi_system_tb/gpio_out

add wave -divider "UART"
add wave -radix hex /triple_riscv_axi_system_tb/uart_tx_valid
add wave -radix hex /triple_riscv_axi_system_tb/uart_tx_byte

add wave -divider "SPI"
add wave -radix hex /triple_riscv_axi_system_tb/spi_cs_n
add wave -radix hex /triple_riscv_axi_system_tb/spi_sclk
add wave -radix hex /triple_riscv_axi_system_tb/spi_mosi
add wave -radix hex /triple_riscv_axi_system_tb/spi_miso

add wave -divider "Core 0 Debug"
add wave -radix hex /triple_riscv_axi_system_tb/core0_debug_pc
add wave -radix hex /triple_riscv_axi_system_tb/core0_debug_r1
add wave -radix hex /triple_riscv_axi_system_tb/core0_debug_r2

add wave -divider "Core 1 Debug"
add wave -radix hex /triple_riscv_axi_system_tb/core1_debug_pc
add wave -radix hex /triple_riscv_axi_system_tb/core1_debug_r1
add wave -radix hex /triple_riscv_axi_system_tb/core1_debug_r2

add wave -divider "Core 2 Debug"
add wave -radix hex /triple_riscv_axi_system_tb/core2_debug_pc
add wave -radix hex /triple_riscv_axi_system_tb/core2_debug_r1
add wave -radix hex /triple_riscv_axi_system_tb/core2_debug_r2

add wave -divider "DUT Internal Signals"
add wave -radix hex /triple_riscv_axi_system_tb/u_dut/M0_ARADDR
add wave -radix hex /triple_riscv_axi_system_tb/u_dut/M0_RDATA
add wave -radix hex /triple_riscv_axi_system_tb/u_dut/M0_ARVALID
add wave -radix hex /triple_riscv_axi_system_tb/u_dut/M0_ARREADY

# Run simulation
run 10000ns

# End of script

