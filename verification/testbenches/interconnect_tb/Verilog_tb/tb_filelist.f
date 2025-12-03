# ModelSim Filelist for AXI Interconnect Testbenches
# Usage: vlog -f tb_filelist.f

# ============================================
# Includes
# ============================================
+incdir+../../src/axi_interconnect/Verilog/rtl/includes
+incdir+../../src/common/rtl/utils

# ============================================
# Source Files (compile first)
# ============================================

# Utils (compile first - no dependencies)
../../src/axi_interconnect/Verilog/rtl/utils/Raising_Edge_Det.v
../../src/axi_interconnect/Verilog/rtl/utils/Faling_Edge_Detc.v

# Handshake (depends on utils)
../../src/axi_interconnect/Verilog/rtl/handshake/AW_HandShake_Checker.v
../../src/axi_interconnect/Verilog/rtl/handshake/WD_HandShake.v
../../src/axi_interconnect/Verilog/rtl/handshake/WR_HandShake.v

# Datapath - MUX
../../src/axi_interconnect/Verilog/rtl/datapath/mux/AW_MUX_2_1.v
../../src/axi_interconnect/Verilog/rtl/datapath/mux/WD_MUX_2_1.v
../../src/axi_interconnect/Verilog/rtl/datapath/mux/Mux_2x1.v
../../src/axi_interconnect/Verilog/rtl/datapath/mux/Mux_2x1_en.v
../../src/axi_interconnect/Verilog/rtl/datapath/mux/BReady_MUX_2_1.v

# Datapath - DEMUX
../../src/axi_interconnect/Verilog/rtl/datapath/demux/Demux_1_2.v
../../src/axi_interconnect/Verilog/rtl/datapath/demux/Demux_1x2.v
../../src/axi_interconnect/Verilog/rtl/datapath/demux/Demux_1x2_en.v

# Buffers
../../src/axi_interconnect/Verilog/rtl/buffers/Queue.v
../../src/axi_interconnect/Verilog/rtl/buffers/Resp_Queue.v

# Arbitration
../../src/axi_interconnect/Verilog/rtl/arbitration/Qos_Arbiter.v
../../src/axi_interconnect/Verilog/rtl/arbitration/Write_Arbiter.v
../../src/axi_interconnect/Verilog/rtl/arbitration/Write_Arbiter_RR.v

# Decoders
../../src/axi_interconnect/Verilog/rtl/decoders/Write_Addr_Channel_Dec.v
../../src/axi_interconnect/Verilog/rtl/decoders/Write_Resp_Channel_Dec.v
../../src/axi_interconnect/Verilog/rtl/decoders/Write_Resp_Channel_Arb.v

# Channel Controllers
../../src/axi_interconnect/Verilog/rtl/channel_controllers/write/AW_Channel_Controller_Top.v
../../src/axi_interconnect/Verilog/rtl/channel_controllers/write/WD_Channel_Controller_Top.v
../../src/axi_interconnect/Verilog/rtl/channel_controllers/write/BR_Channel_Controller_Top.v
../../src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v

# Core
../../src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect.v
../../src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v

# ============================================
# Testbenches - Utils (compile first)
# ============================================
utils/Faling_Edge_Detc_tb.v
utils/Raising_Edge_Det_tb.v

# ============================================
# Testbenches - Handshake
# ============================================
handshake/AW_HandShake_Checker_tb.v
handshake/WD_HandShake_tb.v
handshake/WR_HandShake_tb.v

# ============================================
# Testbenches - Datapath MUX
# ============================================
datapath/mux/AW_MUX_2_1_tb.v
datapath/mux/WD_MUX_2_1_tb.v
datapath/mux/Mux_2x1_tb.v
datapath/mux/Mux_2x1_en_tb.v
datapath/mux/BReady_MUX_2_1_tb.v

# ============================================
# Testbenches - Datapath DEMUX
# ============================================
datapath/demux/Demux_1_2_tb.v
datapath/demux/Demux_1x2_tb.v
datapath/demux/Demux_1x2_en_tb.v

# ============================================
# Testbenches - Buffers
# ============================================
buffers/Queue_tb.v
buffers/Resp_Queue_tb.v

# ============================================
# Testbenches - Arbitration
# ============================================
arbitration/Qos_Arbiter_tb.v
arbitration/Write_Arbiter_tb.v
arbitration/Write_Arbiter_RR_tb.v

# ============================================
# Testbenches - Decoders
# ============================================
decoders/Write_Addr_Channel_Dec_tb.v
decoders/Write_Resp_Channel_Dec_tb.v

# ============================================
# Testbenches - Channel Controllers
# ============================================
channel_controllers/write/AW_Channel_Controller_Top_tb.v
channel_controllers/write/WD_Channel_Controller_Top_tb.v
channel_controllers/write/BR_Channel_Controller_Top_tb.v
channel_controllers/read/Controller_tb.v

# ============================================
# Testbenches - Core (Top Level)
# ============================================
core/AXI_Interconnect_tb.v
core/test_case1.v
core/test_case2.v
core/test_case3.v
core/test_case4.v
core/test_case5.v

