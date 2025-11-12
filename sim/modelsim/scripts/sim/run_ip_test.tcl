# ============================================================================
# TCL Script to compile and run serv_axi_system_ip testbench
# ============================================================================

# Clean work directory
if {[file exists work]} {
    vdel -all -lib work
}
vlib work
vmap work work

puts "\n============================================================================"
puts "Compiling SERV RISC-V System IP Testbench"
puts "============================================================================\n"

# Paths
# Get script directory and calculate root
set script_dir [file dirname [file normalize [info script]]]
set root_dir [file normalize [file join $script_dir .. ..]]
set src_path [file join $root_dir "src"]
set tb_path [file join $root_dir "tb"]

# Debug: Print paths
puts "Script directory: $script_dir"
puts "Root directory: $root_dir"
puts "Source path: $src_path"

# 1. SERV RISC-V Core
puts "1. Compiling SERV RISC-V Core..."
set serv_rtl [file join $src_path "cores" "serv" "rtl"]
puts "SERV RTL path: $serv_rtl"

# Check if file exists before compiling
set serv_state_file [file join $serv_rtl "serv_state.v"]
if {![file exists $serv_state_file]} {
    puts "ERROR: File not found: $serv_state_file"
    quit -code 1
}

vlog +acc -work work $serv_state_file
vlog +acc -work work [file join $serv_rtl "serv_immdec.v"]
vlog +acc -work work [file join $serv_rtl "serv_compdec.v"]
vlog +acc -work work [file join $serv_rtl "serv_decode.v"]
vlog +acc -work work [file join $serv_rtl "serv_alu.v"]
vlog +acc -work work [file join $serv_rtl "serv_ctrl.v"]
vlog +acc -work work [file join $serv_rtl "serv_csr.v"]
vlog +acc -work work [file join $serv_rtl "serv_bufreg.v"]
vlog +acc -work work [file join $serv_rtl "serv_bufreg2.v"]
vlog +acc -work work [file join $serv_rtl "serv_aligner.v"]
vlog +acc -work work [file join $serv_rtl "serv_mem_if.v"]
vlog +acc -work work [file join $serv_rtl "serv_rf_if.v"]
vlog +acc -work work [file join $serv_rtl "serv_rf_ram_if.v"]
vlog +acc -work work [file join $serv_rtl "serv_rf_ram.v"]
vlog +acc -work work [file join $serv_rtl "serv_rf_top.v"]
vlog +acc -work work [file join $serv_rtl "serv_top.v"]

# 2. Wishbone to AXI Converters
puts "\n2. Compiling Wishbone to AXI Converters..."
vlog +acc -work work [file join $src_path "wrapper" "wb2axi_read.v"]
vlog +acc -work work [file join $src_path "wrapper" "wb2axi_write.v"]

# 3. SERV AXI Wrapper
puts "\n3. Compiling SERV AXI Wrapper..."
vlog +acc -work work [file join $src_path "wrapper" "serv_axi_wrapper.v"]

# 4. AXI Interconnect (compile all components)
puts "\n4. Compiling AXI Interconnect..."
set intercon_path [file join $src_path "axi_interconnect" "rtl"]

# 4.1 Utils
vlog +acc -work work [file join $intercon_path "utils" "Raising_Edge_Det.v"]
vlog +acc -work work [file join $intercon_path "utils" "Faling_Edge_Detc.v"]

# 4.2 Handshake
vlog +acc -work work [file join $intercon_path "handshake" "AW_HandShake_Checker.v"]
vlog +acc -work work [file join $intercon_path "handshake" "WD_HandShake.v"]
vlog +acc -work work [file join $intercon_path "handshake" "WR_HandShake.v"]

# 4.3 Datapath MUX
vlog +acc -work work [file join $intercon_path "datapath" "mux" "Mux_2x1.v"]
vlog +acc -work work [file join $intercon_path "datapath" "mux" "Mux_2x1_en.v"]
vlog +acc -work work [file join $intercon_path "datapath" "mux" "Mux_4x1.v"]
vlog +acc -work work [file join $intercon_path "datapath" "mux" "AW_MUX_2_1.v"]
vlog +acc -work work [file join $intercon_path "datapath" "mux" "WD_MUX_2_1.v"]
vlog +acc -work work [file join $intercon_path "datapath" "mux" "BReady_MUX_2_1.v"]

# 4.4 Datapath DEMUX
vlog +acc -work work [file join $intercon_path "datapath" "demux" "Demux_1x2.v"]
vlog +acc -work work [file join $intercon_path "datapath" "demux" "Demux_1x2_en.v"]
vlog +acc -work work [file join $intercon_path "datapath" "demux" "Demux_1x4.v"]
vlog +acc -work work [file join $intercon_path "datapath" "demux" "Demux_1_2.v"]

# 4.5 Buffers
vlog +acc -work work [file join $intercon_path "buffers" "Queue.v"]
vlog +acc -work work [file join $intercon_path "buffers" "Resp_Queue.v"]

# 4.6 Arbitration
vlog +acc -work work [file join $intercon_path "arbitration" "Qos_Arbiter.v"]
vlog +acc -work work [file join $intercon_path "arbitration" "Write_Arbiter.v"]
vlog +acc -work work [file join $intercon_path "arbitration" "Write_Arbiter_RR.v"]
vlog +acc -work work [file join $intercon_path "arbitration" "Read_Arbiter.v"]

# 4.7 Decoders
vlog +acc -work work [file join $intercon_path "decoders" "Write_Addr_Channel_Dec.v"]
vlog +acc -work work [file join $intercon_path "decoders" "Write_Resp_Channel_Dec.v"]
vlog +acc -work work [file join $intercon_path "decoders" "Write_Resp_Channel_Arb.v"]
vlog +acc -work work [file join $intercon_path "decoders" "Read_Addr_Channel_Dec.v"]

# 4.8 Write Channel Controllers
vlog +acc -work work [file join $intercon_path "channel_controllers" "write" "AW_Channel_Controller_Top.v"]
vlog +acc -work work [file join $intercon_path "channel_controllers" "write" "WD_Channel_Controller_Top.v"]
vlog +acc -work work [file join $intercon_path "channel_controllers" "write" "BR_Channel_Controller_Top.v"]

# 4.9 Read Channel Controllers
vlog +acc -work work [file join $intercon_path "channel_controllers" "read" "Controller.v"]
vlog +acc -work work [file join $intercon_path "channel_controllers" "read" "AR_Channel_Controller_Top.v"]

# 4.10 Core Modules
vlog +acc -work work [file join $intercon_path "core" "AXI_Interconnect.v"]
vlog +acc -work work [file join $intercon_path "core" "AXI_Interconnect_Full.v"]

# 5. Memory Slaves
puts "\n5. Compiling Memory Slaves..."
vlog +acc -work work [file join $src_path "wrapper" "memory" "axi_rom_slave.v"]
vlog +acc -work work [file join $src_path "wrapper" "memory" "axi_memory_slave.v"]

# 6. Complete IP Module
puts "\n6. Compiling Complete IP Module..."
vlog +acc -work work [file join $src_path "wrapper" "ip" "serv_axi_system_ip.v"]

# 7. Testbench
puts "\n7. Compiling Testbench..."
vlog +acc -work work [file join $tb_path "wrapper_tb" "testbenches" "serv" "serv_axi_system_ip_tb.v"]

# Check for compilation errors
if {[catch {vsim -voptargs=+acc work.serv_axi_system_ip_tb} err]} {
    puts "\n============================================================================"
    puts "ERROR: Compilation failed!"
    puts "============================================================================"
    puts $err
    quit -code 1
}

# Load simulation
vsim -voptargs=+acc work.serv_axi_system_ip_tb

# Run simulation
puts "\n============================================================================"
puts "Running simulation (timeout: 100us)..."
puts "============================================================================"
run 100us

puts "\n============================================================================"
puts "Simulation completed!"
puts "============================================================================"
quit -f

