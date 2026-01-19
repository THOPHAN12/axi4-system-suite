#==============================================================================
# Run Bridge Testbench Script
#==============================================================================
# This script helps you run either AXI Master Bridge or AXI Slave Bridge testbench
#
# Usage:
#   source synthesis/scripts/vivado/run_bridge_tb.tcl
#   Then follow the prompts or modify the $tb_choice variable below
#==============================================================================

puts "============================================================================"
puts "Bridge Testbench Runner"
puts "============================================================================"
puts ""

# Close existing simulation
close_sim -force

# Base paths
set workspace_root "C:/Users/Nguyen Ha Hai/axi4-system-suite"
set tb_dir [file join $workspace_root "SystemVerilog/testbenches/axi_bridge"]
set src_dir [file join $workspace_root "SystemVerilog/axi_bridge"]

# Choose testbench: 1 = Master Bridge, 2 = Slave Bridge
set tb_choice 1

if {$tb_choice == 1} {
    #==============================================================================
    # AXI Master Bridge Testbench
    #==============================================================================
    puts "Running AXI Master Bridge Testbench..."
    puts ""
    
    # Remove old files from sim_1
    remove_files -fileset sim_1 [get_files -of_objects [get_filesets sim_1] "*axi_master_bridge*"]
    remove_files -fileset sim_1 [get_files -of_objects [get_filesets sim_1] "*axi_slave_bridge*"]
    
    # Add testbench and source files
    add_files -fileset sim_1 -norecurse [file join $tb_dir "axi_master_bridge_tb.sv"]
    add_files -fileset sim_1 -norecurse [file join $src_dir "axi_master_bridge.sv"]
    
    # Set file types
    set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1] "*axi_master_bridge*"]
    
    # Set top module
    set_property top axi_master_bridge_tb [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    
    puts "  - Added: axi_master_bridge_tb.sv"
    puts "  - Added: axi_master_bridge.sv"
    puts "  - Top module: axi_master_bridge_tb"
    
} else {
    #==============================================================================
    # AXI Slave Bridge Testbench
    #==============================================================================
    puts "Running AXI Slave Bridge Testbench..."
    puts ""
    
    # Close simulation first
    close_sim -force
    
    # Remove old files from sim_1 (more thorough cleanup)
    set old_files [get_files -of_objects [get_filesets sim_1] "*axi_master_bridge*"]
    if {[llength $old_files] > 0} {
        remove_files -fileset sim_1 $old_files
    }
    set old_files [get_files -of_objects [get_filesets sim_1] "*axi_slave_bridge*"]
    if {[llength $old_files] > 0} {
        remove_files -fileset sim_1 $old_files
    }
    
    # Add testbench and source files with absolute paths
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
    
    add_files -fileset sim_1 -norecurse $tb_file
    add_files -fileset sim_1 -norecurse $src_file
    
    # Set file types
    set_property file_type {SystemVerilog} [get_files -of_objects [get_filesets sim_1] "*axi_slave_bridge*"]
    
    # Set top module
    set_property top axi_slave_bridge_tb [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    
    puts "  - Added: axi_slave_bridge_tb.sv"
    puts "  - Added: axi_slave_bridge.sv"
    puts "  - Top module: axi_slave_bridge_tb"
}

# Update compile order
puts ""
puts "Updating compile order..."
update_compile_order -fileset sim_1

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

