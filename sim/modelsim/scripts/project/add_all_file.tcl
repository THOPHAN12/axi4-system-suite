# ============================================================================
# Alias script - redirects to add_all_files.tcl
# ============================================================================
# This file exists for convenience (shorter name)
# It simply sources the main script

# Try to get script directory from [info script]
set script_file [info script]
if {[string equal $script_file ""] || ![file exists $script_file]} {
    # Fallback: use hardcoded path
    set script_dir "D:/AXI/sim/modelsim/scripts/project"
} else {
    set script_dir [file dirname [file normalize $script_file]]
}

# Source the main script
set main_script [file join $script_dir "add_all_files.tcl"]
if {[file exists $main_script]} {
    source $main_script
} else {
    # Final fallback: use absolute path
    source "D:/AXI/sim/modelsim/scripts/project/add_all_files.tcl"
}

