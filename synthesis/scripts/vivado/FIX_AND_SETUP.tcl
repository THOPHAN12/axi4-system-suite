#==============================================================================
# FIX_AND_SETUP.tcl
# Fix common issues and setup simulation properly
#==============================================================================

puts "============================================================================"
puts "Fix and Setup Simulation"
puts "============================================================================"
puts ""

# Step 1: Close existing simulation with force
puts "Step 1: Closing existing simulation..."
if {[catch {close_sim -force} err]} {
    puts "  Note: $err"
} else {
    puts "  ✓ Simulation closed"
}
puts ""

# Step 2: Check if testbench file exists
puts "Step 2: Checking testbench file..."
set tb_file "C:/Users/Nguyen Ha Hai/axi4-system-suite/verification/testbenches/system_tb/dual_riscv_system_tb.v"
if {[file exists $tb_file]} {
    puts "  ✓ Testbench file found: $tb_file"
} else {
    puts "  ✗ ERROR: Testbench file not found: $tb_file"
    puts "  Please check file path"
    return
}
puts ""

# Step 3: Ensure testbench is in sim_1 fileset
puts "Step 3: Checking testbench in project..."
set tb_in_project [get_files -quiet -of_objects [get_filesets sim_1] $tb_file]
if {[llength $tb_in_project] == 0} {
    puts "  WARNING: Testbench not in sim_1 fileset, adding..."
    add_files -fileset sim_1 -norecurse $tb_file
    puts "  ✓ Testbench added to sim_1"
} else {
    puts "  ✓ Testbench already in sim_1"
}
puts ""

# Step 4: Set testbench as top
puts "Step 4: Setting testbench as simulation top..."
set_property top dual_riscv_system_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
puts "  ✓ Testbench set as top: dual_riscv_system_tb"
puts ""

# Step 5: Set debug options
puts "Step 5: Setting debug options..."
set_property -name {xsim.elaborate.debug_level} -value {all} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
puts "  ✓ Debug options set"
puts ""

# Step 6: Update compile order
puts "Step 6: Updating compile order..."
update_compile_order -fileset sim_1
puts "  ✓ Compile order updated"
puts ""

# Step 7: Launch simulation
puts "Step 7: Launching simulation..."
if {[catch {launch_simulation} err]} {
    puts "  ✗ ERROR launching simulation: $err"
    puts ""
    puts "Please check:"
    puts "  1. All source files are compiled"
    puts "  2. Testbench has no syntax errors"
    puts "  3. Dependencies are resolved"
    return
} else {
    puts "  ✓ Simulation launched successfully"
}
puts ""

puts "============================================================================"
puts "Setup complete!"
puts "============================================================================"
puts ""
puts "Next steps:"
puts "  1. Setup waveform: source setup_waveform_simple.tcl"
puts "  2. Run simulation: run 50us"
puts ""



