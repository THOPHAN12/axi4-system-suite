# TCL script to compile and run testcase 1

# Set working directory
set work_dir [pwd]
cd verification/testcases

# Create work library
vlib work
vmap work work

# Compile AXI Interconnect files
puts "Compiling AXI Interconnect..."
vlog -work work ../../src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/core/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/decoders/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/datapath/mux/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/datapath/demux/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/channel_controllers/read/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/channel_controllers/write/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/arbitration/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/buffers/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/handshake/*.v
vlog -work work ../../src/axi_interconnect/Verilog/rtl/utils/*.v

# Compile testcase
puts "Compiling testcase1_m0_ram..."
vlog -work work testcase1_m0_ram.v

# Run simulation
puts "Running testcase1_m0_ram..."
vsim -c work.testcase1_m0_ram -do "run -all; quit -f"

cd $work_dir

