# ==============================================================================
# Master Dependency Testbench - Compilation and Simulation Script
# ==============================================================================
# This script compiles and runs the master_dependency_tb testbench (Test Case 4)
# ==============================================================================

puts "============================================================================"
puts "Master Dependency Testbench - Compilation and Simulation"
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
set MEM_INIT_S0 [file normalize [file join $SCRIPT_DIR "mem_init_s0_dep.hex"]]
set mem_fp [open $MEM_INIT_S0 "w"]
if {$mem_fp != ""} {
    puts $mem_fp "00000000"
    puts $mem_fp "01123456"
    close $mem_fp
    puts "Created mem_init_s0_dep.hex at: $MEM_INIT_S0"
}

set MEM_INIT_S1 [file normalize [file join $SCRIPT_DIR "mem_init_s1_dep.hex"]]
set mem_fp [open $MEM_INIT_S1 "w"]
if {$mem_fp != ""} {
    puts $mem_fp "00000000"
    close $mem_fp
    puts "Created mem_init_s1_dep.hex at: $MEM_INIT_S1"
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

# 2. Compile AXI Master 0
set M0_FILE [file normalize [file join $ROOT_DIR "src" "axi_masters" "axi_master_0.v"]]
puts "Compiling: axi_master_0.v"
if {[catch {vlog -work work $M0_FILE} err]} {
    puts "ERROR: Failed to compile axi_master_0.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# 3. Compile AXI Master 1
set M1_FILE [file normalize [file join $ROOT_DIR "src" "axi_masters" "axi_master_1.v"]]
puts "Compiling: axi_master_1.v"
if {[catch {vlog -work work $M1_FILE} err]} {
    puts "ERROR: Failed to compile axi_master_1.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# 4. Compile Testbench
set TB_BASE [file normalize [file join $ROOT_DIR "verification" "testbenches" "dual_master_tb"]]
set TB_FILE [file normalize [file join $TB_BASE "master_dependency_tb.v"]]
puts "Compiling: master_dependency_tb.v"
if {[catch {vlog -work work $TB_FILE} err]} {
    puts "ERROR: Failed to compile master_dependency_tb.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# Elaboration
puts "============================================================================"
puts "Elaboration"
puts "============================================================================"
if {[catch {vsim -t ps -voptargs="+acc=npr" work.master_dependency_tb} err]} {
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

# Master 0 signals
add wave -divider -height 20 "=== Master 0 (M0) ==="
add wave -color Cyan -radix hex -label "M0_ARADDR" /master_dependency_tb/M0_ARADDR
add wave -color Cyan -radix binary -label "M0_ARVALID" /master_dependency_tb/M0_ARVALID
add wave -color Cyan -radix binary -label "M0_ARREADY" /master_dependency_tb/M0_ARREADY
add wave -color Yellow -radix hex -label "M0_RDATA" /master_dependency_tb/M0_RDATA
add wave -color Yellow -radix binary -label "M0_RVALID" /master_dependency_tb/M0_RVALID
add wave -color Yellow -radix binary -label "M0_RREADY" /master_dependency_tb/M0_RREADY
add wave -color Green -radix hex -label "M0_AWADDR" /master_dependency_tb/M0_AWADDR
add wave -color Green -radix binary -label "M0_AWVALID" /master_dependency_tb/M0_AWVALID
add wave -color Green -radix binary -label "M0_AWREADY" /master_dependency_tb/M0_AWREADY
add wave -color Green -radix hex -label "M0_WDATA" /master_dependency_tb/M0_WDATA
add wave -color Green -radix binary -label "M0_WVALID" /master_dependency_tb/M0_WVALID
add wave -color Green -radix binary -label "M0_WREADY" /master_dependency_tb/M0_WREADY
add wave -color Red -radix binary -label "M0_BUSY" /master_dependency_tb/m0_busy
add wave -color White -radix binary -label "M0_STATE" /master_dependency_tb/u_master_0/state
add wave -color White -radix hex -label "M0_INSTRUCTION" /master_dependency_tb/m0_instruction
add wave -color White -radix hex -label "M0_RESULT" /master_dependency_tb/m0_result
add wave -color White -radix binary -label "M0_COMPLETED" /master_dependency_tb/m0_completed

# Master 1 signals
add wave -divider -height 20 "=== Master 1 (M1) ==="
add wave -color Cyan -radix hex -label "M1_ARADDR" /master_dependency_tb/M1_ARADDR
add wave -color Cyan -radix binary -label "M1_ARVALID" /master_dependency_tb/M1_ARVALID
add wave -color Cyan -radix binary -label "M1_ARREADY" /master_dependency_tb/M1_ARREADY
add wave -color Yellow -radix hex -label "M1_RDATA" /master_dependency_tb/M1_RDATA
add wave -color Yellow -radix binary -label "M1_RVALID" /master_dependency_tb/M1_RVALID
add wave -color Yellow -radix binary -label "M1_RREADY" /master_dependency_tb/M1_RREADY
add wave -color Green -radix hex -label "M1_AWADDR" /master_dependency_tb/M1_AWADDR
add wave -color Green -radix binary -label "M1_AWVALID" /master_dependency_tb/M1_AWVALID
add wave -color Green -radix binary -label "M1_AWREADY" /master_dependency_tb/M1_AWREADY
add wave -color Green -radix hex -label "M1_WDATA" /master_dependency_tb/M1_WDATA
add wave -color Green -radix binary -label "M1_WVALID" /master_dependency_tb/M1_WVALID
add wave -color Green -radix binary -label "M1_WREADY" /master_dependency_tb/M1_WREADY
add wave -color Red -radix binary -label "M1_BUSY" /master_dependency_tb/m1_busy
add wave -color White -radix binary -label "M1_STATE" /master_dependency_tb/u_master_1/state
add wave -color White -radix hex -label "M1_ADDRESS_OFFSET" /master_dependency_tb/m1_address_offset
add wave -color White -radix binary -label "M1_COMPLETED" /master_dependency_tb/m1_completed

# Arbitration signals
add wave -divider -height 20 "=== Arbitration ==="
add wave -color Magenta -radix binary -label "M0_READ_REQ" /master_dependency_tb/m0_read_req
add wave -color Magenta -radix binary -label "M1_READ_REQ" /master_dependency_tb/m1_read_req
add wave -color Magenta -radix binary -label "M0_READ_GRANT" /master_dependency_tb/m0_read_grant
add wave -color Magenta -radix binary -label "M1_READ_GRANT" /master_dependency_tb/m1_read_grant
add wave -color Magenta -radix binary -label "M0_TO_S0" /master_dependency_tb/m0_to_s0
add wave -color Magenta -radix binary -label "M1_TO_S0" /master_dependency_tb/m1_to_s0
add wave -color Magenta -radix binary -label "M1_TO_S1" /master_dependency_tb/m1_to_s1

# Slave 0 signals
add wave -divider -height 20 "=== Slave 0 (S0) - Shared Memory ==="
add wave -color Orange -radix hex -label "S0_ARADDR" /master_dependency_tb/S0_ARADDR
add wave -color Orange -radix binary -label "S0_ARVALID" /master_dependency_tb/S0_ARVALID
add wave -color Orange -radix binary -label "S0_ARREADY" /master_dependency_tb/S0_ARREADY
add wave -color Orange -radix hex -label "S0_RDATA" /master_dependency_tb/S0_RDATA
add wave -color Orange -radix binary -label "S0_RVALID" /master_dependency_tb/S0_RVALID
add wave -color Orange -radix hex -label "S0_AWADDR" /master_dependency_tb/S0_AWADDR
add wave -color Orange -radix hex -label "S0_WDATA" /master_dependency_tb/S0_WDATA

# Slave 1 signals
add wave -divider -height 20 "=== Slave 1 (S1) - Target for M1 ==="
add wave -color Purple -radix hex -label "S1_AWADDR" /master_dependency_tb/S1_AWADDR
add wave -color Purple -radix binary -label "S1_AWVALID" /master_dependency_tb/S1_AWVALID
add wave -color Purple -radix binary -label "S1_AWREADY" /master_dependency_tb/S1_AWREADY
add wave -color Purple -radix hex -label "S1_WDATA" /master_dependency_tb/S1_WDATA
add wave -color Purple -radix binary -label "S1_WVALID" /master_dependency_tb/S1_WVALID
add wave -color Purple -radix binary -label "S1_WREADY" /master_dependency_tb/S1_WREADY

# Clock and Reset
add wave -divider -height 20 "=== Clock and Reset ==="
add wave -color White -radix binary -label "ACLK" /master_dependency_tb/ACLK
add wave -color White -radix binary -label "ARESETN" /master_dependency_tb/ARESETN

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

