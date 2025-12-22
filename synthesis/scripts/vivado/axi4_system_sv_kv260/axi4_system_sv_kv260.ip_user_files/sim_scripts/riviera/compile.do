transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/xil_defaultlib

vmap xilinx_vip riviera/xilinx_vip
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xilinx_vip  -incr -l axi_vip_v1_1_19 -l zynq_ultra_ps_e_vip_v1_0_19 "+incdir+D:/Xilink/Vivado/2024.2/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"D:/Xilink/Vivado/2024.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xil_defaultlib  -incr -l axi_vip_v1_1_19 -l zynq_ultra_ps_e_vip_v1_0_19 "+incdir+../../../axi4_system_sv_kv260.gen/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../axi4_system_sv_kv260.gen/sources_1/bd/design_1/ipshared/6f8f/hdl" "+incdir+D:/Xilink/Vivado/2024.2/data/xilinx_vip/include" -l xilinx_vip -l xil_defaultlib \
"../../../../../../../SystemVerilog/axi_interconnect/channel_controllers/read/AR_Channel_Controller_Top.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/channel_controllers/write/AW_Channel_Controller_Top.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/handshake/AW_HandShake_Checker.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/mux/AW_MUX_2_1.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/core/AXI_Interconnect.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/core/AXI_Interconnect_Full.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/channel_controllers/write/BR_Channel_Controller_Top.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/mux/BReady_MUX_2_1.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/channel_controllers/read/Controller.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/demux/Demux_1_2.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/demux/Demux_1x4.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/utils/Faling_Edge_Detc.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/mux/Mux_2x1.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/mux/Mux_4x1.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/buffers/Queue.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/utils/Raising_Edge_Det.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/decoders/Read_Addr_Channel_Dec.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/channel_controllers/write/WD_Channel_Controller_Top.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/handshake/WD_HandShake.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/datapath/mux/WD_MUX_2_1.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/handshake/WR_HandShake.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/decoders/Write_Addr_Channel_Dec.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/decoders/Write_Resp_Channel_Arb.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/decoders/Write_Resp_Channel_Dec.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/arbitration/algorithms/arbiter_qos_based.sv" \
"../../../../../../../SystemVerilog/axi_masters/axi_master_0.sv" \
"../../../../../../../SystemVerilog/axi_masters/axi_master_1.sv" \
"../../../../../../../SystemVerilog/axi_interconnect/arbitration/algorithms/read_arbiter.sv" \
"../../../../../../../SystemVerilog/testbenches/axi_masters/comprehensive_system_tb.sv" \

vlog -work xil_defaultlib \
"glbl.v"

