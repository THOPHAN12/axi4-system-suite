#==============================================================================
# Run Synthesis for AXI Interconnect
#==============================================================================
# This script runs synthesis for the AXI Interconnect design
#
# Usage: In Vivado TCL Console:
#   source run_synthesis.tcl
# Or with full path:
#   source [file normalize "synthesis/scripts/vivado/run_synthesis.tcl"]
#==============================================================================

puts "============================================================================"
puts "Running Synthesis for AXI Interconnect"
puts "============================================================================"
puts ""

# Get script directory and calculate project path
# Handle paths with spaces properly using file normalize
if {[info script] != ""} {
    set script_path [file normalize [info script]]
    set script_dir [file dirname $script_path]
} else {
    # Fallback: use project directory if available
    if {![catch {current_project} err]} {
        set proj_dir [get_property DIRECTORY [current_project]]
        set script_dir [file normalize [file join $proj_dir ".." ".." "scripts" "vivado"]]
    } else {
        # Last resort: use relative path
        set script_dir "synthesis/scripts/vivado"
    }
}

set project_dir [file normalize [file join $script_dir "axi4_system_sv_kv260"]]
set project_file [file normalize [file join $project_dir "axi4_system_sv_kv260.xpr"]]

puts "Script directory: $script_dir"
puts "Project file: $project_file"
puts ""

# Check if project exists
if {![file exists $project_file]} {
    puts "ERROR: Project file not found: $project_file"
    puts ""
    puts "Please create the project first with:"
    puts "  source [file join $script_dir create_sv_kv260_project.tcl]"
    return
}

# Check if project is already open
set project_open 0
if {![catch {current_project} err]} {
    set current_proj [get_property DIRECTORY [current_project]]
    set current_proj_file [file join $current_proj [current_project].xpr]
    if {[file normalize $current_proj_file] == [file normalize $project_file]} {
        puts "Project is already open: [current_project]"
        set project_open 1
    } else {
        puts "Closing current project: [current_project]"
        close_project
        set project_open 0
    }
}

# Open project if not already open
if {!$project_open} {
    puts "Opening project: $project_file"
    open_project $project_file
}

set project_name [current_project]
puts "Current project: $project_name"
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
    puts "Adding constraints file..."
    source [file join $script_dir "add_constraints.tcl"]
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
    report_utilization -file [file join $project_dir "axi4_system_sv_kv260.runs" "synth_1" "AXI_Interconnect_utilization_synth.rpt"] -pb [file join $project_dir "axi4_system_sv_kv260.runs" "synth_1" "AXI_Interconnect_utilization_synth.pb"]
    
    puts "Generating timing report..."
    report_timing_summary -file [file join $project_dir "axi4_system_sv_kv260.runs" "synth_1" "AXI_Interconnect_timing_synth.rpt"]
    
    puts ""
    puts "Reports generated:"
    puts "  - Utilization: axi4_system_sv_kv260.runs/synth_1/AXI_Interconnect_utilization_synth.rpt"
    puts "  - Timing: axi4_system_sv_kv260.runs/synth_1/AXI_Interconnect_timing_synth.rpt"
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
    puts "  axi4_system_sv_kv260.runs/synth_1/runme.log"
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

