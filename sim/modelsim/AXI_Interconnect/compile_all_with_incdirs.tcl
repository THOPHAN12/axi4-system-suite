# ============================================================================
# ModelSim TCL Script - Compile All Files with Include Directories
# ============================================================================
# This script compiles all files that failed in GUI with proper include directories
# Run this from ModelSim GUI: source compile_all_with_incdirs.tcl
# ============================================================================

puts "============================================================================"
puts "Compiling All Files with Include Directories"
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
    [file normalize [file join $SRC_BASE "axi_bridge"]] \
    [file normalize [file join $SRC_BASE "systems"]] \
    [file normalize [file join $SRC_BASE "peripherals" "axi_lite"]] \
]

# Build +incdir+ list
set incdirs_list [list]
foreach dir $INC_DIRS {
    lappend incdirs_list "+incdir+$dir"
}

puts "Include directories:"
foreach dir $INC_DIRS {
    puts "  +incdir+$dir"
}
puts ""

set compile_count 0
set error_count 0

# Files that need include directories
set files_to_compile [list \
    [file normalize [file join $SRC_BASE "axi_bridge" "serv_axi_wrapper.v"]] \
    [file normalize [file join $SRC_BASE "systems" "dual_axi_shell.v"]] \
    [file normalize [file join $SRC_BASE "systems" "dual_pipeline_serv_axi_system_aggregators.v"]] \
    [file normalize [file join $SRC_BASE "systems" "dual_serv_axi_system.v"]] \
]

puts "============================================================================"
puts "Compiling files with include directories..."
puts "============================================================================"
puts ""

foreach file $files_to_compile {
    set filename [file tail $file]
    puts "Compiling: $filename"
    
    if {[catch {eval [list vlog -work work] $incdirs_list [list $file]} err]} {
        puts "  ✗ ERROR: $err"
        incr error_count
    } else {
        puts "  ✓ SUCCESS"
        incr compile_count
    }
    puts ""
}

puts "============================================================================"
puts "COMPILATION SUMMARY"
puts "============================================================================"
puts "Files compiled successfully: $compile_count"
puts "Files with errors: $error_count"
puts "============================================================================"



