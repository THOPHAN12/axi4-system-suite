# count_transactions.tcl - Manually count transactions

vsim work.dual_riscv_axi_system_tb

puts "\n========================================="
puts "MANUAL TRANSACTION COUNTING"
puts "=========================================\n"

# Run simulation
puts "Running simulation for 10us..."
run 10us

# Count by sampling at every clock edge
puts "\nCounting handshakes..."

set m0_read_count 0
set m1_read_count 0
set m0_write_count 0
set m1_write_count 0

# Sample at intervals
for {set t 0} {$t < 10000} {incr t 10} {
    # Check M0 read
    set m0_arv [examine -time ${t}ns /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID]
    set m0_arr [examine -time ${t}ns /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARREADY]
    
    if {$m0_arv == "St1" && $m0_arr == "St1"} {
        incr m0_read_count
    }
    
    # Check M1 read
    set m1_arv [examine -time ${t}ns /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID]
    set m1_arr [examine -time ${t}ns /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARREADY]
    
    if {$m1_arv == "St1" && $m1_arr == "St1"} {
        incr m1_read_count
    }
}

puts "\n========================================="
puts "TRANSACTION COUNT (sampled every 10ns)"
puts "=========================================\n"
puts "  Master 0 Reads: $m0_read_count"
puts "  Master 1 Reads: $m1_read_count"
puts "  Total Reads: [expr $m0_read_count + $m1_read_count]"

if {$m0_read_count > 0 || $m1_read_count > 0} {
    puts "\n✅ TRANSACTIONS ARE OCCURRING!"
    puts "   Testbench counter may have timing issue."
} else {
    puts "\n❌ NO TRANSACTIONS DETECTED"
    puts "   Need further investigation."
}

puts "\n========================================="
quit

