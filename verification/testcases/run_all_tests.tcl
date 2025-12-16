# TCL script to compile and run all testcases

# Set working directory
set work_dir [pwd]
cd verification/testcases

# Create work library
vlib work
vmap work work

# Compile AXI Interconnect
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

# Compile slave models
vlog -work work slave_models.v

# Compile and run each testcase
set testcases [list testcase1_m0_ram testcase2_m1_ram testcase3_m0_uart testcase4_m1_spi testcase5_m0_gpio]

foreach testcase $testcases {
    puts "\n========================================"
    puts "Compiling $testcase"
    puts "========================================"
    vlog -work work ${testcase}.v
    
    puts "\n========================================"
    puts "Running $testcase"
    puts "========================================"
    vsim -c work.${testcase} -do "run -all; quit -f"
}

puts "\n========================================"
puts "All tests completed!"
puts "========================================"

cd $work_dir

