#==============================================================================
# run_simulation.tcl
# Run simulation for dual_riscv_axi_system in Vivado
#
# Usage: In Vivado TCL Console:
#   source run_simulation.tcl
#==============================================================================

puts "============================================================================"
puts "Run Simulation - Dual RISC-V System"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open project first:"
    puts "  open_project synthesis/scripts/vivado/kv260_dual_riscv/kv260_dual_riscv.xpr"
    return
}

set project_name [current_project]
puts "Current project: $project_name"
puts ""

# Set testbench parameters
set HEX_FILE [file normalize [file join .. .. .. "verification" "programs" "simple_test.hex"]]

puts "Test program: $HEX_FILE"
if {![file exists $HEX_FILE]} {
    puts "WARNING: Test program not found: $HEX_FILE"
    puts "Simulation will use empty RAM"
}
puts ""

# Set simulation properties
set_property -name {xsim.simulate.runtime} -value {50us} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]

# Set testbench generics
set_property generic "RAM_INIT_HEX=$HEX_FILE" [get_filesets sim_1]

puts "Starting simulation..."
puts ""

# Launch simulation
launch_simulation

puts ""
puts "Simulation started!"
puts ""
puts "Useful commands:"
puts "  run 10us          - Run for 10 microseconds"
puts "  run -all          - Run until finish"
puts "  restart           - Restart simulation"
puts "  add_wave          - Add signals to waveform"
puts ""

