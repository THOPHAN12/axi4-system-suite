#==============================================================================
# add_all_sv_files.tcl
# Add ALL SystemVerilog (.sv) files from src folder to ModelSim project
# Compatible with ModelSim 10.1d
# Usage: In ModelSim TCL Console, type: do add_all_sv_files.tcl
#==============================================================================

puts "============================================================================"
puts "Add ALL SystemVerilog Files from src/ to AXI_Project"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. ..]]

set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set PROJECT_FILE [file normalize [file join $PROJECT_DIR "AXI_Project.mpf"]]

# Change to project directory
cd $PROJECT_DIR

# Check if project is open, if not, open it
set project_is_open 0
if {[catch {set current_project [project]} err]} {
    # No project open, try to open it
    puts "Opening project: $PROJECT_FILE"
    if {[file exists $PROJECT_FILE]} {
        if {[catch {project open $PROJECT_FILE} open_err]} {
            puts "ERROR: Cannot open project: $open_err"
            puts "Please open the project manually first:"
            puts "  File -> Open -> $PROJECT_FILE"
            return
        } else {
            set project_is_open 1
            puts "Project opened successfully!"
        }
    } else {
        puts "ERROR: Project file not found: $PROJECT_FILE"
        puts "Please create the project first:"
        puts "  File -> New -> Project -> AXI_Project"
        return
    }
} else {
    set project_is_open 1
    puts "Project already open: $current_project"
}

# Verify project is actually open
if {!$project_is_open} {
    if {[catch {set current_project [project]} verify_err]} {
        puts "ERROR: Project verification failed. Project is not open."
        return
    }
}

puts ""
puts "Source directory: $SRC_BASE"
puts ""

# Set include paths for ModelSim to find included files
set AXI_SV_RTL [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl"]]

# Ensure work library exists
if {![file exists [file join $PROJECT_DIR "work"]]} {
    vlib work
    puts "Created work library"
}

puts "Scanning and adding SystemVerilog files in dependency order..."
puts ""

# Helper function to add file with error checking
proc add_file_safe {file_path {file_type "SystemVerilog"}} {
    set full_path [file normalize $file_path]
    if {[file exists $full_path]} {
        if {[catch {project addfile $full_path} err]} {
            # File might already be in project, that's okay
            return 0
        }
        return 1
    }
    return 0
}

# Recursive function to find all .sv files
proc find_all_sv_files {base_dir {exclude_dirs {}}} {
    set file_list [list]
    if {![file exists $base_dir]} {
        return $file_list
    }
    
    # Get all .sv files in current directory
    set sv_files [glob -nocomplain -directory $base_dir -type f "*.sv"]
    foreach file $sv_files {
        lappend file_list $file
    }
    
    # Recursively search subdirectories
    set dirs [glob -nocomplain -directory $base_dir -type d *]
    foreach dir $dirs {
        set dir_name [file tail $dir]
        # Skip excluded directories
        if {[lsearch -exact $exclude_dirs $dir_name] >= 0} {
            continue
        }
        set sub_files [find_all_sv_files $dir $exclude_dirs]
        foreach sub_file $sub_files {
            lappend file_list $sub_file
        }
    }
    
    return $file_list
}

# Add files in correct dependency order
set total_added 0
set pkg_count 0
set if_count 0
set utils_count 0
set buffers_count 0
set axi_rtl_count 0
set other_count 0

# Step 1: Packages (MUST be compiled first)
puts "\[1/5\] Adding Packages..."
set packages_dir [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl" "packages"]]
if {[file exists $packages_dir]} {
    set pkg_files [glob -nocomplain -directory $packages_dir -type f "*.sv"]
    foreach file $pkg_files {
        if {[add_file_safe $file]} {
            incr total_added
            incr pkg_count
            puts "  ✓ Added: [file tail $file]"
        }
    }
}
puts "  Packages added: $pkg_count"
puts ""

# Step 2: Interfaces (depend on packages)
puts "\[2/5\] Adding Interfaces..."
set interfaces_dir [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl" "interfaces"]]
if {[file exists $interfaces_dir]} {
    set if_files [glob -nocomplain -directory $interfaces_dir -type f "*.sv"]
    foreach file $if_files {
        if {[add_file_safe $file]} {
            incr total_added
            incr if_count
            puts "  ✓ Added: [file tail $file]"
        }
    }
}
puts "  Interfaces added: $if_count"
puts ""

# Step 3: Utils and Buffers
puts "\[3/5\] Adding Utils and Buffers..."
set utils_dir [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl" "utils"]]
if {[file exists $utils_dir]} {
    set sv_files [glob -nocomplain -directory $utils_dir -type f "*.sv"]
    foreach file $sv_files {
        if {[add_file_safe $file]} {
            incr total_added
            incr utils_count
        }
    }
}
set buffers_dir [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl" "buffers"]]
if {[file exists $buffers_dir]} {
    set sv_files [glob -nocomplain -directory $buffers_dir -type f "*.sv"]
    foreach file $sv_files {
        if {[add_file_safe $file]} {
            incr total_added
            incr buffers_count
        }
    }
}
puts "  Utils added: $utils_count"
puts "  Buffers added: $buffers_count"
puts ""

# Step 4: All other SystemVerilog files in AXI Interconnect RTL
puts "\[4/5\] Adding AXI Interconnect RTL Files..."
set exclude_dirs [list "packages" "interfaces" "utils" "buffers"]
set axi_rtl_files [find_all_sv_files $AXI_SV_RTL $exclude_dirs]
foreach file $axi_rtl_files {
    if {[add_file_safe $file]} {
        incr total_added
        incr axi_rtl_count
    }
}
puts "  AXI RTL files added: $axi_rtl_count"
puts ""

# Step 5: Add files from other directories (cores, systems, etc.)
puts "\[5/5\] Adding Files from Other Directories..."
set other_dirs [list \
    [file normalize [file join $SRC_BASE "cores"]] \
    [file normalize [file join $SRC_BASE "systems"]] \
    [file normalize [file join $SRC_BASE "axi_bridge"]] \
    [file normalize [file join $SRC_BASE "axi_full"]] \
    [file normalize [file join $SRC_BASE "axi_stream"]] \
    [file normalize [file join $SRC_BASE "peripherals"]] \
]
foreach dir $other_dirs {
    if {[file exists $dir]} {
        set dir_files [find_all_sv_files $dir {}]
        set dir_count 0
        foreach file $dir_files {
            if {[add_file_safe $file]} {
                incr total_added
                incr dir_count
                incr other_count
            }
        }
        if {$dir_count > 0} {
            set dir_name [file tail $dir]
            puts "  ✓ $dir_name: $dir_count files"
        }
    }
}
puts "  Other directories files added: $other_count"
puts ""

# Summary
puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "Packages:              $pkg_count files"
puts "Interfaces:            $if_count files"
puts "Utils:                 $utils_count files"
puts "Buffers:               $buffers_count files"
puts "AXI Interconnect RTL:  $axi_rtl_count files"
puts "Other directories:     $other_count files"
puts "----------------------------------------"
puts "TOTAL:                 $total_added SystemVerilog files added"
puts "============================================================================"
puts ""
puts "Done! All SystemVerilog files from src/ have been added to the project."
puts ""
puts "IMPORTANT: Compilation Order"
puts "  Files have been added in dependency order:"
puts "    1. Packages (axi_pkg.sv) - MUST compile first"
puts "    2. Interfaces (axi4_if.sv) - depends on packages"
puts "    3. Utils and Buffers - supporting modules"
puts "    4. AXI Interconnect RTL - core modules"
puts "    5. Other directories - cores, systems, etc."
puts ""
puts "Next steps:"
puts "  1. Compile files using: do compile_sv_files.tcl"
puts "     This script will compile in the correct dependency order with proper include paths"
puts ""
puts "  2. Or compile manually:"
puts "     - First: Right-click on axi_pkg.sv -> Compile -> Compile Selected"
puts "     - Then: Right-click -> Compile -> Compile All"
puts "============================================================================"
