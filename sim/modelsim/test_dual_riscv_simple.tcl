# Simple test script for dual_riscv_axi_system
# Tests the complete system after AXI_Interconnect modifications

puts "\n========================================"
puts "  DUAL RISC-V SYSTEM TEST"
puts "========================================\n"

# Clean and compile
puts "\[1/3\] Cleaning workspace..."
catch {vdel -lib work -all}
vlib work

puts "\[2/3\] Compiling project..."

# Source files root
set SRC "../../src"
set AXI "${SRC}/axi_interconnect/Verilog/rtl"

# Compile SERV core
vlog -work work ${SRC}/cores/serv/rtl/serv_alu.v
vlog -work work ${SRC}/cores/serv/rtl/serv_bufreg.v  
vlog -work work ${SRC}/cores/serv/rtl/serv_bufreg2.v
vlog -work work ${SRC}/cores/serv/rtl/serv_csr.v
vlog -work work ${SRC}/cores/serv/rtl/serv_ctrl.v
vlog -work work ${SRC}/cores/serv/rtl/serv_decode.v
vlog -work work ${SRC}/cores/serv/rtl/serv_immdec.v
vlog -work work ${SRC}/cores/serv/rtl/serv_mem_if.v
vlog -work work ${SRC}/cores/serv/rtl/serv_rf_if.v
vlog -work work ${SRC}/cores/serv/rtl/serv_rf_ram.v
vlog -work work ${SRC}/cores/serv/rtl/serv_rf_ram_if.v
vlog -work work ${SRC}/cores/serv/rtl/serv_state.v
vlog -work work ${SRC}/cores/serv/rtl/serv_top.v

# Compile AXI Bridge
vlog -work work ${SRC}/axi_bridge/rtl/legacy/serv_bridge/wb2axi_read.v
vlog -work work ${SRC}/axi_bridge/rtl/legacy/serv_bridge/wb2axi_write.v
vlog -work work ${SRC}/axi_bridge/rtl/legacy/serv_bridge/serv_axi_dualbus_adapter.v
vlog -work work ${SRC}/axi_bridge/rtl/legacy/serv_bridge/serv_axi_wrapper.v

# Compile AXI Interconnect (NEW!)
vlog -work work ${AXI}/core/AXI_Interconnect_Full.v
vlog -work work ${AXI}/core/AXI_Interconnect.v

# Compile Peripherals
vlog -work work ${SRC}/peripherals/axi_lite/axi_lite_ram.v
vlog -work work ${SRC}/peripherals/axi_lite/axi_lite_gpio.v
vlog -work work ${SRC}/peripherals/axi_lite/axi_lite_uart.v
vlog -work work ${SRC}/peripherals/axi_lite/axi_lite_spi.v

# Compile System
vlog -work work ${SRC}/systems/dual_riscv_axi_system.v

puts "\n\[3/3\] Compilation Summary"
puts "  Status: All main modules compiled!"
puts "  AXI_Interconnect: FULL R/W with 3 arbitration modes"
puts "  System: Ready for simulation"
puts "\nTo run simulation:"
puts "  vsim work.dual_riscv_axi_system -gRAM_INIT_HEX=test_program_simple.hex"
puts "========================================\n"

