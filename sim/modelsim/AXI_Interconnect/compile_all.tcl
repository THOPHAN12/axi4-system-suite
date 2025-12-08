# ==============================================================================
# ModelSim TCL Script - Compile All Files in Correct Order
# ==============================================================================
# This script compiles all files in the correct dependency order
# with proper include directories set
# ==============================================================================

set PROJECT_DIR "D:/AXI"
set SRC_DIR "$PROJECT_DIR/src"
set VERIF_DIR "$PROJECT_DIR/verification"
set RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline"

# Create work library if it doesn't exist
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

puts "\n=========================================="
puts "Compiling All Files in Correct Order"
puts "==========================================\n"

# ==============================================================================
# STEP 1: AXI Interconnect Files (No dependencies)
# ==============================================================================
puts "Step 1: Compiling AXI Interconnect files..."

# Utils (used by other modules)
vlog -work work "$SRC_DIR/axi_interconnect/rtl/utils/Raising_Edge_Det.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/utils/Faling_Edge_Detc.v"

# Buffers
vlog -work work "$SRC_DIR/axi_interconnect/rtl/buffers/Queue.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/buffers/Resp_Queue.v"

# Arbitration algorithms
vlog -work work "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/arbiter_round_robin.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/arbiter_fixed_priority.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/arbiter_qos_based.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/read_arbiter.v"

# Handshake modules
vlog -work work "$SRC_DIR/axi_interconnect/rtl/handshake/AW_HandShake_Checker.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/handshake/WD_HandShake.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/handshake/WR_HandShake.v"

# Mux/Demux modules
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/mux/Mux_2x1.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/mux/Mux_2x1_en.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/mux/Mux_4x1.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/mux/AW_MUX_2_1.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/mux/WD_MUX_2_1.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/mux/BReady_MUX_2_1.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1x2.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1x2_en.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1x4.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1_2.v"

# Decoders
vlog -work work "$SRC_DIR/axi_interconnect/rtl/decoders/Write_Addr_Channel_Dec.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/decoders/Read_Addr_Channel_Dec.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/decoders/Write_Resp_Channel_Dec.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/decoders/Write_Resp_Channel_Arb.v"

# Channel Controllers - Read
vlog -work work "$SRC_DIR/axi_interconnect/rtl/channel_controllers/read/Controller.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/channel_controllers/read/AR_Channel_Controller_Top.v"

# Channel Controllers - Write
vlog -work work "$SRC_DIR/axi_interconnect/rtl/channel_controllers/write/AW_Channel_Controller_Top.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/channel_controllers/write/WD_Channel_Controller_Top.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/channel_controllers/write/BR_Channel_Controller_Top.v"

# Core Interconnect modules
vlog -work work "$SRC_DIR/axi_interconnect/rtl/core/AXI_Interconnect.v"
vlog -work work "$SRC_DIR/axi_interconnect/rtl/core/AXI_Interconnect_Full.v"

# ==============================================================================
# STEP 2: RISC-V Core Files - Compile in Dependency Order
# ==============================================================================
puts "\nStep 2: Compiling RISC-V 5-stage Pipeline core files..."

# Set include directory for RISC-V core
# RV32I_PIPELINE.v uses paths like "rtl/datapath/..." so +incdir+ must point to parent of rtl/

# 2.1: Datapath modules (no dependencies)
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/ADD.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/ADD_PC.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/ALU.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/EXTENDv1.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX2.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX2v2.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX41.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/PCv1.v"

# 2.2: Pipeline registers (may depend on datapath)
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/IF_ID.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/ID_EX.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/EX_ME.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/ME_WB.v"

# 2.3: Control modules
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/control/CONTROL.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/control/CONTROL_PIPELINE.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/control/HAZARD_UNIT.v"

# 2.4: Memory modules
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/REGISTERFILE.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/registerfile_test.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/IMEM.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/DMEM.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/WRAPPER_DMEM.v"

# 2.5: Core modules (depend on all above)
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/core/RV32I.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/core/RV32I_test.v"
vlog -work work +incdir+$RISC_CORE_BASE "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/core/RV32I_PIPELINE.v"

# ==============================================================================
# STEP 3: Peripheral Files (No dependencies)
# ==============================================================================
puts "\nStep 3: Compiling Peripheral files..."

vlog -work work "$SRC_DIR/peripherals/axi_lite/axi_lite_ram.v"
vlog -work work "$SRC_DIR/peripherals/axi_lite/axi_lite_gpio.v"
vlog -work work "$SRC_DIR/peripherals/axi_lite/axi_lite_uart.v"
vlog -work work "$SRC_DIR/peripherals/axi_lite/axi_lite_spi.v"

# ==============================================================================
# STEP 4: SERV RISC-V Core Files (Only RTL, no platform-specific files)
# ==============================================================================
puts "\nStep 4: Compiling SERV RISC-V core files (RTL only)..."

set SERV_RTL_DIR "$SRC_DIR/cores/serv/rtl"

# SERV core RTL files (compile in dependency order)
# Note: We skip platform-specific files in servant/ directory as they have syntax issues
vlog -work work "$SERV_RTL_DIR/serv_aligner.v"
vlog -work work "$SERV_RTL_DIR/serv_alu.v"
vlog -work work "$SERV_RTL_DIR/serv_bufreg.v"
vlog -work work "$SERV_RTL_DIR/serv_bufreg2.v"
vlog -work work "$SERV_RTL_DIR/serv_compdec.v"
vlog -work work "$SERV_RTL_DIR/serv_csr.v"
vlog -work work "$SERV_RTL_DIR/serv_ctrl.v"
vlog -work work "$SERV_RTL_DIR/serv_debug.v"
vlog -work work "$SERV_RTL_DIR/serv_decode.v"
vlog -work work "$SERV_RTL_DIR/serv_immdec.v"
vlog -work work "$SERV_RTL_DIR/serv_mem_if.v"
vlog -work work "$SERV_RTL_DIR/serv_rf_if.v"
vlog -work work "$SERV_RTL_DIR/serv_rf_ram_if.v"
vlog -work work "$SERV_RTL_DIR/serv_rf_ram.v"
vlog -work work "$SERV_RTL_DIR/serv_rf_top.v"
vlog -work work "$SERV_RTL_DIR/serv_state.v"
vlog -work work "$SERV_RTL_DIR/serv_synth_wrapper.v"
vlog -work work "$SERV_RTL_DIR/serv_top.v"

# ==============================================================================
# STEP 5: AXI Bridge Files (Depend on RISC-V cores)
# ==============================================================================
puts "\nStep 5: Compiling AXI Bridge files..."

vlog -work work +incdir+$SRC_DIR/axi_bridge +incdir+$RISC_CORE_BASE +incdir+$SERV_RTL_DIR "$SRC_DIR/axi_bridge/riscv_pipeline_axi_wrapper.v"
vlog -work work +incdir+$SRC_DIR/axi_bridge +incdir+$SERV_RTL_DIR "$SRC_DIR/axi_bridge/serv_axi_wrapper.v"
vlog -work work +incdir+$SRC_DIR/axi_bridge "$SRC_DIR/axi_bridge/friscv_axi_wrapper.v"
vlog -work work +incdir+$SRC_DIR/axi_bridge +incdir+$RISC_CORE_BASE +incdir+$SERV_RTL_DIR "$SRC_DIR/axi_bridge/triple_riscv_axi_bridge.v"

# ==============================================================================
# STEP 6: System Files (Depend on Bridge and Peripherals)
# ==============================================================================
puts "\nStep 6: Compiling System files..."

vlog -work work +incdir+$SRC_DIR/systems +incdir+$SRC_DIR/axi_bridge +incdir+$RISC_CORE_BASE +incdir+$SERV_RTL_DIR +incdir+$SRC_DIR/axi_interconnect/rtl/core +incdir+$SRC_DIR/peripherals/axi_lite "$SRC_DIR/systems/triple_riscv_axi_system.v"

# ==============================================================================
# STEP 7: Testbench Files (Depend on System)
# ==============================================================================
puts "\nStep 7: Compiling Testbench files..."

vlog -work work +incdir+$SRC_DIR/systems +incdir+$SRC_DIR/axi_bridge +incdir+$RISC_CORE_BASE +incdir+$SERV_RTL_DIR +incdir+$SRC_DIR/axi_interconnect/rtl/core +incdir+$SRC_DIR/peripherals/axi_lite "$VERIF_DIR/testbenches/interconnect_tb/system/triple_riscv_axi_system_tb.v"

# ==============================================================================
# Compilation Summary
# ==============================================================================
puts "\n=========================================="
puts "Compilation Complete!"
puts "=========================================="
puts "All files compiled in correct dependency order"
puts "Ready for simulation!"
puts "==========================================\n"

