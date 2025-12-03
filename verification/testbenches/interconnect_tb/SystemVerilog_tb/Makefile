###############################################################################
# Makefile - Icarus Verilog Simulation Flow for AXI Interconnect
#
# Requirements:
#   - Icarus Verilog (iverilog/vvp) in PATH
#
# Usage:
#   make compile     # Compile design + testbench
#   make run         # Compile + run simulation
#   make test_edge   # Run edge detector testbench
#   make test_all    # Run all testbenches
#   make clean       # Remove generated files
#   make wave        # Open waveform viewer (gtkwave)
###############################################################################

IVERILOG = iverilog
VVP = vvp
IVFLAGS = -g2012
GTKWAVE = gtkwave

# Source directories
RTL_DIR = ../../../src/axi_interconnect/SystemVerilog/rtl
COMMON_DIR = ../../../src/common/rtl

# Include directories
INCDIRS = -I$(RTL_DIR)/packages -I$(RTL_DIR)/interfaces -I$(COMMON_DIR)/utils

# RTL Source files
RTL_UTILS = \
	$(RTL_DIR)/utils/Raising_Edge_Det.sv \
	$(RTL_DIR)/utils/Faling_Edge_Detc.sv

RTL_HANDSHAKE = \
	$(RTL_DIR)/handshake/AW_HandShake_Checker.sv \
	$(RTL_DIR)/handshake/WD_HandShake.sv \
	$(RTL_DIR)/handshake/WR_HandShake.sv

RTL_MUX = \
	$(RTL_DIR)/datapath/mux/AW_MUX_2_1.sv \
	$(RTL_DIR)/datapath/mux/WD_MUX_2_1.sv \
	$(RTL_DIR)/datapath/mux/Mux_2x1.sv \
	$(RTL_DIR)/datapath/mux/Mux_2x1_en.sv \
	$(RTL_DIR)/datapath/mux/Mux_4x1.sv \
	$(RTL_DIR)/datapath/mux/BReady_MUX_2_1.sv

RTL_DEMUX = \
	$(RTL_DIR)/datapath/demux/Demux_1_2.sv \
	$(RTL_DIR)/datapath/demux/Demux_1x2.sv \
	$(RTL_DIR)/datapath/demux/Demux_1x2_en.sv \
	$(RTL_DIR)/datapath/demux/Demux_1x4.sv

RTL_BUFFERS = \
	$(RTL_DIR)/buffers/Queue.sv \
	$(RTL_DIR)/buffers/Resp_Queue.sv

RTL_ARBITRATION = \
	$(RTL_DIR)/arbitration/Qos_Arbiter.sv \
	$(RTL_DIR)/arbitration/Write_Arbiter.sv \
	$(RTL_DIR)/arbitration/Write_Arbiter_RR.sv \
	$(RTL_DIR)/arbitration/Read_Arbiter.sv

RTL_DECODERS = \
	$(RTL_DIR)/decoders/Write_Addr_Channel_Dec.sv \
	$(RTL_DIR)/decoders/Write_Resp_Channel_Dec.sv \
	$(RTL_DIR)/decoders/Write_Resp_Channel_Arb.sv \
	$(RTL_DIR)/decoders/Read_Addr_Channel_Dec.sv

RTL_CONTROLLERS = \
	$(RTL_DIR)/channel_controllers/write/AW_Channel_Controller_Top.sv \
	$(RTL_DIR)/channel_controllers/write/WD_Channel_Controller_Top.sv \
	$(RTL_DIR)/channel_controllers/write/BR_Channel_Controller_Top.sv \
	$(RTL_DIR)/channel_controllers/read/Controller.sv \
	$(RTL_DIR)/channel_controllers/read/AR_Channel_Controller_Top.sv

RTL_CORE = \
	$(RTL_DIR)/core/AXI_Interconnect.sv \
	$(RTL_DIR)/core/AXI_Interconnect_Full.sv

# All RTL sources
RTL_ALL = $(RTL_UTILS) $(RTL_HANDSHAKE) $(RTL_MUX) $(RTL_DEMUX) \
          $(RTL_BUFFERS) $(RTL_ARBITRATION) $(RTL_DECODERS) \
          $(RTL_CONTROLLERS) $(RTL_CORE)

# Testbenches
TB_EDGE_DET = utils/Raising_Edge_Det_tb.sv
TB_AXI_INTERCONNECT = core/AXI_Interconnect_tb.sv

# Output files
OUT_EDGE_DET = test_edge_det.vvp
OUT_AXI_INTERCONNECT = axi_interconnect.vvp

.PHONY: all compile run test_edge test_interconnect test_all clean wave help

all: run

help:
	@echo "Available targets:"
	@echo "  make compile         - Compile AXI Interconnect testbench"
	@echo "  make run             - Compile and run AXI Interconnect simulation"
	@echo "  make test_edge       - Run edge detector testbench"
	@echo "  make test_interconnect - Run AXI Interconnect testbench"
	@echo "  make test_all        - Run all testbenches"
	@echo "  make clean           - Remove generated files"
	@echo "  make wave            - Open waveform viewer"

# Compile AXI Interconnect
compile: $(OUT_AXI_INTERCONNECT)

$(OUT_AXI_INTERCONNECT): $(RTL_ALL) $(TB_AXI_INTERCONNECT)
	$(IVERILOG) $(IVFLAGS) $(INCDIRS) $(RTL_ALL) $(TB_AXI_INTERCONNECT) -o $@

# Run AXI Interconnect simulation
run: $(OUT_AXI_INTERCONNECT)
	$(VVP) $<

# Edge detector test
$(OUT_EDGE_DET): $(RTL_UTILS) $(TB_EDGE_DET)
	$(IVERILOG) $(IVFLAGS) $(INCDIRS) $(RTL_UTILS) $(TB_EDGE_DET) -o $@

test_edge: $(OUT_EDGE_DET)
	$(VVP) $<

# AXI Interconnect test
test_interconnect: run

# Run all tests
test_all: test_edge test_interconnect
	@echo ""
	@echo "========================================"
	@echo "All tests completed!"
	@echo "========================================"

# Open waveform viewer
wave:
	@if [ -f *.vcd ]; then \
		$(GTKWAVE) $$(ls -t *.vcd | head -1); \
	else \
		echo "No VCD file found. Run simulation first."; \
	fi

# Clean generated files
clean:
	rm -f *.vvp *.vcd transcript
	rm -f utils/*.vcd core/*.vcd
	@echo "Cleaned generated files"


