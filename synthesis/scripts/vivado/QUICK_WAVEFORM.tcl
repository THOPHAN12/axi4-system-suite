#==============================================================================
# QUICK_WAVEFORM.tcl
# Quick waveform setup - copy this to your project directory for easy access
#==============================================================================

puts "============================================================================"
puts "Quick Waveform Setup for dual_riscv_axi_system"
puts "============================================================================"
puts ""

# Check if simulation is running
set sim_running [current_sim]
if {$sim_running == ""} {
    puts "No simulation running. Please launch simulation first:"
    puts "  launch_simulation"
    puts ""
    puts "Make sure testbench is set as top:"
    puts "  set_property top dual_riscv_system_tb [get_filesets sim_1]"
    return
}

puts "Simulation is running: $sim_running"
puts "Setting up waveform..."
puts ""

# Helper function to safely add wave
proc safe_add_wave {signal_path {radix ""}} {
    if {$radix != ""} {
        set signal_obj [get_objects -quiet -radix $radix $signal_path]
    } else {
        set signal_obj [get_objects -quiet $signal_path]
    }
    
    if {[llength $signal_obj] > 0} {
        if {$radix != ""} {
            add_wave -radix $radix $signal_path
        } else {
            add_wave $signal_path
        }
        return 1
    } else {
        puts "  WARNING: Signal not found: $signal_path"
        return 0
    }
}

# Clock & Reset
add_wave_divider "Clock & Reset"
safe_add_wave /dual_riscv_system_tb/ACLK
safe_add_wave /dual_riscv_system_tb/ARESETN

# GPIO
add_wave_divider "GPIO"
safe_add_wave /dual_riscv_system_tb/gpio_out hex
safe_add_wave /dual_riscv_system_tb/gpio_in hex

# UART
add_wave_divider "UART"
safe_add_wave /dual_riscv_system_tb/uart_tx_valid
safe_add_wave /dual_riscv_system_tb/uart_tx_byte hex

# SPI
add_wave_divider "SPI"
safe_add_wave /dual_riscv_system_tb/spi_cs_n
safe_add_wave /dual_riscv_system_tb/spi_sclk
safe_add_wave /dual_riscv_system_tb/spi_mosi
safe_add_wave /dual_riscv_system_tb/spi_miso

# SERV Core 0 - AXI Read
add_wave_divider "SERV 0 - Instruction Fetch (M0)"
safe_add_wave /dual_riscv_system_tb/dut/serv0_M0_arvalid
safe_add_wave /dual_riscv_system_tb/dut/serv0_M0_arready
safe_add_wave /dual_riscv_system_tb/dut/serv0_M0_araddr hex
safe_add_wave /dual_riscv_system_tb/dut/serv0_M0_rvalid
safe_add_wave /dual_riscv_system_tb/dut/serv0_M0_rready
safe_add_wave /dual_riscv_system_tb/dut/serv0_M0_rdata hex

# SERV Core 0 - AXI Write
add_wave_divider "SERV 0 - Data Write (M1)"
safe_add_wave /dual_riscv_system_tb/dut/serv0_M1_awvalid
safe_add_wave /dual_riscv_system_tb/dut/serv0_M1_awready
safe_add_wave /dual_riscv_system_tb/dut/serv0_M1_awaddr hex
safe_add_wave /dual_riscv_system_tb/dut/serv0_M1_wvalid
safe_add_wave /dual_riscv_system_tb/dut/serv0_M1_wready
safe_add_wave /dual_riscv_system_tb/dut/serv0_M1_wdata hex

# SERV Core 1 - AXI Read
add_wave_divider "SERV 1 - Instruction Fetch (M0)"
safe_add_wave /dual_riscv_system_tb/dut/serv1_M0_arvalid
safe_add_wave /dual_riscv_system_tb/dut/serv1_M0_arready
safe_add_wave /dual_riscv_system_tb/dut/serv1_M0_araddr hex
safe_add_wave /dual_riscv_system_tb/dut/serv1_M0_rvalid
safe_add_wave /dual_riscv_system_tb/dut/serv1_M0_rready
safe_add_wave /dual_riscv_system_tb/dut/serv1_M0_rdata hex

# SERV Core 1 - AXI Write
add_wave_divider "SERV 1 - Data Write (M1)"
safe_add_wave /dual_riscv_system_tb/dut/serv1_M1_awvalid
safe_add_wave /dual_riscv_system_tb/dut/serv1_M1_awready
safe_add_wave /dual_riscv_system_tb/dut/serv1_M1_awaddr hex
safe_add_wave /dual_riscv_system_tb/dut/serv1_M1_wvalid
safe_add_wave /dual_riscv_system_tb/dut/serv1_M1_wready
safe_add_wave /dual_riscv_system_tb/dut/serv1_M1_wdata hex

# Zoom to fit
wave zoom full

puts ""
puts "Waveform setup complete!"
puts ""
puts "Useful commands:"
puts "  run 10us          - Run for 10 microseconds"
puts "  run -all          - Run until finish"
puts "  restart           - Restart simulation"
puts "  wave zoom full    - Zoom to fit all signals"



