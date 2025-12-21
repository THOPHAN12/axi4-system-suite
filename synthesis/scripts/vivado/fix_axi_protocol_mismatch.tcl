#==============================================================================
# fix_axi_protocol_mismatch.tcl
# Fix AXI Protocol Mismatch between AXI Interconnect and Peripherals
# 
# Problem: AXI Interconnect uses AXI4 Full, but GPIO/UART/SPI use AXI4-Lite
# Solution: Add AXI Protocol Converter to convert AXI4 Full -> AXI4-Lite
#
# Usage: In Vivado TCL Console (after opening Block Design):
#   source fix_axi_protocol_mismatch.tcl
#==============================================================================

puts "============================================================================"
puts "Fix AXI Protocol Mismatch"
puts "============================================================================"
puts ""

# Check if Block Design is open
if {[catch {current_bd_design} err]} {
    puts "ERROR: No Block Design is currently open!"
    puts "Please open Block Design first:"
    puts "  open_bd_design [get_files *.bd]"
    return
}

set bd_design [current_bd_design]
puts "Current Block Design: $bd_design"
puts ""

#==============================================================================
# Step 1: Check for required components
#==============================================================================
puts "============================================================================"
puts "Step 1: Checking Required Components"
puts "============================================================================"

set axi_ic [get_bd_cells -quiet axi_interconnect_0]
if {[llength $axi_ic] == 0} {
    puts "ERROR: AXI Interconnect instance 'axi_interconnect_0' not found!"
    return
}

set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
set rst_ps [get_bd_cells -quiet rst_ps8_0_99M]

if {[llength $zynq_ps] == 0} {
    puts "ERROR: Zynq PS instance not found!"
    return
}

# Determine clock and reset sources
if {[llength $rst_ps] > 0} {
    set clk_source [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    set rst_source [get_bd_pins rst_ps8_0_99M/peripheral_aresetn]
    puts "Using Processor System Reset for reset signals"
} else {
    set clk_source [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
    set rst_source [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]
    puts "Using Zynq PS pl_resetn0 for reset signals"
}

puts "Clock source: $clk_source"
puts "Reset source: $rst_source"
puts ""

# Check for peripherals
set gpio [get_bd_cells -quiet axi_gpio_0]
set uart [get_bd_cells -quiet axi_uartlite_0]
set spi [get_bd_cells -quiet axi_quad_spi_0]
set bram_ctrl [get_bd_cells -quiet axi_bram_ctrl_0]

if {[llength $gpio] == 0} {
    puts "WARNING: axi_gpio_0 not found"
}
if {[llength $uart] == 0} {
    puts "WARNING: axi_uartlite_0 not found"
}
if {[llength $spi] == 0} {
    puts "WARNING: axi_quad_spi_0 not found"
}
if {[llength $bram_ctrl] == 0} {
    puts "WARNING: axi_bram_ctrl_0 not found"
}
puts ""

#==============================================================================
# Step 2: Disconnect existing connections (if any)
#==============================================================================
puts "============================================================================"
puts "Step 2: Disconnecting Existing Connections"
puts "============================================================================"

# Disconnect S1 (GPIO) if connected directly
set s1_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S1]]
if {[llength $s1_net] > 0 && [llength $gpio] > 0} {
    set s1_pins [get_bd_intf_pins -of_objects $s1_net]
    set gpio_pin_found 0
    foreach pin $s1_pins {
        if {[string match "*axi_gpio_0*" $pin]} {
            set gpio_pin_found 1
            break
        }
    }
    if {$gpio_pin_found} {
        delete_bd_objs $s1_net
        puts "Disconnected S1 from GPIO (will reconnect through Protocol Converter)"
    }
}

# Disconnect S2 (UART) if connected directly
set s2_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S2]]
if {[llength $s2_net] > 0 && [llength $uart] > 0} {
    set s2_pins [get_bd_intf_pins -of_objects $s2_net]
    set uart_pin_found 0
    foreach pin $s2_pins {
        if {[string match "*axi_uartlite_0*" $pin]} {
            set uart_pin_found 1
            break
        }
    }
    if {$uart_pin_found} {
        delete_bd_objs $s2_net
        puts "Disconnected S2 from UART (will reconnect through Protocol Converter)"
    }
}

# Disconnect S3 (SPI) if connected directly
set s3_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S3]]
if {[llength $s3_net] > 0 && [llength $spi] > 0} {
    set s3_pins [get_bd_intf_pins -of_objects $s3_net]
    set spi_pin_found 0
    foreach pin $s3_pins {
        if {[string match "*axi_quad_spi_0*" $pin]} {
            set spi_pin_found 1
            break
        }
    }
    if {$spi_pin_found} {
        delete_bd_objs $s3_net
        puts "Disconnected S3 from SPI (will reconnect through Protocol Converter)"
    }
}
puts ""

#==============================================================================
# Step 3: Add AXI Protocol Converters for S1, S2, S3
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding AXI Protocol Converters"
puts "============================================================================"

# Protocol Converter for S1 (GPIO)
set conv_s1 [get_bd_cells -quiet axi_protocol_converter_s1]
if {[llength $conv_s1] == 0 && [llength $gpio] > 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_s1
    set_property -dict [list \
        CONFIG.MI_PROTOCOL {AXI4LITE} \
        CONFIG.SI_PROTOCOL {AXI4} \
        CONFIG.ADDR_WIDTH {32} \
        CONFIG.DATA_WIDTH {32} \
        CONFIG.ID_WIDTH {0} \
        CONFIG.TRANSLATION_MODE {0} \
    ] [get_bd_cells axi_protocol_converter_s1]
    puts "Created AXI Protocol Converter for S1 (GPIO)"
} else {
    puts "Protocol Converter S1 already exists"
}

# Protocol Converter for S2 (UART)
set conv_s2 [get_bd_cells -quiet axi_protocol_converter_s2]
if {[llength $conv_s2] == 0 && [llength $uart] > 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_s2
    set_property -dict [list \
        CONFIG.MI_PROTOCOL {AXI4LITE} \
        CONFIG.SI_PROTOCOL {AXI4} \
        CONFIG.ADDR_WIDTH {32} \
        CONFIG.DATA_WIDTH {32} \
        CONFIG.ID_WIDTH {0} \
        CONFIG.TRANSLATION_MODE {0} \
    ] [get_bd_cells axi_protocol_converter_s2]
    puts "Created AXI Protocol Converter for S2 (UART)"
} else {
    puts "Protocol Converter S2 already exists"
}

# Protocol Converter for S3 (SPI)
set conv_s3 [get_bd_cells -quiet axi_protocol_converter_s3]
if {[llength $conv_s3] == 0 && [llength $spi] > 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_s3
    set_property -dict [list \
        CONFIG.MI_PROTOCOL {AXI4LITE} \
        CONFIG.SI_PROTOCOL {AXI4} \
        CONFIG.ADDR_WIDTH {32} \
        CONFIG.DATA_WIDTH {32} \
        CONFIG.ID_WIDTH {0} \
        CONFIG.TRANSLATION_MODE {0} \
    ] [get_bd_cells axi_protocol_converter_s3]
    puts "Created AXI Protocol Converter for S3 (SPI)"
} else {
    puts "Protocol Converter S3 already exists"
}
puts ""

#==============================================================================
# Step 4: Connect AXI Interfaces through Protocol Converters
#==============================================================================
puts "============================================================================"
puts "Step 4: Connecting AXI Interfaces"
puts "============================================================================"

# S0: AXI Interconnect -> BRAM Controller (direct, both AXI4 Full)
if {[llength $bram_ctrl] > 0} {
    set s0_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S0]]
    if {[llength $s0_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S0] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
        puts "Connected S0: AXI Interconnect -> BRAM Controller (direct)"
    } else {
        puts "S0 already connected"
    }
}

# S1: AXI Interconnect -> Protocol Converter -> GPIO
if {[llength $conv_s1] > 0 && [llength $gpio] > 0} {
    set s1_ic_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S1]]
    if {[llength $s1_ic_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1] [get_bd_intf_pins axi_protocol_converter_s1/S_AXI]
        puts "Connected: AXI Interconnect S1 -> Protocol Converter S1"
    }
    
    set s1_conv_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_protocol_converter_s1/M_AXI]]
    if {[llength $s1_conv_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_s1/M_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
        puts "Connected: Protocol Converter S1 -> GPIO"
    }
}

# S2: AXI Interconnect -> Protocol Converter -> UART
if {[llength $conv_s2] > 0 && [llength $uart] > 0} {
    set s2_ic_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S2]]
    if {[llength $s2_ic_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2] [get_bd_intf_pins axi_protocol_converter_s2/S_AXI]
        puts "Connected: AXI Interconnect S2 -> Protocol Converter S2"
    }
    
    set s2_conv_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_protocol_converter_s2/M_AXI]]
    if {[llength $s2_conv_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_s2/M_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]
        puts "Connected: Protocol Converter S2 -> UART"
    }
}

# S3: AXI Interconnect -> Protocol Converter -> SPI
if {[llength $conv_s3] > 0 && [llength $spi] > 0} {
    set s3_ic_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S3]]
    if {[llength $s3_ic_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3] [get_bd_intf_pins axi_protocol_converter_s3/S_AXI]
        puts "Connected: AXI Interconnect S3 -> Protocol Converter S3"
    }
    
    set s3_conv_net [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_protocol_converter_s3/M_AXI]]
    if {[llength $s3_conv_net] == 0} {
        connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_s3/M_AXI] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
        puts "Connected: Protocol Converter S3 -> SPI"
    }
}
puts ""

#==============================================================================
# Step 5: Connect Clock and Reset to Protocol Converters
#==============================================================================
puts "============================================================================"
puts "Step 5: Connecting Clock and Reset to Protocol Converters"
puts "============================================================================"

set converters [list axi_protocol_converter_s1 axi_protocol_converter_s2 axi_protocol_converter_s3]

foreach conv $converters {
    set conv_cell [get_bd_cells -quiet $conv]
    if {[llength $conv_cell] > 0} {
        # Connect clock
        set aclk_pin [get_bd_pins -quiet $conv/aclk]
        if {[llength $aclk_pin] > 0} {
            set aclk_net [get_bd_nets -quiet -of_objects $aclk_pin]
            if {[llength $aclk_net] == 0} {
                connect_bd_net $clk_source $aclk_pin
                puts "Connected clock to $conv"
            } else {
                puts "Clock already connected to $conv"
            }
        }
        
        # Connect reset
        set aresetn_pin [get_bd_pins -quiet $conv/aresetn]
        if {[llength $aresetn_pin] > 0} {
            set aresetn_net [get_bd_nets -quiet -of_objects $aresetn_pin]
            if {[llength $aresetn_net] == 0} {
                connect_bd_net $rst_source $aresetn_pin
                puts "Connected reset to $conv"
            } else {
                puts "Reset already connected to $conv"
            }
        }
    }
}
puts ""

#==============================================================================
# Step 6: Regenerate Layout and Save
#==============================================================================
puts "============================================================================"
puts "Step 6: Regenerating Layout and Saving"
puts "============================================================================"

regenerate_bd_layout
save_bd_design
puts "Block Design layout regenerated and saved"
puts ""

#==============================================================================
# Step 7: Validate Block Design
#==============================================================================
puts "============================================================================"
puts "Step 7: Validating Block Design"
puts "============================================================================"

validate_bd_design
puts "Block Design validation completed"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "AXI Protocol Converters added and connected:"
puts "  - S0: AXI Interconnect -> BRAM Controller (direct, both AXI4 Full)"
puts "  - S1: AXI Interconnect -> Protocol Converter -> GPIO (AXI4 -> AXI4-Lite)"
puts "  - S2: AXI Interconnect -> Protocol Converter -> UART (AXI4 -> AXI4-Lite)"
puts "  - S3: AXI Interconnect -> Protocol Converter -> SPI (AXI4 -> AXI4-Lite)"
puts ""
puts "Next steps:"
puts "  1. Regenerate Output Products (right-click Block Design)"
puts "  2. Run Synthesis and Implementation"
puts ""

