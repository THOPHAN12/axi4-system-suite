#==============================================================================
# fix_simulation_lock.tcl
# Fix simulation lock issues by closing existing simulations
#==============================================================================

puts "============================================================================"
puts "Fixing Simulation Lock Issues"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    return
}

# Step 1: Close any existing simulation
puts "Step 1: Closing existing simulations..."
set sim_count 0
while {[current_sim] != ""} {
    puts "  Closing simulation: [current_sim]"
    catch {close_sim -force}
    set sim_count [expr $sim_count + 1]
    after 100
}

if {$sim_count > 0} {
    puts "  ✓ Closed $sim_count simulation(s)"
} else {
    puts "  ✓ No simulation running"
}
puts ""

# Step 2: Wait a bit for file handles to release
puts "Step 2: Waiting for file handles to release..."
after 500
puts "  ✓ Wait completed"
puts ""

# Step 3: Try to clean up simulation directory (optional)
puts "Step 3: Checking simulation directory..."
set sim_dir [file join [get_property DIRECTORY [current_project]] [current_project].sim sim_1 behav xsim]
if {[file exists $sim_dir]} {
    puts "  Simulation directory exists: $sim_dir"
    puts "  Note: If issues persist, you may need to manually close any file viewers"
    puts "        or restart Vivado"
} else {
    puts "  Simulation directory not found (will be created on next run)"
}
puts ""

puts "============================================================================"
puts "Fix Complete!"
puts "============================================================================"
puts ""
puts "Next steps:"
puts "  1. Try running simulation again: launch_simulation"
puts "  2. If still fails, restart Vivado"
puts "  3. Or manually delete simulation directory if needed"
puts ""


