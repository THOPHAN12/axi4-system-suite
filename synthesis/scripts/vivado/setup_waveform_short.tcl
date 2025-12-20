#==============================================================================
# setup_waveform_short.tcl
# Short version - can be placed in project directory
# Automatically finds the full setup_waveform.tcl script
#==============================================================================

# Get current directory
set current_dir [pwd]

# Try to find setup_waveform.tcl in common locations
set script_found 0
set script_paths [list \
    "setup_waveform.tcl" \
    "synthesis/scripts/vivado/setup_waveform.tcl" \
    "../synthesis/scripts/vivado/setup_waveform.tcl" \
    "../../synthesis/scripts/vivado/setup_waveform.tcl" \
    "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/setup_waveform.tcl" \
]

foreach path $script_paths {
    if {[file exists $path]} {
        puts "Found setup_waveform.tcl at: $path"
        source $path
        set script_found 1
        break
    }
}

if {!$script_found} {
    puts "ERROR: Could not find setup_waveform.tcl"
    puts "Please specify full path:"
    puts "  source <full_path>/setup_waveform.tcl"
    puts ""
    puts "Or copy setup_waveform.tcl to current directory"
}



