################################################################################
# unlock_ips.tcl
# Quick script to unlock and upgrade locked IP instances
# Run this in Vivado TCL Console after regenerating AXI Slave Bridge IP
################################################################################

puts "============================================================================"
puts "Unlocking IP Instances"
puts "============================================================================"
puts ""

# Upgrade locked IP instances
set locked_ips [list \
    "design_1_axi_slave_bridge_s1_0" \
    "design_1_axi_slave_bridge_s2_0" \
    "design_1_axi_slave_bridge_s3_0" \
]

puts "Upgrading IP instances:"
foreach ip_name $locked_ips {
    puts "  Processing: $ip_name"
    set ip_obj [get_ips -quiet $ip_name]
    if {[llength $ip_obj] == 0} {
        puts "    WARNING: IP instance not found"
        continue
    }
    
    # Try to upgrade
    if {[catch {upgrade_ip $ip_obj} err]} {
        puts "    ERROR: $err"
    } else {
        puts "    -> Upgraded successfully"
    }
}
puts ""

# Regenerate IP output products
puts "Regenerating IP output products..."
generate_target all [get_ips]
puts "Done"
puts ""

# Now regenerate Block Design
puts "Regenerating Block Design..."
set bd_file "design_1.bd"
if {[catch {generate_target all [get_files $bd_file]} err]} {
    puts "WARNING: $err"
} else {
    puts "Block Design regenerated"
}
puts ""

puts "============================================================================"
puts "If IPs are still locked, try:"
puts "  1. Close and reopen Block Design: close_bd_design [current_bd_design]; open_bd_design [get_files design_1.bd]"
puts "  2. Or remove and recreate IP instances in Block Design"
puts "============================================================================"











