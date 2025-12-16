# ==============================================================================
# Busy Signal Testbench - Compilation and Simulation Script
# ==============================================================================
# This script compiles and runs the busy_test_tb testbench
# ==============================================================================

puts "============================================================================"
puts "Busy Signal Testbench - Compilation and Simulation"
puts "============================================================================"

# Change to script directory
cd [file dirname [file normalize [info script]]]

# Get root directory
set SCRIPT_DIR [pwd]
set ROOT_DIR [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]

puts "Script directory: $SCRIPT_DIR"
puts "Root directory: $ROOT_DIR"
puts ""

# Use catch to ignore error if no simulation is running
if {[catch {quit -sim} err]} {
    # No simulation running, continue
}

# Initialize work library
if {[file exists work]} {
    file delete -force work
}
vlib work
vmap work work
puts "Work library initialized successfully!"
puts ""

# Create memory initialization files before compilation
puts "============================================================================"
puts "Creating memory initialization files"
puts "============================================================================"
set MEM_INIT_S0 [file normalize [file join $SCRIPT_DIR "mem_init_s0_busy.hex"]]
set mem_fp [open $MEM_INIT_S0 "w"]
if {$mem_fp != ""} {
    puts $mem_fp "00000000"
    puts $mem_fp "01123456"
    close $mem_fp
    puts "Created mem_init_s0_busy.hex at: $MEM_INIT_S0"
}

set MEM_INIT_S1 [file normalize [file join $SCRIPT_DIR "mem_init_s1_busy.hex"]]
set mem_fp [open $MEM_INIT_S1 "w"]
if {$mem_fp != ""} {
    puts $mem_fp "00000000"
    close $mem_fp
    puts "Created mem_init_s1_busy.hex at: $MEM_INIT_S1"
}
puts ""

# Compilation
puts "============================================================================"
puts "Compilation"
puts "============================================================================"

# 1. Compile AXI Lite RAM
set RAM_FILE [file normalize [file join $ROOT_DIR "src" "peripherals" "axi_lite" "axi_lite_ram.v"]]
puts "Compiling: axi_lite_ram.v"
if {[catch {vlog -work work [list $RAM_FILE]} err]} {
    puts "ERROR: Failed to compile axi_lite_ram.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# 2. Compile AXI Master 0
set M0_FILE [file normalize [file join $ROOT_DIR "src" "axi_masters" "axi_master_0.v"]]
puts "Compiling: axi_master_0.v"
if {[catch {vlog -work work [list $M0_FILE]} err]} {
    puts "ERROR: Failed to compile axi_master_0.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# 3. Compile AXI Master 1
set M1_FILE [file normalize [file join $ROOT_DIR "src" "axi_masters" "axi_master_1.v"]]
puts "Compiling: axi_master_1.v"
if {[catch {vlog -work work [list $M1_FILE]} err]} {
    puts "ERROR: Failed to compile axi_master_1.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# 4. Compile Testbench
set TB_BASE [file normalize [file join $ROOT_DIR "verification" "testbenches" "busy_test_tb"]]
set TB_FILE [file normalize [file join $TB_BASE "busy_test_tb.v"]]
puts "Compiling: busy_test_tb.v"
if {[catch {vlog -work work [list $TB_FILE]} err]} {
    puts "ERROR: Failed to compile busy_test_tb.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# Elaboration
puts "============================================================================"
puts "Elaboration"
puts "============================================================================"
if {[catch {vsim -t ps -voptargs="+acc=npr" work.busy_test_tb} err]} {
    puts "ERROR: Failed to elaborate design"
    puts $err
    return -code error
}
puts "Design elaborated successfully!"
puts ""

# Waveform setup
puts "============================================================================"
puts "Setting up waveforms"
puts "============================================================================"

# Master 0 Busy Test Signals
add wave -divider -height 20 "=== Master 0 Busy Test ==="
add wave -color Red -radix binary -label "M0_BUSY" /busy_test_tb/m0_busy
add wave -color White -radix binary -label "M0_START" /busy_test_tb/m0_start
add wave -color White -radix binary -label "M0_COMPLETED" /busy_test_tb/m0_completed
add wave -color White -radix binary -label "M0_STATE" /busy_test_tb/u_master_0/state

# Master 1 Busy Test Signals
add wave -divider -height 20 "=== Master 1 Busy Test ==="
add wave -color Red -radix binary -label "M1_BUSY" /busy_test_tb/m1_busy
add wave -color White -radix binary -label "M1_START" /busy_test_tb/m1_start
add wave -color White -radix binary -label "M1_COMPLETED" /busy_test_tb/m1_completed
add wave -color White -radix binary -label "M1_STATE" /busy_test_tb/u_master_1/state

# Clock and Reset
add wave -divider -height 20 "=== Clock and Reset ==="
add wave -color White -radix binary -label "ACLK" /busy_test_tb/ACLK
add wave -color White -radix binary -label "ARESETN" /busy_test_tb/ARESETN

puts "Waveforms configured successfully!"
puts ""

# Run simulation
puts "============================================================================"
puts "Running Simulation"
puts "============================================================================"
puts "Simulation will run until \$finish is called in testbench"
puts ""

transcript on
run -all
wave zoom full
view wave

puts ""
puts "============================================================================"
puts "Simulation Complete"
puts "============================================================================"

