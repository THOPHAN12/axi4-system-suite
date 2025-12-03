# ==============================================================================
# Quartus Project Creation Script for AXI Interconnect System
# ==============================================================================
# Description: Creates a new Quartus project with all necessary files
# Usage: quartus_sh -t create_project.tcl
# ==============================================================================

# ==============================================================================
# PROJECT CONFIGURATION
# ==============================================================================

# Project name and device settings
set project_name "AXI_Interconnect_System"
set top_level_entity "dual_riscv_axi_system"

# FPGA Device (change according to your board)
set device_family "Cyclone V"
set device_part "5CSEMA5F31C6"

# Alternative devices (uncomment as needed):
# set device_family "Cyclone IV E"
# set device_part "EP4CE115F29C7"

# set device_family "Cyclone 10 LP"
# set device_part "10CL025YU256C8G"

# set device_family "Arria 10"
# set device_part "10AS066N3F40E2SG"

# ==============================================================================
# PATH CONFIGURATION
# ==============================================================================

# Get script directory and project root
set script_dir [file normalize [file dirname [info script]]]
# From synthesis/scripts/quartus -> go up 3 levels to project root
set project_root [file normalize [file join $script_dir .. .. ..]]
set project_dir [file join $project_root "synthesis" "quartus"]

# Create project directory if it doesn't exist
file mkdir $project_dir

# Source directories
set src_dir [file join $project_root "src"]
set tb_dir [file join $project_root "tb"]

puts "\n===================================================================="
puts "AXI Interconnect - Quartus Project Creation"
puts "===================================================================="
puts "Project Name: $project_name"
puts "Top-Level: $top_level_entity"
puts "Device: $device_family - $device_part"
puts "Project Root: $project_root"
puts "Project Directory: $project_dir"
puts "====================================================================\n"

# ==============================================================================
# CREATE NEW PROJECT
# ==============================================================================

# Check if project already exists
set qpf_file [file join $project_dir "${project_name}.qpf"]
if {[file exists $qpf_file]} {
    puts "⚠ Project already exists: $qpf_file"
    puts "Opening existing project...\n"
    project_open [file join $project_dir $project_name]
} else {
    puts "Creating new project: $project_name\n"
    project_new [file join $project_dir $project_name]
}

# ==============================================================================
# PROJECT SETTINGS
# ==============================================================================

puts "Configuring project settings..."

# Device settings
set_global_assignment -name FAMILY $device_family
set_global_assignment -name DEVICE $device_part

# Top-level entity
set_global_assignment -name TOP_LEVEL_ENTITY $top_level_entity

# Compilation settings
set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
set_global_assignment -name OPTIMIZATION_MODE "AGGRESSIVE PERFORMANCE"
set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

# Timing settings
set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
set_global_assignment -name TIMEQUEST_DO_REPORT_TIMING ON

# Incremental compilation
set_global_assignment -name INCREMENTAL_COMPILATION ON

# Message settings
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files

puts "✓ Project settings configured\n"

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

# Function to add a Verilog file
proc add_verilog_file {file_path} {
    if {[file exists $file_path]} {
        set_global_assignment -name VERILOG_FILE $file_path
        puts "  ✓ Added: [file tail $file_path]"
        return 1
    } else {
        puts "  ✗ Missing: [file tail $file_path]"
        return 0
    }
}

# Function to add all files from a directory
proc add_directory_files {dir_path pattern} {
    set count 0
    if {[file exists $dir_path]} {
        set files [glob -nocomplain [file join $dir_path $pattern]]
        foreach file $files {
            if {[add_verilog_file $file]} {
                incr count
            }
        }
    }
    return $count
}

puts "✓ Project created and configured successfully!"
puts "\nNext steps:"
puts "1. Run: quartus_sh -t add_source_files.tcl"
puts "2. Set pin assignments (if needed)"
puts "3. Compile: quartus_sh --flow compile $project_name"
puts "====================================================================\n"

# Close project
project_close

