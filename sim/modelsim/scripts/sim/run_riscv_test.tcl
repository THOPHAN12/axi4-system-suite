# ============================================================================
# TCL Script to Compile and Run SERV RISC-V System Testbench
# Usage: vsim -c -do "source run_riscv_test.tcl; quit -f"
# 
# Note: This script does both compile and simulation.
# For separate steps, use:
#   - compile_riscv.tcl (compile only)
#   - run_riscv_sim.tcl (simulation only)
#   - compile_and_run_riscv.tcl (compile then simulate)
# ============================================================================

# ============================================================================
# Cấu hình
# ============================================================================
# Get script directory and calculate root
# Use absolute path to avoid issues with current working directory
set script_file [info script]
if {[string equal $script_file ""]} {
    # If script is sourced directly, use current directory
    set script_dir [pwd]
} else {
    set script_dir [file dirname [file normalize $script_file]]
}

# Calculate project root (go up 2 levels from sim/modelsim to AXI root)
set project_root [file normalize [file join $script_dir .. ..]]

# Verify project root exists
if {![file exists $project_root]} {
    puts "ERROR: Project root not found: $project_root"
    puts "Script directory: $script_dir"
    quit -code 1
}

set src_path [file join $project_root "src"]
set tb_path [file join $project_root "tb"]
set intercon_path [file join $src_path "axi_interconnect" "rtl"]
set serv_path [file join $src_path "cores" "serv" "rtl"]
set wrapper_path [file join $src_path "wrapper"]

# Debug: Print paths
puts "Script file: $script_file"
puts "Script directory: $script_dir"
puts "Project root: $project_root"
puts "Source path: $src_path"
puts "Interconnect path: $intercon_path"
puts "SERV path: $serv_path"
puts "Wrapper path: $wrapper_path"

# Verify key directories exist
if {![file exists $src_path]} {
    puts "ERROR: Source path not found: $src_path"
    quit -code 1
}
if {![file exists $intercon_path]} {
    puts "ERROR: Interconnect path not found: $intercon_path"
    quit -code 1
}
if {![file exists $serv_path]} {
    puts "ERROR: SERV path not found: $serv_path"
    quit -code 1
}

puts ""

# ============================================================================
# Clean up và tạo work library
# ============================================================================
puts "\n============================================================================"
puts "Cleaning up previous compilation..."
puts "============================================================================"
# Try to clean up, but don't fail if it doesn't work
catch {vdel -all}
if {![file exists work]} {
    vlib work
    vmap work work
}

# ============================================================================
# Compile theo thứ tự dependency
# ============================================================================
puts "\n============================================================================"
puts "Compiling Source Files..."
puts "============================================================================"

# 1. AXI Interconnect - Utils
puts "\n1. Compiling AXI Interconnect Utils..."
set utils_path [file join $intercon_path "utils"]
vlog +acc -work work [file join $utils_path "Raising_Edge_Det.v"]
vlog +acc -work work [file join $utils_path "Faling_Edge_Detc.v"]

# 2. AXI Interconnect - Handshake
puts "\n2. Compiling AXI Interconnect Handshake..."
set handshake_path [file join $intercon_path "handshake"]
vlog +acc -work work [file join $handshake_path "AW_HandShake_Checker.v"]
vlog +acc -work work [file join $handshake_path "WD_HandShake.v"]
vlog +acc -work work [file join $handshake_path "WR_HandShake.v"]

# 3. AXI Interconnect - Datapath MUX
puts "\n3. Compiling AXI Interconnect Datapath MUX..."
set mux_path [file join $intercon_path "datapath" "mux"]
vlog +acc -work work [file join $mux_path "Mux_2x1.v"]
vlog +acc -work work [file join $mux_path "Mux_2x1_en.v"]
vlog +acc -work work [file join $mux_path "Mux_4x1.v"]
vlog +acc -work work [file join $mux_path "AW_MUX_2_1.v"]
vlog +acc -work work [file join $mux_path "WD_MUX_2_1.v"]
vlog +acc -work work [file join $mux_path "BReady_MUX_2_1.v"]

# 4. AXI Interconnect - Datapath DEMUX
puts "\n4. Compiling AXI Interconnect Datapath DEMUX..."
set demux_path [file join $intercon_path "datapath" "demux"]
vlog +acc -work work [file join $demux_path "Demux_1x2.v"]
vlog +acc -work work [file join $demux_path "Demux_1x2_en.v"]
vlog +acc -work work [file join $demux_path "Demux_1x4.v"]
vlog +acc -work work [file join $demux_path "Demux_1_2.v"]

# 5. AXI Interconnect - Buffers
puts "\n5. Compiling AXI Interconnect Buffers..."
set buffers_path [file join $intercon_path "buffers"]
vlog +acc -work work [file join $buffers_path "Queue.v"]
vlog +acc -work work [file join $buffers_path "Resp_Queue.v"]

# 6. AXI Interconnect - Arbitration
puts "\n6. Compiling AXI Interconnect Arbitration..."
set arb_path [file join $intercon_path "arbitration"]
vlog +acc -work work [file join $arb_path "Qos_Arbiter.v"]
vlog +acc -work work [file join $arb_path "Write_Arbiter.v"]
vlog +acc -work work [file join $arb_path "Write_Arbiter_RR.v"]
vlog +acc -work work [file join $arb_path "Read_Arbiter.v"]

# 7. AXI Interconnect - Decoders
puts "\n7. Compiling AXI Interconnect Decoders..."
set decoders_path [file join $intercon_path "decoders"]
vlog +acc -work work [file join $decoders_path "Write_Addr_Channel_Dec.v"]
vlog +acc -work work [file join $decoders_path "Write_Resp_Channel_Dec.v"]
vlog +acc -work work [file join $decoders_path "Write_Resp_Channel_Arb.v"]
vlog +acc -work work [file join $decoders_path "Read_Addr_Channel_Dec.v"]

# 8. AXI Interconnect - Channel Controllers
puts "\n8. Compiling AXI Interconnect Channel Controllers..."
set write_ctrl_path [file join $intercon_path "channel_controllers" "write"]
set read_ctrl_path [file join $intercon_path "channel_controllers" "read"]
vlog +acc -work work [file join $write_ctrl_path "AW_Channel_Controller_Top.v"]
vlog +acc -work work [file join $write_ctrl_path "WD_Channel_Controller_Top.v"]
vlog +acc -work work [file join $write_ctrl_path "BR_Channel_Controller_Top.v"]
vlog +acc -work work [file join $read_ctrl_path "AR_Channel_Controller_Top.v"]
vlog +acc -work work [file join $read_ctrl_path "Controller.v"]

# 9. AXI Interconnect - Core
puts "\n9. Compiling AXI Interconnect Core..."
set core_path [file join $intercon_path "core"]
vlog +acc -work work [file join $core_path "AXI_Interconnect.v"]
vlog +acc -work work [file join $core_path "AXI_Interconnect_2S_RDONLY.v"]
vlog +acc -work work [file join $core_path "AXI_Interconnect_Full.v"]

# 10. SERV RISC-V Core
puts "\n10. Compiling SERV RISC-V Core..."
vlog +acc -work work [file join $serv_path "serv_state.v"]
vlog +acc -work work [file join $serv_path "serv_immdec.v"]
vlog +acc -work work [file join $serv_path "serv_compdec.v"]
vlog +acc -work work [file join $serv_path "serv_decode.v"]
vlog +acc -work work [file join $serv_path "serv_alu.v"]
vlog +acc -work work [file join $serv_path "serv_ctrl.v"]
vlog +acc -work work [file join $serv_path "serv_csr.v"]
vlog +acc -work work [file join $serv_path "serv_bufreg.v"]
vlog +acc -work work [file join $serv_path "serv_bufreg2.v"]
vlog +acc -work work [file join $serv_path "serv_aligner.v"]
vlog +acc -work work [file join $serv_path "serv_mem_if.v"]
vlog +acc -work work [file join $serv_path "serv_rf_if.v"]
vlog +acc -work work [file join $serv_path "serv_rf_ram_if.v"]
vlog +acc -work work [file join $serv_path "serv_rf_ram.v"]
vlog +acc -work work [file join $serv_path "serv_rf_top.v"]
vlog +acc -work work [file join $serv_path "serv_top.v"]

# 11. Wishbone to AXI Converters
puts "\n11. Compiling Wishbone to AXI Converters..."
vlog +acc -work work [file join $wrapper_path "converters" "wb2axi_read.v"]
vlog +acc -work work [file join $wrapper_path "converters" "wb2axi_write.v"]

# 12. SERV AXI Wrapper
puts "\n12. Compiling SERV AXI Wrapper..."
vlog +acc -work work [file join $wrapper_path "converters" "serv_axi_wrapper.v"]

# 13. SERV AXI System
puts "\n13. Compiling SERV AXI System..."
vlog +acc -work work [file join $wrapper_path "systems" "serv_axi_system.v"]

# 14. Memory Slaves
puts "\n14. Compiling Memory Slaves..."
vlog +acc -work work [file join $wrapper_path "memory" "axi_rom_slave.v"]
vlog +acc -work work [file join $wrapper_path "memory" "axi_memory_slave.v"]

# 15. Testbench
puts "\n15. Compiling Testbench..."
vlog +acc -work work [file join $tb_path "wrapper_tb" "testbenches" "serv" "serv_axi_system_tb.v"]
set tb_module "serv_axi_system_tb"

# ============================================================================
# Kiểm tra compilation errors
# ============================================================================
if {[catch {vsim -voptargs=+acc work.$tb_module} err]} {
    puts "\n============================================================================"
    puts "ERROR: Compilation failed!"
    puts "============================================================================"
    puts $err
    quit -code 1
}

# ============================================================================
# Chạy simulation
# ============================================================================
puts "\n============================================================================"
puts "Starting Simulation..."
puts "============================================================================"

# Load simulation
vsim -voptargs=+acc work.$tb_module

# Run simulation với timeout
puts "\nRunning simulation (timeout: 50us)..."
run 50us

puts "\n============================================================================"
puts "Simulation Complete"
puts "============================================================================"
puts "You can view waveform with: gtkwave serv_axi_system_tb.vcd"
puts "============================================================================"

# Quit
quit -f

