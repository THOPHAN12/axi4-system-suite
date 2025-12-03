# quick_verify.tcl - Quick console verification

vsim work.dual_riscv_axi_system_tb

# Run enough time for transactions to occur
run 2us

puts "\n========================================="
puts "QUICK VERIFICATION @ 2us"
puts "=========================================\n"

# 1. Check ARBITRATION_MODE
set arb_mode [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE]
puts "1. ARBITRATION_MODE: $arb_mode"
if {$arb_mode == "1"} {
    puts "   ✅ CORRECT (ROUND_ROBIN)"
} else {
    puts "   ❌ WRONG! Should be 1"
}

# 2. Check if masters are requesting
set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid]
set m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arvalid]
puts "\n2. Master Requests:"
puts "   M0 ARVALID: $m0_arvalid"
puts "   M1 ARVALID: $m1_arvalid"

# 3. Check grants
set grant_m0 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set grant_m1 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1]
puts "\n3. Arbitration Grants:"
puts "   grant_r_m0: $grant_m0"
puts "   grant_r_m1: $grant_m1"

# 4. Check if slave is being accessed
set s0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID]
set s0_arready [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARREADY]
puts "\n4. Slave 0 (RAM) Access:"
puts "   S0_ARVALID: $s0_arvalid"
puts "   S0_ARREADY: $s0_arready"

# 5. Check RAM response
set ram_rvalid [examine /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rvalid]
set ram_rready [examine /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rready]
puts "\n5. RAM Response:"
puts "   S_AXI_rvalid: $ram_rvalid"
puts "   S_AXI_rready: $ram_rready"

# 6. Check if read transaction is active
set read_active [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active]
set read_master [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_master]
set read_slave [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_slave]
puts "\n6. Interconnect State:"
puts "   read_active: $read_active"
puts "   read_master: $read_master (0=M0, 1=M1)"
puts "   read_slave:  $read_slave (0=RAM, 1=GPIO, 2=UART, 3=SPI)"

# 7. Sample some RAM data to verify it's loaded
puts "\n7. RAM Content (first 4 words):"
for {set i 0} {$i < 4} {incr i} {
    set val [examine -radix hex /dual_riscv_axi_system_tb/dut/ram_slave/mem($i)]
    puts "   mem\[$i\] = $val"
}

# 8. Check SERV instruction fetch
set ibus_adr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_adr]
set ibus_cyc [examine /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_cyc]
set ibus_ack [examine /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_ack]
puts "\n8. SERV 0 Instruction Fetch:"
puts "   o_ibus_adr: $ibus_adr"
puts "   o_ibus_cyc: $ibus_cyc"
puts "   i_ibus_ack: $ibus_ack"

puts "\n========================================="
puts "DIAGNOSIS"
puts "=========================================\n"

if {$arb_mode != "1"} {
    puts "❌ CRITICAL: ARBITRATION_MODE still wrong!"
    puts "   Need to recompile with correct parameter."
} elseif {$m0_arvalid == "St0" && $m1_arvalid == "St0"} {
    puts "❌ PROBLEM: No masters requesting"
    puts "   SERV cores may not be running properly."
} elseif {$grant_m0 == "St0" && $grant_m1 == "St0"} {
    puts "❌ PROBLEM: No grants issued"
    puts "   Arbitration logic issue."
} elseif {$s0_arvalid == "St0"} {
    puts "❌ PROBLEM: No requests reaching slave"
    puts "   Interconnect routing issue."
} elseif {$s0_arready == "St0"} {
    puts "❌ PROBLEM: Slave not ready"
    puts "   RAM slave issue."
} elseif {$ram_rvalid == "St1" && $ram_rready == "St1"} {
    puts "✅ TRANSACTION IN PROGRESS!"
    puts "   Read data being returned."
} elseif {$read_active == "1"} {
    puts "⚠️  Transaction started but not complete yet"
    puts "   Wait for RVALID handshake."
} else {
    puts "⚠️  System state unclear - check waveform"
    puts "   May need longer simulation time."
}

puts "\n========================================="
quit

