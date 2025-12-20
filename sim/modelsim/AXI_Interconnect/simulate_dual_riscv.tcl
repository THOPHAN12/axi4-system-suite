#==============================================================================
# simulate_dual_riscv.tcl
# ModelSim Simulation Script for Dual RISC-V System
# 
# Usage: In ModelSim TCL Console, type: do simulate_dual_riscv.tcl
#==============================================================================

puts "============================================================================"
puts "Dual RISC-V System Simulation"
puts "============================================================================"
puts ""

# Get script directory
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR

# Calculate ROOT_DIR: script is in sim/modelsim/AXI_Interconnect/, so go up 3 levels
set ROOT_DIR_TMP [file join $SCRIPT_DIR .. .. ..]
set ROOT_DIR [file normalize $ROOT_DIR_TMP]

# Verify ROOT_DIR is correct by checking if src/ exists
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]

# If src/ doesn't exist, try alternative calculation
if {![file exists $SRC_BASE]} {
    set path_parts [file split $SCRIPT_DIR]
    set path_len [llength $path_parts]
    
    if {$path_len >= 3} {
        set root_parts [lrange $path_parts 0 [expr {$path_len - 4}]]
        set ROOT_DIR [eval file join $root_parts]
        set ROOT_DIR [file normalize $ROOT_DIR]
        set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
        set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]
    } else {
        set ROOT_DIR_TMP2 [file join $SCRIPT_DIR .. ..]
        set ROOT_DIR [file normalize $ROOT_DIR_TMP2]
        set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
        set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]
    }
}

# Paths
set TB_FILE [file normalize [file join $VERIF_BASE "testbenches" "system_tb" "dual_riscv_system_tb.v"]]

# Default test program - can be overridden
if {[info exists env(TEST_PROGRAM)]} {
    set HEX_FILE [file normalize [file join $VERIF_BASE "programs" $env(TEST_PROGRAM)]]
} else {
    set HEX_FILE [file normalize [file join $VERIF_BASE "programs" "simple_test.hex"]]
}

puts "Project directory: $PROJECT_DIR"
puts "Root directory: $ROOT_DIR"
puts "Testbench: $TB_FILE"
puts "Test program: $HEX_FILE"
puts ""

# Check if testbench exists
if {![file exists $TB_FILE]} {
    puts "ERROR: Testbench file not found: $TB_FILE"
    return
}

# Check if hex file exists
if {![file exists $HEX_FILE]} {
    puts "WARNING: Test program not found: $HEX_FILE"
    puts "Simulation will use empty RAM or fail to load program"
}

#==============================================================================
# Step 1: Ensure all files are compiled
#==============================================================================
puts "Step 1: Checking compilation status..."
puts "----------------------------------------"

# Check if work library exists
if {![file exists [file join $PROJECT_DIR "work"]]} {
    puts "Work library not found. Running compile_dual_riscv_files.tcl..."
    if {[file exists [file join $PROJECT_DIR "compile_dual_riscv_files.tcl"]]} {
        source [file join $PROJECT_DIR "compile_dual_riscv_files.tcl"]
    } else {
        puts "ERROR: compile_dual_riscv_files.tcl not found!"
        puts "Please compile the design first."
        return
    }
} else {
    puts "Work library exists. Assuming files are compiled."
    puts "If you encounter errors, run: do compile_dual_riscv_files.tcl"
}

puts ""

#==============================================================================
# Step 2: Compile testbench
#==============================================================================
puts "Step 2: Compiling testbench..."
puts "----------------------------------------"

# Change to project directory
cd $PROJECT_DIR

# Compile testbench
set tb_path_normalized [string map {\\ /} $TB_FILE]
if {[catch {vlog -work work $tb_path_normalized} err]} {
    puts "ERROR compiling testbench:"
    puts $err
    return
} else {
    puts "✓ Testbench compiled successfully"
}

puts ""

#==============================================================================
# Step 3: Start simulation
#==============================================================================
puts "Step 3: Starting simulation..."
puts "----------------------------------------"

# Close any existing simulation
catch {quit -sim}

# Start simulation with optimizations disabled for better debugging
# Pass hex file path as generic/parameter
set hex_path_for_sim [string map {\\ /} $HEX_FILE]

if {[catch {vsim -voptargs=+acc work.dual_riscv_system_tb \
    -G RAM_INIT_HEX=$hex_path_for_sim \
    -t 1ps} err]} {
    puts "ERROR starting simulation:"
    puts $err
    return
} else {
    puts "✓ Simulation started successfully"
}

puts ""

#==============================================================================
# Step 4: Setup waveforms
#==============================================================================
puts "Step 4: Setting up waveforms..."
puts "----------------------------------------"

# Check if wave config file exists (try both locations)
set WAVE_FILE1 [file join $PROJECT_DIR "wave_dual_riscv.do"]
set WAVE_FILE2 [file join $PROJECT_DIR .. "wave_dual_riscv.do"]

if {[file exists $WAVE_FILE1]} {
    puts "Loading wave configuration from: wave_dual_riscv.do"
    do $WAVE_FILE1
} elseif {[file exists $WAVE_FILE2]} {
    puts "Loading wave configuration from: ../wave_dual_riscv.do"
    do $WAVE_FILE2
} else {
    puts "Wave config file not found. Adding basic signals..."
    
    # Add basic signals
    add wave -divider "Clock and Reset"
    add wave -hex /dual_riscv_system_tb/ACLK
    add wave -hex /dual_riscv_system_tb/ARESETN
    add wave -dec /dual_riscv_system_tb/cycle_count
    
    add wave -divider "UART Output"
    add wave -hex /dual_riscv_system_tb/uart_tx_valid
    add wave -hex /dual_riscv_system_tb/uart_tx_byte
    add wave -ascii /dual_riscv_system_tb/uart_tx_byte
    
    add wave -divider "GPIO"
    add wave -hex /dual_riscv_system_tb/gpio_in
    add wave -hex /dual_riscv_system_tb/gpio_out
    
    add wave -divider "SPI"
    add wave -hex /dual_riscv_system_tb/spi_cs_n
    add wave -hex /dual_riscv_system_tb/spi_sclk
    add wave -hex /dual_riscv_system_tb/spi_mosi
    add wave -hex /dual_riscv_system_tb/spi_miso
    
    add wave -divider "SERV Core 0 - AXI Master 0"
    add wave -hex /dual_riscv_system_tb/dut/serv0_axi_araddr
    add wave -hex /dual_riscv_system_tb/dut/serv0_axi_arvalid
    add wave -hex /dual_riscv_system_tb/dut/serv0_axi_arready
    add wave -hex /dual_riscv_system_tb/dut/serv0_axi_rdata
    add wave -hex /dual_riscv_system_tb/dut/serv0_axi_rvalid
    add wave -hex /dual_riscv_system_tb/dut/serv0_axi_rready
    
    add wave -divider "AXI Interconnect - Slave 0 (RAM)"
    add wave -hex /dual_riscv_system_tb/dut/S0_araddr
    add wave -hex /dual_riscv_system_tb/dut/S0_arvalid
    add wave -hex /dual_riscv_system_tb/dut/S0_arready
    add wave -hex /dual_riscv_system_tb/dut/S0_rdata
    add wave -hex /dual_riscv_system_tb/dut/S0_rvalid
    
    # Configure wave window
    configure wave -namecolwidth 250
    configure wave -valuecolwidth 100
    configure wave -justifyvalue left
    configure wave -signalnamewidth 1
    configure wave -snapdistance 10
    configure wave -datasetprefix 0
    configure wave -rowmargin 4
    configure wave -childrowmargin 2
}

puts "✓ Waveforms configured"
puts ""

#==============================================================================
# Step 5: Run simulation
#==============================================================================
puts "Step 5: Running simulation..."
puts "============================================================================"
puts ""

# Run for a reasonable time (increased for comprehensive testing)
# Can be overridden with: run <time>
if {[info exists env(SIM_TIME)]} {
    set sim_time $env(SIM_TIME)
} else {
    set sim_time "500us"
}
run $sim_time

puts ""
puts "============================================================================"
puts "Simulation paused. Use 'run <time>' to continue or 'run -all' to finish."
puts "============================================================================"
puts ""
puts "Useful commands:"
puts "  run 10us          - Run for 10 microseconds"
puts "  run -all          - Run until finish"
puts "  restart -f        - Restart simulation"
puts "  view wave          - Show waveform window"
puts "  do wave_dual_riscv.do  - Reload wave configuration"
puts "============================================================================"

