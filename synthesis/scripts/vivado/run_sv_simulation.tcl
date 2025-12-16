#==============================================================================
# run_sv_simulation.tcl
# Run SystemVerilog simulation in Vivado
#
# Usage:
#   Option 1: Set variable before sourcing
#     set tb Raising_Edge_Det_tb
#     source run_sv_simulation.tcl
#
#   Option 2: Source and it will auto-detect or prompt
#     source run_sv_simulation.tcl
#
# Note: Make sure you're in the correct directory:
#   cd C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado
#==============================================================================

puts "============================================================================"
puts "Run SystemVerilog Simulation"
puts "============================================================================"
puts ""

# Get script directory to help with path issues
set script_dir [file dirname [file normalize [info script]]]
puts "Script directory: $script_dir"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open project first:"
    puts "  open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr"
    puts ""
    puts "Or create new project:"
    puts "  source create_sv_kv260_project.tcl"
    return
}

set project_name [current_project]
puts "Current project: $project_name"
puts ""

# Get testbench name from variable 'tb' (set before sourcing) or auto-detect
if {[info exists tb]} {
    set testbench_name $tb
    puts "Using testbench from variable: $testbench_name"
} else {
    # Try to find a testbench automatically
    set tb_files [get_files -of_objects [get_filesets sim_1] -filter {FILE_TYPE == SystemVerilog}]
    if {[llength $tb_files] > 0} {
        set first_tb [file rootname [file tail [lindex $tb_files 0]]]
        set testbench_name $first_tb
        puts "Auto-detected testbench: $testbench_name"
        puts ""
        puts "To specify a different testbench, use:"
        puts "  set tb <testbench_name>"
        puts "  source run_sv_simulation.tcl"
    } else {
        puts "ERROR: No testbench specified and no testbench files found!"
        puts ""
        puts "Usage:"
        puts "  set tb <testbench_name>"
        puts "  source run_sv_simulation.tcl"
        puts ""
        puts "Or add testbench files to project first."
        return
    }
}

puts "Testbench: $testbench_name"
puts ""

# Check if testbench file exists in project
set tb_files_in_project [get_files -of_objects [get_filesets sim_1] -filter {FILE_TYPE == SystemVerilog}]
set tb_found 0
foreach file $tb_files_in_project {
    set file_name [file rootname [file tail $file]]
    if {$file_name == $testbench_name} {
        set tb_found 1
        break
    }
}

if {!$tb_found} {
    puts "WARNING: Testbench '$testbench_name' not found in project!"
    puts ""
    puts "Adding testbench file..."
    set project_root [file normalize [file join [file dirname [file normalize [info script]]] ".." ".." ".."]]
    set tb_file [file join $project_root "SystemVerilog" "testbenches" "axi_interconnect" "utils" "${testbench_name}.sv"]
    
    if {[file exists $tb_file]} {
        add_files -fileset sim_1 -norecurse $tb_file
        set tb_file_obj [get_files -of_objects [get_filesets sim_1] $tb_file]
        set_property file_type {SystemVerilog} $tb_file_obj
        puts "  ✓ Testbench added to project"
        update_compile_order -fileset sim_1
    } else {
        puts "  ✗ ERROR: Testbench file not found: $tb_file"
        puts ""
        puts "Please add testbench file to project first:"
        puts "  set tb_file \"path/to/${testbench_name}.sv\""
        puts "  source add_sv_testbench.tcl"
        return
    }
    puts ""
}

# Close existing simulation if running
puts "Checking for existing simulations..."
set sim_count 0
while {[catch {set sim_running [current_sim]} err] == 0 && $sim_running != ""} {
    puts "Closing existing simulation: $sim_running"
    catch {close_sim -force}
    set sim_count [expr $sim_count + 1]
    after 200  ;# Wait for file handles to release
}

if {$sim_count > 0} {
    puts "  ✓ Closed $sim_count simulation(s)"
    after 500  ;# Additional wait for file handles
} else {
    puts "  ✓ No simulation running"
}
puts ""

# Set simulation top
puts "Setting simulation top..."
set_property top $testbench_name [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
puts "  ✓ Simulation top set: $testbench_name"
puts ""

# Set simulation properties for SystemVerilog
puts "Setting simulation properties..."
set sim_fileset [get_filesets sim_1]

# Enable SystemVerilog compilation
# Note: Vivado auto-detects .sv files, but we explicitly enable SV mode
catch {
    set_property -name {xsim.compile.xvlog.more_options} -value {-sv} -objects $sim_fileset
}

set_property -name {xsim.elaborate.debug_level} -value {all} -objects $sim_fileset
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects $sim_fileset
# Set simulation runtime (increased for testbenches that need more time)
# Testbenches will use $finish to end simulation, but this provides a safety timeout
set_property -name {xsim.simulate.runtime} -value {100us} -objects $sim_fileset
puts "  ✓ Simulation properties set"
puts ""

# Launch simulation
puts "Starting simulation..."
puts ""

launch_simulation

puts ""
puts "============================================================================"
puts "Simulation Started!"
puts "============================================================================"
puts ""
puts "Useful commands:"
puts "  run 100ns        - Run for 100 nanoseconds"
puts "  run 1000ns       - Run for 1000 nanoseconds"
puts "  run -all         - Run until finish"
puts "  run -continue    - Continue from current time"
puts "  restart          - Restart simulation"
puts "  add_wave         - Add signals to waveform"
puts "  add_wave -radix hex /$testbench_name/*  - Add all signals in hex"
puts "  log_wave -r /*   - Log all signals"
puts ""
puts "Waveform commands:"
puts "  wave zoom full   - Fit waveform to window"
puts "  wave zoom in     - Zoom in"
puts "  wave zoom out    - Zoom out"
puts ""


