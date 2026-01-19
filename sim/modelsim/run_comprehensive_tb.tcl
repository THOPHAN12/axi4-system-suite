#==============================================================================
# run_comprehensive_tb.tcl
# Compile and simulate comprehensive_system_tb.sv
# Usage: In ModelSim TCL Console, type: do run_comprehensive_tb.tcl
#==============================================================================

puts "============================================================================"
puts "Compile and Simulate Comprehensive System Testbench"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. ..]]

set SRC_BASE [file normalize [file join $ROOT_DIR "SystemVerilog"]]
set TB_DIR [file normalize [file join $SRC_BASE "testbenches" "axi_masters"]]
set TB_FILE [file normalize [file join $TB_DIR "comprehensive_system_tb.sv"]]

# Change to script directory (quote path to handle spaces)
cd "$SCRIPT_DIR"

# Create work library
if {![file exists [file join "$SCRIPT_DIR" "work"]]} {
    vlib work
    puts "Created work library"
} else {
    vmap work work
}

puts ""
puts "Source directory: $SRC_BASE"
puts "Testbench file: $TB_FILE"
puts ""

# Check if testbench exists
if {![file exists "$TB_FILE"]} {
    puts "ERROR: Testbench file not found: $TB_FILE"
    exit 1
}

# Set include paths
set AXI_INTERCONNECT_DIR [file normalize [file join $SRC_BASE "axi_interconnect"]]
set AXI_MASTERS_DIR [file normalize [file join $SRC_BASE "axi_masters"]]

# First, try to use existing compile script if available
set COMPILE_SCRIPT [file normalize [file join "$SCRIPT_DIR" "compile_sv_files.tcl"]]
if {[file exists "$COMPILE_SCRIPT"]} {
    puts "Found compile_sv_files.tcl, using it to compile dependencies..."
    puts "  (This will compile all AXI Interconnect files)"
    puts ""
    source "$COMPILE_SCRIPT"
    puts ""
} else {
    puts "compile_sv_files.tcl not found, compiling manually..."
    puts ""
    
    # Compile dependencies manually
    puts "============================================================================"
    puts "Compiling Dependencies"
    puts "============================================================================"
    puts ""
    
    # Compile all AXI Interconnect files recursively
    proc compile_sv_dir {dir} {
        set count 0
        if {![file exists "$dir"]} {
            return 0
        }
        
        # Get all .sv files in current directory
        set sv_files [glob -nocomplain -directory "$dir" -type f "*.sv"]
        foreach file $sv_files {
            if {[catch {vlog -work work -sv "$file"} err]} {
                puts "  WARNING: Failed to compile [file tail "$file"]: $err"
            } else {
                puts "  ✓ Compiled: [file tail "$file"]"
                incr count
            }
        }
        
        # Recursively compile subdirectories
        set dirs [glob -nocomplain -directory "$dir" -type d *]
        foreach subdir $dirs {
            set sub_count [compile_sv_dir "$subdir"]
            set count [expr $count + $sub_count]
        }
        
        return $count
    }
    
    # Compile AXI Interconnect (all subdirectories)
    puts "\[1/2\] Compiling AXI Interconnect..."
    set count [compile_sv_dir "$AXI_INTERCONNECT_DIR"]
    puts "  Compiled $count files from AXI Interconnect"
    puts ""
    
    # Compile AXI Masters
    puts "\[2/2\] Compiling AXI Masters..."
    set M0_FILE [file normalize [file join "$AXI_MASTERS_DIR" "axi_master_0.sv"]]
    set M1_FILE [file normalize [file join "$AXI_MASTERS_DIR" "axi_master_1.sv"]]
    
    if {[file exists "$M0_FILE"]} {
        if {[catch {vlog -work work -sv "$M0_FILE"} err]} {
            puts "  ERROR compiling axi_master_0.sv: $err"
            exit 1
        } else {
            puts "  ✓ Compiled: axi_master_0.sv"
        }
    }
    
    if {[file exists "$M1_FILE"]} {
        if {[catch {vlog -work work -sv "$M1_FILE"} err]} {
            puts "  ERROR compiling axi_master_1.sv: $err"
            exit 1
        } else {
            puts "  ✓ Compiled: axi_master_1.sv"
        }
    }
    puts ""
}

# 4. Compile testbench
puts "============================================================================"
puts "Compiling Testbench"
puts "============================================================================"
puts ""
if {[catch {vlog -work work -sv "$TB_FILE"} err]} {
    puts "ERROR compiling testbench: $err"
    exit 1
} else {
    puts "✓ Compiled: comprehensive_system_tb.sv"
}
puts ""

# Start simulation
puts "============================================================================"
puts "Starting Simulation"
puts "============================================================================"
puts ""

# Optimize simulation
vsim -voptargs="+acc" work.comprehensive_system_tb

# Add waves
add wave -divider "Clock and Reset"
add wave /comprehensive_system_tb/ACLK
add wave /comprehensive_system_tb/ARESETN

add wave -divider "Master 0 Control"
add wave /comprehensive_system_tb/m0_start
add wave /comprehensive_system_tb/m0_busy
add wave /comprehensive_system_tb/m0_completed
add wave /comprehensive_system_tb/m0_instruction
add wave /comprehensive_system_tb/m0_result

add wave -divider "Master 1 Control"
add wave /comprehensive_system_tb/m1_start
add wave /comprehensive_system_tb/m1_busy
add wave /comprehensive_system_tb/m1_completed

add wave -divider "Master 0 AXI Write"
add wave /comprehensive_system_tb/M0_AWADDR
add wave /comprehensive_system_tb/M0_AWVALID
add wave /comprehensive_system_tb/M0_AWREADY
add wave /comprehensive_system_tb/M0_WDATA
add wave /comprehensive_system_tb/M0_WVALID
add wave /comprehensive_system_tb/M0_WREADY
add wave /comprehensive_system_tb/M0_BVALID
add wave /comprehensive_system_tb/M0_BREADY

add wave -divider "Master 0 AXI Read"
add wave /comprehensive_system_tb/M0_ARADDR
add wave /comprehensive_system_tb/M0_ARVALID
add wave /comprehensive_system_tb/M0_ARREADY
add wave /comprehensive_system_tb/M0_RDATA
add wave /comprehensive_system_tb/M0_RVALID
add wave /comprehensive_system_tb/M0_RREADY

add wave -divider "Master 1 AXI Write"
add wave /comprehensive_system_tb/M1_AWADDR
add wave /comprehensive_system_tb/M1_AWVALID
add wave /comprehensive_system_tb/M1_AWREADY
add wave /comprehensive_system_tb/M1_WDATA
add wave /comprehensive_system_tb/M1_WVALID
add wave /comprehensive_system_tb/M1_WREADY

add wave -divider "Master 1 AXI Read"
add wave /comprehensive_system_tb/M1_ARADDR
add wave /comprehensive_system_tb/M1_ARVALID
add wave /comprehensive_system_tb/M1_ARREADY
add wave /comprehensive_system_tb/M1_RDATA
add wave /comprehensive_system_tb/M1_RVALID
add wave /comprehensive_system_tb/M1_RREADY

# Run simulation
puts "Running simulation..."
puts ""

# Run until $finish (testbench will call $finish when done)
run -all

puts ""
puts "============================================================================"
puts "Simulation Complete"
puts "============================================================================"
puts ""

