# ============================================================================
# TCL Script de compile va simulate SERV AXI System trong ModelSim
# ============================================================================
# Script nay se:
# 1. Xoa cac file cu (work directory)
# 2. Compile tat ca source files
# 3. Load top-level module
# 4. Run simulation
# ============================================================================

# Thiet lap thu muc lam viec
set project_dir [file normalize [file dirname [info script]]]
set src_base_dir [file normalize [file join $project_dir .. .. src]]
set tb_dir [file normalize [file join $project_dir .. .. tb]]

# Debug: In ra duong dan
puts "\n============================================================================"
puts "ModelSim Compilation Script"
puts "============================================================================"
puts "Script location: [info script]"
puts "Project directory: $project_dir"
puts "Source base directory: $src_base_dir"
puts "Testbench directory: $tb_dir"
puts "============================================================================\n"

# Kiem tra thu muc source co ton tai khong
if {![file exists $src_base_dir]} {
    puts "ERROR: Thu muc source khong ton tai: $src_base_dir"
    return
}

# Khoi tao work library
# Luu y: Neu ModelSim dang mo hoac work directory dang duoc su dung, 
# khong the xoa duoc -> chi can compile lai vao work library hien co
puts "Khoi tao work library..."

# Thu xoa library mapping cu neu co
catch {vmap -del work}

# Kiem tra xem work directory co ton tai khong
if {[file exists work]} {
    puts "Work directory da ton tai, su dung library hien co..."
    # Thu tao lai library mapping (neu chua co)
    if {[catch {vmap work work} err]} {
        puts "Canh bao: Khong the map work library: $err"
        puts "Thu tao lai work library..."
        # Neu khong map duoc, co the work directory khong phai la library hop le
        # Thu xoa va tao lai (neu co the)
        if {![catch {file delete -force work} del_err]} {
            vlib work
            vmap work work
        } else {
            puts "Loi: Khong the xoa work directory (co the ModelSim dang mo)"
            puts "Vui long dong ModelSim hoac chay: vmap -del work"
            puts "Sau do chay lai script."
            return
        }
    }
} else {
    # Tao work library moi
    puts "Tao work library moi..."
    vlib work
    vmap work work
}

# Thiet lap include directories
set include_dirs [list \
    "$src_base_dir/cores/serv/rtl" \
    "$src_base_dir/axi_interconnect/rtl" \
    "$src_base_dir/wrapper" \
]

# Compile SERV RISC-V Core files
puts "\n1. Compiling SERV RISC-V Core files..."
set serv_files [list \
    "$src_base_dir/cores/serv/rtl/serv_state.v" \
    "$src_base_dir/cores/serv/rtl/serv_immdec.v" \
    "$src_base_dir/cores/serv/rtl/serv_compdec.v" \
    "$src_base_dir/cores/serv/rtl/serv_decode.v" \
    "$src_base_dir/cores/serv/rtl/serv_alu.v" \
    "$src_base_dir/cores/serv/rtl/serv_ctrl.v" \
    "$src_base_dir/cores/serv/rtl/serv_csr.v" \
    "$src_base_dir/cores/serv/rtl/serv_bufreg.v" \
    "$src_base_dir/cores/serv/rtl/serv_bufreg2.v" \
    "$src_base_dir/cores/serv/rtl/serv_aligner.v" \
    "$src_base_dir/cores/serv/rtl/serv_mem_if.v" \
    "$src_base_dir/cores/serv/rtl/serv_rf_if.v" \
    "$src_base_dir/cores/serv/rtl/serv_rf_ram_if.v" \
    "$src_base_dir/cores/serv/rtl/serv_rf_ram.v" \
    "$src_base_dir/cores/serv/rtl/serv_rf_top.v" \
    "$src_base_dir/cores/serv/rtl/serv_top.v" \
]

foreach file $serv_files {
    if {[file exists $file]} {
        vlog -work work $file
        puts "   Compiled: [file tail $file]"
    } else {
        puts "   Missing: $file"
    }
}

# Compile AXI Interconnect files (can compile theo thu tu dependency)
puts "\n2. Compiling AXI Interconnect files..."
# Utility modules truoc
set util_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/utils/*.v"]
foreach file $util_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Handshake modules
set handshake_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/handshake/*.v"]
foreach file $handshake_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Mux/Demux modules
set mux_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/datapath/mux/*.v"]
foreach file $mux_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

set demux_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/datapath/demux/*.v"]
foreach file $demux_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Buffer/Queue modules
set buffer_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/buffers/*.v"]
foreach file $buffer_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Arbitration modules
set arb_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/arbitration/*.v"]
foreach file $arb_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Decoder modules
set dec_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/decoders/*.v"]
foreach file $dec_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Channel Controller modules
set ctrl_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/channel_controllers/write/*.v"]
foreach file $ctrl_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

set ctrl_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/channel_controllers/read/*.v"]
foreach file $ctrl_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Core modules (cuoi cung)
set core_files [glob -nocomplain "$src_base_dir/axi_interconnect/rtl/core/*.v"]
foreach file $core_files {
    vlog -work work $file
    puts "   Compiled: [file tail $file]"
}

# Compile Wrapper modules
puts "\n3. Compiling Wrapper modules..."
set wrapper_files [list \
    "$src_base_dir/wrapper/wb2axi_read.v" \
    "$src_base_dir/wrapper/wb2axi_write.v" \
    "$src_base_dir/wrapper/serv_axi_wrapper.v" \
    "$src_base_dir/wrapper/serv_axi_system.v" \
]

foreach file $wrapper_files {
    if {[file exists $file]} {
        vlog -work work $file
        puts "   Compiled: [file tail $file]"
    } else {
        puts "   Missing: $file"
    }
}

# Compile Memory Slave models
puts "\n4. Compiling Memory Slave models..."
set mem_files [list \
    "$src_base_dir/wrapper/axi_rom_slave.v" \
    "$src_base_dir/wrapper/axi_memory_slave.v" \
]

foreach file $mem_files {
    if {[file exists $file]} {
        vlog -work work $file
        puts "   Compiled: [file tail $file]"
    } else {
        puts "   Missing: $file (optional)"
    }
}

# Compile Testbench
puts "\n5. Compiling Testbench..."
set tb_file "$tb_dir/wrapper_tb/serv_axi_system_tb.v"
if {[file exists $tb_file]} {
    vlog -work work $tb_file
    puts "   Compiled: [file tail $tb_file]"
} else {
    puts "   Missing: $tb_file (optional)"
}

puts "\n============================================================================"
puts "Compilation Complete!"
puts "============================================================================"
puts "\nDe chay simulation, su dung:"
puts "  vsim -t ps work.serv_axi_system_tb"
puts "  add wave -radix hex /serv_axi_system_tb/*"
puts "  run -all"
puts "============================================================================\n"

