#==============================================================================
# Simple script to run comprehensive testbench with proper runtime
#==============================================================================

# Set top module
set_property top comprehensive_system_tb [get_filesets sim_1]

# Set runtime to 1ms (testbench will finish earlier with $finish)
set_property -name {xsim.simulate.runtime} -value {1ms} -objects [get_filesets sim_1]

# Launch simulation
launch_simulation

# Run until $finish (instead of fixed time)
run -all

puts ""
puts "Simulation completed!"






