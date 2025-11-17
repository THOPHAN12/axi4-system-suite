# ============================================================================
# TCL Script to Compile and Run Dual Master System IP Testbench
# Usage: 
#   vsim -c -do "source compile_and_run_dual_master_ip.tcl; quit -f"
#   hoặc trong ModelSim GUI: source compile_and_run_dual_master_ip.tcl
# ============================================================================

# ============================================================================
# Cấu hình đường dẫn
# ============================================================================
set script_file [info script]
if {[string equal $script_file ""]} {
    set script_dir [pwd]
} else {
    set script_dir [file dirname [file normalize $script_file]]
}

# Tính project root (lên 4 cấp từ sim/modelsim/scripts/compile -> D:/AXI)
set project_root [file normalize [file join $script_dir .. .. .. ..]]

# Verify project root
if {![file exists $project_root]} {
    puts "ERROR: Project root not found: $project_root"
    quit -code 1
}

set src_path [file join $project_root "src"]
set tb_path [file join $project_root "tb"]
set intercon_path [file join $src_path "axi_interconnect" "rtl"]
set serv_path [file join $src_path "cores" "serv" "rtl"]
set alu_path [file join $src_path "cores" "alu"]
set wrapper_path [file join $src_path "wrapper"]

puts "\n============================================================================"
puts "Dual Master System IP - Compilation and Simulation"
puts "============================================================================"
puts "Script directory: $script_dir"
puts "Project root: $project_root"
puts "============================================================================\n"

# ============================================================================
# Clean up và tạo work library
# ============================================================================
puts "============================================================================"
puts "Cleaning up previous compilation..."
puts "============================================================================"
if {[file exists work]} {
    puts "Removing old work library..."
    vdel -lib work -all
}

puts "Creating work library..."
vlib work
vmap work work

# ============================================================================
# Compile theo thứ tự dependency
# ============================================================================
puts "\n============================================================================"
puts "Compiling Source Files..."
puts "============================================================================"

# 1. AXI Interconnect - Utils
puts "\n1. Compiling AXI Interconnect Utils..."
set utils_path [file join $intercon_path "utils"]
if {[file exists $utils_path]} {
    set utils_files [glob -nocomplain [file join $utils_path "*.v"]]
    foreach file $utils_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 2. AXI Interconnect - Handshake
puts "\n2. Compiling AXI Interconnect Handshake..."
set handshake_path [file join $intercon_path "handshake"]
if {[file exists $handshake_path]} {
    set handshake_files [glob -nocomplain [file join $handshake_path "*.v"]]
    foreach file $handshake_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 3. AXI Interconnect - Datapath MUX
puts "\n3. Compiling AXI Interconnect Datapath MUX..."
set mux_path [file join $intercon_path "datapath" "mux"]
if {[file exists $mux_path]} {
    set mux_files [glob -nocomplain [file join $mux_path "*.v"]]
    foreach file $mux_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 4. AXI Interconnect - Datapath DEMUX
puts "\n4. Compiling AXI Interconnect Datapath DEMUX..."
set demux_path [file join $intercon_path "datapath" "demux"]
if {[file exists $demux_path]} {
    set demux_files [glob -nocomplain [file join $demux_path "*.v"]]
    foreach file $demux_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 5. AXI Interconnect - Buffers
puts "\n5. Compiling AXI Interconnect Buffers..."
set buffers_path [file join $intercon_path "buffers"]
if {[file exists $buffers_path]} {
    set buffers_files [glob -nocomplain [file join $buffers_path "*.v"]]
    foreach file $buffers_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 6. AXI Interconnect - Arbitration
puts "\n6. Compiling AXI Interconnect Arbitration..."
set arb_path [file join $intercon_path "arbitration"]
if {[file exists $arb_path]} {
    set arb_files [glob -nocomplain [file join $arb_path "*.v"]]
    foreach file $arb_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 7. AXI Interconnect - Decoders
puts "\n7. Compiling AXI Interconnect Decoders..."
set decoders_path [file join $intercon_path "decoders"]
if {[file exists $decoders_path]} {
    set decoders_files [glob -nocomplain [file join $decoders_path "*.v"]]
    foreach file $decoders_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 8. AXI Interconnect - Channel Controllers (Write)
puts "\n8. Compiling AXI Interconnect Write Channel Controllers..."
set write_ctrl_path [file join $intercon_path "channel_controllers" "write"]
if {[file exists $write_ctrl_path]} {
    set write_ctrl_files [glob -nocomplain [file join $write_ctrl_path "*.v"]]
    foreach file $write_ctrl_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 9. AXI Interconnect - Channel Controllers (Read)
puts "\n9. Compiling AXI Interconnect Read Channel Controllers..."
set read_ctrl_path [file join $intercon_path "channel_controllers" "read"]
if {[file exists $read_ctrl_path]} {
    set read_ctrl_files [glob -nocomplain [file join $read_ctrl_path "*.v"]]
    foreach file $read_ctrl_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 10. AXI Interconnect - Core
puts "\n10. Compiling AXI Interconnect Core..."
set core_path [file join $intercon_path "core"]
if {[file exists $core_path]} {
    set core_files [glob -nocomplain [file join $core_path "*.v"]]
    foreach file $core_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 11. SERV RISC-V Core (theo thứ tự dependency)
puts "\n11. Compiling SERV RISC-V Core..."
if {[file exists $serv_path]} {
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
    foreach file $serv_files {
        set file_path [file join $serv_path $file]
        if {[file exists $file_path]} {
            puts "  Compiling: $file"
            vlog -work work $file_path
        } else {
            puts "  WARNING: File not found: $file_path"
        }
    }
} else {
    puts "ERROR: SERV core directory not found: $serv_path"
    quit -code 1
}

# 12. Wishbone to AXI Converters
puts "\n12. Compiling Wishbone to AXI Converters..."
set converters_path [file join $wrapper_path "converters"]
if {[file exists $converters_path]} {
    set converter_files [glob -nocomplain [file join $converters_path "*.v"]]
    foreach file $converter_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 13. SERV AXI Wrapper
puts "\n13. Compiling SERV AXI Wrapper..."
set serv_wrapper_file [file join $wrapper_path "converters" "serv_axi_wrapper.v"]
if {[file exists $serv_wrapper_file]} {
    puts "  Compiling: serv_axi_wrapper.v"
    vlog -work work $serv_wrapper_file
} else {
    puts "WARNING: SERV AXI Wrapper not found: $serv_wrapper_file (already compiled in converters or not required)"
}

# 14. ALU Core Components
puts "\n14. Compiling ALU Master Components..."
if {[file exists $alu_path]} {
    # Compile ALU_Core first
    set alu_core_file [file join $alu_path "ALU_Core.v"]
    if {[file exists $alu_core_file]} {
        puts "  Compiling: ALU_Core.v"
        vlog -work work $alu_core_file
    } else {
        puts "ERROR: ALU_Core not found: $alu_core_file"
        quit -code 1
    }
    
    # Compile CPU_Controller second
    set cpu_controller_file [file join $alu_path "CPU_Controller.v"]
    if {[file exists $cpu_controller_file]} {
        puts "  Compiling: CPU_Controller.v"
        vlog -work work $cpu_controller_file
    } else {
        puts "ERROR: CPU_Controller not found: $cpu_controller_file"
        quit -code 1
    }
    
    # Compile CPU_ALU_Master last
    set alu_master_file [file join $alu_path "CPU_ALU_Master.v"]
    if {[file exists $alu_master_file]} {
        puts "  Compiling: CPU_ALU_Master.v"
        vlog -work work $alu_master_file
    } else {
        puts "ERROR: CPU_ALU_Master not found: $alu_master_file"
        quit -code 1
    }
} else {
    puts "ERROR: ALU directory not found: $alu_path"
    quit -code 1
}

# 15. Memory Slaves
puts "\n15. Compiling Memory Slaves..."
set memory_path [file join $wrapper_path "memory"]
if {[file exists $memory_path]} {
    set memory_files [glob -nocomplain [file join $memory_path "*.v"]]
    foreach file $memory_files {
        if {![string match "*.bak" $file]} {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
}

# 16. Dual Master System IP
puts "\n16. Compiling Dual Master System IP..."
set ip_file [file join $wrapper_path "ip" "dual_master_system_ip.v"]
if {[file exists $ip_file]} {
    puts "  Compiling: dual_master_system_ip.v"
    vlog -work work $ip_file
} else {
    puts "ERROR: Dual Master System IP not found: $ip_file"
    quit -code 1
}

# 17. Testbench
puts "\n17. Compiling Testbench..."
set tb_file [file join $tb_path "wrapper_tb" "testbenches" "dual_master" "dual_master_system_ip_tb_RISC_V.v"]
if {[file exists $tb_file]} {
    puts "  Compiling: dual_master_system_ip_tb_RISC_V.v"
    vlog -work work $tb_file
} else {
    puts "ERROR: Testbench not found: $tb_file"
    quit -code 1
}

puts "\n============================================================================"
puts "Compilation Complete!"
puts "============================================================================"
puts ""

# ============================================================================
# Start Simulation
# ============================================================================
puts "============================================================================"
puts "Starting Simulation"
puts "============================================================================"
puts ""

# Start simulation with GUI
vsim -voptargs=+acc -t ps work.dual_master_system_ip_tb_RISC_V

# Add waves
puts "Adding waves to Wave window..."
add wave -divider "Clock and Reset"
add wave -radix binary /dual_master_system_ip_tb_RISC_V/ACLK
add wave -radix binary /dual_master_system_ip_tb_RISC_V/ARESETN
add wave -radix binary /dual_master_system_ip_tb_RISC_V/i_timer_irq

add wave -divider "ALU Master Control"
add wave -radix binary /dual_master_system_ip_tb_RISC_V/alu_master_start
add wave -radix binary /dual_master_system_ip_tb_RISC_V/alu_master_busy
add wave -radix binary /dual_master_system_ip_tb_RISC_V/alu_master_done

add wave -divider "Memory Status"
add wave -radix binary /dual_master_system_ip_tb_RISC_V/inst_mem_ready
add wave -radix binary /dual_master_system_ip_tb_RISC_V/data_mem_ready
add wave -radix binary /dual_master_system_ip_tb_RISC_V/alu_mem_ready
add wave -radix binary /dual_master_system_ip_tb_RISC_V/reserved_mem_ready

add wave -divider "Test Counters"
add wave -radix decimal /dual_master_system_ip_tb_RISC_V/pass_count
add wave -radix decimal /dual_master_system_ip_tb_RISC_V/fail_count
add wave -radix decimal /dual_master_system_ip_tb_RISC_V/test_idx

add wave -divider "DUT - ALU Master"
add wave -radix hex /dual_master_system_ip_tb_RISC_V/u_dut/u_alu_master/*
add wave -radix hex /dual_master_system_ip_tb_RISC_V/u_dut/u_alu_master/u_controller/*
add wave -radix hex /dual_master_system_ip_tb_RISC_V/u_dut/u_alu_master/u_alu/*

add wave -divider "DUT - Memory Slaves"
add wave -radix hex /dual_master_system_ip_tb_RISC_V/u_dut/u_inst_mem/*
add wave -radix hex /dual_master_system_ip_tb_RISC_V/u_dut/u_data_mem/*
add wave -radix hex /dual_master_system_ip_tb_RISC_V/u_dut/u_alu_mem/*

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -timelineunits ns
wave zoom full

puts ""
puts "============================================================================"
puts "Simulation Ready!"
puts "============================================================================"
puts "Use 'run -all' to run the complete simulation"
puts "or 'run <time>' to run for a specific duration"
puts "============================================================================"
puts ""

