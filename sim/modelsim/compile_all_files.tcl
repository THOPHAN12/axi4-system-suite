#==============================================================================
# compile_all_files.tcl
# Compile all files (Verilog + SystemVerilog) with error handling
# Skips files that are incompatible with ModelSim 10.1d
# Usage: In ModelSim TCL Console, type: do compile_all_files.tcl
#==============================================================================

puts "============================================================================"
puts "Compile All Files (Verilog + SystemVerilog) - ModelSim 10.1d Compatible"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. ..]]

set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]
set PROJECT_FILE [file normalize [file join $PROJECT_DIR "AXI_Project.mpf"]]

# Change to project directory
cd $PROJECT_DIR

# Check if project is open
set project_is_open 0
if {[catch {set current_project [project]} err]} {
    puts "Opening project: $PROJECT_FILE"
    if {[file exists $PROJECT_FILE]} {
        if {[catch {project open $PROJECT_FILE} open_err]} {
            puts "ERROR: Cannot open project: $open_err"
            return
        } else {
            set project_is_open 1
            puts "Project opened successfully!"
        }
    } else {
        puts "ERROR: Project file not found: $PROJECT_FILE"
        return
    }
} else {
    set project_is_open 1
    puts "Project already open: $current_project"
}

# Ensure work library exists
if {![file exists [file join $PROJECT_DIR "work"]]} {
    vlib work
    puts "Created work library"
}

# Set include paths
set AXI_SV_RTL [file normalize [file join $SRC_BASE "axi_interconnect" "SystemVerilog" "rtl"]]
set AXI_PACKAGES_DIR [file normalize [file join $AXI_SV_RTL "packages"]]
set include_paths [list $AXI_PACKAGES_DIR $AXI_SV_RTL]
# Build incdir options as a list (each option is a separate element)
# This will be used to build command properly
set incdir_options_list [list]
foreach path $include_paths {
    if {[file exists $path]} {
        set path_normalized [string map {\\ /} $path]
        # Build +incdir+ option as single string
        lappend incdir_options_list "+incdir+$path_normalized"
    }
}
# Keep as list for proper handling of paths with spaces

puts ""
puts "Compiling files in dependency order..."
puts ""

# Helper function to compile file with error handling
# Handles paths with spaces by using TCL list (automatic quoting)
proc compile_file_safe {file_path {incdir_list {}} {skip_on_error 0}} {
    set full_path [file normalize $file_path]
    if {![file exists $full_path]} {
        return 0
    }
    
    set file_name [file tail $file_path]
    
    # Convert backslashes to forward slashes for ModelSim
    set path_normalized [string map {\\ /} $full_path]
    
    # Build command using list - TCL will automatically quote paths with spaces
    set cmd [list vlog -work work]
    
    # Add incdir options if provided (as a list)
    if {[llength $incdir_list] > 0} {
        foreach incdir_opt $incdir_list {
            lappend cmd $incdir_opt
        }
    }
    
    # Add file path - TCL list will automatically quote if it has spaces
    lappend cmd $path_normalized
    
    # Execute using eval with list (properly handles spaces)
    if {[catch {eval $cmd} err]} {
        if {$skip_on_error} {
            puts "  ⚠ Skipped (incompatible): $file_name"
            return 0
        } else {
            puts "  ✗ ERROR: $file_name"
            puts "    $err"
            return 0
        }
    } else {
        puts "  ✓ Compiled: $file_name"
        return 1
    }
}

# Counters
set sv_compiled 0
set v_compiled 0
set sv_skipped 0
set v_skipped 0

#==============================================================================
# PART 1: SystemVerilog Source Files
#==============================================================================
puts "============================================================================"
puts "PART 1: SystemVerilog Source Files"
puts "============================================================================"

# Step 1.1: Packages
puts "\[1.1\] Compiling SystemVerilog Packages..."
set pkg_file [file normalize [file join $AXI_PACKAGES_DIR "axi_pkg.sv"]]
if {[compile_file_safe $pkg_file $incdir_options_list 0]} {
    incr sv_compiled
}
puts ""

# Step 1.2: Interfaces
puts "\[1.2\] Compiling SystemVerilog Interfaces..."
set if_file [file normalize [file join $AXI_SV_RTL "interfaces" "axi4_if.sv"]]
# Compile directly with absolute paths (no cd needed since axi_pkg is inlined)
set if_file_normalized [string map {\\ /} $if_file]
set pkg_path_normalized [string map {\\ /} $AXI_PACKAGES_DIR]
# Build command with incdir options
set cmd_parts [list vlog -work work]
lappend cmd_parts "+incdir+$pkg_path_normalized"
lappend cmd_parts $if_file_normalized
if {[catch {eval $cmd_parts} err]} {
    puts "  ✗ ERROR: axi4_if.sv"
    puts "    $err"
} else {
    puts "  ✓ Compiled: axi4_if.sv"
    incr sv_compiled
}
puts ""

# Step 1.3: Utils and Buffers
puts "\[1.3\] Compiling Utils and Buffers..."
set utils_dirs [list \
    [file normalize [file join $AXI_SV_RTL "utils"]] \
    [file normalize [file join $AXI_SV_RTL "buffers"]] \
]
foreach dir $utils_dirs {
    if {[file exists $dir]} {
        set sv_files [glob -nocomplain -directory $dir -type f "*.sv"]
        foreach file $sv_files {
            if {[compile_file_safe $file $incdir_options_list 0]} {
                incr sv_compiled
            }
        }
    }
}
puts ""

# Step 1.4: AXI Interconnect RTL
puts "\[1.4\] Compiling AXI Interconnect RTL..."
set exclude_dirs [list "packages" "interfaces" "utils" "buffers"]
set rtl_dirs [list \
    [file normalize [file join $AXI_SV_RTL "datapath"]] \
    [file normalize [file join $AXI_SV_RTL "decoders"]] \
    [file normalize [file join $AXI_SV_RTL "handshake"]] \
    [file normalize [file join $AXI_SV_RTL "arbitration"]] \
    [file normalize [file join $AXI_SV_RTL "channel_controllers"]] \
    [file normalize [file join $AXI_SV_RTL "core"]] \
]
foreach dir $rtl_dirs {
    if {[file exists $dir]} {
        set sv_files [glob -nocomplain -directory $dir -type f "*.sv"]
        foreach file $sv_files {
            if {[compile_file_safe $file $incdir_options_list 0]} {
                incr sv_compiled
            }
        }
    }
}
puts ""

# Step 1.5: Other SystemVerilog files
puts "\[1.5\] Compiling Other SystemVerilog Files..."
set other_dirs [list \
    [file normalize [file join $SRC_BASE "cores"]] \
    [file normalize [file join $SRC_BASE "systems"]] \
]
foreach dir $other_dirs {
    if {[file exists $dir]} {
        set sv_files [glob -nocomplain -directory $dir -type f "*.sv"]
        foreach file $sv_files {
            if {[compile_file_safe $file $incdir_options_list 0]} {
                incr sv_compiled
            }
        }
    }
}
puts ""

#==============================================================================
# PART 2: Verilog Source Files
#==============================================================================
puts "============================================================================"
puts "PART 2: Verilog Source Files"
puts "============================================================================"

# Compile all Verilog files from src/
set v_dirs [list \
    [file normalize [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl"]] \
    [file normalize [file join $SRC_BASE "cores" "serv" "rtl"]] \
    [file normalize [file join $SRC_BASE "cores" "serv" "servant"]] \
    [file normalize [file join $SRC_BASE "axi_bridge" "rtl"]] \
    [file normalize [file join $SRC_BASE "peripherals"]] \
    [file normalize [file join $SRC_BASE "systems"]] \
]
foreach dir $v_dirs {
    if {[file exists $dir]} {
        set v_files [glob -nocomplain -directory $dir -type f "*.v"]
        foreach file $v_files {
            if {[compile_file_safe $file "" 0]} {
                incr v_compiled
            }
        }
    }
}
puts ""

#==============================================================================
# PART 3: Verilog Testbenches (Compatible)
#==============================================================================
puts "============================================================================"
puts "PART 3: Verilog Testbenches"
puts "============================================================================"

set tb_v_dir [file normalize [file join $VERIF_BASE "testbenches" "interconnect_tb" "Verilog_tb"]]
if {[file exists $tb_v_dir]} {
    set v_files [glob -nocomplain -directory $tb_v_dir -type f "*.v"]
    foreach file $v_files {
        if {[compile_file_safe $file "" 0]} {
            incr v_compiled
        }
    }
}
puts ""

#==============================================================================
# PART 4: SystemVerilog Testbenches (Skip incompatible ones)
#==============================================================================
puts "============================================================================"
puts "PART 4: SystemVerilog Testbenches (Skipping incompatible files)"
puts "============================================================================"
puts "Note: ModelSim 10.1d has limited SystemVerilog class support"
puts "Skipping testbench packages with classes and UVM files"
puts ""

# List of files to skip (incompatible with ModelSim 10.1d)
set skip_patterns [list \
    "*_tb_pkg.sv" \
    "*uvm*.sv" \
    "*agent*.sv" \
    "*sequence*.sv" \
    "*test*.sv" \
    "*env*.sv" \
    "*scoreboard*.sv" \
    "*coverage*.sv" \
    "*config*.sv" \
]

# Compile simple SystemVerilog testbenches (without classes)
set tb_sv_dir [file normalize [file join $VERIF_BASE "testbenches" "interconnect_tb" "SystemVerilog_tb"]]
if {[file exists $tb_sv_dir]} {
    # Compile interfaces first
    set if_dir [file normalize [file join $tb_sv_dir "common"]]
    if {[file exists $if_dir]} {
        set if_files [glob -nocomplain -directory $if_dir -type f "*_if.sv"]
        foreach file $if_files {
            set skip 0
            set file_name [file tail $file]
            foreach pattern $skip_patterns {
                if {[string match $pattern $file_name]} {
                    set skip 1
                    break
                }
            }
            if {!$skip} {
                if {[compile_file_safe $file $incdir_options_list 0]} {
                    incr sv_compiled
                }
            } else {
                incr sv_skipped
            }
        }
    }
    
    # Compile simple testbenches (not packages)
    set tb_files [glob -nocomplain -directory $tb_sv_dir -type f "*.sv"]
    foreach file $tb_files {
        set skip 0
        set file_name [file tail $file]
        foreach pattern $skip_patterns {
            if {[string match $pattern $file_name]} {
                set skip 1
                break
            }
        }
        if {!$skip} {
            if {[compile_file_safe $file $incdir_options_list 1]} {
                incr sv_compiled
            } else {
                incr sv_skipped
            }
        } else {
            incr sv_skipped
        }
    }
}
puts ""

#==============================================================================
# SUMMARY
#==============================================================================
puts "============================================================================"
puts "COMPILATION SUMMARY"
puts "============================================================================"
puts "SystemVerilog files compiled:  $sv_compiled"
puts "Verilog files compiled:        $v_compiled"
puts "SystemVerilog files skipped:   $sv_skipped (incompatible with ModelSim 10.1d)"
puts "----------------------------------------"
set total_compiled [expr $sv_compiled + $v_compiled]
puts "TOTAL compiled:                $total_compiled files"
puts ""
puts "Note: Files with SystemVerilog classes and UVM were skipped"
puts "      because ModelSim 10.1d has limited support for these features."
puts "      Use Verilog testbenches or upgrade to newer ModelSim/QuestaSim."
puts "============================================================================"

