#==============================================================================
# Run Synthesis for AXI Interconnect (Simple Version)
#==============================================================================
# This script runs synthesis using project directory
# Works even with spaces in path names
#
# Usage: In Vivado TCL Console (after opening project):
#   source run_synthesis_simple.tcl
#==============================================================================

puts "============================================================================"
puts "Running Synthesis for AXI Interconnect"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open the project first:"
    puts "  open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr"
    return
}

set project_name [current_project]
set proj_dir [get_property DIRECTORY [current_project]]
puts "Current project: $project_name"
puts "Project directory: $proj_dir"
puts ""

# Set top module for synthesis
puts "Setting top module: AXI_Interconnect"
set_property top AXI_Interconnect [current_fileset]
puts "  Top module set"
puts ""

# Check if constraints are added
set constraint_files [get_files -quiet -of_objects [get_filesets constrs_1]]
if {[llength $constraint_files] == 0} {
    puts "WARNING: No constraints file found in project!"
    puts "You may want to add constraints first."
    puts ""
} else {
    puts "Constraints files found:"
    foreach file $constraint_files {
        puts "  - [file tail $file]"
    }
    puts ""
}

# Check if synthesis has already been run
set synth_run [get_runs -quiet synth_1]
if {[llength $synth_run] > 0} {
    set synth_status [get_property STATUS $synth_run]
    puts "Synthesis run status: $synth_status"
    
    if {$synth_status == "synth_design Complete!"} {
        puts ""
        puts "Synthesis already completed!"
        puts "To re-run synthesis, resetting run..."
        reset_run synth_1
        puts ""
    }
} else {
    puts "Creating synthesis run..."
    create_run synth_1 -flow {Vivado Synthesis 2024} -strategy "Vivado Synthesis Defaults"
    puts "  Synthesis run created"
    puts ""
}

# Launch synthesis
puts "============================================================================"
puts "Launching Synthesis..."
puts "============================================================================"
puts ""

launch_runs synth_1 -jobs 4

# Wait for synthesis to complete
puts "Waiting for synthesis to complete..."
puts "This may take several minutes..."
wait_on_run synth_1

# Check synthesis status
set synth_status [get_property STATUS [get_runs synth_1]]
puts ""
puts "============================================================================"
puts "Synthesis Status: $synth_status"
puts "============================================================================"
puts ""

if {$synth_status == "synth_design Complete!"} {
    puts "Synthesis completed successfully!"
    puts ""
    
    # Open synthesis results
    open_run synth_1
    
    # Generate reports
    puts "Generating utilization report..."
    set util_rpt [file join $proj_dir "axi4_system_sv_kv260.runs" "synth_1" "AXI_Interconnect_utilization_synth.rpt"]
    report_utilization -file $util_rpt
    
    puts "Generating timing report..."
    set timing_rpt [file join $proj_dir "axi4_system_sv_kv260.runs" "synth_1" "AXI_Interconnect_timing_synth.rpt"]
    report_timing_summary -file $timing_rpt
    
    puts ""
    puts "Reports generated:"
    puts "  - Utilization: [file tail $util_rpt]"
    puts "  - Timing: [file tail $timing_rpt]"
    puts ""
    
    # Display utilization summary
    puts "Utilization Summary:"
    report_utilization -hierarchical -hierarchical_percentages
    puts ""
    
    # Display timing summary
    puts "Timing Summary:"
    report_timing_summary -max_paths 10
    puts ""
    
} else {
    puts "ERROR: Synthesis failed with status: $synth_status"
    puts ""
    puts "Check the log file for details:"
    set log_file [file join $proj_dir "axi4_system_sv_kv260.runs" "synth_1" "runme.log"]
    puts "  $log_file"
    puts ""
    puts "Common issues:"
    puts "  1. Check for syntax errors in RTL"
    puts "  2. Verify all source files are added"
    puts "  3. Check constraints file for errors"
    puts ""
}

puts "============================================================================"
puts "Synthesis Script Complete"
puts "============================================================================"






















