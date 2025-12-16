# ==============================================================================
# ModelSim TCL Script - Run Busy Signal Testbench
# ==============================================================================
# This script compiles and runs the busy signal testbench
# Usage: 
#   From ModelSim GUI: do run_busy_signal_tb.tcl
#   From command line: vsim -do run_busy_signal_tb.tcl
# ==============================================================================

# Get script directory first (before any cd operations)
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Enable transcript logging
transcript on

# Check if running in batch mode
set IS_BATCH_MODE [batch_mode]

# If already in simulation, quit it first
if {[catch {quit -sim} err]} {
    puts "Starting fresh (no existing simulation)"
} else {
    puts "Quitting existing simulation to start fresh..."
}

# Change to script directory
if {[catch {cd $SCRIPT_DIR} err]} {
    puts "Warning: Could not change directory: $err"
    puts "Continuing with current directory..."
}

puts "============================================================================"
puts "Busy Signal Testbench - Compilation and Simulation"
puts "============================================================================"

# Get base paths
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. .. ..]]
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set TB_BASE [file normalize [file join $ROOT_DIR "verification" "testbenches" "system_tb"]]
set PROG_BASE [file normalize [file join $ROOT_DIR "verification" "programs"]]

puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts "Testbench base: $TB_BASE"
puts ""

# Initialize work library
puts "============================================================================"
puts "Initializing work library..."
puts "============================================================================"
if {[file exists work]} {
    puts "Work library exists, removing old library..."
    vlib work
} else {
    vlib work
}
vmap work work
puts "Work library initialized."
puts ""

# Set include directories
set INCDIRS [list \
    [file join $SRC_BASE] \
    [file join $SRC_BASE "cores"] \
    [file join $SRC_BASE "cores" "serv" "rtl"] \
    [file join $SRC_BASE "axi_interconnect" "rtl" "core"] \
    [file join $SRC_BASE "axi_interconnect" "rtl"] \
    [file join $SRC_BASE "peripherals" "axi_lite"] \
]

# Build include directory list for vlog (as separate arguments)
set INCDIR_LIST [list]
foreach dir $INCDIRS {
    lappend INCDIR_LIST "+incdir+$dir"
}

puts "============================================================================"
puts "Compiling Dependencies"
puts "============================================================================"

# Compile SERV core files (minimal set needed for serv_axi_wrapper)
puts "\n\[1/8\] Compiling SERV core files..."
set SERV_RTL [file join $SRC_BASE "cores" "serv" "rtl"]
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $SERV_RTL "serv_alu.v"] \
        [file join $SERV_RTL "serv_bufreg.v"] \
        [file join $SERV_RTL "serv_bufreg2.v"] \
        [file join $SERV_RTL "serv_compdec.v"] \
        [file join $SERV_RTL "serv_csr.v"] \
        [file join $SERV_RTL "serv_ctrl.v"] \
        [file join $SERV_RTL "serv_decode.v"] \
        [file join $SERV_RTL "serv_immdec.v"] \
        [file join $SERV_RTL "serv_mem_if.v"] \
        [file join $SERV_RTL "serv_rf_if.v"] \
        [file join $SERV_RTL "serv_rf_ram_if.v"] \
        [file join $SERV_RTL "serv_rf_ram.v"] \
        [file join $SERV_RTL "serv_rf_top.v"] \
        [file join $SERV_RTL "serv_state.v"] \
        [file join $SERV_RTL "serv_top.v"]
} result]} {
    puts "ERROR: Failed to compile SERV core files"
    puts $result
    return -code error
}
puts "SERV core files compiled successfully."

# Compile AXI Interconnect core modules
puts "\n\[2/8\] Compiling AXI Interconnect core modules..."
set AXI_CORE [file join $SRC_BASE "axi_interconnect" "rtl" "core"]
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_CORE "AXI_Master_Aggregator.v"] \
        [file join $AXI_CORE "AXI_Interconnect.v"]
} result]} {
    puts "ERROR: Failed to compile AXI Interconnect core"
    puts $result
    return -code error
}
puts "AXI Interconnect core compiled successfully."

# Compile AXI Interconnect sub-modules (needed for AXI_Interconnect)
puts "\n\[3/8\] Compiling AXI Interconnect sub-modules..."
set AXI_RTL [file join $SRC_BASE "axi_interconnect" "rtl"]
if {[catch {
    # Compile arbitration modules
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "arbitration" "algorithms" "arbiter_fixed_priority.v"] \
        [file join $AXI_RTL "arbitration" "algorithms" "arbiter_round_robin.v"] \
        [file join $AXI_RTL "arbitration" "algorithms" "arbiter_qos_based.v"] \
        [file join $AXI_RTL "arbitration" "read_arbiter.v"]
    
    # Compile channel controllers
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "channel_controllers" "read" "Controller.v"] \
        [file join $AXI_RTL "channel_controllers" "write" "AW_Channel_Controller_Top.v"] \
        [file join $AXI_RTL "channel_controllers" "write" "WD_Channel_Controller_Top.v"] \
        [file join $AXI_RTL "channel_controllers" "write" "BR_Channel_Controller_Top.v"]
    
    # Compile datapath modules
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "datapath" "mux" "Mux_2x1.v"] \
        [file join $AXI_RTL "datapath" "mux" "Mux_2x1_en.v"] \
        [file join $AXI_RTL "datapath" "mux" "Mux_4x1.v"] \
        [file join $AXI_RTL "datapath" "mux" "AW_MUX_2_1.v"] \
        [file join $AXI_RTL "datapath" "mux" "WD_MUX_2_1.v"] \
        [file join $AXI_RTL "datapath" "mux" "BReady_MUX_2_1.v"] \
        [file join $AXI_RTL "datapath" "demux" "Demux_1_2.v"] \
        [file join $AXI_RTL "datapath" "demux" "Demux_1x2.v"] \
        [file join $AXI_RTL "datapath" "demux" "Demux_1x2_en.v"] \
        [file join $AXI_RTL "datapath" "demux" "Demux_1x4.v"]
    
    # Compile decoders
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "decoders" "Read_Addr_Channel_Dec.v"] \
        [file join $AXI_RTL "decoders" "Write_Addr_Channel_Dec.v"] \
        [file join $AXI_RTL "decoders" "Write_Resp_Channel_Dec.v"] \
        [file join $AXI_RTL "decoders" "Write_Resp_Channel_Arb.v"]
    
    # Compile buffers
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "buffers" "Queue.v"] \
        [file join $AXI_RTL "buffers" "Resp_Queue.v"]
    
    # Compile handshake modules
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "handshake" "AW_HandShake_Checker.v"] \
        [file join $AXI_RTL "handshake" "WD_HandShake.v"] \
        [file join $AXI_RTL "handshake" "WR_HandShake.v"]
    
    # Compile utils
    eval vlog -work work $INCDIR_LIST \
        [file join $AXI_RTL "utils" "Raising_Edge_Det.v"] \
        [file join $AXI_RTL "utils" "Faling_Edge_Detc.v"]
} result]} {
    puts "WARNING: Some AXI Interconnect sub-modules may have compilation issues"
    puts "Continuing anyway..."
}
puts "AXI Interconnect sub-modules compiled."

# Compile dual_axi_shell
puts "\n\[4/8\] Compiling dual_axi_shell..."
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $SRC_BASE "systems" "dual_axi_shell.v"]
} result]} {
    puts "ERROR: Failed to compile dual_axi_shell"
    puts $result
    return -code error
}
puts "dual_axi_shell compiled successfully."

# Compile AXI Bridge (serv_axi_wrapper)
puts "\n\[5/8\] Compiling AXI Bridge (serv_axi_wrapper)..."
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $SRC_BASE "axi_bridge" "serv_axi_wrapper.v"]
} result]} {
    puts "ERROR: Failed to compile serv_axi_wrapper"
    puts $result
    return -code error
}
puts "serv_axi_wrapper compiled successfully."

# Compile Peripherals
puts "\n\[6/8\] Compiling Peripherals..."
set PERIPH_BASE [file join $SRC_BASE "peripherals" "axi_lite"]
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $PERIPH_BASE "axi_lite_ram.v"] \
        [file join $PERIPH_BASE "axi_lite_gpio.v"] \
        [file join $PERIPH_BASE "axi_lite_uart.v"] \
        [file join $PERIPH_BASE "axi_lite_spi.v"]
} result]} {
    puts "ERROR: Failed to compile peripherals"
    puts $result
    return -code error
}
puts "Peripherals compiled successfully."

# Compile System (dual_serv_axi_system)
puts "\n\[7/8\] Compiling System (dual_serv_axi_system)..."
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $SRC_BASE "systems" "dual_serv_axi_system.v"]
} result]} {
    puts "ERROR: Failed to compile dual_serv_axi_system"
    puts $result
    return -code error
}
puts "dual_serv_axi_system compiled successfully."

# Compile Testbench
puts "\n\[8/8\] Compiling Testbench (busy_signal_tb)..."
if {[catch {
    eval vlog -work work $INCDIR_LIST \
        [file join $TB_BASE "busy_signal_tb.v"]
} result]} {
    puts "ERROR: Failed to compile testbench"
    puts $result
    return -code error
}
puts "Testbench compiled successfully."

puts "\n============================================================================"
puts "Compilation Complete"
puts "============================================================================"

# Start Simulation
puts "\n============================================================================"
puts "Starting Simulation"
puts "============================================================================"

if {[catch {
    vsim -voptargs="+acc" work.busy_signal_tb
} result]} {
    puts "ERROR: Failed to start simulation"
    puts $result
    return -code error
}

# Add waves for better visibility
puts "\nAdding waves..."
add wave -divider "Clock and Reset"
add wave -radix binary /busy_signal_tb/ACLK
add wave -radix binary /busy_signal_tb/ARESETN

add wave -divider "Busy Signals"
add wave -radix binary /busy_signal_tb/serv0_busy
add wave -radix binary /busy_signal_tb/serv1_busy

add wave -divider "SERV0 Debug"
add wave -radix hex /busy_signal_tb/serv0_debug_pc
add wave -radix hex /busy_signal_tb/serv0_debug_r1
add wave -radix hex /busy_signal_tb/serv0_debug_r2

add wave -divider "SERV1 Debug"
add wave -radix hex /busy_signal_tb/serv1_debug_pc
add wave -radix hex /busy_signal_tb/serv1_debug_r1
add wave -radix hex /busy_signal_tb/serv1_debug_r2

add wave -divider "GPIO"
add wave -radix hex /busy_signal_tb/gpio_in
add wave -radix hex /busy_signal_tb/gpio_out

add wave -divider "UART"
add wave -radix binary /busy_signal_tb/uart_tx_valid
add wave -radix hex /busy_signal_tb/uart_tx_byte

# Run simulation
set SIM_TIME 10000ns
puts "\nRunning simulation for $SIM_TIME..."
puts "============================================================================"

if {$IS_BATCH_MODE} {
    # Batch mode - run and exit
    run $SIM_TIME
    puts "\n============================================================================"
    puts "Simulation Complete"
    puts "============================================================================"
    quit -sim
} else {
    # GUI mode - just run
    run $SIM_TIME
    puts "\n============================================================================"
    puts "Simulation Complete"
    puts "============================================================================"
    puts "You can now view waveforms and continue simulation if needed."
}

