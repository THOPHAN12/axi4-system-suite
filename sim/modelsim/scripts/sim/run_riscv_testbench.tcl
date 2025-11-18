# ============================================================================
# TCL Script to Run RISC-V Testbench in Batch Mode
# Usage: vsim -c -do "source scripts/sim/run_riscv_testbench.tcl; quit -f"
# ============================================================================

# ============================================================================
# Cấu hình đường dẫn
# ============================================================================
set script_file [info script]
if {[string equal $script_file ""]} {
    set script_dir [pwd]
} else {
    set script_dir [file dirname [file normalize $script_file]]
}

# Tính project root (lên 3 cấp từ sim/modelsim/scripts/sim -> D:/AXI)
set project_root [file normalize [file join $script_dir .. .. ..]]

# Verify project root
if {![file exists $project_root]} {
    puts "ERROR: Project root not found: $project_root"
    quit -code 1
}

puts "\n============================================================================"
puts "Running RISC-V Testbench Simulation"
puts "============================================================================"
puts "Project root: $project_root"
puts "============================================================================\n"

# ============================================================================
# Check if work library exists
# ============================================================================
if {![file exists work]} {
    puts "ERROR: Work library not found. Please compile first using:"
    puts "  source scripts/compile/compile_and_run_dual_master_ip_RISCV.tcl"
    quit -code 1
}

# ============================================================================
# Start Simulation in Batch Mode
# ============================================================================
puts "============================================================================"
puts "Starting Simulation (Batch Mode)"
puts "============================================================================"
puts ""

# Start simulation without GUI
vsim -voptargs=+acc -t ps -c work.dual_master_system_ip_tb_RISC_V

# Run simulation to completion
puts "Running simulation to completion..."
run -all

puts ""
puts "============================================================================"
puts "Simulation Complete!"
puts "============================================================================"
puts ""

# Quit simulation
quit -f

