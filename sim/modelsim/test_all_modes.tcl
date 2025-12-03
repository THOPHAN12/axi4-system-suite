#==============================================================================
# test_all_modes.tcl
# Test all 3 arbitration modes with statistics
#==============================================================================

puts "=========================================="
puts "Testing All 3 Arbitration Modes"
puts "=========================================="

# Test FIXED mode
puts "\n\[MODE 1/3\] FIXED Priority..."
puts "=========================================="
vsim -quiet -c -g ARBIT_MODE=0 work.arb_test_verilog
run -all
quit -sim

# Test ROUND_ROBIN mode
puts "\n\[MODE 2/3\] ROUND_ROBIN..."
puts "=========================================="
vsim -quiet -c -g ARBIT_MODE=1 work.arb_test_verilog
run -all
quit -sim

# Test QOS mode
puts "\n\[MODE 3/3\] QOS Priority..."
puts "=========================================="
vsim -quiet -c -g ARBIT_MODE=2 work.arb_test_verilog
run -all
quit -sim

puts "\n=========================================="
puts "All 3 modes tested!"
puts "=========================================="
quit -f

