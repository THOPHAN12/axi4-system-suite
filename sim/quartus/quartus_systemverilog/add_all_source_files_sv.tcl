# ============================================================================
# TCL Script de them TAT CA Source Files vao Quartus Project (SystemVerilog)
# Cach dung: Trong Quartus Tcl Console, chay: source add_all_source_files_sv.tcl
# 
# Script nay tu dong them tat ca SystemVerilog source files vao Quartus project:
# - AXI Interconnect files (SystemVerilog .sv)
# - SERV RISC-V Core files (Verilog .v - unchanged)
# - AXI Wrapper files (Verilog .v - unchanged)
# - Memory slave models (Verilog .v - unchanged)
# ============================================================================

# ============================================================================
# Cau hinh
# ============================================================================
set project_name "AXI_PROJECT_SV"

# Lay thu muc project hien tai
set project_dir [file normalize [file dirname [info script]]]
# Tu sim/quartus/quartus_systemverilog, len 3 cap de den AXI root
set root_dir [file normalize [file join $project_dir .. .. ..]]
set src_base_dir [file join $root_dir "src"]

# Lua chon khac: Dung absolute path (tin cay hon)
# Bo comment dong duoi va comment dong tren neu relative path khong hoat dong
# set root_dir [file normalize "D:/AXI"]
# set src_base_dir [file join $root_dir "src"]

# Debug: In ra duong dan de kiem tra
puts "\n============================================================================"
puts "Path Debug Information"
puts "============================================================================"
puts "Script location: [info script]"
puts "Project directory: $project_dir"
puts "Source base directory: $src_base_dir"
puts "============================================================================\n"

# Kiem tra thu muc source co ton tai khong
if {![file exists $src_base_dir]} {
    puts "ERROR: Thu muc source khong ton tai: $src_base_dir"
    puts "Vui long kiem tra tinh toan duong dan."
    puts "Thu dung absolute path: set src_base_dir [file normalize \"D:/AXI/src\"]"
    return
}

# Kiem tra va tao project neu chua ton tai
set project_file [file join $project_dir "${project_name}.qpf"]
set project_file_alt [file join $project_dir "AXI_PROJECT.qpf"]

# Kiem tra xem co file project nao ton tai khong
if {[file exists $project_file]} {
    puts "Mo project: $project_name"
    catch {project_close}
    project_open $project_name
} elseif {[file exists $project_file_alt]} {
    puts "Tim thay project: AXI_PROJECT, dang mo..."
    catch {project_close}
    project_open "AXI_PROJECT"
    set project_name "AXI_PROJECT"
} else {
    puts "Project chua ton tai, dang tao project moi..."
    # Dong project hien tai neu co
    catch {project_close}
    # Tao project moi
    project_new $project_name -overwrite
    puts "Project da duoc tao: $project_file"
    # Thiet lap device co ban
    set_global_assignment -name FAMILY "Cyclone II"
    set_global_assignment -name DEVICE EP2C70F672C6
    set_global_assignment -name TOP_LEVEL_ENTITY AXI_Interconnect_Full
    set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
    puts "Da thiet lap device: EP2C70F672C6"
}

puts "\n============================================================================"
puts "Adding All Source Files to Quartus Project (SystemVerilog)"
puts "============================================================================"
puts "Project: $project_name"
puts "Source Base Directory: $src_base_dir"
puts "============================================================================\n"

# ============================================================================
# Cac ham tien ich
# ============================================================================

# Ham de them mot file Verilog vao project
proc add_verilog_file {file_path {library ""}} {
    set full_path [file normalize $file_path]
    if {[file exists $full_path]} {
        if {$library != ""} {
            set_global_assignment -name VERILOG_FILE $full_path -library $library
            puts "   Added: [file tail $file_path] (Library: $library)"
        } else {
            set_global_assignment -name VERILOG_FILE $full_path
            puts "   Added: [file tail $file_path]"
        }
        return 1
    } else {
        puts "    Missing: $file_path"
        return 0
    }
}

# Ham de them mot file SystemVerilog vao project
proc add_systemverilog_file {file_path {library ""}} {
    set full_path [file normalize $file_path]
    if {[file exists $full_path]} {
        if {$library != ""} {
            set_global_assignment -name SYSTEMVERILOG_FILE $full_path -library $library
            puts "   Added: [file tail $file_path] (Library: $library) \[SV\]"
        } else {
            set_global_assignment -name SYSTEMVERILOG_FILE $full_path
            puts "   Added: [file tail $file_path] \[SV\]"
        }
        return 1
    } else {
        puts "    Missing: $file_path"
        return 0
    }
}

# Ham de them tat ca file .sv tu mot thu muc
proc add_directory_sv_files {dir pattern {subdir ""} {library ""}} {
    if {$subdir != ""} {
        set base_dir [file normalize [file join $::src_base_dir $dir $subdir]]
    } else {
        set base_dir [file normalize [file join $::src_base_dir $dir]]
    }
    
    if {![file exists $base_dir]} {
        puts "  ⚠ Directory not found: $base_dir"
        return 0
    }
    
    set files [glob -nocomplain -directory $base_dir $pattern]
    set count 0
    foreach file $files {
        # Bo qua file backup
        if {[string match "*.bak" $file]} {
            continue
        }
        if {[add_systemverilog_file $file $library]} {
            incr count
        }
    }
    return $count
}

# Ham de them tat ca file .v tu mot thu muc (cho Verilog files)
proc add_directory_verilog_files {dir pattern {subdir ""} {library ""}} {
    if {$subdir != ""} {
        set base_dir [file normalize [file join $::src_base_dir $dir $subdir]]
    } else {
        set base_dir [file normalize [file join $::src_base_dir $dir]]
    }
    
    if {![file exists $base_dir]} {
        puts "  ⚠ Directory not found: $base_dir"
        return 0
    }
    
    set files [glob -nocomplain -directory $base_dir $pattern]
    set count 0
    foreach file $files {
        if {[string match "*.bak" $file]} {
            continue
        }
        if {[add_verilog_file $file $library]} {
            incr count
        }
    }
    return $count
}

# ============================================================================
# Them Source Files theo danh muc (theo thu tu compile)
# ============================================================================

set total_files 0

# ============================================================================
# 1. SERV RISC-V Core Files (Verilog)
# ============================================================================
puts "1. Adding SERV RISC-V Core Files (Verilog)..."
set serv_rtl_dir [file join $src_base_dir "cores" "serv" "rtl"]

set serv_core_files {
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
    "serv_debug.v"
    "serv_synth_wrapper.v"
}

set serv_count 0
foreach file $serv_core_files {
    set file_path [file join $serv_rtl_dir $file]
    if {[add_verilog_file $file_path]} {
        incr serv_count
    }
}
set total_files [expr $total_files + $serv_count]
puts "   Added $serv_count SERV core files\n"

# ============================================================================
# 2. AXI Interconnect - SystemVerilog Files (.sv)
# ============================================================================
puts "2. Adding AXI Interconnect SystemVerilog Files..."

# 2.1 Packages and Interfaces (must be compiled first)
puts "   2.1 Packages and Interfaces..."
set count_pkg [add_directory_sv_files "axi_interconnect/sv/packages" "*.sv"]
set count_if [add_directory_sv_files "axi_interconnect/sv/interfaces" "*.sv"]
set interconnect_count [expr $count_pkg + $count_if]
puts "      Added $count_pkg package files and $count_if interface files"

# 2.2 Utilities
puts "   2.2 Utilities..."
set count [add_directory_sv_files "axi_interconnect/sv/utils" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count utility files"

# 2.3 Handshake
puts "   2.3 Handshake..."
set count [add_directory_sv_files "axi_interconnect/sv/handshake" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count handshake files"

# 2.4 Datapath (MUX/DEMUX)
puts "   2.4 Datapath (MUX/DEMUX)..."
set count_mux [add_directory_sv_files "axi_interconnect/sv/datapath/mux" "*.sv"]
set count_demux [add_directory_sv_files "axi_interconnect/sv/datapath/demux" "*.sv"]
set count [expr $count_mux + $count_demux]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count datapath files ($count_mux mux, $count_demux demux)"

# 2.5 Buffers
puts "   2.5 Buffers..."
set count [add_directory_sv_files "axi_interconnect/sv/buffers" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count buffer files"

# 2.6 Arbitration
puts "   2.6 Arbitration..."
set count [add_directory_sv_files "axi_interconnect/sv/arbitration" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count arbitration files"

# 2.7 Decoders
puts "   2.7 Decoders..."
set count [add_directory_sv_files "axi_interconnect/sv/decoders" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count decoder files"

# 2.8 Write Channel Controllers
puts "   2.8 Write Channel Controllers..."
set count [add_directory_sv_files "axi_interconnect/sv/channel_controllers/write" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count write controller files"

# 2.9 Read Channel Controllers
puts "   2.9 Read Channel Controllers..."
set count [add_directory_sv_files "axi_interconnect/sv/channel_controllers/read" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count read controller files"

# 2.10 Core Modules (Top-level)
puts "   2.10 Core Modules..."
set count [add_directory_sv_files "axi_interconnect/sv/core" "*.sv"]
set interconnect_count [expr $interconnect_count + $count]
puts "      Added $count core files\n"

set total_files [expr $total_files + $interconnect_count]

# ============================================================================
# 3. Wrapper SystemVerilog (nếu có)
# ============================================================================
puts "3. Adding SystemVerilog Wrapper Files..."
puts "   Note: Only adding .sv files, NOT .v wrapper files to avoid conflicts"

# Xóa file .v của wrapper nếu đã có trong project (tránh conflict)
set wrapper_v_file "D:/AXI/src/wrapper/systems/axi_interconnect_2m4s_wrapper.v"
catch {
    set_global_assignment -name VERILOG_FILE $wrapper_v_file -remove
    puts "   Removed old Verilog wrapper: axi_interconnect_2m4s_wrapper.v"
}

set wrapper_sv_dir [file join $src_base_dir "wrapper" "sv" "systems"]
set wrapper_sv_files {
    "axi_interconnect_2m4s_wrapper.sv"
}

set wrapper_sv_count 0
foreach file $wrapper_sv_files {
    set file_path [file join $wrapper_sv_dir $file]
    if {[file exists $file_path]} {
        if {[add_systemverilog_file $file_path]} {
            incr wrapper_sv_count
        }
    }
}
if {$wrapper_sv_count > 0} {
    set total_files [expr $total_files + $wrapper_sv_count]
    puts "   Added $wrapper_sv_count SystemVerilog wrapper files\n"
} else {
    puts "   ⚠ SystemVerilog wrapper files not found\n"
}

# ============================================================================
# 4. Wishbone to AXI Converters (Verilog)
# ============================================================================
puts "4. Adding Wishbone to AXI Converter Modules (Verilog)..."
set wrapper_dir [file join $src_base_dir "wrapper"]

set wb2axi_files {
    "converters/wb2axi_read.v"
    "converters/wb2axi_write.v"
}

set wb2axi_count 0
foreach file $wb2axi_files {
    set file_path [file join $wrapper_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr wb2axi_count
        }
    }
}
set total_files [expr $total_files + $wb2axi_count]
puts "   Added $wb2axi_count converter files\n"

# ============================================================================
# 5. SERV AXI Wrapper (Verilog)
# ============================================================================
puts "5. Adding SERV AXI Wrapper (Verilog)..."
set wrapper_file [file join $wrapper_dir "converters" "serv_axi_wrapper.v"]
if {[file exists $wrapper_file]} {
    if {[add_verilog_file $wrapper_file]} {
        set total_files [expr $total_files + 1]
        puts "    Added serv_axi_wrapper.v\n"
    } else {
        puts "    Failed to add serv_axi_wrapper.v\n"
    }
} else {
    puts "    ⚠ serv_axi_wrapper.v not found\n"
}

# ============================================================================
# 6. Top-Level System Integration (Verilog)
# ============================================================================
puts "6. Adding System Integration Modules (Verilog)..."
set system_files {
    "systems/serv_axi_system.v"
}

set ip_files {
    "ip/serv_axi_system_ip.v"
}

set system_count 0
foreach file $system_files {
    set file_path [file join $wrapper_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr system_count
        }
    }
}

set ip_count 0
foreach file $ip_files {
    set file_path [file join $wrapper_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr ip_count
        }
    }
}

set total_system_count [expr $system_count + $ip_count]
if {$total_system_count > 0} {
    set total_files [expr $total_files + $total_system_count]
    puts "   Added $system_count system files and $ip_count IP files\n"
} else {
    puts "   ⚠ System integration files not found\n"
}

# ============================================================================
# 7. Memory Slaves (Verilog)
# ============================================================================
puts "7. Adding Memory Slave Models (Verilog)..."
set memory_files {
    "memory/axi_rom_slave.v"
    "memory/axi_memory_slave.v"
    "memory/Simple_Memory_Slave.v"
}

set memory_count 0
foreach file $memory_files {
    set file_path [file join $wrapper_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr memory_count
        }
    }
}
if {$memory_count > 0} {
    set total_files [expr $total_files + $memory_count]
    puts "   Added $memory_count memory slave files\n"
} else {
    puts "   ⚠ Memory slave files not found\n"
}

# ============================================================================
# 8. Wrapper Systems (Verilog)
# ============================================================================
puts "8. Adding Wrapper Systems (Verilog)..."
set wrapper_systems {
    "systems/axi_interconnect_wrapper.v"
}

set wrapper_count 0
foreach file $wrapper_systems {
    set file_path [file join $wrapper_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr wrapper_count
        }
    }
}
if {$wrapper_count > 0} {
    set total_files [expr $total_files + $wrapper_count]
    puts "   Added $wrapper_count wrapper system files\n"
} else {
    puts "   ⚠ Wrapper system files not found\n"
}

# ============================================================================
# Set Top-Level Entity
# ============================================================================

puts "9. Setting Top-Level Entity..."
# Giu nguyen top-level hien tai (KHUYEN NGHI - Khong override)
puts "   ℹ Keeping existing top-level entity (not overriding)\n"
puts "   ℹ Current top-level is set in AXI_PROJECT_SV.qsf\n"
puts "   ℹ Uncomment one of the options below if you want to change it\n"

# Lua chon 1: Dung AXI_Interconnect_Full (SystemVerilog)
# set_global_assignment -name TOP_LEVEL_ENTITY "AXI_Interconnect_Full"
# puts "    Top-Level: AXI_Interconnect_Full (SystemVerilog)\n"

# ============================================================================
# Set Include Directories
# ============================================================================

puts "10. Setting Include Directories..."
set interconnect_sv_includes [file join $src_base_dir "axi_interconnect" "sv" "packages"]
set interconnect_sv_if_includes [file join $src_base_dir "axi_interconnect" "sv" "interfaces"]

if {[file exists $interconnect_sv_includes]} {
    set_global_assignment -name SEARCH_PATH $interconnect_sv_includes
    puts "    Added AXI Interconnect SV packages: $interconnect_sv_includes"
}

if {[file exists $interconnect_sv_if_includes]} {
    set_global_assignment -name SEARCH_PATH $interconnect_sv_if_includes
    puts "    Added AXI Interconnect SV interfaces: $interconnect_sv_if_includes"
}

set serv_includes [file join $src_base_dir "cores" "serv" "rtl"]
set interconnect_includes [file join $src_base_dir "axi_interconnect" "rtl" "includes"]

if {[file exists $serv_includes]} {
    set_global_assignment -name SEARCH_PATH $serv_includes
    puts "    Added SERV includes: $serv_includes"
}

if {[file exists $interconnect_includes]} {
    set_global_assignment -name SEARCH_PATH $interconnect_includes
    puts "    Added AXI Interconnect includes: $interconnect_includes"
}

puts ""

# ============================================================================
# Tom tat
# ============================================================================

puts "============================================================================"
puts "Summary"
puts "============================================================================"
puts "Total files added: $total_files"
puts "  - SERV Core files (Verilog): $serv_count"
puts "  - AXI Interconnect files (SystemVerilog): $interconnect_count"
if {$wrapper_sv_count > 0} {
    puts "  - Wrapper files (SystemVerilog): $wrapper_sv_count"
}
puts "  - WB2AXI Converters (Verilog): $wb2axi_count"
puts "  - System Integration files (Verilog): $total_system_count"
puts "  - Memory Slave files (Verilog): $memory_count"
if {$wrapper_count > 0} {
    puts "  - Wrapper Systems (Verilog): $wrapper_count"
}
puts ""
puts "Top-Level Entity: AXI_Interconnect_Full (SystemVerilog)"
puts ""
puts "============================================================================"
puts " Files da duoc them vao Project Navigator!"
puts "============================================================================"
puts ""
puts "Kiem tra Project Navigator (khung ben trai) de xem files!"
puts ""
puts "Next steps:"
puts "1. Verify all files in Project Navigator (ben trai)"
puts "2. Run Analysis & Synthesis"
puts "3. Check for compilation errors"
puts "4. Set pin assignments and constraints"
puts "============================================================================"

# Luu project
project_close

puts "\n Project saved successfully!"
puts ""
puts "Project Navigator se tu dong refresh khi files duoc them."

