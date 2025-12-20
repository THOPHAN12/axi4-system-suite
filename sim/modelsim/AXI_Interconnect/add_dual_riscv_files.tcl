#==============================================================================
# add_dual_riscv_files.tcl
# Add all Verilog files related to dual_riscv_axi_system to ModelSim project
# 
# Usage: In ModelSim TCL Console, type: do add_dual_riscv_files.tcl
#==============================================================================

puts "============================================================================"
puts "Add Dual RISC-V System Files to ModelSim Project"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR

# Calculate ROOT_DIR: script is in sim/modelsim/AXI_Interconnect/, so go up 3 levels
# SCRIPT_DIR = .../axi4-system-suite/sim/modelsim/AXI_Interconnect
# Need to go up 3 levels to get to root
set ROOT_DIR_TMP [file join $SCRIPT_DIR .. .. ..]
set ROOT_DIR [file normalize $ROOT_DIR_TMP]

# Verify ROOT_DIR is correct by checking if src/ exists
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]

# Debug: Print paths to verify
puts "Script directory: $SCRIPT_DIR"
puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts "Verification base: $VERIF_BASE"
puts ""

# Verify paths exist - if src/ doesn't exist, try alternative calculation
if {![file exists $SRC_BASE]} {
    puts "WARNING: Source directory not found: $SRC_BASE"
    puts "Trying alternative path calculation..."
    
    # Alternative method: Remove last 3 path components from SCRIPT_DIR
    # (AXI_Interconnect, modelsim, sim)
    set path_parts [file split $SCRIPT_DIR]
    set path_len [llength $path_parts]
    
    if {$path_len >= 3} {
        # Remove last 3 components
        set root_parts [lrange $path_parts 0 [expr {$path_len - 4}]]
        set ALT_ROOT [eval file join $root_parts]
        set ALT_ROOT [file normalize $ALT_ROOT]
        set ALT_SRC [file normalize [file join $ALT_ROOT "src"]]
        
        puts "Alternative root: $ALT_ROOT"
        puts "Alternative source: $ALT_SRC"
        
        if {[file exists $ALT_SRC]} {
            puts "Using alternative path calculation!"
            set ROOT_DIR $ALT_ROOT
            set SRC_BASE $ALT_SRC
            set VERIF_BASE [file normalize [file join $ALT_ROOT "verification"]]
            puts "Updated paths:"
            puts "  ROOT_DIR: $ROOT_DIR"
            puts "  SRC_BASE: $SRC_BASE"
        } else {
            puts "ERROR: Cannot find source directory!"
            puts "Please check that src/ directory exists in project root"
            puts "Expected location: [file join $ROOT_DIR src]"
            return
        }
    } else {
        # Last resort: try going up 2 levels (if script is in sim/modelsim/)
        set ROOT_DIR_TMP2 [file join $SCRIPT_DIR .. ..]
        set ROOT_DIR2 [file normalize $ROOT_DIR_TMP2]
        set SRC_BASE2 [file normalize [file join $ROOT_DIR2 "src"]]
        
        if {[file exists $SRC_BASE2]} {
            puts "Found src/ by going up 2 levels instead"
            set ROOT_DIR $ROOT_DIR2
            set SRC_BASE $SRC_BASE2
            set VERIF_BASE [file normalize [file join $ROOT_DIR2 "verification"]]
        } else {
            puts "ERROR: Cannot determine root directory from script path!"
            puts "Script location: $SCRIPT_DIR"
            puts "Tried: $ROOT_DIR (3 levels up)"
            puts "Tried: $ROOT_DIR2 (2 levels up)"
            return
        }
    }
    puts ""
}

puts ""

# Change to project directory
cd $PROJECT_DIR

# Check if project is open
set project_is_open 0
set PROJECT_FILE [file normalize [file join $PROJECT_DIR "AXI_Project.mpf"]]

if {[catch {set current_project [project]} err]} {
    puts "Opening project: $PROJECT_FILE"
    if {[file exists $PROJECT_FILE]} {
        if {[catch {project open $PROJECT_FILE} open_err]} {
            puts "ERROR: Cannot open project: $open_err"
            puts "Creating new project..."
            project new $PROJECT_FILE
            set project_is_open 1
        } else {
            set project_is_open 1
            puts "Project opened successfully!"
        }
    } else {
        puts "Project file not found. Creating new project..."
        project new $PROJECT_FILE
        set project_is_open 1
    }
} else {
    set project_is_open 1
    puts "Project already open: $current_project"
}

if {!$project_is_open} {
    puts "ERROR: Cannot open or create project!"
    return
}

puts ""
puts "Adding files in dependency order..."
puts ""

set file_count 0

#==============================================================================
# PART 1: SERV RISC-V Core Files
#==============================================================================
puts "============================================================================"
puts "PART 1: SERV RISC-V Core Files"
puts "============================================================================"

set SERV_RTL_DIR [file normalize [file join $SRC_BASE "cores" "serv" "rtl"]]

if {[file exists $SERV_RTL_DIR]} {
    # SERV core files (compile in dependency order)
    set serv_files [list \
        "serv_alu.v" \
        "serv_bufreg.v" \
        "serv_bufreg2.v" \
        "serv_compdec.v" \
        "serv_csr.v" \
        "serv_ctrl.v" \
        "serv_decode.v" \
        "serv_immdec.v" \
        "serv_mem_if.v" \
        "serv_rf_if.v" \
        "serv_rf_ram_if.v" \
        "serv_rf_ram.v" \
        "serv_rf_top.v" \
        "serv_state.v" \
        "serv_aligner.v" \
        "serv_top.v" \
    ]
    
    foreach file $serv_files {
        set full_path [file normalize [file join $SERV_RTL_DIR $file]]
        if {[file exists $full_path]} {
            project addfile $full_path
            incr file_count
            puts "  ✓ Added: $file"
        } else {
            puts "  ⚠ Not found: $file"
        }
    }
} else {
    puts "  ⚠ SERV RTL directory not found: $SERV_RTL_DIR"
}

puts ""

#==============================================================================
# PART 2: AXI Bridge Wrappers
#==============================================================================
puts "============================================================================"
puts "PART 2: AXI Bridge Wrappers"
puts "============================================================================"

set BRIDGE_DIR [file normalize [file join $SRC_BASE "axi_bridge"]]
set PIPELINE_CORE_DIR [file normalize [file join $SRC_BASE "cores" "riscv-5stage-pipeline"]]
set PIPELINE_RTL_CORE_FILE [file normalize [file join $PIPELINE_CORE_DIR "rtl" "core" "RV32I_PIPELINE.v"]]

# Check if riscv-5stage-pipeline exists
set has_pipeline [file exists $PIPELINE_RTL_CORE_FILE]

puts "Looking for bridge wrapper files in: $BRIDGE_DIR"

set wrapper_files [list \
    "serv_axi_wrapper.v" \
    "riscv_pipeline_axi_wrapper.v" \
    "friscv_axi_wrapper.v" \
]

foreach file $wrapper_files {
    set full_path [file normalize [file join $BRIDGE_DIR $file]]
    if {[file exists $full_path]} {
        # Skip riscv_pipeline_axi_wrapper.v if riscv-5stage-pipeline doesn't exist
        if {$file == "riscv_pipeline_axi_wrapper.v" && !$has_pipeline} {
            puts "  ⚠ Skipping: $file (riscv-5stage-pipeline/RV32I_PIPELINE.v not found)"
            continue
        }
        project addfile $full_path
        incr file_count
        puts "  ✓ Added: $file"
    } else {
        puts "  ⚠ Not found: $file"
    }
}

puts ""

#==============================================================================
# PART 4: AXI Interconnect - Utils and Handshake
#==============================================================================
puts "============================================================================"
puts "PART 4: AXI Interconnect - Utils and Handshake"
puts "============================================================================"

set AXI_VERILOG_DIR [file normalize [file join $SRC_BASE "axi_interconnect" "rtl"]]

# Utils
set utils_dir [file normalize [file join $AXI_VERILOG_DIR "utils"]]
if {[file exists $utils_dir]} {
    set utils_files [glob -nocomplain -directory $utils_dir -type f "*.v"]
    foreach file $utils_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

# Handshake
set handshake_dir [file normalize [file join $AXI_VERILOG_DIR "handshake"]]
if {[file exists $handshake_dir]} {
    set handshake_files [glob -nocomplain -directory $handshake_dir -type f "*.v"]
    foreach file $handshake_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

puts ""

#==============================================================================
# PART 5: AXI Interconnect - Buffers
#==============================================================================
puts "============================================================================"
puts "PART 5: AXI Interconnect - Buffers"
puts "============================================================================"

set buffers_dir [file normalize [file join $AXI_VERILOG_DIR "buffers"]]
if {[file exists $buffers_dir]} {
    set buffers_files [glob -nocomplain -directory $buffers_dir -type f "*.v"]
    foreach file $buffers_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

puts ""

#==============================================================================
# PART 6: AXI Interconnect - Datapath (MUX/DEMUX)
#==============================================================================
puts "============================================================================"
puts "PART 6: AXI Interconnect - Datapath (MUX/DEMUX)"
puts "============================================================================"

# MUX
set mux_dir [file normalize [file join $AXI_VERILOG_DIR "datapath" "mux"]]
if {[file exists $mux_dir]} {
    set mux_files [glob -nocomplain -directory $mux_dir -type f "*.v"]
    foreach file $mux_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

# DEMUX
set demux_dir [file normalize [file join $AXI_VERILOG_DIR "datapath" "demux"]]
if {[file exists $demux_dir]} {
    set demux_files [glob -nocomplain -directory $demux_dir -type f "*.v"]
    foreach file $demux_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

puts ""

#==============================================================================
# PART 7: AXI Interconnect - Decoders
#==============================================================================
puts "============================================================================"
puts "PART 7: AXI Interconnect - Decoders"
puts "============================================================================"

set decoders_dir [file normalize [file join $AXI_VERILOG_DIR "decoders"]]
if {[file exists $decoders_dir]} {
    set decoders_files [glob -nocomplain -directory $decoders_dir -type f "*.v"]
    foreach file $decoders_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

puts ""

#==============================================================================
# PART 8: AXI Interconnect - Arbitration
#==============================================================================
puts "============================================================================"
puts "PART 8: AXI Interconnect - Arbitration"
puts "============================================================================"

set arb_dir [file normalize [file join $AXI_VERILOG_DIR "arbitration" "algorithms"]]
if {[file exists $arb_dir]} {
    set arb_files [glob -nocomplain -directory $arb_dir -type f "*.v"]
    foreach file $arb_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

puts ""

#==============================================================================
# PART 9: AXI Interconnect - Channel Controllers
#==============================================================================
puts "============================================================================"
puts "PART 9: AXI Interconnect - Channel Controllers"
puts "============================================================================"

# Read channel controllers
set read_ctrl_dir [file normalize [file join $AXI_VERILOG_DIR "channel_controllers" "read"]]
if {[file exists $read_ctrl_dir]} {
    set read_ctrl_files [glob -nocomplain -directory $read_ctrl_dir -type f "*.v"]
    foreach file $read_ctrl_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

# Write channel controllers
set write_ctrl_dir [file normalize [file join $AXI_VERILOG_DIR "channel_controllers" "write"]]
if {[file exists $write_ctrl_dir]} {
    set write_ctrl_files [glob -nocomplain -directory $write_ctrl_dir -type f "*.v"]
    foreach file $write_ctrl_files {
        project addfile $file
        incr file_count
        puts "  ✓ Added: [file tail $file]"
    }
}

puts ""

#==============================================================================
# PART 10: AXI Interconnect - Core
#==============================================================================
puts "============================================================================"
puts "PART 10: AXI Interconnect - Core"
puts "============================================================================"

set core_dir [file normalize [file join $AXI_VERILOG_DIR "core"]]
if {[file exists $core_dir]} {
    # Add AXI_Interconnect.v (used by dual_riscv_axi_system)
    set interconnect_file [file normalize [file join $core_dir "AXI_Interconnect.v"]]
    if {[file exists $interconnect_file]} {
        project addfile $interconnect_file
        incr file_count
        puts "  ✓ Added: AXI_Interconnect.v"
    } else {
        puts "  ⚠ Not found: AXI_Interconnect.v"
    }
}

puts ""

#==============================================================================
# PART 11: AXI-Lite Peripherals
#==============================================================================
puts "============================================================================"
puts "PART 11: AXI-Lite Peripherals"
puts "============================================================================"

set PERIPHERALS_DIR [file normalize [file join $SRC_BASE "peripherals" "axi_lite"]]

puts "Looking for peripherals in: $PERIPHERALS_DIR"

set peripheral_files [list \
    "axi_lite_ram.v" \
    "axi_lite_gpio.v" \
    "axi_lite_uart.v" \
    "axi_lite_spi.v" \
]

foreach file $peripheral_files {
    set full_path [file normalize [file join $PERIPHERALS_DIR $file]]
    if {[file exists $full_path]} {
        project addfile $full_path
        incr file_count
        puts "  ✓ Added: $file"
    } else {
        puts "  ⚠ Not found: $file"
    }
}

puts ""

#==============================================================================
# PART 12: AXI Master Aggregator
#==============================================================================
puts "============================================================================"
puts "PART 12: AXI Master Aggregator"
puts "============================================================================"

set aggregator_file [file normalize [file join $AXI_VERILOG_DIR "core" "AXI_Master_Aggregator.v"]]

if {[file exists $aggregator_file]} {
    project addfile $aggregator_file
    incr file_count
    puts "  ✓ Added: AXI_Master_Aggregator.v"
} else {
    puts "  ⚠ Not found: AXI_Master_Aggregator.v"
}

puts ""

#==============================================================================
# PART 13: Dual AXI Shell
#==============================================================================
puts "============================================================================"
puts "PART 13: Dual AXI Shell"
puts "============================================================================"

set shell_file [file normalize [file join $SRC_BASE "systems" "dual_axi_shell.v"]]

if {[file exists $shell_file]} {
    project addfile $shell_file
    incr file_count
    puts "  ✓ Added: dual_axi_shell.v"
} else {
    puts "  ⚠ Not found: dual_axi_shell.v"
}

puts ""

#==============================================================================
# PART 14: Top System Modules
#==============================================================================
puts "============================================================================"
puts "PART 14: Top System Modules"
puts "============================================================================"

set SYSTEMS_DIR [file normalize [file join $SRC_BASE "systems"]]
set PIPELINE_CORE_DIR [file normalize [file join $SRC_BASE "cores" "riscv-5stage-pipeline"]]
set PIPELINE_RTL_CORE_FILE [file normalize [file join $PIPELINE_CORE_DIR "rtl" "core" "RV32I_PIPELINE.v"]]

# Check if riscv-5stage-pipeline exists
set has_pipeline [file exists $PIPELINE_RTL_CORE_FILE]

set system_files [list \
    "dual_pipeline_serv_axi_system_aggregators.v" \
    "dual_serv_axi_system.v" \
    "dual_pipeline_serv_axi_system.v" \
]

foreach file $system_files {
    set full_path [file normalize [file join $SYSTEMS_DIR $file]]
    if {[file exists $full_path]} {
        # Skip dual_pipeline_serv_axi_system.v if riscv-5stage-pipeline doesn't exist
        # because it depends on riscv_pipeline_axi_wrapper.v which needs RV32I_PIPELINE.v
        if {$file == "dual_pipeline_serv_axi_system.v" && !$has_pipeline} {
            puts "  ⚠ Skipping: $file (riscv-5stage-pipeline/RV32I_PIPELINE.v not found)"
            puts "    This file requires riscv_pipeline_axi_wrapper.v which depends on RV32I_PIPELINE.v"
            continue
        }
        project addfile $full_path
        incr file_count
        puts "  ✓ Added: $file"
    } else {
        puts "  ⚠ Not found: $file"
    }
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "SUMMARY"
puts "============================================================================"
puts ""
puts "Total files added: $file_count"
puts ""
puts "Files are now visible in ModelSim Project window"
puts ""
puts "Next steps:"
puts "  1. Compile all files: Compile -> Compile All"
puts "  2. Or use: do compile_all_files.tcl"
puts ""
puts "============================================================================"

