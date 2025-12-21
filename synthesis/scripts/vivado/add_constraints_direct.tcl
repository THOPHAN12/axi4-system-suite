#==============================================================================
# Add Constraints Directly (No Path Issues)
#==============================================================================
# This script adds constraints using direct file path calculation
# Works with spaces in path names
#
# Usage: In Vivado TCL Console (after opening project):
#   source add_constraints_direct.tcl
#==============================================================================

puts "============================================================================"
puts "Adding Constraints to Vivado Project"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open the project first"
    return
}

set project_name [current_project]
set proj_dir [get_property DIRECTORY [current_project]]
puts "Current project: $project_name"
puts "Project directory: $proj_dir"
puts ""

# Calculate constraints file path
# Project is in: .../axi4_system_sv_kv260/
# Constraints file is in: .../constraints/axi_interconnect.xdc
# Relative path: ../../constraints/axi_interconnect.xdc

set constraints_rel_path "../../constraints/axi_interconnect.xdc"
set constraints_file [file join $proj_dir $constraints_rel_path]
set constraints_file [file normalize $constraints_file]

puts "Looking for constraints file:"
puts "  $constraints_file"
puts ""

# Check if constraints file exists
if {![file exists $constraints_file]} {
    puts "ERROR: Constraints file not found!"
    puts ""
    puts "Expected location: $constraints_file"
    puts ""
    puts "Please ensure the file exists, or add it manually:"
    puts "  1. Flow Navigator > Add Sources"
    puts "  2. Add or Create Constraints"
    puts "  3. Add Files > Browse to: synthesis/constraints/axi_interconnect.xdc"
    return
}

puts "Constraints file found!"
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
# Use file normalize to handle spaces properly
puts "Adding constraints file to project..."
set constraints_file_normalized [file normalize $constraints_file]

# Try adding with normalized path
if {[catch {
    add_files -fileset constrs_1 -norecurse $constraints_file_normalized
} err]} {
    puts "ERROR: Failed to add constraints file"
    puts "Error: $err"
    puts ""
    puts "Please add constraints manually in GUI:"
    puts "  1. Flow Navigator > Add Sources"
    puts "  2. Add or Create Constraints"
    puts "  3. Add Files > Select: $constraints_file"
    return
}

puts "  Constraints file added successfully"
puts ""

# Set as active constraint set
set_property target_constrs_file $constraints_file_normalized [current_fileset -constrset]
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
puts "Constraint file: [file tail $constraints_file]"
puts ""
puts "Key constraints:"
puts "  - Clock: ACLK @ 100MHz (10ns period)"
puts "  - Reset: ARESETN (async reset with false paths)"
puts "  - I/O Delays: 2.0ns max, 0.5ns min"
puts ""
puts "Next step: Run synthesis"
puts "  launch_runs synth_1"
puts ""














