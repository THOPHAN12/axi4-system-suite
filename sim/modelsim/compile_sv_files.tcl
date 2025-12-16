#==============================================================================
# compile_sv_files.tcl
# Compile SystemVerilog files in correct dependency order
# Usage: In ModelSim TCL Console, type: do compile_sv_files.tcl
#==============================================================================

puts "============================================================================"
puts "Compile SystemVerilog Files in Dependency Order"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. ..]]

set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set AXI_SV_RTL [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl"]]
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

# Ensure work library exists and is properly mapped
if {![file exists [file join $PROJECT_DIR "work"]]} {
    vlib work
    puts "Created work library"
} else {
    # Make sure work library is mapped
    catch {vmap work work}
}

# Ensure work library directory structure exists (for older ModelSim versions)
set work_dir [file join $PROJECT_DIR "work"]
if {[file exists $work_dir] && ![file isdirectory $work_dir]} {
    file mkdir $work_dir
}

# Workaround for ModelSim 10.1d: Create problematic library directories manually
# ModelSim 10.1d has issues creating library files for modules with special name patterns
set problematic_modules [list \
    "@demux_1_2" \
    "@write_@arbiter_@r@r" \
    "@controller" \
]
foreach mod_dir $problematic_modules {
    set mod_path [file join $work_dir $mod_dir]
    if {![file exists $mod_path]} {
        if {[catch {file mkdir $mod_path} mkdir_err]} {
            # Ignore errors - ModelSim will try to create it anyway
        }
    }
}

# Set include paths for `include directives
# This tells ModelSim where to look for included files
# Need packages directory so that "axi_pkg.sv" can be found
set AXI_PACKAGES_DIR [file normalize [file join $AXI_SV_RTL "packages"]]
set include_paths [list $AXI_PACKAGES_DIR $AXI_SV_RTL]
set incdir_options ""
foreach path $include_paths {
    if {[file exists $path]} {
        # Build +incdir+ options for vlog
        # Use forward slashes for ModelSim compatibility
        set path_normalized [string map {\\ /} $path]
        append incdir_options "+incdir+$path_normalized "
        puts "Include path: $path_normalized"
    }
}

puts ""
puts "Compiling files in dependency order..."
puts ""

# Step 1: Compile packages first
puts "\[1/4\] Compiling Packages..."
set pkg_file [file normalize [file join $AXI_SV_RTL "packages" "axi_pkg.sv"]]
if {[file exists $pkg_file]} {
    # Compile with include directories
    if {[catch {vlog -work work $incdir_options $pkg_file} err]} {
        puts "  ERROR compiling $pkg_file: $err"
    } else {
        puts "  ✓ Compiled: axi_pkg.sv"
    }
} else {
    puts "  WARNING: Package file not found: $pkg_file"
}
puts ""

# Step 2: Compile interfaces (depend on packages)
puts "\[2/4\] Compiling Interfaces..."
set if_file [file normalize [file join $AXI_SV_RTL "interfaces" "axi4_if.sv"]]
if {[file exists $if_file]} {
    # Change to rtl/ directory so relative path ../packages/ works
    set old_dir [pwd]
    cd $AXI_SV_RTL
    
    # Compile using relative path from rtl/ directory
    # File uses "../packages/axi_pkg.sv" which works when compiling from rtl/
    set if_file_rel "interfaces/axi4_if.sv"
    set pkg_path_normalized [string map {\\ /} $AXI_PACKAGES_DIR]
    set incdir_pkg_only "+incdir+$pkg_path_normalized"
    
    if {[catch {vlog -work work $incdir_pkg_only $if_file_rel} err]} {
        puts "  ERROR compiling $if_file: $err"
        puts "  Include path used: $incdir_pkg_only"
        puts "  Package file location: $AXI_PACKAGES_DIR/axi_pkg.sv"
        puts "  Current directory: [pwd]"
    } else {
        puts "  ✓ Compiled: axi4_if.sv"
    }
    
    # Restore directory
    cd $old_dir
} else {
    puts "  WARNING: Interface file not found: $if_file"
}
puts ""

# Step 3: Compile utils and buffers
puts "\[3/4\] Compiling Utils and Buffers..."
set utils_dirs [list \
    [file normalize [file join $AXI_SV_RTL "utils"]] \
    [file normalize [file join $AXI_SV_RTL "buffers"]] \
]
foreach dir $utils_dirs {
    if {[file exists $dir]} {
        set sv_files [glob -nocomplain -directory $dir -type f "*.sv"]
        foreach file $sv_files {
            if {[catch {vlog -work work $incdir_options $file} err]} {
                puts "  ERROR compiling [file tail $file]: $err"
            } else {
                puts "  ✓ Compiled: [file tail $file]"
            }
        }
    }
}
puts ""

# Step 4: Compile all remaining files
puts "\[4/4\] Compiling All Remaining Files..."
puts "  (This may take a while...)"

# Get all remaining .sv files
set remaining_dirs [list \
    [file normalize [file join $AXI_SV_RTL "datapath"]] \
    [file normalize [file join $AXI_SV_RTL "decoders"]] \
    [file normalize [file join $AXI_SV_RTL "handshake"]] \
    [file normalize [file join $AXI_SV_RTL "arbitration"]] \
    [file normalize [file join $AXI_SV_RTL "channel_controllers"]] \
    [file normalize [file join $AXI_SV_RTL "core"]] \
]

proc compile_dir_recursive {dir incdir_opts project_dir} {
    set count 0
    if {![file exists $dir]} {
        return 0
    }
    
    # Compile .sv files in current directory
    set sv_files [glob -nocomplain -directory $dir -type f "*.sv"]
    foreach file $sv_files {
        set file_tail [file tail $file]
        
        # Pre-create library directory for known problematic modules
        set problematic_files [list "Demux_1_2.sv" "Write_Arbiter_RR.sv" "Controller.sv"]
        set is_problematic 0
        foreach prob_file $problematic_files {
            if {[string match "*$prob_file" $file]} {
                set is_problematic 1
                # Try to determine the library directory name ModelSim will use
                # ModelSim converts module names to library dirs with @ prefix for special chars
                set work_dir [file join $project_dir "work"]
                # Create a dummy directory to help ModelSim
                if {[string match "*Demux_1_2*" $file]} {
                    set lib_dir [file join $work_dir "@demux_1_2"]
                } elseif {[string match "*Write_Arbiter_RR*" $file]} {
                    set lib_dir [file join $work_dir "@write_@arbiter_@r@r"]
                } elseif {[string match "*Controller.sv" $file]} {
                    set lib_dir [file join $work_dir "@controller"]
                }
                if {[info exists lib_dir] && ![file exists $lib_dir]} {
                    catch {file mkdir $lib_dir}
                }
                break
            }
        }
        
        if {[catch {vlog -work work $incdir_opts $file} err]} {
            # Check if this is a known ModelSim 10.1d issue with special characters in module names
            if {[string match "*Failed to open library file*@*" $err] || [string match "*vlog-7*" $err]} {
                puts "  WARNING: ModelSim 10.1d library issue with $file_tail (module name with special chars)"
                puts "    Error: $err"
                puts "    This is a known limitation of ModelSim 10.1d."
                puts "    Attempting workaround: creating library directory manually..."
                
                # Extract module name from error or file
                if {[regexp {@"([^"]+)"} $err match mod_name]} {
                    set lib_dir [file join $project_dir "work" $mod_name]
                    if {![file exists $lib_dir]} {
                        if {[catch {file mkdir $lib_dir} mkdir_err]} {
                            puts "    Could not create directory: $mkdir_err"
                        } else {
                            puts "    Created library directory: $lib_dir"
                            # Try compiling again
                            if {[catch {vlog -work work $incdir_opts $file} err2]} {
                                puts "    ERROR: Still failed after creating directory: $err2"
                                puts "    Skipping this file. Other files will continue to compile."
                            } else {
                                puts "    ✓ Compiled successfully after workaround: $file_tail"
                                incr count
                            }
                        }
                    }
                } else {
                    puts "    Could not extract module name from error. Skipping file."
                }
            } else {
                puts "  ERROR compiling $file_tail: $err"
            }
        } else {
            incr count
        }
    }
    
    # Recursively compile subdirectories
    set dirs [glob -nocomplain -directory $dir -type d *]
    foreach subdir $dirs {
        set sub_count [compile_dir_recursive $subdir $incdir_opts $project_dir]
        set count [expr $count + $sub_count]
    }
    
    return $count
}

set compiled_count 0
foreach dir $remaining_dirs {
    if {[file exists $dir]} {
        set count [compile_dir_recursive $dir $incdir_options $PROJECT_DIR]
        set compiled_count [expr $compiled_count + $count]
    }
}

# Compile files from other directories (cores, etc.)
set other_dirs [list \
    [file normalize [file join $SRC_BASE "cores"]] \
]
foreach dir $other_dirs {
    if {[file exists $dir]} {
        set count [compile_dir_recursive $dir $incdir_options $PROJECT_DIR]
        set compiled_count [expr $compiled_count + $count]
    }
}

puts ""
puts "============================================================================"
puts "Compilation Summary"
puts "============================================================================"
puts "Remaining files compiled: $compiled_count"
puts ""
puts "Done! Check for errors above."
puts ""
puts "If you see include errors, make sure:"
puts "  1. Include path is set correctly: $AXI_SV_RTL"
puts "  2. Files are compiled in dependency order (packages first)"
puts "============================================================================"

