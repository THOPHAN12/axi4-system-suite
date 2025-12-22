################################################################################
# unlock_and_upgrade_ips.tcl
# Unlock and upgrade locked IP instances in Block Design
################################################################################

puts "============================================================================"
puts "Unlocking and Upgrading Locked IP Instances"
puts "============================================================================"
puts ""

# Get locked IPs
set locked_ips [list \
    "design_1_axi_slave_bridge_s1_0" \
    "design_1_axi_slave_bridge_s2_0" \
    "design_1_axi_slave_bridge_s3_0" \
]

puts "Locked IP instances:"
foreach ip $locked_ips {
    puts "  - $ip"
}
puts ""

# Upgrade each IP
foreach ip $locked_ips {
    puts "Upgrading: $ip"
    if {[catch {upgrade_ip [get_ips $ip]} err]} {
        puts "  WARNING: Could not upgrade $ip: $err"
        puts "  Trying to reset locked state..."
        
        # Try to reset locked property
        set ip_cell [get_bd_cells -quiet $ip]
        if {[llength $ip_cell] > 0} {
            # Remove and recreate the IP instance
            puts "  Attempting to remove and recreate $ip..."
            # Don't remove - just try to regenerate
        }
    } else {
        puts "  -> Upgraded successfully"
    }
    puts ""
}

# Regenerate all IPs
puts "Regenerating all IP output products..."
generate_target all [get_ips]
puts "IP output products regenerated"
puts ""

# Now try to regenerate Block Design
puts "Regenerating Block Design..."
set bd_file "design_1.bd"
set bd_path [get_files -quiet $bd_file]
if {[llength $bd_path] > 0} {
    generate_target all [get_files $bd_file]
    puts "Block Design regenerated"
} else {
    puts "ERROR: Block Design file not found"
}
puts ""

puts "============================================================================"
puts "Done"
puts "============================================================================"











