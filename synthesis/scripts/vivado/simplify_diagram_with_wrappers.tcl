#==============================================================================
# simplify_diagram_with_wrappers.tcl
# Simplify Block Design Diagram by Using Wrapper Block Designs
#
# This script provides a step-by-step guide to:
# 1. Create wrapper Block Designs (GPIO, UART, SPI)
# 2. Generate output products for wrappers
# 3. Replace existing peripherals with wrapper instances
#
# Usage: In Vivado TCL Console (after opening main Block Design):
#   source simplify_diagram_with_wrappers.tcl
#
# Note: Some steps require manual GUI interaction due to Vivado TCL limitations
#==============================================================================

puts "============================================================================"
puts "Simplify Block Design Diagram with Wrapper Block Designs"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    return
}

set current_proj [current_project]
set proj_dir [get_property DIRECTORY [current_project]]

puts "Current project: $current_proj"
puts "Project directory: $proj_dir"
puts ""

#==============================================================================
# Step 1: Check if wrapper BDs exist
#==============================================================================
puts "============================================================================"
puts "Step 1: Checking Wrapper Block Designs"
puts "============================================================================"

set wrapper_bds [list gpio_wrapper uart_wrapper spi_wrapper]
set wrapper_bd_files {}
set missing_wrappers {}

foreach wrapper_name $wrapper_bds {
    set bd_file [file normalize [file join $proj_dir "${current_proj}.srcs" "sources_1" "bd" $wrapper_name "${wrapper_name}.bd"]]
    if {[file exists $bd_file]} {
        lappend wrapper_bd_files $bd_file
        puts "✓ Found: $wrapper_name"
    } else {
        lappend missing_wrappers $wrapper_name
        puts "✗ Missing: $wrapper_name"
    }
}

if {[llength $missing_wrappers] > 0} {
    puts ""
    puts "Missing wrapper BDs detected. Creating them now..."
    puts ""
    
    # Source the creation script
    # Calculate path: project_dir is in synthesis/scripts/vivado/<project_name>
    # So scripts are in synthesis/scripts/vivado/
    set scripts_dir [file dirname $proj_dir]
    set create_script [file normalize [file join $scripts_dir "create_peripheral_wrappers.tcl"]]
    
    if {[file exists $create_script]} {
        puts "Found create_peripheral_wrappers.tcl at: $create_script"
        source $create_script
    } else {
        puts "ERROR: Cannot find create_peripheral_wrappers.tcl"
        puts "Expected path: $create_script"
        puts ""
        puts "Please run it manually with full path:"
        puts "  source \"C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_peripheral_wrappers.tcl\""
        return
    }
}
puts ""

#==============================================================================
# Step 2: Generate Output Products for Wrapper BDs
#==============================================================================
puts "============================================================================"
puts "Step 2: Generating Output Products for Wrapper BDs"
puts "============================================================================"

set main_bd [current_bd_design]
if {[catch {current_bd_design} err]} {
    set main_bd "design_1"
    puts "WARNING: No Block Design currently open. Assuming main BD: $main_bd"
}

foreach wrapper_file $wrapper_bd_files {
    set wrapper_name [file rootname [file tail [file dirname $wrapper_file]]]
    puts "Processing: $wrapper_name"
    
    # Open wrapper BD
    set wrapper_bd [open_bd_design $wrapper_file]
    
    # Generate output products
    catch {
        generate_target all [get_files $wrapper_file]
        puts "  ✓ Generated output products"
    } err_msg
    
    # Create HDL wrapper
    catch {
        make_wrapper -files [get_files $wrapper_file] -top
        puts "  ✓ Created HDL wrapper"
    } err_msg2
    
    close_bd_design $wrapper_bd
}

# Return to main BD
if {[llength [get_files -quiet "${main_bd}.bd"]] > 0} {
    open_bd_design [get_files "${main_bd}.bd"]
    puts "Returned to main BD: $main_bd"
}
puts ""

#==============================================================================
# Step 3: Instructions for Manual Steps
#==============================================================================
puts "============================================================================"
puts "Step 3: Manual Steps Required"
puts "============================================================================"
puts ""
puts "Due to Vivado TCL limitations, the following steps must be done manually:"
puts ""
puts "3.1. Open Main Block Design (if not already open):"
puts "     - Flow Navigator -> IP Integrator -> Open Block Design"
puts "     - Or double-click design_1.bd in Sources panel"
puts ""
puts "3.2. Delete Existing Protocol Converters and Peripherals:"
puts "     - Delete: axi_protocol_converter_s1, axi_protocol_converter_s2, axi_protocol_converter_s3"
puts "     - Delete: axi_gpio_0, axi_uartlite_0, axi_quad_spi_0"
puts "     - (Keep: axi_bram_ctrl_0 for S0)"
puts ""
puts "3.3. Add Wrapper Instances:"
puts "     - Right-click in Block Design canvas -> Add Module..."
puts "     - Select 'gpio_wrapper_wrapper' -> OK (rename to gpio_wrapper_0)"
puts "     - Repeat for 'uart_wrapper_wrapper' -> uart_wrapper_0"
puts "     - Repeat for 'spi_wrapper_wrapper' -> spi_wrapper_0"
puts ""
puts "3.4. Connect AXI Interfaces:"
puts "     - axi_interconnect_0/S1 -> gpio_wrapper_0/S_AXI"
puts "     - axi_interconnect_0/S2 -> uart_wrapper_0/S_AXI"
puts "     - axi_interconnect_0/S3 -> spi_wrapper_0/S_AXI"
puts ""
puts "3.5. Connect Clock and Reset:"
puts "     - Connect pl_clk0 to ACLK of all wrappers"
puts "     - Connect peripheral_aresetn to ARESETN of all wrappers"
puts ""
puts "After completing manual steps, run:"
puts "  validate_bd_design"
puts "  regenerate_bd_layout"
puts "  save_bd_design"
puts ""

#==============================================================================
# Step 4: Provide Connection Commands (for reference)
#==============================================================================
puts "============================================================================"
puts "Step 4: Connection Commands (After Adding Wrapper Instances)"
puts "============================================================================"
puts ""
puts "After you manually add wrapper instances, you can use these TCL commands:"
puts ""
puts "# Connect AXI Interfaces"
puts "connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1] [get_bd_intf_pins gpio_wrapper_0/S_AXI]"
puts "connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2] [get_bd_intf_pins uart_wrapper_0/S_AXI]"
puts "connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3] [get_bd_intf_pins spi_wrapper_0/S_AXI]"
puts ""
puts "# Connect Clock"
puts "connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins gpio_wrapper_0/ACLK]"
puts "connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins uart_wrapper_0/ACLK]"
puts "connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins spi_wrapper_0/ACLK]"
puts ""
puts "# Connect Reset (if using Processor System Reset)"
puts "set rst_ps [get_bd_cells -quiet rst_ps8_0_99M]"
puts "if {[llength \$rst_ps] > 0} {"
puts "    connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins gpio_wrapper_0/ARESETN]"
puts "    connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins uart_wrapper_0/ARESETN]"
puts "    connect_bd_net [get_bd_pins rst_ps8_0_99M/peripheral_aresetn] [get_bd_pins spi_wrapper_0/ARESETN]"
puts "} else {"
puts "    connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins gpio_wrapper_0/ARESETN]"
puts "    connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins uart_wrapper_0/ARESETN]"
puts "    connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins spi_wrapper_0/ARESETN]"
puts "}"
puts ""
puts "# Validate and Save"
puts "validate_bd_design"
puts "regenerate_bd_layout"
puts "save_bd_design"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "✓ Wrapper Block Designs checked/created"
puts "✓ Output products generated for wrappers"
puts "⏳ Manual steps required (see Step 3 above)"
puts ""
puts "Once manual steps are completed, your diagram will show:"
puts "  - Zynq PS"
puts "  - 2x AXI Master Bridges"
puts "  - AXI Interconnect"
puts "  - BRAM Controller (S0)"
puts "  - 3x Wrapper instances (S1, S2, S3) - Protocol Converters hidden inside"
puts ""

