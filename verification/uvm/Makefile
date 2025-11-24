###############################################################################
# Makefile - UVM Simulation Flow for AXI Interconnect SystemVerilog
#
# Requirements:
#   - Mentor Questa/ModelSim (vlog/vsim) or compatible simulator in PATH
#   - UVM installation (set UVM_HOME if not using built-in version)
#
# Usage:
#   make compile   # Compile design + UVM testbench
#   make run       # Compile + run default test (axi_interconnect_simple_test)
#   make test TEST=axi_interconnect_base_test
#   make clean     # Remove work library and generated files
###############################################################################

SIM            ?= questa
VLOG           ?= vlog
VSIM           ?= vsim
LIB            ?= work

# Try to find UVM in common locations
UVM_HOME       ?= $(shell if exist "C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d" (echo C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d) else (if exist "C:\modeltech_*\verilog_src\uvm-1.1d" (echo C:\modeltech_*\verilog_src\uvm-1.1d) else ()))
UVM_DPI        ?=

# Include directories (relative to verification/uvm)
INCDIRS = \
	+incdir+agents \
	+incdir+config \
	+incdir+coverage \
	+incdir+env \
	+incdir+scoreboard \
	+incdir+sequences \
	+incdir+test \
	+incdir+tb

# Source files (top-level tb includes the rest via `include`)
TB_TOP = tb/axi_interconnect_tb.sv

# Design source directories
DESIGN_SV = \
	../../src/axi_interconnect/sv/packages/axi_pkg.sv \
	../../src/axi_interconnect/sv/interfaces/axi4_if.sv \
	../../src/axi_interconnect/sv/core/AXI_Interconnect_Full.sv \
	../../src/axi_interconnect/sv/core/AXI_Interconnect.sv \
	../../src/axi_interconnect/sv/core/AXI_Interconnect_2S_RDONLY.sv \
	../../src/axi_interconnect/sv/channel_controllers/read/AR_Channel_Controller_Top.sv \
	../../src/axi_interconnect/sv/channel_controllers/read/Controller.sv \
	../../src/axi_interconnect/sv/channel_controllers/write/AW_Channel_Controller_Top.sv \
	../../src/axi_interconnect/sv/channel_controllers/write/BR_Channel_Controller_Top.sv \
	../../src/axi_interconnect/sv/channel_controllers/write/WD_Channel_Controller_Top.sv \
	../../src/axi_interconnect/sv/arbitration/Read_Arbiter.sv \
	../../src/axi_interconnect/sv/arbitration/Write_Arbiter.sv \
	../../src/axi_interconnect/sv/arbitration/Write_Arbiter_RR.sv \
	../../src/axi_interconnect/sv/arbitration/Qos_Arbiter.sv \
	../../src/axi_interconnect/sv/datapath/mux/Mux_2x1.sv \
	../../src/axi_interconnect/sv/datapath/mux/Mux_2x1_en.sv \
	../../src/axi_interconnect/sv/datapath/mux/Mux_4x1.sv \
	../../src/axi_interconnect/sv/datapath/mux/AW_MUX_2_1.sv \
	../../src/axi_interconnect/sv/datapath/mux/WD_MUX_2_1.sv \
	../../src/axi_interconnect/sv/datapath/mux/BReady_MUX_2_1.sv \
	../../src/axi_interconnect/sv/datapath/demux/Demux_1x2.sv \
	../../src/axi_interconnect/sv/datapath/demux/Demux_1x2_en.sv \
	../../src/axi_interconnect/sv/datapath/demux/Demux_1x4.sv \
	../../src/axi_interconnect/sv/datapath/demux/Demux_1_2.sv \
	../../src/axi_interconnect/sv/buffers/Queue.sv \
	../../src/axi_interconnect/sv/buffers/Resp_Queue.sv \
	../../src/axi_interconnect/sv/handshake/AW_HandShake_Checker.sv \
	../../src/axi_interconnect/sv/handshake/WD_HandShake.sv \
	../../src/axi_interconnect/sv/handshake/WR_HandShake.sv \
	../../src/axi_interconnect/sv/decoders/Read_Addr_Channel_Dec.sv \
	../../src/axi_interconnect/sv/decoders/Write_Addr_Channel_Dec.sv \
	../../src/axi_interconnect/sv/decoders/Write_Resp_Channel_Dec.sv \
	../../src/axi_interconnect/sv/decoders/Write_Resp_Channel_Arb.sv \
	../../src/axi_interconnect/sv/utils/Raising_Edge_Det.sv \
	../../src/axi_interconnect/sv/utils/Faling_Edge_Detc.sv \
	../../src/wrapper/sv/systems/axi_interconnect_2m4s_wrapper.sv

UVM_DEFINES = +define+UVM_NO_DEPRECATED
UVM_FLAGS   = +UVM_TESTNAME=$(TEST)

VLOG_FLAGS = -sv -timescale 1ns/1ps $(INCDIRS) $(UVM_DEFINES)
VSIM_FLAGS = -c -sv_seed random +UVM_VERBOSITY=UVM_MEDIUM $(UVM_FLAGS) \
	-do "run -all; quit"

ifeq ($(SIM),questa)
	ifneq ($(UVM_HOME),)
		VLOG_FLAGS += +incdir+$(UVM_HOME)/src
		VSIM_FLAGS += -L $(UVM_HOME)/lib/uvm_dpi
	endif
endif

TEST ?= axi_interconnect_simple_test

.PHONY: all compile run test clean

all: run

$(LIB):
	vlib $(LIB)

compile: $(LIB)
	$(VLOG) $(VLOG_FLAGS) $(DESIGN_SV) $(TB_TOP)

run: compile
	$(VSIM) $(VSIM_FLAGS) $(LIB).axi_interconnect_simple_tb

test:
	$(MAKE) run TEST=$(TEST)

clean:
	@if exist $(LIB) rmdir /S /Q $(LIB)
	@if exist transcript del /Q transcript
	@if exist vsim.wlf del /Q vsim.wlf
	@if exist vlog.log del /Q vlog.log
	@if exist vsim.log del /Q vsim.log

