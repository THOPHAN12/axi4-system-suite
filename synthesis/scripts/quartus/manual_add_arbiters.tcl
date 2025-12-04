# Manual script to add ONLY arbiter files to existing Quartus project
# Run this in Quartus TCL Console after opening your project

puts "\n========================================="
puts "Adding Arbiter Files to Quartus Project"
puts "=========================================\n"

# Get current project
if {[catch {set project_name [get_current_revision]} err]} {
    puts "ERROR: No project open!"
    puts "Please open your Quartus project first."
    return
}

puts "Project: $project_name\n"

# Paths
set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir .. .. ..]]
set arb_algo_dir [file join $project_root "src" "axi_interconnect" "Verilog" "rtl" "arbitration" "algorithms"]

puts "Adding arbiter algorithms from:"
puts "  $arb_algo_dir\n"

# Arbiter files
set arb_files {
    "arbiter_fixed_priority.v"
    "arbiter_round_robin.v"
    "arbiter_qos_based.v"
    "read_arbiter.v"
}

set added_count 0
foreach file $arb_files {
    set file_path [file normalize [file join $arb_algo_dir $file]]
    if {[file exists $file_path]} {
        set_global_assignment -name VERILOG_FILE $file_path
        puts "  ✓ Added: $file"
        incr added_count
    } else {
        puts "  ✗ NOT FOUND: $file"
    }
}

puts "\n========================================="
puts "Added: $added_count arbiter files"
puts "=========================================\n"

# Save assignments
export_assignments

puts "✓ Saved to project!"
puts "\nNext steps:"
puts "  1. Processing → Start → Start Analysis & Elaboration"
puts "  2. Check for errors\n"


