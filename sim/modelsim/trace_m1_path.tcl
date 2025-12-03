# trace_m1_path.tcl - Trace complete M1 signal path

vsim work.dual_riscv_axi_system_tb
run 500ns

puts "\n========================================="
puts "TRACING M1 SIGNAL PATH @ 500ns"
puts "=========================================\n"

# 1. SERV 1 Core
puts "1. SERV 1 Core (u_serv1/u_serv_core):"
set s1_ibus_cyc [examine /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_ibus_cyc]
set s1_ibus_adr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_ibus_adr]
puts "   o_ibus_cyc: $s1_ibus_cyc"
puts "   o_ibus_adr: 0x$s1_ibus_adr"

# 2. WB2AXI Converter
puts "\n2. WB2AXI Converter (u_serv1/u_wb2axi_inst):"
set wb_cyc [examine /dual_riscv_axi_system_tb/dut/u_serv1/u_wb2axi_inst/wb_cyc]
set wb_adr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv1/u_wb2axi_inst/wb_adr]
puts "   wb_cyc: $wb_cyc"
puts "   wb_adr: 0x$wb_adr"

# 3. AXI Master 1 (from SERV 1)
puts "\n3. AXI Master 1 (u_serv1/M0_AXI_*):"
set m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arvalid]
set m1_arready [examine /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arready]
set m1_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_araddr]
puts "   M0_AXI_arvalid: $m1_arvalid"
puts "   M0_AXI_arready: $m1_arready"
puts "   M0_AXI_araddr:  0x$m1_araddr"

# 4. Interconnect Input (M1 perspective)
puts "\n4. Interconnect M1 Input (u_rr_xbar/M1_*):"
set ic_m1_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID]
set ic_m1_arready [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARREADY]
set ic_m1_araddr [examine -radix hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARADDR]
puts "   M1_ARVALID: $ic_m1_arvalid"
puts "   M1_ARREADY: $ic_m1_arready"
puts "   M1_ARADDR:  0x$ic_m1_araddr"

# 5. Arbitration
puts "\n5. Arbitration Logic:"
set m1_ar_req [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/m1_ar_req]
set grant_m1 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1]
set m1_ar_sel [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/m1_ar_sel]
puts "   m1_ar_req:   $m1_ar_req"
puts "   grant_r_m1:  $grant_m1"
puts "   m1_ar_sel:   $m1_ar_sel (decoded slave)"

# 6. Slave Selection Logic
puts "\n6. Slave ARVALID Outputs:"
set s0_arv [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID]
set s1_arv [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S1_ARVALID]
set s2_arv [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S2_ARVALID]
set s3_arv [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/S3_ARVALID]
puts "   S0_ARVALID (RAM):  $s0_arv"
puts "   S1_ARVALID (GPIO): $s1_arv"
puts "   S2_ARVALID (UART): $s2_arv"
puts "   S3_ARVALID (SPI):  $s3_arv"

puts "\n========================================="
puts "FORMULA VERIFICATION"
puts "=========================================\n"

puts "S0_ARVALID should be:"
puts "  (grant_r_m0 && m0_ar_sel==0 && M0_ARVALID) ||"
puts "  (grant_r_m1 && m1_ar_sel==0 && M1_ARVALID)"

set grant_m0 [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set m0_ar_sel [examine -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/m0_ar_sel]
set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID]

puts "\nTerm 1 (M0): grant_r_m0=$grant_m0 && m0_ar_sel=$m0_ar_sel && M0_ARVALID=$m0_arvalid"
if {$grant_m0 == "St1" && $m0_ar_sel == "0" && $m0_arvalid == "St1"} {
    puts "  → Term 1 = TRUE"
    set term1 1
} else {
    puts "  → Term 1 = FALSE"
    set term1 0
}

puts "\nTerm 2 (M1): grant_r_m1=$grant_m1 && m1_ar_sel=$m1_ar_sel && M1_ARVALID=$ic_m1_arvalid"
if {$grant_m1 == "St1" && $m1_ar_sel == "0" && $ic_m1_arvalid == "St1"} {
    puts "  → Term 2 = TRUE"
    set term2 1
} else {
    puts "  → Term 2 = FALSE"
    set term2 0
}

puts "\nResult: S0_ARVALID = Term1 OR Term2 = [expr $term1 || $term2]"
puts "Actual S0_ARVALID: $s0_arv"

if {[expr $term1 || $term2] == 1 && $s0_arv == "St0"} {
    puts "\n❌ BUG: S0_ARVALID should be 1 but is 0!"
} elseif {[expr $term1 || $term2] == 0 && $s0_arv == "St0"} {
    puts "\n✅ S0_ARVALID = 0 is correct (no valid routing)"
    puts "\nReason: Neither M0 nor M1 has valid routing to S0"
    if {$m0_ar_sel != "0"} {
        puts "  - M0 targeting slave $m0_ar_sel (not RAM)"
    }
    if {$m1_ar_sel != "0"} {
        puts "  - M1 targeting slave $m1_ar_sel (not RAM)"
    }
}

puts "\n========================================="
quit

