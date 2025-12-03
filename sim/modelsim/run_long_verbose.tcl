# run_long_verbose.tcl - Extended verbose test without testbench auto-finish

puts "\n========================================"
puts "DUAL RISC-V - EXTENDED VERBOSE TEST"  
puts "========================================"
puts "Running 500us to see more activity...\n"

vsim work.dual_riscv_axi_system_tb

# Disable $finish to run longer
onfinish stop

# Run with detailed progress
for {set t 50} {$t <= 500} {incr t 50} {
    run 50us
    
    set m0r [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
    set m1r [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
    set m0w [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
    set m1w [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
    set total [expr $m0r + $m1r + $m0w + $m1w]
    
    # Show current addresses being accessed
    set m0_arv [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID]
    set m1_arv [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID]
    set m0_addr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARADDR]
    set m1_addr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARADDR]
    
    puts "[format "%4d" $t]us: Total=$total | M0: R=$m0r W=$m0w (REQ=$m0_arv @0x$m0_addr) | M1: R=$m1r W=$m1w (REQ=$m1_arv @0x$m1_addr)"
    
    # Show when new transactions happen
    if {$t > 50 && $total > [examine -time [expr $t-50]us -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]} {
        puts "      ↑ NEW ACTIVITY!"
    }
}

puts "\n========================================"
puts "FINAL STATISTICS @ 500us"
puts "========================================\n"

set m0r [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
set m1r [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
set m0w [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
set m1w [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
set total [expr $m0r + $m1r + $m0w + $m1w]

puts "Transaction Summary:"
puts "  Master 0: $m0r reads, $m0w writes = [expr $m0r+$m0w] total"
puts "  Master 1: $m1r reads, $m1w writes = [expr $m1r+$m1w] total"
puts "  GRAND TOTAL: $total transactions"

if {$total > 0} {
    set rate [expr $total / 500.0]
    puts "  Rate: [format "%.3f" $rate] trans/us"
}

puts "\nInterconnect Status:"
set arb [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE]
set turn [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/rd_turn]
set active [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active]
puts "  Arbitration: Mode $arb (1=RR), Turn=$turn, Active=$active"

puts "\nRAM State (first 16 words):"
for {set i 0} {$i < 16} {incr i} {
    set val [examine -radix hex /dual_riscv_axi_system_tb/dut/u_sram/mem($i)]
    puts "  mem\[[format "%2d" $i]\] = 0x$val"
}

puts "\n========================================"
puts "TEST COMPLETE"
puts "========================================\n"

quit

