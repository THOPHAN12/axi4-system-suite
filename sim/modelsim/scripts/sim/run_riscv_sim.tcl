# ============================================================================
# TCL Script to Run SERV RISC-V System Simulation
# Usage: vsim -c -do "source run_riscv_sim.tcl; quit -f"
# Note: Must compile first with 'source compile_riscv.tcl'
# ============================================================================

# ============================================================================
# Kiểm tra compilation
# ============================================================================
puts "\n============================================================================"
puts "Starting SERV RISC-V System Simulation"
puts "============================================================================"

# Check if work library exists
if {![file exists work]} {
    puts "ERROR: Work library not found!"
    puts "Please compile first with: source compile_riscv.tcl"
    quit -code 1
}

# Check if testbench module exists
if {[catch {vsim -voptargs=+acc work.serv_axi_system_tb} err]} {
    puts "ERROR: Testbench module 'serv_axi_system_tb' not found!"
    puts "Please compile first with: source compile_riscv.tcl"
    puts "Error: $err"
    quit -code 1
}

# ============================================================================
# Chạy simulation
# ============================================================================
puts "\n============================================================================"
puts "Loading Simulation..."
puts "============================================================================"

# Load simulation
vsim -voptargs=+acc work.serv_axi_system_tb

# Run simulation với timeout
puts "\n============================================================================"
puts "Running simulation (timeout: 50us)..."
puts "============================================================================"
run 50us

puts "\n============================================================================"
puts "Simulation completed!"
puts "============================================================================"

# Don't quit automatically - let user inspect results
# quit -f

