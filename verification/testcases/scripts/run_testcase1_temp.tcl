#==============================================================================
# run_testcase1.tcl
# Compile and simulate testcase1_m0_ram
# Description: M0 wins arbitration and communicates with RAM
# 
# Usage: 
#   From anywhere: do "C:/Users/Nguyen Ha Hai/axi4-system-suite/verification/testcases/scripts/run_testcase1.tcl"
#   Or: source "C:/Users/Nguyen Ha Hai/axi4-system-suite/verification/testcases/scripts/run_testcase1.tcl"
#==============================================================================

puts "============================================================================"
puts "Testcase 1: M0 wins arbitration and communicates with RAM"
puts "============================================================================"
puts ""

# Get script directory and root (works from anywhere)
if {[info exists ::SCRIPT_ALREADY_RUNNING]} {
    # If called from another script, use existing paths
    set SCRIPT_DIR $::SCRIPT_DIR
    set TESTCASES_DIR $::TESTCASES_DIR
    set ROOT_DIR $::ROOT_DIR
} else {
    # First time running - calculate paths
    set SCRIPT_DIR [file dirname [file normalize [info script]]]
    set TESTCASES_DIR [file normalize [file join $SCRIPT_DIR ..]]
    set ROOT_DIR [file normalize [file join $TESTCASES_DIR .. ..]]
    set ::SCRIPT_DIR $SCRIPT_DIR
    set ::TESTCASES_DIR $TESTCASES_DIR
    set ::ROOT_DIR $ROOT_DIR
}

set SRC_BASE [file join $ROOT_DIR "src" "axi_interconnect" "Verilog" "rtl"]

# Normalize paths for ModelSim (use forward slashes)
set TESTCASES_DIR_NORM [string map {\\ /} $TESTCASES_DIR]
set ROOT_DIR_NORM [string map {\\ /} $ROOT_DIR]
set SRC_BASE_NORM [string map {\\ /} $SRC_BASE]

# Change to testcases directory
cd $TESTCASES_DIR_NORM

# Create work library if it doesn't exist
if {![file exists [file join $TESTCASES_DIR "work"]]} {
    vlib work
    puts "Created work library"
}
vmap work work

# Compile AXI Interconnect files (if not already compiled)
puts "Compiling AXI Interconnect files..."

# Utils first
vlog -work work [string map {\\ /} [file join $SRC_BASE "utils" "Raising_Edge_Det.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "utils" "Faling_Edge_Detc.v"]]

# Buffers
vlog -work work [string map {\\ /} [file join $SRC_BASE "buffers" "Queue.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "buffers" "Resp_Queue.v"]]

# Handshake
vlog -work work [string map {\\ /} [file join $SRC_BASE "handshake" "AW_HandShake_Checker.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "handshake" "WD_HandShake.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "handshake" "WR_HandShake.v"]]

# Arbitration algorithms
vlog -work work [string map {\\ /} [file join $SRC_BASE "arbitration" "algorithms" "arbiter_fixed_priority.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "arbitration" "algorithms" "arbiter_round_robin.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "arbitration" "algorithms" "arbiter_qos_based.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "arbitration" "algorithms" "read_arbiter.v"]]

# Datapath - demux
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "demux" "Demux_1_2.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "demux" "Demux_1x2.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "demux" "Demux_1x2_en.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "demux" "Demux_1x4.v"]]

# Datapath - mux
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "mux" "Mux_2x1.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "mux" "Mux_2x1_en.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "mux" "Mux_4x1.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "mux" "AW_MUX_2_1.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "mux" "BReady_MUX_2_1.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "datapath" "mux" "WD_MUX_2_1.v"]]

# Decoders
vlog -work work [string map {\\ /} [file join $SRC_BASE "decoders" "Read_Addr_Channel_Dec.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "decoders" "Write_Addr_Channel_Dec.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "decoders" "Write_Resp_Channel_Dec.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "decoders" "Write_Resp_Channel_Arb.v"]]

# Channel controllers - read
vlog -work work [string map {\\ /} [file join $SRC_BASE "channel_controllers" "read" "Controller.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "channel_controllers" "read" "AR_Channel_Controller_Top.v"]]

# Channel controllers - write
vlog -work work [string map {\\ /} [file join $SRC_BASE "channel_controllers" "write" "AW_Channel_Controller_Top.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "channel_controllers" "write" "WD_Channel_Controller_Top.v"]]
vlog -work work [string map {\\ /} [file join $SRC_BASE "channel_controllers" "write" "BR_Channel_Controller_Top.v"]]

# Core
vlog -work work [string map {\\ /} [file join $SRC_BASE "core" "AXI_Interconnect_Full.v"]]

# Compile slave models
puts ""
puts "Compiling slave models..."
vlog -work work [string map {\\ /} [file join $TESTCASES_DIR "slave_models.v"]]

# Compile testcase
puts ""
puts "============================================================================"
puts "Compiling testcase1_m0_ram..."
puts "============================================================================"
vlog -work work [string map {\\ /} [file join $TESTCASES_DIR "testcase1_m0_ram.v"]]

# Run simulation
puts ""
puts "============================================================================"
puts "Running simulation: testcase1_m0_ram"
puts "============================================================================"
vsim -c work.testcase1_m0_ram -do "run -all; quit -f"

puts ""
puts "============================================================================"
puts "Testcase 1 completed!"
puts "============================================================================"

