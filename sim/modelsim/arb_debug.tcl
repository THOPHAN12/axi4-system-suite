# arb_debug.tcl - Focus on arbitration

vsim work.dual_riscv_axi_system_tb

run 1us

puts "\n========================================="
puts "ARBITRATION DEBUG"
puts "=========================================\n"

set m0_ar_req [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/m0_ar_req]
set m1_ar_req [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/m1_ar_req]
set rd_turn [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/rd_turn]
set read_active [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active]

puts "Request signals:"
puts "  m0_ar_req:   $m0_ar_req"
puts "  m1_ar_req:   $m1_ar_req"
puts "  read_active: $read_active"
puts "  rd_turn:     $rd_turn (0=MAST0, 1=MAST1)"

set grant_r_m0 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set grant_r_m1 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1]

puts "\nGrant signals:"
puts "  grant_r_m0: $grant_r_m0"
puts "  grant_r_m1: $grant_r_m1"

set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID]
set m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID]

puts "\nMaster ARVALID:"
puts "  M0_ARVALID: $m0_arvalid"
puts "  M1_ARVALID: $m1_arvalid"

puts "\nARBITRATION PARAMETER:"
set arb_mode [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE]
puts "  ARBITRATION_MODE: $arb_mode (0=FIXED, 1=ROUND_ROBIN, 2=QOS)"

puts "\n========================================="
puts "ANALYSIS"
puts "=========================================\n"

if {$m0_ar_req == "St1"} {
    puts "M0 is requesting"
    if {$m1_ar_req == "St1"} {
        puts "M1 is ALSO requesting"
        puts "Round-robin turn: $rd_turn"
        if {$rd_turn == "0"} {
            puts "→ Turn is MAST0, so M0 should be granted"
        } else {
            puts "→ Turn is MAST1, so M1 should be granted"
        }
    } else {
        puts "M1 is NOT requesting"
        puts "→ M0 should be granted (no contention)"
    }
    
    if {$grant_r_m0 == "St0"} {
        puts "\n❌ ERROR: M0 NOT GRANTED despite requesting!"
        puts "This is the BUG!"
    }
} else {
    puts "M0 is NOT requesting"
}

quit

