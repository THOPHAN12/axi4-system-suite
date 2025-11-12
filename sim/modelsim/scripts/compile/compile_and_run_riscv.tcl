# ============================================================================
# TCL Script to Compile and Run SERV RISC-V System
# Usage: vsim -c -do "source compile_and_run_riscv.tcl; quit -f"
# ============================================================================

# Step 1: Compile
puts "\n============================================================================"
puts "Step 1: Compiling..."
puts "============================================================================"
source compile_riscv.tcl

# Step 2: Run simulation
puts "\n============================================================================"
puts "Step 2: Running Simulation..."
puts "============================================================================"
source ../sim/run_riscv_sim.tcl

# Quit after simulation
quit -f

