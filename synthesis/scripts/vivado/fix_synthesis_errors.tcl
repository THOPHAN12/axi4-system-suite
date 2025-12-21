################################################################################
# fix_synthesis_errors.tcl
# Fix all synthesis errors:
# 1. Fix read_burst_error in axi_slave_bridge.sv (already fixed in source)
# 2. Remove/comment XDC constraints for non-existent external ports
# 3. Regenerate IPs and Block Design
################################################################################

puts "============================================================================"
puts "Fixing Synthesis Errors"
puts "============================================================================"
puts ""

#==============================================================================
# Step 1: Open Block Design
#==============================================================================
puts "Step 1: Opening Block Design"
puts "----------------------------------------------------------------------------"

set bd_file "design_1.bd"
set bd_path [get_files -quiet $bd_file]

if {[llength $bd_path] == 0} {
    puts "ERROR: Block Design file '$bd_file' not found!"
    puts "Please open the project first and ensure the Block Design exists."
    exit 1
}

puts "Found Block Design: $bd_path"

# Open Block Design
open_bd_design $bd_path
puts "Block Design opened successfully"
puts ""

#==============================================================================
# Step 2: Comment out XDC constraints for non-existent external ports
#==============================================================================
puts "Step 2: Fixing XDC Constraints"
puts "----------------------------------------------------------------------------"

# List of XDC files to fix (contain constraints for external ports)
set xdc_files_to_fix [list \
    "design_1_axi_master_bridge_0_0/src/axi_interconnect.xdc" \
    "design_1_axi_master_bridge_1_0/src/axi_interconnect.xdc" \
    "design_1_axi_interconnect_0_0/src/axi_interconnect.xdc" \
    "design_1_axi_slave_bridge_s1_0/src/axi_interconnect.xdc" \
    "design_1_axi_slave_bridge_s2_0/src/axi_interconnect.xdc" \
    "design_1_axi_slave_bridge_s3_0/src/axi_interconnect.xdc" \
]

set bd_dir [file dirname $bd_path]
set ip_dir [file normalize [file join $bd_dir "ip"]]

puts "IP directory: $ip_dir"
puts ""

# Function to comment out external port constraints
proc comment_external_port_constraints {xdc_file} {
    if {![file exists $xdc_file]} {
        puts "  WARNING: File not found: $xdc_file"
        return 0
    }
    
    puts "  Processing: $xdc_file"
    
    # Read file content
    set fp [open $xdc_file r]
    set content [read $fp]
    close $fp
    
    # Lines to comment out (patterns for external ports)
    set patterns [list \
        "set_input_delay.*get_ports M" \
        "set_output_delay.*get_ports S" \
        "set_false_path.*get_ports M" \
        "set_false_path.*get_ports S" \
        "set_max_delay.*get_ports M" \
        "set_max_delay.*get_ports S" \
        "set_min_delay.*get_ports M" \
        "set_min_delay.*get_ports S" \
    ]
    
    # Split into lines
    set lines [split $content "\n"]
    set new_lines {}
    set changed 0
    
    foreach line $lines {
        set should_comment 0
        
        # Check if line matches any pattern for external ports
        foreach pattern $patterns {
            if {[regexp $pattern $line]} {
                set should_comment 1
                break
            }
        }
        
        if {$should_comment && ![regexp {^\s*#} $line]} {
            # Comment out the line
            lappend new_lines "# [string trim $line]"
            set changed 1
        } else {
            lappend new_lines $line
        }
    }
    
    if {$changed} {
        # Write back to file
        set fp [open $xdc_file w]
        puts -nonewline $fp [join $new_lines "\n"]
        close $fp
        puts "    -> Commented out external port constraints"
        return 1
    } else {
        puts "    -> No changes needed"
        return 0
    }
}

# Process each XDC file
set files_fixed 0
foreach xdc_rel_path $xdc_files_to_fix {
    set xdc_full_path [file normalize [file join $ip_dir $xdc_rel_path]]
    if {[comment_external_port_constraints $xdc_full_path]} {
        incr files_fixed
    }
}

puts ""
puts "Fixed $files_fixed XDC file(s)"
puts ""

#==============================================================================
# Step 3: Regenerate AXI Slave Bridge IP (to pick up read_burst_error fix)
#==============================================================================
puts "Step 3: Regenerating AXI Slave Bridge IP"
puts "----------------------------------------------------------------------------"

# Check if IP repo path is set
set ip_repo_path "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/ip_repo"
if {[file exists $ip_repo_path]} {
    set_property ip_repo_paths [list $ip_repo_path] [current_project]
    update_ip_catalog -rebuild
    puts "IP catalog updated"
} else {
    puts "WARNING: IP repo path not found: $ip_repo_path"
    puts "Please run package_axi_slave_bridge_ip.tcl first to regenerate the IP"
}
puts ""

#==============================================================================
# Step 4: Regenerate Output Products for Block Design
#==============================================================================
puts "Step 4: Regenerating Block Design Output Products"
puts "----------------------------------------------------------------------------"

# Regenerate all output products
generate_target all [get_files $bd_file]
puts "Output products regenerated"
puts ""

#==============================================================================
# Step 5: Validate Block Design
#==============================================================================
puts "Step 5: Validating Block Design"
puts "----------------------------------------------------------------------------"

validate_bd_design -force
puts "Block Design validated"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "1. Fixed read_burst_error in axi_slave_bridge.sv (in source file)"
puts "2. Commented out external port constraints in $files_fixed XDC file(s)"
puts "3. Regenerated Block Design output products"
puts ""
puts "Next Steps:"
puts "  - Run synthesis: launch_runs synth_1 -jobs 4"
puts "  - If XDC warnings persist, they are non-critical (ports don't exist)"
puts "============================================================================"








