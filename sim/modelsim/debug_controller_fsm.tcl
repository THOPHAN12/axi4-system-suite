# Debug Controller FSM for Test 11
# Check if state machine transitions to Slave3

puts "=========================================="
puts "DEBUG: Controller FSM Test 11"
puts "=========================================="

# Load design
vsim work.Controller_tb

# Add critical signals
puts "\nAdding debug signals..."

# State machine
add wave -divider "=== STATE MACHINE ===" -color yellow
add wave -radix unsigned /Controller_tb/uut/curr_state_slave -label "curr_state (0=Idle,1=S0,2=S1,3=S2,4=S3)"
add wave -radix unsigned /Controller_tb/uut/next_state_slave -label "next_state"

# Address and control
add wave -divider "=== ADDRESS & CONTROL ===" -color cyan
add wave -radix hex /Controller_tb/M_ADDR -label "M_ADDR"
add wave /Controller_tb/M0_ARVALID -label "M0_ARVALID"
add wave /Controller_tb/S3_ARREADY -label "S3_ARREADY"

# Address range
add wave -radix hex /Controller_tb/uut/slave3_addr1 -label "slave3_addr1"
add wave -radix hex /Controller_tb/uut/slave3_addr2 -label "slave3_addr2"

# Data channel
add wave -divider "=== DATA CHANNEL ===" -color orange
add wave /Controller_tb/S3_RVALID -label "S3_RVALID"
add wave /Controller_tb/S3_RLAST -label "S3_RLAST"
add wave /Controller_tb/M0_RREADY -label "M0_RREADY"

# Output
add wave -divider "=== OUTPUT ===" -color springgreen
add wave -radix binary /Controller_tb/select_data_M0 -label "select_data_M0 (expect 11)"

# Run to Test 11
puts "\nRunning to Test 11..."
run 4.5us

# Check state
puts "\n=========================================="
puts "STATE MACHINE ANALYSIS @ 4.5us (Test 11)"
puts "=========================================="

set curr_state [examine -radix unsigned /Controller_tb/uut/curr_state_slave]
set next_state [examine -radix unsigned /Controller_tb/uut/next_state_slave]
set sel_data [examine -radix binary /Controller_tb/select_data_M0]
set m_addr [examine -radix hex /Controller_tb/M_ADDR]
set m0_arvalid [examine /Controller_tb/M0_ARVALID]
set s3_arready [examine /Controller_tb/S3_ARREADY]

puts "Current State:  $curr_state (should be 4 for Slave3)"
puts "Next State:     $next_state"
puts "select_data_M0: $sel_data (should be 11)"
puts "M_ADDR:         $m_addr (should be in S3 range)"
puts "M0_ARVALID:     $m0_arvalid"
puts "S3_ARREADY:     $s3_arready"

if {$curr_state == 4} {
    puts "\n✓ State machine IS in Slave3!"
    if {$sel_data == "11"} {
        puts "✓ select_data_M0 is correct!"
        puts "\n==> RTL CODE IS CORRECT! Issue is in testbench timing."
    } else {
        puts "✗ select_data_M0 is WRONG even in Slave3 state!"
        puts "\n==> RTL CODE HAS A BUG!"
    }
} else {
    puts "\n✗ State machine is NOT in Slave3!"
    puts "   -> State transition failed. Check conditions:"
    
    set s3_addr1 [examine -radix hex /Controller_tb/uut/slave3_addr1]
    set s3_addr2 [examine -radix hex /Controller_tb/uut/slave3_addr2]
    
    puts "   S3 Address Range: $s3_addr1 - $s3_addr2"
    puts "   M_ADDR: $m_addr"
    puts "   M0_ARVALID: $m0_arvalid (need 1)"
    puts "   S3_ARREADY: $s3_arready (need 1)"
    
    if {$m0_arvalid == "1" && $s3_arready == "1"} {
        puts "\n   -> Both signals OK. Problem: Address decode or timing!"
    } else {
        puts "\n   -> Missing required signals for state transition!"
    }
}

puts "\n=========================================="
puts "Run 'wave zoom full' to see waveform"
puts "=========================================="

# Keep GUI open
puts "\nGUI ready. Type 'quit' to exit."


