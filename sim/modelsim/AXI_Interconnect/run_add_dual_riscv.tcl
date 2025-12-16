#==============================================================================
# run_add_dual_riscv.tcl
# Wrapper script to open project and add dual RISC-V files
#==============================================================================

# Get script directory
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_FILE [file normalize [file join $SCRIPT_DIR "AXI_Project.mpf"]]

# Open project
if {[file exists $PROJECT_FILE]} {
    puts "Opening project: $PROJECT_FILE"
    project open $PROJECT_FILE
} else {
    puts "ERROR: Project file not found: $PROJECT_FILE"
    exit 1
}

# Run the add files script
set ADD_SCRIPT [file normalize [file join $SCRIPT_DIR "add_dual_riscv_files.tcl"]]
if {[file exists $ADD_SCRIPT]} {
    puts "Running add_dual_riscv_files.tcl..."
    source $ADD_SCRIPT
} else {
    puts "ERROR: Script not found: $ADD_SCRIPT"
    exit 1
}

puts ""
puts "Done! Files have been added to the project."
puts "You can now compile the files in ModelSim."




