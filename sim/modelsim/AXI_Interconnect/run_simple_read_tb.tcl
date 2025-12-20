# ============================================================================
# ModelSim TCL Script - Run Simple AXI Read Testbench
# ============================================================================
# This script compiles and runs the simple AXI read testbench
# Usage: 
#   From ModelSim GUI: do run_simple_read_tb.tcl
#   From command line: vsim -do run_simple_read_tb.tcl
# ============================================================================

# Get script directory first (before any cd operations)
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Enable transcript logging for better visibility
transcript on

# Check if running in GUI mode (simplified check)
# In GUI mode, batch_mode returns 0
set IS_BATCH_MODE [batch_mode]

# If already in simulation, quit it first to start fresh
# Use catch to ignore error if no simulation is running
if {[catch {quit -sim} err]} {
    # No simulation running, that's fine
    puts "Starting fresh (no existing simulation)"
} else {
    puts "Quitting existing simulation to start fresh..."
}

# Now change to script directory (after quitting simulation)
# Use catch to handle any remaining issues
if {[catch {cd $SCRIPT_DIR} err]} {
    puts "Warning: Could not change directory: $err"
    puts "Continuing with current directory..."
}

puts "============================================================================"
puts "Simple AXI Read Testbench - Compilation and Simulation"
puts "============================================================================"

# Get base paths
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. .. ..]]
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set TB_BASE [file normalize [file join $ROOT_DIR "verification" "testbenches" "simple_read_tb"]]

puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts "Testbench base: $TB_BASE"
puts ""

# Initialize work library
puts "============================================================================"
puts "Initializing work library"
puts "============================================================================"
set WORK_LIB_PATH [file normalize [file join $SCRIPT_DIR "work"]]

if {[file exists $WORK_LIB_PATH]} {
    puts "Removing existing work library..."
    vdel -lib work -all
}

puts "Creating work library at: $WORK_LIB_PATH"
vlib work
vmap work $WORK_LIB_PATH
puts "Work library initialized successfully!"
puts ""

# Create memory initialization file before compilation
puts "============================================================================"
puts "Creating memory initialization file"
puts "============================================================================"
set MEM_INIT_FILE [file normalize [file join $SCRIPT_DIR "mem_init.hex"]]
set mem_fp [open $MEM_INIT_FILE "w"]
if {$mem_fp != ""} {
    puts $mem_fp "DEADBEEF"
    puts $mem_fp "CAFEBABE"
    puts $mem_fp "12345678"
    puts $mem_fp "87654321"
    puts $mem_fp "ABCDEF00"
    puts $mem_fp "00FEDCBA"
    puts $mem_fp "11111111"
    puts $mem_fp "22222222"
    close $mem_fp
    puts "Created mem_init.hex at: $MEM_INIT_FILE"
} else {
    puts "WARNING: Could not create mem_init.hex file"
}
puts ""

# Compile files in dependency order
puts "============================================================================"
puts "Compiling Verilog files"
puts "============================================================================"

# 1. Compile AXI Lite RAM (Slave)
set RAM_FILE [file normalize [file join $SRC_BASE "peripherals" "axi_lite" "axi_lite_ram.v"]]
puts "Compiling: axi_lite_ram.v"
if {[catch {vlog -work work $RAM_FILE} err]} {
    puts "ERROR: Failed to compile axi_lite_ram.v"
    puts $err
    return -code error
}
puts "  ✓ SUCCESS"
puts ""

# 2. Compile Testbench
set TB_FILE [file normalize [file join $TB_BASE "simple_axi_read_tb.v"]]
puts "Compiling: simple_axi_read_tb.v"
if {[catch {vlog -work work $TB_FILE} err]} {
    puts "ERROR: Failed to compile simple_axi_read_tb.v"
    puts $err
    return -code error
}
puts "  ✓ SUCCESS"
puts ""

# Elaborate design
puts "============================================================================"
puts "Elaborating design"
puts "============================================================================"
if {[catch {vsim -t ps -voptargs="+acc=npr" work.simple_axi_read_tb} err]} {
    puts "ERROR: Failed to elaborate design"
    puts $err
    return -code error
}
puts "Design elaborated successfully!"
puts ""

# Open waveform window (only in GUI mode)
if {!$IS_BATCH_MODE} {
    if {[catch {view wave} err]} {
        puts "Note: Wave window will be opened when signals are added"
    }
}

# Add signals to wave window
puts "============================================================================"
puts "Adding signals to wave window"
puts "============================================================================"

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns

# Clock and Reset
add wave -divider -height 20 "=== Clock and Reset ==="
add wave -color Yellow -radix binary /simple_axi_read_tb/ACLK
add wave -color Yellow -radix binary /simple_axi_read_tb/ARESETN

# Master AXI Read Interface
add wave -divider -height 20 "=== Master AXI Read Interface ==="
add wave -color Cyan -radix hex -label "ARADDR" /simple_axi_read_tb/M_AXI_araddr
add wave -color Cyan -radix binary -label "ARVALID" /simple_axi_read_tb/M_AXI_arvalid
add wave -color Cyan -radix binary -label "ARREADY" /simple_axi_read_tb/M_AXI_arready
add wave -color Green -radix hex -label "RDATA" /simple_axi_read_tb/M_AXI_rdata
add wave -color Green -radix binary -label "RVALID" /simple_axi_read_tb/M_AXI_rvalid
add wave -color Green -radix binary -label "RREADY" /simple_axi_read_tb/M_AXI_rready
add wave -color Green -radix binary -label "RRESP" /simple_axi_read_tb/M_AXI_rresp

# Slave AXI Interface
add wave -divider -height 20 "=== Slave AXI Interface ==="
add wave -color Orange -radix hex -label "S_ARADDR" /simple_axi_read_tb/S_AXI_araddr
add wave -color Orange -radix binary -label "S_ARVALID" /simple_axi_read_tb/S_AXI_arvalid
add wave -color Orange -radix binary -label "S_ARREADY" /simple_axi_read_tb/S_AXI_arready
add wave -color Magenta -radix hex -label "S_RDATA" /simple_axi_read_tb/S_AXI_rdata
add wave -color Magenta -radix binary -label "S_RVALID" /simple_axi_read_tb/S_AXI_rvalid
add wave -color Magenta -radix binary -label "S_RREADY" /simple_axi_read_tb/S_AXI_rready
add wave -color Magenta -radix binary -label "S_RRESP" /simple_axi_read_tb/S_AXI_rresp

# Test Control
add wave -divider -height 20 "=== Test Control ==="
add wave -color White -radix hex -label "Read Address" /simple_axi_read_tb/read_addr
add wave -color White -radix hex -label "Read Data" /simple_axi_read_tb/read_data
add wave -color White -radix hex -label "Expected Data" /simple_axi_read_tb/expected_data
add wave -color Lime -radix decimal -label "Tests Passed" /simple_axi_read_tb/test_pass
add wave -color Red -radix decimal -label "Tests Failed" /simple_axi_read_tb/test_fail
add wave -color White -radix binary -label "Master State" /simple_axi_read_tb/master_state

# Slave internal signals (if accessible)
# Note: Memory array signals may show X even with +acc due to ModelSim optimization
# Try to add memory signals - if accessible, they will show actual values
add wave -divider -height 20 "=== Slave Memory (First 8 words) ==="
set mem_added 0
for {set i 0} {$i < 8} {incr i} {
    # Try with parentheses (ModelSim syntax for array indexing)
    if {[catch {add wave -color White -radix hex -label "mem\[$i\]" /simple_axi_read_tb/u_slave_ram/mem($i)} err]} {
        # Try with brackets as fallback
        if {[catch {add wave -color White -radix hex -label "mem\[$i\]" /simple_axi_read_tb/u_slave_ram/mem\[$i\]} err2]} {
            if {$i == 0} {
                puts "Note: Memory array signals not accessible in wave window"
                puts "      This is normal - memory may be optimized. Check S_RDATA for actual values."
            }
        } else {
            set mem_added 1
        }
    } else {
        set mem_added 1
    }
}
if {$mem_added == 0} {
    puts "      Memory contents can be verified through S_RDATA signal during read operations"
}

puts "Signals added to wave window with colors and formatting"
puts ""

# Run simulation
puts "============================================================================"
puts "Running simulation"
puts "============================================================================"
puts "Simulation will run until \$finish is called in testbench"
puts ""

# Run simulation
run -all

# Zoom to fit all signals after simulation (only if not in batch mode)
if {!$IS_BATCH_MODE} {
    # Wait a bit for wave window to update
    after 100
    if {[catch {wave zoom full} err]} {
        puts "Note: Could not zoom wave window: $err"
    }
}

# Check if simulation completed
if {[examine /simple_axi_read_tb/test_fail] == 0} {
    puts ""
    puts "============================================================================"
    puts "SIMULATION COMPLETED SUCCESSFULLY - ALL TESTS PASSED!"
    puts "============================================================================"
} else {
    puts ""
    puts "============================================================================"
    puts "SIMULATION COMPLETED WITH FAILURES"
    puts "============================================================================"
}

puts ""
puts "============================================================================"
puts "Simulation completed!"
puts "============================================================================"
puts ""
puts "Waveform window is open with all signals displayed"
puts "Transcript shows detailed test results above"
puts ""
puts "Useful commands:"
puts "  - Zoom in/out: Use mouse wheel or zoom buttons"
puts "  - Run more: run 100ns"
puts "  - Restart: restart -f"
puts "  - Quit: quit -sim"
puts ""
puts "============================================================================"

# If running in batch mode, quit after simulation
if {$IS_BATCH_MODE} {
    quit -sim
} else {
    # In GUI mode, keep simulation open
    # Wave window is already open and zoomed
    puts ""
    puts "Simulation completed and paused."
    puts "Waveform window is open with all signals displayed."
    puts ""
    puts "Useful commands:"
    puts "  - Continue simulation: run 100ns"
    puts "  - Restart simulation: restart -f"
    puts "  - Zoom in/out: Use mouse wheel or zoom buttons in wave window"
    puts "  - Quit simulation: quit -sim"
    puts ""
}

