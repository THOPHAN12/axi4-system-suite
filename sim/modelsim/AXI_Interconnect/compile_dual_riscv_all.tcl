#==============================================================================
# compile_dual_riscv_all.tcl
# Compile all dual RISC-V system files in correct dependency order
#==============================================================================

puts "============================================================================"
puts "Compiling Dual RISC-V System Files"
puts "============================================================================"
puts ""

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR

# Calculate ROOT_DIR: script is in sim/modelsim/AXI_Interconnect/, so go up 3 levels
set ROOT_DIR_TMP [file join $SCRIPT_DIR .. .. ..]
set ROOT_DIR [file normalize $ROOT_DIR_TMP]
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]

puts "Root directory: $ROOT_DIR"
puts "Source base: $SRC_BASE"
puts ""

# Change to project directory
cd $PROJECT_DIR

# Initialize work library
if {![file exists work]} {
    puts "Creating work library..."
    vlib work
}
vmap work work

puts ""
puts "Compiling files in dependency order..."
puts ""

set compile_count 0
set error_count 0

#==============================================================================
# PART 1: SERV RISC-V Core Files
#==============================================================================
puts "============================================================================"
puts "PART 1: SERV RISC-V Core Files"
puts "============================================================================"

set SERV_RTL_DIR [file normalize [file join $SRC_BASE "cores" "serv" "rtl"]]

if {[file exists $SERV_RTL_DIR]} {
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
            if {[catch {vlog -work work $full_path} err]} {
                puts "  ✗ ERROR compiling: $file"
                puts "    $err"
                incr error_count
            } else {
                puts "  ✓ Compiled: $file"
                incr compile_count
            }
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
set SERV_RTL_DIR [file normalize [file join $SRC_BASE "cores" "serv" "rtl"]]
set SERV_CORE_DIR [file normalize [file join $SRC_BASE "cores" "serv"]]
set PIPELINE_RTL_DIR [file normalize [file join $SRC_BASE "cores" "riscv-5stage-pipeline" "rtl"]]
set PIPELINE_CORE_DIR [file normalize [file join $SRC_BASE "cores" "riscv-5stage-pipeline"]]
set PIPELINE_CORE_RTL_DIR [file normalize [file join $PIPELINE_CORE_DIR "rtl" "core"]]

# Set include directories for bridge files (relative paths from src/axi_bridge/)
# serv_axi_wrapper.v uses: ../cores/serv/rtl/serv_top.v
#   - This relative path is resolved from src/axi_bridge/, so we need src/cores/serv/ in include path
# riscv_pipeline_axi_wrapper.v uses: ../cores/riscv-5stage-pipeline/rtl/core/RV32I_PIPELINE.v
#   - This relative path is resolved from src/axi_bridge/, so we need src/cores/riscv-5stage-pipeline/ in include path
# Note: For relative paths like ../cores/serv/rtl/serv_top.v, ModelSim resolves from the file's directory
# So we need to add the parent directory (src/cores/serv/) to the include path
set CORES_DIR [file normalize [file join $SRC_BASE "cores"]]
set incdirs "+incdir+$SRC_BASE +incdir+$CORES_DIR +incdir+$BRIDGE_DIR +incdir+$SERV_CORE_DIR +incdir+$SERV_RTL_DIR +incdir+$PIPELINE_CORE_DIR +incdir+$PIPELINE_RTL_DIR +incdir+$PIPELINE_CORE_RTL_DIR"

set wrapper_files [list \
    "serv_axi_wrapper.v" \
    "riscv_pipeline_axi_wrapper.v" \
    "friscv_axi_wrapper.v" \
]

foreach file $wrapper_files {
    set full_path [file normalize [file join $BRIDGE_DIR $file]]
    if {[file exists $full_path]} {
        # Skip riscv_pipeline_axi_wrapper.v if riscv-5stage-pipeline doesn't exist or is empty
        if {$file == "riscv_pipeline_axi_wrapper.v"} {
            set pipeline_rtl_core [file normalize [file join $PIPELINE_CORE_DIR "rtl" "core" "RV32I_PIPELINE.v"]]
            if {![file exists $pipeline_rtl_core]} {
                puts "  ⚠ Skipping: $file (RV32I_PIPELINE.v not found in riscv-5stage-pipeline)"
                continue
            }
        }
        if {[catch {vlog -work work $incdirs $full_path} err]} {
            puts "  ✗ ERROR compiling: $file"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: $file"
            incr compile_count
        }
    } else {
        puts "  ⚠ Not found: $file"
    }
}

puts ""

#==============================================================================
# PART 3: AXI Interconnect - Utils and Handshake
#==============================================================================
puts "============================================================================"
puts "PART 3: AXI Interconnect - Utils and Handshake"
puts "============================================================================"

set AXI_RTL_DIR [file normalize [file join $SRC_BASE "axi_interconnect" "rtl"]]

# Utils
set utils_dir [file normalize [file join $AXI_RTL_DIR "utils"]]
if {[file exists $utils_dir]} {
    set utils_files [glob -nocomplain -directory $utils_dir -type f "*.v"]
    foreach file $utils_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

# Handshake
set handshake_dir [file normalize [file join $AXI_RTL_DIR "handshake"]]
if {[file exists $handshake_dir]} {
    set handshake_files [glob -nocomplain -directory $handshake_dir -type f "*.v"]
    foreach file $handshake_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

puts ""

#==============================================================================
# PART 4: AXI Interconnect - Buffers
#==============================================================================
puts "============================================================================"
puts "PART 4: AXI Interconnect - Buffers"
puts "============================================================================"

set buffers_dir [file normalize [file join $AXI_RTL_DIR "buffers"]]
if {[file exists $buffers_dir]} {
    set buffers_files [glob -nocomplain -directory $buffers_dir -type f "*.v"]
    foreach file $buffers_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

puts ""

#==============================================================================
# PART 5: AXI Interconnect - Datapath (MUX/DEMUX)
#==============================================================================
puts "============================================================================"
puts "PART 5: AXI Interconnect - Datapath (MUX/DEMUX)"
puts "============================================================================"

# MUX
set mux_dir [file normalize [file join $AXI_RTL_DIR "datapath" "mux"]]
if {[file exists $mux_dir]} {
    set mux_files [glob -nocomplain -directory $mux_dir -type f "*.v"]
    foreach file $mux_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

# DEMUX
set demux_dir [file normalize [file join $AXI_RTL_DIR "datapath" "demux"]]
if {[file exists $demux_dir]} {
    set demux_files [glob -nocomplain -directory $demux_dir -type f "*.v"]
    foreach file $demux_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

puts ""

#==============================================================================
# PART 6: AXI Interconnect - Decoders
#==============================================================================
puts "============================================================================"
puts "PART 6: AXI Interconnect - Decoders"
puts "============================================================================"

set decoders_dir [file normalize [file join $AXI_RTL_DIR "decoders"]]
if {[file exists $decoders_dir]} {
    set decoders_files [glob -nocomplain -directory $decoders_dir -type f "*.v"]
    foreach file $decoders_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

puts ""

#==============================================================================
# PART 7: AXI Interconnect - Arbitration
#==============================================================================
puts "============================================================================"
puts "PART 7: AXI Interconnect - Arbitration"
puts "============================================================================"

set arb_dir [file normalize [file join $AXI_RTL_DIR "arbitration" "algorithms"]]
if {[file exists $arb_dir]} {
    set arb_files [glob -nocomplain -directory $arb_dir -type f "*.v"]
    foreach file $arb_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

puts ""

#==============================================================================
# PART 8: AXI Interconnect - Channel Controllers
#==============================================================================
puts "============================================================================"
puts "PART 8: AXI Interconnect - Channel Controllers"
puts "============================================================================"

# Read channel controllers
set read_ctrl_dir [file normalize [file join $AXI_RTL_DIR "channel_controllers" "read"]]
if {[file exists $read_ctrl_dir]} {
    set read_ctrl_files [glob -nocomplain -directory $read_ctrl_dir -type f "*.v"]
    foreach file $read_ctrl_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

# Write channel controllers
set write_ctrl_dir [file normalize [file join $AXI_RTL_DIR "channel_controllers" "write"]]
if {[file exists $write_ctrl_dir]} {
    set write_ctrl_files [glob -nocomplain -directory $write_ctrl_dir -type f "*.v"]
    foreach file $write_ctrl_files {
        if {[catch {vlog -work work $file} err]} {
            puts "  ✗ ERROR compiling: [file tail $file]"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: [file tail $file]"
            incr compile_count
        }
    }
}

puts ""

#==============================================================================
# PART 9: AXI Interconnect - Core
#==============================================================================
puts "============================================================================"
puts "PART 9: AXI Interconnect - Core"
puts "============================================================================"

set core_dir [file normalize [file join $AXI_RTL_DIR "core"]]
set interconnect_file [file normalize [file join $core_dir "AXI_Interconnect.v"]]

if {[file exists $interconnect_file]} {
    if {[catch {vlog -work work $interconnect_file} err]} {
        puts "  ✗ ERROR compiling: AXI_Interconnect.v"
        puts "    $err"
        incr error_count
    } else {
        puts "  ✓ Compiled: AXI_Interconnect.v"
        incr compile_count
    }
} else {
    puts "  ⚠ Not found: AXI_Interconnect.v"
}

puts ""

#==============================================================================
# PART 10: AXI-Lite Peripherals
#==============================================================================
puts "============================================================================"
puts "PART 10: AXI-Lite Peripherals"
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
    if {[file exists $full_path]} {
        if {[catch {vlog -work work $full_path} err]} {
            puts "  ✗ ERROR compiling: $file"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: $file"
            incr compile_count
        }
    } else {
        puts "  ⚠ Not found: $file"
    }
}

puts ""

#==============================================================================
# PART 11: AXI Master Aggregator
#==============================================================================
puts "============================================================================"
puts "PART 11: AXI Master Aggregator"
puts "============================================================================"

set aggregator_file [file normalize [file join $AXI_RTL_DIR "core" "AXI_Master_Aggregator.v"]]

if {[file exists $aggregator_file]} {
    if {[catch {vlog -work work $aggregator_file} err]} {
        puts "  ✗ ERROR compiling: AXI_Master_Aggregator.v"
        puts "    $err"
        incr error_count
    } else {
        puts "  ✓ Compiled: AXI_Master_Aggregator.v"
        incr compile_count
    }
} else {
    puts "  ⚠ Not found: AXI_Master_Aggregator.v"
}

puts ""

#==============================================================================
# PART 12: Dual AXI Shell
#==============================================================================
puts "============================================================================"
puts "PART 12: Dual AXI Shell"
puts "============================================================================"

set shell_file [file normalize [file join $SRC_BASE "systems" "dual_axi_shell.v"]]
set SYSTEMS_DIR [file normalize [file join $SRC_BASE "systems"]]
set AXI_RTL_DIR [file normalize [file join $SRC_BASE "axi_interconnect" "rtl"]]
set AXI_CORE_DIR [file normalize [file join $AXI_RTL_DIR "core"]]

# Set include directories for system files
set sys_incdirs "+incdir+$SRC_BASE +incdir+$SYSTEMS_DIR +incdir+$AXI_CORE_DIR"

if {[file exists $shell_file]} {
    if {[catch {vlog -work work $sys_incdirs $shell_file} err]} {
        puts "  ✗ ERROR compiling: dual_axi_shell.v"
        puts "    $err"
        incr error_count
    } else {
        puts "  ✓ Compiled: dual_axi_shell.v"
        incr compile_count
    }
} else {
    puts "  ⚠ Not found: dual_axi_shell.v"
}

puts ""

#==============================================================================
# PART 13: Top System Modules
#==============================================================================
puts "============================================================================"
puts "PART 13: Top System Modules"
puts "============================================================================"

set SYSTEMS_DIR [file normalize [file join $SRC_BASE "systems"]]
set BRIDGE_DIR [file normalize [file join $SRC_BASE "axi_bridge"]]
set PERIPHERALS_DIR [file normalize [file join $SRC_BASE "peripherals" "axi_lite"]]
set AXI_RTL_DIR [file normalize [file join $SRC_BASE "axi_interconnect" "rtl"]]
set AXI_CORE_DIR [file normalize [file join $AXI_RTL_DIR "core"]]

# Check if riscv-5stage-pipeline exists
set PIPELINE_RTL_CORE_FILE [file normalize [file join $PIPELINE_CORE_DIR "rtl" "core" "RV32I_PIPELINE.v"]]
set has_pipeline [file exists $PIPELINE_RTL_CORE_FILE]

# Set include directories for system files (comprehensive)
# Note: dual_pipeline_serv_axi_system.v uses: include "dual_axi_shell.v" (relative to systems/)
# So we need SYSTEMS_DIR in the include path
set sys_incdirs "+incdir+$SRC_BASE +incdir+$SYSTEMS_DIR +incdir+$BRIDGE_DIR +incdir+$AXI_CORE_DIR +incdir+$PERIPHERALS_DIR +incdir+$SERV_RTL_DIR +incdir+$PIPELINE_RTL_DIR +incdir+$PIPELINE_CORE_RTL_DIR"

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
        
        if {[catch {vlog -work work $sys_incdirs $full_path} err]} {
            puts "  ✗ ERROR compiling: $file"
            puts "    $err"
            incr error_count
        } else {
            puts "  ✓ Compiled: $file"
            incr compile_count
        }
    } else {
        puts "  ⚠ Not found: $file"
    }
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "COMPILATION SUMMARY"
puts "============================================================================"
puts ""
puts "Files compiled successfully: $compile_count"
if {$error_count > 0} {
    puts "Files with errors: $error_count"
} else {
    puts "No compilation errors!"
}
puts ""
puts "============================================================================"


