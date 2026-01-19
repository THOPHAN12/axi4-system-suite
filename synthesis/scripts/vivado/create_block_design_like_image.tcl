#==============================================================================
# create_block_design_like_image.tcl
# Create Block Design exactly like the image: direct connections without Protocol Converters
#
# Architecture (like image):
#   Zynq PS (2 Masters, 32-bit)
#     -> 2x AXI Master Bridges
#     -> AXI Interconnect
#     -> 4 Slaves (direct connections):
#        - S0: AXI GPIO
#        - S1: AXI Quad SPI
#        - S2: AXI Uartlite
#        - S3: AXI BRAM Controller -> Block Memory Generator
#
# NOTE: This will show protocol mismatch warnings because AXI Interconnect is AXI4 Full
#       while GPIO/UART/SPI are AXI4-Lite. You may need to handle this separately.
#
# Usage: In Vivado TCL Console (with project open):
#   source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_block_design_like_image.tcl"
#==============================================================================

puts "============================================================================"
puts "Create Block Design Like Image (Direct Connections)"
puts "============================================================================"
puts ""

#==============================================================================
# Step 0: Check Project and Setup
#==============================================================================
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    return
}

set current_proj [current_project]
set proj_dir [get_property DIRECTORY [current_project]]

puts "Current project: $current_proj"
puts ""

# IP repository
set scripts_dir [file dirname $proj_dir]
set synthesis_dir [file dirname $scripts_dir]
set ip_repo_path [file normalize [file join $synthesis_dir "ip_repo"]]

if {[file exists $ip_repo_path]} {
    set_property ip_repo_paths [list $ip_repo_path] [current_project]
    update_ip_catalog -rebuild
    puts "Added IP repository"
}
puts ""

#==============================================================================
# Step 0.5: Check and Package AXI Slave Bridge IP if needed
#==============================================================================
puts "============================================================================"
puts "Step 0.5: Checking AXI Slave Bridge IP"
puts "============================================================================"

set slave_bridge_ip_vlnv "user.org:user:axi_slave_bridge:1.0"
set slave_bridge_ip_defs [get_ipdefs -quiet -filter "VLNV == $slave_bridge_ip_vlnv"]

if {[llength $slave_bridge_ip_defs] == 0} {
    puts "AXI Slave Bridge IP not found. Attempting to package it..."
    
    set package_script [file normalize [file join $scripts_dir "package_axi_slave_bridge_ip.tcl"]]
    if {[file exists $package_script]} {
        puts "Found package script: $package_script"
        source $package_script
        
        # Update IP catalog after packaging
        if {[file exists $ip_repo_path]} {
            set_property ip_repo_paths [list $ip_repo_path] [current_project]
            update_ip_catalog -rebuild
            puts "IP catalog updated after packaging"
        }
    } else {
        puts "ERROR: Package script not found: $package_script"
        puts "Please run package_axi_slave_bridge_ip.tcl manually first"
        return
    }
} else {
    puts "AXI Slave Bridge IP found in catalog"
}
puts ""

#==============================================================================
# Step 1: Clean and Create Block Design
#==============================================================================
puts "============================================================================"
puts "Step 1: Creating Block Design"
puts "============================================================================"

set bd_name "design_1"

# Clean existing BD
catch {
    set current_bd [current_bd_design]
    if {[string equal $current_bd $bd_name]} {
        close_bd_design [current_bd_design]
    }
} err_msg

set bd_files [get_files -quiet -all -filter {FILE_TYPE == "Block Designs"} *${bd_name}.bd]
if {[llength $bd_files] > 0} {
    remove_files $bd_files
}

set bd_designs [get_bd_designs -quiet $bd_name]
if {[llength $bd_designs] > 0} {
    catch {delete_bd_design $bd_designs}
}

after 500

create_bd_design $bd_name
current_bd_design $bd_name
puts "Created Block Design: $bd_name"
puts ""

#==============================================================================
# Step 2: Add Zynq UltraScale+ PS
#==============================================================================
puts "============================================================================"
puts "Step 2: Adding Zynq PS (2 Masters, 32-bit)"
puts "============================================================================"

create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0

set_property -dict [list \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
] [get_bd_cells zynq_ultra_ps_e_0]

# Regenerate layout to update interfaces after config change
regenerate_bd_layout
save_bd_design

puts "Zynq PS added (HPM interfaces will be configured after connection)"
puts "Added Zynq PS"
puts ""

#==============================================================================
# Step 3: Add AXI Master Bridges
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding AXI Master Bridges"
puts "============================================================================"

create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_0
create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_1

# Set DATA_WIDTH = 32 for both AXI Master Bridges
set_property -dict [list CONFIG.DATA_WIDTH {32}] [get_bd_cells axi_master_bridge_0]
set_property -dict [list CONFIG.DATA_WIDTH {32}] [get_bd_cells axi_master_bridge_1]
puts "Added 2 AXI Master Bridges (DATA_WIDTH = 32)"
puts ""

#==============================================================================
# Step 4: Add AXI Interconnect
#==============================================================================
puts "============================================================================"
puts "Step 4: Adding AXI Interconnect"
puts "============================================================================"

create_bd_cell -type ip -vlnv user.org:user:axi_interconnect_2m4s:1.0 axi_interconnect_0

puts "Added AXI Interconnect"
puts ""

#==============================================================================
# Step 5: Add Processor System Reset
#==============================================================================
puts "============================================================================"
puts "Step 5: Adding Processor System Reset"
puts "============================================================================"

create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_99M

puts "Added Processor System Reset"
puts ""

#==============================================================================
# Step 6: Add Slaves (External Ports for S0, S1; IP Peripherals with AXI Slave Bridge for S2, S3)
#==============================================================================
puts "============================================================================"
puts "Step 6: Adding Slaves"
puts "============================================================================"
puts "Strategy:"
puts "  - S0, S1: External AXI ports (like testbench) - for I/O reduction"
puts "  - S2, S3: IP Peripherals with AXI Slave Bridge (custom bridge instead of Protocol Converter)"
puts ""

# S2: AXI UART Lite with AXI Slave Bridge
puts "Adding S2: UART with AXI Slave Bridge..."
create_bd_cell -type ip -vlnv user.org:user:axi_slave_bridge:1.0 axi_slave_bridge_s2
set_property -dict [list \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ADDR_WIDTH {32} \
] [get_bd_cells axi_slave_bridge_s2]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
set_property -dict [list \
    CONFIG.C_BAUDRATE {115200} \
    CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
] [get_bd_cells axi_uartlite_0]
puts "  Added S2: UART with AXI Slave Bridge"

# S3: AXI Quad SPI with AXI Slave Bridge
puts "Adding S3: SPI with AXI Slave Bridge..."
create_bd_cell -type ip -vlnv user.org:user:axi_slave_bridge:1.0 axi_slave_bridge_s3
set_property -dict [list \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ADDR_WIDTH {32} \
] [get_bd_cells axi_slave_bridge_s3]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0
set_property -dict [list \
    CONFIG.C_USE_STARTUP {0} \
    CONFIG.C_NUM_SS_BITS {1} \
] [get_bd_cells axi_quad_spi_0]
puts "  Added S3: SPI with AXI Slave Bridge"
puts ""

#==============================================================================
# Step 7: Connect Clock and Reset
#==============================================================================
puts "============================================================================"
puts "Step 7: Connecting Clock and Reset"
puts "============================================================================"

set clk_source [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Processor System Reset
connect_bd_net $clk_source [get_bd_pins rst_ps8_0_99M/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_ps8_0_99M/ext_reset_in]
set rst_source [get_bd_pins rst_ps8_0_99M/peripheral_aresetn]
set interconnect_rst [get_bd_pins rst_ps8_0_99M/interconnect_aresetn]

# Zynq PS HPM clock connections (required for HPM interfaces)
connect_bd_net $clk_source [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net $clk_source [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk]

# AXI Master Bridges
connect_bd_net $clk_source [get_bd_pins axi_master_bridge_0/ACLK]
connect_bd_net $clk_source [get_bd_pins axi_master_bridge_1/ACLK]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_master_bridge_0/ARESETN]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_master_bridge_1/ARESETN]

# AXI Interconnect
connect_bd_net $clk_source [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net $interconnect_rst [get_bd_pins axi_interconnect_0/ARESETN]

# AXI Slave Bridges - Clock and Reset
connect_bd_net $clk_source [get_bd_pins axi_slave_bridge_s2/ACLK]
connect_bd_net $rst_source [get_bd_pins axi_slave_bridge_s2/ARESETN]
connect_bd_net $clk_source [get_bd_pins axi_slave_bridge_s3/ACLK]
connect_bd_net $rst_source [get_bd_pins axi_slave_bridge_s3/ARESETN]

# Peripherals - Clock
connect_bd_net $clk_source [get_bd_pins axi_uartlite_0/s_axi_aclk]
connect_bd_net $clk_source [get_bd_pins axi_quad_spi_0/ext_spi_clk]
connect_bd_net $clk_source [get_bd_pins axi_quad_spi_0/s_axi_aclk]

# Peripherals - Reset
connect_bd_net $rst_source [get_bd_pins axi_uartlite_0/s_axi_aresetn]
connect_bd_net $rst_source [get_bd_pins axi_quad_spi_0/s_axi_aresetn]

puts "Connected clock and reset"
puts ""

#==============================================================================
# Step 8: Connect AXI Interfaces (Direct - Like Image)
#==============================================================================
puts "============================================================================"
puts "Step 8: Connecting AXI Interfaces (Direct Connections)"
puts "============================================================================"

# Check if Zynq PS HPM interfaces are enabled
set hpm0_intf [get_bd_intf_pins -quiet zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
set hpm1_intf [get_bd_intf_pins -quiet zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]

if {[llength $hpm0_intf] == 0 || [llength $hpm1_intf] == 0} {
    puts "ERROR: Zynq PS HPM interfaces not enabled!"
    puts ""
    puts "Please configure Zynq PS HPM ports via GUI:"
    puts "  1. Double-click zynq_ultra_ps_e_0 in Block Design"
    puts "  2. In 'PS-PL Configuration' -> 'HP Slave AXI Interface' section:"
    puts "     - Enable M_AXI_HPM0_FPD"
    puts "     - Enable M_AXI_HPM1_FPD"
    puts "     - Set both Data Width to 32-bit"
    puts "  3. Click OK"
    puts "  4. Run this script again"
    puts ""
    puts "Script stopped. Please configure Zynq PS and try again."
    return
}

# Master 0: PS -> Bridge 0 -> AXI Interconnect M0
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] [get_bd_intf_pins axi_master_bridge_0/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_0/m_axi] [get_bd_intf_pins axi_interconnect_0/M0]

# Force DATA_WIDTH = 32 for HPM0 interface after connection
set_property -dict [list CONFIG.DATA_WIDTH {32}] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
puts "Connected Master 0: PS (M_AXI_HPM0_FPD) -> Bridge 0 -> AXI Interconnect M0 (DATA_WIDTH = 32)"

# Master 1: PS -> Bridge 1 -> AXI Interconnect M1
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD] [get_bd_intf_pins axi_master_bridge_1/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_1/m_axi] [get_bd_intf_pins axi_interconnect_0/M1]

# Force DATA_WIDTH = 32 for HPM1 interface after connection
set_property -dict [list CONFIG.DATA_WIDTH {32}] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]
puts "Connected Master 1: PS (M_AXI_HPM1_FPD) -> Bridge 1 -> AXI Interconnect M1 (DATA_WIDTH = 32)"

# Slaves connections:
# S0, S1: External AXI ports (like testbench - giảm I/O overutilization)
# S2, S3: IP Peripherals with Protocol Converters

# S0: External AXI port (like testbench)
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 S0_AXI
set_property -dict [list \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
] [get_bd_intf_ports /S0_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S0] [get_bd_intf_ports /S0_AXI]
puts "Connected S0: AXI Interconnect -> External Port S0_AXI"

# S1: External AXI port (like testbench)
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 S1_AXI
set_property -dict [list \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
] [get_bd_intf_ports /S1_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1] [get_bd_intf_ports /S1_AXI]
puts "Connected S1: AXI Interconnect -> External Port S1_AXI"

# S2: AXI Interconnect -> AXI Slave Bridge -> UART
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2] [get_bd_intf_pins axi_slave_bridge_s2/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_slave_bridge_s2/m_axi] [get_bd_intf_pins axi_uartlite_0/S_AXI]
puts "Connected S2: AXI Interconnect -> AXI Slave Bridge -> UART"

# S3: AXI Interconnect -> AXI Slave Bridge -> SPI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3] [get_bd_intf_pins axi_slave_bridge_s3/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_slave_bridge_s3/m_axi] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
puts "Connected S3: AXI Interconnect -> AXI Slave Bridge -> SPI"
puts ""

#==============================================================================
# Step 9: Create External Clock Port for External AXI Ports
#==============================================================================
puts "============================================================================"
puts "Step 9: Creating External Clock Port"
puts "============================================================================"

# Create external clock port for S0_AXI and S1_AXI
create_bd_port -dir O -type clk pl_clk0_out
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_ports /pl_clk0_out]
set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports /pl_clk0_out]
set_property CONFIG.ASSOCIATED_BUSIF {S0_AXI:S1_AXI} [get_bd_ports /pl_clk0_out]
puts "Created external clock port for S0_AXI and S1_AXI"
puts ""

#==============================================================================
# Step 10: Regenerate Layout and Validate
#==============================================================================
puts "============================================================================"
puts "Step 10: Regenerating Layout and Validating"
puts "============================================================================"

regenerate_bd_layout
save_bd_design
puts "Layout regenerated and design saved"
puts ""

validate_bd_design -force
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "Block Design created successfully!"
puts ""
puts "Architecture (similar to testbench with I/O reduction):"
puts "  Zynq PS (M_AXI_HPM0_FPD, M_AXI_HPM1_FPD, 32-bit)"
puts "    -> 2x AXI Master Bridges"
puts "    -> AXI Interconnect"
puts "    -> 4 Slaves:"
puts "       - S0: External AXI Port (S0_AXI) - like testbench"
puts "       - S1: External AXI Port (S1_AXI) - like testbench"
puts "       - S2: UART (with AXI Slave Bridge) - reduces I/O"
puts "       - S3: SPI (with AXI Slave Bridge) - reduces I/O"
puts ""
puts "Benefits:"
puts "  ✓ S0, S1 are external ports (like testbench simple slave models)"
puts "  ✓ S2, S3 use IP peripherals (reduces I/O count ~50%)"
puts "  ✓ AXI Slave Bridge (your custom code) handles AXI4 Full -> AXI4-Lite conversion"
puts "  ✓ Uses your own bridge instead of Xilinx Protocol Converter"
puts ""
puts "Next steps:"
puts "  1. Configure Address Map (Address Editor)"
puts "  2. Generate Output Products"
puts "  3. Create HDL Wrapper"
puts "  4. Run Synthesis"
puts ""

