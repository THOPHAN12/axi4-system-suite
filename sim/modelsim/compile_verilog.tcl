#==============================================================================
# compile_verilog.tcl
# Compile ONLY Verilog (.v) files
# Usage: vsim -do compile_verilog.tcl
#==============================================================================

puts "=========================================="
puts "Compiling Verilog Files Only"
puts "=========================================="

# Create library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

set SRC "../../src"
set TB "../../tb"
set count 0

#==============================================================================
# 1. SERV RISC-V Core
#==============================================================================
puts "\n\[1/6\] SERV RISC-V Core..."
set SERV "${SRC}/cores/serv/rtl"

foreach file {
    serv_aligner.v serv_alu.v serv_bufreg.v serv_bufreg2.v
    serv_compdec.v serv_csr.v serv_ctrl.v serv_decode.v
    serv_immdec.v serv_mem_if.v serv_rf_if.v serv_rf_ram_if.v
    serv_rf_ram.v serv_rf_top.v serv_state.v serv_top.v
} {
    vlog -work work ${SERV}/${file}
    incr count
}
puts "  Compiled: 16 files"

#==============================================================================
# 2. AXI Interconnect (Verilog)
#==============================================================================
puts "\n\[2/6\] AXI Interconnect..."
set AXI "${SRC}/axi_interconnect/Verilog/rtl"

# Utils
vlog -work work ${AXI}/utils/Raising_Edge_Det.v
vlog -work work ${AXI}/utils/Faling_Edge_Detc.v

# Buffers
vlog -work work ${AXI}/buffers/Queue.v
vlog -work work ${AXI}/buffers/Resp_Queue.v

# Datapath
vlog -work work ${AXI}/datapath/mux/Mux_2x1.v
vlog -work work ${AXI}/datapath/mux/Mux_2x1_en.v
vlog -work work ${AXI}/datapath/mux/Mux_4x1.v
vlog -work work ${AXI}/datapath/mux/AW_MUX_2_1.v
vlog -work work ${AXI}/datapath/mux/WD_MUX_2_1.v
vlog -work work ${AXI}/datapath/mux/BReady_MUX_2_1.v
vlog -work work ${AXI}/datapath/demux/Demux_1_2.v
vlog -work work ${AXI}/datapath/demux/Demux_1x2.v
vlog -work work ${AXI}/datapath/demux/Demux_1x2_en.v
vlog -work work ${AXI}/datapath/demux/Demux_1x4.v

# Decoders
vlog -work work ${AXI}/decoders/Read_Addr_Channel_Dec.v
vlog -work work ${AXI}/decoders/Write_Addr_Channel_Dec.v
vlog -work work ${AXI}/decoders/Write_Resp_Channel_Dec.v
vlog -work work ${AXI}/decoders/Write_Resp_Channel_Arb.v

# Handshake
vlog -work work ${AXI}/handshake/AW_HandShake_Checker.v
vlog -work work ${AXI}/handshake/WD_HandShake.v
vlog -work work ${AXI}/handshake/WR_HandShake.v

# Arbitration
vlog -work work ${AXI}/arbitration/Write_Arbiter.v
vlog -work work ${AXI}/arbitration/Write_Arbiter_RR.v
vlog -work work ${AXI}/arbitration/Read_Arbiter.v
vlog -work work ${AXI}/arbitration/Qos_Arbiter.v

# Channel Controllers
vlog -work work ${AXI}/channel_controllers/write/AW_Channel_Controller_Top.v
vlog -work work ${AXI}/channel_controllers/write/WD_Channel_Controller_Top.v
vlog -work work ${AXI}/channel_controllers/write/BR_Channel_Controller_Top.v
vlog -work work ${AXI}/channel_controllers/read/Controller.v

# Core
vlog -work work ${AXI}/core/AXI_Interconnect.v
vlog -work work ${AXI}/core/AXI_Interconnect_Full.v
vlog -work work ${AXI}/core/AXI_Interconnect_2S_RDONLY.v

# Main interconnect
vlog -work work ${AXI}/arbitration/axi_rr_interconnect_2x4.v

set count [expr $count + 34]
puts "  Compiled: 34 files"

#==============================================================================
# 3. Peripherals
#==============================================================================
puts "\n\[3/6\] Peripherals..."
set PERIPH "${SRC}/peripherals/axi_lite"

vlog -work work ${PERIPH}/axi_lite_ram.v
vlog -work work ${PERIPH}/axi_lite_gpio.v
vlog -work work ${PERIPH}/axi_lite_uart.v
vlog -work work ${PERIPH}/axi_lite_spi.v

set count [expr $count + 4]
puts "  Compiled: 4 files"

#==============================================================================
# 4. AXI Bridge
#==============================================================================
puts "\n\[4/6\] AXI Bridge..."
set BRIDGE "${SRC}/axi_bridge/rtl/riscv_to_axi"

vlog -work work ${BRIDGE}/wb2axi_read.v
vlog -work work ${BRIDGE}/wb2axi_write.v
vlog -work work ${BRIDGE}/serv_axi_wrapper.v
vlog -work work ${BRIDGE}/serv_axi_dualbus_adapter.v

set count [expr $count + 4]
puts "  Compiled: 4 files"

#==============================================================================
# 5. Systems
#==============================================================================
puts "\n\[5/6\] Systems..."
set SYSTEMS "${SRC}/systems"

vlog -work work ${SYSTEMS}/serv_axi_system.v
vlog -work work ${SYSTEMS}/dual_riscv_axi_system.v
vlog -work work ${SYSTEMS}/axi_interconnect_wrapper.v
vlog -work work ${SYSTEMS}/axi_interconnect_2m4s_wrapper.v

set count [expr $count + 4]
puts "  Compiled: 4 files"

#==============================================================================
# 6. Verilog Testbenches
#==============================================================================
puts "\n\[6/6\] Testbenches..."

# Arbitration test
vlog -work work ${TB}/interconnect_tb/Verilog/arb_test_verilog.v

# System testbench
vlog -work work ${TB}/wrapper_tb/testbenches/dual_riscv/dual_riscv_axi_system_tb.v

set count [expr $count + 2]
puts "  Compiled: 2 files"

#==============================================================================
# Summary
#==============================================================================
puts "\n=========================================="
puts "Compilation Complete!"
puts "=========================================="
puts "Total files compiled: $count"
puts ""
puts "Top modules available:"
puts "  - arb_test_verilog (arbitration test)"
puts "  - dual_riscv_axi_system_tb (system testbench)"
puts ""
puts "To simulate:"
puts "  vsim work.arb_test_verilog -g ARBIT_MODE=1"
puts "  vsim work.dual_riscv_axi_system_tb"
puts ""
puts "Quick test:"
puts "  vsim -c -do \"do test_arb.tcl\""
puts "=========================================="

