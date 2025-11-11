# ModelSim Filelist for AXI Project
# Usage: vlog -f filelist.f

# ============================================
# Includes and Defines
# ============================================
+incdir+../src/axi_interconnect/rtl/includes
+incdir+../src/axi_stream/rtl/includes
+incdir+../src/common/rtl/utils
+incdir+../src/axi_full/rtl/includes

# ============================================
# Common Utilities (compile first)
# ============================================
../src/common/rtl/utils/constants.vh
../src/common/rtl/utils/type_definitions.svh

# ============================================
# AXI Interconnect - Utils (compile first)
# ============================================
../src/axi_interconnect/rtl/utils/Raising_Edge_Det.v
../src/axi_interconnect/rtl/utils/Faling_Edge_Detc.v

# ============================================
# AXI Interconnect - Handshake
# ============================================
../src/axi_interconnect/rtl/handshake/AW_HandShake_Checker.v
../src/axi_interconnect/rtl/handshake/WD_HandShake.v
../src/axi_interconnect/rtl/handshake/WR_HandShake.v

# ============================================
# AXI Interconnect - Datapath (MUX/DEMUX)
# ============================================
# MUX modules
../src/axi_interconnect/rtl/datapath/mux/AW_MUX_2_1.v
../src/axi_interconnect/rtl/datapath/mux/WD_MUX_2_1.v
../src/axi_interconnect/rtl/datapath/mux/Mux_2x1.v
../src/axi_interconnect/rtl/datapath/mux/Mux_2x1_en.v
../src/axi_interconnect/rtl/datapath/mux/Mux_4x1.v
../src/axi_interconnect/rtl/datapath/mux/BReady_MUX_2_1.v

# DEMUX modules
../src/axi_interconnect/rtl/datapath/demux/Demux_1_2.v
../src/axi_interconnect/rtl/datapath/demux/Demux_1x2.v
../src/axi_interconnect/rtl/datapath/demux/Demux_1x2_en.v
../src/axi_interconnect/rtl/datapath/demux/Demux_1x4.v

# ============================================
# AXI Interconnect - Buffers
# ============================================
../src/axi_interconnect/rtl/buffers/Queue.v
../src/axi_interconnect/rtl/buffers/Resp_Queue.v

# ============================================
# AXI Interconnect - Arbitration
# ============================================
../src/axi_interconnect/rtl/arbitration/Qos_Arbiter.v
../src/axi_interconnect/rtl/arbitration/Write_Arbiter.v
../src/axi_interconnect/rtl/arbitration/Write_Arbiter_RR.v
../src/axi_interconnect/rtl/arbitration/Read_Arbiter.v

# ============================================
# AXI Interconnect - Decoders
# ============================================
../src/axi_interconnect/rtl/decoders/Write_Addr_Channel_Dec.v
../src/axi_interconnect/rtl/decoders/Write_Resp_Channel_Dec.v
../src/axi_interconnect/rtl/decoders/Write_Resp_Channel_Arb.v
../src/axi_interconnect/rtl/decoders/Read_Addr_Channel_Dec.v

# ============================================
# AXI Interconnect - Channel Controllers
# ============================================
# Write channels
../src/axi_interconnect/rtl/channel_controllers/write/AW_Channel_Controller_Top.v
../src/axi_interconnect/rtl/channel_controllers/write/WD_Channel_Controller_Top.v
../src/axi_interconnect/rtl/channel_controllers/write/BR_Channel_Controller_Top.v

# Read channels
../src/axi_interconnect/rtl/channel_controllers/read/Controller.v
../src/axi_interconnect/rtl/channel_controllers/read/AR_Channel_Controller_Top.v

# ============================================
# AXI Interconnect - Core (Top Level)
# ============================================
../src/axi_interconnect/rtl/core/AXI_Interconnect.v
../src/axi_interconnect/rtl/core/AXI_Interconnect_Full.v
../src/axi_interconnect/rtl/core/AXI_Interconnect_2S_RDONLY.v

# ============================================
# AXI Stream - Interfaces (SystemVerilog)
# ============================================
../src/axi_stream/rtl/interfaces/axis_stream_if.sv

# ============================================
# AXI Stream - Components
# ============================================
../src/axi_stream/rtl/register/axis_register.sv
../src/axi_stream/rtl/fifo/axis_fifo.sv
../src/axi_stream/rtl/mux/axis_arb_mux.sv
../src/axi_stream/rtl/demux/axis_demux.sv
../src/axi_stream/rtl/adapter/axis_adapter.sv

# ============================================
# AXI Bridge (if implemented)
# ============================================
# ../src/axi_bridge/rtl/axi4_to_stream/axi4_to_stream_write.v
# ../src/axi_bridge/rtl/stream_to_axi4/stream_to_axi4_read.v

# ============================================
# AXI Full System (if implemented)
# ============================================
# ../src/axi_full/rtl/AXI_Full_System.v

# ============================================
# Testbenches
# ============================================
# Interconnect Testbenches
../tb/interconnect_tb/core/AXI_Interconnect_tb.v
../tb/interconnect_tb/channel_controllers/read/Controller_tb.v
../tb/interconnect_tb/Qos_Arbiter_tb.v
../tb/interconnect_tb/Write_Arbiter_tb.v
../tb/interconnect_tb/Write_Arbiter_RR_tb.v
../tb/interconnect_tb/test_case1.v
../tb/interconnect_tb/test_case2.v
../tb/interconnect_tb/test_case3.v
../tb/interconnect_tb/test_case4.v
../tb/interconnect_tb/test_case5.v

# Stream Testbenches (SystemVerilog)
../tb/stream_tb/axis_register_tb.sv
../tb/stream_tb/axis_fifo_tb.sv
../tb/stream_tb/axis_arb_mux_tb.sv

# Utils Testbenches
../tb/utils_tb/Mux_2x1_tb.v
../tb/utils_tb/Mux_2x1_en_tb.v
../tb/utils_tb/Demux_1_2_tb.v
../tb/utils_tb/Demux_1x2_tb.v
../tb/utils_tb/Demux_1x2_en_tb.v
../tb/utils_tb/BReady_MUX_2_1_tb.v
../tb/utils_tb/Faling_Edge_Detc_tb.v
../tb/utils_tb/Raising_Edge_Det_tb.v
../tb/utils_tb/utils_tb_all.v

