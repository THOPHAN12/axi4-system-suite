#==============================================================================
# test_arb.tcl
# Simple test script for arbitration
# Usage: vsim -do test_arb.tcl
#==============================================================================

puts "=========================================="
puts "AXI Interconnect Arbitration Test"
puts "=========================================="

# Clean and create library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compile RTL
puts "\nCompiling RTL..."
vlog -work work ../../src/axi_interconnect/Verilog/rtl/core/axi_lite_interconnect_2x4.v

# Compile testbench
puts "Compiling testbench..."
vlog -work work ../../verification/testbenches/interconnect_tb/Verilog_tb/arbitration/Write_Arbiter_RR_tb.v

puts "\n=========================================="
puts "Running Tests"
puts "=========================================="

# Test 1: FIXED mode
puts "\n\[TEST 1/3\] FIXED Priority..."
vsim -quiet -c -g ARBIT_MODE=0 work.arb_test_verilog
run -all
quit -sim

# Test 2: ROUND_ROBIN mode
puts "\n\[TEST 2/3\] ROUND_ROBIN..."
vsim -quiet -c -g ARBIT_MODE=1 work.arb_test_verilog
run -all
quit -sim

# Test 3: QOS mode
puts "\n\[TEST 3/3\] QOS..."
vsim -quiet -c -g ARBIT_MODE=2 work.arb_test_verilog
run -all
quit -sim

puts "\n=========================================="
puts "All tests completed!"
puts "=========================================="
quit -f

