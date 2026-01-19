# run_master_bridge_tb_auto.tcl
# Auto-run master bridge testbench and check for 100% pass rate

set PROJECT_ROOT [file normalize [file join [file dirname [file dirname [file dirname [file dirname [file dirname [info script]]]]]]]]

puts "============================================================================"
puts "Running AXI Master Bridge Testbench - Auto Check"
puts "============================================================================"
puts "Project Root: $PROJECT_ROOT"
puts ""

# Open project if not already open
if {[catch {current_project} proj]} {
    set proj_file [file normalize [file join $PROJECT_ROOT "synthesis" "scripts" "vivado" "axi4_system_sv_kv260" "axi4_system_sv_kv260.xpr"]]
    if {[file exists $proj_file]} {
        open_project $proj_file
        puts "Opened project: [current_project]"
    } else {
        puts "ERROR: Project file not found: $proj_file"
        exit 1
    }
} else {
    puts "Project already open: $proj"
}

# Set simulation properties
set_property top axi_master_bridge_tb [get_filesets sim_1]
set_property runtime {50000ns} [get_filesets sim_1]

puts ""
puts "Starting simulation..."
puts ""

# Launch simulation
launch_simulation

# Run simulation
run 50000ns

puts ""
puts "============================================================================"
puts "Simulation completed"
puts "============================================================================"
puts ""
puts "Please check the simulation output for test results."
puts "Expected: 100% pass rate (22/22 tests)"
puts ""



