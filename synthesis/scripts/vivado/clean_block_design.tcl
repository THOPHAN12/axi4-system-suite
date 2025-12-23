#==============================================================================
# clean_block_design.tcl
# Clean Block Design references from project
#
# Run this script if you get errors about missing BD files
# Usage: source clean_block_design.tcl
#==============================================================================

puts "============================================================================"
puts "Clean Block Design References"
puts "============================================================================"
puts ""

set bd_name "design_1"

# Close BD if open
catch {
    set current_bd [current_bd_design]
    if {[string equal $current_bd $bd_name]} {
        close_bd_design [current_bd_design]
        puts "Closed Block Design: $bd_name"
    }
} err_msg

# Remove BD files from project
set bd_files [get_files -quiet -all -filter {FILE_TYPE == "Block Designs"} *${bd_name}.bd]
if {[llength $bd_files] > 0} {
    puts "Removing BD files from project..."
    remove_files $bd_files
    puts "Removed [llength $bd_files] BD file(s)"
} else {
    puts "No BD files found in project"
}

# Delete BD design if exists
set bd_designs [get_bd_designs -quiet $bd_name]
if {[llength $bd_designs] > 0} {
    puts "Deleting BD design..."
    delete_bd_design $bd_designs
    puts "Deleted BD design: $bd_name"
} else {
    puts "No BD design found"
}

puts ""
puts "Cleanup completed. You can now create new Block Design."
puts ""
















