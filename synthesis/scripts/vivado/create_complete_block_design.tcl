#==============================================================================
# create_complete_block_design.tcl
# Create Complete Block Design for KV260 - 2M.4S System with Wrappers
#
# This script creates the entire Block Design from scratch:
# - Zynq PS
# - 2x AXI Master Bridges
# - AXI Interconnect (Custom IP)
# - BRAM Controller (S0)
# - GPIO/UART/SPI Wrappers (S1, S2, S3) - with Protocol Converters inside
# - Processor System Reset
# - All connections
#
# Usage: In Vivado TCL Console (with project open):
#   source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_complete_block_design.tcl"
#==============================================================================

puts "============================================================================"
puts "Create Complete Block Design for KV260 - 2M.4S System"
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

# Calculate IP repository path (ip_repo is at synthesis/ip_repo, not synthesis/scripts/ip_repo)
set scripts_dir [file dirname $proj_dir]
set synthesis_dir [file dirname $scripts_dir]
set ip_repo_path [file normalize [file join $synthesis_dir "ip_repo"]]
puts "IP repository path: $ip_repo_path"
puts ""

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
# Step 1: Create/Open Block Design
#==============================================================================
puts "============================================================================"
puts "Step 1: Creating Block Design"
puts "============================================================================"

set bd_name "design_1"
set bd_file [file normalize [file join $proj_dir "${current_proj}.srcs" "sources_1" "bd" $bd_name "${bd_name}.bd"]]

# Check if BD exists and delete it properly
puts "Checking for existing Block Design..."

# First, try to close if open
catch {
    set current_bd [current_bd_design]
    if {[string equal $current_bd $bd_name]} {
        close_bd_design [current_bd_design]
        puts "Closed current Block Design"
    }
} err_msg

# Get BD files from project
set bd_files [get_files -quiet -all -filter {FILE_TYPE == "Block Designs"} *${bd_name}.bd]

if {[llength $bd_files] > 0} {
    puts "Found existing Block Design files in project. Removing from project..."
    remove_files [get_files -quiet -all -filter {FILE_TYPE == "Block Designs"} *${bd_name}.bd]
    puts "Removed BD files from project"
}

# Delete BD design if it exists
set bd_designs [get_bd_designs -quiet $bd_name]
if {[llength $bd_designs] > 0} {
    puts "Found existing Block Design. Deleting..."
    catch {
        delete_bd_design $bd_designs
        puts "Deleted Block Design: $bd_name"
    } err_msg2
    if {[string length $err_msg2] > 0} {
        puts "Warning: $err_msg2"
    }
}

# Also delete directory if it exists
if {[file exists [file dirname $bd_file]]} {
    catch {
        file delete -force [file dirname $bd_file]
        puts "Deleted Block Design directory"
    } err_msg3
}

# Wait a bit for cleanup to complete
after 500

# Create new Block Design
create_bd_design $bd_name
puts "Created new Block Design: $bd_name"

current_bd_design $bd_name
puts ""

#==============================================================================
# Step 2: Add Zynq UltraScale+ PS
#==============================================================================
puts "============================================================================"
puts "Step 2: Adding Zynq UltraScale+ PS"
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
] [get_bd_cells zynq_ultra_ps_e_0]

# Configure AXI HPM Data Width to 32-bit
set_property -dict [list \
    CONFIG.PSU__SAXIGP0__DATA_WIDTH {32} \
    CONFIG.PSU__SAXIGP2__DATA_WIDTH {32} \
] [get_bd_cells zynq_ultra_ps_e_0]

puts "Added and configured Zynq PS"
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
# Step 6: Add BRAM Controller (S0)
#==============================================================================
puts "============================================================================"
puts "Step 6: Adding BRAM Controller (S0)"
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
# Step 7: Create Wrapper Block Designs for GPIO, UART, SPI
#==============================================================================
puts "============================================================================"
puts "Step 7: Creating Wrapper Block Designs"
puts "============================================================================"

# Source the wrapper creation script
set create_wrapper_script [file normalize [file join $scripts_dir "create_peripheral_wrappers.tcl"]]

if {[file exists $create_wrapper_script]} {
    puts "Creating wrapper Block Designs..."
    source $create_wrapper_script
    puts "Wrapper Block Designs created"
} else {
    puts "WARNING: Cannot find create_peripheral_wrappers.tcl"
    puts "Please create wrapper BDs manually or run the script separately"
    puts "Continuing without wrappers..."
}
puts ""

#==============================================================================
# Step 8: Generate Output Products for Wrapper BDs
#==============================================================================
puts "============================================================================"
puts "Step 8: Generating Output Products for Wrapper BDs"
puts "============================================================================"

set wrapper_names [list gpio_wrapper uart_wrapper spi_wrapper]

foreach wrapper_name $wrapper_names {
    set wrapper_bd_file [file normalize [file join $proj_dir "${current_proj}.srcs" "sources_1" "bd" $wrapper_name "${wrapper_name}.bd"]]
    
    if {[file exists $wrapper_bd_file]} {
        puts "Processing: $wrapper_name"
        
        # Open wrapper BD
        set wrapper_bd [open_bd_design $wrapper_bd_file]
        
        # Generate output products
        catch {
            generate_target all [get_files $wrapper_bd_file]
            puts "  Generated output products"
        } err_msg
        
        # Create HDL wrapper
        catch {
            make_wrapper -files [get_files $wrapper_bd_file] -top
            puts "  Created HDL wrapper"
        } err_msg2
        
        close_bd_design $wrapper_bd
    }
}

# Return to main BD
current_bd_design $bd_name
puts ""

#==============================================================================
# Step 9: Add Wrapper Instances (if wrappers were created)
#==============================================================================
puts "============================================================================"
puts "Step 9: Adding Wrapper Instances"
puts "============================================================================"

# Note: Adding BD as module reference requires the BD to be generated
# We'll try to add them, but user may need to add via GUI if this fails

set wrappers_added 0

foreach wrapper_name $wrapper_names {
    set wrapper_bd_file [file normalize [file join $proj_dir "${current_proj}.srcs" "sources_1" "bd" $wrapper_name "${wrapper_name}.bd"]]
    set wrapper_instance_name "${wrapper_name}_0"
    
    if {[file exists $wrapper_bd_file]} {
        # Try to get the generated wrapper module
        set wrapper_module "${wrapper_name}_wrapper"
        
        # Check if wrapper module exists in project
        set wrapper_files [get_files -quiet "*${wrapper_module}.v"]
        
        if {[llength $wrapper_files] > 0} {
            # Try to create module reference
            catch {
                # Note: This might not work perfectly - user may need to add via GUI
                # create_bd_cell -type module -reference $wrapper_module $wrapper_instance_name
                puts "  $wrapper_name: Wrapper module found (add manually via GUI: Add Module -> $wrapper_module)"
            } err_msg
            incr wrappers_added
        } else {
            puts "  $wrapper_name: Wrapper module not generated yet"
        }
    }
}

if {$wrappers_added == 0} {
    puts ""
    puts "NOTE: Wrapper instances need to be added manually via GUI:"
    puts "  1. Right-click in Block Design -> Add Module..."
    puts "  2. Select gpio_wrapper_wrapper -> OK (rename to gpio_wrapper_0)"
    puts "  3. Repeat for uart_wrapper_wrapper and spi_wrapper_wrapper"
    puts ""
}
puts ""

#==============================================================================
# Step 10: Connect Clock and Reset
#==============================================================================
puts "============================================================================"
puts "Step 10: Connecting Clock and Reset"
puts "============================================================================"

set clk_source [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]

# Connect clock to Processor System Reset
connect_bd_net $clk_source [get_bd_pins rst_ps8_0_99M/slowest_sync_clk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins rst_ps8_0_99M/ext_reset_in]

# Connect clock to AXI Master Bridges
connect_bd_net $clk_source [get_bd_pins axi_master_bridge_0/ACLK]
connect_bd_net $clk_source [get_bd_pins axi_master_bridge_1/ACLK]

# Connect clock to AXI Interconnect
connect_bd_net $clk_source [get_bd_pins axi_interconnect_0/ACLK]

# Connect clock to BRAM Controller
connect_bd_net $clk_source [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
connect_bd_net $clk_source [get_bd_pins blk_mem_gen_0/clka]
connect_bd_net $clk_source [get_bd_pins blk_mem_gen_0/clkb]

# Connect reset (from Processor System Reset)
set rst_source [get_bd_pins rst_ps8_0_99M/peripheral_aresetn]
connect_bd_net $rst_source [get_bd_pins axi_master_bridge_0/ARESETN]
connect_bd_net $rst_source [get_bd_pins axi_master_bridge_1/ARESETN]
connect_bd_net $rst_source [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net $rst_source [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]

# Connect clock to Zynq PS HPM AXI clocks
connect_bd_net $clk_source [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_fpd_aclk]
connect_bd_net $clk_source [get_bd_pins zynq_ultra_ps_e_0/maxihpm1_fpd_aclk]

puts "Connected clock and reset"
puts ""

#==============================================================================
# Step 11: Connect AXI Interfaces
#==============================================================================
puts "============================================================================"
puts "Step 11: Connecting AXI Interfaces"
puts "============================================================================"

# Master 0: PS -> Bridge 0 -> AXI Interconnect M0
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] [get_bd_intf_pins axi_master_bridge_0/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_0/m_axi] [get_bd_intf_pins axi_interconnect_0/M0]
puts "Connected Master 0: PS -> Bridge 0 -> AXI Interconnect M0"

# Master 1: PS -> Bridge 1 -> AXI Interconnect M1
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD] [get_bd_intf_pins axi_master_bridge_1/s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_1/m_axi] [get_bd_intf_pins axi_interconnect_0/M1]
puts "Connected Master 1: PS -> Bridge 1 -> AXI Interconnect M1"

# S0: AXI Interconnect -> BRAM Controller
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S0] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
puts "Connected S0: AXI Interconnect -> BRAM Controller"

# S1, S2, S3: Will be connected after adding wrapper instances
puts ""
puts "NOTE: Connect S1, S2, S3 after adding wrapper instances:"
puts "  - axi_interconnect_0/S1 -> gpio_wrapper_0/S_AXI"
puts "  - axi_interconnect_0/S2 -> uart_wrapper_0/S_AXI"
puts "  - axi_interconnect_0/S3 -> spi_wrapper_0/S_AXI"
puts ""

#==============================================================================
# Step 12: Exclude Address Segments (for Bridge and Interconnect internal segments)
#==============================================================================
puts "============================================================================"
puts "Step 12: Configuring Address Map"
puts "============================================================================"

puts "Address map configuration will be done after validation"
puts ""

#==============================================================================
# Step 13: Regenerate Layout and Validate
#==============================================================================
puts "============================================================================"
puts "Step 13: Regenerating Layout and Validating"
puts "============================================================================"

regenerate_bd_layout
save_bd_design

puts "Layout regenerated and design saved"
puts ""

# Validate (will show warnings for missing S1, S2, S3 connections - expected)
validate_bd_design -force
puts ""

#==============================================================================
# Step 14: Instructions for Manual Steps
#==============================================================================
puts "============================================================================"
puts "Step 14: Manual Steps Required"
puts "============================================================================"
puts ""
puts "1. Add Wrapper Instances (if not added automatically):"
puts "   - Right-click in Block Design -> Add Module..."
puts "   - Select 'gpio_wrapper_wrapper' -> OK (rename to gpio_wrapper_0)"
puts "   - Repeat for 'uart_wrapper_wrapper' -> uart_wrapper_0"
puts "   - Repeat for 'spi_wrapper_wrapper' -> spi_wrapper_0"
puts ""
puts "2. Connect Wrapper Instances:"
puts "   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1] [get_bd_intf_pins gpio_wrapper_0/S_AXI]"
puts "   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2] [get_bd_intf_pins uart_wrapper_0/S_AXI]"
puts "   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3] [get_bd_intf_pins spi_wrapper_0/S_AXI]"
puts ""
puts "   connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins gpio_wrapper_0/ACLK]"
puts "   connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins uart_wrapper_0/ACLK]"
puts "   connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins spi_wrapper_0/ACLK]"
puts ""
puts "   connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins gpio_wrapper_0/ARESETN]"
puts "   connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins uart_wrapper_0/ARESETN]"
puts "   connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins spi_wrapper_0/ARESETN]"
puts ""
puts "3. Configure Address Map:"
puts "   - Open Address Editor tab"
puts "   - Exclude internal segments (bridge, interconnect M0/M1)"
puts "   - Assign addresses to S0, S1, S2, S3"
puts ""
puts "4. Validate and Generate Output Products:"
puts "   validate_bd_design"
puts "   generate_target all [get_files design_1.bd]"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "Block Design created with:"
puts "  ✓ Zynq PS"
puts "  ✓ 2x AXI Master Bridges"
puts "  ✓ AXI Interconnect"
puts "  ✓ Processor System Reset"
puts "  ✓ BRAM Controller (S0)"
puts "  ⏳ Wrapper instances (need to add manually)"
puts ""
puts "Next: Complete manual steps above, then run synthesis"
puts ""

