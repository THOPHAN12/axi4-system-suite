#==============================================================================
# compile_friscv.tcl
# Compile FRISCV files with correct include directories
#
# Usage: source scripts/compile_friscv.tcl
#==============================================================================

puts "\n======================================================================"
puts "   COMPILING FRISCV FILES WITH INCLUDE DIRECTORIES"
puts "======================================================================\n"

# Detect current directory and set paths
set CURRENT_DIR [pwd]
if {[string match "*scripts*" $CURRENT_DIR]} {
    set SRC_BASE "../../../src"
} else {
    set SRC_BASE "../../../src"
}

set FRISCV_DIR "${SRC_BASE}/cores/friscv/friscv/rtl"

# Set include directory for FRISCV
set INCDIR "+incdir+${FRISCV_DIR}"

puts "FRISCV RTL Directory: $FRISCV_DIR"
puts "Include Directory: $INCDIR\n"

# Compile FRISCV header files first (in correct order)
puts "\[1/6\] Compiling FRISCV header files...\n"

vlog -work work $INCDIR ${FRISCV_DIR}/friscv_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_debug_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_memfy_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_control_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_checkers.sv

puts "\n\[2/6\] Compiling FRISCV core...\n"
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_rv32i_core.sv

puts "\n\[3/6\] Compiling AXI Width Adapter...\n"
vlog -work work ${SRC_BASE}/axi_bridge/rtl/axi_width_adapter_128to32.sv

puts "\n\[4/6\] Compiling FRISCV AXI System...\n"
vlog -work work ${SRC_BASE}/systems/friscv_axi_system.sv

puts "\n\[5/6\] Compiling FRISCV Testbench...\n"
# Set testbench base path
if {[string match "*scripts*" $CURRENT_DIR]} {
    set TB_BASE "../testbenches"
} else {
    set TB_BASE "testbenches"
}
vlog -work work $INCDIR ${TB_BASE}/tb_friscv_auto_verify.sv

puts "\n======================================================================"
puts "   FRISCV COMPILATION COMPLETE!"
puts "======================================================================\n"

