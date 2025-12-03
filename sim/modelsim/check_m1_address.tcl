# check_m1_address.tcl - Check M1 address and slave selection

vsim work.dual_riscv_axi_system_tb
run 2us

puts "\n========================================="
puts "M1 ADDRESS DEBUGGING"
puts "=========================================\n"

# M0 signals
set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid]
set m0_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_araddr]
puts "Master 0:"
puts "  ARVALID: $m0_arvalid"
puts "  ARADDR:  0x$m0_araddr"

# M1 signals  
set m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arvalid]
set m1_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_araddr]
puts "\nMaster 1:"
puts "  ARVALID: $m1_arvalid"
puts "  ARADDR:  0x$m1_araddr"

# Slave selection
set m0_ar_sel [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/m0_ar_sel]
set m1_ar_sel [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/m1_ar_sel]
puts "\nSlave Selection (decoded from address[31:30]):"
puts "  m0_ar_sel: $m0_ar_sel (0=RAM, 1=GPIO, 2=UART, 3=SPI)"
puts "  m1_ar_sel: $m1_ar_sel (0=RAM, 1=GPIO, 2=UART, 3=SPI)"

# Grants
set grant_m0 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set grant_m1 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1]
puts "\nGrants:"
puts "  grant_r_m0: $grant_m0"
puts "  grant_r_m1: $grant_m1"

# S0 (RAM) signals
set s0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID]
set s1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S1_ARVALID]
set s2_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S2_ARVALID]
set s3_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S3_ARVALID]
puts "\nSlave ARVALID outputs:"
puts "  S0 (RAM):  $s0_arvalid"
puts "  S1 (GPIO): $s1_arvalid"
puts "  S2 (UART): $s2_arvalid"
puts "  S3 (SPI):  $s3_arvalid"

puts "\n========================================="
puts "ANALYSIS"
puts "=========================================\n"

if {$grant_m1 == "St1"} {
    puts "M1 is granted"
    puts "  M1_ARVALID = $m1_arvalid"
    puts "  M1_ARADDR = 0x$m1_araddr"
    puts "  m1_ar_sel = $m1_ar_sel"
    
    if {$m1_ar_sel == "0"} {
        puts "\n  → M1 targeting Slave 0 (RAM)"
        puts "  → S0_ARVALID should be: (grant_r_m1=1 && m1_ar_sel=0 && M1_ARVALID=1)"
        
        if {$m1_arvalid == "St1"} {
            puts "  → Formula: 1 && 1 && 1 = 1"
            puts "  → S0_ARVALID SHOULD BE 1!"
            
            if {$s0_arvalid == "St0"} {
                puts "\n  ❌ BUG: S0_ARVALID is 0 despite correct conditions!"
            } else {
                puts "\n  ✅ S0_ARVALID is correctly 1"
            }
        } else {
            puts "  → M1_ARVALID is 0, so S0_ARVALID = 0 is correct"
        }
    } else {
        puts "\n  → M1 targeting Slave $m1_ar_sel (NOT RAM)"
        puts "  → That's why S0_ARVALID = 0"
    }
} else {
    puts "M1 NOT granted (grant_r_m1 = 0)"
    puts "  → S0_ARVALID depends on M0"
}

if {$grant_m0 == "St1"} {
    puts "\nM0 is granted"
    if {$m0_ar_sel == "0" && $m0_arvalid == "St1"} {
        puts "  M0 targeting RAM with valid request"
        puts "  → S0_ARVALID should be 1"
    }
}

puts "\n========================================="
quit

