#==============================================================================
# create_peripheral_wrappers.tcl
# Create Wrapper Block Designs for Peripherals (GPIO, UART, SPI)
#
# This script creates nested Block Designs that wrap Protocol Converter + Peripheral
# into a single IP that appears as one block in the main Block Design.
#
# Each wrapper BD will have:
#   - AXI4 Full interface (input) - to connect to AXI Interconnect
#   - Protocol Converter (AXI4 -> AXI4-Lite)
#   - Peripheral (GPIO/UART/SPI) - AXI4-Lite
#   - Clock and Reset ports
#
# Usage: In Vivado TCL Console (after opening main Block Design project):
#   source create_peripheral_wrappers.tcl
#==============================================================================

puts "============================================================================"
puts "Create Peripheral Wrapper Block Designs"
puts "============================================================================"
puts ""

# Get current project and directory
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open a project first."
    return
}

set current_proj [current_project]
set proj_dir [get_property DIRECTORY [current_project]]
set proj_name [get_property NAME [current_project]]

puts "Current project: $proj_name"
puts "Project directory: $proj_dir"
puts ""

#==============================================================================
# Function: Create Wrapper Block Design for a Peripheral
#==============================================================================
proc create_peripheral_wrapper_bd {wrapper_name peripheral_type peripheral_vlnv peripheral_instance} {
    global proj_dir proj_name
    
    puts "============================================================================"
    puts "Creating wrapper: $wrapper_name"
    puts "============================================================================"
    
    # Check if wrapper BD already exists
    set bd_path [file normalize [file join $proj_dir "${proj_name}.srcs" "sources_1" "bd" $wrapper_name "${wrapper_name}.bd"]]
    
    if {[file exists $bd_path]} {
        puts "WARNING: Block Design '$wrapper_name' already exists!"
        puts "Skipping creation..."
        puts ""
        return
    }
    
    # Create wrapper Block Design
    create_bd_design $wrapper_name
    current_bd_design $wrapper_name
    puts "Created wrapper Block Design: $wrapper_name"
    
    #==============================================================================
    # Step 1: Create External AXI4 Full Interface Port (input from AXI Interconnect)
    #==============================================================================
    create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI
    set_property -dict [list \
        CONFIG.PROTOCOL {AXI4} \
        CONFIG.ADDR_WIDTH {32} \
        CONFIG.DATA_WIDTH {32} \
    ] [get_bd_intf_ports /S_AXI]
    puts "Created external AXI4 Full interface port: S_AXI"
    
    #==============================================================================
    # Step 2: Create External Clock and Reset Ports
    #==============================================================================
    create_bd_port -dir I -type clk ACLK
    set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports /ACLK]
    create_bd_port -dir I -type rst ARESETN
    set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports /ARESETN]
    puts "Created external clock and reset ports"
    
    #==============================================================================
    # Step 3: Add AXI Protocol Converter
    #==============================================================================
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_0
    set_property -dict [list \
        CONFIG.MI_PROTOCOL {AXI4LITE} \
        CONFIG.SI_PROTOCOL {AXI4} \
        CONFIG.ADDR_WIDTH {32} \
        CONFIG.DATA_WIDTH {32} \
        CONFIG.ID_WIDTH {0} \
        CONFIG.TRANSLATION_MODE {0} \
    ] [get_bd_cells axi_protocol_converter_0]
    puts "Added AXI Protocol Converter"
    
    #==============================================================================
    # Step 4: Add Peripheral IP
    #==============================================================================
    create_bd_cell -type ip -vlnv $peripheral_vlnv $peripheral_instance
    puts "Added peripheral: $peripheral_instance"
    
    # Configure peripheral based on type
    if {$peripheral_type == "GPIO"} {
        set_property -dict [list \
            CONFIG.C_ALL_INPUTS {0} \
            CONFIG.C_ALL_OUTPUTS {0} \
            CONFIG.C_GPIO_WIDTH {32} \
            CONFIG.C_IS_DUAL {0} \
        ] [get_bd_cells $peripheral_instance]
    } elseif {$peripheral_type == "UART"} {
        set_property -dict [list \
            CONFIG.C_BAUDRATE {115200} \
            CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
        ] [get_bd_cells $peripheral_instance]
    } elseif {$peripheral_type == "SPI"} {
        set_property -dict [list \
            CONFIG.C_USE_STARTUP {0} \
            CONFIG.C_NUM_SS_BITS {1} \
        ] [get_bd_cells $peripheral_instance]
    }
    
    #==============================================================================
    # Step 5: Connect Interfaces
    #==============================================================================
    # Connect external AXI4 -> Protocol Converter
    connect_bd_intf_net [get_bd_intf_ports /S_AXI] [get_bd_intf_pins axi_protocol_converter_0/S_AXI]
    puts "Connected: S_AXI -> Protocol Converter"
    
    # Connect Protocol Converter -> Peripheral
    if {$peripheral_type == "SPI"} {
        # SPI uses AXI_LITE interface name
        connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_0/M_AXI] [get_bd_intf_pins $peripheral_instance/AXI_LITE]
    } else {
        connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_0/M_AXI] [get_bd_intf_pins $peripheral_instance/S_AXI]
    }
    puts "Connected: Protocol Converter -> Peripheral"
    
    #==============================================================================
    # Step 6: Connect Clock and Reset
    #==============================================================================
    # Connect to Protocol Converter
    connect_bd_net [get_bd_ports /ACLK] [get_bd_pins axi_protocol_converter_0/aclk]
    connect_bd_net [get_bd_ports /ARESETN] [get_bd_pins axi_protocol_converter_0/aresetn]
    
    # Connect to Peripheral
    if {$peripheral_type == "SPI"} {
        connect_bd_net [get_bd_ports /ACLK] [get_bd_pins $peripheral_instance/ext_spi_clk]
        connect_bd_net [get_bd_ports /ACLK] [get_bd_pins $peripheral_instance/s_axi_aclk]
    } else {
        connect_bd_net [get_bd_ports /ACLK] [get_bd_pins $peripheral_instance/s_axi_aclk]
    }
    connect_bd_net [get_bd_ports /ARESETN] [get_bd_pins $peripheral_instance/s_axi_aresetn]
    
    puts "Connected clock and reset"
    
    #==============================================================================
    # Step 7: Create External Ports for Peripheral Signals (if needed)
    #==============================================================================
    if {$peripheral_type == "GPIO"} {
        # GPIO external ports
        create_bd_port -dir I -from 31 -to 0 gpio_io_i
        create_bd_port -dir O -from 31 -to 0 gpio_io_o
        create_bd_port -dir O -from 31 -to 0 gpio_io_t
        connect_bd_net [get_bd_ports /gpio_io_i] [get_bd_pins $peripheral_instance/gpio_io_i]
        connect_bd_net [get_bd_ports /gpio_io_o] [get_bd_pins $peripheral_instance/gpio_io_o]
        connect_bd_net [get_bd_ports /gpio_io_t] [get_bd_pins $peripheral_instance/gpio_io_t]
        puts "Created GPIO external ports"
    } elseif {$peripheral_type == "UART"} {
        # UART external ports
        create_bd_port -dir O tx
        create_bd_port -dir I rx
        connect_bd_net [get_bd_ports /tx] [get_bd_pins $peripheral_instance/tx]
        connect_bd_net [get_bd_ports /rx] [get_bd_pins $peripheral_instance/rx]
        puts "Created UART external ports"
    } elseif {$peripheral_type == "SPI"} {
        # SPI external ports
        create_bd_port -dir O -from 0 -to 0 io0_i
        create_bd_port -dir I -from 0 -to 0 io0_o
        create_bd_port -dir O -from 0 -to 0 io0_t
        create_bd_port -dir O -from 0 -to 0 io1_i
        create_bd_port -dir I -from 0 -to 0 io1_o
        create_bd_port -dir O -from 0 -to 0 io1_t
        create_bd_port -dir O -from 0 -to 0 sck_o
        create_bd_port -dir I -from 0 -to 0 sck_t
        create_bd_port -dir O -from 0 -to 0 ss_o
        create_bd_port -dir I -from 0 -to 0 ss_t
        
        connect_bd_net [get_bd_ports /io0_i] [get_bd_pins $peripheral_instance/io0_i]
        connect_bd_net [get_bd_ports /io0_o] [get_bd_pins $peripheral_instance/io0_o]
        connect_bd_net [get_bd_ports /io0_t] [get_bd_pins $peripheral_instance/io0_t]
        connect_bd_net [get_bd_ports /io1_i] [get_bd_pins $peripheral_instance/io1_i]
        connect_bd_net [get_bd_ports /io1_o] [get_bd_pins $peripheral_instance/io1_o]
        connect_bd_net [get_bd_ports /io1_t] [get_bd_pins $peripheral_instance/io1_t]
        connect_bd_net [get_bd_ports /sck_o] [get_bd_pins $peripheral_instance/sck_o]
        connect_bd_net [get_bd_ports /sck_t] [get_bd_pins $peripheral_instance/sck_t]
        connect_bd_net [get_bd_ports /ss_o] [get_bd_pins $peripheral_instance/ss_o]
        connect_bd_net [get_bd_ports /ss_t] [get_bd_pins $peripheral_instance/ss_t]
        puts "Created SPI external ports"
    }
    
    #==============================================================================
    # Step 8: Validate and Save
    #==============================================================================
    validate_bd_design
    save_bd_design
    puts "Validated and saved wrapper Block Design: $wrapper_name"
    puts ""
}

#==============================================================================
# Create all three wrapper Block Designs
#==============================================================================

# GPIO Wrapper
create_peripheral_wrapper_bd \
    "gpio_wrapper" \
    "GPIO" \
    "xilinx.com:ip:axi_gpio:2.0" \
    "axi_gpio_0"

# UART Wrapper  
create_peripheral_wrapper_bd \
    "uart_wrapper" \
    "UART" \
    "xilinx.com:ip:axi_uartlite:2.0" \
    "axi_uartlite_0"

# SPI Wrapper
create_peripheral_wrapper_bd \
    "spi_wrapper" \
    "SPI" \
    "xilinx.com:ip:axi_quad_spi:3.2" \
    "axi_quad_spi_0"

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "Created wrapper Block Designs:"
puts "  1. gpio_wrapper - GPIO with Protocol Converter"
puts "  2. uart_wrapper - UART with Protocol Converter"
puts "  3. spi_wrapper - SPI with Protocol Converter"
puts ""
puts "Next steps:"
puts "  1. Generate Output Products for each wrapper BD"
puts "  2. Use script 'replace_peripherals_with_wrappers.tcl' to replace"
puts "     existing peripherals with wrapper instances in main Block Design"
puts ""
















