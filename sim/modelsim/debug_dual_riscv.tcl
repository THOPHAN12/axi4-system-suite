# debug_dual_riscv.tcl
# Debug script for dual RISC-V system

puts "\n========================================="
puts "Debug Dual RISC-V System"
puts "=========================================\n"

# Load design
vsim work.dual_riscv_axi_system_tb

puts "Adding signals..."

# Clock & Reset
add wave -divider "=== Clock & Reset ==="
add wave /dual_riscv_axi_system_tb/ACLK
add wave /dual_riscv_axi_system_tb/ARESETN

# SERV 0 Core Internal
add wave -divider "=== SERV 0 Core Internal ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_rst
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_cyc
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_adr
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_rdt
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_ack
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_cyc
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_adr
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_dat
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_we
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_dbus_rdt
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_dbus_ack

# WB to AXI Converters
add wave -divider "=== WB2AXI Instruction Bus ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/i_wb_cyc
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/i_wb_adr
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/o_wb_ack
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/o_wb_rdt
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_rdata

# Master 0 AXI (from interconnect view)
add wave -divider "=== Master 0 to Interconnect ==="
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_rdata

# Interconnect to Slave 0 (RAM)
add wave -divider "=== Interconnect to Slave 0 (RAM) ==="
add wave /dual_riscv_axi_system_tb/dut/interconnect/S0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/interconnect/S0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/interconnect/S0_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/interconnect/S0_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/interconnect/S0_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/interconnect/S0_AXI_rdata

# RAM Internal
add wave -divider "=== RAM Internal ==="
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rdata

puts "Running simulation for 2us..."
run 2us

puts "\n========================================="
puts "Checking signal activity..."
puts "=========================================\n"

# Check if SERV is out of reset
set rst_val [examine -time 200ns /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_rst]
puts "SERV i_rst at 200ns: $rst_val (should be 0 after reset release)"

# Check if ibus_cyc goes high
set ibus_cyc [examine -time 500ns /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_cyc]
puts "SERV o_ibus_cyc at 500ns: $ibus_cyc (should be 1 if fetching)"

# Check AXI arvalid
set arvalid [examine -time 500ns /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid]
puts "Master 0 arvalid at 500ns: $arvalid (should be 1 if requesting)"

wave zoom full
puts "\nWaveform ready. Close GUI when done."

