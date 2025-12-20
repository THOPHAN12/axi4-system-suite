#==============================================================================
# add_and_run_tb.tcl
# Simple script to add testbench and run simulation
# Usage: source add_and_run_tb.tcl
#==============================================================================

puts "============================================================================"
puts "Add Testbench and Run Simulation"
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

# Testbench file path
set tb_file [file join $project_root "SystemVerilog" "testbenches" "axi_interconnect" "core" "AXI_Interconnect_tb.sv"]
set tb_file [file normalize $tb_file]

puts "Testbench file: $tb_file"
puts ""

# Check if file exists
if {![file exists $tb_file]} {
    puts "ERROR: Testbench file not found: $tb_file"
    return
}

# Close existing simulation
puts "Closing existing simulation..."
catch {close_sim -force}
after 500
puts "  ✓ Done"
puts ""

# Add testbench to sim_1
puts "Adding testbench to project..."
set tb_in_project [get_files -quiet -of_objects [get_filesets sim_1] $tb_file]

if {[llength $tb_in_project] == 0} {
    add_files -fileset sim_1 -norecurse $tb_file
    puts "  ✓ Testbench added"
} else {
    puts "  ✓ Testbench already in project"
}
puts ""

# Set file type
puts "Setting file type to SystemVerilog..."
set tb_file_obj [get_files -of_objects [get_filesets sim_1] $tb_file]
if {[llength $tb_file_obj] > 0} {
    set_property file_type {SystemVerilog} $tb_file_obj
    puts "  ✓ File type set"
} else {
    puts "  ⚠ Could not find file object"
}
puts ""

# Set as simulation top
puts "Setting as simulation top..."
set_property top AXI_Interconnect_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
puts "  ✓ Simulation top set: AXI_Interconnect_tb"
puts ""

# Update compile order
puts "Updating compile order..."
update_compile_order -fileset sim_1
puts "  ✓ Compile order updated"
puts ""

# Launch simulation
puts "Launching simulation..."
puts ""
launch_simulation

puts ""
puts "============================================================================"
puts "Simulation Started!"
puts "============================================================================"
puts ""
puts "Useful commands:"
puts "  run 5000ns     - Run for 5000 nanoseconds"
puts "  run -all       - Run until finish"
puts "  add_wave /AXI_Interconnect_tb/*  - Add all signals to waveform"
puts ""


