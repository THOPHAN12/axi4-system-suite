#==============================================================================
# add_files.tcl
# CHỈ ADD TẤT CẢ FILES VÀO PROJECT - KHÔNG COMPILE
#
# Usage: source add_files.tcl
#==============================================================================

puts "\n======================================================================"
puts "   ADD ALL .V FILES TO PROJECT (UPDATED WITH RV32I!)"
puts "======================================================================\n"

set SRC_BASE "../../../src"

# Check if project is open
if {[project env] == ""} {
    puts "ERROR: No project is open!"
    puts "Please open AXI_Interconnect.mpf first\n"
    return
}

puts "Project: [project env]\n"

set total_count 0

#==============================================================================
# 1. SERV RISC-V Core (16 files)
#==============================================================================
puts "\[1/7\] Adding SERV RISC-V Core files..."

set SERV_DIR "${SRC_BASE}/cores/serv/rtl"
set serv_files {
    serv_aligner.v serv_alu.v serv_bufreg.v serv_bufreg2.v
    serv_compdec.v serv_csr.v serv_ctrl.v serv_decode.v
    serv_immdec.v serv_mem_if.v serv_rf_if.v serv_rf_ram_if.v
    serv_rf_ram.v serv_rf_top.v serv_state.v serv_top.v
}

foreach file $serv_files {
    project addfile ${SERV_DIR}/$file
    incr total_count
}
puts "  -> 16 files added\n"

#==============================================================================
# 2. AXI Interconnect (36 files)
#==============================================================================
puts "\[2/7\] Adding AXI Interconnect files..."

set AXI_V "${SRC_BASE}/axi_interconnect/Verilog/rtl"

# Utils
project addfile ${AXI_V}/utils/Raising_Edge_Det.v
project addfile ${AXI_V}/utils/Faling_Edge_Detc.v
incr total_count 2

# Buffers
project addfile ${AXI_V}/buffers/Queue.v
project addfile ${AXI_V}/buffers/Resp_Queue.v
incr total_count 2

# MUX
project addfile ${AXI_V}/datapath/mux/Mux_2x1.v
project addfile ${AXI_V}/datapath/mux/Mux_2x1_en.v
project addfile ${AXI_V}/datapath/mux/Mux_4x1.v
project addfile ${AXI_V}/datapath/mux/AW_MUX_2_1.v
project addfile ${AXI_V}/datapath/mux/WD_MUX_2_1.v
project addfile ${AXI_V}/datapath/mux/BReady_MUX_2_1.v
incr total_count 6

# DEMUX
project addfile ${AXI_V}/datapath/demux/Demux_1_2.v
project addfile ${AXI_V}/datapath/demux/Demux_1x2.v
project addfile ${AXI_V}/datapath/demux/Demux_1x2_en.v
project addfile ${AXI_V}/datapath/demux/Demux_1x4.v
incr total_count 4

# Decoders
project addfile ${AXI_V}/decoders/Read_Addr_Channel_Dec.v
project addfile ${AXI_V}/decoders/Write_Addr_Channel_Dec.v
project addfile ${AXI_V}/decoders/Write_Resp_Channel_Dec.v
project addfile ${AXI_V}/decoders/Write_Resp_Channel_Arb.v
incr total_count 4

# Handshake
project addfile ${AXI_V}/handshake/AW_HandShake_Checker.v
project addfile ${AXI_V}/handshake/WD_HandShake.v
project addfile ${AXI_V}/handshake/WR_HandShake.v
incr total_count 3

# Arbitration
project addfile ${AXI_V}/arbitration/algorithms/arbiter_fixed_priority.v
project addfile ${AXI_V}/arbitration/algorithms/arbiter_round_robin.v
project addfile ${AXI_V}/arbitration/algorithms/arbiter_qos_based.v
project addfile ${AXI_V}/arbitration/algorithms/read_arbiter.v
incr total_count 4

# Channel Controllers
project addfile ${AXI_V}/channel_controllers/write/AW_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/write/WD_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/write/BR_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/read/AR_Channel_Controller_Top.v
project addfile ${AXI_V}/channel_controllers/read/Controller.v
incr total_count 5

# Core
project addfile ${AXI_V}/core/AXI_Interconnect_Full.v
project addfile ${AXI_V}/core/AXI_Interconnect.v
incr total_count 2

puts "  -> 36 files added\n"

#==============================================================================
# 3. AXI-Lite Peripherals (4 files)
#==============================================================================
puts "\[3/7\] Adding AXI-Lite Peripherals..."

project addfile ${SRC_BASE}/peripherals/axi_lite/axi_lite_ram.v
project addfile ${SRC_BASE}/peripherals/axi_lite/axi_lite_gpio.v
project addfile ${SRC_BASE}/peripherals/axi_lite/axi_lite_uart.v
project addfile ${SRC_BASE}/peripherals/axi_lite/axi_lite_spi.v
incr total_count 4

puts "  -> 4 files added\n"

#==============================================================================
# 4. AXI Bridge (4 files)
#==============================================================================
puts "\[4/7\] Adding AXI Bridge files..."

project addfile ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/wb2axi_read.v
project addfile ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/wb2axi_write.v
project addfile ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/serv_axi_dualbus_adapter.v
project addfile ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/serv_axi_wrapper.v
incr total_count 4

puts "  -> 4 files added\n"

#==============================================================================
# 5. RV32I 5-Stage Pipeline AXI Wrapper (NEW!)
#==============================================================================
puts "\[5/7\] Adding RV32I AXI Wrapper files..."

set RV32I_DIR "${SRC_BASE}/cores/riscv-axi-wrapper"

# Core wrapper files
project addfile ${RV32I_DIR}/rtl/RV32I_PIPELINE_ext.v
project addfile ${RV32I_DIR}/rtl/riscv_pipeline_axi_wrapper.v
incr total_count 2

# Supporting modules from original backup
set rv32i_support_files {
    MUX2v2.v MUX2.v PCv1.v ADD_PC.v IF_ID.v
    CONTROL_PIPELINE.v registerfile_test.v EXTENDv1.v
    ID_EX.v MUX41.v ALU.v ADD.v EX_ME.v ME_WB.v HAZARD_UNIT.v
}

foreach file $rv32i_support_files {
    project addfile ${RV32I_DIR}/original_backup/$file
    incr total_count
}

puts "  -> 17 files added (2 core + 15 support)\n"

#==============================================================================
# 6. Top System (1 file)
#==============================================================================
puts "\[6/7\] Adding Top System file..."

project addfile ${SRC_BASE}/systems/dual_riscv_axi_system.v
incr total_count

puts "  -> 1 file added\n"

#==============================================================================
# 7. Testbench (1 file)
#==============================================================================
puts "\[7/7\] Adding Testbench file..."

project addfile tb_dual_riscv_axi_system.v
incr total_count

puts "  -> 1 file added\n"

#==============================================================================
# Summary
#==============================================================================
puts "======================================================================"
puts "   FILES ADDED TO PROJECT!"
puts "======================================================================\n"
puts "  Breakdown:"
puts "    • SERV Core:          16 files"
puts "    • AXI Interconnect:   36 files"
puts "    • AXI Peripherals:     4 files"
puts "    • AXI Bridge:          4 files"
puts "    • RV32I AXI Wrapper:  17 files ✅ NEW!"
puts "    • Top System:          1 file"
puts "    • Testbench:           1 file"
puts ""
puts "  Total: $total_count files\n"
puts "  Files are now visible in Project window\n"
puts "======================================================================"
puts "   NEXT STEPS (Do these manually):"
puts "======================================================================\n"
puts "  1. Compile all files:"
puts "     Compile -> Compile All"
puts ""
puts "  2. Run testbench:"
puts "     Simulate -> Start Simulation"
puts "     Select: work.tb_dual_riscv_axi_system"
puts "     Click OK"
puts "     In console: run -all\n"
puts "======================================================================\n"

