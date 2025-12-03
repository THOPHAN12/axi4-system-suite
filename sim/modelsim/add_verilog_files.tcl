#==============================================================================
# add_verilog_files.tcl
# Add only Verilog (.v) files to ModelSim project
# Usage: do add_verilog_files.tcl
#==============================================================================

puts "=========================================="
puts "Adding Verilog Files (.v) to Project"
puts "=========================================="

set SRC_BASE "../../src"
set TB_BASE "../../tb"

#==============================================================================
# 1. SERV RISC-V Core
#==============================================================================
puts "\n\[1/6\] SERV RISC-V Core..."

set SERV "${SRC_BASE}/cores/serv/rtl"

project addfile ${SERV}/serv_aligner.v
project addfile ${SERV}/serv_alu.v
project addfile ${SERV}/serv_bufreg.v
project addfile ${SERV}/serv_bufreg2.v
project addfile ${SERV}/serv_compdec.v
project addfile ${SERV}/serv_csr.v
project addfile ${SERV}/serv_ctrl.v
project addfile ${SERV}/serv_decode.v
project addfile ${SERV}/serv_immdec.v
project addfile ${SERV}/serv_mem_if.v
project addfile ${SERV}/serv_rf_if.v
project addfile ${SERV}/serv_rf_ram_if.v
project addfile ${SERV}/serv_rf_ram.v
project addfile ${SERV}/serv_rf_top.v
project addfile ${SERV}/serv_state.v
project addfile ${SERV}/serv_top.v

puts "  Added: 16 files"

#==============================================================================
# 2. AXI Interconnect (Verilog)
#==============================================================================
puts "\n\[2/6\] AXI Interconnect (Verilog)..."

set AXI_V "${SRC_BASE}/axi_interconnect/Verilog/rtl"

# Utils
project addfile ${AXI_V}/utils/Raising_Edge_Det.v
project addfile ${AXI_V}/utils/Faling_Edge_Detc.v

# Buffers
project addfile ${AXI_V}/buffers/Queue.v
project addfile ${AXI_V}/buffers/Resp_Queue.v

# Datapath - MUX
project addfile ${AXI_V}/datapath/mux/Mux_2x1.v
project addfile ${AXI_V}/datapath/mux/Mux_2x1_en.v
project addfile ${AXI_V}/datapath/mux/Mux_4x1.v
project addfile ${AXI_V}/datapath/mux/AW_MUX_2_1.v
project addfile ${AXI_V}/datapath/mux/WD_MUX_2_1.v
project addfile ${AXI_V}/datapath/mux/BReady_MUX_2_1.v

# Datapath - DEMUX
project addfile ${AXI_V}/datapath/demux/Demux_1_2.v
project addfile ${AXI_V}/datapath/demux/Demux_1x2.v
project addfile ${AXI_V}/datapath/demux/Demux_1x2_en.v
project addfile ${AXI_V}/datapath/demux/Demux_1x4.v

# Decoders
project addfile ${AXI_V}/decoders/Read_Addr_Channel_Dec.v
project addfile ${AXI_V}/decoders/Write_Addr_Channel_Dec.v
project addfile ${AXI_V}/decoders/Write_Resp_Channel_Dec.v
project addfile ${AXI_V}/decoders/Write_Resp_Channel_Arb.v

# Handshake
project addfile ${AXI_V}/handshake/AW_HandShake_Checker.v
project addfile ${AXI_V}/handshake/WD_HandShake.v
project addfile ${AXI_V}/handshake/WR_HandShake.v

# Arbitration
project addfile ${AXI_V}/arbitration/Write_Arbiter.v
project addfile ${AXI_V}/arbitration/Write_Arbiter_RR.v
project addfile ${AXI_V}/arbitration/Read_Arbiter.v
project addfile ${AXI_V}/arbitration/Qos_Arbiter.v

# Channel Controllers
project addfile ${AXI_V}/channel_controllers/write/AW_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/write/WD_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/write/BR_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/read/Controller.v

# Core - Top-level interconnect
project addfile ${AXI_V}/core/AXI_Interconnect.v
project addfile ${AXI_V}/core/AXI_Interconnect_Full.v
project addfile ${AXI_V}/core/AXI_Interconnect_2S_RDONLY.v

# Main interconnect with configurable arbitration
project addfile ${AXI_V}/arbitration/axi_rr_interconnect_2x4.v

puts "  Added: 34 files"

#==============================================================================
# 3. AXI-Lite Peripherals
#==============================================================================
puts "\n\[3/6\] AXI-Lite Peripherals..."

set PERIPH "${SRC_BASE}/peripherals/axi_lite"

project addfile ${PERIPH}/axi_lite_ram.v
project addfile ${PERIPH}/axi_lite_gpio.v
project addfile ${PERIPH}/axi_lite_uart.v
project addfile ${PERIPH}/axi_lite_spi.v

puts "  Added: 4 files"

#==============================================================================
# 4. AXI Bridge - RISC-V to AXI Converters
#==============================================================================
puts "\n\[4/6\] AXI Bridge (RISC-V Converters)..."

set BRIDGE "${SRC_BASE}/axi_bridge/rtl/riscv_to_axi"

project addfile ${BRIDGE}/wb2axi_read.v
project addfile ${BRIDGE}/wb2axi_write.v
project addfile ${BRIDGE}/serv_axi_wrapper.v
project addfile ${BRIDGE}/serv_axi_dualbus_adapter.v

puts "  Added: 4 files"

#==============================================================================
# 5. System Integration
#==============================================================================
puts "\n\[5/6\] System Integration..."

set SYSTEMS "${SRC_BASE}/systems"

project addfile ${SYSTEMS}/serv_axi_system.v
project addfile ${SYSTEMS}/dual_riscv_axi_system.v
project addfile ${SYSTEMS}/axi_interconnect_wrapper.v
project addfile ${SYSTEMS}/axi_interconnect_2m4s_wrapper.v

puts "  Added: 4 files"

#==============================================================================
# 6. Verilog Testbenches
#==============================================================================
puts "\n\[6/6\] Verilog Testbenches..."

set TB_V "${TB_BASE}/interconnect_tb/Verilog_tb"

# Main arbitration testbench
project addfile ${TB_BASE}/interconnect_tb/Verilog/arb_test_verilog.v

# Component testbenches
project addfile ${TB_V}/arbitration/Write_Arbiter_tb.v
project addfile ${TB_V}/arbitration/Write_Arbiter_RR_tb.v
project addfile ${TB_V}/arbitration/Qos_Arbiter_tb.v

project addfile ${TB_V}/buffers/Queue_tb.v
project addfile ${TB_V}/buffers/Resp_Queue_tb.v

project addfile ${TB_V}/channel_controllers/read/Controller_tb.v
project addfile ${TB_V}/channel_controllers/write/AW_Channel_Controller_Top_tb.v
project addfile ${TB_V}/channel_controllers/write/WD_Channel_Controller_Top_tb.v
project addfile ${TB_V}/channel_controllers/write/BR_Channel_Controller_Top_tb.v

project addfile ${TB_V}/datapath/mux/AW_MUX_2_1_tb.v
project addfile ${TB_V}/datapath/mux/WD_MUX_2_1_tb.v
project addfile ${TB_V}/datapath/mux/BReady_MUX_2_1_tb.v
project addfile ${TB_V}/datapath/mux/Mux_2x1_tb.v
project addfile ${TB_V}/datapath/mux/Mux_2x1_en_tb.v

project addfile ${TB_V}/datapath/demux/Demux_1_2_tb.v
project addfile ${TB_V}/datapath/demux/Demux_1x2_tb.v
project addfile ${TB_V}/datapath/demux/Demux_1x2_en_tb.v

project addfile ${TB_V}/decoders/Write_Addr_Channel_Dec_tb.v
project addfile ${TB_V}/decoders/Write_Resp_Channel_Dec_tb.v

project addfile ${TB_V}/handshake/AW_HandShake_Checker_tb.v
project addfile ${TB_V}/handshake/WD_HandShake_tb.v
project addfile ${TB_V}/handshake/WR_HandShake_tb.v

project addfile ${TB_V}/utils/Raising_Edge_Det_tb.v
project addfile ${TB_V}/utils/Faling_Edge_Detc_tb.v

project addfile ${TB_V}/core/AXI_Interconnect_tb.v

# System testbench
project addfile ${TB_BASE}/wrapper_tb/testbenches/dual_riscv/dual_riscv_axi_system_tb.v

puts "  Added: 27 files"

#==============================================================================
# Summary
#==============================================================================
puts "\n=========================================="
puts "Summary - Verilog Files Only"
puts "=========================================="
puts "SERV Core:          16 files"
puts "Interconnect:       34 files"
puts "Peripherals:        4 files"
puts "AXI Bridge:         4 files"
puts "Systems:            4 files"
puts "Testbenches:        27 files"
puts "----------------------------------------"
puts "TOTAL:              89 Verilog files"
puts "=========================================="
puts ""
puts "✅ All Verilog files added to project!"
puts ""
puts "Next steps:"
puts "  1. Compile All: Right-click → Compile → Compile All"
puts "  2. Or use: do compile_verilog.tcl"
puts "=========================================="

