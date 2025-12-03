# detailed_debug.tcl - Very detailed signal tracing

vsim work.dual_riscv_axi_system_tb

run 1us

puts "\n========================================="
puts "DETAILED DEBUG - READ PATH"
puts "=========================================\n"

# Master 0 signals
set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid]
set m0_arready [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arready]
set m0_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_araddr]
puts "Master 0 (SERV) → Interconnect:"
puts "  arvalid: $m0_arvalid"
puts "  arready: $m0_arready"
puts "  araddr:  $m0_araddr"

# Interconnect internal
puts "\nInterconnect Internal:"
set read_active [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active]
set read_master [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_master]
set read_slave [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_slave]
puts "  read_active: $read_active"
puts "  read_master: $read_master"
puts "  read_slave:  $read_slave"

set m0_ar_req [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/m0_ar_req]
set grant_r_m0 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set m0_ar_sel [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/m0_ar_sel]
puts "  m0_ar_req:   $m0_ar_req"
puts "  grant_r_m0:  $grant_r_m0"
puts "  m0_ar_sel:   $m0_ar_sel (decoded slave)"

# Interconnect → Slave 0 (RAM)
puts "\nInterconnect → Slave 0 (RAM):"
set s0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID]
set s0_arready [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARREADY]
set s0_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARADDR]
puts "  S0_ARVALID: $s0_arvalid"
puts "  S0_ARREADY: $s0_arready"
puts "  S0_ARADDR:  $s0_araddr"

# RAM signals
puts "\nRAM Slave:"
set ram_arvalid [examine /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arvalid]
set ram_arready [examine /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arready]
set ram_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_araddr]
puts "  S_AXI_arvalid: $ram_arvalid"
puts "  S_AXI_arready: $ram_arready"
puts "  S_AXI_araddr:  $ram_araddr"

# RAM internal state
puts "\nRAM Internal State:"
set ram_read_busy [examine /dual_riscv_axi_system_tb/dut/ram_slave/read_busy]
puts "  read_busy: $ram_read_busy"

puts "\n========================================="
puts "ROOT CAUSE ANALYSIS"
puts "=========================================\n"

if {$m0_arvalid == "St1"} {
    puts "✓ Master 0 is requesting (arvalid=1)"
    
    if {$grant_r_m0 == "St1"} {
        puts "✓ Arbitration granted to Master 0"
        
        if {$s0_arvalid == "St1"} {
            puts "✓ Request forwarded to Slave 0"
            
            if {$s0_arready == "St1"} {
                puts "✓ Slave 0 is ready"
                puts "\n→ Transaction should be progressing!"
            } else {
                puts "✗ Slave 0 NOT READY (arready=0)"
                puts "\n→ PROBLEM: RAM is not responding!"
            }
        } else {
            puts "✗ Request NOT forwarded to Slave 0"
            puts "\n→ PROBLEM: Interconnect routing issue!"
        }
    } else {
        puts "✗ Arbitration NOT granted"
        puts "\n→ PROBLEM: Arbitration logic issue!"
    }
} else {
    puts "✗ Master 0 NOT requesting"
    puts "\n→ PROBLEM: SERV core or WB2AXI converter!"
}

puts "\n========================================="
quit

