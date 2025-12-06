#==============================================================================
# remove_missing_files.tcl
# Remove files that don't exist from ModelSim project
#
# Usage: source scripts/remove_missing_files.tcl
#==============================================================================

puts "\n======================================================================"
puts "   REMOVE MISSING FILES FROM PROJECT"
puts "======================================================================\n"

# Check if project is open
if {[project env] == ""} {
    puts "ERROR: No project is open!"
    puts "Please open project first:\n"
    puts "  project open project/AXI_Project.mpf\n"
    return
}

puts "Project: [project env]\n"

set missing_files {}
set total_removed 0

# Get all files in project
set project_files [project files]

puts "Checking [llength $project_files] files in project...\n"

# Patterns to identify old RV32I wrapper files that should be removed
set old_rv32i_patterns {
    "riscv-axi-wrapper"
    "original_backup"
    "RV32I_PIPELINE_ext"
    "riscv_pipeline_axi_wrapper"
}

foreach file $project_files {
    set file_path [lindex $file 0]
    set should_remove 0
    
    # Check if file doesn't exist
    if {![file exists $file_path]} {
        set should_remove 1
    }
    
    # Check if file path contains old RV32I wrapper patterns
    foreach pattern $old_rv32i_patterns {
        if {[string match "*$pattern*" $file_path]} {
            set should_remove 1
            break
        }
    }
    
    if {$should_remove} {
        lappend missing_files $file_path
        puts "  ✗ Removing: $file_path"
        
        # Remove from project
        project removefile $file_path
        incr total_removed
    }
}

puts "\n======================================================================"
puts "   SUMMARY"
puts "======================================================================\n"

if {$total_removed > 0} {
    puts "  Removed $total_removed missing file(s) from project"
    puts "\n  Missing files were:"
    foreach file $missing_files {
        puts "    - $file"
    }
} else {
    puts "  ✓ All files exist - nothing to remove"
}

puts "\n======================================================================"
puts "   NEXT STEPS"
puts "======================================================================\n"
puts "  1. Re-add files with correct paths:"
puts "     source scripts/add_files.tcl"
puts ""
puts "  2. Compile:"
puts "     compile_all"
puts "======================================================================\n"

