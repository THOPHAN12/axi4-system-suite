# ModelSim Filelist for AXI Interconnect Testbenches
# Usage: vlog -f tb_filelist.f

# ============================================
# Includes
# ============================================
+incdir+../../../src/axi_interconnect/SystemVerilog/rtl/packages
+incdir+../../../src/axi_interconnect/SystemVerilog/rtl/interfaces
+incdir+../../../src/common/rtl/utils

# ============================================
# Source Files (compile first)
# ============================================

# Packages & interfaces
../../../src/axi_interconnect/SystemVerilog/rtl/packages/axi_pkg.sv
../../../src/axi_interconnect/SystemVerilog/rtl/interfaces/axi4_if.sv
common/axi_master_if.sv
common/axi_slave_if.sv
common/axi_tb_pkg.sv
common/read_controller_if.sv
common/read_controller_tb_pkg.sv
common/write_controller_if.sv
common/write_controller_tb_pkg.sv
common/write_data_ctrl_if.sv
common/write_data_ctrl_tb_pkg.sv
common/write_resp_ctrl_if.sv
common/write_resp_ctrl_tb_pkg.sv
common/write_resp_dec_if.sv
common/write_resp_dec_tb_pkg.sv
common/write_addr_dec_if.sv
common/write_addr_dec_tb_pkg.sv
common/resp_queue_if.sv
common/resp_queue_tb_pkg.sv
common/aw_mux_if.sv
common/aw_mux_tb_pkg.sv
common/wd_mux_if.sv
common/wd_mux_tb_pkg.sv
common/mux2_if.sv
common/mux2_tb_pkg.sv
common/mux2_en_if.sv
common/mux2_en_tb_pkg.sv
common/bready_mux_if.sv
common/bready_mux_tb_pkg.sv
common/demux_if.sv
common/demux_tb_pkg.sv
common/demux_en_if.sv
common/demux_en_tb_pkg.sv
common/handshake_if.sv
common/handshake_tb_pkg.sv
common/wd_handshake_if.sv
common/wd_handshake_tb_pkg.sv
common/edge_det_if.sv
common/edge_det_tb_pkg.sv
common/write_arb_if.sv
common/write_arb_tb_pkg.sv
common/queue_if.sv
common/queue_tb_pkg.sv

# Utils (compile first - no dependencies)
../../../src/axi_interconnect/SystemVerilog/rtl/utils/Raising_Edge_Det.sv
../../../src/axi_interconnect/SystemVerilog/rtl/utils/Faling_Edge_Detc.sv

# Handshake (depends on utils)
../../../src/axi_interconnect/SystemVerilog/rtl/handshake/AW_HandShake_Checker.sv
../../../src/axi_interconnect/SystemVerilog/rtl/handshake/WD_HandShake.sv
../../../src/axi_interconnect/SystemVerilog/rtl/handshake/WR_HandShake.sv

# Datapath - MUX
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/mux/AW_MUX_2_1.sv
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/mux/WD_MUX_2_1.sv
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/mux/Mux_2x1.sv
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/mux/Mux_2x1_en.sv
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/mux/BReady_MUX_2_1.sv

# Datapath - DEMUX
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/demux/Demux_1_2.sv
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/demux/Demux_1x2.sv
../../../src/axi_interconnect/SystemVerilog/rtl/datapath/demux/Demux_1x2_en.sv

# Buffers
../../../src/axi_interconnect/SystemVerilog/rtl/buffers/Queue.sv
../../../src/axi_interconnect/SystemVerilog/rtl/buffers/Resp_Queue.sv

# Arbitration
../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/Qos_Arbiter.sv
../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/Write_Arbiter.sv
../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/Write_Arbiter_RR.sv

# Decoders
../../../src/axi_interconnect/SystemVerilog/rtl/decoders/Write_Addr_Channel_Dec.sv
../../../src/axi_interconnect/SystemVerilog/rtl/decoders/Write_Resp_Channel_Dec.sv
../../../src/axi_interconnect/SystemVerilog/rtl/decoders/Write_Resp_Channel_Arb.sv

# Channel Controllers
../../../src/axi_interconnect/SystemVerilog/rtl/channel_controllers/write/AW_Channel_Controller_Top.sv
../../../src/axi_interconnect/SystemVerilog/rtl/channel_controllers/write/WD_Channel_Controller_Top.sv
../../../src/axi_interconnect/SystemVerilog/rtl/channel_controllers/write/BR_Channel_Controller_Top.sv
../../../src/axi_interconnect/SystemVerilog/rtl/channel_controllers/read/Controller.sv

# Core
../../../src/axi_interconnect/SystemVerilog/rtl/core/AXI_Interconnect.sv
../../../src/axi_interconnect/SystemVerilog/rtl/core/AXI_Interconnect_Full.sv

# ============================================
# Testbenches - Utils (compile first)
# ============================================
utils/Faling_Edge_Detc_tb.sv
utils/Raising_Edge_Det_tb.sv

# ============================================
# Testbenches - Handshake
# ============================================
handshake/AW_HandShake_Checker_tb.sv
handshake/WD_HandShake_tb.sv
handshake/WR_HandShake_tb.sv

# ============================================
# Testbenches - Datapath MUX
# ============================================
datapath/mux/AW_MUX_2_1_tb.sv
datapath/mux/WD_MUX_2_1_tb.sv
datapath/mux/Mux_2x1_tb.sv
datapath/mux/Mux_2x1_en_tb.sv
datapath/mux/BReady_MUX_2_1_tb.sv

# ============================================
# Testbenches - Datapath DEMUX
# ============================================
datapath/demux/Demux_1_2_tb.sv
datapath/demux/Demux_1x2_tb.sv
datapath/demux/Demux_1x2_en_tb.sv

# ============================================
# Testbenches - Buffers
# ============================================
buffers/Queue_tb.sv
buffers/Resp_Queue_tb.sv

# ============================================
# Testbenches - Arbitration
# ============================================
arbitration/Qos_Arbiter_tb.sv
arbitration/Write_Arbiter_tb.sv
arbitration/Write_Arbiter_RR_tb.sv

# ============================================
# Testbenches - Decoders
# ============================================
decoders/Write_Addr_Channel_Dec_tb.sv
decoders/Write_Resp_Channel_Dec_tb.sv

# ============================================
# Testbenches - Channel Controllers
# ============================================
channel_controllers/write/AW_Channel_Controller_Top_tb.sv
channel_controllers/write/WD_Channel_Controller_Top_tb.sv
channel_controllers/write/BR_Channel_Controller_Top_tb.sv
channel_controllers/read/Controller_tb.sv

# ============================================
# Testbenches - Core (Top Level)
# ============================================
core/test_case1.sv
core/test_case2.sv
core/test_case3.sv
core/test_case4.sv
core/test_case5.sv
core/AXI_Interconnect_tb.sv

