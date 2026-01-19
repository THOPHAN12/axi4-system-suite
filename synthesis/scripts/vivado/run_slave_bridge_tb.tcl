#==============================================================================
# Run AXI Slave Bridge Testbench - Force Reload
#==============================================================================
# This script forces a clean reload of the Slave Bridge testbench
# Use this if you encounter compile errors due to cache issues
#==============================================================================

puts "============================================================================"
puts "Running AXI Slave Bridge Testbench (Force Reload)"
puts "============================================================================"
puts ""

# Close existing simulation
close_sim -force

# Base paths
set workspace_root "C:/Users/Nguyen Ha Hai/axi4-system-suite"
set tb_dir [file join $workspace_root "SystemVerilog/testbenches/axi_bridge"]
set src_dir [file join $workspace_root "SystemVerilog/axi_bridge"]

# Remove ALL old files from sim_1
puts "Cleaning up old files..."
set all_old_files [get_files -of_objects [get_filesets sim_1] "*axi_master_bridge*"]
if {[llength $all_old_files] > 0} {
    remove_files -fileset sim_1 $all_old_files
    puts "  - Removed old master bridge files"
}

set all_old_files [get_files -of_objects [get_filesets sim_1] "*axi_slave_bridge*"]
if {[llength $all_old_files] > 0} {
    remove_files -fileset sim_1 $all_old_files
    puts "  - Removed old slave bridge files"
}

# Wait a bit for cleanup
after 100

# Add testbench and source files with absolute paths
puts ""
puts "Adding files..."
set tb_file [file normalize [file join $tb_dir "axi_slave_bridge_tb.sv"]]
set src_file [file normalize [file join $src_dir "axi_slave_bridge.sv"]]

if {![file exists $tb_file]} {
    puts "ERROR: Testbench file not found: $tb_file"
    return
}
if {![file exists $src_file]} {
    puts "ERROR: Source file not found: $src_file"
    return
}

# Add files
add_files -fileset sim_1 -norecurse $tb_file
add_files -fileset sim_1 -norecurse $src_file

puts "  - Added: axi_slave_bridge_tb.sv"
puts "  - Added: axi_slave_bridge.sv"

# Set file types explicitly
puts ""
puts "Setting file properties..."
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1] "*axi_slave_bridge_tb.sv"]
set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1] "*axi_slave_bridge.sv"]

# Set top module
set_property top axi_slave_bridge_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

puts "  - Top module: axi_slave_bridge_tb"
puts "  - Top library: xil_defaultlib"

# Force update compile order
puts ""
puts "Updating compile order..."
update_compile_order -fileset sim_1 -force

puts ""
puts "============================================================================"
puts "Launching simulation..."
puts "============================================================================"
puts ""

# Launch simulation
launch_simulation

puts ""
puts "Simulation launched. Use 'run -all' to run the testbench."
puts ""


