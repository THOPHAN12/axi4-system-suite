# TCL script to compile and run all testcases

# Get script directory
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. ..]]
set SRC_BASE [file join $ROOT_DIR "src" "axi_interconnect" "Verilog" "rtl"]

puts "============================================================================"
puts "Compile and Run Testcases"
puts "============================================================================"
puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts ""

# Change to testcases directory
cd $SCRIPT_DIR

# Create work library
vlib work
vmap work work

# Compile in dependency order
puts "Compiling AXI Interconnect files..."

# Utils first
vlog -work work [file join $SRC_BASE "utils" "Raising_Edge_Det.v"]
vlog -work work [file join $SRC_BASE "utils" "Faling_Edge_Detc.v"]

# Buffers
vlog -work work [file join $SRC_BASE "buffers" "Queue.v"]
vlog -work work [file join $SRC_BASE "buffers" "Resp_Queue.v"]

# Handshake
vlog -work work [file join $SRC_BASE "handshake" "AW_HandShake_Checker.v"]
vlog -work work [file join $SRC_BASE "handshake" "WD_HandShake.v"]
vlog -work work [file join $SRC_BASE "handshake" "WR_HandShake.v"]

# Arbitration algorithms
vlog -work work [file join $SRC_BASE "arbitration" "algorithms" "arbiter_fixed_priority.v"]
vlog -work work [file join $SRC_BASE "arbitration" "algorithms" "arbiter_round_robin.v"]
vlog -work work [file join $SRC_BASE "arbitration" "algorithms" "arbiter_qos_based.v"]
vlog -work work [file join $SRC_BASE "arbitration" "algorithms" "read_arbiter.v"]

# Datapath - demux
vlog -work work [file join $SRC_BASE "datapath" "demux" "Demux_1_2.v"]
vlog -work work [file join $SRC_BASE "datapath" "demux" "Demux_1x2.v"]
vlog -work work [file join $SRC_BASE "datapath" "demux" "Demux_1x2_en.v"]
vlog -work work [file join $SRC_BASE "datapath" "demux" "Demux_1x4.v"]

# Datapath - mux
vlog -work work [file join $SRC_BASE "datapath" "mux" "Mux_2x1.v"]
vlog -work work [file join $SRC_BASE "datapath" "mux" "Mux_2x1_en.v"]
vlog -work work [file join $SRC_BASE "datapath" "mux" "Mux_4x1.v"]
vlog -work work [file join $SRC_BASE "datapath" "mux" "AW_MUX_2_1.v"]
vlog -work work [file join $SRC_BASE "datapath" "mux" "BReady_MUX_2_1.v"]
vlog -work work [file join $SRC_BASE "datapath" "mux" "WD_MUX_2_1.v"]

# Decoders
vlog -work work [file join $SRC_BASE "decoders" "Read_Addr_Channel_Dec.v"]
vlog -work work [file join $SRC_BASE "decoders" "Write_Addr_Channel_Dec.v"]
vlog -work work [file join $SRC_BASE "decoders" "Write_Resp_Channel_Dec.v"]
vlog -work work [file join $SRC_BASE "decoders" "Write_Resp_Channel_Arb.v"]

# Channel controllers - read
vlog -work work [file join $SRC_BASE "channel_controllers" "read" "Controller.v"]
vlog -work work [file join $SRC_BASE "channel_controllers" "read" "AR_Channel_Controller_Top.v"]

# Channel controllers - write
vlog -work work [file join $SRC_BASE "channel_controllers" "write" "AW_Channel_Controller_Top.v"]
vlog -work work [file join $SRC_BASE "channel_controllers" "write" "WD_Channel_Controller_Top.v"]
vlog -work work [file join $SRC_BASE "channel_controllers" "write" "BR_Channel_Controller_Top.v"]

# Core
vlog -work work [file join $SRC_BASE "core" "AXI_Interconnect_Full.v"]

puts ""
puts "Compiling testcases..."

# Compile testcases
set testcases [list testcase1_m0_ram testcase2_m1_ram testcase3_m0_uart testcase4_m1_spi testcase5_m0_gpio]

foreach testcase $testcases {
    puts "Compiling $testcase..."
    vlog -work work ${testcase}.v
}

puts ""
puts "============================================================================"
puts "Running testcases..."
puts "============================================================================"

foreach testcase $testcases {
    puts ""
    puts "========================================"
    puts "Running $testcase"
    puts "========================================"
    vsim -c work.${testcase} -do "run -all; quit -f"
}

puts ""
puts "============================================================================"
puts "All testcases completed!"
puts "============================================================================"

