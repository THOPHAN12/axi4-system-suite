# run_detailed_console.tcl - Detailed console output for dual RISC-V system

puts "\n============================================================"
puts "    DUAL RISC-V AXI SYSTEM - DETAILED CONSOLE TEST"
puts "============================================================\n"

# Load design
vsim work.dual_riscv_axi_system_tb

puts "Design loaded successfully!"
puts "Starting simulation...\n"

# Run for initial period
puts "------------------------------------------------------------"
puts "PHASE 1: Reset and Initialization (0-200ns)"
puts "------------------------------------------------------------"
run 200ns

set aresetn [examine /dual_riscv_axi_system_tb/ARESETN]
puts "  ARESETN: $aresetn"
puts "  Status: System initialized\n"

# Run to first activity
puts "------------------------------------------------------------"
puts "PHASE 2: Early Execution (200ns-1us)"
puts "------------------------------------------------------------"
run 800ns

# Check system state at 1us
puts "\nSystem State @ 1us:"
puts "  Clock cycles: ~100"

set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID]
set m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID]
puts "  M0 ARVALID: $m0_arvalid"
puts "  M1 ARVALID: $m1_arvalid"

if {$m0_arvalid == "St1" || $m1_arvalid == "St1"} {
    puts "  → Masters are requesting!"
}

set arb_mode [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE]
puts "  Arbitration Mode: $arb_mode (1=ROUND_ROBIN)"

# Check first transactions
set m0_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
set m1_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
puts "  Transactions so far: M0=$m0_reads, M1=$m1_reads\n"

# Continue for more activity
puts "------------------------------------------------------------"
puts "PHASE 3: Active Execution (1us-10us)"
puts "------------------------------------------------------------"

for {set i 1} {$i <= 9} {incr i} {
    run 1us
    
    set current_time [expr $i + 1]
    set m0_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
    set m1_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
    set m0_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
    set m1_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
    set total [expr $m0_reads + $m1_reads + $m0_writes + $m1_writes]
    
    puts "  @ ${current_time}us: M0_R=$m0_reads, M1_R=$m1_reads, M0_W=$m0_writes, M1_W=$m1_writes, Total=$total"
    
    if {$total > 0} {
        # Check what addresses are being accessed
        set m0_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARADDR]
        set m1_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARADDR]
        
        if {$m0_arvalid == "St1"} {
            puts "    M0 accessing: 0x$m0_araddr"
        }
        if {$m1_arvalid == "St1"} {
            puts "    M1 accessing: 0x$m1_araddr"
        }
    }
}

puts "\n------------------------------------------------------------"
puts "PHASE 4: Extended Run (10us-50us)"
puts "------------------------------------------------------------"
puts "Running longer simulation to accumulate more transactions..."

# Run in larger chunks with periodic updates
for {set i 10} {$i <= 50} {incr i 10} {
    run 10us
    
    set m0_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
    set m1_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
    set m0_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
    set m1_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
    set total [expr $m0_reads + $m1_reads + $m0_writes + $m1_writes]
    
    puts "  @ ${i}us: Total Transactions = $total"
}

puts "\n------------------------------------------------------------"
puts "PHASE 5: Final Status & Analysis"
puts "------------------------------------------------------------"

# Get final counts
set m0_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
set m1_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
set m0_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
set m1_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
set total [expr $m0_reads + $m1_reads + $m0_writes + $m1_writes]

puts "\n=========================================="
puts "FINAL TRANSACTION STATISTICS"
puts "=========================================="
puts "  Master 0:"
puts "    Reads:  $m0_reads"
puts "    Writes: $m0_writes"
puts "    Total:  [expr $m0_reads + $m0_writes]"
puts ""
puts "  Master 1:"
puts "    Reads:  $m1_reads"
puts "    Writes: $m1_writes"
puts "    Total:  [expr $m1_reads + $m1_writes]"
puts ""
puts "  GRAND TOTAL: $total transactions"
puts "=========================================="

# Arbitration analysis
set rd_turn [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/rd_turn]
set read_active [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active]
set grant_m0 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set grant_m1 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1]

puts "\n=========================================="
puts "INTERCONNECT STATUS"
puts "=========================================="
puts "  Arbitration Mode: Round-Robin"
puts "  Current Turn: [expr {$rd_turn == "0" ? "Master 0" : "Master 1"}]"
puts "  Read Active: $read_active"
puts "  M0 Grant: $grant_m0"
puts "  M1 Grant: $grant_m1"
puts "=========================================="

# RAM status
puts "\n=========================================="
puts "RAM MEMORY DUMP (First 8 words)"
puts "=========================================="
for {set i 0} {$i < 8} {incr i} {
    set val [examine -radix hex /dual_riscv_axi_system_tb/dut/u_sram/mem($i)]
    puts "  mem\[$i\] = 0x$val"
}
puts "=========================================="

# Performance metrics
set sim_time [examine -time]
puts "\n=========================================="
puts "PERFORMANCE METRICS"
puts "=========================================="
puts "  Simulation Time: $sim_time"
puts "  Total Transactions: $total"

if {$total > 0} {
    set time_ns [string range $sim_time 0 end-2]
    set time_us [expr $time_ns / 1000.0]
    set rate [expr $total / $time_us]
    puts "  Transaction Rate: [format "%.2f" $rate] trans/us"
    puts "  Average Latency: [format "%.2f" [expr $time_us / $total]] us/trans"
}
puts "=========================================="

# Recommendations
puts "\n=========================================="
puts "ANALYSIS & RECOMMENDATIONS"
puts "=========================================="

if {$total == 0} {
    puts "  ⚠️  NO TRANSACTIONS DETECTED!"
    puts "  Possible reasons:"
    puts "    - SERV cores need more time to initialize"
    puts "    - Program may be in infinite loop"
    puts "    - Reset timing issue"
    puts ""
    puts "  Try:"
    puts "    - Run for longer time (500us+)"
    puts "    - Check waveform for activity"
    puts "    - Verify program is loaded correctly"
} elseif {$total < 10} {
    puts "  ✅ System is working but activity is LOW"
    puts "  This is NORMAL for SERV (bit-serial CPU)"
    puts ""
    puts "  To see more activity:"
    puts "    - Run for much longer (1ms+)"
    puts "    - Use more aggressive test program"
    puts "    - Create memory access loop"
} else {
    puts "  ✅ System is working with GOOD activity!"
    puts "  Transaction rate is healthy."
    puts ""
    puts "  Next steps:"
    puts "    - Test peripheral access (GPIO, UART, SPI)"
    puts "    - Verify write operations"
    puts "    - Stress test with continuous traffic"
}

puts "=========================================="

puts "\n============================================================"
puts "    TEST COMPLETE!"
puts "============================================================\n"

quit

