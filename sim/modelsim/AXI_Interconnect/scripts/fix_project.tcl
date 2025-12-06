#==============================================================================
# fix_project.tcl
# Complete fix: Remove missing files + Re-add all files with correct paths
#
# Usage: source scripts/fix_project.tcl
#==============================================================================

puts "\n======================================================================"
puts "   FIX PROJECT - Remove Missing Files & Re-add All"
puts "======================================================================\n"

# Detect current directory
set CURRENT_DIR [pwd]
if {[string match "*scripts*" $CURRENT_DIR]} {
    set PROJECT_FILE "../project/AXI_Project.mpf"
} else {
    set PROJECT_FILE "project/AXI_Project.mpf"
}

# Open project
if {[file exists $PROJECT_FILE]} {
    if {[project env] != ""} {
        project close
    }
    project open $PROJECT_FILE
    puts "✓ Project opened: $PROJECT_FILE\n"
} else {
    puts "ERROR: Project file not found: $PROJECT_FILE"
    return
}

# Step 1: Remove all missing files and old RV32I wrapper files
puts "Step 1: Removing missing files and old RV32I wrapper files...\n"
set project_files [project files]
set removed_count 0

# Patterns to identify old RV32I wrapper files
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
        project removefile $file_path
        incr removed_count
        puts "  ✗ Removed: $file_path"
    }
}

if {$removed_count > 0} {
    puts "\n  → Removed $removed_count missing file(s)\n"
} else {
    puts "  ✓ No missing files found\n"
}

# Step 2: Re-add all files with correct paths
puts "Step 2: Re-adding all files with correct paths...\n"

# Determine script path based on current directory
if {[string match "*scripts*" $CURRENT_DIR]} {
    source add_files.tcl
} else {
    source scripts/add_files.tcl
}

puts "\n======================================================================"
puts "   PROJECT FIXED!"
puts "======================================================================\n"
puts "Next step: compile_all"
puts "======================================================================\n"

