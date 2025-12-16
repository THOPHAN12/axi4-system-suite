#==============================================================================
# Run Comprehensive System Testbench
#==============================================================================
# This script runs the comprehensive_system_tb with appropriate runtime
#==============================================================================

set tb_name "comprehensive_system_tb"

puts "============================================================================"
puts "Running Comprehensive System Testbench"
puts "============================================================================"
puts ""

# Get simulation fileset
set sim_fileset [get_filesets sim_1]
if {[string length $sim_fileset] == 0} {
    puts "ERROR: No simulation fileset found!"
    puts "Please create a project first or set sim_1 fileset."
    return
}

# Close any existing simulation
puts "Closing any existing simulation..."
close_sim -force
after 1000

# Set testbench as top
set_property top $tb_name [get_filesets sim_1]
puts "  ✓ Set top module: $tb_name"

# Set simulation properties
set_property -name {xsim.elaborate.debug_level} -value {all} -objects $sim_fileset
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects $sim_fileset

# Set simulation runtime to 1ms (comprehensive testbench needs more time)
# Testbench will use $finish to end simulation, but this provides a safety timeout
set_property -name {xsim.simulate.runtime} -value {1ms} -objects $sim_fileset
puts "  ✓ Simulation runtime set to 1ms (safety timeout)"
puts "  ✓ Testbench will auto-finish when all tests complete"
puts ""

# Launch simulation
puts "Starting simulation..."
puts "  This may take a while as the comprehensive testbench runs many test scenarios..."
puts ""

launch_simulation

puts ""
puts "============================================================================"
puts "Simulation Complete!"
puts "============================================================================"






