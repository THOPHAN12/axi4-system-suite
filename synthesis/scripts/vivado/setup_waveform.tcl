#==============================================================================
# setup_waveform.tcl
# Setup waveform for dual_riscv_axi_system simulation in Vivado
# Shows only important signals for easy debugging
#==============================================================================

puts "Setting up waveform for dual_riscv_axi_system..."

# Check if simulation is already running
set sim_running [current_sim]
if {$sim_running != ""} {
    puts "Simulation is already running: $sim_running"
    puts "Using existing simulation..."
} else {
    puts "No simulation running. Checking if design needs elaboration..."
    
    # Check if simset exists
    set simset_exists [get_filesets -quiet sim_1]
    if {[llength $simset_exists] == 0} {
        puts "ERROR: Simulation fileset 'sim_1' not found!"
        puts "Please create simulation fileset first."
        return
    }
    
    # Set simulation properties to preserve all signals
    set_property -name {xsim.elaborate.debug_level} -value {all} -objects [get_filesets sim_1]
    set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
    
    puts "Launching simulation with debug options..."
    
    # Try to launch simulation, catch error if already running
    if {[catch {launch_simulation -mode behavioral -type functional -simset sim_1 -name sim_1} err]} {
        puts "Note: $err"
        puts "Trying to use existing simulation..."
        
        # Check again if simulation is now available
        set sim_running [current_sim]
        if {$sim_running == ""} {
            puts "ERROR: Could not launch or find simulation."
            puts "Please try manually:"
            puts "  1. Close existing simulation: close_sim"
            puts "  2. Set properties: set_property -name {xsim.elaborate.debug_level} -value {all} -objects [get_filesets sim_1]"
            puts "  3. Launch: launch_simulation"
            return
        }
    }
    
    # Wait for simulation to initialize
    after 1000
    
    # Check again
    set sim_running [current_sim]
    if {$sim_running == ""} {
        puts "ERROR: Failed to launch simulation."
        puts "Please try manually:"
        puts "  1. Close existing simulation: close_sim"
        puts "  2. Set properties: set_property -name {xsim.elaborate.debug_level} -value {all} -objects [get_filesets sim_1]"
        puts "  3. Launch: launch_simulation"
        return
    }
}

# Final check
set sim_running [current_sim]
if {$sim_running == ""} {
    puts "ERROR: No simulation available. Please launch simulation first."
    return
}

puts "Simulation is ready: $sim_running"
puts "Checking for signals..."
puts ""

# Check simulation top
set sim_top [get_property top [current_fileset -simset]]
puts "Simulation top: $sim_top"
puts ""

# Adjust signal paths based on simulation top
if {$sim_top == "dual_riscv_axi_system"} {
    puts "NOTE: Simulation top is DUT, not testbench."
    puts "Adding signals from DUT directly..."
    set SIGNAL_PREFIX "/dual_riscv_axi_system"
} elseif {$sim_top == "dual_riscv_system_tb"} {
    puts "Simulation top is testbench - using testbench signals..."
    set SIGNAL_PREFIX "/dual_riscv_system_tb"
} else {
    puts "WARNING: Unknown simulation top: $sim_top"
    puts "Trying to use testbench path..."
    set SIGNAL_PREFIX "/dual_riscv_system_tb"
}
puts ""

# Helper function to safely add wave
proc safe_add_wave {signal_path {radix ""}} {
    # Check if signal exists (get_objects doesn't support -radix)
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

#==============================================================================
# Clock & Reset
#==============================================================================
add_wave_divider "Clock & Reset"
safe_add_wave ${SIGNAL_PREFIX}/ACLK
safe_add_wave ${SIGNAL_PREFIX}/ARESETN

#==============================================================================
# GPIO
#==============================================================================
add_wave_divider "GPIO"
safe_add_wave ${SIGNAL_PREFIX}/gpio_out hex
safe_add_wave ${SIGNAL_PREFIX}/gpio_in hex

#==============================================================================
# UART
#==============================================================================
add_wave_divider "UART"
safe_add_wave ${SIGNAL_PREFIX}/uart_tx_valid
safe_add_wave ${SIGNAL_PREFIX}/uart_tx_byte hex

#==============================================================================
# SPI
#==============================================================================
add_wave_divider "SPI"
safe_add_wave ${SIGNAL_PREFIX}/spi_cs_n
safe_add_wave ${SIGNAL_PREFIX}/spi_sclk
safe_add_wave ${SIGNAL_PREFIX}/spi_mosi
safe_add_wave ${SIGNAL_PREFIX}/spi_miso

# Determine DUT path based on top
if {$sim_top == "dual_riscv_axi_system"} {
    set DUT_PREFIX ${SIGNAL_PREFIX}
} else {
    set DUT_PREFIX ${SIGNAL_PREFIX}/dut
}

#==============================================================================
# SERV Core 0 - AXI Read (Instruction Fetch)
#==============================================================================
add_wave_divider "SERV 0 - Instruction Fetch (M0)"
safe_add_wave ${DUT_PREFIX}/serv0_M0_arvalid
safe_add_wave ${DUT_PREFIX}/serv0_M0_arready
safe_add_wave ${DUT_PREFIX}/serv0_M0_araddr hex
safe_add_wave ${DUT_PREFIX}/serv0_M0_rvalid
safe_add_wave ${DUT_PREFIX}/serv0_M0_rready
safe_add_wave ${DUT_PREFIX}/serv0_M0_rdata hex

#==============================================================================
# SERV Core 0 - AXI Write (Data Store)
#==============================================================================
add_wave_divider "SERV 0 - Data Write (M1)"
safe_add_wave ${DUT_PREFIX}/serv0_M1_awvalid
safe_add_wave ${DUT_PREFIX}/serv0_M1_awready
safe_add_wave ${DUT_PREFIX}/serv0_M1_awaddr hex
safe_add_wave ${DUT_PREFIX}/serv0_M1_wvalid
safe_add_wave ${DUT_PREFIX}/serv0_M1_wready
safe_add_wave ${DUT_PREFIX}/serv0_M1_wdata hex

#==============================================================================
# SERV Core 1 - AXI Read (Instruction Fetch)
#==============================================================================
add_wave_divider "SERV 1 - Instruction Fetch (M0)"
safe_add_wave ${DUT_PREFIX}/serv1_M0_arvalid
safe_add_wave ${DUT_PREFIX}/serv1_M0_arready
safe_add_wave ${DUT_PREFIX}/serv1_M0_araddr hex
safe_add_wave ${DUT_PREFIX}/serv1_M0_rvalid
safe_add_wave ${DUT_PREFIX}/serv1_M0_rready
safe_add_wave ${DUT_PREFIX}/serv1_M0_rdata hex

#==============================================================================
# SERV Core 1 - AXI Write (Data Store)
#==============================================================================
add_wave_divider "SERV 1 - Data Write (M1)"
safe_add_wave ${DUT_PREFIX}/serv1_M1_awvalid
safe_add_wave ${DUT_PREFIX}/serv1_M1_awready
safe_add_wave ${DUT_PREFIX}/serv1_M1_awaddr hex
safe_add_wave ${DUT_PREFIX}/serv1_M1_wvalid
safe_add_wave ${DUT_PREFIX}/serv1_M1_wready
safe_add_wave ${DUT_PREFIX}/serv1_M1_wdata hex

#==============================================================================
# AXI Interconnect - Slave 0 (RAM)
#==============================================================================
add_wave_divider "Slave 0 - RAM"
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

#==============================================================================
# AXI Interconnect - Slave 1 (GPIO)
#==============================================================================
add_wave_divider "Slave 1 - GPIO"
safe_add_wave ${DUT_PREFIX}/S1_awvalid
safe_add_wave ${DUT_PREFIX}/S1_awready
safe_add_wave ${DUT_PREFIX}/S1_awaddr hex
safe_add_wave ${DUT_PREFIX}/S1_wvalid
safe_add_wave ${DUT_PREFIX}/S1_wready
safe_add_wave ${DUT_PREFIX}/S1_wdata hex

#==============================================================================
# AXI Interconnect - Slave 2 (UART)
#==============================================================================
add_wave_divider "Slave 2 - UART"
safe_add_wave ${DUT_PREFIX}/S2_awvalid
safe_add_wave ${DUT_PREFIX}/S2_awready
safe_add_wave ${DUT_PREFIX}/S2_awaddr hex
safe_add_wave ${DUT_PREFIX}/S2_wvalid
safe_add_wave ${DUT_PREFIX}/S2_wready
safe_add_wave ${DUT_PREFIX}/S2_wdata hex

#==============================================================================
# AXI Interconnect - Slave 3 (SPI)
#==============================================================================
add_wave_divider "Slave 3 - SPI"
safe_add_wave ${DUT_PREFIX}/S3_awvalid
safe_add_wave ${DUT_PREFIX}/S3_awready
safe_add_wave ${DUT_PREFIX}/S3_awaddr hex
safe_add_wave ${DUT_PREFIX}/S3_wvalid
safe_add_wave ${DUT_PREFIX}/S3_wready
safe_add_wave ${DUT_PREFIX}/S3_wdata hex

# Zoom to fit (Vivado uses different command)
# Note: In Vivado, zoom is done via GUI or using configure_wave_viewer
# The waveform window will auto-fit when signals are added

puts ""
puts "Waveform setup complete!"
puts ""
puts "Useful commands:"
puts "  run 10us          - Run for 10 microseconds"
puts "  run -all          - Run until finish"
puts "  restart           - Restart simulation"
puts ""
puts "Note: Use GUI to zoom waveform (right-click -> Zoom -> Fit)"

