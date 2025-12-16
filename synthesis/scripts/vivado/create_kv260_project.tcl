#==============================================================================
# create_kv260_project.tcl
# Create Vivado project for KV260 with dual_riscv_axi_system
# Target: Xilinx Kria KV260 Vision AI Starter Kit
# Device: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
# Purpose: Simulation
#
# Usage: In Vivado TCL Console:
#   source create_kv260_project.tcl
#==============================================================================

puts "============================================================================"
puts "Create Vivado Project for KV260 - Dual RISC-V System"
puts "============================================================================"
puts ""

# Get script directory and calculate paths
# Use file normalize to handle paths with spaces
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Calculate PROJECT_ROOT: go up 3 levels from script
set PROJECT_ROOT [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]

# Verify PROJECT_ROOT exists
if {![file exists $PROJECT_ROOT]} {
    puts "ERROR: Cannot determine project root!"
    puts "Script directory: $SCRIPT_DIR"
    puts "Calculated root: $PROJECT_ROOT"
    return
}

set PROJECT_DIR [file normalize [file join $SCRIPT_DIR "kv260_dual_riscv"]]
set SRC_BASE [file normalize [file join $PROJECT_ROOT "src"]]
set VERIF_BASE [file normalize [file join $PROJECT_ROOT "verification"]]

puts "Script directory: $SCRIPT_DIR"
puts "Project root: $PROJECT_ROOT"
puts "Project directory: $PROJECT_DIR"
puts "Source base: $SRC_BASE"
puts ""

# Create project directory if it doesn't exist
if {![file exists $PROJECT_DIR]} {
    file mkdir $PROJECT_DIR
    puts "Created project directory: $PROJECT_DIR"
}

#==============================================================================
# Step 1: Create Vivado Project
#==============================================================================
puts "============================================================================"
puts "Step 1: Creating Vivado Project"
puts "============================================================================"

set PROJECT_NAME "kv260_dual_riscv"
set PROJECT_FILE [file join $PROJECT_DIR "${PROJECT_NAME}.xpr"]

# Close any existing project
if {[catch {current_project} err]} {
    puts "No project currently open"
} else {
    puts "Closing current project..."
    close_project
}

# Create new project
create_project $PROJECT_NAME $PROJECT_DIR -part xczu5ev-sfvc784-1-e -force

puts "Project created: $PROJECT_FILE"
puts "Target device: xczu5ev-sfvc784-1-e (KV260)"
puts ""

#==============================================================================
# Step 2: Set Project Properties
#==============================================================================
puts "============================================================================"
puts "Step 2: Setting Project Properties"
puts "============================================================================"

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib work [current_project]

# Set simulation properties
set_property target_simulator XSim [current_project]
set_property -name {xsim.simulate.runtime} -value {1000ns} -objects [get_filesets sim_1]

puts "Project properties set"
puts ""

#==============================================================================
# Step 3: Add Source Files (Verilog)
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding Verilog Source Files"
puts "============================================================================"

set file_count 0

# Helper function to add file
# Handles paths with spaces by using file normalize and proper quoting
proc add_source_file {file_path {file_type "Verilog"}} {
    # Normalize path to handle spaces
    set full_path [file normalize $file_path]
    
    # Convert backslashes to forward slashes for Vivado (works better with spaces)
    set full_path [string map {\\ /} $full_path]
    
    if {[file exists $full_path]} {
        # Use list to properly handle paths with spaces
        set file_list [list $full_path]
        
        if {$file_type == "SystemVerilog"} {
            add_files -fileset sources_1 -norecurse $file_list
            set_property file_type {SystemVerilog} [get_files $full_path]
        } else {
            add_files -fileset sources_1 -norecurse $file_list
        }
        puts "  ✓ Added: [file tail $file_path]"
        return 1
    } else {
        puts "  ✗ Not found: [file tail $file_path]"
        puts "    Full path: $full_path"
        return 0
    }
}

# PART 1: SERV RISC-V Core Files
puts "\[1/12\] Adding SERV RISC-V Core files..."
set SERV_RTL_DIR [file join $SRC_BASE "cores" "serv" "rtl"]
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
    set full_path [file join $SERV_RTL_DIR $file]
    if {[add_source_file $full_path]} {
        incr file_count
    }
}
puts ""

# PART 2: Wishbone to AXI Converters
puts "\[2/12\] Adding Wishbone to AXI converters..."
set BRIDGE_DIR [file join $SRC_BASE "axi_bridge" "rtl" "legacy" "serv_bridge"]
set bridge_files [list \
    "wb2axi_read.v" \
    "wb2axi_write.v" \
]
foreach file $bridge_files {
    set full_path [file join $BRIDGE_DIR $file]
    if {[add_source_file $full_path]} {
        incr file_count
    }
}
puts ""

# PART 3: SERV AXI Wrapper and Adapter
puts "\[3/12\] Adding SERV AXI wrapper and adapter..."
set wrapper_files [list \
    "serv_axi_wrapper.v" \
    "serv_axi_dualbus_adapter.v" \
]
foreach file $wrapper_files {
    set full_path [file join $BRIDGE_DIR $file]
    if {[add_source_file $full_path]} {
        incr file_count
    }
}
puts ""

# PART 4: AXI Interconnect - Utils
puts "\[4/12\] Adding AXI Interconnect utils..."
set utils_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "utils"]
if {[file exists $utils_dir]} {
    set utils_files [glob -nocomplain -directory $utils_dir -type f "*.v"]
    foreach file $utils_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 5: AXI Interconnect - Handshake
puts "\[5/12\] Adding AXI Interconnect handshake modules..."
set handshake_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "handshake"]
if {[file exists $handshake_dir]} {
    set handshake_files [glob -nocomplain -directory $handshake_dir -type f "*.v"]
    foreach file $handshake_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 6: AXI Interconnect - Buffers
puts "\[6/12\] Adding AXI Interconnect buffers..."
set buffers_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "buffers"]
if {[file exists $buffers_dir]} {
    set buffers_files [glob -nocomplain -directory $buffers_dir -type f "*.v"]
    foreach file $buffers_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 7: AXI Interconnect - Datapath (MUX/DEMUX)
puts "\[7/12\] Adding AXI Interconnect datapath..."
set mux_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "datapath" "mux"]
if {[file exists $mux_dir]} {
    set mux_files [glob -nocomplain -directory $mux_dir -type f "*.v"]
    foreach file $mux_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
set demux_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "datapath" "demux"]
if {[file exists $demux_dir]} {
    set demux_files [glob -nocomplain -directory $demux_dir -type f "*.v"]
    foreach file $demux_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 8: AXI Interconnect - Decoders
puts "\[8/12\] Adding AXI Interconnect decoders..."
set decoders_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "decoders"]
if {[file exists $decoders_dir]} {
    set decoders_files [glob -nocomplain -directory $decoders_dir -type f "*.v"]
    foreach file $decoders_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 9: AXI Interconnect - Arbitration
puts "\[9/12\] Adding AXI Interconnect arbitration..."
set arb_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "arbitration" "algorithms"]
if {[file exists $arb_dir]} {
    set arb_files [glob -nocomplain -directory $arb_dir -type f "*.v"]
    foreach file $arb_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 10: AXI Interconnect - Channel Controllers
puts "\[10/12\] Adding AXI Interconnect channel controllers..."
set read_ctrl_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "channel_controllers" "read"]
if {[file exists $read_ctrl_dir]} {
    set read_ctrl_files [glob -nocomplain -directory $read_ctrl_dir -type f "*.v"]
    foreach file $read_ctrl_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
set write_ctrl_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "channel_controllers" "write"]
if {[file exists $write_ctrl_dir]} {
    set write_ctrl_files [glob -nocomplain -directory $write_ctrl_dir -type f "*.v"]
    foreach file $write_ctrl_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
}
puts ""

# PART 11: AXI Interconnect - Core
puts "\[11/12\] Adding AXI Interconnect core..."
set core_dir [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "core"]

# Add AXI_Interconnect_Full.v first (dependency of AXI_Interconnect.v)
set interconnect_full_file [file join $core_dir "AXI_Interconnect_Full.v"]
if {[add_source_file $interconnect_full_file]} {
    incr file_count
}

# Then add AXI_Interconnect.v (wrapper that uses AXI_Interconnect_Full)
set interconnect_file [file join $core_dir "AXI_Interconnect.v"]
if {[add_source_file $interconnect_file]} {
    incr file_count
}
puts ""

# PART 12: AXI Masters (including master_controller.v)
puts "\[12/13\] Adding AXI Masters files (including Controller)..."
set AXI_MASTERS_DIR [file join $SRC_BASE "axi_masters"]
if {[file exists $AXI_MASTERS_DIR]} {
    set masters_files [glob -nocomplain -directory $AXI_MASTERS_DIR -type f "*.v"]
    foreach file $masters_files {
        if {[add_source_file $file]} {
            incr file_count
        }
    }
    puts "  ✓ Added AXI Masters files (including master_controller.v)"
} else {
    puts "  ⚠ AXI Masters directory not found: $AXI_MASTERS_DIR"
}
puts ""

# PART 13: AXI-Lite Peripherals
puts "\[13/14\] Adding AXI-Lite peripherals..."
set PERIPHERALS_DIR [file join $SRC_BASE "peripherals" "axi_lite"]
set peripheral_files [list \
    "axi_lite_ram.v" \
    "axi_lite_gpio.v" \
    "axi_lite_uart.v" \
    "axi_lite_spi.v" \
]
foreach file $peripheral_files {
    set full_path [file join $PERIPHERALS_DIR $file]
    if {[add_source_file $full_path]} {
        incr file_count
    }
}
puts ""

# PART 14: Top System Module
puts "\[14/14\] Adding top system module..."
set top_file [file join $SRC_BASE "systems" "dual_riscv_axi_system.v"]
if {[add_source_file $top_file]} {
    incr file_count
    # Set as top module
    set_property top dual_riscv_axi_system [current_fileset]
}
puts ""

#==============================================================================
# Step 4: Add Testbench Files
#==============================================================================
puts "============================================================================"
puts "Step 4: Adding Testbench Files"
puts "============================================================================"

set tb_file [file join $VERIF_BASE "testbenches" "system_tb" "dual_riscv_system_tb.v"]
set tb_file [file normalize $tb_file]
set tb_file [string map {\\ /} $tb_file]

if {[file exists $tb_file]} {
    set tb_list [list $tb_file]
    add_files -fileset sim_1 -norecurse $tb_list
    set_property top dual_riscv_system_tb [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    puts "  ✓ Added testbench: dual_riscv_system_tb.v"
    puts "  ✓ Set as simulation top"
} else {
    puts "  ⚠ Testbench not found: $tb_file"
}
puts ""

#==============================================================================
# Step 5: Set Include Directories (if needed)
#==============================================================================
puts "============================================================================"
puts "Step 5: Setting Include Directories"
puts "============================================================================"

# Add include directories for any `include files
set include_dirs [list \
    [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl" "includes"] \
]

foreach dir $include_dirs {
    set dir_normalized [file normalize $dir]
    set dir_normalized [string map {\\ /} $dir_normalized]
    if {[file exists $dir_normalized]} {
        set_property include_dirs $dir_normalized [get_filesets sources_1]
        set_property include_dirs $dir_normalized [get_filesets sim_1]
        puts "  ✓ Added include directory: $dir_normalized"
    }
}
puts ""

#==============================================================================
# Step 6: Update Compile Order
#==============================================================================
puts "============================================================================"
puts "Step 6: Updating Compile Order"
puts "============================================================================"

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Compile order updated"
puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "SUMMARY"
puts "============================================================================"
puts ""
puts "Project created: $PROJECT_NAME"
puts "Location: $PROJECT_DIR"
puts "Target device: xczu5ev-sfvc784-1-e (KV260)"
puts "Total source files added: $file_count"
puts ""

# Verify Controller was added
set controller_file [get_files -quiet -of_objects [get_filesets sources_1] "*master_controller.v"]
if {[llength $controller_file] > 0} {
    puts "✓ Controller verified: master_controller.v"
} else {
    puts "⚠ Warning: master_controller.v not found in project"
    puts "  Expected location: $SRC_BASE/axi_masters/master_controller.v"
}
puts ""

puts "Next steps:"
puts "  1. Check for compilation errors:"
puts "     Run Synthesis -> Run Synthesis"
puts ""
puts "  2. Run simulation:"
puts "     Simulation -> Run Simulation -> Run Behavioral Simulation"
puts ""
puts "  3. Or use TCL command:"
puts "     launch_simulation"
puts ""
puts "============================================================================"

