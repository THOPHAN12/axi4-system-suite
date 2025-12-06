#==============================================================================
# compile_all.tcl
# Compile all files with correct include directories
#
# Usage: source scripts/compile_all.tcl
#==============================================================================

puts "\n======================================================================"
puts "   COMPILING ALL FILES WITH INCLUDE DIRECTORIES"
puts "======================================================================\n"

# Detect current directory and set paths
set CURRENT_DIR [pwd]
if {[string match "*scripts*" $CURRENT_DIR} {
    set SRC_BASE "../../../src"
} else {
    set SRC_BASE "../../../src"
}

set FRISCV_DIR "${SRC_BASE}/cores/friscv/friscv/rtl"

# Set include directories
set INCDIRS "+incdir+${FRISCV_DIR}"

puts "Include Directories: $INCDIRS\n"

# Compile in correct order with include directories

# 1. FRISCV Headers (must be first)
puts "\[1\] Compiling FRISCV headers...\n"
vlog -work work $INCDIRS ${FRISCV_DIR}/friscv_h.sv
vlog -work work $INCDIRS ${FRISCV_DIR}/friscv_debug_h.sv
vlog -work work $INCDIRS ${FRISCV_DIR}/friscv_memfy_h.sv
vlog -work work $INCDIRS ${FRISCV_DIR}/friscv_control_h.sv
vlog -work work $INCDIRS ${FRISCV_DIR}/friscv_checkers.sv

# 2. Compile all other files (ModelSim will skip already compiled files)
puts "\n\[2\] Compiling all other files...\n"
puts "Note: Use 'Compile -> Compile All' from GUI, or compile files individually\n"
puts "For FRISCV files, use: source scripts/compile_friscv.tcl\n"

puts "\n======================================================================"
puts "   COMPILATION SCRIPT READY"
puts "======================================================================\n"
puts "For best results, compile FRISCV files first with:"
puts "  source scripts/compile_friscv.tcl"
puts "\nThen compile other files normally.\n"
puts "======================================================================\n"

