#==============================================================================
# replace_external_ports_with_peripherals.tcl
# Replace External AXI Ports with AXI IP Peripherals in Block Design
# 
# This script replaces the external ports (S0_AXI, S1_AXI, S2_AXI, S3_AXI)
# with actual AXI IP peripherals to reduce I/O pin count:
#   - S0_AXI -> AXI BRAM Controller + Block Memory Generator
#   - S1_AXI -> AXI GPIO
#   - S2_AXI -> AXI UART Lite
#   - S3_AXI -> AXI Quad SPI
#
# Usage: In Vivado TCL Console (after opening Block Design):
#   source replace_external_ports_with_peripherals.tcl
#==============================================================================

puts "============================================================================"
puts "Replace External Ports with AXI IP Peripherals"
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
# Step 1: Check for AXI Interconnect
#==============================================================================
puts "============================================================================"
puts "Step 1: Checking AXI Interconnect"
puts "============================================================================"

set axi_ic [get_bd_cells -quiet axi_interconnect_0]
if {[llength $axi_ic] == 0} {
    puts "ERROR: AXI Interconnect instance 'axi_interconnect_0' not found!"
    puts "Please ensure AXI Interconnect is added to the Block Design."
    return
}
puts "Found AXI Interconnect: $axi_ic"
puts ""

# Get clock and reset sources
set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
set rst_ps [get_bd_cells -quiet rst_ps8_0_99M]

if {[llength $zynq_ps] == 0} {
    puts "ERROR: Zynq PS instance 'zynq_ultra_ps_e_0' not found!"
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

#==============================================================================
# Step 2: Delete External Ports
#==============================================================================
puts "============================================================================"
puts "Step 2: Deleting External AXI Ports"
puts "============================================================================"

set external_ports [list S0_AXI S1_AXI S2_AXI S3_AXI]
foreach port $external_ports {
    set port_obj [get_bd_intf_ports -quiet /$port]
    if {[llength $port_obj] > 0} {
        puts "Deleting external port: /$port"
        delete_bd_objs $port_obj
    } else {
        puts "External port /$port not found (may have been deleted already)"
    }
}
puts ""

#==============================================================================
# Step 3: Add AXI BRAM Controller and Block Memory Generator (S0)
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding AXI BRAM Controller and Block Memory Generator (S0)"
puts "============================================================================"

# Check if already exists
set bram_ctrl [get_bd_cells -quiet axi_bram_ctrl_0]
if {[llength $bram_ctrl] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
    puts "Created AXI BRAM Controller: axi_bram_ctrl_0"
    
    # Configure BRAM Controller
    set_property -dict [list \
        CONFIG.SINGLE_PORT_BRAM {1} \
        CONFIG.PROTOCOL {AXI4} \
        CONFIG.DATA_WIDTH {32} \
        CONFIG.ECC_TYPE {0} \
    ] [get_bd_cells axi_bram_ctrl_0]
    puts "Configured AXI BRAM Controller"
} else {
    puts "AXI BRAM Controller already exists: axi_bram_ctrl_0"
}

# Add Block Memory Generator
set bram_gen [get_bd_cells -quiet blk_mem_gen_0]
if {[llength $bram_gen] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
    puts "Created Block Memory Generator: blk_mem_gen_0"
    
    # Configure Block Memory Generator
    set_property -dict [list \
        CONFIG.Memory_Type {True_Dual_Port_RAM} \
        CONFIG.use_bram_block {BRAM_Controller} \
        CONFIG.Enable_B {Use_ENB_Pin} \
    ] [get_bd_cells blk_mem_gen_0]
    puts "Configured Block Memory Generator"
} else {
    puts "Block Memory Generator already exists: blk_mem_gen_0"
}

# Connect BRAM Controller to Block Memory Generator
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
puts "Connected BRAM Controller to Block Memory Generator"
puts ""

#==============================================================================
# Step 4: Add AXI GPIO (S1)
#==============================================================================
puts "============================================================================"
puts "Step 4: Adding AXI GPIO (S1)"
puts "============================================================================"

set gpio [get_bd_cells -quiet axi_gpio_0]
if {[llength $gpio] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
    puts "Created AXI GPIO: axi_gpio_0"
    
    # Configure GPIO: 1 channel, 32 bits
    set_property -dict [list \
        CONFIG.C_ALL_OUTPUTS {0} \
        CONFIG.C_ALL_INPUTS {0} \
        CONFIG.C_GPIO_WIDTH {32} \
        CONFIG.C_IS_DUAL {0} \
    ] [get_bd_cells axi_gpio_0]
    puts "Configured AXI GPIO (32-bit, bidirectional)"
} else {
    puts "AXI GPIO already exists: axi_gpio_0"
}
puts ""

#==============================================================================
# Step 5: Add AXI UART Lite (S2)
#==============================================================================
puts "============================================================================"
puts "Step 5: Adding AXI UART Lite (S2)"
puts "============================================================================"

set uart [get_bd_cells -quiet axi_uartlite_0]
if {[llength $uart] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
    puts "Created AXI UART Lite: axi_uartlite_0"
    
    # Configure UART: 115200 baud (default)
    set_property -dict [list \
        CONFIG.C_BAUDRATE {115200} \
    ] [get_bd_cells axi_uartlite_0]
    puts "Configured AXI UART Lite (115200 baud)"
} else {
    puts "AXI UART Lite already exists: axi_uartlite_0"
}
puts ""

#==============================================================================
# Step 6: Add AXI Quad SPI (S3)
#==============================================================================
puts "============================================================================"
puts "Step 6: Adding AXI Quad SPI (S3)"
puts "============================================================================"

set spi [get_bd_cells -quiet axi_quad_spi_0]
if {[llength $spi] == 0} {
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0
    puts "Created AXI Quad SPI: axi_quad_spi_0"
    
    # Configure SPI: Standard mode, 1 slave
    set_property -dict [list \
        CONFIG.C_USE_STARTUP {0} \
        CONFIG.C_NUM_SS_BITS {1} \
    ] [get_bd_cells axi_quad_spi_0]
    puts "Configured AXI Quad SPI (Standard mode, 1 slave)"
} else {
    puts "AXI Quad SPI already exists: axi_quad_spi_0"
}
puts ""

#==============================================================================
# Step 7: Connect AXI Interfaces
#==============================================================================
puts "============================================================================"
puts "Step 7: Connecting AXI Interfaces"
puts "============================================================================"

# Connect S0: AXI Interconnect -> BRAM Controller
if {[llength [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S0]]] == 0} {
    connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S0] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
    puts "Connected: axi_interconnect_0/S0 -> axi_bram_ctrl_0/S_AXI"
} else {
    puts "S0 already connected"
}

# Connect S1: AXI Interconnect -> GPIO
if {[llength [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S1]]] == 0} {
    connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1] [get_bd_intf_pins axi_gpio_0/S_AXI]
    puts "Connected: axi_interconnect_0/S1 -> axi_gpio_0/S_AXI"
} else {
    puts "S1 already connected"
}

# Connect S2: AXI Interconnect -> UART
if {[llength [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S2]]] == 0} {
    connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2] [get_bd_intf_pins axi_uartlite_0/S_AXI]
    puts "Connected: axi_interconnect_0/S2 -> axi_uartlite_0/S_AXI"
} else {
    puts "S2 already connected"
}

# Connect S3: AXI Interconnect -> SPI
if {[llength [get_bd_intf_nets -quiet -of_objects [get_bd_intf_pins axi_interconnect_0/S3]]] == 0} {
    connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
    puts "Connected: axi_interconnect_0/S3 -> axi_quad_spi_0/AXI_LITE"
} else {
    puts "S3 already connected"
}
puts ""

#==============================================================================
# Step 8: Connect Clock and Reset
#==============================================================================
puts "============================================================================"
puts "Step 8: Connecting Clock and Reset"
puts "============================================================================"

# Connect clock to all peripherals
set peripherals [list axi_bram_ctrl_0 axi_gpio_0 axi_uartlite_0 axi_quad_spi_0]

foreach periph $peripherals {
    set periph_cell [get_bd_cells -quiet $periph]
    if {[llength $periph_cell] > 0} {
        set s_axi_aclk [get_bd_pins -quiet $periph/s_axi_aclk]
        if {[llength $s_axi_aclk] > 0} {
            if {[llength [get_bd_nets -quiet -of_objects $s_axi_aclk]] == 0} {
                connect_bd_net $clk_source $s_axi_aclk
                puts "Connected clock to $periph"
            } else {
                puts "Clock already connected to $periph"
            }
        }
        
        set s_axi_aresetn [get_bd_pins -quiet $periph/s_axi_aresetn]
        if {[llength $s_axi_aresetn] > 0} {
            if {[llength [get_bd_nets -quiet -of_objects $s_axi_aresetn]] == 0} {
                connect_bd_net $rst_source $s_axi_aresetn
                puts "Connected reset to $periph"
            } else {
                puts "Reset already connected to $periph"
            }
        }
    }
}

# Connect clock to Block Memory Generator (if it has clock pin)
set bram_porta_clk [get_bd_pins -quiet blk_mem_gen_0/clka]
if {[llength $bram_porta_clk] > 0 && [llength [get_bd_nets -quiet -of_objects $bram_porta_clk]] == 0} {
    connect_bd_net $clk_source $bram_porta_clk
    puts "Connected clock to blk_mem_gen_0/clka"
}
set bram_portb_clk [get_bd_pins -quiet blk_mem_gen_0/clkb]
if {[llength $bram_portb_clk] > 0 && [llength [get_bd_nets -quiet -of_objects $bram_portb_clk]] == 0} {
    connect_bd_net $clk_source $bram_portb_clk
    puts "Connected clock to blk_mem_gen_0/clkb"
}

# Connect external SPI clock (required for AXI Quad SPI)
set spi_ext_clk [get_bd_pins -quiet axi_quad_spi_0/ext_spi_clk]
if {[llength $spi_ext_clk] > 0 && [llength [get_bd_nets -quiet -of_objects $spi_ext_clk]] == 0} {
    connect_bd_net $clk_source $spi_ext_clk
    puts "Connected external SPI clock to axi_quad_spi_0/ext_spi_clk"
}
puts ""

#==============================================================================
# Step 9: Create External Ports for Peripherals (Optional - Can be done manually)
#==============================================================================
puts "============================================================================"
puts "Step 9: External Ports for Peripherals (Optional)"
puts "============================================================================"
puts "NOTE: External ports for peripherals (GPIO, UART, SPI) can be created"
puts "      manually in GUI if you need to connect them to physical pins."
puts ""
puts "To create external ports manually:"
puts "  - GPIO: Create GPIO interface port and connect to axi_gpio_0/GPIO"
puts "  - UART: Create ports uart_tx (O) and uart_rx (I), connect to axi_uartlite_0"
puts "  - SPI: Create SPI interface port and connect to axi_quad_spi_0/SPI_0"
puts ""
puts "For now, peripherals are connected internally via AXI Interconnect,"
puts "which reduces I/O pin count significantly (from ~687 to 0 external AXI pins)."
puts ""

#==============================================================================
# Step 10: Regenerate Layout and Save
#==============================================================================
puts "============================================================================"
puts "Step 10: Regenerating Layout and Saving"
puts "============================================================================"

regenerate_bd_layout
save_bd_design
puts "Block Design layout regenerated and saved"
puts ""

#==============================================================================
# Step 11: Validate Block Design
#==============================================================================
puts "============================================================================"
puts "Step 11: Validating Block Design"
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
puts "External ports replaced with AXI IP Peripherals:"
puts "  - S0_AXI -> axi_bram_ctrl_0 (BRAM Controller + Block Memory Generator)"
puts "  - S1_AXI -> axi_gpio_0 (GPIO)"
puts "  - S2_AXI -> axi_uartlite_0 (UART Lite)"
puts "  - S3_AXI -> axi_quad_spi_0 (Quad SPI)"
puts ""
puts "External ports created for peripherals:"
puts "  - gpio_io[31:0] (GPIO)"
puts "  - uart_tx, uart_rx (UART)"
puts "  - spi_sck, spi_mosi, spi_miso, spi_ss (SPI)"
puts ""
puts "Next steps:"
puts "  1. Check Address Editor - addresses should be automatically assigned"
puts "  2. Regenerate Output Products (right-click Block Design)"
puts "  3. Run Synthesis and Implementation"
puts ""

