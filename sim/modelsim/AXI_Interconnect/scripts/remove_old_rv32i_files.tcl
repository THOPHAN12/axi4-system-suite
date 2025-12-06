#==============================================================================
# remove_old_rv32i_files.tcl
# Remove old RV32I wrapper files that don't exist anymore
#
# Usage: source scripts/remove_old_rv32i_files.tcl
#==============================================================================

puts "\n======================================================================"
puts "   REMOVE OLD RV32I WRAPPER FILES FROM PROJECT"
puts "======================================================================\n"

# Check if project is open
if {[project env] == ""} {
    puts "ERROR: No project is open!"
    puts "Please open project first:\n"
    puts "  project open project/AXI_Project.mpf\n"
    return
}

puts "Project: [project env]\n"

set removed_count 0
set old_rv32i_patterns {
    "riscv-axi-wrapper"
    "original_backup"
    "RV32I_PIPELINE_ext"
    "riscv_pipeline_axi_wrapper"
}

# Get all files in project
set project_files [project files]

puts "Checking [llength $project_files] files in project...\n"

foreach file $project_files {
    set file_path [lindex $file 0]
    
    # Check if file path contains old RV32I wrapper patterns
    set should_remove 0
    foreach pattern $old_rv32i_patterns {
        if {[string match "*$pattern*" $file_path]} {
            set should_remove 1
            break
        }
    }
    
    # Also check if file doesn't exist
    if {![file exists $file_path]} {
        set should_remove 1
    }
    
    if {$should_remove} {
        puts "  ✗ Removing: $file_path"
        project removefile $file_path
        incr removed_count
    }
}

puts "\n======================================================================"
puts "   SUMMARY"
puts "======================================================================\n"

if {$removed_count > 0} {
    puts "  ✓ Removed $removed_count old/missing file(s) from project"
    puts "\n  Next step: Re-add files with correct paths:"
    puts "    source scripts/add_files.tcl"
} else {
    puts "  ✓ No old RV32I wrapper files found"
}

puts "\n======================================================================\n"

