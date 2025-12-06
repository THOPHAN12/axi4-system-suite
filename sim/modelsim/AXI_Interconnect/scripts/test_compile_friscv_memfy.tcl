#==============================================================================
# test_compile_friscv_memfy.tcl
# Test compile friscv_memfy_h.sv with proper include directory
#
# Usage: source scripts/test_compile_friscv_memfy.tcl
#==============================================================================

puts "\n======================================================================"
puts "   TEST COMPILE FRISCV_MEMFY_H.SV"
puts "======================================================================\n"

# Detect current directory and set paths
set CURRENT_DIR [pwd]
if {[string match "*scripts*" $CURRENT_DIR} {
    set SRC_BASE "../../../src"
} else {
    set SRC_BASE "../../../src"
}

set FRISCV_DIR "${SRC_BASE}/cores/friscv/friscv/rtl"

# Set include directory
set INCDIR "+incdir+${FRISCV_DIR}"

puts "FRISCV RTL Directory: $FRISCV_DIR"
puts "Include Directory: $INCDIR\n"

# First, compile friscv_h.sv to ensure XLEN is defined
puts "Step 1: Compiling friscv_h.sv...\n"
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_h.sv

# Then compile friscv_memfy_h.sv
puts "\nStep 2: Compiling friscv_memfy_h.sv...\n"
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_memfy_h.sv

puts "\n======================================================================"
puts "   TEST COMPILATION COMPLETE!"
puts "======================================================================\n"

