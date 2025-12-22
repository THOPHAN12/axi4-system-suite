#==============================================================================
# fix_address_map.tcl
# Script để tự động fix address map issues trong Block Design
# 
# Usage: In Vivado TCL Console (after opening Block Design):
#   source fix_address_map.tcl
#==============================================================================

puts "============================================================================"
puts "Fixing Address Map Issues"
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
# Step 1: Exclude Bridge Slave Interfaces (Pass-through, không cần address)
#==============================================================================
puts "============================================================================"
puts "Step 1: Excluding Bridge Slave Interfaces"
puts "============================================================================"

set bridge_slaves [list \
    "/axi_master_bridge_0/s_axi/reg0" \
    "/axi_master_bridge_1/s_axi/reg0" \
]

foreach seg_path $bridge_slaves {
    # Try to find segment
    set found 0
    set all_addr_spaces [get_bd_addr_spaces]
    foreach addr_space $all_addr_spaces {
        set slave_segs [get_bd_addr_segs -of_objects $addr_space]
        foreach seg $slave_segs {
            if {[string match "*$seg_path*" $seg]} {
                set found 1
                puts "Found: $seg"
                
                # Exclude it
                if {![catch {set_property EXCLUDED_PL_FOR_IP_INTEGRATOR true $seg} err]} {
                    puts "  ✓ Excluded: $seg"
                } else {
                    puts "  ✗ Failed to exclude: $err"
                }
                break
            }
        }
        if {$found} break
    }
    
    if {!$found} {
        puts "  ⚠ Not found: $seg_path"
    }
}

puts ""

#==============================================================================
# Step 2: Exclude AXI Interconnect Master Interfaces trong Bridge Address Spaces
#==============================================================================
puts "============================================================================"
puts "Step 2: Excluding AXI Interconnect Master Interfaces"
puts "============================================================================"

set interconnect_masters [list \
    "/axi_interconnect_0/M0/reg0" \
    "/axi_interconnect_0/M1/reg0" \
]

foreach seg_path $interconnect_masters {
    set found 0
    set all_addr_spaces [get_bd_addr_spaces]
    foreach addr_space $all_addr_spaces {
        set slave_segs [get_bd_addr_segs -of_objects $addr_space]
        foreach seg $slave_segs {
            if {[string match "*$seg_path*" $seg]} {
                set found 1
                puts "Found: $seg"
                
                # Exclude it (vì interconnect masters không cần address trong bridge address space)
                if {![catch {set_property EXCLUDED_PL_FOR_IP_INTEGRATOR true $seg} err]} {
                    puts "  ✓ Excluded: $seg"
                } else {
                    puts "  ✗ Failed to exclude: $err"
                }
                break
            }
        }
        if {$found} break
    }
    
    if {!$found} {
        puts "  ⚠ Not found: $seg_path"
    }
}

puts ""

#==============================================================================
# Step 3: Exclude External Ports (S0_AXI, S1_AXI, S2_AXI, S3_AXI)
#==============================================================================
puts "============================================================================"
puts "Step 3: Excluding External Port Segments"
puts "============================================================================"

set external_ports [list \
    "/S0_AXI/Reg" \
    "/S1_AXI/Reg" \
    "/S2_AXI/Reg" \
    "/S3_AXI/Reg" \
]

foreach seg_path $external_ports {
    set found 0
    set all_addr_spaces [get_bd_addr_spaces]
    foreach addr_space $all_addr_spaces {
        set slave_segs [get_bd_addr_segs -of_objects $addr_space]
        foreach seg $slave_segs {
            if {[string match "*$seg_path*" $seg]} {
                set found 1
                puts "Found: $seg"
                
                # Exclude it (external ports không cần address assignment trong Block Design)
                if {![catch {set_property EXCLUDED_PL_FOR_IP_INTEGRATOR true $seg} err]} {
                    puts "  ✓ Excluded: $seg"
                } else {
                    puts "  ✗ Failed to exclude: $err"
                }
                break
            }
        }
        if {$found} break
    }
    
    if {!$found} {
        puts "  ⚠ Not found: $seg_path"
    }
}

puts ""

#==============================================================================
# Step 4: Regenerate and Save
#==============================================================================
puts "============================================================================"
puts "Step 4: Regenerating Layout and Saving"
puts "============================================================================"

regenerate_bd_layout
puts "Layout regenerated"

save_bd_design
puts "Block Design saved"

puts ""

#==============================================================================
# Step 5: Validate
#==============================================================================
puts "============================================================================"
puts "Step 5: Validating Block Design"
puts "============================================================================"

if {![catch {validate_bd_design} err]} {
    puts "✓ Validation completed"
} else {
    puts "⚠ Validation had warnings/errors (check messages)"
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Address Map Fix Complete!"
puts "============================================================================"
puts ""
puts "Summary:"
puts "  - Excluded bridge slave interfaces (pass-through)"
puts "  - Excluded AXI Interconnect master interfaces"
puts "  - Excluded external port segments"
puts ""
puts "Next Steps:"
puts "  1. Check validation results"
puts "  2. If warnings remain, review in Address Editor"
puts "  3. Generate output products:"
puts "     generate_target all [get_files design_1.bd]"
puts ""
puts "============================================================================"












