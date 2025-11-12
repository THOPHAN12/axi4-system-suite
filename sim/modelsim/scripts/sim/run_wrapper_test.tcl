# ============================================================================
# ModelSim Script để chạy testbench cho ALU Master System Wrapper
# Usage: vsim -c -do "source run_wrapper_test.tcl; quit -f"
# ============================================================================

# ============================================================================
# Cấu hình
# ============================================================================
set project_root "../.."
set src_path "$project_root/src"
set master_path "$project_root/Master_ALU"
set slave_path "$project_root/Slave_Memory"
set tb_path "$project_root/tb"
set intercon_path "$src_path/axi_interconnect/rtl"

# ============================================================================
# Clean up và tạo work library
# ============================================================================
puts "\n============================================================================"
puts "Cleaning up previous compilation..."
puts "============================================================================"
if {[file exists work]} {
    vdel -all
}
vlib work
vmap work work

# ============================================================================
# Compile theo thứ tự dependency
# ============================================================================
puts "\n============================================================================"
puts "Compiling Source Files..."
puts "============================================================================"

# 1. AXI Interconnect - Utils
puts "\n1. Compiling AXI Interconnect Utils..."
vlog +acc -work work "$intercon_path/utils/Raising_Edge_Det.v"
vlog +acc -work work "$intercon_path/utils/Faling_Edge_Detc.v"

# 2. AXI Interconnect - Handshake
puts "\n2. Compiling AXI Interconnect Handshake..."
vlog +acc -work work "$intercon_path/handshake/AW_HandShake_Checker.v"
vlog +acc -work work "$intercon_path/handshake/WD_HandShake.v"
vlog +acc -work work "$intercon_path/handshake/WR_HandShake.v"

# 3. AXI Interconnect - Datapath MUX
puts "\n3. Compiling AXI Interconnect Datapath MUX..."
vlog +acc -work work "$intercon_path/datapath/mux/Mux_2x1.v"
vlog +acc -work work "$intercon_path/datapath/mux/Mux_2x1_en.v"
vlog +acc -work work "$intercon_path/datapath/mux/Mux_4x1.v"
vlog +acc -work work "$intercon_path/datapath/mux/AW_MUX_2_1.v"
vlog +acc -work work "$intercon_path/datapath/mux/WD_MUX_2_1.v"
vlog +acc -work work "$intercon_path/datapath/mux/BReady_MUX_2_1.v"

# 4. AXI Interconnect - Datapath DEMUX
puts "\n4. Compiling AXI Interconnect Datapath DEMUX..."
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1x2.v"
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1x2_en.v"
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1x4.v"
vlog +acc -work work "$intercon_path/datapath/demux/Demux_1_2.v"

# 5. AXI Interconnect - Buffers
puts "\n5. Compiling AXI Interconnect Buffers..."
vlog +acc -work work "$intercon_path/buffers/Queue.v"
vlog +acc -work work "$intercon_path/buffers/Resp_Queue.v"

# 6. AXI Interconnect - Arbitration
puts "\n6. Compiling AXI Interconnect Arbitration..."
vlog +acc -work work "$intercon_path/arbitration/Qos_Arbiter.v"
vlog +acc -work work "$intercon_path/arbitration/Write_Arbiter.v"
vlog +acc -work work "$intercon_path/arbitration/Write_Arbiter_RR.v"
vlog +acc -work work "$intercon_path/arbitration/Read_Arbiter.v"

# 7. AXI Interconnect - Decoders
puts "\n7. Compiling AXI Interconnect Decoders..."
vlog +acc -work work "$intercon_path/decoders/Write_Addr_Channel_Dec.v"
vlog +acc -work work "$intercon_path/decoders/Write_Resp_Channel_Dec.v"
vlog +acc -work work "$intercon_path/decoders/Write_Resp_Channel_Arb.v"
vlog +acc -work work "$intercon_path/decoders/Read_Addr_Channel_Dec.v"

# 8. AXI Interconnect - Channel Controllers
puts "\n8. Compiling AXI Interconnect Channel Controllers..."
vlog +acc -work work "$intercon_path/channel_controllers/write/AW_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/write/WD_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/write/BR_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/read/AR_Channel_Controller_Top.v"
vlog +acc -work work "$intercon_path/channel_controllers/read/Controller.v"

# 9. AXI Interconnect - Core
puts "\n9. Compiling AXI Interconnect Core..."
vlog +acc -work work "$intercon_path/core/AXI_Interconnect.v"
vlog +acc -work work "$intercon_path/core/AXI_Interconnect_2S_RDONLY.v"
vlog +acc -work work "$intercon_path/core/AXI_Interconnect_Full.v"

# 10. Master ALU Components
puts "\n10. Compiling Master ALU Components..."
vlog +acc -work work "$master_path/ALU/ALU_Core.v"
vlog +acc -work work "$master_path/ALU/CPU_Controller.v"
vlog +acc -work work "$master_path/ALU/CPU_ALU_Master.v"
vlog +acc -work work "$master_path/ALU/Simple_AXI_Master_Test.v"

# 11. Slave Memory
puts "\n11. Compiling Slave Memory..."
vlog +acc -work work "$slave_path/Simple_Memory_Slave.v"

# 12. Wrapper - Top-level System
puts "\n12. Compiling Top-level System Wrapper..."
vlog +acc -work work "$src_path/wrapper/systems/alu_master_system.v"

# 13. Testbench
puts "\n13. Compiling Testbench..."
# Chọn testbench: alu_master_system_tb.v (cơ bản) hoặc alu_master_system_tb_enhanced.v (nâng cao)
set use_enhanced_tb 1
if {$use_enhanced_tb} {
    vlog +acc -work work "$tb_path/wrapper_tb/testbenches/alu_master/alu_master_system_tb_enhanced.v"
    set tb_module "alu_master_system_tb_enhanced"
} else {
    vlog +acc -work work "$tb_path/wrapper_tb/testbenches/alu_master/alu_master_system_tb.v"
    set tb_module "alu_master_system_tb"
}

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

# Add waves để debug (optional - uncomment nếu cần)
# add wave -radix hex sim:/$tb_module/*
# add wave -radix hex sim:/$tb_module/dut/*
# add wave -radix hex sim:/$tb_module/dut/u_master0/*
# add wave -radix hex sim:/$tb_module/dut/u_master1/*

# Enable waveform dump (testbench enhanced tự động dump VCD)
if {!$use_enhanced_tb} {
    vcd file alu_master_system_tb.vcd
    vcd add -r /$tb_module/*
}

# Run simulation với timeout
puts "\nRunning simulation (timeout: 200us)..."
run 200us

# Kiểm tra kết quả (chỉ cho basic testbench)
if {!$use_enhanced_tb} {
    if {[examine -radix decimal /$tb_module/master0_done] == 1 && \
        [examine -radix decimal /$tb_module/master1_done] == 1} {
        puts "\n============================================================================"
        puts "✓ TEST PASSED: Both masters completed successfully!"
        puts "============================================================================"
    } else {
        puts "\n============================================================================"
        puts "✗ TEST FAILED or TIMEOUT: Masters did not complete"
        puts "============================================================================"
        puts "master0_done = [examine /$tb_module/master0_done]"
        puts "master1_done = [examine /$tb_module/master1_done]"
    }
    
    # Close VCD
    vcd flush
    vcd close
    puts "\nWaveform saved to: alu_master_system_tb.vcd"
} else {
    puts "\nEnhanced testbench tự động kiểm tra và hiển thị kết quả"
    puts "Waveform saved to: alu_master_system_tb_enhanced.vcd"
}

puts "\n============================================================================"
puts "Simulation Complete"
puts "============================================================================"
puts "You can view waveform with: gtkwave alu_master_system_tb_enhanced.vcd"
puts "============================================================================"

# Quit
quit -f

