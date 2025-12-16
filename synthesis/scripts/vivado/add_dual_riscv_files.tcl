#==============================================================================
# add_dual_riscv_files.tcl
# Add all Verilog files related to dual_riscv_axi_system to existing Vivado project
# 
# Usage: In Vivado TCL Console (with project open):
#   source add_dual_riscv_files.tcl
#==============================================================================

puts "============================================================================"
puts "Add Dual RISC-V System Files to Vivado Project"
puts "============================================================================"
puts ""

# Check if project is open
if {[catch {current_project} err]} {
    puts "ERROR: No project is currently open!"
    puts "Please open a project first:"
    puts "  open_project <path_to_project>/<project_name>.xpr"
    return
}

set project_name [current_project]
puts "Current project: $project_name"
puts ""

# Get script directory and calculate paths
# Use file normalize to handle paths with spaces
set SCRIPT_DIR [file dirname [file normalize [info script]]]

# Calculate PROJECT_ROOT: go up 3 levels from script
# Script is in: synthesis/scripts/vivado/
# Need to go to: project root
set PROJECT_ROOT [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]

# Verify PROJECT_ROOT exists
if {![file exists $PROJECT_ROOT]} {
    puts "ERROR: Cannot determine project root!"
    puts "Script directory: $SCRIPT_DIR"
    puts "Calculated root: $PROJECT_ROOT"
    return
}

set SRC_BASE [file normalize [file join $PROJECT_ROOT "src"]]
set VERIF_BASE [file normalize [file join $PROJECT_ROOT "verification"]]

puts "Script directory: $SCRIPT_DIR"
puts "Project root: $PROJECT_ROOT"
puts "Source base: $SRC_BASE"
puts ""

# Verify source directory exists
if {![file exists $SRC_BASE]} {
    puts "ERROR: Source directory not found: $SRC_BASE"
    puts "Please check project structure"
    return
}

# Helper function to add file
# Handles paths with spaces by using file normalize and proper quoting
proc add_source_file {file_path {file_type "Verilog"}} {
    # Normalize path to handle spaces and convert to forward slashes
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

set file_count 0

puts "============================================================================"
puts "Adding files in dependency order..."
puts "============================================================================"
puts ""

#==============================================================================
# PART 1: SERV RISC-V Core Files
#==============================================================================
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

#==============================================================================
# PART 2: Wishbone to AXI Converters
#==============================================================================
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

#==============================================================================
# PART 3: SERV AXI Wrapper and Adapter
#==============================================================================
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

#==============================================================================
# PART 4: AXI Interconnect - Utils
#==============================================================================
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

#==============================================================================
# PART 5: AXI Interconnect - Handshake
#==============================================================================
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

#==============================================================================
# PART 6: AXI Interconnect - Buffers
#==============================================================================
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

#==============================================================================
# PART 7: AXI Interconnect - Datapath (MUX/DEMUX)
#==============================================================================
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

#==============================================================================
# PART 8: AXI Interconnect - Decoders
#==============================================================================
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

#==============================================================================
# PART 9: AXI Interconnect - Arbitration
#==============================================================================
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

#==============================================================================
# PART 10: AXI Interconnect - Channel Controllers
#==============================================================================
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

#==============================================================================
# PART 11: AXI Interconnect - Core
#==============================================================================
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

#==============================================================================
# PART 12: AXI-Lite Peripherals
#==============================================================================
puts "\[12/12\] Adding AXI-Lite peripherals..."

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

#==============================================================================
# PART 13: Top System Module
#==============================================================================
puts "\[13/13\] Adding top system module..."

set top_file [file join $SRC_BASE "systems" "dual_riscv_axi_system.v"]
if {[add_source_file $top_file]} {
    incr file_count
    # Set as top module
    set_property top dual_riscv_axi_system [current_fileset]
    puts "  ✓ Set as top module"
}
puts ""

#==============================================================================
# Add Testbench Files
#==============================================================================
puts "============================================================================"
puts "Adding Testbench Files"
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
    incr file_count
} else {
    puts "  ⚠ Testbench not found: $tb_file"
}
puts ""

#==============================================================================
# Set Include Directories
#==============================================================================
puts "============================================================================"
puts "Setting Include Directories"
puts "============================================================================"

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
# Update Compile Order
#==============================================================================
puts "============================================================================"
puts "Updating Compile Order"
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
puts "Total files added: $file_count"
puts ""
puts "Files are now visible in Vivado Project window"
puts ""
puts "Next steps:"
puts "  1. Check for errors:"
puts "     Flow -> Run Synthesis (or: synth_design -rtl -name rtl_1)"
puts ""
puts "  2. Run simulation:"
puts "     Flow -> Run Simulation -> Run Behavioral Simulation"
puts "     Or: launch_simulation"
puts ""
puts "============================================================================"

