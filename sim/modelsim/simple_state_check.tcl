# Simple state machine check for Test 11

vsim -c work.Controller_tb

# Run until Test 11
run 4.8us

# Sample signals
set curr_state [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
set sel_data [examine /Controller_tb/select_data_M0]
set m0_arvalid [examine /Controller_tb/M0_ARVALID]
set s3_arready [examine /Controller_tb/S3_ARREADY]
set s3_rvalid [examine /Controller_tb/S3_RVALID]
set m_addr [examine -radix hex /Controller_tb/M_ADDR]

puts "\n=========================================="
puts "Test 11 State Check @ 4.8us"
puts "=========================================="
puts "curr_state_slave:  $curr_state (0=Idle,1=S0,2=S1,3=S2,4=S3)"
puts "select_data_M0:    $sel_data (expect: 11)"
puts "M_ADDR:            $m_addr"
puts "M0_ARVALID:        $m0_arvalid"
puts "S3_ARREADY:        $s3_arready"
puts "S3_RVALID:         $s3_rvalid"

if {$curr_state == "4"} {
    puts "\nSTATE OK: In Slave3"
    if {$sel_data == "11"} {
        puts "OUTPUT OK: select_data_M0 = 11"
        puts "\n=> RTL IS CORRECT!"
    } else {
        puts "OUTPUT WRONG: select_data_M0 = $sel_data"
        puts "\n=> RTL BUG: Output wrong even in correct state!"
    }
} else {
    puts "\nSTATE WRONG: Not in Slave3 (curr=$curr_state)"
    puts "\n=> ISSUE: State transition failed"
    puts "   Check: Address range, ARVALID, ARREADY"
}

puts "=========================================="
quit


