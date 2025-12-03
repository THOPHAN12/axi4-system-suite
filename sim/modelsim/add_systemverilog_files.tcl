#==============================================================================
# add_systemverilog_files.tcl
# Add only SystemVerilog (.sv) files to ModelSim project
# Usage: do add_systemverilog_files.tcl
#==============================================================================

puts "=========================================="
puts "Adding SystemVerilog Files (.sv) to Project"
puts "=========================================="

set SRC_BASE "../../src"
set TB_BASE "../../tb"

#==============================================================================
# 1. AXI Interconnect - SystemVerilog RTL
#==============================================================================
puts "\n\[1/3\] AXI Interconnect (SystemVerilog RTL)..."

set AXI_SV "${SRC_BASE}/axi_interconnect/SystemVerilog/rtl"

# Packages (compile FIRST - dependencies!)
project addfile ${AXI_SV}/packages/axi_pkg.sv

# Interfaces
project addfile ${AXI_SV}/interfaces/axi4_if.sv

# Utils
project addfile ${AXI_SV}/utils/Raising_Edge_Det.sv
project addfile ${AXI_SV}/utils/Faling_Edge_Detc.sv

# Buffers
project addfile ${AXI_SV}/buffers/Queue.sv
project addfile ${AXI_SV}/buffers/Resp_Queue.sv

# Datapath - MUX
project addfile ${AXI_SV}/datapath/mux/Mux_2x1.sv
project addfile ${AXI_SV}/datapath/mux/Mux_2x1_en.sv
project addfile ${AXI_SV}/datapath/mux/Mux_4x1.sv
project addfile ${AXI_SV}/datapath/mux/AW_MUX_2_1.sv
project addfile ${AXI_SV}/datapath/mux/WD_MUX_2_1.sv
project addfile ${AXI_SV}/datapath/mux/BReady_MUX_2_1.sv

# Datapath - DEMUX
project addfile ${AXI_SV}/datapath/demux/Demux_1_2.sv
project addfile ${AXI_SV}/datapath/demux/Demux_1x2.sv
project addfile ${AXI_SV}/datapath/demux/Demux_1x2_en.sv
project addfile ${AXI_SV}/datapath/demux/Demux_1x4.sv

# Decoders
project addfile ${AXI_SV}/decoders/Read_Addr_Channel_Dec.sv
project addfile ${AXI_SV}/decoders/Write_Addr_Channel_Dec.sv
project addfile ${AXI_SV}/decoders/Write_Resp_Channel_Dec.sv
project addfile ${AXI_SV}/decoders/Write_Resp_Channel_Arb.sv

# Handshake
project addfile ${AXI_SV}/handshake/AW_HandShake_Checker.sv
project addfile ${AXI_SV}/handshake/WD_HandShake.sv
project addfile ${AXI_SV}/handshake/WR_HandShake.sv

# Arbitration
project addfile ${AXI_SV}/arbitration/Write_Arbiter.sv
project addfile ${AXI_SV}/arbitration/Write_Arbiter_RR.sv
project addfile ${AXI_SV}/arbitration/Read_Arbiter.sv
project addfile ${AXI_SV}/arbitration/Qos_Arbiter.sv

# Channel Controllers
project addfile ${AXI_SV}/channel_controllers/write/AW_Channel_Controller_Top.sv
project addfile ${AXI_SV}/channel_controllers/write/WD_Channel_Controller_Top.sv
project addfile ${AXI_SV}/channel_controllers/write/BR_Channel_Controller_Top.sv
project addfile ${AXI_SV}/channel_controllers/read/Controller.sv

# Core
project addfile ${AXI_SV}/core/AXI_Interconnect.sv
project addfile ${AXI_SV}/core/AXI_Interconnect_Full.sv
project addfile ${AXI_SV}/core/AXI_Interconnect_2S_RDONLY.sv

# Main interconnect with configurable arbitration
project addfile ${AXI_SV}/arbitration/axi_rr_interconnect_2x4.sv

puts "  Added: 37 files"

#==============================================================================
# 2. SystemVerilog Testbenches
#==============================================================================
puts "\n\[2/3\] SystemVerilog Testbenches..."

set TB_SV "${TB_BASE}/interconnect_tb/SystemVerilog_tb"

# Main arbitration testbench
project addfile ${TB_BASE}/interconnect_tb/SystemVerilog/arb_test_systemverilog.sv

# Common interfaces and packages (compile FIRST!)
project addfile ${TB_SV}/common/axi_master_if.sv
project addfile ${TB_SV}/common/axi_slave_if.sv
project addfile ${TB_SV}/common/axi_tb_pkg.sv

project addfile ${TB_SV}/common/write_arb_if.sv
project addfile ${TB_SV}/common/write_arb_tb_pkg.sv

project addfile ${TB_SV}/common/queue_if.sv
project addfile ${TB_SV}/common/queue_tb_pkg.sv

project addfile ${TB_SV}/common/resp_queue_if.sv
project addfile ${TB_SV}/common/resp_queue_tb_pkg.sv

project addfile ${TB_SV}/common/aw_mux_if.sv
project addfile ${TB_SV}/common/aw_mux_tb_pkg.sv

project addfile ${TB_SV}/common/wd_mux_if.sv
project addfile ${TB_SV}/common/wd_mux_tb_pkg.sv

project addfile ${TB_SV}/common/bready_mux_if.sv
project addfile ${TB_SV}/common/bready_mux_tb_pkg.sv

project addfile ${TB_SV}/common/mux2_if.sv
project addfile ${TB_SV}/common/mux2_tb_pkg.sv

project addfile ${TB_SV}/common/mux2_en_if.sv
project addfile ${TB_SV}/common/mux2_en_tb_pkg.sv

project addfile ${TB_SV}/common/demux_if.sv
project addfile ${TB_SV}/common/demux_tb_pkg.sv

project addfile ${TB_SV}/common/demux_en_if.sv
project addfile ${TB_SV}/common/demux_en_tb_pkg.sv

project addfile ${TB_SV}/common/write_addr_dec_if.sv
project addfile ${TB_SV}/common/write_addr_dec_tb_pkg.sv

project addfile ${TB_SV}/common/write_resp_dec_if.sv
project addfile ${TB_SV}/common/write_resp_dec_tb_pkg.sv

project addfile ${TB_SV}/common/handshake_if.sv
project addfile ${TB_SV}/common/handshake_tb_pkg.sv

project addfile ${TB_SV}/common/wd_handshake_if.sv
project addfile ${TB_SV}/common/wd_handshake_tb_pkg.sv

project addfile ${TB_SV}/common/edge_det_if.sv
project addfile ${TB_SV}/common/edge_det_tb_pkg.sv

# Component testbenches
project addfile ${TB_SV}/arbitration/Write_Arbiter_tb.sv
project addfile ${TB_SV}/arbitration/Write_Arbiter_RR_tb.sv
project addfile ${TB_SV}/arbitration/Qos_Arbiter_tb.sv

project addfile ${TB_SV}/buffers/Queue_tb.sv
project addfile ${TB_SV}/buffers/Resp_Queue_tb.sv

project addfile ${TB_SV}/datapath/mux/AW_MUX_2_1_tb.sv
project addfile ${TB_SV}/datapath/mux/WD_MUX_2_1_tb.sv
project addfile ${TB_SV}/datapath/mux/BReady_MUX_2_1_tb.sv
project addfile ${TB_SV}/datapath/mux/Mux_2x1_tb.sv
project addfile ${TB_SV}/datapath/mux/Mux_2x1_en_tb.sv

project addfile ${TB_SV}/datapath/demux/Demux_1_2_tb.sv
project addfile ${TB_SV}/datapath/demux/Demux_1x2_tb.sv
project addfile ${TB_SV}/datapath/demux/Demux_1x2_en_tb.sv

project addfile ${TB_SV}/decoders/Write_Addr_Channel_Dec_tb.sv
project addfile ${TB_SV}/decoders/Write_Resp_Channel_Dec_tb.sv

project addfile ${TB_SV}/handshake/AW_HandShake_Checker_tb.sv
project addfile ${TB_SV}/handshake/WD_HandShake_tb.sv
project addfile ${TB_SV}/handshake/WR_HandShake_tb.sv

project addfile ${TB_SV}/utils/Raising_Edge_Det_tb.sv
project addfile ${TB_SV}/utils/Faling_Edge_Detc_tb.sv

project addfile ${TB_SV}/core/AXI_Interconnect_tb.sv

puts "  Added: ~80 files (interfaces + packages + testbenches)"

#==============================================================================
# 3. System Testbench (SystemVerilog)
#==============================================================================
puts "\n\[3/3\] System Testbench..."

project addfile ${TB_BASE}/wrapper_tb/testbenches/dual_riscv/dual_riscv_axi_system_tb.sv

puts "  Added: 1 file"

#==============================================================================
# Summary
#==============================================================================
puts "\n=========================================="
puts "Summary - SystemVerilog Files Only"
puts "=========================================="
puts "Interconnect RTL:   37 files"
puts "Testbenches:        ~80 files (OOP framework)"
puts "System TB:          1 file"
puts "----------------------------------------"
puts "TOTAL:              ~118 SystemVerilog files"
puts "=========================================="
puts ""
puts "✅ All SystemVerilog files added to project!"
puts ""
puts "⚠️  NOTE: SystemVerilog requires modern simulator"
puts "   (QuestaSim 2016+ or ModelSim 2016+)"
puts ""
puts "Next steps:"
puts "  1. Compile All: Right-click → Compile → Compile All"
puts "  2. Or use: do compile_systemverilog.tcl"
puts "=========================================="

