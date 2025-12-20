# ==============================================================================
# Dual Master Arbitration Testbench - Compilation and Simulation Script
# ==============================================================================
# This script compiles and runs the dual_master_arbitration_tb testbench
# ==============================================================================

puts "============================================================================"
puts "Dual Master Arbitration Testbench - Compilation and Simulation"
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
set MEM_INIT_S1 [file normalize [file join $SCRIPT_DIR "mem_init_s1.hex"]]
set mem_fp [open $MEM_INIT_S1 "w"]
if {$mem_fp != ""} {
    puts $mem_fp "01123456"
    puts $mem_fp "00000000"
    close $mem_fp
    puts "Created mem_init_s1.hex at: $MEM_INIT_S1"
}

set MEM_INIT_S3 [file normalize [file join $SCRIPT_DIR "mem_init_s3.hex"]]
set mem_fp [open $MEM_INIT_S3 "w"]
if {$mem_fp != ""} {
    puts $mem_fp "02789ABC"
    puts $mem_fp "00000000"
    close $mem_fp
    puts "Created mem_init_s3.hex at: $MEM_INIT_S3"
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
set TB_BASE [file normalize [file join $ROOT_DIR "verification" "testbenches" "dual_master_tb"]]
set TB_FILE [file normalize [file join $TB_BASE "dual_master_arbitration_tb.v"]]
puts "Compiling: dual_master_arbitration_tb.v"
if {[catch {vlog -work work $TB_FILE} err]} {
    puts "ERROR: Failed to compile dual_master_arbitration_tb.v"
    puts $err
    return -code error
}
puts "  ? SUCCESS"
puts ""

# Elaboration
puts "============================================================================"
puts "Elaboration"
puts "============================================================================"
if {[catch {vsim -t ps -voptargs="+acc=npr" work.dual_master_arbitration_tb} err]} {
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
add wave -color Cyan -radix hex -label "M0_ARADDR" /dual_master_arbitration_tb/M0_ARADDR
add wave -color Cyan -radix binary -label "M0_ARVALID" /dual_master_arbitration_tb/M0_ARVALID
add wave -color Cyan -radix binary -label "M0_ARREADY" /dual_master_arbitration_tb/M0_ARREADY
add wave -color Yellow -radix hex -label "M0_RDATA" /dual_master_arbitration_tb/M0_RDATA
add wave -color Yellow -radix binary -label "M0_RVALID" /dual_master_arbitration_tb/M0_RVALID
add wave -color Yellow -radix binary -label "M0_RREADY" /dual_master_arbitration_tb/M0_RREADY
add wave -color Green -radix hex -label "M0_AWADDR" /dual_master_arbitration_tb/M0_AWADDR
add wave -color Green -radix binary -label "M0_AWVALID" /dual_master_arbitration_tb/M0_AWVALID
add wave -color Green -radix binary -label "M0_AWREADY" /dual_master_arbitration_tb/M0_AWREADY
add wave -color Green -radix hex -label "M0_WDATA" /dual_master_arbitration_tb/M0_WDATA
add wave -color Green -radix binary -label "M0_WVALID" /dual_master_arbitration_tb/M0_WVALID
add wave -color Green -radix binary -label "M0_WREADY" /dual_master_arbitration_tb/M0_WREADY
add wave -color White -radix binary -label "M0_STATE" /dual_master_arbitration_tb/m0_state
add wave -color White -radix hex -label "M0_INSTRUCTION" /dual_master_arbitration_tb/m0_instruction
add wave -color White -radix hex -label "M0_RESULT" /dual_master_arbitration_tb/m0_result

# Master 1 signals
add wave -divider -height 20 "=== Master 1 (M1) ==="
add wave -color Cyan -radix hex -label "M1_ARADDR" /dual_master_arbitration_tb/M1_ARADDR
add wave -color Cyan -radix binary -label "M1_ARVALID" /dual_master_arbitration_tb/M1_ARVALID
add wave -color Cyan -radix binary -label "M1_ARREADY" /dual_master_arbitration_tb/M1_ARREADY
add wave -color Yellow -radix hex -label "M1_RDATA" /dual_master_arbitration_tb/M1_RDATA
add wave -color Yellow -radix binary -label "M1_RVALID" /dual_master_arbitration_tb/M1_RVALID
add wave -color Yellow -radix binary -label "M1_RREADY" /dual_master_arbitration_tb/M1_RREADY
add wave -color Green -radix hex -label "M1_AWADDR" /dual_master_arbitration_tb/M1_AWADDR
add wave -color Green -radix binary -label "M1_AWVALID" /dual_master_arbitration_tb/M1_AWVALID
add wave -color Green -radix binary -label "M1_AWREADY" /dual_master_arbitration_tb/M1_AWREADY
add wave -color Green -radix hex -label "M1_WDATA" /dual_master_arbitration_tb/M1_WDATA
add wave -color Green -radix binary -label "M1_WVALID" /dual_master_arbitration_tb/M1_WVALID
add wave -color Green -radix binary -label "M1_WREADY" /dual_master_arbitration_tb/M1_WREADY
add wave -color White -radix binary -label "M1_STATE" /dual_master_arbitration_tb/m1_state
add wave -color White -radix hex -label "M1_INSTRUCTION" /dual_master_arbitration_tb/m1_instruction
add wave -color White -radix hex -label "M1_RESULT" /dual_master_arbitration_tb/m1_result

# Arbitration signals
add wave -divider -height 20 "=== Arbitration ==="
add wave -color Magenta -radix binary -label "M0_READ_REQ" /dual_master_arbitration_tb/m0_read_req
add wave -color Magenta -radix binary -label "M1_READ_REQ" /dual_master_arbitration_tb/m1_read_req
add wave -color Magenta -radix binary -label "M0_READ_GRANT" /dual_master_arbitration_tb/m0_read_grant
add wave -color Magenta -radix binary -label "M1_READ_GRANT" /dual_master_arbitration_tb/m1_read_grant
add wave -color Magenta -radix binary -label "ROUTE_TO_S1" /dual_master_arbitration_tb/route_to_s1
add wave -color Magenta -radix binary -label "ROUTE_TO_S3" /dual_master_arbitration_tb/route_to_s3

# Slave 1 signals
add wave -divider -height 20 "=== Slave 1 (S1) ==="
add wave -color Orange -radix hex -label "S1_ARADDR" /dual_master_arbitration_tb/S1_ARADDR
add wave -color Orange -radix binary -label "S1_ARVALID" /dual_master_arbitration_tb/S1_ARVALID
add wave -color Orange -radix binary -label "S1_ARREADY" /dual_master_arbitration_tb/S1_ARREADY
add wave -color Orange -radix hex -label "S1_RDATA" /dual_master_arbitration_tb/S1_RDATA
add wave -color Orange -radix binary -label "S1_RVALID" /dual_master_arbitration_tb/S1_RVALID
add wave -color Orange -radix hex -label "S1_AWADDR" /dual_master_arbitration_tb/S1_AWADDR
add wave -color Orange -radix hex -label "S1_WDATA" /dual_master_arbitration_tb/S1_WDATA

# Slave 3 signals
add wave -divider -height 20 "=== Slave 3 (S3) ==="
add wave -color Purple -radix hex -label "S3_ARADDR" /dual_master_arbitration_tb/S3_ARADDR
add wave -color Purple -radix binary -label "S3_ARVALID" /dual_master_arbitration_tb/S3_ARVALID
add wave -color Purple -radix binary -label "S3_ARREADY" /dual_master_arbitration_tb/S3_ARREADY
add wave -color Purple -radix hex -label "S3_RDATA" /dual_master_arbitration_tb/S3_RDATA
add wave -color Purple -radix binary -label "S3_RVALID" /dual_master_arbitration_tb/S3_RVALID
add wave -color Purple -radix hex -label "S3_AWADDR" /dual_master_arbitration_tb/S3_AWADDR
add wave -color Purple -radix hex -label "S3_WDATA" /dual_master_arbitration_tb/S3_WDATA

# Clock and Reset
add wave -divider -height 20 "=== Clock and Reset ==="
add wave -color White -radix binary -label "ACLK" /dual_master_arbitration_tb/ACLK
add wave -color White -radix binary -label "ARESETN" /dual_master_arbitration_tb/ARESETN

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

