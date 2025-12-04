# Test script to verify arbiter file paths
puts "\n========================================="
puts "Testing Arbiter File Paths"
puts "=========================================\n"

set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir .. .. ..]]
set src_dir [file join $project_root "src"]
set interconnect_base [file join $src_dir "axi_interconnect" "Verilog" "rtl"]
set arb_dir [file join $interconnect_base "arbitration"]
set arb_algo_dir [file join $arb_dir "algorithms"]

puts "Project Root: $project_root"
puts "Arbiter Dir: $arb_algo_dir\n"

set arb_algo_files {
    "arbiter_fixed_priority.v"
    "arbiter_round_robin.v"
    "arbiter_qos_based.v"
    "read_arbiter.v"
}

set found_count 0
set missing_count 0

foreach file $arb_algo_files {
    set file_path [file join $arb_algo_dir $file]
    if {[file exists $file_path]} {
        puts "  ✓ FOUND: $file"
        puts "    Path: $file_path"
        incr found_count
    } else {
        puts "  ✗ MISSING: $file"
        puts "    Expected: $file_path"
        incr missing_count
    }
}

puts "\n========================================="
puts "Summary: Found $found_count / [expr $found_count + $missing_count] files"
puts "=========================================\n"

