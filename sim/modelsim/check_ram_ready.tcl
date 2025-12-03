# check_ram_ready.tcl - Check if RAM is responding

vsim work.dual_riscv_axi_system_tb
run 500ns

puts "\n========================================="
puts "RAM READINESS CHECK @ 500ns"
puts "=========================================\n"

# Check interconnect to RAM
puts "Interconnect → RAM:"
set s0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID]
set s0_arready [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARREADY]
set s0_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARADDR]
puts "  S0_ARVALID: $s0_arvalid"
puts "  S0_ARREADY: $s0_arready"
puts "  S0_ARADDR:  0x$s0_araddr"

# Find RAM instance name
puts "\nSearching for RAM instance..."
puts "Checking possible paths:"

# Try different possible paths
set paths [list \
    "/dual_riscv_axi_system_tb/dut/ram_slave" \
    "/dual_riscv_axi_system_tb/dut/u_ram" \
    "/dual_riscv_axi_system_tb/dut/slave0" \
    "/dual_riscv_axi_system_tb/dut/u_ram_slave"]

foreach path $paths {
    if {[catch {examine $path/S_AXI_arvalid} result]} {
        puts "  $path - NOT FOUND"
    } else {
        puts "  $path - FOUND!"
        set ram_path $path
        break
    }
}

if {[info exists ram_path]} {
    puts "\nRAM Instance: $ram_path"
    set ram_arvalid [examine $ram_path/S_AXI_arvalid]
    set ram_arready [examine $ram_path/S_AXI_arready]
    puts "  S_AXI_arvalid: $ram_arvalid"
    puts "  S_AXI_arready: $ram_arready"
    
    if {$ram_arready == "St0"} {
        puts "\n❌ RAM NOT READY!"
        set read_busy [examine $ram_path/read_busy]
        puts "  read_busy: $read_busy"
    } else {
        puts "\n✅ RAM IS READY"
    }
} else {
    puts "\n⚠️  Could not find RAM instance"
    puts "Listing all instances under /dual_riscv_axi_system_tb/dut/:"
    # This would need further hierarchy exploration
}

# Check M0 and M1 readiness
puts "\n========================================="
puts "Master Status:"
puts "=========================================\n"

set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID]
set m0_arready [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARREADY]
set m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID]
set m1_arready [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARREADY]

puts "Master 0: ARVALID=$m0_arvalid, ARREADY=$m0_arready"
puts "Master 1: ARVALID=$m1_arvalid, ARREADY=$m1_arready"

if {$m0_arvalid == "St1" && $m0_arready == "St1"} {
    puts "✅ M0 HANDSHAKE ACTIVE!"
} elseif {$m1_arvalid == "St1" && $m1_arready == "St1"} {
    puts "✅ M1 HANDSHAKE ACTIVE!"
} else {
    puts "❌ NO HANDSHAKE"
    if {$s0_arvalid == "St1" && $s0_arready == "St0"} {
        puts "   Reason: RAM not responding (S0_ARREADY=0)"
    }
}

puts "\n========================================="
quit

