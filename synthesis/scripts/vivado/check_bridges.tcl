#==============================================================================
# check_bridges.tcl
# Script to check AXI Master Bridges and Slave Bridges in Block Design
#==============================================================================
# Usage: In Vivado TCL Console:
#   source synthesis/scripts/vivado/check_bridges.tcl
#
# Or in batch mode:
#   vivado -mode batch -source check_bridges.tcl
#==============================================================================

puts "============================================================================"
puts "Checking Bridge Connections in Block Design"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open project first:"
    puts "  open_project <path_to_project>/<project_name>.xpr"
    return
}

set project_name [current_project]
puts "Project: $project_name"
puts ""

# Open block design if not open
if {[catch {current_bd_design} err]} {
    puts "Opening block design..."
    set bd_files [get_files *.bd]
    if {[llength $bd_files] == 0} {
        puts "ERROR: No block design file found!"
        return
    }
    open_bd_design [lindex $bd_files 0]
}

set bd_design [current_bd_design]
puts "Block Design: $bd_design"
puts ""

# Error counters
set error_count 0
set warning_count 0

#==============================================================================
# 1. Check AXI Master Bridges
#==============================================================================
puts "============================================================================"
puts "1. Checking AXI Master Bridges"
puts "============================================================================"

set master_bridge_0 [get_bd_cells -quiet axi_master_bridge_0]
set master_bridge_1 [get_bd_cells -quiet axi_master_bridge_1]

# Master Bridge 0
if {[llength $master_bridge_0] > 0} {
    puts "OK AXI Master Bridge 0: FOUND"
    
    # Check s_axi connection (from PS)
    set s_axi_0 [get_bd_intf_pins -quiet $master_bridge_0/s_axi]
    if {[llength $s_axi_0] > 0} {
        set s_axi_nets_0 [get_bd_intf_nets -of_objects $s_axi_0]
        if {[llength $s_axi_nets_0] > 0} {
            set source_pins_0 [get_bd_intf_pins -of_objects [lindex $s_axi_nets_0 0] -filter {MODE == Master}]
            if {[llength $source_pins_0] > 0} {
                set source_name [lindex $source_pins_0 0]
                puts "  OK s_axi connected to: $source_name"
                
                if {[string match "*zynq_ultra_ps_e_0*" $source_name] || [string match "*M_AXI_HPM0*" $source_name]} {
                    puts "    -> Correct: Connected to Zynq PS M_AXI_HPM0_FPD"
                }
            } else {
                puts "  ERROR: s_axi NOT connected!"
                incr error_count
            }
        } else {
            puts "  ERROR: s_axi NOT connected!"
            incr error_count
        }
    } else {
        puts "  ERROR: s_axi pin not found!"
        incr error_count
    }
    
    # Check m_axi connection (to AXI Interconnect)
    set m_axi_0 [get_bd_intf_pins -quiet $master_bridge_0/m_axi]
    if {[llength $m_axi_0] > 0} {
        set m_axi_nets_0 [get_bd_intf_nets -of_objects $m_axi_0]
        if {[llength $m_axi_nets_0] > 0} {
            set sink_pins_0 [get_bd_intf_pins -of_objects [lindex $m_axi_nets_0 0] -filter {MODE == Slave}]
            if {[llength $sink_pins_0] > 0} {
                set sink_name [lindex $sink_pins_0 0]
                puts "  OK m_axi connected to: $sink_name"
                
                if {[string match "*axi_interconnect*" $sink_name] || [string match "*M0*" $sink_name]} {
                    puts "    -> Correct: Connected to AXI Interconnect M0"
                }
            } else {
                puts "  ERROR: m_axi NOT connected!"
                incr error_count
            }
        } else {
            puts "  ERROR: m_axi NOT connected!"
            incr error_count
        }
    } else {
        puts "  ERROR: m_axi pin not found!"
        incr error_count
    }
    
    # Check clock
    set aclk_0 [get_bd_pins -quiet $master_bridge_0/ACLK]
    if {[llength $aclk_0] > 0} {
        set aclk_nets_0 [get_bd_nets -of_objects $aclk_0]
        if {[llength $aclk_nets_0] > 0} {
            puts "  OK ACLK connected"
        } else {
            puts "  ERROR: ACLK NOT connected!"
            incr error_count
        }
    }
    
    # Check reset
    set aresetn_0 [get_bd_pins -quiet $master_bridge_0/ARESETN]
    if {[llength $aresetn_0] > 0} {
        set aresetn_nets_0 [get_bd_nets -of_objects $aresetn_0]
        if {[llength $aresetn_nets_0] > 0} {
            puts "  OK ARESETN connected"
        } else {
            puts "  ERROR: ARESETN NOT connected!"
            incr error_count
        }
    }
} else {
    puts "ERROR: AXI Master Bridge 0 NOT FOUND!"
    incr error_count
}

puts ""

# Master Bridge 1
if {[llength $master_bridge_1] > 0} {
    puts "OK AXI Master Bridge 1: FOUND"
    
    # Check s_axi connection (from PS)
    set s_axi_1 [get_bd_intf_pins -quiet $master_bridge_1/s_axi]
    if {[llength $s_axi_1] > 0} {
        set s_axi_nets_1 [get_bd_intf_nets -of_objects $s_axi_1]
        if {[llength $s_axi_nets_1] > 0} {
            set source_pins_1 [get_bd_intf_pins -of_objects [lindex $s_axi_nets_1 0] -filter {MODE == Master}]
            if {[llength $source_pins_1] > 0} {
                set source_name [lindex $source_pins_1 0]
                puts "  OK s_axi connected to: $source_name"
                
                if {[string match "*zynq_ultra_ps_e_0*" $source_name] || [string match "*M_AXI_HPM1*" $source_name]} {
                    puts "    -> Correct: Connected to Zynq PS M_AXI_HPM1_FPD"
                }
            } else {
                puts "  ERROR: s_axi NOT connected!"
                incr error_count
            }
        } else {
            puts "  ERROR: s_axi NOT connected!"
            incr error_count
        }
    } else {
        puts "  ERROR: s_axi pin not found!"
        incr error_count
    }
    
    # Check m_axi connection (to AXI Interconnect)
    set m_axi_1 [get_bd_intf_pins -quiet $master_bridge_1/m_axi]
    if {[llength $m_axi_1] > 0} {
        set m_axi_nets_1 [get_bd_intf_nets -of_objects $m_axi_1]
        if {[llength $m_axi_nets_1] > 0} {
            set sink_pins_1 [get_bd_intf_pins -of_objects [lindex $m_axi_nets_1 0] -filter {MODE == Slave}]
            if {[llength $sink_pins_1] > 0} {
                set sink_name [lindex $sink_pins_1 0]
                puts "  OK m_axi connected to: $sink_name"
                
                if {[string match "*axi_interconnect*" $sink_name] || [string match "*M1*" $sink_name]} {
                    puts "    -> Correct: Connected to AXI Interconnect M1"
                }
            } else {
                puts "  ERROR: m_axi NOT connected!"
                incr error_count
            }
        } else {
            puts "  ERROR: m_axi NOT connected!"
            incr error_count
        }
    } else {
        puts "  ERROR: m_axi pin not found!"
        incr error_count
    }
    
    # Check clock and reset
    set aclk_1 [get_bd_pins -quiet $master_bridge_1/ACLK]
    set aresetn_1 [get_bd_pins -quiet $master_bridge_1/ARESETN]
    if {[llength $aclk_1] > 0} {
        set aclk_nets_1 [get_bd_nets -of_objects $aclk_1]
        puts "  [expr {[llength $aclk_nets_1] > 0 ? "OK" : "ERROR:"}] ACLK [expr {[llength $aclk_nets_1] > 0 ? "connected" : "NOT connected!"}]"
        if {[llength $aclk_nets_1] == 0} { incr error_count }
    }
    if {[llength $aresetn_1] > 0} {
        set aresetn_nets_1 [get_bd_nets -of_objects $aresetn_1]
        puts "  [expr {[llength $aresetn_nets_1] > 0 ? "OK" : "ERROR:"}] ARESETN [expr {[llength $aresetn_nets_1] > 0 ? "connected" : "NOT connected!"}]"
        if {[llength $aresetn_nets_1] == 0} { incr error_count }
    }
} else {
    puts "ERROR: AXI Master Bridge 1 NOT FOUND!"
    incr error_count
}

puts ""

#==============================================================================
# 2. Check AXI Slave Bridges
#==============================================================================
puts "============================================================================"
puts "2. Checking AXI Slave Bridges"
puts "============================================================================"

# Automatically find all AXI Slave Bridges in block design
set all_slave_bridges [get_bd_cells -quiet -filter {VLNV =~ "*axi_slave_bridge*"}]

if {[llength $all_slave_bridges] > 0} {
    puts "Found [llength $all_slave_bridges] AXI Slave Bridge(s):"
    foreach bridge $all_slave_bridges {
        puts "  - [get_property NAME $bridge]"
    }
    puts ""
} else {
    puts "WARNING: No AXI Slave Bridges found in block design"
    puts "  (This is OK if using direct connections to peripherals)"
    puts ""
}

# Check each slave bridge
foreach bridge_cell $all_slave_bridges {
    set bridge_name [get_property NAME $bridge_cell]
    if {[llength $bridge_cell] > 0} {
        puts "OK $bridge_name: FOUND"
        
        # Check s_axi connection (from AXI Interconnect)
        set s_axi [get_bd_intf_pins -quiet $bridge_cell/s_axi]
        if {[llength $s_axi] > 0} {
            set s_axi_nets [get_bd_intf_nets -of_objects $s_axi]
            if {[llength $s_axi_nets] > 0} {
                set source_pins [get_bd_intf_pins -of_objects [lindex $s_axi_nets 0] -filter {MODE == Master}]
                if {[llength $source_pins] > 0} {
                    set source_name [lindex $source_pins 0]
                    puts "  OK s_axi connected to: $source_name"
                    
                    if {[string match "*axi_interconnect*" $source_name]} {
                        puts "    -> Correct: Connected to AXI Interconnect"
                    }
                } else {
                    puts "  ERROR: s_axi NOT connected!"
                    incr error_count
                }
            } else {
                puts "  ERROR: s_axi NOT connected!"
                incr error_count
            }
        } else {
            puts "  ERROR: s_axi pin not found!"
            incr error_count
        }
        
        # Check m_axi connection (to peripheral)
        set m_axi [get_bd_intf_pins -quiet $bridge_cell/m_axi]
        if {[llength $m_axi] > 0} {
            set m_axi_nets [get_bd_intf_nets -of_objects $m_axi]
            if {[llength $m_axi_nets] > 0} {
                set sink_pins [get_bd_intf_pins -of_objects [lindex $m_axi_nets 0] -filter {MODE == Slave}]
                if {[llength $sink_pins] > 0} {
                    set sink_name [lindex $sink_pins 0]
                    puts "  OK m_axi connected to: $sink_name"
                    
                    if {[string match "*gpio*" $sink_name] || \
                        [string match "*uart*" $sink_name] || \
                        [string match "*spi*" $sink_name] || \
                        [string match "*bram*" $sink_name]} {
                        puts "    -> Correct: Connected to AXI Peripheral"
                    } else {
                        puts "    WARNING: Connected to external port (OK if using peripherals)"
                        incr warning_count
                    }
                } else {
                    set ext_ports [get_bd_ports -of_objects [lindex $m_axi_nets 0]]
                    if {[llength $ext_ports] > 0} {
                        puts "  OK m_axi connected to external port: [lindex $ext_ports 0]"
                        puts "    -> OK: External port (can connect to peripherals later)"
                    } else {
                        puts "  ERROR: m_axi NOT connected!"
                        incr error_count
                    }
                }
            } else {
                puts "  ERROR: m_axi NOT connected!"
                incr error_count
            }
        } else {
            puts "  ERROR: m_axi pin not found!"
            incr error_count
        }
        
        # Check clock and reset
        set aclk [get_bd_pins -quiet $bridge_cell/ACLK]
        set aresetn [get_bd_pins -quiet $bridge_cell/ARESETN]
        if {[llength $aclk] > 0} {
            set aclk_nets [get_bd_nets -of_objects $aclk]
            puts "  [expr {[llength $aclk_nets] > 0 ? "OK" : "ERROR:"}] ACLK [expr {[llength $aclk_nets] > 0 ? "connected" : "NOT connected!"}]"
            if {[llength $aclk_nets] == 0} { incr error_count }
        }
        if {[llength $aresetn] > 0} {
            set aresetn_nets [get_bd_nets -of_objects $aresetn]
            puts "  [expr {[llength $aresetn_nets] > 0 ? "OK" : "ERROR:"}] ARESETN [expr {[llength $aresetn_nets] > 0 ? "connected" : "NOT connected!"}]"
            if {[llength $aresetn_nets] == 0} { incr error_count }
        }
    } else {
        puts "WARNING: $bridge_name NOT FOUND"
        incr warning_count
    }
    puts ""
}

# If no slave bridges found, check for direct connections
if {[llength $all_slave_bridges] == 0} {
    puts "Checking for direct connections to peripherals (without slave bridges)..."
    
    set axi_ic [get_bd_cells -quiet axi_interconnect_0]
    if {[llength $axi_ic] > 0} {
        # Check S0 (usually BRAM, no slave bridge needed)
        set s0_port [get_bd_intf_pins -quiet $axi_ic/S0*]
        if {[llength $s0_port] > 0} {
            set s0_nets [get_bd_intf_nets -of_objects $s0_port]
            if {[llength $s0_nets] > 0} {
                set s0_sinks [get_bd_intf_pins -of_objects [lindex $s0_nets 0] -filter {MODE == Slave}]
                if {[llength $s0_sinks] > 0} {
                    set s0_sink_name [lindex $s0_sinks 0]
                    puts "  OK S0 connected directly to: $s0_sink_name"
                    if {[string match "*bram*" $s0_sink_name]} {
                        puts "    -> Correct: Direct connection to BRAM Controller (no bridge needed)"
                    }
                }
            }
        }
        
        # Check S1, S2, S3
        for {set i 1} {$i < 4} {incr i} {
            set s_port [get_bd_intf_pins -quiet $axi_ic/S${i}*]
            if {[llength $s_port] > 0} {
                set s_nets [get_bd_intf_nets -of_objects $s_port]
                if {[llength $s_nets] > 0} {
                    set s_sinks [get_bd_intf_pins -of_objects [lindex $s_nets 0] -filter {MODE == Slave}]
                    if {[llength $s_sinks] > 0} {
                        set s_sink_name [lindex $s_sinks 0]
                        puts "  OK S$i connected to: $s_sink_name"
                        if {[string match "*gpio*" $s_sink_name] || \
                            [string match "*uart*" $s_sink_name] || \
                            [string match "*spi*" $s_sink_name]} {
                            puts "    -> OK: Direct connection to peripheral (may use protocol converter)"
                        }
                    }
                }
            }
        }
    }
    puts ""
}

#==============================================================================
# 3. Check AXI Interconnect
#==============================================================================
puts "============================================================================"
puts "3. Checking AXI Interconnect"
puts "============================================================================"

set axi_ic [get_bd_cells -quiet axi_interconnect_0]
if {[llength $axi_ic] > 0} {
    puts "OK AXI Interconnect: FOUND"
    
    # Check Master ports
    set m0_port [get_bd_intf_pins -quiet $axi_ic/M0*]
    set m1_port [get_bd_intf_pins -quiet $axi_ic/M1*]
    
    if {[llength $m0_port] > 0} {
        set m0_nets [get_bd_intf_nets -of_objects $m0_port]
        if {[llength $m0_nets] > 0} {
            puts "  OK M0 connected"
        } else {
            puts "  ERROR: M0 NOT connected!"
            incr error_count
        }
    } else {
        puts "  WARNING: M0 port not found (check port name)"
        incr warning_count
    }
    
    if {[llength $m1_port] > 0} {
        set m1_nets [get_bd_intf_nets -of_objects $m1_port]
        if {[llength $m1_nets] > 0} {
            puts "  OK M1 connected"
        } else {
            puts "  ERROR: M1 NOT connected!"
            incr error_count
        }
    } else {
        puts "  WARNING: M1 port not found (check port name)"
        incr warning_count
    }
    
    # Check Slave ports
    for {set i 0} {$i < 4} {incr i} {
        set s_port [get_bd_intf_pins -quiet $axi_ic/S${i}*]
        if {[llength $s_port] > 0} {
            set s_nets [get_bd_intf_nets -of_objects $s_port]
            if {[llength $s_nets] > 0} {
                puts "  OK S$i connected"
            } else {
                puts "  ERROR: S$i NOT connected!"
                incr error_count
            }
        } else {
            puts "  WARNING: S$i port not found (check port name)"
            incr warning_count
        }
    }
    
    # Check clock and reset
    set ic_aclk [get_bd_pins -quiet $axi_ic/ACLK]
    set ic_aresetn [get_bd_pins -quiet $axi_ic/ARESETN]
    if {[llength $ic_aclk] > 0} {
        set ic_aclk_nets [get_bd_nets -of_objects $ic_aclk]
        puts "  [expr {[llength $ic_aclk_nets] > 0 ? "OK" : "ERROR:"}] ACLK [expr {[llength $ic_aclk_nets] > 0 ? "connected" : "NOT connected!"}]"
        if {[llength $ic_aclk_nets] == 0} { incr error_count }
    }
    if {[llength $ic_aresetn] > 0} {
        set ic_aresetn_nets [get_bd_nets -of_objects $ic_aresetn]
        puts "  [expr {[llength $ic_aresetn_nets] > 0 ? "OK" : "ERROR:"}] ARESETN [expr {[llength $ic_aresetn_nets] > 0 ? "connected" : "NOT connected!"}]"
        if {[llength $ic_aresetn_nets] == 0} { incr error_count }
    }
} else {
    puts "ERROR: AXI Interconnect NOT FOUND!"
    incr error_count
}

puts ""

#==============================================================================
# 4. Check Zynq PS Connections
#==============================================================================
puts "============================================================================"
puts "4. Checking Zynq PS Connections"
puts "============================================================================"

set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
if {[llength $zynq_ps] > 0} {
    puts "OK Zynq PS: FOUND"
    
    # Check M_AXI_HPM0_FPD
    set hpm0 [get_bd_intf_pins -quiet $zynq_ps/M_AXI_HPM0_FPD]
    if {[llength $hpm0] > 0} {
        set hpm0_nets [get_bd_intf_nets -of_objects $hpm0]
        if {[llength $hpm0_nets] > 0} {
            puts "  OK M_AXI_HPM0_FPD connected"
        } else {
            puts "  ERROR: M_AXI_HPM0_FPD NOT connected!"
            incr error_count
        }
    } else {
        puts "  WARNING: M_AXI_HPM0_FPD pin not found"
        incr warning_count
    }
    
    # Check M_AXI_HPM1_FPD
    set hpm1 [get_bd_intf_pins -quiet $zynq_ps/M_AXI_HPM1_FPD]
    if {[llength $hpm1] > 0} {
        set hpm1_nets [get_bd_intf_nets -of_objects $hpm1]
        if {[llength $hpm1_nets] > 0} {
            puts "  OK M_AXI_HPM1_FPD connected"
        } else {
            puts "  ERROR: M_AXI_HPM1_FPD NOT connected!"
            incr error_count
        }
    } else {
        puts "  WARNING: M_AXI_HPM1_FPD pin not found"
        incr warning_count
    }
    
    # Check clock output
    set pl_clk0 [get_bd_pins -quiet $zynq_ps/pl_clk0]
    if {[llength $pl_clk0] > 0} {
        set pl_clk0_nets [get_bd_nets -of_objects $pl_clk0]
        if {[llength $pl_clk0_nets] > 0} {
            puts "  OK pl_clk0 connected"
        } else {
            puts "  WARNING: pl_clk0 NOT connected (may be OK if not used)"
            incr warning_count
        }
    }
    
    # Check reset output
    set pl_resetn0 [get_bd_pins -quiet $zynq_ps/pl_resetn0]
    if {[llength $pl_resetn0] > 0} {
        set pl_resetn0_nets [get_bd_nets -of_objects $pl_resetn0]
        if {[llength $pl_resetn0_nets] > 0} {
            puts "  OK pl_resetn0 connected"
        } else {
            puts "  WARNING: pl_resetn0 NOT connected (may be OK if not used)"
            incr warning_count
        }
    }
} else {
    puts "ERROR: Zynq PS NOT FOUND!"
    incr error_count
}

puts ""

#==============================================================================
# 5. Validate Block Design
#==============================================================================
puts "============================================================================"
puts "5. Validating Block Design"
puts "============================================================================"

if {[catch {validate_bd_design} err]} {
    puts "VALIDATION FAILED:"
    puts "$err"
    incr error_count
} else {
    puts "OK Block Design Validation: PASSED"
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts ""
puts "Errors found:   $error_count"
puts "Warnings found: $warning_count"
puts ""

if {$error_count == 0} {
    puts "OK ALL BRIDGES ARE CONNECTED CORRECTLY!"
    puts ""
    puts "Block design is ready for Implementation and Bitstream generation."
} else {
    puts "ERROR: Found errors! Please check and fix the errors above before continuing."
    puts ""
    puts "Common issues:"
    puts "  - Bridge not connected to Zynq PS"
    puts "  - Bridge not connected to AXI Interconnect"
    puts "  - Clock/Reset not connected"
    puts "  - AXI Interconnect ports not connected"
}

if {$warning_count > 0} {
    puts ""
    puts "WARNING: Found $warning_count warnings (may not affect functionality)"
}

puts ""
puts "============================================================================"
