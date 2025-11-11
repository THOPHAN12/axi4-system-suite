# ModelSim Simulation Script for AXI Interconnect Test
# Usage: vsim -do run_test.tcl

# Clean up previous compilation
if {[file exists work]} {
    vdel -all
}

# Create work library
vlib work
vmap work work

# Define base paths
set project_root "../.."
set src_path "$project_root/src"
set master_path "$project_root/Master_ALU"
set slave_path "$project_root/Slave_Memory"
set tb_path "$project_root/tb"
set intercon_path "$src_path/axi_interconnect/rtl"

puts "=========================================="
puts "Compiling AXI Interconnect Components..."
puts "=========================================="

# Compile in dependency order (bottom-up)

# 1. Utils
puts "Compiling utils..."
vlog +acc -work work "$intercon_path/utils/Raising_Edge_Det.v"
vlog +acc -work work "$intercon_path/utils/Faling_Edge_Detc.v"

# 2. Buffers/Queues
puts "Compiling buffers..."
vlog +acc -work work "$intercon_path/buffers/Queue.v"
vlog +acc -work work "$intercon_path/buffers/Resp_Queue.v"

# 3. Datapath components (Mux/Demux)
puts "Compiling datapath mux..."
vlog +acc -work work "$intercon_path/datapath/mux/Mux_2x1.v"
vlog +acc -work work "$intercon_path/datapath/mux/Mux_2x1_en.v"
vlog +acc -work work "$intercon_path/datapath/mux/Mux_4x1.v"
vlog +acc -work work "$intercon_path/datapath/mux/AW_MUX_2_1.v"
vlog +acc -work work "$intercon_path/datapath/mux/WD_MUX_2_1.v"
vlog +acc -work work "$intercon_path/datapath/mux/BReady_MUX_2_1.v"

puts "Compiling datapath demux..."
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1x2.v"
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1x2_en.v"
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1x4.v"
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1_2.v"

# 4. Arbiters
puts "Compiling arbiters..."
vlog +acc -work work "$intercon_path/arbitration/Qos_Arbiter.v"
vlog +acc -work work "$intercon_path/arbitration/Read_Arbiter.v"
vlog +acc -work work "$intercon_path/arbitration/Write_Arbiter.v"
vlog +acc -work work "$intercon_path/arbitration/Write_Arbiter_RR.v"

# 5. Decoders
puts "Compiling decoders..."
vlog +acc -work work "$intercon_path/decoders/Read_Addr_Channel_Dec.v"
vlog +acc -work work "$intercon_path/decoders/Write_Addr_Channel_Dec.v"
vlog +acc -work work "$intercon_path/decoders/Write_Resp_Channel_Dec.v"
vlog +acc -work work "$intercon_path/decoders/Write_Resp_Channel_Arb.v"

# 6. Handshake controllers
puts "Compiling handshake..."
vlog +acc -work work "$intercon_path/handshake/AW_HandShake_Checker.v"
vlog +acc -work work "$intercon_path/handshake/WD_HandShake.v"
vlog +acc -work work "$intercon_path/handshake/WR_HandShake.v"

# 7. Channel controllers
puts "Compiling channel controllers..."
vlog +acc -work work "$intercon_path/channel_controllers/read/Controller.v"
vlog +acc -work work "$intercon_path/channel_controllers/read/AR_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/write/AW_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/write/WD_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/write/BR_Channel_Controller_Top.v"

# 8. Core interconnect
puts "Compiling interconnect core..."
vlog +acc -work work "$intercon_path/core/AXI_Interconnect_Full.v"

puts ""
puts "=========================================="
puts "Compiling Master and Slave Components..."
puts "=========================================="

# Compile ALU Core and CPU components
puts "Compiling ALU Master..."
vlog +acc -work work "$master_path/ALU/ALU_Core.v"
vlog +acc -work work "$master_path/ALU/CPU_Controller.v"
vlog +acc -work work "$master_path/ALU/CPU_ALU_Master.v"

# Compile Slave Memory
puts "Compiling Slave Memory..."
vlog +acc -work work "$slave_path/Simple_Memory_Slave.v"

# Compile Top-level System
puts "Compiling Top-level System..."
vlog +acc -work work "$src_path/wrapper/alu_master_system.v"

# Compile Testbench
puts "Compiling Testbench..."
vlog +acc -work work "$tb_path/wrapper_tb/alu_master_system_tb.v"

puts ""
puts "=========================================="
puts "Starting Simulation..."
puts "=========================================="

# Load simulation
vsim -voptargs=+acc work.alu_master_system_tb

# Add waves for debugging (optional)
# add wave -radix hex sim:/alu_master_system_tb/*
# add wave -radix hex sim:/alu_master_system_tb/dut/u_master0/*
# add wave -radix hex sim:/alu_master_system_tb/dut/u_master1/*

# Run simulation
run -all

puts ""
puts "=========================================="
puts "Simulation Complete"
puts "=========================================="

# Quit
quit -f
