#==============================================================================
# compile_dual_riscv_files.tcl
# Compile all Verilog files for dual_riscv_axi_system in correct dependency order
# Usage: In ModelSim TCL Console, type: do compile_dual_riscv_files.tcl
#==============================================================================

puts "============================================================================"
puts "Compile Dual RISC-V System Files"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR

# Calculate ROOT_DIR: script is in sim/modelsim/AXI_Interconnect/, so go up 3 levels
set ROOT_DIR_TMP [file join $SCRIPT_DIR .. .. ..]
set ROOT_DIR [file normalize $ROOT_DIR_TMP]

# Verify ROOT_DIR is correct by checking if src/ exists
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]

# If src/ doesn't exist, try alternative calculation
if {![file exists $SRC_BASE]} {
    set path_parts [file split $SCRIPT_DIR]
    set path_len [llength $path_parts]
    
    if {$path_len >= 3} {
        set root_parts [lrange $path_parts 0 [expr {$path_len - 4}]]
        set ROOT_DIR [eval file join $root_parts]
        set ROOT_DIR [file normalize $ROOT_DIR]
        set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
        set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]
    } else {
        set ROOT_DIR_TMP2 [file join $SCRIPT_DIR .. ..]
        set ROOT_DIR [file normalize $ROOT_DIR_TMP2]
        set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]
        set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]
    }
}

puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts ""

# Change to project directory
cd $PROJECT_DIR

# Ensure work library exists
if {![file exists [file join $PROJECT_DIR "work"]]} {
    vlib work
    puts "Created work library"
} else {
    vmap work work
    puts "Work library exists"
}

puts ""

# Helper function to compile file
proc compile_file {file_path} {
    set full_path [file normalize $file_path]
    if {![file exists $full_path]} {
        puts "  ✗ File not found: [file tail $file_path]"
        return 0
    }
    
    set file_name [file tail $file_path]
    set path_normalized [string map {\\ /} $full_path]
    
    # Try to compile
    if {[catch {vlog -work work $path_normalized} err]} {
        puts "  ✗ ERROR: $file_name"
        # Print first line of error (usually the important one)
        set err_lines [split $err "\n"]
        if {[llength $err_lines] > 0} {
            puts "    [lindex $err_lines 0]"
        }
        return 0
    } else {
        puts "  ✓ Compiled: $file_name"
        return 1
    }
}

set compiled_count 0
set failed_count 0

#==============================================================================
# PART 1: SERV RISC-V Core Files (compile in dependency order)
#==============================================================================
puts "============================================================================"
puts "PART 1: SERV RISC-V Core Files"
puts "============================================================================"

set SERV_RTL_DIR [file normalize [file join $SRC_BASE "cores" "serv" "rtl"]]

if {[file exists $SERV_RTL_DIR]} {
    # SERV core files in dependency order
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
        if {[compile_file $full_path]} {
            incr compiled_count
        } else {
            incr failed_count
        }
    }
} else {
    puts "  ✗ SERV RTL directory not found: $SERV_RTL_DIR"
}

puts ""

#==============================================================================
# PART 2: Wishbone to AXI Converters
#==============================================================================
puts "============================================================================"
puts "PART 2: Wishbone to AXI Converters"
puts "============================================================================"

set BRIDGE_DIR [file normalize [file join $SRC_BASE "axi_bridge" "rtl" "legacy" "serv_bridge"]]

set bridge_files [list \
    "wb2axi_read.v" \
    "wb2axi_write.v" \
]

foreach file $bridge_files {
    set full_path [file normalize [file join $BRIDGE_DIR $file]]
    if {[compile_file $full_path]} {
        incr compiled_count
    } else {
        incr failed_count
    }
}

puts ""

#==============================================================================
# PART 3: SERV AXI Wrapper and Adapter
#==============================================================================
puts "============================================================================"
puts "PART 3: SERV AXI Wrapper and Adapter"
puts "============================================================================"

set wrapper_files [list \
    "serv_axi_wrapper.v" \
    "serv_axi_dualbus_adapter.v" \
]

foreach file $wrapper_files {
    set full_path [file normalize [file join $BRIDGE_DIR $file]]
    if {[compile_file $full_path]} {
        incr compiled_count
    } else {
        incr failed_count
    }
}

puts ""

#==============================================================================
# PART 4: AXI Interconnect - Utils and Handshake
#==============================================================================
puts "============================================================================"
puts "PART 4: AXI Interconnect - Utils and Handshake"
puts "============================================================================"

set AXI_VERILOG_DIR [file normalize [file join $SRC_BASE "axi_interconnect" "Verilog" "rtl"]]

# Utils
set utils_dir [file normalize [file join $AXI_VERILOG_DIR "utils"]]
if {[file exists $utils_dir]} {
    set utils_files [glob -nocomplain -directory $utils_dir -type f "*.v"]
    foreach file $utils_files {
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
    }
}

# Handshake
set handshake_dir [file normalize [file join $AXI_VERILOG_DIR "handshake"]]
if {[file exists $handshake_dir]} {
    set handshake_files [glob -nocomplain -directory $handshake_dir -type f "*.v"]
    foreach file $handshake_files {
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
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
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
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
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
    }
}

# DEMUX
set demux_dir [file normalize [file join $AXI_VERILOG_DIR "datapath" "demux"]]
if {[file exists $demux_dir]} {
    set demux_files [glob -nocomplain -directory $demux_dir -type f "*.v"]
    foreach file $demux_files {
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
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
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
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
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
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
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
    }
}

# Write channel controllers
set write_ctrl_dir [file normalize [file join $AXI_VERILOG_DIR "channel_controllers" "write"]]
if {[file exists $write_ctrl_dir]} {
    set write_ctrl_files [glob -nocomplain -directory $write_ctrl_dir -type f "*.v"]
    foreach file $write_ctrl_files {
        if {[compile_file $file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
    }
}

puts ""

#==============================================================================
# PART 10: AXI Interconnect - Core (must compile AXI_Interconnect_Full.v first)
#==============================================================================
puts "============================================================================"
puts "PART 10: AXI Interconnect - Core"
puts "============================================================================"

set core_dir [file normalize [file join $AXI_VERILOG_DIR "core"]]
if {[file exists $core_dir]} {
    # First compile AXI_Interconnect_Full.v (dependency)
    set interconnect_full_file [file normalize [file join $core_dir "AXI_Interconnect_Full.v"]]
    if {[file exists $interconnect_full_file]} {
        if {[compile_file $interconnect_full_file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
    }
    
    # Then compile AXI_Interconnect.v
    set interconnect_file [file normalize [file join $core_dir "AXI_Interconnect.v"]]
    if {[file exists $interconnect_file]} {
        if {[compile_file $interconnect_file]} {
            incr compiled_count
        } else {
            incr failed_count
        }
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

set peripheral_files [list \
    "axi_lite_ram.v" \
    "axi_lite_gpio.v" \
    "axi_lite_uart.v" \
    "axi_lite_spi.v" \
]

foreach file $peripheral_files {
    set full_path [file normalize [file join $PERIPHERALS_DIR $file]]
    if {[compile_file $full_path]} {
        incr compiled_count
    } else {
        incr failed_count
    }
}

puts ""

#==============================================================================
# PART 12: Top System Module
#==============================================================================
puts "============================================================================"
puts "PART 12: Top System Module"
puts "============================================================================"

set top_file [file normalize [file join $SRC_BASE "systems" "dual_riscv_axi_system.v"]]
if {[file exists $top_file]} {
    if {[compile_file $top_file]} {
        incr compiled_count
    } else {
        incr failed_count
    }
} else {
    puts "  ✗ Top module not found: $top_file"
    incr failed_count
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "COMPILATION SUMMARY"
puts "============================================================================"
puts "Files compiled successfully: $compiled_count"
puts "Files failed:                $failed_count"
puts ""

if {$failed_count == 0} {
    puts "✓ All files compiled successfully!"
} else {
    puts "⚠ Some files failed to compile. Check errors above."
    puts ""
    puts "Common issues:"
    puts "  1. Missing dependencies - ensure all files are in correct order"
    puts "  2. Syntax errors - check individual file errors"
    puts "  3. Missing modules - verify all dependencies are compiled"
}
puts "============================================================================"

