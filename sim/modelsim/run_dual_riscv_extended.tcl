# run_dual_riscv_extended.tcl - Extended run with waveform

puts "\n========================================="
puts "Dual RISC-V Extended Test"
puts "=========================================\n"

vsim work.dual_riscv_axi_system_tb

# Add comprehensive waveforms
puts "Adding waveforms..."

add wave -divider "=== CLOCK & RESET ==="
add wave /dual_riscv_axi_system_tb/ACLK
add wave /dual_riscv_axi_system_tb/ARESETN

add wave -divider "=== MASTER 0 (SERV 0) ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rdata

add wave -divider "=== MASTER 1 (SERV 1) ==="
add wave /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_araddr
add wave /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_rvalid
add wave /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_rready
add wave -hex /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_rdata

add wave -divider "=== INTERCONNECT ARBITRATION ==="
add wave -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_master
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/rd_turn
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1

add wave -divider "=== RAM (SLAVE 0) ==="
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARREADY
add wave -hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARADDR
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RVALID
add wave /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RREADY
add wave -hex /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RDATA

add wave -divider "=== TRANSACTION COUNTERS ==="
add wave -radix unsigned /dual_riscv_axi_system_tb/m0_read_count
add wave -radix unsigned /dual_riscv_axi_system_tb/m1_read_count
add wave -radix unsigned /dual_riscv_axi_system_tb/m0_write_count
add wave -radix unsigned /dual_riscv_axi_system_tb/m1_write_count

puts "\nRunning simulation for 100us..."
run 100us

puts "\n========================================="
puts "Simulation Complete!"
puts "=========================================\n"

# Check counters
set m0_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
set m1_reads [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
set m0_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
set m1_writes [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]

puts "Transaction Summary:"
puts "  Master 0 Reads:  $m0_reads"
puts "  Master 1 Reads:  $m1_reads"
puts "  Master 0 Writes: $m0_writes"
puts "  Master 1 Writes: $m1_writes"
puts "  Total: [expr $m0_reads + $m1_reads + $m0_writes + $m1_writes]"

wave zoom full
puts "\nWaveform ready for inspection!"
puts "Close GUI when done.\n"

