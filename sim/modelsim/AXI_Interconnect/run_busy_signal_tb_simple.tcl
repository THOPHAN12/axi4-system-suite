# ==============================================================================
# Simple TCL Script - Run Busy Signal Testbench
# Usage: In ModelSim GUI, type: do run_busy_signal_tb_simple.tcl
# ==============================================================================

# Get current directory and set paths
set SCRIPT_DIR [pwd]
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. .. ..]]
set SRC_BASE [file join $ROOT_DIR src]
set TB_BASE [file join $ROOT_DIR verification testbenches system_tb]

puts "============================================================================"
puts "Busy Signal Testbench - Simple Compilation"
puts "============================================================================"
puts "Root: $ROOT_DIR"
puts ""

# Initialize work library
if {[file exists work]} {
    vlib work
}
vmap work work

# Set include directories
set INCDIRS [list \
    [file join $SRC_BASE] \
    [file join $SRC_BASE cores] \
    [file join $SRC_BASE cores serv rtl] \
    [file join $SRC_BASE axi_interconnect rtl core] \
    [file join $SRC_BASE axi_interconnect rtl] \
    [file join $SRC_BASE peripherals axi_lite] \
]

# Build include directory arguments - use list to preserve paths with spaces
set INCDIR_ARGS [list]
foreach dir $INCDIRS {
    lappend INCDIR_ARGS "+incdir+$dir"
}

puts "============================================================================"
puts "Compiling..."
puts "============================================================================"

# Compile SERV core
puts "\[1/6\] SERV core..."
set SERV_RTL [file join $SRC_BASE cores serv rtl]
set SERV_FILES [list \
    [file join $SERV_RTL serv_alu.v] \
    [file join $SERV_RTL serv_bufreg.v] \
    [file join $SERV_RTL serv_bufreg2.v] \
    [file join $SERV_RTL serv_compdec.v] \
    [file join $SERV_RTL serv_csr.v] \
    [file join $SERV_RTL serv_ctrl.v] \
    [file join $SERV_RTL serv_decode.v] \
    [file join $SERV_RTL serv_immdec.v] \
    [file join $SERV_RTL serv_mem_if.v] \
    [file join $SERV_RTL serv_rf_if.v] \
    [file join $SERV_RTL serv_rf_ram_if.v] \
    [file join $SERV_RTL serv_rf_ram.v] \
    [file join $SERV_RTL serv_rf_top.v] \
    [file join $SERV_RTL serv_state.v] \
    [file join $SERV_RTL serv_top.v] \
]
# Use eval with proper list expansion to handle paths with spaces
eval [list vlog -work work] $INCDIR_ARGS $SERV_FILES

# Compile AXI Interconnect core
puts "\[2/6\] AXI Interconnect core..."
set AXI_CORE [file join $SRC_BASE axi_interconnect rtl core]
set AXI_CORE_FILES [list \
    [file join $AXI_CORE AXI_Master_Aggregator.v] \
    [file join $AXI_CORE AXI_Interconnect.v] \
    [file join $AXI_CORE AXI_Interconnect_Full.v] \
]
eval [list vlog -work work] $INCDIR_ARGS $AXI_CORE_FILES

# Compile AXI Interconnect sub-modules
puts "\[3/6\] AXI Interconnect sub-modules..."
set AXI_RTL [file join $SRC_BASE axi_interconnect rtl]
set AXI_SUB_FILES [list \
    [file join $AXI_RTL arbitration algorithms arbiter_fixed_priority.v] \
    [file join $AXI_RTL arbitration algorithms arbiter_round_robin.v] \
    [file join $AXI_RTL arbitration algorithms arbiter_qos_based.v] \
    [file join $AXI_RTL arbitration algorithms read_arbiter.v] \
    [file join $AXI_RTL channel_controllers read Controller.v] \
    [file join $AXI_RTL channel_controllers write AW_Channel_Controller_Top.v] \
    [file join $AXI_RTL channel_controllers write WD_Channel_Controller_Top.v] \
    [file join $AXI_RTL channel_controllers write BR_Channel_Controller_Top.v] \
    [file join $AXI_RTL datapath mux Mux_2x1.v] \
    [file join $AXI_RTL datapath mux Mux_2x1_en.v] \
    [file join $AXI_RTL datapath mux Mux_4x1.v] \
    [file join $AXI_RTL datapath mux AW_MUX_2_1.v] \
    [file join $AXI_RTL datapath mux WD_MUX_2_1.v] \
    [file join $AXI_RTL datapath mux BReady_MUX_2_1.v] \
    [file join $AXI_RTL datapath demux Demux_1_2.v] \
    [file join $AXI_RTL datapath demux Demux_1x2.v] \
    [file join $AXI_RTL datapath demux Demux_1x2_en.v] \
    [file join $AXI_RTL datapath demux Demux_1x4.v] \
    [file join $AXI_RTL decoders Read_Addr_Channel_Dec.v] \
    [file join $AXI_RTL decoders Write_Addr_Channel_Dec.v] \
    [file join $AXI_RTL decoders Write_Resp_Channel_Dec.v] \
    [file join $AXI_RTL decoders Write_Resp_Channel_Arb.v] \
    [file join $AXI_RTL buffers Queue.v] \
    [file join $AXI_RTL buffers Resp_Queue.v] \
    [file join $AXI_RTL handshake AW_HandShake_Checker.v] \
    [file join $AXI_RTL handshake WD_HandShake.v] \
    [file join $AXI_RTL handshake WR_HandShake.v] \
    [file join $AXI_RTL utils Raising_Edge_Det.v] \
    [file join $AXI_RTL utils Faling_Edge_Detc.v] \
]
eval [list vlog -work work] $INCDIR_ARGS $AXI_SUB_FILES

# Compile dual_axi_shell
puts "\[4/6\] dual_axi_shell..."
set SHELL_FILE [list [file join $SRC_BASE systems dual_axi_shell.v]]
eval [list vlog -work work] $INCDIR_ARGS $SHELL_FILE

# Compile AXI Bridge and Peripherals
puts "\[5/6\] AXI Bridge and Peripherals..."
set BRIDGE_FILE [list [file join $SRC_BASE axi_bridge serv_axi_wrapper.v]]
eval [list vlog -work work] $INCDIR_ARGS $BRIDGE_FILE
set PERIPH_FILES [list \
    [file join $SRC_BASE peripherals axi_lite axi_lite_ram.v] \
    [file join $SRC_BASE peripherals axi_lite axi_lite_gpio.v] \
    [file join $SRC_BASE peripherals axi_lite axi_lite_uart.v] \
    [file join $SRC_BASE peripherals axi_lite axi_lite_spi.v] \
]
eval [list vlog -work work] $INCDIR_ARGS $PERIPH_FILES

# Compile System and Testbench
puts "\[6/6\] System and Testbench..."
set SYSTEM_FILE [list [file join $SRC_BASE systems dual_serv_axi_system.v]]
eval [list vlog -work work] $INCDIR_ARGS $SYSTEM_FILE
set TB_FILE [list [file join $TB_BASE busy_signal_tb.v]]
eval [list vlog -work work] $INCDIR_ARGS $TB_FILE

puts ""
puts "============================================================================"
puts "Compilation Complete!"
puts "============================================================================"
puts ""
puts "Starting simulation..."
puts ""

# Start simulation
vsim -voptargs="+acc" work.busy_signal_tb

# Add waves
add wave -divider "Clock and Reset"
add wave /busy_signal_tb/ACLK
add wave /busy_signal_tb/ARESETN

add wave -divider "Busy Signals"
add wave /busy_signal_tb/serv0_busy
add wave /busy_signal_tb/serv1_busy

add wave -divider "SERV0 Debug"
add wave -radix hex /busy_signal_tb/serv0_debug_pc
add wave -radix hex /busy_signal_tb/serv0_debug_r1
add wave -radix hex /busy_signal_tb/serv0_debug_r2

add wave -divider "SERV1 Debug"
add wave -radix hex /busy_signal_tb/serv1_debug_pc
add wave -radix hex /busy_signal_tb/serv1_debug_r1
add wave -radix hex /busy_signal_tb/serv1_debug_r2

# Run simulation
run 10000ns

puts ""
puts "============================================================================"
puts "Simulation Complete!"
puts "============================================================================"
puts ""
puts "You can continue simulation with: run 10000ns"
puts "Or view waveforms in the Wave window."

