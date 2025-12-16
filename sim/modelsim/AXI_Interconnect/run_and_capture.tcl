#==============================================================================
# run_and_capture.tcl
# Run simulation and capture transcript to file
#==============================================================================

# Redirect output to file
set transcript_file "simulation_transcript.log"
set transcript_handle [open $transcript_file w]

# Source the main simulation script
source simulate_dual_riscv.tcl

# Run simulation to completion
run -all

# Print final message
puts ""
puts "============================================================================"
puts "Simulation completed! Transcript saved to: $transcript_file"
puts "============================================================================"

# Close transcript file
close $transcript_handle

# Exit ModelSim
quit -f

