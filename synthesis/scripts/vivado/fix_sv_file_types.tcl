#==============================================================================
# fix_sv_file_types.tcl
# Fix file types for SystemVerilog files in existing project
#
# Usage: In Vivado TCL Console:
#   source fix_sv_file_types.tcl
#==============================================================================

puts "============================================================================"
puts "Fixing SystemVerilog File Types"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open project first"
    return
}

set project_name [current_project]
puts "Current project: $project_name"
puts ""

# Set file type for SystemVerilog files in sources_1
puts "Setting file types for design sources..."
set sv_files [get_files -of_objects [get_filesets sources_1] -filter {FILE_TYPE == Verilog}]
set sv_count 0
foreach file $sv_files {
    set file_ext [file extension $file]
    if {$file_ext == ".sv"} {
        set_property file_type {SystemVerilog} $file
        set sv_count [expr $sv_count + 1]
        puts "  ✓ Set [file tail $file] to SystemVerilog"
    }
}

# Also set for simulation files
puts ""
puts "Setting file types for simulation sources..."
set sv_sim_files [get_files -of_objects [get_filesets sim_1] -filter {FILE_TYPE == Verilog}]
foreach file $sv_sim_files {
    set file_ext [file extension $file]
    if {$file_ext == ".sv"} {
        set_property file_type {SystemVerilog} $file
        set sv_count [expr $sv_count + 1]
        puts "  ✓ Set [file tail $file] to SystemVerilog"
    }
}

puts ""
puts "============================================================================"
puts "File Types Fixed!"
puts "============================================================================"
puts "Total SystemVerilog files updated: $sv_count"
puts ""
puts "Next: Update compile order and recompile"
puts "  update_compile_order -fileset sources_1"
puts "  update_compile_order -fileset sim_1"
puts ""

