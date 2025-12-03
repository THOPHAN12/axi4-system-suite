#==============================================================================
# compile_all.tcl
# Compile all RTL and testbench files (no simulation)
# Usage: vsim -do compile_all.tcl
#==============================================================================

puts "=========================================="
puts "Compiling All Files"
puts "=========================================="

# Create library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

set SRC "../../src"
set TB "../../tb"
set compile_count 0

#==============================================================================
# 1. SERV RISC-V Core
#==============================================================================
puts "\n\[1/7\] SERV RISC-V Core..."
set SERV "${SRC}/cores/serv/rtl"

foreach file {
    serv_aligner.v serv_alu.v serv_bufreg.v serv_bufreg2.v
    serv_compdec.v serv_csr.v serv_ctrl.v serv_decode.v
    serv_immdec.v serv_mem_if.v serv_rf_if.v serv_rf_ram_if.v
    serv_rf_ram.v serv_rf_top.v serv_state.v serv_top.v
} {
    vlog -work work ${SERV}/${file}
    incr compile_count
}

#==============================================================================
# 2. AXI Interconnect (Verilog)
#==============================================================================
puts "\[2/7\] AXI Interconnect (Verilog)..."
set AXI_V "${SRC}/axi_interconnect/Verilog/rtl"

# Utils (compile first - no dependencies)
vlog -work work ${AXI_V}/utils/Raising_Edge_Det.v
vlog -work work ${AXI_V}/utils/Faling_Edge_Detc.v

# Buffers
vlog -work work ${AXI_V}/buffers/Queue.v
vlog -work work ${AXI_V}/buffers/Resp_Queue.v

# Datapath
vlog -work work ${AXI_V}/datapath/mux/Mux_2x1.v
vlog -work work ${AXI_V}/datapath/mux/Mux_2x1_en.v
vlog -work work ${AXI_V}/datapath/mux/Mux_4x1.v
vlog -work work ${AXI_V}/datapath/mux/AW_MUX_2_1.v
vlog -work work ${AXI_V}/datapath/mux/WD_MUX_2_1.v
vlog -work work ${AXI_V}/datapath/mux/BReady_MUX_2_1.v

vlog -work work ${AXI_V}/datapath/demux/Demux_1_2.v
vlog -work work ${AXI_V}/datapath/demux/Demux_1x2.v
vlog -work work ${AXI_V}/datapath/demux/Demux_1x2_en.v
vlog -work work ${AXI_V}/datapath/demux/Demux_1x4.v

# Decoders
vlog -work work ${AXI_V}/decoders/Read_Addr_Channel_Dec.v
vlog -work work ${AXI_V}/decoders/Write_Addr_Channel_Dec.v
vlog -work work ${AXI_V}/decoders/Write_Resp_Channel_Dec.v
vlog -work work ${AXI_V}/decoders/Write_Resp_Channel_Arb.v

# Handshake
vlog -work work ${AXI_V}/handshake/AW_HandShake_Checker.v
vlog -work work ${AXI_V}/handshake/WD_HandShake.v
vlog -work work ${AXI_V}/handshake/WR_HandShake.v

# Arbitration
vlog -work work ${AXI_V}/arbitration/Write_Arbiter.v
vlog -work work ${AXI_V}/arbitration/Write_Arbiter_RR.v
vlog -work work ${AXI_V}/arbitration/Read_Arbiter.v
vlog -work work ${AXI_V}/arbitration/Qos_Arbiter.v

# Channel Controllers
vlog -work work ${AXI_V}/channel_controllers/write/AW_Channel_Controller_Top.v
vlog -work work ${AXI_V}/channel_controllers/write/WD_Channel_Controller_Top.v
vlog -work work ${AXI_V}/channel_controllers/write/BR_Channel_Controller_Top.v
vlog -work work ${AXI_V}/channel_controllers/read/Controller.v

# Core (compile last - depends on above)
vlog -work work ${AXI_V}/core/AXI_Interconnect.v
vlog -work work ${AXI_V}/core/AXI_Interconnect_Full.v
vlog -work work ${AXI_V}/core/AXI_Interconnect_2S_RDONLY.v

# Main interconnect with arbitration
vlog -work work ${AXI_V}/arbitration/axi_rr_interconnect_2x4.v

set compile_count [expr $compile_count + 34]

#==============================================================================
# 3. Peripherals
#==============================================================================
puts "\[3/7\] Peripherals..."
set PERIPH "${SRC}/peripherals/axi_lite"

vlog -work work ${PERIPH}/axi_lite_ram.v
vlog -work work ${PERIPH}/axi_lite_gpio.v
vlog -work work ${PERIPH}/axi_lite_uart.v
vlog -work work ${PERIPH}/axi_lite_spi.v

set compile_count [expr $compile_count + 4]

#==============================================================================
# 4. AXI Bridge - RISC-V to AXI Converters
#==============================================================================
puts "\[4/7\] AXI Bridge (RISC-V Converters)..."
set BRIDGE "${SRC}/axi_bridge/rtl/riscv_to_axi"

vlog -work work ${BRIDGE}/wb2axi_read.v
vlog -work work ${BRIDGE}/wb2axi_write.v
vlog -work work ${BRIDGE}/serv_axi_wrapper.v
vlog -work work ${BRIDGE}/serv_axi_dualbus_adapter.v

puts "\[4b/7\] System Integration..."
set SYSTEMS "${SRC}/systems"

vlog -work work ${SYSTEMS}/serv_axi_system.v
vlog -work work ${SYSTEMS}/dual_riscv_axi_system.v
vlog -work work ${SYSTEMS}/axi_interconnect_wrapper.v
vlog -work work ${SYSTEMS}/axi_interconnect_2m4s_wrapper.v

set compile_count [expr $compile_count + 8]

#==============================================================================
# 5. SystemVerilog RTL (if needed)
#==============================================================================
puts "\[5/7\] SystemVerilog RTL (optional)..."

# Uncomment if you want to compile SV version:
# set AXI_SV "${SRC}/axi_interconnect/SystemVerilog/rtl"
# vlog -sv -work work ${AXI_SV}/packages/axi_pkg.sv
# vlog -sv -work work ${AXI_SV}/interfaces/axi4_if.sv
# vlog -sv -work work ${AXI_SV}/arbitration/axi_rr_interconnect_2x4.sv
# ... (add more as needed)

puts "Skipped (use Verilog version)"

#==============================================================================
# 6. Verilog Testbenches
#==============================================================================
puts "\[6/7\] Verilog Testbenches..."

vlog -work work ${TB}/interconnect_tb/Verilog/arb_test_verilog.v

# Add component TBs as needed
# vlog -work work ${TB}/interconnect_tb/Verilog_tb/arbitration/Write_Arbiter_tb.v
# ...

set compile_count [expr $compile_count + 1]

#==============================================================================
# 7. System Testbench
#==============================================================================
puts "\[7/7\] System Testbench..."

vlog -sv -work work ${TB}/wrapper_tb/testbenches/dual_riscv/dual_riscv_axi_system_tb.sv

set compile_count [expr $compile_count + 1]

#==============================================================================
# Done
#==============================================================================
puts "\n=========================================="
puts "Compilation Complete!"
puts "=========================================="
puts "Total files compiled: $compile_count"
puts ""
puts "You can now simulate:"
puts "  vsim work.arb_test_verilog"
puts "  vsim work.dual_riscv_axi_system_tb"
puts "=========================================="

