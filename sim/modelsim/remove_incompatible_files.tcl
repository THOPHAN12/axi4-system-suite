#==============================================================================
# remove_incompatible_files.tcl
# Remove files incompatible with ModelSim 10.1d from project
# Usage: In ModelSim TCL Console, type: do remove_incompatible_files.tcl
#==============================================================================

puts "============================================================================"
puts "Remove Incompatible Files from Project"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR
set PROJECT_FILE [file normalize [file join $PROJECT_DIR "AXI_Project.mpf"]]

# Check if project is open
if {[catch {set current_project [project]} err]} {
    puts "Opening project: $PROJECT_FILE"
    if {[file exists $PROJECT_FILE]} {
        if {[catch {project open $PROJECT_FILE} open_err]} {
            puts "ERROR: Cannot open project: $open_err"
            return
        } else {
            puts "Project opened successfully!"
        }
    } else {
        puts "ERROR: Project file not found: $PROJECT_FILE"
        return
    }
} else {
    puts "Project already open: $current_project"
}

puts ""
puts "Removing incompatible files..."
puts ""

# List of patterns to remove (incompatible with ModelSim 10.1d)
set remove_patterns [list \
    "*_tb_pkg.sv" \
    "*uvm*.sv" \
    "*agent*.sv" \
    "*sequence*.sv" \
    "*test*.sv" \
    "*env*.sv" \
    "*scoreboard*.sv" \
    "*coverage*.sv" \
    "*config*.sv" \
]

# Get all files in project
set all_files [project filenames]
set removed_count 0

foreach file $all_files {
    set file_name [file tail $file]
    set should_remove 0
    
    foreach pattern $remove_patterns {
        if {[string match $pattern $file_name]} {
            set should_remove 1
            break
        }
    }
    
    # Also check if file contains SystemVerilog classes (UVM, etc.)
    if {$should_remove} {
        if {[catch {project removefile $file} err]} {
            # File might not be in project, that's okay
        } else {
            puts "  ✓ Removed: $file_name"
            incr removed_count
        }
    }
}

puts ""
puts "============================================================================"
puts "SUMMARY"
puts "============================================================================"
puts "Files removed: $removed_count"
puts ""
puts "Removed files include:"
puts "  - SystemVerilog testbench packages (*_tb_pkg.sv)"
puts "  - UVM verification files (*uvm*.sv)"
puts "  - Files with SystemVerilog classes"
puts ""
puts "These files are incompatible with ModelSim 10.1d"
puts "Use Verilog testbenches or upgrade to newer ModelSim/QuestaSim"
puts "============================================================================"

