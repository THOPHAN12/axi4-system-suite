#==============================================================================
# replace_smartconnect_with_bridge.tcl
# Replace SmartConnect with AXI Master Bridge in Block Design
# 
# Usage: In Vivado TCL Console (after opening Block Design):
#   source replace_smartconnect_with_bridge.tcl
#==============================================================================

puts "============================================================================"
puts "Replace SmartConnect with AXI Master Bridge"
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
    set_property ip_repo_paths [lappend current_repos $IP_REPO_DIR] [current_project]
    update_ip_catalog
    puts "Added IP repository: $IP_REPO_DIR"
} else {
    puts "IP repository already added: $IP_REPO_DIR"
}
update_ip_catalog
puts ""

#==============================================================================
# Step 2: Check for SmartConnect instances
#==============================================================================
puts "============================================================================"
puts "Step 2: Checking for SmartConnect instances"
puts "============================================================================"

set sc0_exists [llength [get_bd_cells -quiet smartconnect_0]]
set sc1_exists [llength [get_bd_cells -quiet smartconnect_1]]

if {$sc0_exists == 0 && $sc1_exists == 0} {
    puts "No SmartConnect instances found. Nothing to replace."
    puts "If you want to add AXI Master Bridge, use create_block_design_with_bridge.tcl"
    return
}

puts "Found SmartConnect instances:"
if {$sc0_exists > 0} {
    puts "  - smartconnect_0"
}
if {$sc1_exists > 0} {
    puts "  - smartconnect_1"
}
puts ""

#==============================================================================
# Step 3: Save connections before deletion
#==============================================================================
puts "============================================================================"
puts "Step 3: Saving connections"
puts "============================================================================"

# Get connections from SmartConnect_0
set ps_m0_net ""
set axi_m0_net ""

if {$sc0_exists > 0} {
    # Get connection from PS to SmartConnect_0
    set ps_m0_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins smartconnect_0/S00_AXI]]
    if {[llength $ps_m0_nets] > 0} {
        set ps_m0_net [lindex $ps_m0_nets 0]
        puts "Found PS → SmartConnect_0 connection: $ps_m0_net"
    }
    
    # Get connection from SmartConnect_0 to AXI Interconnect
    set axi_m0_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins smartconnect_0/M00_AXI]]
    if {[llength $axi_m0_nets] > 0} {
        set axi_m0_net [lindex $axi_m0_nets 0]
        puts "Found SmartConnect_0 → AXI Interconnect connection: $axi_m0_net"
    }
}

# Get connections from SmartConnect_1
set ps_m1_net ""
set axi_m1_net ""

if {$sc1_exists > 0} {
    # Get connection from PS to SmartConnect_1
    set ps_m1_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins smartconnect_1/S00_AXI]]
    if {[llength $ps_m1_nets] > 0} {
        set ps_m1_net [lindex $ps_m1_nets 0]
        puts "Found PS → SmartConnect_1 connection: $ps_m1_net"
    }
    
    # Get connection from SmartConnect_1 to AXI Interconnect
    set axi_m1_nets [get_bd_intf_nets -of_objects [get_bd_intf_pins smartconnect_1/M00_AXI]]
    if {[llength $axi_m1_nets] > 0} {
        set axi_m1_net [lindex $axi_m1_nets 0]
        puts "Found SmartConnect_1 → AXI Interconnect connection: $axi_m1_net"
    }
}

puts ""

#==============================================================================
# Step 4: Get clock and reset connections
#==============================================================================
puts "============================================================================"
puts "Step 4: Getting clock and reset connections"
puts "============================================================================"

# Get clock from SmartConnect (should be connected to pl_clk0)
set aclk_net ""
if {$sc0_exists > 0} {
    set aclk_nets [get_bd_nets -of_objects [get_bd_pins smartconnect_0/aclk]]
    if {[llength $aclk_nets] > 0} {
        set aclk_net [lindex $aclk_nets 0]
        puts "Found clock net: $aclk_net"
    }
}

# Get reset from SmartConnect (should be connected to pl_resetn0)
set aresetn_net ""
if {$sc0_exists > 0} {
    set aresetn_nets [get_bd_nets -of_objects [get_bd_pins smartconnect_0/aresetn]]
    if {[llength $aresetn_nets] > 0} {
        set aresetn_net [lindex $aresetn_nets 0]
        puts "Found reset net: $aresetn_net"
    }
}

puts ""

#==============================================================================
# Step 5: Delete SmartConnect instances and their connections
#==============================================================================
puts "============================================================================"
puts "Step 5: Deleting SmartConnect instances"
puts "============================================================================"

if {$sc0_exists > 0} {
    delete_bd_objs [get_bd_cells smartconnect_0]
    puts "Deleted smartconnect_0"
}

if {$sc1_exists > 0} {
    delete_bd_objs [get_bd_cells smartconnect_1]
    puts "Deleted smartconnect_1"
}

puts ""

#==============================================================================
# Step 6: Add AXI Master Bridge IPs
#==============================================================================
puts "============================================================================"
puts "Step 6: Adding AXI Master Bridge IPs"
puts "============================================================================"

# Add Bridge 0 for Master 0
create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_0
puts "Added axi_master_bridge_0"

# Add Bridge 1 for Master 1
create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_1
puts "Added axi_master_bridge_1"

puts ""

#==============================================================================
# Step 7: Connect Clock and Reset
#==============================================================================
puts "============================================================================"
puts "Step 7: Connecting Clock and Reset"
puts "============================================================================"

# Connect clock
if {$aclk_net != ""} {
    connect_bd_net $aclk_net [get_bd_pins axi_master_bridge_0/ACLK]
    connect_bd_net $aclk_net [get_bd_pins axi_master_bridge_1/ACLK]
    puts "Connected clock to bridges"
} else {
    # Fallback: connect to pl_clk0 directly
    set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
    if {[llength $zynq_ps] > 0} {
        connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_master_bridge_0/ACLK]
        connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_master_bridge_1/ACLK]
        puts "Connected clock from Zynq PS to bridges"
    }
}

# Connect reset
if {$aresetn_net != ""} {
    connect_bd_net $aresetn_net [get_bd_pins axi_master_bridge_0/ARESETN]
    connect_bd_net $aresetn_net [get_bd_pins axi_master_bridge_1/ARESETN]
    puts "Connected reset to bridges"
} else {
    # Fallback: connect to pl_resetn0 directly
    set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
    if {[llength $zynq_ps] > 0} {
        connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_master_bridge_0/ARESETN]
        connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_master_bridge_1/ARESETN]
        puts "Connected reset from Zynq PS to bridges"
    }
}

puts ""

#==============================================================================
# Step 8: Reconnect AXI Interfaces
#==============================================================================
puts "============================================================================"
puts "Step 8: Reconnecting AXI Interfaces"
puts "============================================================================"

# Reconnect Master 0: PS → Bridge → AXI Interconnect
set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
set axi_ic [get_bd_cells -quiet axi_interconnect_0]

if {[llength $zynq_ps] > 0 && [llength $axi_ic] > 0} {
    # PS → Bridge 0
    connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] \
        [get_bd_intf_pins axi_master_bridge_0/s_axi]
    
    # Bridge 0 → AXI Interconnect M0
    connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_0/m_axi] \
        [get_bd_intf_pins axi_interconnect_0/M0]
    
    puts "Connected Master 0: PS → Bridge 0 → AXI Interconnect M0"
    
    # PS → Bridge 1
    connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD] \
        [get_bd_intf_pins axi_master_bridge_1/s_axi]
    
    # Bridge 1 → AXI Interconnect M1
    connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_1/m_axi] \
        [get_bd_intf_pins axi_interconnect_0/M1]
    
    puts "Connected Master 1: PS → Bridge 1 → AXI Interconnect M1"
} else {
    puts "WARNING: Zynq PS or AXI Interconnect not found!"
    puts "Please connect manually:"
    puts "  PS M_AXI_HPM0_FPD → Bridge_0 s_axi"
    puts "  Bridge_0 m_axi → AXI Interconnect M0"
    puts "  PS M_AXI_HPM1_FPD → Bridge_1 s_axi"
    puts "  Bridge_1 m_axi → AXI Interconnect M1"
}

puts ""

#==============================================================================
# Step 9: Validate Block Design
#==============================================================================
puts "============================================================================"
puts "Step 9: Validating Block Design"
puts "============================================================================"

validate_bd_design

puts "Validation completed"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Replacement Complete!"
puts "============================================================================"
puts ""
puts "Summary:"
puts "  - Removed: SmartConnect_0, SmartConnect_1"
puts "  - Added: axi_master_bridge_0, axi_master_bridge_1"
puts "  - Connections: PS → Bridge → AXI Interconnect"
puts ""
puts "Next Steps:"
puts "  1. Regenerate Block Design layout"
puts "  2. Generate Output Products"
puts "  3. Validate design"
puts ""
puts "============================================================================"












