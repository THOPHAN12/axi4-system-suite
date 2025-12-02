#=============================================================================
# test_all_modes.tcl
# Test all 3 arbitration modes and report results
#=============================================================================

puts "\n=============================================="
puts "AXI Interconnect Arbitration Mode Test Suite"
puts "=============================================="

# Clean up
catch {vdel -all}
vlib work

# Compile sources
puts "\n[1/4] Compiling RTL..."
vlog -sv D:/AXI/src/axi_interconnect/SystemVerilog/rtl/arbitration/axi_rr_interconnect_2x4.sv
vlog -sv D:/AXI/tb/interconnect_tb/quick_arb_test.sv

# Test FIXED mode
puts "\n[2/4] Testing FIXED priority mode..."
vsim -c -g MODE="FIXED" work.quick_arb_test -do "run -all; quit"  > test_fixed.log

# Test ROUND_ROBIN mode
puts "\n[3/4] Testing ROUND_ROBIN mode..."
vsim -c -g MODE="ROUND_ROBIN" work.quick_arb_test -do "run -all; quit" > test_rr.log

# Test QOS mode  
puts "\n[4/4] Testing QOS mode..."
vsim -c -g MODE="QOS" work.quick_arb_test -do "run -all; quit" > test_qos.log

puts "\n=============================================="
puts "Test Results Summary"
puts "=============================================="

# Show results
puts "\n--- FIXED Mode ---"
set fp [open "test_fixed.log" r]
while {[gets $fp line] >= 0} {
    if {[string match "*RESULTS*" $line] || [string match "*granted*" $line] || [string match "*PASS*" $line] || [string match "*FAIL*" $line]} {
        puts $line
    }
}
close $fp

puts "\n--- ROUND_ROBIN Mode ---"
set fp [open "test_rr.log" r]
while {[gets $fp line] >= 0} {
    if {[string match "*RESULTS*" $line] || [string match "*granted*" $line] || [string match "*PASS*" $line] || [string match "*FAIL*" $line] || [string match "*Check*" $line]} {
        puts $line
    }
}
close $fp

puts "\n--- QOS Mode ---"
set fp [open "test_qos.log" r]
while {[gets $fp line] >= 0} {
    if {[string match "*RESULTS*" $line] || [string match "*granted*" $line] || [string match "*PASS*" $line] || [string match "*FAIL*" $line]} {
        puts $line
    }
}
close $fp

puts "\n=============================================="
puts "All tests completed!"
puts "Full logs: test_fixed.log, test_rr.log, test_qos.log"
puts "==============================================\n"

quit

