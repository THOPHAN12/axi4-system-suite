# ==============================================================================
# ModelSim TCL Script - Test Dual Pipeline + SERV AXI System
# ==============================================================================
# This script:
# 1. Compiles all necessary files
# 2. Runs the testbench
# 3. Checks for errors
# ==============================================================================

set PROJECT_DIR "D:/AXI"
set SRC_DIR "$PROJECT_DIR/src"
set VERIF_DIR "$PROJECT_DIR/verification"
set SIM_DIR "$PROJECT_DIR/sim/modelsim/AXI_Interconnect"

# Create work library
vlib work
vmap work work

puts "=========================================="
puts "Compiling Dual Pipeline + SERV AXI System"
puts "=========================================="

# Compile AXI Interconnect
puts "\n[1/7] Compiling AXI Interconnect..."
vlog -work work -stats=none "$SRC_DIR/axi_interconnect/rtl/core/AXI_Interconnect.v"
if {[catch {vlog -work work -stats=none "$SRC_DIR/axi_interconnect/rtl/core/AXI_Interconnect.v"} result]} {
    puts "ERROR: Failed to compile AXI_Interconnect"
    puts $result
    exit 1
}

# Compile AXI Master Aggregator
puts "\n[2/7] Compiling AXI Master Aggregator..."
vlog -work work -stats=none "$SRC_DIR/axi_interconnect/rtl/core/AXI_Master_Aggregator.v"
if {[catch {vlog -work work -stats=none "$SRC_DIR/axi_interconnect/rtl/core/AXI_Master_Aggregator.v"} result]} {
    puts "ERROR: Failed to compile AXI_Master_Aggregator"
    puts $result
    exit 1
}

# Compile Core Wrappers
puts "\n[3/7] Compiling Core Wrappers..."
vlog -work work -stats=none +incdir+"$SRC_DIR/cores/riscv-5stage-pipeline" "$SRC_DIR/axi_bridge/riscv_pipeline_axi_wrapper.v"
vlog -work work -stats=none "$SRC_DIR/axi_bridge/serv_axi_wrapper.v"

# Compile Dual AXI Shell
puts "\n[4/7] Compiling Dual AXI Shell..."
vlog -work work -stats=none "$SRC_DIR/systems/dual_axi_shell.v"
if {[catch {vlog -work work -stats=none "$SRC_DIR/systems/dual_axi_shell.v"} result]} {
    puts "ERROR: Failed to compile dual_axi_shell"
    puts $result
    exit 1
}

# Compile Peripherals
puts "\n[5/7] Compiling Peripherals..."
vlog -work work -stats=none "$SRC_DIR/peripherals/axi_lite/axi_lite_ram.v"
vlog -work work -stats=none "$SRC_DIR/peripherals/axi_lite/axi_lite_gpio.v"
vlog -work work -stats=none "$SRC_DIR/peripherals/axi_lite/axi_lite_uart.v"
vlog -work work -stats=none "$SRC_DIR/peripherals/axi_lite/axi_lite_spi.v"

# Compile System
puts "\n[6/7] Compiling Dual Pipeline + SERV System..."
vlog -work work -stats=none +incdir+"$SRC_DIR/cores/riscv-5stage-pipeline" "$SRC_DIR/systems/dual_pipeline_serv_axi_system.v"
if {[catch {vlog -work work -stats=none +incdir+"$SRC_DIR/cores/riscv-5stage-pipeline" "$SRC_DIR/systems/dual_pipeline_serv_axi_system.v"} result]} {
    puts "ERROR: Failed to compile dual_pipeline_serv_axi_system"
    puts $result
    exit 1
}

# Compile Testbench
puts "\n[7/7] Compiling Testbench..."
vlog -work work -stats=none "$VERIF_DIR/testbenches/interconnect_tb/system/dual_pipeline_serv_axi_system_tb.v"
if {[catch {vlog -work work -stats=none "$VERIF_DIR/testbenches/interconnect_tb/system/dual_pipeline_serv_axi_system_tb.v"} result]} {
    puts "ERROR: Failed to compile testbench"
    puts $result
    exit 1
}

puts "\n=========================================="
puts "Compilation Complete"
puts "=========================================="

# Start Simulation
puts "\n=========================================="
puts "Starting Simulation"
puts "=========================================="
vsim -voptargs="+acc" work.dual_pipeline_serv_axi_system_tb

# Add waves
add wave -r /*

# Run simulation
set SIM_TIME 10000ns
puts "\nRunning simulation for $SIM_TIME..."
run $SIM_TIME

puts "\n=========================================="
puts "Simulation Complete"
puts "=========================================="

# Check for errors in transcript
set transcript_file [open "transcript.log" r]
set content [read $transcript_file]
close $transcript_file

if {[string match "*ERROR*" $content] || [string match "*Error*" $content]} {
    puts "\nWARNING: Errors found in simulation!"
    puts "Check transcript.log for details"
} else {
    puts "\nNo errors found in simulation"
}

puts "\nTest completed. Check waveform viewer for details."

