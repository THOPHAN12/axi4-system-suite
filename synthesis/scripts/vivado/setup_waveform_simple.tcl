#==============================================================================
# setup_waveform_simple.tcl
# Simple waveform setup - works with both DUT and testbench as top
#==============================================================================

puts "============================================================================"
puts "Simple Waveform Setup for dual_riscv_axi_system"
puts "============================================================================"
puts ""

# Helper function to safely add wave
proc safe_add_wave {signal_path {radix ""}} {
    # Check if signal exists
    set signal_obj [get_objects -quiet $signal_path]
    
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

# Check simulation top
set sim_top [get_property top [current_fileset -simset]]
puts "Simulation top: $sim_top"
puts ""

# Adjust signal paths based on simulation top
if {$sim_top == "dual_riscv_axi_system"} {
    puts "Using DUT signals directly..."
    set SIGNAL_PREFIX "/dual_riscv_axi_system"
    set DUT_PREFIX "/dual_riscv_axi_system"
} elseif {$sim_top == "dual_riscv_system_tb"} {
    puts "Using testbench signals..."
    set SIGNAL_PREFIX "/dual_riscv_system_tb"
    set DUT_PREFIX "/dual_riscv_system_tb/dut"
} else {
    puts "WARNING: Unknown simulation top: $sim_top"
    puts "Trying DUT path..."
    set SIGNAL_PREFIX "/dual_riscv_axi_system"
    set DUT_PREFIX "/dual_riscv_axi_system"
}
puts ""

# Clock & Reset
puts "Adding Clock & Reset..."
safe_add_wave ${SIGNAL_PREFIX}/ACLK
safe_add_wave ${SIGNAL_PREFIX}/ARESETN

# GPIO
puts "Adding GPIO..."
safe_add_wave ${SIGNAL_PREFIX}/gpio_out hex
safe_add_wave ${SIGNAL_PREFIX}/gpio_in hex

# UART
puts "Adding UART..."
safe_add_wave ${SIGNAL_PREFIX}/uart_tx_valid
safe_add_wave ${SIGNAL_PREFIX}/uart_tx_byte hex

# SPI
puts "Adding SPI..."
safe_add_wave ${SIGNAL_PREFIX}/spi_cs_n
safe_add_wave ${SIGNAL_PREFIX}/spi_sclk
safe_add_wave ${SIGNAL_PREFIX}/spi_mosi
safe_add_wave ${SIGNAL_PREFIX}/spi_miso

# SERV Core 0 - AXI Read
puts "Adding SERV 0 - Instruction Fetch..."
safe_add_wave ${DUT_PREFIX}/serv0_M0_arvalid
safe_add_wave ${DUT_PREFIX}/serv0_M0_arready
safe_add_wave ${DUT_PREFIX}/serv0_M0_araddr hex
safe_add_wave ${DUT_PREFIX}/serv0_M0_rvalid
safe_add_wave ${DUT_PREFIX}/serv0_M0_rready
safe_add_wave ${DUT_PREFIX}/serv0_M0_rdata hex

# SERV Core 0 - AXI Write
puts "Adding SERV 0 - Data Write..."
safe_add_wave ${DUT_PREFIX}/serv0_M1_awvalid
safe_add_wave ${DUT_PREFIX}/serv0_M1_awready
safe_add_wave ${DUT_PREFIX}/serv0_M1_awaddr hex
safe_add_wave ${DUT_PREFIX}/serv0_M1_wvalid
safe_add_wave ${DUT_PREFIX}/serv0_M1_wready
safe_add_wave ${DUT_PREFIX}/serv0_M1_wdata hex

# SERV Core 1 - AXI Read
puts "Adding SERV 1 - Instruction Fetch..."
safe_add_wave ${DUT_PREFIX}/serv1_M0_arvalid
safe_add_wave ${DUT_PREFIX}/serv1_M0_arready
safe_add_wave ${DUT_PREFIX}/serv1_M0_araddr hex
safe_add_wave ${DUT_PREFIX}/serv1_M0_rvalid
safe_add_wave ${DUT_PREFIX}/serv1_M0_rready
safe_add_wave ${DUT_PREFIX}/serv1_M0_rdata hex

# SERV Core 1 - AXI Write
puts "Adding SERV 1 - Data Write..."
safe_add_wave ${DUT_PREFIX}/serv1_M1_awvalid
safe_add_wave ${DUT_PREFIX}/serv1_M1_awready
safe_add_wave ${DUT_PREFIX}/serv1_M1_awaddr hex
safe_add_wave ${DUT_PREFIX}/serv1_M1_wvalid
safe_add_wave ${DUT_PREFIX}/serv1_M1_wready
safe_add_wave ${DUT_PREFIX}/serv1_M1_wdata hex

# Slave 0 - RAM
puts "Adding Slave 0 - RAM..."
safe_add_wave ${DUT_PREFIX}/S0_arvalid
safe_add_wave ${DUT_PREFIX}/S0_arready
safe_add_wave ${DUT_PREFIX}/S0_araddr hex
safe_add_wave ${DUT_PREFIX}/S0_rvalid
safe_add_wave ${DUT_PREFIX}/S0_rready
safe_add_wave ${DUT_PREFIX}/S0_rdata hex
safe_add_wave ${DUT_PREFIX}/S0_awvalid
safe_add_wave ${DUT_PREFIX}/S0_awready
safe_add_wave ${DUT_PREFIX}/S0_awaddr hex
safe_add_wave ${DUT_PREFIX}/S0_wvalid
safe_add_wave ${DUT_PREFIX}/S0_wready
safe_add_wave ${DUT_PREFIX}/S0_wdata hex

# Slave 1 - GPIO
puts "Adding Slave 1 - GPIO..."
safe_add_wave ${DUT_PREFIX}/S1_awvalid
safe_add_wave ${DUT_PREFIX}/S1_awready
safe_add_wave ${DUT_PREFIX}/S1_awaddr hex
safe_add_wave ${DUT_PREFIX}/S1_wvalid
safe_add_wave ${DUT_PREFIX}/S1_wready
safe_add_wave ${DUT_PREFIX}/S1_wdata hex

# Slave 2 - UART
puts "Adding Slave 2 - UART..."
safe_add_wave ${DUT_PREFIX}/S2_awvalid
safe_add_wave ${DUT_PREFIX}/S2_awready
safe_add_wave ${DUT_PREFIX}/S2_awaddr hex
safe_add_wave ${DUT_PREFIX}/S2_wvalid
safe_add_wave ${DUT_PREFIX}/S2_wready
safe_add_wave ${DUT_PREFIX}/S2_wdata hex

# Slave 3 - SPI
puts "Adding Slave 3 - SPI..."
safe_add_wave ${DUT_PREFIX}/S3_awvalid
safe_add_wave ${DUT_PREFIX}/S3_awready
safe_add_wave ${DUT_PREFIX}/S3_awaddr hex
safe_add_wave ${DUT_PREFIX}/S3_wvalid
safe_add_wave ${DUT_PREFIX}/S3_wready
safe_add_wave ${DUT_PREFIX}/S3_wdata hex

puts ""
puts "============================================================================"
puts "Waveform setup complete!"
puts "============================================================================"
puts ""
puts "Useful commands:"
puts "  run 10us          - Run for 10 microseconds"
puts "  run -all          - Run until finish"
puts "  restart           - Restart simulation"
puts ""
