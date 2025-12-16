#==============================================================================
# init_work_library.tcl
# Initialize work library for ModelSim project
#==============================================================================

puts "============================================================================"
puts "Initializing work library"
puts "============================================================================"

# Get script directory
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set WORK_DIR [file normalize [file join $SCRIPT_DIR "work"]]

# Remove existing work library if it exists (to start fresh)
if {[file exists $WORK_DIR]} {
    puts "Removing existing work library..."
    file delete -force $WORK_DIR
}

# Create work library
puts "Creating work library at: $WORK_DIR"
vlib work

# Map work library
vmap work work

puts "Work library initialized successfully!"
puts "============================================================================"




