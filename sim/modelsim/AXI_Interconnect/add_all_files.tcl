# ==============================================================================
# ModelSim TCL Script - Add All AXI Interconnect Related Files to Project
# ==============================================================================
# This script adds all files related to:
# - AXI Interconnect
# - AXI Bridge (3 RISC-V cores)
# - RISC-V Cores
# - Peripherals
# - System and Testbench
#
# NOTE: This script only ADDS files to project, does NOT compile them
# Compile manually after adding files
# ==============================================================================

# Set working directory
set PROJECT_DIR "D:/AXI"
set SRC_DIR "$PROJECT_DIR/src"
set VERIF_DIR "$PROJECT_DIR/verification"
set TB_DIR "$PROJECT_DIR/verification/testbenches"
set SIM_DIR "$PROJECT_DIR/sim/modelsim/AXI_Interconnect"

# ==============================================================================
# AXI Interconnect Files
# ==============================================================================
puts "Adding AXI Interconnect files to project..."

# Core files
project addfile "$SRC_DIR/axi_interconnect/rtl/core/AXI_Interconnect.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/core/AXI_Interconnect_Full.v"

# Channel Controllers - Write
project addfile "$SRC_DIR/axi_interconnect/rtl/channel_controllers/write/AW_Channel_Controller_Top.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/channel_controllers/write/WD_Channel_Controller_Top.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/channel_controllers/write/BR_Channel_Controller_Top.v"

# Channel Controllers - Read
project addfile "$SRC_DIR/axi_interconnect/rtl/channel_controllers/read/AR_Channel_Controller_Top.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/channel_controllers/read/Controller.v"

# Decoders
project addfile "$SRC_DIR/axi_interconnect/rtl/decoders/Write_Addr_Channel_Dec.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/decoders/Read_Addr_Channel_Dec.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/decoders/Write_Resp_Channel_Dec.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/decoders/Write_Resp_Channel_Arb.v"

# Mux modules
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/mux/Mux_2x1.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/mux/Mux_2x1_en.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/mux/Mux_4x1.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/mux/AW_MUX_2_1.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/mux/WD_MUX_2_1.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/mux/BReady_MUX_2_1.v"

# Demux modules
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1x2.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1x2_en.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1x4.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/datapath/demux/Demux_1_2.v"

# Handshake modules
project addfile "$SRC_DIR/axi_interconnect/rtl/handshake/AW_HandShake_Checker.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/handshake/WD_HandShake.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/handshake/WR_HandShake.v"

# Buffers
project addfile "$SRC_DIR/axi_interconnect/rtl/buffers/Queue.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/buffers/Resp_Queue.v"

# Arbitration algorithms
project addfile "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/arbiter_round_robin.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/arbiter_fixed_priority.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/arbiter_qos_based.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/arbitration/algorithms/read_arbiter.v"

# Utils
project addfile "$SRC_DIR/axi_interconnect/rtl/utils/Raising_Edge_Det.v"
project addfile "$SRC_DIR/axi_interconnect/rtl/utils/Faling_Edge_Detc.v"

# ==============================================================================
# RISC-V Core Files (5-stage Pipeline)
# ==============================================================================
puts "Adding RISC-V 5-stage Pipeline core files to project..."

# Datapath modules
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX2v2.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX2.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/PCv1.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/ADD_PC.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/EXTENDv1.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX41.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/ALU.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/ADD.v"

# Pipeline registers
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/IF_ID.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/ID_EX.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/EX_ME.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/pipeline/ME_WB.v"

# Control modules
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/control/CONTROL_PIPELINE.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/control/HAZARD_UNIT.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/control/CONTROL.v"

# Memory modules
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/IMEM.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/DMEM.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/REGISTERFILE.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/registerfile_test.v"

# Core modules
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/core/RV32I_PIPELINE.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/core/RV32I.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/core/RV32I_test.v"

# Additional datapath files
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/PC.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/MUX2v1.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/datapath/EXTEND.v"

# Additional memory files
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/rtl/memory/WRAPPER_DMEM.v"

# Testbench files
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/tb/RV32I_PIPELINE_tb.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/tb/REGISTERFILE_tb.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/tb/IMEM_tb.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/tb/HAZARD_UNIT_tb.v"
project addfile "$SRC_DIR/cores/riscv-5stage-pipeline/tb/DMEM_tb.v"

# ==============================================================================
# SERV Core Files
# ==============================================================================
puts "Adding SERV core files to project..."

project addfile "$SRC_DIR/cores/serv/rtl/serv_top.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_state.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_rf_top.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_rf_ram_if.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_rf_ram.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_rf_if.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_mem_if.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_immdec.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_decode.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_debug.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_ctrl.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_csr.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_compdec.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_bufreg2.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_bufreg.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_alu.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_aligner.v"
project addfile "$SRC_DIR/cores/serv/rtl/serv_synth_wrapper.v"

# SERV Servant files (all platform variants)
project addfile "$SRC_DIR/cores/serv/servant/servant.v"
# Note: servant_arbiter.v does not exist in the repository
# project addfile "$SRC_DIR/cores/serv/servant/servant_arbiter.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_mux.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ram.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_timer.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_gpio.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ac701.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_cmod_a7.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_cmod_a7_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ax309.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ax309_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ecp5.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ecp5_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ecp5_evn.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_ecp5_evn_clock_gen.v"
# Note: ecp5_evn_pll.v uses ECP5 primitives, not needed for simulation
# project addfile "$SRC_DIR/cores/serv/servant/ecp5_evn_pll.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_gmm7550.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_lx9.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_lx9_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_md_kolibri.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_orangecrab.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_pf.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_pf_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_te0802.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_te0802_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servant_upduino2.v"
project addfile "$SRC_DIR/cores/serv/servant/servclone10.v"
project addfile "$SRC_DIR/cores/serv/servant/servclone10_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/service.v"
project addfile "$SRC_DIR/cores/serv/servant/service_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/service_go_board.v"
project addfile "$SRC_DIR/cores/serv/servant/servis.v"
project addfile "$SRC_DIR/cores/serv/servant/servis_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servive.v"
project addfile "$SRC_DIR/cores/serv/servant/servive_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servix.v"
project addfile "$SRC_DIR/cores/serv/servant/servix_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servix_ebaz4205.v"
project addfile "$SRC_DIR/cores/serv/servant/servix_ebaz4205_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servus.v"
project addfile "$SRC_DIR/cores/serv/servant/servus_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servax.v"
project addfile "$SRC_DIR/cores/serv/servant/servax_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/servde1_soc_revF.v"
project addfile "$SRC_DIR/cores/serv/servant/servde1_soc_revF_clock_gen.v"
project addfile "$SRC_DIR/cores/serv/servant/ecppll.v"
project addfile "$SRC_DIR/cores/serv/servant/ice40_pll.v"

# SERV Servile files
project addfile "$SRC_DIR/cores/serv/servile/servile.v"
project addfile "$SRC_DIR/cores/serv/servile/servile_arbiter.v"
project addfile "$SRC_DIR/cores/serv/servile/servile_mux.v"
project addfile "$SRC_DIR/cores/serv/servile/servile_rf_mem_if.v"

# SERV Serving files
project addfile "$SRC_DIR/cores/serv/serving/serving.v"
project addfile "$SRC_DIR/cores/serv/serving/serving_ram.v"

# SERV Testbench files
project addfile "$SRC_DIR/cores/serv/bench/serv_core_tb.v"
project addfile "$SRC_DIR/cores/serv/bench/servant_sim.v"
project addfile "$SRC_DIR/cores/serv/bench/servant_tb.v"
project addfile "$SRC_DIR/cores/serv/bench/uart_decoder.v"

# ==============================================================================
# F-RISCV Core Files (SystemVerilog)
# ==============================================================================
puts "Adding F-RISCV core files to project..."

project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_rv32i_core.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_rv32i_platform.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_pipeline.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_processing.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_control.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_decoder.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_alu.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_csr.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_registers.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_icache.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_dcache.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_mem_router.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_ram.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_rambe.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_axi_or_tracker.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_m_ext.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_div.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_clint.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_mpu.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_pmp_region.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_io_subsystem.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_uart.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_gpios.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_memfy.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_blocks.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_block_fetcher.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_flusher.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_io_fetcher.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_memctrl.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_ooo_mgt.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_prefetcher.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_cache_pusher.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_apb_interconnect.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_bus_perf.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_checkers.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_pulser.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_stats.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_bit_sync.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_scfifo.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_h.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_control_h.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_debug_h.sv"
project addfile "$SRC_DIR/cores/friscv/friscv/rtl/friscv_memfy_h.sv"

# ==============================================================================
# AXI Bridge Files
# ==============================================================================
puts "Adding AXI Bridge files to project..."

project addfile "$SRC_DIR/axi_bridge/riscv_pipeline_axi_wrapper.v"
project addfile "$SRC_DIR/axi_bridge/serv_axi_wrapper.v"
project addfile "$SRC_DIR/axi_bridge/friscv_axi_wrapper.v"

# ==============================================================================
# Peripheral Files
# ==============================================================================
puts "Adding Peripheral files to project..."

project addfile "$SRC_DIR/peripherals/axi_lite/axi_lite_ram.v"
project addfile "$SRC_DIR/peripherals/axi_lite/axi_lite_gpio.v"
project addfile "$SRC_DIR/peripherals/axi_lite/axi_lite_uart.v"
project addfile "$SRC_DIR/peripherals/axi_lite/axi_lite_spi.v"

# ==============================================================================
# System Files
# ==============================================================================
puts "Adding System files to project..."

# Dual systems
project addfile "$SRC_DIR/systems/dual_axi_shell.v"
project addfile "$SRC_DIR/systems/dual_pipeline_serv_axi_system_aggregators.v"
project addfile "$SRC_DIR/systems/dual_pipeline_serv_axi_system.v"

# ==============================================================================
# Testbench Files
# ==============================================================================
puts "Adding Testbench files to project..."

# System Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/system/dual_pipeline_serv_axi_system_tb.v"

# AXI Interconnect Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/core/AXI_Interconnect_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/core/test_case1.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/core/test_case2.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/core/test_case3.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/core/test_case4.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/core/test_case5.v"

# Channel Controller Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/channel_controllers/write/AW_Channel_Controller_Top_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/channel_controllers/write/WD_Channel_Controller_Top_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/channel_controllers/write/BR_Channel_Controller_Top_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/channel_controllers/read/Controller_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/channel_controllers/read/Controller_minimal_tb.v"

# Arbitration Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/arbitration/arbiter_round_robin_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/arbitration/arbiter_fixed_priority_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/arbitration/arbiter_qos_based_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/arbitration/read_arbiter_tb.v"

# Decoder Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/decoders/Write_Addr_Channel_Dec_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/decoders/Write_Resp_Channel_Dec_tb.v"

# Mux/Demux Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/mux/Mux_2x1_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/mux/Mux_2x1_en_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/mux/Mux_4x1_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/mux/AW_MUX_2_1_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/mux/WD_MUX_2_1_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/mux/BReady_MUX_2_1_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/demux/Demux_1x2_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/demux/Demux_1x2_en_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/demux/Demux_1x4_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/datapath/demux/Demux_1_2_tb.v"

# Handshake Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/handshake/AW_HandShake_Checker_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/handshake/WD_HandShake_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/handshake/WR_HandShake_tb.v"

# Buffer Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/buffers/Queue_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/buffers/Resp_Queue_tb.v"

# Utils Testbenches
project addfile "$VERIF_DIR/testbenches/interconnect_tb/utils/Raising_Edge_Det_tb.v"
project addfile "$VERIF_DIR/testbenches/interconnect_tb/utils/Faling_Edge_Detc_tb.v"

# Bridge Testbenches
project addfile "$VERIF_DIR/testbenches/bridge_tb/wb_to_axilite_bridge_tb.v"

# ==============================================================================
# Summary
# ==============================================================================
puts "\n=========================================="
puts "Files Added to Project"
puts "=========================================="
puts "✓ AXI Interconnect: 32 files"
puts "✓ RISC-V 5-stage Pipeline: 26 RTL + 5 TB = 31 files"
puts "✓ SERV Core: 18 RTL + 46 Servant + 4 Servile + 2 Serving + 4 TB = 74 files"
puts "✓ F-RISCV Core: 43 SystemVerilog files"
puts "✓ AXI Bridge: 4 files"
puts "✓ Peripherals: 4 files"
puts "✓ System: 3 files (dual shell + dual aggregators + dual pipeline+serv)"
puts "✓ Testbenches: 31 files (System + Interconnect + Components)"
puts "=========================================="
puts "Total: ~221 files added to project"
puts "=========================================="
puts "\nYou can now compile files manually in ModelSim"
puts "Use 'Compile -> Compile All' or compile individual files"
puts "Note: F-RISCV files are SystemVerilog (.sv) - may need special handling"
puts "==========================================\n"

# End of script
