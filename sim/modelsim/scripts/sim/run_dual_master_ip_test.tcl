###############################################################################
# run_dual_master_ip_test.tcl : TCL Script to Compile and Run
#                               dual_master_system_ip_tb.v
###############################################################################

# Get the directory where this script is located
set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir .. ..]]

puts "============================================================================"
puts "Dual Master System IP Testbench - Compilation and Simulation"
puts "============================================================================"
puts "Script directory: $script_dir"
puts "Project root: $project_root"
puts "============================================================================"
puts ""

# Set working directory
cd $script_dir

# Remove old work library
if {[file exists work]} {
    puts "Removing old work library..."
    vdel -lib work -all
}

# Create work library
puts "Creating work library..."
vlib work
vmap work work

puts ""
puts "============================================================================"
puts "Compiling Source Files"
puts "============================================================================"
puts ""

# Compile SERV Core files
set serv_dir [file join $project_root src cores serv rtl]
if {[file exists $serv_dir]} {
    puts "Compiling SERV Core files..."
    set serv_files {
        serv_alu.v
        serv_bufreg.v
        serv_bufreg2.v
        serv_csr.v
        serv_ctrl.v
        serv_decode.v
        serv_immdec.v
        serv_mem_if.v
        serv_rf_if.v
        serv_rf_ram_if.v
        serv_rf_ram.v
        serv_rf_top.v
        serv_state.v
        serv_top.v
    }
    
    foreach file $serv_files {
        set file_path [file join $serv_dir $file]
        if {[file exists $file_path]} {
            puts "  Compiling: $file"
            vlog -work work $file_path
        } else {
            puts "  WARNING: File not found: $file_path"
        }
    }
} else {
    puts "ERROR: SERV core directory not found: $serv_dir"
    exit 1
}

puts ""

# Compile AXI Interconnect files
set axi_interconnect_dir [file join $project_root src axi_interconnect rtl]
if {[file exists $axi_interconnect_dir]} {
    puts "Compiling AXI Interconnect files..."
    
    # Compile utility files first
    set utils_dir [file join $axi_interconnect_dir utils]
    if {[file exists $utils_dir]} {
        set utils_files [glob -nocomplain [file join $utils_dir *.v]]
        foreach file $utils_files {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
    
    # Compile handshake modules
    set handshake_dir [file join $axi_interconnect_dir handshake]
    if {[file exists $handshake_dir]} {
        set handshake_files [glob -nocomplain [file join $handshake_dir *.v]]
        foreach file $handshake_files {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
    
    # Compile buffers
    set buffers_dir [file join $axi_interconnect_dir buffers]
    if {[file exists $buffers_dir]} {
        set buffers_files [glob -nocomplain [file join $buffers_dir *.v]]
        foreach file $buffers_files {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
    
    # Compile arbitration
    set arbitration_dir [file join $axi_interconnect_dir arbitration]
    if {[file exists $arbitration_dir]} {
        set arbitration_files [glob -nocomplain [file join $arbitration_dir *.v]]
        foreach file $arbitration_files {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
    
    # Compile datapath (mux/demux)
    set datapath_dir [file join $axi_interconnect_dir datapath]
    if {[file exists $datapath_dir]} {
        # Mux
        set mux_dir [file join $datapath_dir mux]
        if {[file exists $mux_dir]} {
            set mux_files [glob -nocomplain [file join $mux_dir *.v]]
            foreach file $mux_files {
                puts "  Compiling: [file tail $file]"
                vlog -work work $file
            }
        }
        # Demux
        set demux_dir [file join $datapath_dir demux]
        if {[file exists $demux_dir]} {
            set demux_files [glob -nocomplain [file join $demux_dir *.v]]
            foreach file $demux_files {
                puts "  Compiling: [file tail $file]"
                vlog -work work $file
            }
        }
    }
    
    # Compile decoders
    set decoders_dir [file join $axi_interconnect_dir decoders]
    if {[file exists $decoders_dir]} {
        set decoders_files [glob -nocomplain [file join $decoders_dir *.v]]
        foreach file $decoders_files {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
    
    # Compile channel controllers
    set channel_ctrl_dir [file join $axi_interconnect_dir channel_controllers]
    if {[file exists $channel_ctrl_dir]} {
        # Write channel controllers
        set write_ctrl_dir [file join $channel_ctrl_dir write]
        if {[file exists $write_ctrl_dir]} {
            set write_ctrl_files [glob -nocomplain [file join $write_ctrl_dir *.v]]
            foreach file $write_ctrl_files {
                puts "  Compiling: [file tail $file]"
                vlog -work work $file
            }
        }
        # Read channel controllers
        set read_ctrl_dir [file join $channel_ctrl_dir read]
        if {[file exists $read_ctrl_dir]} {
            set read_ctrl_files [glob -nocomplain [file join $read_ctrl_dir *.v]]
            foreach file $read_ctrl_files {
                puts "  Compiling: [file tail $file]"
                vlog -work work $file
            }
        }
    }
    
    # Compile core (must be last)
    set core_dir [file join $axi_interconnect_dir core]
    if {[file exists $core_dir]} {
        set core_files [glob -nocomplain [file join $core_dir *.v]]
        foreach file $core_files {
            puts "  Compiling: [file tail $file]"
            vlog -work work $file
        }
    }
} else {
    puts "ERROR: AXI Interconnect directory not found: $axi_interconnect_dir"
    exit 1
}

puts ""

# Compile Wishbone to AXI Converters (must be before serv_axi_wrapper)
set wrapper_dir [file join $project_root src wrapper]
set wb2axi_read_file [file join $wrapper_dir converters wb2axi_read.v]
set wb2axi_write_file [file join $wrapper_dir converters wb2axi_write.v]

if {[file exists $wb2axi_read_file]} {
    puts "Compiling wb2axi_read..."
    vlog -work work $wb2axi_read_file
} else {
    puts "ERROR: wb2axi_read not found: $wb2axi_read_file"
    exit 1
}

if {[file exists $wb2axi_write_file]} {
    puts "Compiling wb2axi_write..."
    vlog -work work $wb2axi_write_file
} else {
    puts "ERROR: wb2axi_write not found: $wb2axi_write_file"
    exit 1
}

puts ""

# Compile SERV AXI Wrapper
set serv_wrapper_file [file join $project_root src wrapper serv_axi_wrapper.v]
if {[file exists $serv_wrapper_file]} {
    puts "Compiling SERV AXI Wrapper..."
    vlog -work work $serv_wrapper_file
} else {
    puts "ERROR: SERV AXI Wrapper not found: $serv_wrapper_file"
    exit 1
}

puts ""

# Compile ALU Master Components (must compile dependencies first)
set alu_dir [file join $project_root Master_ALU ALU]
if {[file exists $alu_dir]} {
    puts "Compiling ALU Master Components..."
    
    # Compile ALU_Core first
    set alu_core_file [file join $alu_dir ALU_Core.v]
    if {[file exists $alu_core_file]} {
        puts "  Compiling: ALU_Core.v"
        vlog -work work $alu_core_file
    } else {
        puts "ERROR: ALU_Core not found: $alu_core_file"
        exit 1
    }
    
    # Compile CPU_Controller second
    set cpu_controller_file [file join $alu_dir CPU_Controller.v]
    if {[file exists $cpu_controller_file]} {
        puts "  Compiling: CPU_Controller.v"
        vlog -work work $cpu_controller_file
    } else {
        puts "ERROR: CPU_Controller not found: $cpu_controller_file"
        exit 1
    }
    
    # Compile CPU_ALU_Master last (depends on ALU_Core and CPU_Controller)
    set alu_master_file [file join $alu_dir CPU_ALU_Master.v]
    if {[file exists $alu_master_file]} {
        puts "  Compiling: CPU_ALU_Master.v"
        vlog -work work $alu_master_file
    } else {
        puts "ERROR: ALU Master not found: $alu_master_file"
        exit 1
    }
} else {
    puts "ERROR: ALU directory not found: $alu_dir"
    exit 1
}

puts ""

# Compile Memory Slaves
set memory_slaves {
    {src wrapper memory axi_rom_slave.v}
    {src wrapper memory axi_memory_slave.v}
}

foreach slave $memory_slaves {
    set slave_file [file join $project_root {*}$slave]
    if {[file exists $slave_file]} {
        puts "Compiling: [file tail $slave_file]"
        vlog -work work $slave_file
    } else {
        puts "WARNING: Memory slave not found: $slave_file"
    }
}

puts ""

# Compile Dual Master System IP
set ip_file [file join $project_root src wrapper ip dual_master_system_ip.v]
if {[file exists $ip_file]} {
    puts "Compiling Dual Master System IP..."
    vlog -work work $ip_file
} else {
    puts "ERROR: Dual Master System IP not found: $ip_file"
    exit 1
}

puts ""

# Compile Testbench
set tb_file [file join $project_root tb wrapper_tb testbenches dual_master dual_master_system_ip_tb.v]
if {[file exists $tb_file]} {
    puts "Compiling Testbench..."
    vlog -work work $tb_file
} else {
    puts "ERROR: Testbench not found: $tb_file"
    exit 1
}

puts ""
puts "============================================================================"
puts "Starting Simulation"
puts "============================================================================"
puts ""

# Start simulation
vsim -voptargs=+acc work.dual_master_system_ip_tb

# Add waves
add wave -divider "Clock and Reset"
add wave -radix binary /dual_master_system_ip_tb/ACLK
add wave -radix binary /dual_master_system_ip_tb/ARESETN
add wave -radix binary /dual_master_system_ip_tb/i_timer_irq

add wave -divider "ALU Master Control"
add wave -radix binary /dual_master_system_ip_tb/alu_master_start
add wave -radix binary /dual_master_system_ip_tb/alu_master_busy
add wave -radix binary /dual_master_system_ip_tb/alu_master_done

add wave -divider "Memory Status"
add wave -radix binary /dual_master_system_ip_tb/inst_mem_ready
add wave -radix binary /dual_master_system_ip_tb/data_mem_ready
add wave -radix binary /dual_master_system_ip_tb/alu_mem_ready
add wave -radix binary /dual_master_system_ip_tb/reserved_mem_ready

add wave -divider "DUT"
add wave -radix hex /dual_master_system_ip_tb/u_dut/*

# Run simulation
puts "Running simulation for 10000 ns..."
run 10000ns

puts ""
puts "============================================================================"
puts "Simulation Complete"
puts "============================================================================"
puts ""

# Keep window open
# wave zoom full

