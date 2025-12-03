# Detailed debug for Test 11 - step by step

vsim -c work.Controller_tb

# Run to just before Test 11
run 420ns

puts "\n=========================================="
puts "BEFORE Test 11"
puts "=========================================="
set state_before [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
puts "State before Test 11: $state_before"

# Step through Test 11
puts "\nRunning Test 11 step by step..."

# Step 1: After reset signals
run 20ns  # 440ns total
puts "\n[440ns] After reset signals:"
set state1 [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
set m0_arv [examine /Controller_tb/M0_ARVALID]
set s3_arr [examine /Controller_tb/S3_ARREADY]
puts "  State: $state1, M0_ARVALID: $m0_arv, S3_ARREADY: $s3_arr"

# Step 2: After M_ADDR and M0_ARVALID set
run 20ns  # 460ns
puts "\n[460ns] After M_ADDR + M0_ARVALID set:"
set state2 [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
set next_state2 [examine -radix unsigned /Controller_tb/uut/next_state_slave]
set m_addr [examine -radix hex /Controller_tb/M_ADDR]
set m0_arv2 [examine /Controller_tb/M0_ARVALID]
set s3_arr2 [examine /Controller_tb/S3_ARREADY]
puts "  State: $state2, Next: $next_state2"
puts "  M_ADDR: $m_addr, M0_ARVALID: $m0_arv2, S3_ARREADY: $s3_arr2"

# Check address range match
set s3_addr1 [examine -radix hex /Controller_tb/slave3_addr1]
set s3_addr2 [examine -radix hex /Controller_tb/slave3_addr2]
puts "  S3 Range: $s3_addr1 - $s3_addr2"

# Step 3: After wait for state transition
run 20ns  # 480ns
puts "\n[480ns] After state transition wait:"
set state3 [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
set sel_data3 [examine /Controller_tb/select_data_M0]
puts "  State: $state3 (should be 4 for Slave3)"
puts "  select_data_M0: $sel_data3"

# Step 4: After S3_RVALID set
run 20ns  # 500ns
puts "\n[500ns] After S3_RVALID + M0_RREADY set:"
set state4 [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
set sel_data4 [examine /Controller_tb/select_data_M0]
set s3_rv [examine /Controller_tb/S3_RVALID]
set m0_rr [examine /Controller_tb/M0_RREADY]
puts "  State: $state4"
puts "  select_data_M0: $sel_data4"
puts "  S3_RVALID: $s3_rv, M0_RREADY: $m0_rr"

puts "\n=========================================="
puts "DIAGNOSIS:"
puts "=========================================="

if {$state4 == "4"} {
    puts "✓ State machine reached Slave3"
    if {$sel_data4 == "11"} {
        puts "✓ select_data_M0 is correct (11)"
        puts "\n==> RTL IS WORKING! Test timing issue."
    } else {
        puts "✗ select_data_M0 is WRONG ($sel_data4)"
        puts "\n==> RTL BUG in Slave3 state output logic!"
    }
} else {
    puts "✗ State machine did NOT reach Slave3 (state=$state4)"
    puts "\n==> PROBLEM: State transition conditions not met"
    puts "Check:"
    puts "  1. Address decode logic"
    puts "  2. M0_ARVALID timing"
    puts "  3. S3_ARREADY timing"
    puts "  4. Clock edges"
}

puts "=========================================="
quit


