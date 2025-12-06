#==============================================================================
# add_files.tcl
# CHỈ ADD TẤT CẢ FILES VÀO PROJECT - KHÔNG COMPILE
# Với kiểm tra file tồn tại cho TẤT CẢ files
#
# Usage: source scripts/add_files.tcl
# Note: Script này nằm trong thư mục scripts/, testbenches nằm trong testbenches/
#==============================================================================

puts "\n======================================================================"
puts "   ADD ALL .V/.SV FILES TO PROJECT (UPDATED - NO QoS, WITH FRISCV!)"
puts "======================================================================\n"

# Detect current directory and set paths accordingly
set CURRENT_DIR [pwd]

if {[string match "*scripts*" $CURRENT_DIR]} {
    # Running from scripts/ directory
    set SRC_BASE "../../../src"
    set PROJECT_FILE "../project/AXI_Project.mpf"
} else {
    # Running from root directory
    set SRC_BASE "../../../src"
    set PROJECT_FILE "project/AXI_Project.mpf"
}

# Try to open project if not already open
if {[project env] == ""} {
    puts "No project is open. Attempting to open project..."
    
    # Check if project file exists
    if {[file exists $PROJECT_FILE]} {
        project open $PROJECT_FILE
        puts "✓ Project opened: $PROJECT_FILE\n"
    } else {
        puts "ERROR: Project file not found!"
        puts "Expected location: $PROJECT_FILE"
        puts "Current directory: $CURRENT_DIR"
        puts "\nPlease open project manually:"
        puts "  project open project/AXI_Project.mpf"
        puts "Or use fix_project.tcl from root directory:\n"
        puts "  source scripts/fix_project.tcl\n"
        return
    }
}

puts "Project: [project env]\n"

set total_count 0
set missing_count 0

# Helper procedure to add file with existence check
proc safe_add_file {file_path} {
    global total_count missing_count
    
    if {[file exists $file_path]} {
        project addfile $file_path
        incr total_count
        return 1
    } else {
        puts "  ⚠ Warning: File not found: $file_path"
        incr missing_count
        return 0
    }
}

#==============================================================================
# 1. SERV RISC-V Core (16 files)
#==============================================================================
puts "\[1/8\] Adding SERV RISC-V Core files..."

set SERV_DIR "${SRC_BASE}/cores/serv/rtl"
set serv_files {
    serv_aligner.v serv_alu.v serv_bufreg.v serv_bufreg2.v
    serv_compdec.v serv_csr.v serv_ctrl.v serv_decode.v
    serv_immdec.v serv_mem_if.v serv_rf_if.v serv_rf_ram_if.v
    serv_rf_ram.v serv_rf_top.v serv_state.v serv_top.v
}

set serv_added 0
foreach file $serv_files {
    if {[safe_add_file ${SERV_DIR}/$file]} {
        incr serv_added
    }
}
puts "  -> $serv_added files added\n"

#==============================================================================
# 2. AXI Interconnect (35 files - removed QoS arbiter)
#==============================================================================
puts "\[2/8\] Adding AXI Interconnect files..."

set AXI_V "${SRC_BASE}/axi_interconnect/Verilog/rtl"
set axi_added 0

# Utils
if {[safe_add_file ${AXI_V}/utils/Raising_Edge_Det.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/utils/Faling_Edge_Detc.v]} { incr axi_added }

# Buffers
if {[safe_add_file ${AXI_V}/buffers/Queue.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/buffers/Resp_Queue.v]} { incr axi_added }

# MUX
if {[safe_add_file ${AXI_V}/datapath/mux/Mux_2x1.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/mux/Mux_2x1_en.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/mux/Mux_4x1.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/mux/AW_MUX_2_1.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/mux/WD_MUX_2_1.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/mux/BReady_MUX_2_1.v]} { incr axi_added }

# DEMUX
if {[safe_add_file ${AXI_V}/datapath/demux/Demux_1_2.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/demux/Demux_1x2.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/demux/Demux_1x2_en.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/datapath/demux/Demux_1x4.v]} { incr axi_added }

# Decoders
if {[safe_add_file ${AXI_V}/decoders/Read_Addr_Channel_Dec.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/decoders/Write_Addr_Channel_Dec.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/decoders/Write_Resp_Channel_Dec.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/decoders/Write_Resp_Channel_Arb.v]} { incr axi_added }

# Handshake
if {[safe_add_file ${AXI_V}/handshake/AW_HandShake_Checker.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/handshake/WD_HandShake.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/handshake/WR_HandShake.v]} { incr axi_added }

# Arbitration (3 algorithms: Fixed Priority, Round Robin 1, Round Robin 2)
# Note: QoS-based removed - using Round Robin 2 instead
if {[safe_add_file ${AXI_V}/arbitration/algorithms/arbiter_fixed_priority.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/arbitration/algorithms/arbiter_round_robin.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/arbitration/algorithms/read_arbiter.v]} { incr axi_added }

# Channel Controllers
if {[safe_add_file ${AXI_V}/channel_controllers/write/AW_Channel_Controller_Top.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/channel_controllers/write/WD_Channel_Controller_Top.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/channel_controllers/write/BR_Channel_Controller_Top.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/channel_controllers/read/AR_Channel_Controller_Top.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/channel_controllers/read/Controller.v]} { incr axi_added }

# Core
if {[safe_add_file ${AXI_V}/core/AXI_Interconnect_Full.v]} { incr axi_added }
if {[safe_add_file ${AXI_V}/core/AXI_Interconnect.v]} { incr axi_added }

puts "  -> $axi_added files added (removed QoS arbiter)\n"

#==============================================================================
# 3. AXI-Lite Peripherals (4 files)
#==============================================================================
puts "\[3/8\] Adding AXI-Lite Peripherals..."

set peri_added 0
if {[safe_add_file ${SRC_BASE}/peripherals/axi_lite/axi_lite_ram.v]} { incr peri_added }
if {[safe_add_file ${SRC_BASE}/peripherals/axi_lite/axi_lite_gpio.v]} { incr peri_added }
if {[safe_add_file ${SRC_BASE}/peripherals/axi_lite/axi_lite_uart.v]} { incr peri_added }
if {[safe_add_file ${SRC_BASE}/peripherals/axi_lite/axi_lite_spi.v]} { incr peri_added }

puts "  -> $peri_added files added\n"

#==============================================================================
# 4. AXI Bridge (4 files)
#==============================================================================
puts "\[4/8\] Adding AXI Bridge files..."

set bridge_added 0
if {[safe_add_file ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/wb2axi_read.v]} { incr bridge_added }
if {[safe_add_file ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/wb2axi_write.v]} { incr bridge_added }
if {[safe_add_file ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/serv_axi_dualbus_adapter.v]} { incr bridge_added }
if {[safe_add_file ${SRC_BASE}/axi_bridge/rtl/legacy/serv_bridge/serv_axi_wrapper.v]} { incr bridge_added }

puts "  -> $bridge_added files added\n"

#==============================================================================
# 5. RV32I 5-Stage Pipeline Core Files
#==============================================================================
puts "\[5/8\] Adding RV32I Pipeline Core files..."

set RV32I_DIR "${SRC_BASE}/cores/riscv-5stage-pipeline/RV32I_Pipeline"
set rv32i_added 0

# Core pipeline file
if {[safe_add_file ${RV32I_DIR}/RV32I_PIPELINE.v]} {
    incr rv32i_added
    puts "  ✓ Added: RV32I_PIPELINE.v"
}

# Supporting modules
set rv32i_support_files {
    MUX2v2.v MUX2.v PCv1.v ADD_PC.v IF_ID.v
    CONTROL_PIPELINE.v registerfile_test.v EXTENDv1.v
    ID_EX.v MUX41.v ALU.v ADD.v EX_ME.v ME_WB.v HAZARD_UNIT.v
}

foreach file $rv32i_support_files {
    if {[safe_add_file ${RV32I_DIR}/$file]} {
        incr rv32i_added
    }
}

puts "  -> $rv32i_added files added\n"

#==============================================================================
# 6. FRISCV Core and AXI Width Adapter
#==============================================================================
puts "\[6/8\] Adding FRISCV Core and AXI Bridge files..."

set FRISCV_DIR "${SRC_BASE}/cores/friscv/friscv/rtl"
set friscv_added 0

# FRISCV Header files (must be compiled first)
if {[safe_add_file ${FRISCV_DIR}/friscv_h.sv]} { incr friscv_added }
if {[safe_add_file ${FRISCV_DIR}/friscv_debug_h.sv]} { incr friscv_added }
if {[safe_add_file ${FRISCV_DIR}/friscv_memfy_h.sv]} { incr friscv_added }
if {[safe_add_file ${FRISCV_DIR}/friscv_control_h.sv]} { incr friscv_added }
if {[safe_add_file ${FRISCV_DIR}/friscv_checkers.sv]} { incr friscv_added }

# FRISCV Core (SystemVerilog) - depends on headers
if {[safe_add_file ${FRISCV_DIR}/friscv_rv32i_core.sv]} { incr friscv_added }

# AXI Width Adapter (128-bit to 32-bit)
if {[safe_add_file ${SRC_BASE}/axi_bridge/rtl/axi_width_adapter_128to32.sv]} { incr friscv_added }

puts "  -> $friscv_added files added (headers + FRISCV core + width adapter)\n"

#==============================================================================
# 7. Top System Files
#==============================================================================
puts "\[7/8\] Adding Top System files..."

set system_added 0
# Dual RISC-V System (SERV)
if {[safe_add_file ${SRC_BASE}/systems/dual_riscv_axi_system.v]} { incr system_added }

# FRISCV AXI System (SystemVerilog)
if {[safe_add_file ${SRC_BASE}/systems/friscv_axi_system.sv]} { incr system_added }

# RISC-V Pipeline System (Note: requires riscv_pipeline_axi_wrapper which may not exist)
if {[safe_add_file ${SRC_BASE}/systems/riscv_pipeline_axi_system.v]} { incr system_added }

puts "  -> $system_added files added\n"

#==============================================================================
# 8. Testbenches (multiple files)
#==============================================================================
puts "\[8/8\] Adding Testbench files..."

# Set testbench base path based on current directory
if {[string match "*scripts*" $CURRENT_DIR]} {
    set TB_BASE "../testbenches"
} else {
    set TB_BASE "testbenches"
}

set tb_added 0

# Main testbenches
if {[safe_add_file ${TB_BASE}/tb_dual_riscv_axi_system.v]} { incr tb_added }
if {[safe_add_file ${TB_BASE}/tb_friscv_auto_verify.sv]} { incr tb_added }
if {[safe_add_file ${TB_BASE}/tb_friscv_comprehensive.sv]} { incr tb_added }
if {[safe_add_file ${TB_BASE}/tb_riscv_pipeline_system.v]} { incr tb_added }

# Additional testbenches
if {[safe_add_file ${TB_BASE}/tb_arbitration_test.v]} { incr tb_added }
if {[safe_add_file ${TB_BASE}/tb_arithmetic_memory.v]} { incr tb_added }
if {[safe_add_file ${TB_BASE}/tb_multi_testcase.v]} { incr tb_added }
if {[safe_add_file ${TB_BASE}/tb_peripheral_coverage.v]} { incr tb_added }

puts "  -> $tb_added testbench files added\n"

#==============================================================================
# Summary
#==============================================================================
puts "======================================================================"
puts "   FILES ADDED TO PROJECT!"
puts "======================================================================\n"
puts "  Breakdown:"
puts "    • SERV Core:          $serv_added files"
puts "    • AXI Interconnect:   $axi_added files (removed QoS arbiter)"
puts "    • AXI Peripherals:   $peri_added files"
puts "    • AXI Bridge:        $bridge_added files"
puts "    • RV32I Pipeline:    $rv32i_added files"
puts "    • FRISCV:            $friscv_added files (headers + core + adapter)"
puts "    • Top Systems:       $system_added files"
puts "    • Testbenches:       $tb_added files"
puts ""
puts "  Total: $total_count files added"
if {$missing_count > 0} {
    puts "  ⚠ Warning: $missing_count file(s) not found (see warnings above)"
}
puts ""
puts "  Files are now visible in Project window\n"
puts "======================================================================"
puts "   NEXT STEPS (Do these manually):"
puts "======================================================================\n"
puts "  1. Compile all files:"
puts "     Compile -> Compile All"
puts ""
puts "     Note: FRISCV headers will be compiled first (correct order)"
puts ""
puts "  2. If compilation errors occur:"
puts "     source scripts/fix_project.tcl"
puts "     compile_all"
puts ""
puts "  3. Run testbench:"
puts "     Simulate -> Start Simulation"
puts "     Select one of:"
puts "       - work.tb_dual_riscv_axi_system (SERV dual core)"
puts "       - work.tb_friscv_auto_verify (FRISCV system)"
puts "       - work.tb_riscv_pipeline_system (RV32I pipeline - may need wrapper)"
puts "     Click OK"
puts "     In console: run -all\n"
puts "======================================================================"
puts "   NOTE:"
puts "======================================================================\n"
puts "  • Testbenches are in: testbenches/"
puts "  • Test data files are in: testdata/"
puts "  • Project files are in: project/"
puts "  • FRISCV headers must compile before core (order is correct)"
puts "  • riscv_pipeline_axi_system.v requires riscv_pipeline_axi_wrapper (may not exist)\n"
puts "======================================================================\n"
