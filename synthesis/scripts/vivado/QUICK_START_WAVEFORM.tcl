#==============================================================================
# QUICK_START_WAVEFORM.tcl
# Complete workflow: Close simulation, set testbench as top, launch, setup waveform
#==============================================================================

puts "============================================================================"
puts "Quick Start: Setup Simulation and Waveform"
puts "============================================================================"
puts ""

# Step 1: Close existing simulation if running
set sim_running [current_sim]
if {$sim_running != ""} {
    puts "Step 1: Closing existing simulation..."
    close_sim -force
    puts "  ✓ Simulation closed"
} else {
    puts "Step 1: No simulation running"
}
puts ""

# Step 2: Set testbench as top
puts "Step 2: Setting testbench as simulation top..."
set_property top dual_riscv_system_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
puts "  ✓ Testbench set as top: dual_riscv_system_tb"
puts ""

# Step 3: Set debug options
puts "Step 3: Setting debug options..."
set_property -name {xsim.elaborate.debug_level} -value {all} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
puts "  ✓ Debug options set"
puts ""

# Step 4: Launch simulation
puts "Step 4: Launching simulation..."
launch_simulation
puts "  ✓ Simulation launched"
puts ""

# Step 5: Setup waveform
puts "Step 5: Setting up waveform..."
puts ""

# Source the simple waveform script
set script_dir [file dirname [file normalize [info script]]]
set waveform_script [file join $script_dir "setup_waveform_simple.tcl"]

if {[file exists $waveform_script]} {
    source $waveform_script
} else {
    puts "ERROR: Waveform script not found: $waveform_script"
    puts "Please run setup_waveform_simple.tcl manually"
}

puts ""
puts "============================================================================"
puts "Setup complete! Ready to run simulation."
puts "============================================================================"
puts ""
puts "Next step: run 50us"



