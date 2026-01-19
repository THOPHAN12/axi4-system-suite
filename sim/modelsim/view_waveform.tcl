#==============================================================================
# view_waveform.tcl
# Open waveform viewer for comprehensive_system_tb
# Usage: vsim -do view_waveform.tcl
#==============================================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set wave_file [file join $SCRIPT_DIR comprehensive_system_tb.wlf]

if {[file exists $wave_file]} {
    puts "Opening waveform: $wave_file"
    vsim -view $wave_file
    do wave.do
} else {
    puts "ERROR: Waveform file not found: $wave_file"
    puts "Please run simulation first: do run_comprehensive_tb_simple.tcl"
}























