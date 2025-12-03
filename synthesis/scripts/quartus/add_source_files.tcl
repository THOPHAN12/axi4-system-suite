# ==============================================================================
# Add All Source Files to Quartus Project - UPDATED VERSION
# ==============================================================================
# Description: Adds all RTL files for dual RISC-V AXI Interconnect system
# Usage: quartus_sh -t add_source_files.tcl
#        OR in Quartus TCL console: source add_source_files.tcl
# ==============================================================================

# ==============================================================================
# CONFIGURATION
# ==============================================================================

set project_name "AXI_Interconnect_System"

# Path configuration
set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir .. .. ..]]
set project_dir [file join $project_root "synthesis" "quartus"]
set src_dir [file join $project_root "src"]

puts "\n===================================================================="
puts "Adding Source Files to Quartus Project"
puts "===================================================================="
puts "Project: $project_name"
puts "Root: $project_root"
puts "Source: $src_dir"
puts "====================================================================\n"

# Open project
cd $project_dir
project_open $project_name

# ==============================================================================
# HELPER FUNCTIONS
# ==============================================================================

proc add_verilog_file {file_path {library ""}} {
    set full_path [file normalize $file_path]
    if {[file exists $full_path]} {
        if {$library != ""} {
            set_global_assignment -name VERILOG_FILE $full_path -library $library
        } else {
            set_global_assignment -name VERILOG_FILE $full_path
        }
        puts "  ✓ [file tail $file_path]"
        return 1
    } else {
        puts "  ✗ MISSING: [file tail $file_path]"
        return 0
    }
}

proc add_directory {base_dir pattern {recursive 0}} {
    set count 0
    if {[file exists $base_dir]} {
        if {$recursive} {
            set files [glob -nocomplain -directory $base_dir -type f $pattern]
            foreach file $files {
                if {[string match "*.bak" $file] || [string match "*_tb.v" $file]} {
                    continue
                }
                if {[add_verilog_file $file]} {
                    incr count
                }
            }
            # Recursively search subdirectories
            set dirs [glob -nocomplain -directory $base_dir -type d *]
            foreach dir $dirs {
                set count [expr $count + [add_directory $dir $pattern 1]]
            }
        } else {
            set files [glob -nocomplain [file join $base_dir $pattern]]
            foreach file $files {
                if {[string match "*.bak" $file] || [string match "*_tb.v" $file]} {
                    continue
                }
                if {[add_verilog_file $file]} {
                    incr count
                }
            }
        }
    }
    return $count
}

# ==============================================================================
# ADD SOURCE FILES IN DEPENDENCY ORDER
# ==============================================================================

set total_files 0

# ==============================================================================
# 1. SERV RISC-V CORE
# ==============================================================================
puts "\n[1] SERV RISC-V Core Files"
puts "--------------------------------------------------------------------"

set serv_rtl [file join $src_dir "cores" "serv" "rtl"]

# SERV core files in dependency order
set serv_files {
    "serv_state.v"
    "serv_immdec.v"
    "serv_compdec.v"
    "serv_decode.v"
    "serv_alu.v"
    "serv_ctrl.v"
    "serv_csr.v"
    "serv_bufreg.v"
    "serv_bufreg2.v"
    "serv_aligner.v"
    "serv_mem_if.v"
    "serv_rf_if.v"
    "serv_rf_ram_if.v"
    "serv_rf_ram.v"
    "serv_rf_top.v"
    "serv_top.v"
}

set serv_count 0
foreach file $serv_files {
    set file_path [file join $serv_rtl $file]
    if {[add_verilog_file $file_path]} {
        incr serv_count
    }
}
set total_files [expr $total_files + $serv_count]
puts "  Added: $serv_count files"

# ==============================================================================
# 2. WISHBONE TO AXI BRIDGE
# ==============================================================================
puts "\n[2] Wishbone to AXI Bridge"
puts "--------------------------------------------------------------------"

set bridge_dir [file join $src_dir "axi_bridge" "rtl"]

set bridge_files {
    "wb2axi_read.v"
    "wb2axi_write.v"
    "serv_axi_wrapper.v"
}

set bridge_count 0
foreach file $bridge_files {
    set file_path [file join $bridge_dir $file]
    if {[add_verilog_file $file_path]} {
        incr bridge_count
    }
}
set total_files [expr $total_files + $bridge_count]
puts "  Added: $bridge_count files"

# ==============================================================================
# 3. AXI INTERCONNECT (VERILOG VERSION)
# ==============================================================================
puts "\n[3] AXI Interconnect (Verilog)"
puts "--------------------------------------------------------------------"

set interconnect_base [file join $src_dir "axi_interconnect" "Verilog" "rtl"]

# 3.1 Utilities
puts "  [3.1] Utilities..."
set utils_dir [file join $interconnect_base "utils"]
set utils_count [add_directory $utils_dir "*.v"]
puts "    → $utils_count files"
set total_files [expr $total_files + $utils_count]

# 3.2 Datapath (Mux/Demux)
puts "  [3.2] Datapath (Mux/Demux)..."
set mux_dir [file join $interconnect_base "datapath" "mux"]
set demux_dir [file join $interconnect_base "datapath" "demux"]
set mux_count [add_directory $mux_dir "*.v"]
set demux_count [add_directory $demux_dir "*.v"]
set datapath_count [expr $mux_count + $demux_count]
puts "    → $datapath_count files (Mux: $mux_count, Demux: $demux_count)"
set total_files [expr $total_files + $datapath_count]

# 3.3 Handshake
puts "  [3.3] Handshake..."
set handshake_dir [file join $interconnect_base "handshake"]
set handshake_count [add_directory $handshake_dir "*.v"]
puts "    → $handshake_count files"
set total_files [expr $total_files + $handshake_count]

# 3.4 Buffers
puts "  [3.4] Buffers..."
set buffer_dir [file join $interconnect_base "buffers"]
set buffer_count [add_directory $buffer_dir "*.v"]
puts "    → $buffer_count files"
set total_files [expr $total_files + $buffer_count]

# 3.5 Arbitration
puts "  [3.5] Arbitration..."
set arb_dir [file join $interconnect_base "arbitration"]
set arb_count [add_directory $arb_dir "*.v"]
puts "    → $arb_count files"
set total_files [expr $total_files + $arb_count]

# 3.6 Decoders
puts "  [3.6] Decoders..."
set decoder_dir [file join $interconnect_base "decoders"]
set decoder_count [add_directory $decoder_dir "*.v"]
puts "    → $decoder_count files"
set total_files [expr $total_files + $decoder_count]

# 3.7 Channel Controllers - Write
puts "  [3.7] Write Channel Controllers..."
set write_ctrl_dir [file join $interconnect_base "channel_controllers" "write"]
set write_count [add_directory $write_ctrl_dir "*.v"]
puts "    → $write_count files"
set total_files [expr $total_files + $write_count]

# 3.8 Channel Controllers - Read
puts "  [3.8] Read Channel Controllers..."
set read_ctrl_dir [file join $interconnect_base "channel_controllers" "read"]
set read_count [add_directory $read_ctrl_dir "*.v"]
puts "    → $read_count files"
set total_files [expr $total_files + $read_count]

# 3.9 Core (Top-level interconnect)
puts "  [3.9] Core (Top-level Interconnect)..."
set core_dir [file join $interconnect_base "core"]
set core_count [add_directory $core_dir "*.v"]
puts "    → $core_count files"
set total_files [expr $total_files + $core_count]

set interconnect_total [expr $utils_count + $datapath_count + $handshake_count + \
                             $buffer_count + $arb_count + $decoder_count + \
                             $write_count + $read_count + $core_count]
puts "  Total Interconnect: $interconnect_total files"

# ==============================================================================
# 4. AXI-LITE PERIPHERALS
# ==============================================================================
puts "\n[4] AXI-Lite Peripherals (Slaves)"
puts "--------------------------------------------------------------------"

set periph_dir [file join $src_dir "peripherals" "axi_lite"]

set periph_files {
    "axi_lite_ram.v"
    "axi_lite_gpio.v"
    "axi_lite_uart.v"
    "axi_lite_spi.v"
}

set periph_count 0
foreach file $periph_files {
    set file_path [file join $periph_dir $file]
    if {[add_verilog_file $file_path]} {
        incr periph_count
    }
}
set total_files [expr $total_files + $periph_count]
puts "  Added: $periph_count peripheral files"

# ==============================================================================
# 5. TOP-LEVEL SYSTEM
# ==============================================================================
puts "\n[5] Top-Level System Integration"
puts "--------------------------------------------------------------------"

set systems_dir [file join $src_dir "systems"]

set system_files {
    "dual_riscv_axi_system.v"
}

set system_count 0
foreach file $system_files {
    set file_path [file join $systems_dir $file]
    if {[add_verilog_file $file_path]} {
        incr system_count
    }
}
set total_files [expr $total_files + $system_count]
puts "  Added: $system_count system file(s)"

# ==============================================================================
# 6. OPTIONAL: ADDITIONAL WRAPPERS
# ==============================================================================
puts "\n[6] Optional: Additional Wrappers"
puts "--------------------------------------------------------------------"

set optional_files {
    "axi_interconnect_2m4s_wrapper.v"
    "axi_interconnect_wrapper.v"
    "serv_axi_system.v"
}

set optional_count 0
foreach file $optional_files {
    set file_path [file join $systems_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr optional_count
        }
    }
}
if {$optional_count > 0} {
    set total_files [expr $total_files + $optional_count]
    puts "  Added: $optional_count optional wrapper(s)"
} else {
    puts "  No optional wrappers added"
}

# ==============================================================================
# SET INCLUDE DIRECTORIES
# ==============================================================================
puts "\n[7] Setting Include Directories"
puts "--------------------------------------------------------------------"

set include_dirs [list \
    [file join $src_dir "cores" "serv" "rtl"] \
    [file join $interconnect_base "includes"] \
]

foreach inc_dir $include_dirs {
    if {[file exists $inc_dir]} {
        set_global_assignment -name SEARCH_PATH $inc_dir
        puts "  ✓ [file tail $inc_dir]"
    }
}

# ==============================================================================
# SUMMARY
# ==============================================================================
puts "\n===================================================================="
puts "SUMMARY"
puts "===================================================================="
puts "Total files added: $total_files"
puts ""
puts "Breakdown:"
puts "  • SERV Core:          $serv_count files"
puts "  • WB2AXI Bridge:      $bridge_count files"
puts "  • AXI Interconnect:   $interconnect_total files"
puts "    - Utilities:        $utils_count"
puts "    - Datapath:         $datapath_count"
puts "    - Handshake:        $handshake_count"
puts "    - Buffers:          $buffer_count"
puts "    - Arbitration:      $arb_count"
puts "    - Decoders:         $decoder_count"
puts "    - Write Control:    $write_count"
puts "    - Read Control:     $read_count"
puts "    - Core:             $core_count"
puts "  • Peripherals:        $periph_count files"
puts "  • System:             $system_count file(s)"
if {$optional_count > 0} {
    puts "  • Optional:           $optional_count file(s)"
}
puts "===================================================================="
puts ""
puts "✓ All source files added to project!"
puts ""
puts "Next steps:"
puts "  1. Check Project Navigator to verify files"
puts "  2. Run: Processing -> Start -> Start Analysis & Elaboration"
puts "  3. Set pin assignments (Tools -> Pin Planner)"
puts "  4. Compile: Processing -> Start Compilation"
puts "===================================================================="

# Save and close project
export_assignments
project_close

puts "\n✓ Project saved successfully!\n"

