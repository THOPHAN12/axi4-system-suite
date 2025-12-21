#==============================================================================
# package_axi_slave_bridge_ip.tcl
# Package AXI Slave Bridge as Vivado IP
#
# This script packages the axi_slave_bridge.sv module as a Vivado IP.
# The IP will be available in IP Catalog with VLNV: user.org:user:axi_slave_bridge:1.0
#
# Usage: In Vivado TCL Console (with or without project open):
#   source package_axi_slave_bridge_ip.tcl
#==============================================================================

puts "============================================================================"
puts "Package AXI Slave Bridge as Vivado IP"
puts "============================================================================"
puts ""

# Get script directory and calculate paths
if {[info script] != ""} {
    set SCRIPT_DIR [file dirname [file normalize [info script]]]
} else {
    set SCRIPT_DIR [pwd]
}

set PROJECT_ROOT [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]
set IP_REPO_DIR [file normalize [file join $PROJECT_ROOT "synthesis" "ip_repo"]]
set IP_NAME "axi_slave_bridge"
set IP_DIR [file normalize [file join $IP_REPO_DIR $IP_NAME]]
set AXI_BRIDGE_DIR [file normalize [file join $PROJECT_ROOT "SystemVerilog" "axi_bridge"]]

puts "Script directory: $SCRIPT_DIR"
puts "Project root: $PROJECT_ROOT"
puts "IP repository: $IP_REPO_DIR"
puts "IP directory: $IP_DIR"
puts "AXI Bridge directory: $AXI_BRIDGE_DIR"
puts ""

#==============================================================================
# Step 1: Clean up existing IP directory
#==============================================================================
if {[file exists $IP_DIR]} {
    puts "Removing existing IP directory: $IP_DIR"
    file delete -force $IP_DIR
}

# Create IP directory
file mkdir $IP_DIR
puts "Created IP directory: $IP_DIR"
puts ""

#==============================================================================
# Step 2: Check/Create Project for IP Packaging
#==============================================================================
set use_existing_project 0

if {![catch {current_project} err]} {
    set current_proj [current_project]
    set current_proj_part [get_property PART [current_project]]
    
    puts "Current project: $current_proj"
    puts "Current project part: $current_proj_part"
    
    # Check if part is compatible (xczu5ev for KV260)
    if {[string match "xczu5ev*" $current_proj_part]} {
        puts "Using existing project for IP packaging"
        set use_existing_project 1
    } else {
        puts "Current project part ($current_proj_part) not compatible with KV260"
        puts "Will create temporary project"
    }
} else {
    puts "No project currently open"
}

if {!$use_existing_project} {
    puts "Creating temporary project for IP packaging..."
    set temp_proj_name "temp_ip_packaging"
    set temp_proj_dir [file normalize [file join $SCRIPT_DIR $temp_proj_name]]
    
    if {[file exists $temp_proj_dir]} {
        file delete -force $temp_proj_dir
    }
    
    create_project $temp_proj_name $temp_proj_dir -part xczu5ev-sfvc784-1-e -force
    puts "Created temporary project: $temp_proj_name"
}
puts ""

#==============================================================================
# Step 3: Add AXI Slave Bridge Source File
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding AXI Slave Bridge Source File"
puts "============================================================================"

set bridge_file [file normalize [file join $AXI_BRIDGE_DIR "axi_slave_bridge.sv"]]

if {![file exists $bridge_file]} {
    puts "ERROR: AXI Slave Bridge file not found: $bridge_file"
    if {!$use_existing_project} {
        close_project
    }
    return
}

add_files -norecurse [list $bridge_file]
set_property file_type {SystemVerilog} [get_files [list $bridge_file]]
set_property top axi_slave_bridge [current_fileset]

puts "Added AXI Slave Bridge source file"
puts ""

#==============================================================================
# Step 4: Update Compile Order
#==============================================================================
update_compile_order -fileset sources_1
puts "Updated compile order"
puts ""

#==============================================================================
# Step 5: Package IP
#==============================================================================
puts "============================================================================"
puts "Step 5: Packaging IP"
puts "============================================================================"

set ip_vendor "user.org"
set ip_library "user"
set ip_version "1.0"
set ip_description "AXI Slave Bridge - Converts AXI4 Full to AXI4-Lite"

ipx::package_project -root_dir $IP_DIR \
    -vendor $ip_vendor \
    -library $ip_library \
    -name $IP_NAME \
    -import_files \
    -taxonomy "/UserIP"

puts "IP packaged successfully"
puts ""

#==============================================================================
# Step 6: Configure IP Properties
#==============================================================================
puts "============================================================================"
puts "Step 6: Configuring IP Properties"
puts "============================================================================"

set ip_def [ipx::current_core]
set_property description $ip_description $ip_def

# Add parameters
ipx::add_user_parameter DATA_WIDTH $ip_def
set_property value_resolve_type {user} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]
set_property value {32} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]
set_property value_format {long} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]
set_property value_validation_type {range_long} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]
set_property value_validation_range_minimum {8} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]
set_property value_validation_range_maximum {1024} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]
set_property description {Data width of AXI interface} [ipx::get_user_parameters DATA_WIDTH -of_objects $ip_def]

ipx::add_user_parameter ADDR_WIDTH $ip_def
set_property value_resolve_type {user} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]
set_property value {32} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]
set_property value_format {long} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]
set_property value_validation_type {range_long} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]
set_property value_validation_range_minimum {12} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]
set_property value_validation_range_maximum {64} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]
set_property description {Address width of AXI interface} [ipx::get_user_parameters ADDR_WIDTH -of_objects $ip_def]

puts "IP parameters configured"
puts ""

#==============================================================================
# Step 7: Update Interfaces (if auto-detected)
#==============================================================================
puts "============================================================================"
puts "Step 7: Updating Interfaces"
puts "============================================================================"

# Interfaces should be auto-detected by Vivado
# We can optionally update display names and descriptions

set slave_intf [ipx::get_bus_interfaces -of_objects $ip_def -filter {NAME =~ "*s_axi*"}]
if {[llength $slave_intf] > 0} {
    set_property display_name {S_AXI} [lindex $slave_intf 0]
    puts "  Found slave interface: [lindex $slave_intf 0]"
}

set master_intf [ipx::get_bus_interfaces -of_objects $ip_def -filter {NAME =~ "*m_axi*"}]
if {[llength $master_intf] > 0} {
    set_property display_name {M_AXI} [lindex $master_intf 0]
    puts "  Found master interface: [lindex $master_intf 0]"
}

puts "Interfaces updated (or auto-detected)"
puts ""

#==============================================================================
# Step 8: Save IP
#==============================================================================
puts "============================================================================"
puts "Step 8: Saving IP"
puts "============================================================================"

ipx::save_core [ipx::current_core]
puts "IP saved successfully"
puts ""

#==============================================================================
# Step 9: Cleanup
#==============================================================================
puts "============================================================================"
puts "Step 9: Cleanup"
puts "============================================================================"

if {!$use_existing_project} {
    close_project
    file delete -force $temp_proj_dir
    puts "Temporary project deleted"
} else {
    puts "Keeping current project open (not closing)"
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "AXI Slave Bridge IP packaged successfully!"
puts ""
puts "IP Details:"
puts "  - VLNV: ${ip_vendor}:${ip_library}:${IP_NAME}:${ip_version}"
puts "  - Location: $IP_DIR"
puts "  - Description: $ip_description"
puts ""
puts "Next steps:"
puts "  1. Add IP repository to your project (if not already done):"
puts "     set_property ip_repo_paths [list $IP_REPO_DIR] [current_project]"
puts "     update_ip_catalog -rebuild"
puts ""
puts "  2. Use the IP in Block Design:"
puts "     create_bd_cell -type ip -vlnv ${ip_vendor}:${ip_library}:${IP_NAME}:${ip_version} <instance_name>"
puts ""

