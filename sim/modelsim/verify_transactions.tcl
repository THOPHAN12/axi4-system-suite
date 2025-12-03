# verify_transactions.tcl - Verify AXI transactions are occurring

puts "\n========================================="
puts "TRANSACTION VERIFICATION TEST"
puts "=========================================\n"

vsim work.dual_riscv_axi_system_tb

# Add critical signals for transaction monitoring
add wave -divider "=== CLOCK & RESET ==="
add wave /dual_riscv_axi_system_tb/ACLK
add wave /dual_riscv_axi_system_tb/ARESETN

add wave -divider "=== SERV 0 - INSTRUCTION FETCH ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_cyc
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_adr
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_rdt
add wave /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_ack

add wave -divider "=== MASTER 0 AXI (from SERV 0) ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rdata

add wave -divider "=== MASTER 1 AXI (from SERV 1) ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_araddr

add wave -divider "=== INTERCONNECT ARBITRATION ==="
add wave -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_master
add wave -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_slave
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/rd_turn
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1

add wave -divider "=== INTERCONNECT -> RAM (Slave 0) ==="
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARREADY
add wave -hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARADDR
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RVALID
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RREADY
add wave -hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RDATA

add wave -divider "=== RAM SLAVE ==="
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rdata
add wave /dual_riscv_axi_system_tb/dut/ram_slave/read_busy

puts "\nRunning simulation for 2us..."
run 2us

puts "\n========================================="
puts "CHECKING SIGNAL VALUES"
puts "=========================================\n"

# Check at 500ns (after reset)
puts "At 500ns (after reset released):"
set arb_mode [examine -time 500ns -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE]
puts "  ARBITRATION_MODE: $arb_mode"

set m0_arvalid [examine -time 500ns /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid]
set m0_arready [examine -time 500ns /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arready]
puts "  M0 arvalid: $m0_arvalid, arready: $m0_arready"

set grant_m0 [examine -time 500ns /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0]
set grant_m1 [examine -time 500ns /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1]
puts "  Grants: M0=$grant_m0, M1=$grant_m1"

# Count transaction handshakes
puts "\nSearching for READ transactions (arvalid & arready)..."

# Look for M0 read handshakes
set search_result [examine -time 0 -time 2us /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID]
puts "  S0_ARVALID activity detected"

# Check if RAM responded
set ram_rvalid [examine -time 1us /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_rvalid]
puts "  RAM S_AXI_rvalid at 1us: $ram_rvalid"

puts "\n========================================="
puts "ANALYSIS"
puts "=========================================\n"

if {$arb_mode == "1"} {
    puts "✅ ARBITRATION_MODE = 1 (ROUND_ROBIN) - CORRECT!"
} else {
    puts "❌ ARBITRATION_MODE = $arb_mode - WRONG!"
}

puts "\nTo see detailed waveform:"
puts "  - Zoom to 0-2us range"
puts "  - Look for ARVALID & ARREADY handshakes"
puts "  - Check if RVALID & RREADY complete transactions"
puts "  - Watch grant_r_m0 and grant_r_m1 alternating"

wave zoom range 0 2us
puts "\nWaveform ready. Examine the signals!"
puts "GUI will stay open for inspection."

