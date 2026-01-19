#==============================================================================
# replace_axi_bridge_ip.tcl
# Replace AXI Master Bridge IP instances with new ones (after code update)
# This script preserves all connections
# 
# Usage: In Vivado TCL Console (after opening Block Design):
#   source replace_axi_bridge_ip.tcl
#==============================================================================

puts "============================================================================"
puts "Replace AXI Master Bridge IP Instances"
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
# Step 1: Check IP Repository
#==============================================================================
puts "============================================================================"
puts "Step 1: Checking IP Repository"
puts "============================================================================"

set PROJECT_ROOT [file normalize [file join [pwd] ".." ".." ".."]]
set IP_REPO_DIR [file normalize [file join $PROJECT_ROOT "synthesis" "ip_repo"]]

# Add IP repository if not already added
set current_repos [get_property ip_repo_paths [current_project]]
if {[lsearch $current_repos $IP_REPO_DIR] == -1} {
    lappend current_repos $IP_REPO_DIR
    set_property ip_repo_paths $current_repos [current_project]
    update_ip_catalog -rebuild
    puts "Added IP repository: $IP_REPO_DIR"
} else {
    puts "IP repository already added: $IP_REPO_DIR"
}
update_ip_catalog -rebuild
puts ""

#==============================================================================
# Step 2: Check for AXI Master Bridge instances
#==============================================================================
puts "============================================================================"
puts "Step 2: Checking for AXI Master Bridge instances"
puts "============================================================================"

set bridge0_exists [llength [get_bd_cells -quiet axi_master_bridge_0]]
set bridge1_exists [llength [get_bd_cells -quiet axi_master_bridge_1]]

if {$bridge0_exists == 0 && $bridge1_exists == 0} {
    puts "No AXI Master Bridge instances found. Nothing to replace."
    return
}

puts "Found AXI Master Bridge instances:"
if {$bridge0_exists > 0} {
    puts "  - axi_master_bridge_0"
}
if {$bridge1_exists > 0} {
    puts "  - axi_master_bridge_1"
}
puts ""

#==============================================================================
# Step 3: Save connections before deletion
#==============================================================================
puts "============================================================================"
puts "Step 3: Saving connections"
puts "============================================================================"

# Variables to store connection information (as paths/names, not objects)
set bridge0_s_axi_source ""
set bridge0_m_axi_sink ""
set bridge0_aclk_source ""
set bridge0_aresetn_source ""

set bridge1_s_axi_source ""
set bridge1_m_axi_sink ""
set bridge1_aclk_source ""
set bridge1_aresetn_source ""

# Save Bridge 0 connections
if {$bridge0_exists > 0} {
    # Get s_axi connection (slave interface - from Zynq PS)
    set s_axi_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_master_bridge_0/s_axi]]
    if {[llength $s_axi_nets] > 0} {
        set s_axi_net [lindex $s_axi_nets 0]
        # Get the source pin (Master pin connected to bridge slave)
        set source_pins [get_bd_intf_pins -of_objects $s_axi_net -filter {MODE == Master}]
        if {[llength $source_pins] > 0} {
            # Pin objects are already paths, just store as string
            set bridge0_s_axi_source [lindex $source_pins 0]
            puts "  Bridge 0 s_axi source: $bridge0_s_axi_source"
        }
    }
    
    # Get m_axi connection (master interface - to AXI Interconnect)
    set m_axi_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_master_bridge_0/m_axi]]
    if {[llength $m_axi_nets] > 0} {
        set m_axi_net [lindex $m_axi_nets 0]
        # Get the sink pin (Slave pin connected to bridge master)
        set sink_pins [get_bd_intf_pins -of_objects $m_axi_net -filter {MODE == Slave}]
        if {[llength $sink_pins] > 0} {
            # Pin objects are already paths, just store as string
            set bridge0_m_axi_sink [lindex $sink_pins 0]
            puts "  Bridge 0 m_axi sink: $bridge0_m_axi_sink"
        }
    }
    
    # Get ACLK connection
    set aclk_nets [get_bd_nets -of_objects [get_bd_pins axi_master_bridge_0/ACLK]]
    if {[llength $aclk_nets] > 0} {
        set aclk_net [lindex $aclk_nets 0]
        set source_pins [get_bd_pins -of_objects $aclk_net -filter {DIR == O}]
        if {[llength $source_pins] > 0} {
            set bridge0_aclk_source [lindex $source_pins 0]
            puts "  Bridge 0 ACLK source: $bridge0_aclk_source"
        } elseif {[llength $aclk_net] > 0} {
            # If it's a port
            set ports [get_bd_ports -of_objects $aclk_net]
            if {[llength $ports] > 0} {
                set bridge0_aclk_source [lindex $ports 0]
                puts "  Bridge 0 ACLK source (port): $bridge0_aclk_source"
            }
        }
    }
    
    # Get ARESETN connection
    set aresetn_nets [get_bd_nets -of_objects [get_bd_pins axi_master_bridge_0/ARESETN]]
    if {[llength $aresetn_nets] > 0} {
        set aresetn_net [lindex $aresetn_nets 0]
        set source_pins [get_bd_pins -of_objects $aresetn_net -filter {DIR == O}]
        if {[llength $source_pins] > 0} {
            set bridge0_aresetn_source [lindex $source_pins 0]
            puts "  Bridge 0 ARESETN source: $bridge0_aresetn_source"
        } elseif {[llength $aresetn_net] > 0} {
            set ports [get_bd_ports -of_objects $aresetn_net]
            if {[llength $ports] > 0} {
                set bridge0_aresetn_source [lindex $ports 0]
                puts "  Bridge 0 ARESETN source (port): $bridge0_aresetn_source"
            }
        }
    }
}

# Save Bridge 1 connections
if {$bridge1_exists > 0} {
    # Get s_axi connection
    set s_axi_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_master_bridge_1/s_axi]]
    if {[llength $s_axi_nets] > 0} {
        set s_axi_net [lindex $s_axi_nets 0]
        set source_pins [get_bd_intf_pins -of_objects $s_axi_net -filter {MODE == Master}]
        if {[llength $source_pins] > 0} {
            set bridge1_s_axi_source [lindex $source_pins 0]
            puts "  Bridge 1 s_axi source: $bridge1_s_axi_source"
        }
    }
    
    # Get m_axi connection
    set m_axi_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins axi_master_bridge_1/m_axi]]
    if {[llength $m_axi_nets] > 0} {
        set m_axi_net [lindex $m_axi_nets 0]
        set sink_pins [get_bd_intf_pins -of_objects $m_axi_net -filter {MODE == Slave}]
        if {[llength $sink_pins] > 0} {
            set bridge1_m_axi_sink [lindex $sink_pins 0]
            puts "  Bridge 1 m_axi sink: $bridge1_m_axi_sink"
        }
    }
    
    # Get ACLK connection
    set aclk_nets [get_bd_nets -of_objects [get_bd_pins axi_master_bridge_1/ACLK]]
    if {[llength $aclk_nets] > 0} {
        set aclk_net [lindex $aclk_nets 0]
        set source_pins [get_bd_pins -of_objects $aclk_net -filter {DIR == O}]
        if {[llength $source_pins] > 0} {
            set bridge1_aclk_source [lindex $source_pins 0]
            puts "  Bridge 1 ACLK source: $bridge1_aclk_source"
        } elseif {[llength $aclk_net] > 0} {
            set ports [get_bd_ports -of_objects $aclk_net]
            if {[llength $ports] > 0} {
                set bridge1_aclk_source [lindex $ports 0]
                puts "  Bridge 1 ACLK source (port): $bridge1_aclk_source"
            }
        }
    }
    
    # Get ARESETN connection
    set aresetn_nets [get_bd_nets -of_objects [get_bd_pins axi_master_bridge_1/ARESETN]]
    if {[llength $aresetn_nets] > 0} {
        set aresetn_net [lindex $aresetn_nets 0]
        set source_pins [get_bd_pins -of_objects $aresetn_net -filter {DIR == O}]
        if {[llength $source_pins] > 0} {
            set bridge1_aresetn_source [lindex $source_pins 0]
            puts "  Bridge 1 ARESETN source: $bridge1_aresetn_source"
        } elseif {[llength $aresetn_net] > 0} {
            set ports [get_bd_ports -of_objects $aresetn_net]
            if {[llength $ports] > 0} {
                set bridge1_aresetn_source [lindex $ports 0]
                puts "  Bridge 1 ARESETN source (port): $bridge1_aresetn_source"
            }
        }
    }
}

puts ""

#==============================================================================
# Step 4: Delete old IP instances
#==============================================================================
puts "============================================================================"
puts "Step 4: Deleting old IP instances"
puts "============================================================================"

if {$bridge0_exists > 0} {
    delete_bd_objs [get_bd_cells axi_master_bridge_0]
    puts "Deleted: axi_master_bridge_0"
}

if {$bridge1_exists > 0} {
    delete_bd_objs [get_bd_cells axi_master_bridge_1]
    puts "Deleted: axi_master_bridge_1"
}

puts ""

#==============================================================================
# Step 5: Add new IP instances
#==============================================================================
puts "============================================================================"
puts "Step 5: Adding new IP instances"
puts "============================================================================"

# Check if IP exists in catalog
set ip_vlnv "user.org:user:axi_master_bridge:1.0"
set ip_exists [llength [get_ipdefs -quiet $ip_vlnv]]

if {$ip_exists == 0} {
    puts "ERROR: IP '$ip_vlnv' not found in catalog!"
    puts "Please package the IP first:"
    puts "  source package_axi_master_bridge_ip.tcl"
    return
}

puts "IP found in catalog: $ip_vlnv"

# Add new instances
if {$bridge0_exists > 0} {
    create_bd_cell -type ip -vlnv $ip_vlnv axi_master_bridge_0
    puts "Added: axi_master_bridge_0"
}

if {$bridge1_exists > 0} {
    create_bd_cell -type ip -vlnv $ip_vlnv axi_master_bridge_1
    puts "Added: axi_master_bridge_1"
}

puts ""

#==============================================================================
# Step 6: Restore connections
#==============================================================================
puts "============================================================================"
puts "Step 6: Restoring connections"
puts "============================================================================"

# Restore Bridge 0 connections
if {$bridge0_exists > 0} {
    puts "Restoring Bridge 0 connections..."
    
    # Connect s_axi
    if {$bridge0_s_axi_source != ""} {
        if {[catch {connect_bd_intf_net $bridge0_s_axi_source [get_bd_intf_pins axi_master_bridge_0/s_axi]} err]} {
            puts "  WARNING: Failed to connect s_axi: $err"
        } else {
            puts "  ✓ Connected s_axi"
        }
    }
    
    # Connect m_axi
    if {$bridge0_m_axi_sink != ""} {
        if {[catch {connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_0/m_axi] $bridge0_m_axi_sink} err]} {
            puts "  WARNING: Failed to connect m_axi: $err"
        } else {
            puts "  ✓ Connected m_axi"
        }
    }
    
    # Connect ACLK
    if {$bridge0_aclk_source != ""} {
        if {[catch {connect_bd_net $bridge0_aclk_source [get_bd_pins axi_master_bridge_0/ACLK]} err]} {
            puts "  WARNING: Failed to connect ACLK: $err"
        } else {
            puts "  ✓ Connected ACLK"
        }
    }
    
    # Connect ARESETN
    if {$bridge0_aresetn_source != ""} {
        if {[catch {connect_bd_net $bridge0_aresetn_source [get_bd_pins axi_master_bridge_0/ARESETN]} err]} {
            puts "  WARNING: Failed to connect ARESETN: $err"
        } else {
            puts "  ✓ Connected ARESETN"
        }
    }
}

# Restore Bridge 1 connections
if {$bridge1_exists > 0} {
    puts "Restoring Bridge 1 connections..."
    
    # Connect s_axi
    if {$bridge1_s_axi_source != ""} {
        if {[catch {connect_bd_intf_net $bridge1_s_axi_source [get_bd_intf_pins axi_master_bridge_1/s_axi]} err]} {
            puts "  WARNING: Failed to connect s_axi: $err"
        } else {
            puts "  ✓ Connected s_axi"
        }
    }
    
    # Connect m_axi
    if {$bridge1_m_axi_sink != ""} {
        if {[catch {connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_1/m_axi] $bridge1_m_axi_sink} err]} {
            puts "  WARNING: Failed to connect m_axi: $err"
        } else {
            puts "  ✓ Connected m_axi"
        }
    }
    
    # Connect ACLK
    if {$bridge1_aclk_source != ""} {
        if {[catch {connect_bd_net $bridge1_aclk_source [get_bd_pins axi_master_bridge_1/ACLK]} err]} {
            puts "  WARNING: Failed to connect ACLK: $err"
        } else {
            puts "  ✓ Connected ACLK"
        }
    }
    
    # Connect ARESETN
    if {$bridge1_aresetn_source != ""} {
        if {[catch {connect_bd_net $bridge1_aresetn_source [get_bd_pins axi_master_bridge_1/ARESETN]} err]} {
            puts "  WARNING: Failed to connect ARESETN: $err"
        } else {
            puts "  ✓ Connected ARESETN"
        }
    }
}

puts ""

#==============================================================================
# Step 7: Regenerate layout and save
#==============================================================================
puts "============================================================================"
puts "Step 7: Regenerating layout and saving"
puts "============================================================================"

regenerate_bd_layout
puts "Layout regenerated"

save_bd_design
puts "Block Design saved"

puts ""

#==============================================================================
# Step 8: Summary
#==============================================================================
puts "============================================================================"
puts "Replacement Complete!"
puts "============================================================================"
puts ""
puts "Next Steps:"
puts "  1. Generate output products:"
puts "     generate_target all [get_files design_1.bd]"
puts ""
puts "  2. Validate Block Design:"
puts "     validate_bd_design"
puts ""
puts "============================================================================"

