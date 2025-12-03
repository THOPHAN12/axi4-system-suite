#==============================================================================
# add_all_files.tcl
# Add ALL files (Verilog + SystemVerilog) to ModelSim project
# Usage: do add_all_files.tcl
#==============================================================================

puts "=========================================="
puts "Adding All Files (Verilog + SystemVerilog)"
puts "=========================================="

puts "\nThis will add BOTH .v and .sv files"
puts "For Verilog only: use add_verilog_files.tcl"
puts "For SystemVerilog only: use add_systemverilog_files.tcl"
puts ""

# Add Verilog files
puts "Step 1: Adding Verilog files..."
source add_verilog_files.tcl

# Add SystemVerilog files
puts "\nStep 2: Adding SystemVerilog files..."
source add_systemverilog_files.tcl

puts "\n=========================================="
puts "Complete!"
puts "=========================================="
puts "Verilog files:       88"
puts "SystemVerilog files: ~118"
puts "----------------------------------------"
puts "TOTAL:               ~206 files"
puts "=========================================="
puts ""
puts "✅ All files added to project!"
puts ""
puts "Next steps:"
puts "  Compile All: Right-click → Compile → Compile All"
puts "=========================================="
