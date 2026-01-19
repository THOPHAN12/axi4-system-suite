#==============================================================================
# configure_zynq_ps_32bit.tcl
# Configure Zynq PS M_AXI_HPM ports to use 32-bit DATA_WIDTH
# 
# Usage: In Vivado TCL Console (after opening Block Design):
#   source configure_zynq_ps_32bit.tcl
#==============================================================================

puts "============================================================================"
puts "Configure Zynq PS to use 32-bit DATA_WIDTH"
puts "============================================================================"
puts ""

# Check if Block Design is open
if {[catch {current_bd_design} err]} {
    puts "ERROR: No Block Design is currently open!"
    puts "Please open Block Design first:"
    puts "  open_bd_design [get_files *.bd]"
    return
}

set zynq_ps [get_bd_cells -quiet zynq_ultra_ps_e_0]
if {[llength $zynq_ps] == 0} {
    puts "ERROR: Zynq PS not found in Block Design!"
    return
}

puts "Found Zynq PS: zynq_ultra_ps_e_0"
puts ""

#==============================================================================
# Try different property names to configure DATA_WIDTH
#==============================================================================
puts "============================================================================"
puts "Attempting to configure DATA_WIDTH to 32 bits"
puts "============================================================================"

# List of possible property names to try
set property_names [list \
    "CONFIG.PSU__SAXIGP0__DATA_WIDTH" \
    "CONFIG.PSU__SAXIGP1__DATA_WIDTH" \
    "CONFIG.PSU__M_AXI_HPM0_FPD__DATA_WIDTH" \
    "CONFIG.PSU__M_AXI_HPM1_FPD__DATA_WIDTH" \
    "CONFIG.PSU__M_AXI_GP0_DATA_WIDTH" \
    "CONFIG.PSU__M_AXI_GP1_DATA_WIDTH" \
    "CONFIG.PSU__GP0_DATA_WIDTH" \
    "CONFIG.PSU__GP1_DATA_WIDTH" \
]

# Try to find existing DATA_WIDTH properties
puts "Checking existing DATA_WIDTH properties:"
set found_properties [list]
foreach prop $property_names {
    set prop_name [string map {CONFIG. ""} $prop]
    if {![catch {get_property $prop $zynq_ps} value]} {
        puts "  Found: $prop = $value"
        lappend found_properties $prop
    }
}
puts ""

# Try setting properties
puts "Attempting to set DATA_WIDTH properties to 32:"
set success_count 0
foreach prop $property_names {
    set prop_name [string map {CONFIG. ""} $prop]
    if {![catch {set_property $prop {32} $zynq_ps} err]} {
        set current_value [get_property $prop $zynq_ps]
        if {$current_value == 32} {
            puts "  ✓ Set $prop = $current_value"
            incr success_count
        } else {
            puts "  ✗ $prop set to $current_value (expected 32)"
        }
    }
}
puts ""

#==============================================================================
# Alternative: Use GUI Configuration
#==============================================================================
puts "============================================================================"
puts "Note: If properties above don't work, configure via GUI:"
puts "============================================================================"
puts ""
puts "1. Double-click 'zynq_ultra_ps_e_0' in Block Design"
puts "2. Navigate to 'M_AXI_HPM0_FPD' tab"
puts "3. Set 'Data Width' to '32'"
puts "4. Navigate to 'M_AXI_HPM1_FPD' tab"
puts "5. Set 'Data Width' to '32'"
puts "6. Click OK"
puts ""
puts "============================================================================"
puts "Checking current AXI interface properties:"
puts "============================================================================"

# Check current interface properties
set hpm0_intf [get_bd_intf_pins -quiet zynq_ultra_ps_e_0/M_AXI_HPM0_FPD]
set hpm1_intf [get_bd_intf_pins -quiet zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]

if {[llength $hpm0_intf] > 0} {
    puts "M_AXI_HPM0_FPD properties:"
    set props [list CONFIG.FREQ_HZ CONFIG.DATA_WIDTH CONFIG.ID_WIDTH]
    foreach prop $props {
        if {![catch {get_property $prop $hpm0_intf} value]} {
            puts "  $prop = $value"
        }
    }
    puts ""
}

if {[llength $hpm1_intf] > 0} {
    puts "M_AXI_HPM1_FPD properties:"
    set props [list CONFIG.FREQ_HZ CONFIG.DATA_WIDTH CONFIG.ID_WIDTH]
    foreach prop $props {
        if {![catch {get_property $prop $hpm1_intf} value]} {
            puts "  $prop = $value"
        }
    }
    puts ""
}

# Try setting interface properties directly
puts "Attempting to set interface DATA_WIDTH properties:"
if {[llength $hpm0_intf] > 0} {
    if {![catch {set_property CONFIG.DATA_WIDTH {32} $hpm0_intf} err]} {
        set current_value [get_property CONFIG.DATA_WIDTH $hpm0_intf]
        puts "  M_AXI_HPM0_FPD: CONFIG.DATA_WIDTH = $current_value"
    } else {
        puts "  M_AXI_HPM0_FPD: Could not set DATA_WIDTH - $err"
    }
}

if {[llength $hpm1_intf] > 0} {
    if {![catch {set_property CONFIG.DATA_WIDTH {32} $hpm1_intf} err]} {
        set current_value [get_property CONFIG.DATA_WIDTH $hpm1_intf]
        puts "  M_AXI_HPM1_FPD: CONFIG.DATA_WIDTH = $current_value"
    } else {
        puts "  M_AXI_HPM1_FPD: Could not set DATA_WIDTH - $err"
    }
}

puts ""

# Regenerate layout
regenerate_bd_layout
save_bd_design

puts "============================================================================"
puts "Configuration complete!"
puts "============================================================================"
puts ""
puts "Next: Validate Block Design"
puts "  validate_bd_design"
puts ""

















