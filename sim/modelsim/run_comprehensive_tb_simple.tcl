#==============================================================================
# run_comprehensive_tb_simple.tcl
# Simple version - compile and simulate comprehensive_system_tb.sv
# Usage: In ModelSim TCL Console, type: do run_comprehensive_tb_simple.tcl
#==============================================================================

puts "============================================================================"
puts "Compile and Simulate Comprehensive System Testbench"
puts "============================================================================"
puts ""

# Get script directory using file normalize to handle spaces in path
# Convert to forward slashes for TCL compatibility
set SCRIPT_DIR [string map {\\ /} [file dirname [file normalize [info script]]]]
set ROOT_DIR [string map {\\ /} [file normalize [file join $SCRIPT_DIR .. ..]]]

# Normalize all paths and convert to forward slashes
set SRC_BASE [string map {\\ /} [file normalize [file join $ROOT_DIR SystemVerilog]]]
set TB_FILE [string map {\\ /} [file normalize [file join $SRC_BASE testbenches axi_masters comprehensive_system_tb.sv]]]
set AXI_INTERCONNECT_DIR [string map {\\ /} [file normalize [file join $SRC_BASE axi_interconnect]]]
set AXI_MASTERS_DIR [string map {\\ /} [file normalize [file join $SRC_BASE axi_masters]]]

# Change to script directory (use forward slashes)
cd $SCRIPT_DIR
puts "Changed to directory: [pwd]"

# Create work library - always recreate to ensure it exists
if {[file exists [file join $SCRIPT_DIR work]]} {
    # Remove old work library if exists
    file delete -force [file join $SCRIPT_DIR work]
}
vlib work
vmap work work
puts "Created work library at: [file join $SCRIPT_DIR work]"

puts ""
puts "Source directory: $SRC_BASE"
puts "Testbench file: $TB_FILE"
puts ""

# Check if testbench exists
if {![file exists $TB_FILE]} {
    puts "ERROR: Testbench file not found: $TB_FILE"
    exit 1
}

# Compile all .sv files recursively from a directory
proc compile_sv_recursive {base_dir} {
    set count 0
    if {![file exists $base_dir]} {
        return 0
    }
    
    # Get all .sv files in current directory
    set sv_files [glob -nocomplain -directory $base_dir -type f *.sv]
    foreach file $sv_files {
        set file_normalized [string map {\\ /} [file normalize $file]]
        if {[catch {vlog -work work -sv $file_normalized} err]} {
            puts "  WARNING: [file tail $file_normalized]: $err"
        } else {
            puts "  OK: [file tail $file_normalized]"
            incr count
        }
    }
    
    # Recursively compile subdirectories
    set dirs [glob -nocomplain -directory $base_dir -type d *]
    foreach subdir $dirs {
        set sub_count [compile_sv_recursive $subdir]
        set count [expr $count + $sub_count]
    }
    
    return $count
}

# Compile dependencies
puts "============================================================================"
puts "Compiling Dependencies"
puts "============================================================================"
puts ""

# Compile AXI Interconnect
puts "\[1/2\] Compiling AXI Interconnect..."
set count1 [compile_sv_recursive $AXI_INTERCONNECT_DIR]
puts "  Compiled $count1 files"
puts ""

# Compile AXI Masters
puts "\[2/2\] Compiling AXI Masters..."
set count2 [compile_sv_recursive $AXI_MASTERS_DIR]
puts "  Compiled $count2 files"
puts ""

# Compile testbench
puts "============================================================================"
puts "Compiling Testbench"
puts "============================================================================"
puts ""
set TB_FILE_NORM [string map {\\ /} [file normalize $TB_FILE]]
if {[catch {vlog -work work -sv $TB_FILE_NORM} err]} {
    puts "ERROR compiling testbench: $err"
    quit -force
} else {
    puts "OK: comprehensive_system_tb.sv"
}
puts ""

# Start simulation
puts "============================================================================"
puts "Starting Simulation"
puts "============================================================================"
puts ""

vsim -voptargs="+acc" work.comprehensive_system_tb

# Add waves
add wave -divider "Clock and Reset"
add wave /comprehensive_system_tb/ACLK
add wave /comprehensive_system_tb/ARESETN

add wave -divider "Master 0 Control"
add wave /comprehensive_system_tb/m0_start
add wave /comprehensive_system_tb/m0_busy
add wave /comprehensive_system_tb/m0_completed
add wave -hex /comprehensive_system_tb/m0_instruction
add wave -hex /comprehensive_system_tb/m0_result

add wave -divider "Master 1 Control"
add wave /comprehensive_system_tb/m1_start
add wave /comprehensive_system_tb/m1_busy
add wave /comprehensive_system_tb/m1_completed
add wave -hex /comprehensive_system_tb/m1_address_offset

add wave -divider "Master 0 AXI Write"
add wave -hex /comprehensive_system_tb/M0_AWADDR
add wave /comprehensive_system_tb/M0_AWVALID
add wave /comprehensive_system_tb/M0_AWREADY
add wave -hex /comprehensive_system_tb/M0_WDATA
add wave /comprehensive_system_tb/M0_WVALID
add wave /comprehensive_system_tb/M0_WREADY
add wave /comprehensive_system_tb/M0_BVALID
add wave /comprehensive_system_tb/M0_BREADY

add wave -divider "Master 0 AXI Read"
add wave -hex /comprehensive_system_tb/M0_ARADDR
add wave /comprehensive_system_tb/M0_ARVALID
add wave /comprehensive_system_tb/M0_ARREADY
add wave -hex /comprehensive_system_tb/M0_RDATA
add wave /comprehensive_system_tb/M0_RVALID
add wave /comprehensive_system_tb/M0_RREADY

add wave -divider "Master 1 AXI Write"
add wave -hex /comprehensive_system_tb/M1_AWADDR
add wave /comprehensive_system_tb/M1_AWVALID
add wave /comprehensive_system_tb/M1_AWREADY
add wave -hex /comprehensive_system_tb/M1_WDATA
add wave /comprehensive_system_tb/M1_WVALID
add wave /comprehensive_system_tb/M1_WREADY

add wave -divider "Master 1 AXI Read"
add wave -hex /comprehensive_system_tb/M1_ARADDR
add wave /comprehensive_system_tb/M1_ARVALID
add wave /comprehensive_system_tb/M1_ARREADY
add wave -hex /comprehensive_system_tb/M1_RDATA
add wave /comprehensive_system_tb/M1_RVALID
add wave /comprehensive_system_tb/M1_RREADY

# Log all output to transcript file
set transcript_file [file join $SCRIPT_DIR comprehensive_system_tb_transcript.log]
transcript file $transcript_file
puts "Transcript will be saved to: $transcript_file"

# Run simulation
puts "Running simulation..."
puts ""

# Run until finish or timeout
run -all

# Save waveform (WLF format) - only works in GUI mode
# In batch mode, waveform is automatically saved to vsim.wlf
set wave_file [file join $SCRIPT_DIR comprehensive_system_tb.wlf]
if {[info exists dataset]} {
    dataset save $wave_file
    puts "Waveform saved to: $wave_file"
} else {
    puts "Note: To save waveform, run in GUI mode or use: vsim -gui -do run_comprehensive_tb_simple.tcl"
    puts "Waveform is available in vsim.wlf in current directory"
}

puts ""
puts "============================================================================"
puts "Simulation Complete"
puts "============================================================================"
puts ""

