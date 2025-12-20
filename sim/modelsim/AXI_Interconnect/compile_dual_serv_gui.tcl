# ============================================================================
# ModelSim TCL Script - Compile dual_serv_axi_system.v for GUI
# ============================================================================
# This script compiles dual_serv_axi_system.v with proper include directories
# Run this from ModelSim GUI: Tools -> TCL -> Execute Macro, or type: source compile_dual_serv_gui.tcl
# ============================================================================

puts "============================================================================"
puts "Compiling dual_serv_axi_system.v"
puts "============================================================================"

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. .. ..]]
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]

puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts ""

# Set include directories
set INC_DIRS [list \
    [file normalize [file join $SRC_BASE]] \
    [file normalize [file join $SRC_BASE "cores"]] \
    [file normalize [file join $SRC_BASE "cores" "serv" "rtl"]] \
    [file normalize [file join $SRC_BASE "axi_interconnect" "rtl" "core"]] \
]

# Build +incdir+ string - each directory needs to be a separate argument
set incdirs_list [list]
foreach dir $INC_DIRS {
    lappend incdirs_list "+incdir+$dir"
}

puts "Include directories:"
foreach dir $INC_DIRS {
    puts "  +incdir+$dir"
}
puts ""

# File to compile
set FILE_TO_COMPILE [file normalize [file join $SRC_BASE "systems" "dual_serv_axi_system.v"]]

puts "Compiling: $FILE_TO_COMPILE"
puts ""

# Compile - use list expansion to properly handle paths with spaces
if {[catch {eval [list vlog -work work] $incdirs_list [list $FILE_TO_COMPILE]} err]} {
    puts "============================================================================"
    puts "ERROR: Compilation failed!"
    puts "============================================================================"
    puts $err
    puts "============================================================================"
} else {
    puts "============================================================================"
    puts "SUCCESS: File compiled successfully!"
    puts "============================================================================"
    puts ""
    puts "Top level module: dual_serv_axi_system"
    puts ""
    puts "You can now simulate the design using:"
    puts "  vsim work.dual_serv_axi_system"
    puts "============================================================================"
}

