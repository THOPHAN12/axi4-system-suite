#==============================================================================
# create_sv_kv260_project.tcl
# Create Vivado project for SystemVerilog modules with KV260 target
# Target: Xilinx Kria KV260 Vision AI Starter Kit
# Device: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
# Purpose: SystemVerilog Simulation
#
# Usage: In Vivado TCL Console:
#   source create_sv_kv260_project.tcl
#==============================================================================

puts "============================================================================"
puts "Create Vivado Project for SystemVerilog - KV260"
puts "============================================================================"
puts ""

# Get script directory and calculate paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_ROOT [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]

# Verify PROJECT_ROOT exists
if {![file exists $PROJECT_ROOT]} {
    puts "ERROR: Cannot determine project root!"
    puts "Script directory: $SCRIPT_DIR"
    puts "Calculated root: $PROJECT_ROOT"
    return
}

set PROJECT_NAME "axi4_system_sv_kv260"
set PROJECT_DIR [file normalize [file join $SCRIPT_DIR $PROJECT_NAME]]
set SV_BASE [file normalize [file join $PROJECT_ROOT "SystemVerilog"]]

puts "Script directory: $SCRIPT_DIR"
puts "Project root: $PROJECT_ROOT"
puts "Project directory: $PROJECT_DIR"
puts "SystemVerilog base: $SV_BASE"
puts ""

#==============================================================================
# Step 1: Create Vivado Project
#==============================================================================
puts "============================================================================"
puts "Step 1: Creating Vivado Project"
puts "============================================================================"

# Close any existing project
if {[catch {current_project} err]} {
    puts "No project currently open"
} else {
    puts "Closing current project..."
    close_project
}

# Remove existing project directory if exists
if {[file exists $PROJECT_DIR]} {
    puts "Removing existing project directory..."
    file delete -force $PROJECT_DIR
}

# Create new project
create_project $PROJECT_NAME $PROJECT_DIR -part xczu5ev-sfvc784-1-e -force

puts "Project created: $PROJECT_NAME"
puts "Target device: xczu5ev-sfvc784-1-e (KV260)"
puts ""

#==============================================================================
# Step 2: Set Project Properties
#==============================================================================
puts "============================================================================"
puts "Step 2: Setting Project Properties"
puts "============================================================================"

# Set project properties for SystemVerilog
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]

# Set simulation properties
set_property target_simulator XSim [current_project]

# Get sim_1 fileset
set sim_fileset [get_filesets sim_1]

# Set simulation runtime (increased for testbenches that need more time)
# Testbenches will use $finish to end simulation, but this provides a safety timeout
set_property -name {xsim.simulate.runtime} -value {100us} -objects $sim_fileset

# Enable SystemVerilog compilation
# Note: Vivado auto-detects .sv files, but we explicitly enable SV mode
catch {
    set_property -name {xsim.compile.xvlog.more_options} -value {-sv} -objects $sim_fileset
}

# Enable debug logging
set_property -name {xsim.elaborate.debug_level} -value {all} -objects $sim_fileset
set_property -name {xsim.simulate.log_all_signals} -value {true} -objects $sim_fileset

puts "Project properties set"
puts "SystemVerilog support enabled"
puts ""

#==============================================================================
# Step 3: Add SystemVerilog Source Files
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding SystemVerilog Source Files"
puts "============================================================================"

set file_count 0

# Function to add files from pattern
proc add_sv_files {pattern description} {
    global file_count
    set files [glob -nocomplain $pattern]
    if {[llength $files] > 0} {
        add_files -fileset sources_1 $files
        set count [llength $files]
        set file_count [expr $file_count + $count]
        puts "  ✓ $description: $count files"
        return $count
    } else {
        puts "  ⚠ $description: No files found"
        return 0
    }
}

# Add AXI Interconnect SystemVerilog files
puts "Adding AXI Interconnect files..."
add_sv_files [file join $SV_BASE axi_interconnect arbitration algorithms *.sv] "Arbitration algorithms"
add_sv_files [file join $SV_BASE axi_interconnect buffers *.sv] "Buffers"
add_sv_files [file join $SV_BASE axi_interconnect channel_controllers read *.sv] "Read channel controllers"
add_sv_files [file join $SV_BASE axi_interconnect channel_controllers write *.sv] "Write channel controllers"
add_sv_files [file join $SV_BASE axi_interconnect core *.sv] "Core modules"
add_sv_files [file join $SV_BASE axi_interconnect datapath demux *.sv] "Demux datapath"
add_sv_files [file join $SV_BASE axi_interconnect datapath mux *.sv] "Mux datapath"
add_sv_files [file join $SV_BASE axi_interconnect decoders *.sv] "Decoders"
add_sv_files [file join $SV_BASE axi_interconnect handshake *.sv] "Handshake modules"
add_sv_files [file join $SV_BASE axi_interconnect utils *.sv] "Utils"

# Add AXI Bridge files
puts ""
puts "Adding AXI Bridge files..."
add_sv_files [file join $SV_BASE axi_bridge *.sv] "AXI Bridge modules"

# Add AXI Masters files (including master_controller.sv)
puts ""
puts "Adding AXI Masters files (including Controller)..."
add_sv_files [file join $SV_BASE axi_masters *.sv] "AXI Master modules (including master_controller.sv)"

# Add Peripherals files
puts ""
puts "Adding Peripherals files..."
add_sv_files [file join $SV_BASE peripherals axi_lite *.sv] "AXI-Lite peripherals"

puts ""
puts "Total SystemVerilog source files added: $file_count"
puts ""

#==============================================================================
# Step 4: Add Testbenches (if they exist)
#==============================================================================
puts "============================================================================"
puts "Step 4: Adding Testbench Files"
puts "============================================================================"

set tb_dir [file join $SV_BASE testbenches]
set tb_count 0

if {[file exists $tb_dir]} {
    set tb_files [glob -nocomplain [file join $tb_dir ** *.sv]]
    if {[llength $tb_files] > 0} {
        add_files -fileset sim_1 $tb_files
        set tb_count [llength $tb_files]
        puts "  ✓ Testbench files: $tb_count files"
    } else {
        puts "  ⚠ No testbench files found in $tb_dir"
    }
} else {
    puts "  ⚠ Testbench directory not found: $tb_dir"
    puts "     Create testbenches in: SystemVerilog/testbenches/"
}

puts ""

#==============================================================================
# Step 5: Set Include Directories
#==============================================================================
puts "============================================================================"
puts "Step 5: Setting Include Directories"
puts "============================================================================"

set include_dirs [list \
    [file join $SV_BASE axi_interconnect] \
    [file join $SV_BASE axi_bridge] \
    [file join $SV_BASE axi_masters] \
    [file join $SV_BASE peripherals] \
]

set_property include_dirs $include_dirs [current_fileset]

puts "Include directories set:"
foreach dir $include_dirs {
    puts "  - $dir"
}
puts ""

#==============================================================================
# Step 6: Set File Types for SystemVerilog
#==============================================================================
puts "============================================================================"
puts "Step 6: Setting File Types for SystemVerilog"
puts "============================================================================"

# Set file type for SystemVerilog files in sources_1
set sv_files [get_files -of_objects [get_filesets sources_1] -filter {FILE_TYPE == Verilog}]
set sv_count 0
foreach file $sv_files {
    set file_ext [file extension $file]
    if {$file_ext == ".sv"} {
        set_property file_type {SystemVerilog} $file
        set sv_count [expr $sv_count + 1]
    }
}

# Also set for simulation files
set sv_sim_files [get_files -of_objects [get_filesets sim_1] -filter {FILE_TYPE == Verilog}]
foreach file $sv_sim_files {
    set file_ext [file extension $file]
    if {$file_ext == ".sv"} {
        set_property file_type {SystemVerilog} $file
        set sv_count [expr $sv_count + 1]
    }
}

puts "File types set for $sv_count SystemVerilog files"
puts ""

#==============================================================================
# Step 7: Update Compile Order
#==============================================================================
puts "============================================================================"
puts "Step 7: Updating Compile Order"
puts "============================================================================"

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Compile order updated"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Project Setup Complete!"
puts "============================================================================"
puts ""
puts "Project Name: $PROJECT_NAME"
puts "Project Location: $PROJECT_DIR"
puts "Target Device: xczu5ev-sfvc784-1-e (KV260)"
puts "Source Files: $file_count"
puts "Testbench Files: $tb_count"
puts ""

# Verify Controller was added
set controller_file [get_files -quiet -of_objects [get_filesets sources_1] "*master_controller.sv"]
if {[llength $controller_file] > 0} {
    puts "✓ Controller verified: master_controller.sv"
} else {
    puts "⚠ Warning: master_controller.sv not found in project"
    puts "  Expected location: $SV_BASE/axi_masters/master_controller.sv"
}
puts ""

puts "Next Steps:"
puts "  1. Set simulation top: set_property top <testbench_name> [get_filesets sim_1]"
puts "  2. Run simulation: launch_simulation"
puts "  3. Or use script: set tb <testbench_name>; source run_sv_simulation.tcl"
puts ""
puts "For detailed instructions, see: QUICK_START_SV_KV260.md"
puts ""


