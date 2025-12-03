# run_verbose.tcl - Verbose console output

puts "\n========================================"
puts "DUAL RISC-V AXI SYSTEM - VERBOSE TEST"
puts "========================================\n"

vsim work.dual_riscv_axi_system_tb

puts "Running simulation for 100us with periodic updates...\n"

# Run and report every 10us
for {set t 10} {$t <= 100} {incr t 10} {
    run 10us
    
    set m0r [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
    set m1r [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
    set m0w [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
    set m1w [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
    set total [expr $m0r + $m1r + $m0w + $m1w]
    
    puts "[format "%3d" $t]us: M0(R=$m0r,W=$m0w) M1(R=$m1r,W=$m1w) Total=$total"
}

puts "\n========================================"
puts "FINAL RESULTS"
puts "========================================\n"

set m0r [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
set m1r [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
set m0w [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
set m1w [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]

puts "Master 0: Reads=$m0r, Writes=$m0w"
puts "Master 1: Reads=$m1r, Writes=$m1w"
puts "Total: [expr $m0r+$m1r+$m0w+$m1w] transactions"

puts "\nRAM Content (first 8 words):"
for {set i 0} {$i < 8} {incr i} {
    set val [examine -radix hex /dual_riscv_axi_system_tb/dut/u_sram/mem($i)]
    puts "  \[$i\] = 0x$val"
}

set arb [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE]
puts "\nArbitration Mode: $arb (1=ROUND_ROBIN)"

puts "\n========================================\n"
quit

