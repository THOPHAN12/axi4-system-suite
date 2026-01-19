#==============================================================================
# check_address_map.tcl
# Script để kiểm tra Address Map và các segments trong Block Design
# 
# Usage: In Vivado TCL Console (after opening Block Design):
#   source check_address_map.tcl
#==============================================================================

puts "============================================================================"
puts "Checking Address Map and Segments"
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
# Step 1: List all Address Spaces
#==============================================================================
puts "============================================================================"
puts "Step 1: All Address Spaces"
puts "============================================================================"

set all_addr_spaces [get_bd_addr_spaces]
puts "Total address spaces: [llength $all_addr_spaces]"
puts ""

foreach addr_space $all_addr_spaces {
    puts "Address Space: $addr_space"
    
    # Get properties
    if {![catch {get_property RANGE $addr_space} range]} {
        puts "  Range: $range"
    }
    
    if {![catch {get_property OFFSET $addr_space} offset]} {
        puts "  Offset: $offset"
    }
    
    puts ""
}

#==============================================================================
# Step 2: List all Slave Segments for each Address Space
#==============================================================================
puts "============================================================================"
puts "Step 2: Slave Segments by Address Space"
puts "============================================================================"
puts ""

foreach addr_space $all_addr_spaces {
    puts "--------------------------------------------------------------------------------"
    puts "Address Space: $addr_space"
    puts "--------------------------------------------------------------------------------"
    
    # Get all slave segments in this address space
    set slave_segs [get_bd_addr_segs -of_objects $addr_space]
    
    puts "Total slave segments: [llength $slave_segs]"
    puts ""
    
    if {[llength $slave_segs] == 0} {
        puts "  (No slave segments found)"
        puts ""
        continue
    }
    
    # List each slave segment
    foreach seg $slave_segs {
        puts "  Slave Segment: $seg"
        
        # Get segment properties
        if {![catch {get_property RANGE $seg} range]} {
            puts "    Range: $range"
        }
        
        if {![catch {get_property OFFSET $seg} offset]} {
            puts "    Offset: $offset"
        }
        
        # Check if assigned
        set excluded 0
        if {![catch {get_property EXCLUDED_PL_FOR_IP_INTEGRATOR $seg} excluded_val]} {
            if {$excluded_val == 1 || $excluded_val == true} {
                set excluded 1
            }
        }
        
        if {$excluded} {
            puts "    Status: EXCLUDED"
        } else {
            puts "    Status: ASSIGNED (or UNASSIGNED if no offset)"
        }
        
        puts ""
    }
    
    puts ""
}

#==============================================================================
# Step 3: Find Unassigned Segments
#==============================================================================
puts "============================================================================"
puts "Step 3: Unassigned Segments (causing warnings)"
puts "============================================================================"
puts ""

set unassigned_count 0

foreach addr_space $all_addr_spaces {
    set slave_segs [get_bd_addr_segs -of_objects $addr_space]
    
    foreach seg $slave_segs {
        set excluded 0
        set has_offset 0
        
        if {![catch {get_property EXCLUDED_PL_FOR_IP_INTEGRATOR $seg} excl_val]} {
            if {$excl_val == 1 || $excl_val == true} {
                set excluded 1
            }
        }
        
        if {![catch {get_property OFFSET $seg} offset_val]} {
            if {$offset_val != ""} {
                set has_offset 1
            }
        }
        
        # Unassigned if not excluded and no offset
        if {!$excluded && !$has_offset} {
            incr unassigned_count
            puts "Unassigned: $seg"
            puts "  In Address Space: $addr_space"
            
            # Try to get interface info
            if {![catch {get_bd_intf_pins -of_objects $seg} intf_pins]} {
                if {[llength $intf_pins] > 0} {
                    puts "  Interface: [lindex $intf_pins 0]"
                }
            }
            puts ""
        }
    }
}

puts "Total unassigned segments: $unassigned_count"
puts ""

#==============================================================================
# Step 4: Check Specific Segments Mentioned in Warnings
#==============================================================================
puts "============================================================================"
puts "Step 4: Checking Specific Segments from Warnings"
puts "============================================================================"
puts ""

set segments_to_check [list \
    "axi_master_bridge_0/s_axi/reg0" \
    "axi_master_bridge_1/s_axi/reg0" \
    "S0_AXI/Reg" \
    "S1_AXI/Reg" \
    "S2_AXI/Reg" \
    "S3_AXI/Reg" \
    "axi_interconnect_0/M0/reg0" \
    "axi_interconnect_0/M1/reg0" \
]

foreach seg_pattern $segments_to_check {
    puts "Checking: $seg_pattern"
    
    # Try to find segment by pattern
    set found 0
    foreach addr_space $all_addr_spaces {
        set slave_segs [get_bd_addr_segs -of_objects $addr_space]
        foreach seg $slave_segs {
            if {[string match "*$seg_pattern*" $seg]} {
                set found 1
                puts "  ✓ Found: $seg"
                puts "    In Address Space: $addr_space"
                
                # Check status
                set excluded 0
                set has_offset 0
                if {![catch {get_property EXCLUDED_PL_FOR_IP_INTEGRATOR $seg} excl_val]} {
                    if {$excl_val == 1 || $excl_val == true} {
                        set excluded 1
                    }
                }
                if {![catch {get_property OFFSET $seg} offset_val]} {
                    if {$offset_val != ""} {
                        set has_offset 1
                        puts "    Offset: $offset_val"
                    }
                }
                
                if {$excluded} {
                    puts "    Status: EXCLUDED"
                } elseif {$has_offset} {
                    puts "    Status: ASSIGNED"
                } else {
                    puts "    Status: UNASSIGNED"
                }
                puts ""
                break
            }
        }
        if {$found} break
    }
    
    if {!$found} {
        puts "  ✗ NOT FOUND"
        puts ""
    }
}

#==============================================================================
# Step 5: List all AXI Interfaces
#==============================================================================
puts "============================================================================"
puts "Step 5: All AXI Interfaces in Block Design"
puts "============================================================================"
puts ""

set all_intf_pins [get_bd_intf_pins]
puts "Total AXI interfaces: [llength $all_intf_pins]"
puts ""

# Group by cells
set cells_with_intf [dict create]

foreach intf $all_intf_pins {
    set parent_cell [get_property PARENT.CELL $intf]
    set intf_name [get_property NAME $intf]
    set full_path "$parent_cell/$intf_name"
    
    if {![dict exists $cells_with_intf $parent_cell]} {
        dict set cells_with_intf $parent_cell [list]
    }
    dict lappend cells_with_intf $parent_cell $full_path
}

dict for {cell intf_list} $cells_with_intf {
    puts "$cell:"
    foreach intf $intf_list {
        puts "  - $intf"
    }
    puts ""
}

#==============================================================================
# Step 6: Check External Ports
#==============================================================================
puts "============================================================================"
puts "Step 6: External AXI Ports"
puts "============================================================================"
puts ""

set ext_ports [get_bd_intf_ports]
puts "Total external ports: [llength $ext_ports]"
puts ""

foreach port $ext_ports {
    puts "  $port"
    if {![catch {get_property VLNV $port} vlnv]} {
        puts "    VLNV: $vlnv"
    }
    if {![catch {get_property MODE $port} mode]} {
        puts "    Mode: $mode"
    }
    puts ""
}

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts ""
puts "Address Spaces: [llength $all_addr_spaces]"
puts "Unassigned Segments: $unassigned_count"
puts ""
puts "Next Steps:"
puts "  1. Review the unassigned segments above"
puts "  2. Use Address Editor to exclude or assign addresses"
puts "  3. Or use assign_bd_address for auto-assignment"
puts ""
puts "============================================================================"

