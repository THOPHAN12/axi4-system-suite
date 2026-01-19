#==============================================================================
# Simple script to run comprehensive testbench with proper runtime
# This script assumes project is already open
#==============================================================================

# Set top module
set_property top comprehensive_system_tb [get_filesets sim_1]

# Set runtime to 11000ns (testbench has 10000ns timeout, add margin)
set_property -name {xsim.simulate.runtime} -value {11000ns} -objects [get_filesets sim_1]

# Close any existing simulation first
catch {close_sim -force}
after 500

# Launch simulation
launch_simulation

# Wait a bit for simulation to start
after 1000

# Run until $finish (instead of fixed time)
run -all

puts ""
puts "Simulation completed!"
