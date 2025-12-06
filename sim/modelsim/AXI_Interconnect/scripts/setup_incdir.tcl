#==============================================================================
# setup_incdir.tcl
# Set include directories for ModelSim project
#
# Usage: source scripts/setup_incdir.tcl
#==============================================================================

puts "\n======================================================================"
puts "   SETTING UP INCLUDE DIRECTORIES"
puts "======================================================================\n"

# Detect current directory and set paths
set CURRENT_DIR [pwd]
if {[string match "*scripts*" $CURRENT_DIR} {
    set SRC_BASE "../../../src"
} else {
    set SRC_BASE "../../../src"
}

set FRISCV_DIR "${SRC_BASE}/cores/friscv/friscv/rtl"

# Set include directory using vlog command options
# Note: This sets it for the current session
set INCDIR "+incdir+${FRISCV_DIR}"

puts "FRISCV RTL Directory: $FRISCV_DIR"
puts "Include Directory Option: $INCDIR\n"

# For ModelSim, we need to compile files with +incdir option
# This script prepares the environment, but actual compilation
# should use compile_friscv.tcl or compile with +incdir manually

puts "======================================================================"
puts "   INCLUDE DIRECTORY SETUP COMPLETE"
puts "======================================================================\n"
puts "To compile FRISCV files with include directories, use:"
puts "  source scripts/compile_friscv.tcl"
puts "\nOr compile manually with:"
puts "  vlog -work work +incdir+$FRISCV_DIR <file_path>\n"
puts "======================================================================\n"

