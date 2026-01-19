#==============================================================================
# Add Constraints to Vivado Project (Simple Version)
#==============================================================================
# This script adds constraints using relative path from project directory
# Works even with spaces in path names
#
# Usage: In Vivado TCL Console (from project directory):
#   source add_constraints_simple.tcl
#==============================================================================

puts "============================================================================"
puts "Adding Constraints to Vivado Project"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open the project first:"
    puts "  open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr"
    return
}

set project_name [current_project]
set proj_dir [get_property DIRECTORY [current_project]]
puts "Current project: $project_name"
puts "Project directory: $proj_dir"
puts ""

# Calculate constraints file path relative to project directory
# Project is in: synthesis/scripts/vivado/axi4_system_sv_kv260/
# Constraints file is in: synthesis/constraints/axi_interconnect.xdc
# So we need to go: ../../constraints/axi_interconnect.xdc

set constraints_file_rel "../../constraints/axi_interconnect.xdc"
set constraints_file [file normalize [file join $proj_dir $constraints_file_rel]]

puts "Looking for constraints file: $constraints_file"
puts ""

# Check if constraints file exists
if {![file exists $constraints_file]} {
    puts "ERROR: Constraints file not found: $constraints_file"
    puts ""
    puts "Please ensure the constraints file exists at:"
    puts "  synthesis/constraints/axi_interconnect.xdc"
    puts ""
    puts "Alternative: Add constraints manually in GUI:"
    puts "  1. Flow Navigator > Add Sources"
    puts "  2. Add or Create Constraints"
    puts "  3. Add Files > Select: synthesis/constraints/axi_interconnect.xdc"
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
puts "Adding constraints file to project..."
# Use braces to handle paths with spaces properly
if {[catch {add_files -fileset constrs_1 -norecurse {$constraints_file}} err]} {
    puts "ERROR: Failed to add constraints file: $err"
    puts ""
    puts "Trying alternative method..."
    # Alternative: use file join with proper quoting
    set constraints_file_quoted [file normalize $constraints_file]
    add_files -fileset constrs_1 -norecurse $constraints_file_quoted
}
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
puts "  1. Review constraints in Sources window"
puts "  2. Adjust clock frequency if needed (edit constraints file)"
puts "  3. Comment out I/O delays if masters/slaves are in PL"
puts "  4. Run synthesis: launch_runs synth_1"
puts ""

