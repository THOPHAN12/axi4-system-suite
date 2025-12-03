# quick_debug.tcl - Simple debug for dual RISC-V

vsim work.dual_riscv_axi_system_tb

# Just add everything from SERV wrapper
add wave -divider "Clock & Reset"
add wave /dual_riscv_axi_system_tb/ACLK
add wave /dual_riscv_axi_system_tb/ARESETN

# SERV 0 Wrapper - all signals
add wave -divider "=== SERV 0 Wrapper - Top Level ==="
add wave -r /dual_riscv_axi_system_tb/dut/u_serv0/*

# Interconnect
add wave -divider "=== Interconnect ==="
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_rvalid
add wave -hex /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_rdata

# RAM
add wave -divider "=== RAM ==="
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rvalid
add wave -hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rdata

puts "\nRunning 1us simulation..."
run 1us

puts "\nDone! Waveform ready."

