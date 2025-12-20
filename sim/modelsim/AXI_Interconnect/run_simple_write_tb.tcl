# ==============================================================================
# Simple AXI Write Testbench - Compilation and Simulation Script
# ==============================================================================
# This script compiles and runs the simple_axi_write_tb testbench
# ==============================================================================

puts "============================================================================"
puts "Simple AXI Write Testbench - Compilation and Simulation"
puts "============================================================================"

# Change to script directory
cd [file dirname [file normalize [info script]]]

# Get root directory (go up from sim/modelsim/AXI_Interconnect)
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

# Create memory initialization file before compilation
puts "============================================================================"
puts "Creating memory initialization file"
puts "============================================================================"
set MEM_INIT_FILE [file normalize [file join $SCRIPT_DIR "mem_init_write.hex"]]
set mem_fp [open $MEM_INIT_FILE "w"]
if {$mem_fp != ""} {
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    puts $mem_fp "00000000"
    close $mem_fp
    puts "Created mem_init_write.hex at: $MEM_INIT_FILE"
} else {
    puts "WARNING: Could not create mem_init_write.hex file"
}
puts ""

# Compilation
puts "============================================================================"
puts "Compilation"
puts "============================================================================"

# 1. Compile AXI Lite RAM
set RAM_FILE [file normalize [file join $ROOT_DIR "src" "peripherals" "axi_lite" "axi_lite_ram.v"]]
puts "Compiling: axi_lite_ram.v"
if {[catch {vlog -work work $RAM_FILE} err]} {
    puts "ERROR: Failed to compile axi_lite_ram.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# 2. Compile Testbench
set TB_BASE [file normalize [file join $ROOT_DIR "verification" "testbenches" "simple_write_tb"]]
set TB_FILE [file normalize [file join $TB_BASE "simple_axi_write_tb.v"]]
puts "Compiling: simple_axi_write_tb.v"
if {[catch {vlog -work work $TB_FILE} err]} {
    puts "ERROR: Failed to compile simple_axi_write_tb.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# Elaboration
puts "============================================================================"
puts "Elaboration"
puts "============================================================================"
if {[catch {vsim -t ps -voptargs="+acc=npr" work.simple_axi_write_tb} err]} {
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

# Master AXI Write Interface
add wave -divider -height 20 "=== Master AXI Write Interface ==="
add wave -color Cyan -radix hex -label "AWADDR" /simple_axi_write_tb/M_AXI_awaddr
add wave -color Cyan -radix binary -label "AWVALID" /simple_axi_write_tb/M_AXI_awvalid
add wave -color Cyan -radix binary -label "AWREADY" /simple_axi_write_tb/M_AXI_awready
add wave -color Yellow -radix hex -label "WDATA" /simple_axi_write_tb/M_AXI_wdata
add wave -color Yellow -radix binary -label "WSTRB" /simple_axi_write_tb/M_AXI_wstrb
add wave -color Yellow -radix binary -label "WVALID" /simple_axi_write_tb/M_AXI_wvalid
add wave -color Yellow -radix binary -label "WREADY" /simple_axi_write_tb/M_AXI_wready
add wave -color Green -radix hex -label "BRESP" /simple_axi_write_tb/M_AXI_bresp
add wave -color Green -radix binary -label "BVALID" /simple_axi_write_tb/M_AXI_bvalid
add wave -color Green -radix binary -label "BREADY" /simple_axi_write_tb/M_AXI_bready

# Slave AXI Write Interface
add wave -divider -height 20 "=== Slave AXI Write Interface ==="
add wave -color Cyan -radix hex -label "S_AWADDR" /simple_axi_write_tb/S_AXI_awaddr
add wave -color Cyan -radix binary -label "S_AWVALID" /simple_axi_write_tb/S_AXI_awvalid
add wave -color Cyan -radix binary -label "S_AWREADY" /simple_axi_write_tb/S_AXI_awready
add wave -color Yellow -radix hex -label "S_WDATA" /simple_axi_write_tb/S_AXI_wdata
add wave -color Yellow -radix binary -label "S_WSTRB" /simple_axi_write_tb/S_AXI_wstrb
add wave -color Yellow -radix binary -label "S_WVALID" /simple_axi_write_tb/S_AXI_wvalid
add wave -color Yellow -radix binary -label "S_WREADY" /simple_axi_write_tb/S_AXI_wready
add wave -color Green -radix hex -label "S_BRESP" /simple_axi_write_tb/S_AXI_bresp
add wave -color Green -radix binary -label "S_BVALID" /simple_axi_write_tb/S_AXI_bvalid
add wave -color Green -radix binary -label "S_BREADY" /simple_axi_write_tb/S_AXI_bready

# Test Control
add wave -divider -height 20 "=== Test Control ==="
add wave -color White -radix hex -label "Write Address" /simple_axi_write_tb/write_addr
add wave -color White -radix hex -label "Write Data" /simple_axi_write_tb/write_data
add wave -color White -radix binary -label "Write STRB" /simple_axi_write_tb/write_strb
add wave -color Lime -radix decimal -label "Tests Passed" /simple_axi_write_tb/test_pass
add wave -color Red -radix decimal -label "Tests Failed" /simple_axi_write_tb/test_fail
add wave -color White -radix binary -label "Master State" /simple_axi_write_tb/master_state

# Clock and Reset
add wave -divider -height 20 "=== Clock and Reset ==="
add wave -color White -radix binary -label "ACLK" /simple_axi_write_tb/ACLK
add wave -color White -radix binary -label "ARESETN" /simple_axi_write_tb/ARESETN

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

