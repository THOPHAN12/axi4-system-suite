#==============================================================================
# package_axi_interconnect_ip.tcl
# Package AXI Interconnect as Vivado IP
# Target: Xilinx Kria KV260 Vision AI Starter Kit
# Device: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
#
# Usage: In Vivado TCL Console:
#   source package_axi_interconnect_ip.tcl
#==============================================================================

puts "============================================================================"
puts "Package AXI Interconnect as Vivado IP"
puts "============================================================================"
puts ""

# Get script directory and calculate paths
if {[info script] != ""} {
    set SCRIPT_DIR [file dirname [file normalize [info script]]]
} else {
    set SCRIPT_DIR [pwd]
}
set PROJECT_ROOT [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]
set SV_BASE [file normalize [file join $PROJECT_ROOT "SystemVerilog"]]
set AXI_INTERCONNECT_DIR [file normalize [file join $SV_BASE "axi_interconnect"]]
set IP_REPO_DIR [file normalize [file join $PROJECT_ROOT "synthesis" "ip_repo"]]

puts "Script directory: $SCRIPT_DIR"
puts "Project root: $PROJECT_ROOT"
puts "SystemVerilog base: $SV_BASE"
puts "AXI Interconnect dir: $AXI_INTERCONNECT_DIR"
puts "IP Repository dir: $IP_REPO_DIR"
puts ""

#==============================================================================
# Step 1: Create IP Repository Directory
#==============================================================================
puts "============================================================================"
puts "Step 1: Creating IP Repository Directory"
puts "============================================================================"

if {![file exists $IP_REPO_DIR]} {
    file mkdir $IP_REPO_DIR
    puts "Created IP repository directory: $IP_REPO_DIR"
} else {
    puts "IP repository directory already exists: $IP_REPO_DIR"
}
puts ""

#==============================================================================
# Step 2: Check/Create Project for IP Packaging
#==============================================================================
puts "============================================================================"
puts "Step 2: Checking/Creating Project for IP Packaging"
puts "============================================================================"

set use_existing_project 0
set temp_proj_name "axi_interconnect_ip_temp"
set temp_proj_dir [file normalize [file join $IP_REPO_DIR $temp_proj_name]]

# Check if there's a project currently open
if {![catch {current_project} err]} {
    set current_proj_name [get_property NAME [current_project]]
    set current_part [get_property PART [current_project]]
    puts "Found open project: $current_proj_name"
    puts "Current project part: $current_part"
    puts ""
    
    # Check if current project part is compatible
    if {[string match "*xczu5ev*" $current_part]} {
        puts "Current project part is compatible: $current_part"
        puts "Using current project: $current_proj_name"
        set use_existing_project 1
    } else {
        puts "Current project part ($current_part) is not compatible with KV260 (xczu5ev-sfvc784-1-e)."
        puts "Creating temporary project with correct part..."
        set use_existing_project 0
    }
    puts ""
} else {
    puts "No project currently open."
    puts "Will create temporary project for IP packaging."
    puts ""
    set use_existing_project 0
}

# Create temporary project if needed
if {!$use_existing_project} {
    # Remove existing temp project if exists
    if {[file exists $temp_proj_dir]} {
        puts "Removing existing temporary project..."
        file delete -force $temp_proj_dir
    }
    
    # Create temporary project
    create_project $temp_proj_name $temp_proj_dir -part xczu5ev-sfvc784-1-e -force
    puts "Temporary project created: $temp_proj_name"
    puts ""
} else {
    puts "Using existing project: $current_proj_name"
    puts ""
}

#==============================================================================
# Step 3: Add All AXI Interconnect Source Files
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding AXI Interconnect Source Files"
puts "============================================================================"

# List of all AXI Interconnect files in dependency order
set axi_files [list \
    [file join $AXI_INTERCONNECT_DIR "utils" "Faling_Edge_Detc.sv"] \
    [file join $AXI_INTERCONNECT_DIR "utils" "Raising_Edge_Det.sv"] \
    [file join $AXI_INTERCONNECT_DIR "buffers" "Queue.sv"] \
    [file join $AXI_INTERCONNECT_DIR "buffers" "Resp_Queue.sv"] \
    [file join $AXI_INTERCONNECT_DIR "handshake" "AW_HandShake_Checker.sv"] \
    [file join $AXI_INTERCONNECT_DIR "handshake" "WD_HandShake.sv"] \
    [file join $AXI_INTERCONNECT_DIR "handshake" "WR_HandShake.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "arbiter_fixed_priority.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "arbiter_round_robin.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "arbiter_qos_based.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "read_arbiter.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "Mux_2x1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "Mux_2x1_en.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "Mux_4x1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "AW_MUX_2_1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "BReady_MUX_2_1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "WD_MUX_2_1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1x2.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1x2_en.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1x4.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1_2.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Write_Addr_Channel_Dec.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Read_Addr_Channel_Dec.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Write_Resp_Channel_Dec.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Write_Resp_Channel_Arb.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "read" "Controller.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "read" "AR_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "write" "AW_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "write" "WD_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "write" "BR_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "core" "AXI_Interconnect_Full.sv"] \
    [file join $AXI_INTERCONNECT_DIR "core" "AXI_Interconnect.sv"] \
]

set files_added 0
foreach file $axi_files {
    set full_path [file normalize $file]
    if {[file exists $full_path]} {
        # Check if file already exists
        set existing_files [get_files -quiet [list $full_path]]
        if {[llength $existing_files] == 0} {
            add_files -norecurse [list $full_path]
            set file_obj [get_files -quiet [list $full_path]]
            if {[llength $file_obj] > 0} {
                set_property file_type {SystemVerilog} $file_obj
            }
            incr files_added
            puts "  Added: [file tail $full_path]"
        } else {
            puts "  Skipped (already exists): [file tail $full_path]"
        }
    } else {
        puts "  WARNING: File not found: $full_path"
    }
}

puts ""
puts "Added $files_added AXI Interconnect files"
puts ""

# Set top module
set_property top AXI_Interconnect [current_fileset]
puts "Top module set: AXI_Interconnect"
puts ""

# Update compile order
update_compile_order -fileset sources_1
puts "Compile order updated"
puts ""

#==============================================================================
# Step 4: Start IP Packager
#==============================================================================
puts "============================================================================"
puts "Step 4: Starting IP Packager"
puts "============================================================================"

set ip_name "axi_interconnect_2m4s"
set ip_display_name "AXI Interconnect 2M.4S"
set ip_description "AXI4 Interconnect with 2 Masters and 4 Slaves. Supports Round-Robin, Fixed Priority, and QoS-based arbitration."
set ip_vendor "user.org"
set ip_library "user"
set ip_version "1.0"
set ip_dir [file normalize [file join $IP_REPO_DIR $ip_name]]

puts "IP Configuration:"
puts "  Name: $ip_name"
puts "  Display Name: $ip_display_name"
puts "  Vendor: $ip_vendor"
puts "  Library: $ip_library"
puts "  Version: $ip_version"
puts "  Output Directory: $ip_dir"
puts ""

# Remove existing IP if exists
if {[file exists $ip_dir]} {
    puts "Removing existing IP directory..."
    file delete -force $ip_dir
}

#==============================================================================
# Step 5: Package IP using ipx::package_project
#==============================================================================
puts "============================================================================"
puts "Step 5: Packaging IP"
puts "============================================================================"

# Use ipx::package_project to package the IP
set_property ip_repo_paths $IP_REPO_DIR [current_project]
update_ip_catalog

# Package the project as IP
# Note: ipx::package_project requires the project to be open and sources to be added
puts "Packaging IP using ipx::package_project..."
puts ""

ipx::package_project -root_dir $ip_dir \
    -vendor $ip_vendor \
    -library $ip_library \
    -name $ip_name \
    -import_files \
    -taxonomy "/UserIP"

puts "IP packaging command executed"
puts ""

#==============================================================================
# Step 6: Configure IP Properties
#==============================================================================
puts "============================================================================"
puts "Step 6: Configuring IP Properties"
puts "============================================================================"

# Get the IP definition
set ip_def [ipx::current_core]

# Set display name and description
set_property display_name $ip_display_name $ip_def
set_property description $ip_description $ip_def
set_property vendor_display_name "User" $ip_def
set_property company_url "" $ip_def

# Add parameter: ARBITRATION_MODE
ipx::add_user_parameter ARBITRATION_MODE $ip_def
set_property value_resolve_type {user} [ipx::get_user_parameters ARBITRATION_MODE -of_objects $ip_def]
set_property display_name {Arbitration Mode} [ipx::get_user_parameters ARBITRATION_MODE -of_objects $ip_def]
set_property description {Arbitration Mode: 0=FIXED, 1=ROUND_ROBIN, 2=QOS} [ipx::get_user_parameters ARBITRATION_MODE -of_objects $ip_def]
set_property value {1} [ipx::get_user_parameters ARBITRATION_MODE -of_objects $ip_def]
set_property value_format {long} [ipx::get_user_parameters ARBITRATION_MODE -of_objects $ip_def]

puts "IP properties configured:"
puts "  - Display Name: $ip_display_name"
puts "  - Parameter: ARBITRATION_MODE (default: 1 = ROUND_ROBIN)"
puts ""

#==============================================================================
# Step 7: Save and Close IP Packager
#==============================================================================
puts "============================================================================"
puts "Step 7: Saving IP"
puts "============================================================================"

# Save IP
ipx::save_core [ipx::current_core]

puts "IP saved successfully"
puts ""

# Close IP Packager
ipx::unload_core [ipx::current_core]

puts "IP Packager closed"
puts ""

#==============================================================================
# Step 8: Verify IP Package
#==============================================================================
puts "============================================================================"
puts "Step 8: Verifying IP Package"
puts "============================================================================"

set component_xml [file join $ip_dir "component.xml"]
if {[file exists $component_xml]} {
    puts "✓ IP package verified successfully!"
    puts "  Component file: $component_xml"
    puts ""
    puts "IP VLNV: $ip_vendor:$ip_library:$ip_name:$ip_version"
} else {
    puts "WARNING: Component.xml not found. IP package may be incomplete."
    puts "  Expected: $component_xml"
}

puts ""

#==============================================================================
# Step 9: Cleanup (if using temporary project)
#==============================================================================
puts "============================================================================"
puts "Step 9: Cleaning Up"
puts "============================================================================"

# Close temporary project only if we created one
if {!$use_existing_project} {
    close_project
    puts "Temporary project closed"
    
    # Optionally remove temporary project directory
    # Uncomment the following line if you want to remove temp project
    # file delete -force $temp_proj_dir
} else {
    puts "Keeping current project open (not closing)"
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "IP Packaging Complete!"
puts "============================================================================"
puts ""
puts "Summary:"
puts "  - IP Name: $ip_name"
puts "  - IP VLNV: $ip_vendor:$ip_library:$ip_name:$ip_version"
puts "  - IP Location: $ip_dir"
puts "  - Files Added: $files_added"
puts ""
puts "Next Steps:"
puts "  1. Add IP Repository to your project:"
puts "     Settings → IP → Repository → Add: $IP_REPO_DIR"
puts ""
puts "  2. Or use TCL:"
puts "     set_property ip_repo_paths [list $IP_REPO_DIR] [current_project]"
puts "     update_ip_catalog"
puts ""
puts "  3. Add IP to Block Design:"
puts "     create_bd_cell -type ip -vlnv $ip_vendor:$ip_library:$ip_name:$ip_version axi_interconnect_0"
puts ""
puts "============================================================================"

