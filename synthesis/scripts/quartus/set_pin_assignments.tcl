# ==============================================================================
# Pin Assignment Template for AXI Interconnect System
# ==============================================================================
# Description: Sets pin assignments for FPGA board
# Usage: quartus_sh -t set_pin_assignments.tcl
# Note: CUSTOMIZE THIS FILE for your specific FPGA board!
# ==============================================================================

set project_name "AXI_Interconnect_System"

# Path configuration
set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir .. .. ..]]
set project_dir [file join $project_root "synthesis" "quartus"]

puts "\n===================================================================="
puts "Setting Pin Assignments"
puts "===================================================================="
puts "Project: $project_name"
puts "⚠ IMPORTANT: Customize pins for your specific board!"
puts "====================================================================\n"

cd $project_dir
project_open $project_name

# ==============================================================================
# CLOCK AND RESET
# ==============================================================================
puts "[1] Clock and Reset Pins"
puts "--------------------------------------------------------------------"

# Main clock (50 MHz) - CUSTOMIZE FOR YOUR BOARD
# Example for DE1-SoC: PIN_AF14
set_location_assignment PIN_AF14 -to ACLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ACLK

# Reset - CUSTOMIZE FOR YOUR BOARD
# Example for DE1-SoC: KEY0 = PIN_AA14 (active low)
set_location_assignment PIN_AA14 -to ARESETN
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARESETN

puts "  ✓ ACLK: PIN_AF14 (Customize!)"
puts "  ✓ ARESETN: PIN_AA14 (Customize!)"

# ==============================================================================
# GPIO PERIPHERAL (Example - 8 LEDs, 4 Switches)
# ==============================================================================
puts "\n[2] GPIO Signals (LEDs and Switches)"
puts "--------------------------------------------------------------------"

# Example LED pins (DE1-SoC LEDR[7:0])
set led_pins {PIN_V16 PIN_W16 PIN_V17 PIN_V18 PIN_W17 PIN_W19 PIN_Y19 PIN_W20}
for {set i 0} {$i < 8} {incr i} {
    set pin [lindex $led_pins $i]
    set_location_assignment $pin -to gpio_out\[$i\]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_out\[$i\]
}
puts "  ✓ gpio_out[7:0]: Assigned to LEDs (Customize!)"

# Example Switch pins (DE1-SoC SW[3:0])
set sw_pins {PIN_AB12 PIN_AC12 PIN_AF9 PIN_AF10}
for {set i 0} {$i < 4} {incr i} {
    set pin [lindex $sw_pins $i]
    set_location_assignment $pin -to gpio_in\[$i\]
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio_in\[$i\]
}
puts "  ✓ gpio_in[3:0]: Assigned to Switches (Customize!)"

# ==============================================================================
# UART PERIPHERAL (Example)
# ==============================================================================
puts "\n[3] UART Signals"
puts "--------------------------------------------------------------------"

# Example UART pins - CUSTOMIZE FOR YOUR BOARD
# TX pin
set_location_assignment PIN_AG9 -to uart_tx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_tx

# RX pin
set_location_assignment PIN_AG10 -to uart_rx
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uart_rx

puts "  ✓ uart_tx: PIN_AG9 (Customize!)"
puts "  ✓ uart_rx: PIN_AG10 (Customize!)"

# ==============================================================================
# SPI PERIPHERAL (Example)
# ==============================================================================
puts "\n[4] SPI Signals"
puts "--------------------------------------------------------------------"

# Example SPI pins - CUSTOMIZE FOR YOUR BOARD
set_location_assignment PIN_AH8 -to spi_sclk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_sclk

set_location_assignment PIN_AH9 -to spi_mosi
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_mosi

set_location_assignment PIN_AG11 -to spi_miso
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_miso

set_location_assignment PIN_AH11 -to spi_cs_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_cs_n

puts "  ✓ spi_sclk: PIN_AH8 (Customize!)"
puts "  ✓ spi_mosi: PIN_AH9 (Customize!)"
puts "  ✓ spi_miso: PIN_AG11 (Customize!)"
puts "  ✓ spi_cs_n: PIN_AH11 (Customize!)"

# ==============================================================================
# TIMING CONSTRAINTS
# ==============================================================================
puts "\n[5] Timing Constraints"
puts "--------------------------------------------------------------------"

# Create base clock constraint (50 MHz = 20 ns period)
create_clock -name {ACLK} -period 20.000 -waveform {0.000 10.000} [get_ports {ACLK}]

# Derive PLL clocks (if any)
derive_pll_clocks

# Set input/output delays (example: 5ns)
set_input_delay -clock ACLK -max 5.0 [all_inputs]
set_input_delay -clock ACLK -min 0.0 [all_inputs]
set_output_delay -clock ACLK -max 5.0 [all_outputs]
set_output_delay -clock ACLK -min 0.0 [all_outputs]

# False paths for reset
set_false_path -from [get_ports {ARESETN}]

puts "  ✓ Clock constraint: 50 MHz (20 ns period)"
puts "  ✓ I/O delays: 5 ns"
puts "  ✓ Reset false path set"

# ==============================================================================
# ADDITIONAL SETTINGS
# ==============================================================================
puts "\n[6] Additional Settings"
puts "--------------------------------------------------------------------"

# Reserve unused pins as inputs with weak pull-ups (to prevent floating)
set_global_assignment -name RESERVE_ALL_UNUSED_PINS_WEAK_PULLUP "AS INPUT TRI-STATED"

# Enable configuration device
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"

puts "  ✓ Unused pins: Weak pull-up"
puts "  ✓ I/O standard: 3.3V LVTTL"

# ==============================================================================
# SUMMARY
# ==============================================================================
puts "\n===================================================================="
puts "SUMMARY"
puts "===================================================================="
puts "✓ Pin assignments set (TEMPLATE - CUSTOMIZE FOR YOUR BOARD!)"
puts ""
puts "Assigned signals:"
puts "  • Clock: ACLK (50 MHz)"
puts "  • Reset: ARESETN"
puts "  • GPIO: 8 outputs (LEDs), 4 inputs (Switches)"
puts "  • UART: TX, RX"
puts "  • SPI: SCLK, MOSI, MISO, CS_N"
puts ""
puts "⚠ IMPORTANT:"
puts "  These are EXAMPLE pin assignments!"
puts "  You MUST customize them for your specific FPGA board:"
puts "  1. Check your board's user manual"
puts "  2. Update pin locations in this script"
puts "  3. Verify I/O standards match your board"
puts "  4. Re-run this script"
puts "===================================================================="

# Save and close
export_assignments
project_close

puts "\n✓ Pin assignments saved!\n"

