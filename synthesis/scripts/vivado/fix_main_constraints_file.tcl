# fix_main_constraints_file.tcl
# Script to comment out external port constraints in main constraints file

set constraints_file "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/constraints/axi_interconnect.xdc"

if {![file exists $constraints_file]} {
    puts "ERROR: Constraints file not found: $constraints_file"
    exit 1
}

set fp [open $constraints_file r]
set content [read $fp]
close $fp

set lines [split $content "\n"]
set new_lines {}
set changed 0

foreach line $lines {
    set trimmed_line [string trim $line]
    
    # Skip if already commented
    if {[string match "#*" $trimmed_line]} {
        lappend new_lines $line
        continue
    }
    
    # Comment out external port constraints (M0_, M1_, S0_, S1_, S2_, S3_)
    # But keep ACLK and ARESETN constraints
    if {[regexp {get_ports\s+(M0_|M1_|S0_|S1_|S2_|S3_)} $line] && 
        ![regexp {get_ports\s+(ACLK|ARESETN)} $line]} {
        lappend new_lines "# External port constraint (commented - port no longer exists):"
        lappend new_lines "# $line"
        set changed 1
    } else {
        lappend new_lines $line
    }
}

if {$changed} {
    set fp [open $constraints_file w]
    puts -nonewline $fp [join $new_lines "\n"]
    close $fp
    puts "Fixed constraints file: Commented out external port constraints"
} else {
    puts "Constraints file OK: No external port constraints found"
}















