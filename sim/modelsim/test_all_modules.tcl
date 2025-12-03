# File: test_all_modules.tcl
# Test all individual modules systematically

puts "=========================================="
puts "COMPREHENSIVE MODULE TEST"
puts "=========================================="

set total 0
set passed 0  
set failed 0
set failed_list ""

# Test procedure
proc test_module {name timeout level} {
    global total passed failed failed_list
    incr total
    
    puts "\n\[$level\] Testing: $name"
    puts "  Timeout: $timeout"
    
    if {[catch {
        vsim -c work.$name -do "run $timeout; quit -f"
        incr passed
        puts "  Result: PASS"
        return 1
    } err]} {
        incr failed
        append failed_list "  - $name ($level)\n"
        puts "  Result: FAIL - $err"
        return 0
    }
}

# LEVEL 1: Basic Utils
puts "\n========== LEVEL 1: BASIC UTILS =========="
test_module Raising_Edge_Det_tb "500ns" "L1"
test_module Faling_Edge_Detc_tb "500ns" "L1"
test_module Mux_2x1_tb "500ns" "L1"
test_module Demux_1x2_tb "500ns" "L1"
test_module Mux_2x1_en_tb "500ns" "L1"
test_module Demux_1x2_en_tb "500ns" "L1"
test_module BReady_MUX_2_1_tb "500ns" "L1"
test_module Demux_1_2_tb "500ns" "L1"

# LEVEL 2: Buffers
puts "\n========== LEVEL 2: BUFFERS =========="
test_module Queue_tb "1us" "L2"
test_module Resp_Queue_tb "1us" "L2"

# LEVEL 3: Arbitration
puts "\n========== LEVEL 3: ARBITRATION =========="
test_module Write_Arbiter_tb "5us" "L3"
test_module Write_Arbiter_RR_tb "5us" "L3"

# LEVEL 4: Decoders  
puts "\n========== LEVEL 4: DECODERS =========="
test_module Write_Addr_Channel_Dec_tb "1us" "L4"
test_module Write_Resp_Channel_Dec_tb "1us" "L4"

# LEVEL 5: Handshakes
puts "\n========== LEVEL 5: HANDSHAKES =========="
test_module AW_HandShake_Checker_tb "1us" "L5"
test_module WD_HandShake_tb "1us" "L5"
test_module WR_HandShake_tb "1us" "L5"

# LEVEL 6: Controllers
puts "\n========== LEVEL 6: CONTROLLERS =========="
test_module AW_Channel_Controller_Top_tb "2us" "L6"
test_module WD_Channel_Controller_Top_tb "2us" "L6"
test_module BR_Channel_Controller_Top_tb "2us" "L6"
test_module Controller_tb "2us" "L6"

# LEVEL 7: Datapath
puts "\n========== LEVEL 7: DATAPATH =========="
test_module AW_MUX_2_1_tb "500ns" "L7"
test_module WD_MUX_2_1_tb "500ns" "L7"

# LEVEL 8: Interconnect
puts "\n========== LEVEL 8: FULL INTERCONNECT =========="
test_module AXI_Interconnect_tb "10us" "L8"

# Summary
puts "\n=========================================="
puts "FINAL TEST SUMMARY"
puts "=========================================="
puts "Total Tests:    $total"
puts "Passed:         $passed"
puts "Failed:         $failed"

if {$total > 0} {
    set success_rate [expr {($passed * 100) / $total}]
    puts "Success Rate:   $success_rate%"
}

if {$failed > 0} {
    puts "\n=========================================="
    puts "FAILED MODULES (note for later fix):"
    puts "=========================================="
    puts $failed_list
    puts "These modules have issues and need fixing."
} else {
    puts "\nALL MODULES PASSED!"
}

puts "=========================================="
puts "Testing complete."
quit


