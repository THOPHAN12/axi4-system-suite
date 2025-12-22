#==============================================================================
# create_simple_block_design.tcl
# Create Simple Block Design for KV260 - 2M.4S System
#
# Architecture:
#   Zynq PS (2 Masters, 32-bit) 
#     -> 2x AXI Master Bridges
#     -> AXI Interconnect (Custom IP)
#     -> 4 Slaves:
#        - S0: BRAM Controller (AXI4 Full, direct)
#        - S1: GPIO (AXI4-Lite, via Protocol Converter)
#        - S2: UART (AXI4-Lite, via Protocol Converter)
#        - S3: SPI (AXI4-Lite, via Protocol Converter)
#
# Usage: In Vivado TCL Console (with project open):
#   source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_simple_block_design.tcl"
#==============================================================================

puts "============================================================================"
puts "Create Simple Block Design for KV260 - 2M.4S System"
puts "============================================================================"
puts ""

#==============================================================================
# Step 0: Check Project and Setup
#==============================================================================
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open a project first."
    return
}

set current_proj [current_project]
set proj_dir [get_property DIRECTORY [current_project]]

puts "Current project: $current_proj"
puts "Project directory: $proj_dir"
puts ""

# Calculate IP repository path
set scripts_dir [file dirname $proj_dir]
set synthesis_dir [file dirname $scripts_dir]
set ip_repo_path [file normalize [file join $synthesis_dir "ip_repo"]]
puts "IP repository path: $ip_repo_path"

# Add IP repository
if {[file exists $ip_repo_path]} {
    set_property ip_repo_paths [list $ip_repo_path] [current_project]
    update_ip_catalog -rebuild
    puts "Added IP repository"
} else {
    puts "WARNING: IP repository not found at: $ip_repo_path"
}
puts ""

#==============================================================================
# Step 1: Clean and Create Block Design
#==============================================================================
puts "============================================================================"
puts "Step 1: Creating Block Design"
puts "============================================================================"

set bd_name "design_1"
set bd_file [file normalize [file join $proj_dir "${current_proj}.srcs" "sources_1" "bd" $bd_name "${bd_name}.bd"]]

# Clean existing BD
puts "Cleaning existing Block Design..."
catch {
    set current_bd [current_bd_design]
    if {[string equal $current_bd $bd_name]} {
        close_bd_design [current_bd_design]
        puts "Closed current Block Design"
    }
} err_msg

set bd_files [get_files -quiet -all -filter {FILE_TYPE == "Block Designs"} *${bd_name}.bd]
if {[llength $bd_files] > 0} {
    remove_files $bd_files
    puts "Removed BD files from project"
}

set bd_designs [get_bd_designs -quiet $bd_name]
if {[llength $bd_designs] > 0} {
    catch {
        delete_bd_design $bd_designs
        puts "Deleted BD design"
    } err_msg2
}

after 500

# Create new Block Design
create_bd_design $bd_name
current_bd_design $bd_name
puts "Created Block Design: $bd_name"
puts ""

#==============================================================================
# Step 2: Add Zynq UltraScale+ PS
#==============================================================================
puts "============================================================================"
puts "Step 2: Adding Zynq UltraScale+ PS (2 Masters, 32-bit)"
puts "============================================================================"

create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0

set_property -dict [list \
    CONFIG.PSU__USE__M_AXI_GP0 {0} \
    CONFIG.PSU__USE__M_AXI_GP1 {0} \
    CONFIG.PSU__USE__M_AXI_GP2 {0} \
    CONFIG.PSU__USE__S_AXI_GP0 {0} \
    CONFIG.PSU__USE__S_AXI_GP1 {0} \
    CONFIG.PSU__USE__S_AXI_GP2 {0} \
    CONFIG.PSU__USE__S_AXI_GP3 {0} \
    CONFIG.PSU__USE__S_AXI_GP4 {0} \
    CONFIG.PSU__USE__S_AXI_GP5 {0} \
    CONFIG.PSU__USE__S_AXI_GP6 {0} \
    CONFIG.PSU__USE__M_AXI_HPM0_FPD {1} \
    CONFIG.PSU__USE__M_AXI_HPM1_FPD {1} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__SAXIGP0__DATA_WIDTH {32} \
    CONFIG.PSU__SAXIGP2__DATA_WIDTH {32} \
] [get_bd_cells zynq_ultra_ps_e_0]

puts "Added Zynq PS with 2 AXI Masters (HPM0, HPM1), 32-bit width"
puts ""

#==============================================================================
# Step 3: Add AXI Master Bridges
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding AXI Master Bridges"
puts "============================================================================"

create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_0
create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_1

puts "Added 2 AXI Master Bridges"
puts ""

#==============================================================================
# Step 4: Add AXI Interconnect IP
#==============================================================================
puts "============================================================================"
puts "Step 4: Adding AXI Interconnect IP"
puts "============================================================================"

create_bd_cell -type ip -vlnv user.org:user:axi_interconnect_2m4s:1.0 axi_interconnect_0

puts "Added AXI Interconnect IP"
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
# Step 6: Add Slaves - BRAM Controller (S0)
#==============================================================================
puts "============================================================================"
puts "Step 6: Adding Slaves - BRAM Controller (S0)"
puts "============================================================================"

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
set_property -dict [list \
    CONFIG.PROTOCOL {AXI4} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.SINGLE_PORT_BRAM {1} \
] [get_bd_cells axi_bram_ctrl_0]

create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.use_bram_block {BRAM_Controller} \
] [get_bd_cells blk_mem_gen_0]

connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]

puts "Added BRAM Controller and Block Memory Generator"
puts ""

#==============================================================================
# Step 7: Add Slaves - GPIO, UART, SPI with Protocol Converters
#==============================================================================
puts "============================================================================"
puts "Step 7: Adding Slaves - GPIO, UART, SPI (with Protocol Converters)"
puts "============================================================================"

# Protocol Converter for GPIO (S1)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_s1
set_property -dict [list \
    CONFIG.MI_PROTOCOL {AXI4LITE} \
    CONFIG.SI_PROTOCOL {AXI4} \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ID_WIDTH {0} \
] [get_bd_cells axi_protocol_converter_s1]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0
set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_OUTPUTS {0} \
    CONFIG.C_GPIO_WIDTH {32} \
] [get_bd_cells axi_gpio_0]

puts "Added GPIO with Protocol Converter"

# Protocol Converter for UART (S2)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_s2
set_property -dict [list \
    CONFIG.MI_PROTOCOL {AXI4LITE} \
    CONFIG.SI_PROTOCOL {AXI4} \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ID_WIDTH {0} \
] [get_bd_cells axi_protocol_converter_s2]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0
set_property -dict [list \
    CONFIG.C_BAUDRATE {115200} \
    CONFIG.C_S_AXI_ACLK_FREQ_HZ {100000000} \
] [get_bd_cells axi_uartlite_0]

puts "Added UART with Protocol Converter"

# Protocol Converter for SPI (S3)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_converter:2.1 axi_protocol_converter_s3
set_property -dict [list \
    CONFIG.MI_PROTOCOL {AXI4LITE} \
    CONFIG.SI_PROTOCOL {AXI4} \
    CONFIG.ADDR_WIDTH {32} \
    CONFIG.DATA_WIDTH {32} \
    CONFIG.ID_WIDTH {0} \
] [get_bd_cells axi_protocol_converter_s3]

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0
set_property -dict [list \
    CONFIG.C_USE_STARTUP {0} \
    CONFIG.C_NUM_SS_BITS {1} \
] [get_bd_cells axi_quad_spi_0]

puts "Added SPI with Protocol Converter"
puts ""

#==============================================================================
# Step 8: Connect Clock and Reset
#==============================================================================
puts "============================================================================"
puts "Step 8: Connecting Clock and Reset"
puts "============================================================================"

set clk_source [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Processor System Reset
connect_bd_net $clk_source [get_bd_pins rst_ps8_0_99M/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_ps8_0_99M/ext_reset_in]
set rst_source [get_bd_pins rst_ps8_0_99M/peripheral_aresetn]

# Zynq PS HPM clocks
connect_bd_net $clk_source [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net $clk_source [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk]

# AXI Master Bridges
connect_bd_net $clk_source [get_bd_pins axi_master_bridge_0/ACLK]
connect_bd_net $clk_source [get_bd_pins axi_master_bridge_1/ACLK]
connect_bd_net $rst_source [get_bd_pins axi_master_bridge_0/ARESETN]
connect_bd_net $rst_source [get_bd_pins axi_master_bridge_1/ARESETN]

# AXI Interconnect
connect_bd_net $clk_source [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net $rst_source [get_bd_pins axi_interconnect_0/ARESETN]

# BRAM Controller
connect_bd_net $clk_source [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
connect_bd_net $rst_source [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
connect_bd_net $clk_source [get_bd_pins blk_mem_gen_0/clka]
connect_bd_net $clk_source [get_bd_pins blk_mem_gen_0/clkb]

# Protocol Converters
connect_bd_net $clk_source [get_bd_pins axi_protocol_converter_s1/aclk]
connect_bd_net $rst_source [get_bd_pins axi_protocol_converter_s1/aresetn]
connect_bd_net $clk_source [get_bd_pins axi_protocol_converter_s2/aclk]
connect_bd_net $rst_source [get_bd_pins axi_protocol_converter_s2/aresetn]
connect_bd_net $clk_source [get_bd_pins axi_protocol_converter_s3/aclk]
connect_bd_net $rst_source [get_bd_pins axi_protocol_converter_s3/aresetn]

# Peripherals
connect_bd_net $clk_source [get_bd_pins axi_gpio_0/s_axi_aclk]
connect_bd_net $rst_source [get_bd_pins axi_gpio_0/s_axi_aresetn]
connect_bd_net $clk_source [get_bd_pins axi_uartlite_0/s_axi_aclk]
connect_bd_net $rst_source [get_bd_pins axi_uartlite_0/s_axi_aresetn]
connect_bd_net $clk_source [get_bd_pins axi_quad_spi_0/ext_spi_clk]
connect_bd_net $clk_source [get_bd_pins axi_quad_spi_0/s_axi_aclk]
connect_bd_net $rst_source [get_bd_pins axi_quad_spi_0/s_axi_aresetn]

puts "Connected clock and reset"
puts ""

#==============================================================================
# Step 9: Connect AXI Interfaces
#==============================================================================
puts "============================================================================"
puts "Step 9: Connecting AXI Interfaces"
puts "============================================================================"

# Master 0: PS -> Bridge 0 -> AXI Interconnect M0
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] [get_bd_intf_pins axi_master_bridge_0/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_0/m_axi] [get_bd_intf_pins axi_interconnect_0/M0]
puts "Connected Master 0: PS -> Bridge 0 -> AXI Interconnect M0"

# Master 1: PS -> Bridge 1 -> AXI Interconnect M1
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD] [get_bd_intf_pins axi_master_bridge_1/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_1/m_axi] [get_bd_intf_pins axi_interconnect_0/M1]
puts "Connected Master 1: PS -> Bridge 1 -> AXI Interconnect M1"

# S0: AXI Interconnect -> BRAM Controller (direct)
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S0] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
puts "Connected S0: AXI Interconnect -> BRAM Controller"

# S1: AXI Interconnect -> Protocol Converter -> GPIO
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1] [get_bd_intf_pins axi_protocol_converter_s1/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_s1/M_AXI] [get_bd_intf_pins axi_gpio_0/S_AXI]
puts "Connected S1: AXI Interconnect -> Protocol Converter -> GPIO"

# S2: AXI Interconnect -> Protocol Converter -> UART
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2] [get_bd_intf_pins axi_protocol_converter_s2/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_s2/M_AXI] [get_bd_intf_pins axi_uartlite_0/S_AXI]
puts "Connected S2: AXI Interconnect -> Protocol Converter -> UART"

# S3: AXI Interconnect -> Protocol Converter -> SPI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3] [get_bd_intf_pins axi_protocol_converter_s3/S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_protocol_converter_s3/M_AXI] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]
puts "Connected S3: AXI Interconnect -> Protocol Converter -> SPI"
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

validate_bd_design
puts "Validation completed"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "Block Design created successfully!"
puts ""
puts "Architecture:"
puts "  Zynq PS (2 Masters, 32-bit)"
puts "    -> 2x AXI Master Bridges"
puts "    -> AXI Interconnect (Custom IP)"
puts "    -> 4 Slaves:"
puts "       - S0: BRAM Controller (direct, AXI4 Full)"
puts "       - S1: GPIO (via Protocol Converter)"
puts "       - S2: UART (via Protocol Converter)"
puts "       - S3: SPI (via Protocol Converter)"
puts ""
puts "Next steps:"
puts "  1. Configure Address Map (Address Editor)"
puts "  2. Generate Output Products"
puts "  3. Create HDL Wrapper"
puts "  4. Run Synthesis"
puts ""











