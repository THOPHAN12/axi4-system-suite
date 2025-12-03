# run_complete_waveform.tcl - Complete simulation with organized waveform

puts "\n============================================================"
puts "    DUAL RISC-V AXI SYSTEM - COMPLETE WAVEFORM TEST"
puts "============================================================\n"

# Load testbench
vsim work.dual_riscv_axi_system_tb

puts "Creating organized waveform view...\n"

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# ============================================================
# GROUP 1: SYSTEM CLOCK & RESET
# ============================================================
add wave -noupdate -divider -height 30 "SYSTEM CLOCK & RESET"
add wave -noupdate -color Yellow /dual_riscv_axi_system_tb/ACLK
add wave -noupdate -color Cyan /dual_riscv_axi_system_tb/ARESETN

# ============================================================
# GROUP 2: SERV CORE 0 (Master 0)
# ============================================================
add wave -noupdate -divider -height 30 "SERV CORE 0 - Instruction Bus"
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_cyc
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_adr
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_rdt
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_ibus_ack

add wave -noupdate -divider "SERV CORE 0 - Data Bus"
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_cyc
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_adr
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_we
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_dbus_dat
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_dbus_rdt
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_dbus_ack

add wave -noupdate -divider "SERV CORE 0 - AXI Master Port"
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arready
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_araddr
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rvalid
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rready
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_rdata

# ============================================================
# GROUP 3: SERV CORE 1 (Master 1)
# ============================================================
add wave -noupdate -divider -height 30 "SERV CORE 1 - Instruction Bus"
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_ibus_cyc
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_ibus_adr
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/i_ibus_rdt
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/i_ibus_ack

add wave -noupdate -divider "SERV CORE 1 - Data Bus"
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_dbus_cyc
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_dbus_adr
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_dbus_we
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/o_dbus_dat
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/i_dbus_rdt
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_serv1/u_serv_core/i_dbus_ack

add wave -noupdate -divider "SERV CORE 1 - AXI Master Port"
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arvalid
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_arready
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_araddr
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_rvalid
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_rready
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_serv1/M0_AXI_rdata

# ============================================================
# GROUP 4: AXI INTERCONNECT
# ============================================================
add wave -noupdate -divider -height 30 "INTERCONNECT - Arbitration"
add wave -noupdate -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/ARBITRATION_MODE
add wave -noupdate -color Magenta /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_active
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_master
add wave -noupdate -radix unsigned /dual_riscv_axi_system_tb/dut/u_rr_xbar/read_slave
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_rr_xbar/rd_turn
add wave -noupdate -color "Light Blue" /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m0
add wave -noupdate -color "Light Blue" /dual_riscv_axi_system_tb/dut/u_rr_xbar/grant_r_m1

add wave -noupdate -divider "INTERCONNECT - Master 0 Interface"
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARVALID
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARREADY
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_rr_xbar/M0_ARADDR

add wave -noupdate -divider "INTERCONNECT - Master 1 Interface"
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARVALID
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARREADY
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_rr_xbar/M1_ARADDR

# ============================================================
# GROUP 5: SLAVE 0 - RAM
# ============================================================
add wave -noupdate -divider -height 30 "SLAVE 0 - RAM Interface"
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARVALID
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARREADY
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_ARADDR
add wave -noupdate -color "Orange Red" /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RVALID
add wave -noupdate -color "Spring Green" /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RREADY
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_rr_xbar/S0_RDATA

add wave -noupdate -divider "RAM Internal Signals"
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_sram/S_AXI_arvalid
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_sram/S_AXI_arready
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_sram/S_AXI_araddr
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_sram/S_AXI_rvalid
add wave -noupdate /dual_riscv_axi_system_tb/dut/u_sram/S_AXI_rready
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/dut/u_sram/S_AXI_rdata

# ============================================================
# GROUP 6: TRANSACTION COUNTERS
# ============================================================
add wave -noupdate -divider -height 30 "TRANSACTION COUNTERS"
add wave -noupdate -radix unsigned -color Gold /dual_riscv_axi_system_tb/m0_read_count
add wave -noupdate -radix unsigned -color Gold /dual_riscv_axi_system_tb/m1_read_count
add wave -noupdate -radix unsigned -color Gold /dual_riscv_axi_system_tb/m0_write_count
add wave -noupdate -radix unsigned -color Gold /dual_riscv_axi_system_tb/m1_write_count

# ============================================================
# GROUP 7: PERIPHERALS (Optional)
# ============================================================
add wave -noupdate -divider -height 30 "PERIPHERALS"
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/gpio_in
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/gpio_out
add wave -noupdate /dual_riscv_axi_system_tb/uart_tx_valid
add wave -noupdate -radix hexadecimal /dual_riscv_axi_system_tb/uart_tx_byte

puts "Waveform structure created!"
puts "Running simulation for 100us...\n"

# Run simulation
run 100us

puts "\n============================================================"
puts "    SIMULATION COMPLETE"
puts "============================================================\n"

# Print statistics
set m0r [examine -radix unsigned /dual_riscv_axi_system_tb/m0_read_count]
set m1r [examine -radix unsigned /dual_riscv_axi_system_tb/m1_read_count]
set m0w [examine -radix unsigned /dual_riscv_axi_system_tb/m0_write_count]
set m1w [examine -radix unsigned /dual_riscv_axi_system_tb/m1_write_count]
set total [expr $m0r + $m1r + $m0w + $m1w]

puts "Final Transaction Statistics:"
puts "  Master 0: Reads=$m0r, Writes=$m0w"
puts "  Master 1: Reads=$m1r, Writes=$m1w"
puts "  Total: $total transactions"
puts ""

# Zoom to show activity
puts "Zooming waveform to show activity..."
wave zoom range 0ns 2us

puts ""
puts "============================================================"
puts "WAVEFORM READY!"
puts "============================================================"
puts ""
puts "Key Areas to Inspect:"
puts "  1. 0-200ns: Reset sequence"
puts "  2. ~445ns: First M1 transaction"
puts "  3. Watch for ARVALID & ARREADY handshakes"
puts "  4. Check transaction counters increment"
puts ""
puts "Colors:"
puts "  Orange Red = VALID signals (requests)"
puts "  Spring Green = READY signals (grants)"
puts "  Yellow = Clock"
puts "  Cyan = Reset"
puts "  Magenta = Active states"
puts "  Gold = Counters"
puts ""
puts "Use Wave menu -> Zoom -> Zoom Full to see entire 100us"
puts "Use cursors to measure timing"
puts ""
puts "============================================================\n"


