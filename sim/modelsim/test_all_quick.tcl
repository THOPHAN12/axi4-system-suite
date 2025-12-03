# File: test_all_quick.tcl
# Quick test of all modules - runs each for limited time

puts "=========================================="
puts "QUICK MODULE TEST SUITE"
puts "=========================================="

set total 0
set passed 0
set failed 0
set errors [list]

proc quick_test {tb_name timeout level} {
    global total passed failed errors
    incr total
    
    puts "\n\[$level\] $tb_name..."
    
    if {[catch {
        vsim -c work.$tb_name
        run $timeout
        
        # Check for test failures in output
        set log [exec tail -n 20 transcript 2>@stdout]
        if {[string match "*FAIL*" $log] || [string match "*ERROR*" $log] || [string match "*Fatal*" $log]} {
            incr failed
            lappend errors "$tb_name"
            puts "  -> FAIL (found errors)"
        } else {
            incr passed
            puts "  -> PASS"
        }
        
        quit -sim
    } err]} {
        incr failed
        lappend errors "$tb_name (crash: $err)"
        puts "  -> FAIL (crash)"
        catch {quit -sim}
    }
}

# LEVEL 1: Utils (8 tests)
puts "\n=== LEVEL 1: UTILS ==="
quick_test Raising_Edge_Det_tb "500ns" "L1"
quick_test Faling_Edge_Detc_tb "500ns" "L1"
quick_test Mux_2x1_tb "500ns" "L1"
quick_test Demux_1x2_tb "500ns" "L1"
quick_test Mux_2x1_en_tb "500ns" "L1"
quick_test Demux_1x2_en_tb "500ns" "L1"
quick_test BReady_MUX_2_1_tb "500ns" "L1"
quick_test Demux_1_2_tb "500ns" "L1"

# LEVEL 2: Buffers (2 tests)
puts "\n=== LEVEL 2: BUFFERS ==="
quick_test Queue_tb "1us" "L2"
quick_test Resp_Queue_tb "1us" "L2"

# LEVEL 3: Arbitration (2 tests)
puts "\n=== LEVEL 3: ARBITRATION ==="
quick_test Write_Arbiter_tb "2us" "L3"
quick_test Write_Arbiter_RR_tb "2us" "L3"

# LEVEL 4: Decoders (2 tests)
puts "\n=== LEVEL 4: DECODERS ==="
quick_test Write_Addr_Channel_Dec_tb "1us" "L4"
quick_test Write_Resp_Channel_Dec_tb "1us" "L4"

# LEVEL 5: Handshakes (3 tests)
puts "\n=== LEVEL 5: HANDSHAKES ==="
quick_test AW_HandShake_Checker_tb "1us" "L5"
quick_test WD_HandShake_tb "1us" "L5"
quick_test WR_HandShake_tb "1us" "L5"

# LEVEL 6: Controllers (4 tests)
puts "\n=== LEVEL 6: CONTROLLERS ==="
quick_test AW_Channel_Controller_Top_tb "2us" "L6"
quick_test WD_Channel_Controller_Top_tb "2us" "L6"
quick_test BR_Channel_Controller_Top_tb "2us" "L6"
quick_test Controller_tb "2us" "L6"

# LEVEL 7: Datapath (2 tests)
puts "\n=== LEVEL 7: DATAPATH ==="
quick_test AW_MUX_2_1_tb "500ns" "L7"
quick_test WD_MUX_2_1_tb "500ns" "L7"

# LEVEL 8: Full Interconnect (1 test)
puts "\n=== LEVEL 8: INTERCONNECT ==="
quick_test AXI_Interconnect_tb "5us" "L8"

puts "\n=========================================="
puts "TEST SUMMARY"
puts "=========================================="
puts "Total:   $total tests"
puts "Passed:  $passed"
puts "Failed:  $failed"
puts "Rate:    [expr ($passed * 100) / $total]%"

if {$failed > 0} {
    puts "\n=== FAILED TESTS (note for later) ==="
    foreach err $errors {
        puts "  X $err"
    }
    puts "\nThese modules need fixing later."
} else {
    puts "\nALL TESTS PASSED!"
}

puts "=========================================="
quit


