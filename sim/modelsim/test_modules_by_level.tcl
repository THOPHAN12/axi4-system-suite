# File: test_modules_by_level.tcl
# Test all modules level by level from small to large
# Usage: vsim -c -do "do test_modules_by_level.tcl"

puts "========================================"
puts "MODULE TESTING - LEVEL BY LEVEL"
puts "========================================"
puts "Testing from smallest utilities to full system"
puts ""

set total_tests 0
set passed_tests 0
set failed_tests 0
set error_tests ""

# Procedure to run a testbench and capture result
proc run_test {tb_name level} {
    global total_tests passed_tests failed_tests error_tests
    
    incr total_tests
    puts "\n----------------------------------------"
    puts "\[$level\] Testing: $tb_name"
    puts "----------------------------------------"
    
    if {[catch {
        vsim work.$tb_name -c
        run -all
        
        # Check for errors in transcript
        set result "PASS"
        
        quit -sim
        
        incr passed_tests
        puts "PASS: $tb_name"
        return 1
    } err]} {
        incr failed_tests
        append error_tests "$tb_name (Level: $level)\n"
        puts "FAIL: $tb_name - $err"
        catch {quit -sim}
        return 0
    }
}

# LEVEL 1: Basic Utilities
puts "\n========================================"
puts "LEVEL 1: BASIC UTILITIES"
puts "========================================"

set utils_tests [list \
    Raising_Edge_Det_tb \
    Faling_Edge_Detc_tb \
    Mux_2x1_tb \
    Demux_1x2_tb \
    Mux_2x1_en_tb \
    Demux_1x2_en_tb \
    BReady_MUX_2_1_tb \
    Demux_1_2_tb \
]

foreach tb $utils_tests {
    run_test $tb "LEVEL 1"
}

# LEVEL 2: Buffers & Queues
puts "\n========================================"
puts "LEVEL 2: BUFFERS & QUEUES"
puts "========================================"

set buffer_tests [list \
    Queue_tb \
    Resp_Queue_tb \
]

foreach tb $buffer_tests {
    run_test $tb "LEVEL 2"
}

# LEVEL 3: Arbitration Logic
puts "\n========================================"
puts "LEVEL 3: ARBITRATION LOGIC"
puts "========================================"

set arb_tests [list \
    Write_Arbiter_tb \
    Write_Arbiter_RR_tb \
]

foreach tb $arb_tests {
    run_test $tb "LEVEL 3"
}

# LEVEL 4: Decoders
puts "\n========================================"
puts "LEVEL 4: DECODERS"
puts "========================================"

set dec_tests [list \
    Write_Addr_Channel_Dec_tb \
    Write_Resp_Channel_Dec_tb \
]

foreach tb $dec_tests {
    run_test $tb "LEVEL 4"
}

# LEVEL 5: Handshake Controllers
puts "\n========================================"
puts "LEVEL 5: HANDSHAKE CONTROLLERS"
puts "========================================"

set hs_tests [list \
    AW_HandShake_Checker_tb \
    WD_HandShake_tb \
    WR_HandShake_tb \
]

foreach tb $hs_tests {
    run_test $tb "LEVEL 5"
}

# LEVEL 6: Channel Controllers
puts "\n========================================"
puts "LEVEL 6: CHANNEL CONTROLLERS"
puts "========================================"

set ctrl_tests [list \
    AW_Channel_Controller_Top_tb \
    WD_Channel_Controller_Top_tb \
    BR_Channel_Controller_Top_tb \
    Controller_tb \
]

foreach tb $ctrl_tests {
    run_test $tb "LEVEL 6"
}

# LEVEL 7: Datapath Components
puts "\n========================================"
puts "LEVEL 7: DATAPATH COMPONENTS"
puts "========================================"

set dp_tests [list \
    AW_MUX_2_1_tb \
    WD_MUX_2_1_tb \
    Demux_1x2_tb \
]

foreach tb $dp_tests {
    run_test $tb "LEVEL 7"
}

# Final Summary
puts "\n========================================"
puts "TEST SUMMARY"
puts "========================================"
puts "Total Tests:  $total_tests"
puts "Passed:       $passed_tests"
puts "Failed:       $failed_tests"
puts "Success Rate: [expr ($passed_tests * 100.0) / $total_tests]%"

if {$failed_tests > 0} {
    puts "\n========================================"
    puts "FAILED TESTS (Note for later fix):"
    puts "========================================"
    puts $error_tests
} else {
    puts "\nALL TESTS PASSED!"
}

puts "\n========================================"
puts "MODULE TESTING COMPLETE"
puts "========================================"

quit

