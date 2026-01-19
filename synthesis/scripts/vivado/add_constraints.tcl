#==============================================================================
# Add Constraints to Vivado Project
#==============================================================================
# This script adds the AXI Interconnect constraints file to the current project
#
# Usage: In Vivado TCL Console:
#   source add_constraints.tcl
# Or with full path:
#   source [file normalize "synthesis/scripts/vivado/add_constraints.tcl"]
#==============================================================================

puts "============================================================================"
puts "Adding Constraints to Vivado Project"
puts "============================================================================"
puts ""

# Get script directory and calculate constraints file path
# Handle paths with spaces properly
if {[info exists ::env(PWD)]} {
    set current_dir $::env(PWD)
} else {
    set current_dir [pwd]
}

# Try to get script location
if {[info script] != ""} {
    set script_path [file normalize [info script]]
    set script_dir [file dirname $script_path]
} else {
    # Fallback: use project directory
    if {![catch {current_project} err]} {
        set proj_dir [get_property DIRECTORY [current_project]]
        set script_dir [file normalize [file join $proj_dir ".." ".." "scripts" "vivado"]]
    } else {
        # Last resort: assume we're in project root
        set script_dir [file normalize "synthesis/scripts/vivado"]
    }
}

# Calculate constraints file path
set constraints_file [file normalize [file join $script_dir ".." ".." "constraints" "axi_interconnect.xdc"]]

puts "Script directory: $script_dir"
puts "Constraints file: $constraints_file"
puts ""

# Check if constraints file exists
if {![file exists $constraints_file]} {
    puts "ERROR: Constraints file not found: $constraints_file"
    puts ""
    puts "Please ensure the constraints file exists at:"
    puts "  synthesis/constraints/axi_interconnect.xdc"
    return
}

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open the project first:"
    puts "  open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr"
    return
}

set project_name [current_project]
puts "Current project: $project_name"
puts ""

# Check if constraints file is already in project
set existing_files [get_files -quiet -of_objects [get_filesets constrs_1] $constraints_file]

if {[llength $existing_files] > 0} {
    puts "Constraints file already exists in project"
    puts "Removing old constraints file..."
    remove_files -fileset constrs_1 $existing_files
    puts "  Old constraints removed"
    puts ""
}

# Add constraints file to project
puts "Adding constraints file to project..."
add_files -fileset constrs_1 -norecurse $constraints_file
puts "  Constraints file added"
puts ""

# Set as active constraint set
set_property target_constrs_file $constraints_file [current_fileset -constrset]
puts "  Constraints file set as active constraint set"
puts ""

# Verify constraints were added
set constraint_files [get_files -of_objects [get_filesets constrs_1]]
puts "Constraint files in project:"
foreach file $constraint_files {
    puts "  - [file tail $file]"
}
puts ""

puts "============================================================================"
puts "Constraints Added Successfully!"
puts "============================================================================"
puts ""
puts "Constraint file: $constraints_file"
puts ""
puts "Key constraints:"
puts "  - Clock: ACLK @ 100MHz (10ns period)"
puts "  - Reset: ARESETN (async reset with false paths)"
puts "  - I/O Delays: 2.0ns max, 0.5ns min (adjust if needed)"
puts ""
puts "Next steps:"
puts "  1. Review constraints: open $constraints_file"
puts "  2. Adjust clock frequency if needed (line 15)"
puts "  3. Comment out I/O delays if masters/slaves are in PL (lines 40-120)"
puts "  4. Run synthesis: launch_runs synth_1"
puts "  5. Check timing reports after synthesis"
puts ""
puts "To change clock frequency, edit the constraints file and modify:"
puts "  create_clock -period 10.000 -name ACLK [get_ports ACLK]"
puts "  - 150MHz: -period 6.667"
puts "  - 200MHz: -period 5.000"
puts ""

