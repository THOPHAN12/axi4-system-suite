# ==============================================================================
# Master Script - Complete Quartus Flow
# ==============================================================================
# Description: Runs complete flow from project creation to compilation
# Usage: quartus_sh -t run_all.tcl
# ==============================================================================

set project_name "AXI_Interconnect_System"

puts "\n===================================================================="
puts "AXI Interconnect System - Complete Quartus Flow"
puts "===================================================================="
puts "This script will:"
puts "  1. Create Quartus project"
puts "  2. Add all source files"
puts "  3. Set timing constraints"
puts "  4. Compile the design"
puts "===================================================================="

set script_dir [file normalize [file dirname [info script]]]

# ==============================================================================
# STEP 1: CREATE PROJECT
# ==============================================================================
puts "\n[STEP 1/4] Creating Quartus Project..."
puts "--------------------------------------------------------------------"
if {[catch {source [file join $script_dir "create_project.tcl"]} result]} {
    puts "✗ Project creation failed!"
    puts $result
    exit 1
}

# ==============================================================================
# STEP 2: ADD SOURCE FILES
# ==============================================================================
puts "\n[STEP 2/4] Adding Source Files..."
puts "--------------------------------------------------------------------"
if {[catch {source [file join $script_dir "add_source_files.tcl"]} result]} {
    puts "✗ Adding source files failed!"
    puts $result
    exit 1
}

# ==============================================================================
# STEP 3: SET PIN ASSIGNMENTS (Optional - may need customization)
# ==============================================================================
puts "\n[STEP 3/4] Setting Pin Assignments..."
puts "--------------------------------------------------------------------"
puts "⚠ Skipping automatic pin assignment (requires board customization)"
puts "  To set pins: Edit and run set_pin_assignments.tcl manually"

# Uncomment below to run automatic pin assignment (after customizing)
# if {[catch {source [file join $script_dir "set_pin_assignments.tcl"]} result]} {
#     puts "⚠ Pin assignment had warnings (may need customization)"
#     puts $result
# }

# ==============================================================================
# STEP 4: COMPILE PROJECT
# ==============================================================================
puts "\n[STEP 4/4] Compiling Project..."
puts "--------------------------------------------------------------------"
puts "This may take several minutes..."

if {[catch {source [file join $script_dir "compile_project.tcl"]} result]} {
    puts "✗ Compilation failed!"
    puts $result
    exit 1
}

# ==============================================================================
# COMPLETION
# ==============================================================================
puts "\n===================================================================="
puts "✓ COMPLETE FLOW FINISHED!"
puts "===================================================================="
puts ""
puts "Results:"
puts "  • Project created: $project_name"
puts "  • Files compiled successfully"
puts "  • Programming files generated"
puts ""
puts "Output files location:"
puts "  synthesis/quartus/output_files/"
puts ""
puts "Next steps:"
puts "  1. Review compilation reports"
puts "  2. Check timing analysis (sta.rpt)"
puts "  3. Customize pin assignments if needed"
puts "  4. Program your FPGA"
puts "===================================================================="
puts ""

exit 0

