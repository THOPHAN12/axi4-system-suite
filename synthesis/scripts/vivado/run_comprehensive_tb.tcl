#==============================================================================
# Run Comprehensive Testbench in Vivado
#==============================================================================
# This script can be run from Vivado TCL Console:
#   source run_comprehensive_tb.tcl
# Or with full path:
#   source [file normalize "synthesis/scripts/vivado/run_comprehensive_tb.tcl"]
#==============================================================================

puts "============================================================================"
puts "Running Comprehensive Testbench in Vivado"
puts "============================================================================"
puts ""

# Get script directory and calculate project path
set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize [file join $script_dir "axi4_system_sv_kv260"]]
set project_file [file normalize [file join $project_dir "axi4_system_sv_kv260.xpr"]]

puts "Script directory: $script_dir"
puts "Project file: $project_file"
puts ""

# Check if project exists
if {![file exists $project_file]} {
    puts "ERROR: Project file not found: $project_file"
    puts ""
    puts "Please ensure the project exists, or create it with:"
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

# Set top module
puts "Setting top module: comprehensive_system_tb"
set_property top comprehensive_system_tb [get_filesets sim_1]
puts ""

# Set runtime to 11000ns (testbench has 10000ns timeout, add margin)
puts "Setting simulation runtime: 11000ns"
set_property -name {xsim.simulate.runtime} -value {11000ns} -objects [get_filesets sim_1]
puts ""

# Launch simulation
puts "============================================================================"
puts "Launching simulation..."
puts "============================================================================"
puts ""

# Close any existing simulation first
catch {close_sim -force}
after 500

launch_simulation

# Wait a bit for simulation to start
after 1000

# Run until $finish (instead of fixed time)
puts "Running simulation until \$finish..."
puts "This may take a few seconds..."
puts ""

run -all

puts ""
puts "============================================================================"
puts "Simulation completed!"
puts "============================================================================"
puts ""
puts "Check the simulation output above for test results."
puts "Expected: All 21 test cases should PASS (100% pass rate)"
puts "Test Scenarios: 8 (Basic, Concurrent, Contention, Busy Flags, All Slaves, Multiple Concurrent, Stress, Arbitration)"
puts ""
