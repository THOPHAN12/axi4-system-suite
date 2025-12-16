#==============================================================================
# add_sv_testbench.tcl
# Add SystemVerilog testbench to project
#
# Usage:
#   set tb_file "SystemVerilog/testbenches/axi_interconnect/utils/Raising_Edge_Det_tb.sv"
#   source add_sv_testbench.tcl
#==============================================================================

puts "============================================================================"
puts "Add SystemVerilog Testbench to Project"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    return
}

# Get project root
set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ".." ".." ".."]]

# Default testbench if not specified
if {![info exists tb_file]} {
    set tb_file [file join $project_root "SystemVerilog" "testbenches" "axi_interconnect" "utils" "Raising_Edge_Det_tb.sv"]
}

set tb_file [file normalize $tb_file]

puts "Testbench file: $tb_file"
puts ""

# Check if file exists
if {![file exists $tb_file]} {
    puts "ERROR: Testbench file not found: $tb_file"
    puts ""
    puts "Usage:"
    puts "  set tb_file \"path/to/testbench.sv\""
    puts "  source add_sv_testbench.tcl"
    return
}

puts "✓ Testbench file found"
puts ""

# Add testbench to sim_1 fileset
puts "Adding testbench to sim_1 fileset..."
set tb_in_project [get_files -quiet -of_objects [get_filesets sim_1] $tb_file]

if {[llength $tb_in_project] == 0} {
    add_files -fileset sim_1 -norecurse $tb_file
    puts "✓ Testbench added to sim_1"
} else {
    puts "✓ Testbench already in sim_1"
}
puts ""

# Set file type to SystemVerilog
puts "Setting file type to SystemVerilog..."
set tb_file_obj [get_files -of_objects [get_filesets sim_1] $tb_file]
set_property file_type {SystemVerilog} $tb_file_obj
puts "✓ File type set to SystemVerilog"
puts ""

# Get testbench module name
set tb_name [file rootname [file tail $tb_file]]
puts "Testbench module name: $tb_name"
puts ""

# Set as simulation top
puts "Setting as simulation top..."
set_property top $tb_name [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
puts "✓ Testbench set as simulation top: $tb_name"
puts ""

# Update compile order
puts "Updating compile order..."
update_compile_order -fileset sim_1
puts "✓ Compile order updated"
puts ""

puts "============================================================================"
puts "Testbench Added Successfully!"
puts "============================================================================"
puts ""
puts "Next steps:"
puts "  launch_simulation"
puts ""


