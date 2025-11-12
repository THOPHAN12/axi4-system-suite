# ============================================================================
# TCL Script de them TAT CA Source Files vao Quartus Project
# Cach dung: Trong Quartus Tcl Console, chay: source add_all_source_files.tcl
# 
# Script nay tu dong them tat ca Verilog source files vao Quartus project:
# - SERV RISC-V Core files
# - AXI Wrapper files (Wishbone to AXI converters)
# - AXI Interconnect files (neu chua co)
# - Memory slave models (tuy chon)
# ============================================================================

# ============================================================================
# Cau hinh
# ============================================================================
set project_name "AXI_PROJECT"

# Lay thu muc project hien tai
set project_dir [file normalize [file dirname [info script]]]
# Tu sim/quartus, len 2 cap de den AXI root
# Duong dan: sim/quartus -> .. -> sim -> .. -> AXI
set root_dir [file normalize [file join $project_dir .. ..]]
set src_base_dir [file join $root_dir "src"]

# Lua chon khac: Dung absolute path (tin cay hon, giong add_to_navigator.tcl)
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

# Mo project
project_open $project_name

puts "\n============================================================================"
puts "Adding All Source Files to Quartus Project"
puts "============================================================================"
puts "Project: $project_name"
puts "Source Base Directory: $src_base_dir"
puts "============================================================================\n"

# ============================================================================
# Cac ham tien ich
# ============================================================================

# Ham de them mot file Verilog vao project
# Dam bao files xuat hien trong Project Navigator (giong add_to_navigator.tcl)
proc add_verilog_file {file_path {library ""}} {
    set full_path [file normalize $file_path]
    if {[file exists $full_path]} {
        # Them file bang set_global_assignment (xuat hien trong Project Navigator)
        if {$library != ""} {
            set_global_assignment -name VERILOG_FILE $full_path -library $library
            puts "   Added: [file tail $file_path] (Library: $library)"
        } else {
            # Dung absolute path de dam bao Project Navigator hien thi dung
            set_global_assignment -name VERILOG_FILE $full_path
            puts "   Added: [file tail $file_path]"
        }
        return 1
    } else {
        puts "    Missing: $file_path"
        return 0
    }
}

# Ham de them tat ca file .v tu mot thu muc (loai tru file .bak)
proc add_directory_files {dir pattern {subdir ""} {library ""}} {
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
# 1. SERV RISC-V Core Files (compile truoc - co dependencies)
# ============================================================================
puts "1. Adding SERV RISC-V Core Files..."
set serv_rtl_dir [file join $src_base_dir "cores" "serv" "rtl"]

# Core modules (compile theo thu tu dependency)
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
# 2. Wishbone to AXI Converters
# ============================================================================
puts "2. Adding Wishbone to AXI Converter Modules..."
set wrapper_dir [file join $src_base_dir "wrapper"]

set wb2axi_files {
    "converters/wb2axi_read.v"
    "converters/wb2axi_write.v"
}

set wb2axi_count 0
foreach file $wb2axi_files {
    set file_path [file join $wrapper_dir $file]
    if {[add_verilog_file $file_path]} {
        incr wb2axi_count
    }
}
set total_files [expr $total_files + $wb2axi_count]
puts "   Added $wb2axi_count converter files\n"

# ============================================================================
# 3. SERV AXI Wrapper
# ============================================================================
puts "3. Adding SERV AXI Wrapper..."
set wrapper_file [file join $wrapper_dir "converters" "serv_axi_wrapper.v"]
if {[add_verilog_file $wrapper_file]} {
    set total_files [expr $total_files + 1]
    puts "    Added serv_axi_wrapper.v\n"
} else {
    puts "    Failed to add serv_axi_wrapper.v\n"
}

# ============================================================================
# 4. AXI Interconnect Core Files
# ============================================================================
puts "4. Adding AXI Interconnect Core Files..."
set interconnect_dir [file join $src_base_dir "axi_interconnect" "rtl"]

# Them AXI Interconnect files theo thu tu compile
set interconnect_count 0

# 4.1 Utilities
set count [add_directory_files "axi_interconnect/rtl/utils" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count utility files"

# 4.2 Handshake
set count [add_directory_files "axi_interconnect/rtl/handshake" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count handshake files"

# 4.3 Datapath (MUX/DEMUX)
set count_mux [add_directory_files "axi_interconnect/rtl/datapath/mux" "*.v"]
set count_demux [add_directory_files "axi_interconnect/rtl/datapath/demux" "*.v"]
set count [expr $count_mux + $count_demux]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count datapath files ($count_mux mux, $count_demux demux)"

# 4.4 Buffers
set count [add_directory_files "axi_interconnect/rtl/buffers" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count buffer files"

# 4.5 Arbitration
set count [add_directory_files "axi_interconnect/rtl/arbitration" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count arbitration files"

# 4.6 Decoders
set count [add_directory_files "axi_interconnect/rtl/decoders" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count decoder files"

# 4.7 Write Channel Controllers
set count [add_directory_files "axi_interconnect/rtl/channel_controllers/write" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count write controller files"

# 4.8 Read Channel Controllers
set count [add_directory_files "axi_interconnect/rtl/channel_controllers/read" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count read controller files"

# 4.9 Core Modules (Top-level)
set count [add_directory_files "axi_interconnect/rtl/core" "*.v"]
set interconnect_count [expr $interconnect_count + $count]
puts "   Added $count core files\n"

set total_files [expr $total_files + $interconnect_count]

# ============================================================================
# 5. Top-Level System Integration
# ============================================================================
puts "5. Adding System Integration Modules..."
set system_files {
    "systems/serv_axi_system.v"
    "systems/dual_master_system.v"
    "systems/alu_master_system.v"
}

set ip_files {
    "ip/serv_axi_system_ip.v"
    "ip/dual_master_system_ip.v"
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
# 6. Memory Slaves (Tuy chon - cho testbench/simulation)
# ============================================================================
puts "6. Adding Memory Slave Models (Optional - for simulation)..."
set memory_files {
    "memory/axi_rom_slave.v"
    "memory/axi_memory_slave.v"
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
    puts "   Added $memory_count memory slave files (for simulation)\n"
} else {
    puts "   ⚠ Memory slave files not found (optional for simulation)\n"
}

# ============================================================================
# 7. Master ALU Files
# ============================================================================
puts "7. Adding Master ALU Files..."
set alu_dir [file join $root_dir "Master_ALU" "ALU"]

set alu_files {
    "ALU_Core.v"
    "CPU_ALU_Master.v"
    "CPU_Controller.v"
    "Simple_AXI_Master_Test.v"
}

set alu_count 0
foreach file $alu_files {
    set file_path [file join $alu_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr alu_count
        }
    }
}
if {$alu_count > 0} {
    set total_files [expr $total_files + $alu_count]
    puts "   Added $alu_count ALU master files\n"
} else {
    puts "   ⚠ Master ALU files not found\n"
}

# ============================================================================
# 8. Slave Memory Files
# ============================================================================
puts "8. Adding Slave Memory Files..."
set slave_dir [file join $root_dir "Slave_Memory"]

set slave_files {
    "Simple_Memory_Slave.v"
}

set slave_count 0
foreach file $slave_files {
    set file_path [file join $slave_dir $file]
    if {[file exists $file_path]} {
        if {[add_verilog_file $file_path]} {
            incr slave_count
        }
    }
}
if {$slave_count > 0} {
    set total_files [expr $total_files + $slave_count]
    puts "   Added $slave_count slave memory files\n"
} else {
    puts "   ⚠ Slave Memory files not found\n"
}

# ============================================================================
# Set Top-Level Entity
# ============================================================================

puts "9. Setting Top-Level Entity..."
# Bo comment mot trong cac dong sau dua tren top-level module cua ban:

# Lua chon 1: Dung serv_axi_wrapper (standalone wrapper)
# set_global_assignment -name TOP_LEVEL_ENTITY "serv_axi_wrapper"
# puts "    Top-Level: serv_axi_wrapper\n"

# Lua chon 2: Dung serv_axi_system (full system voi interconnect)
# set_global_assignment -name TOP_LEVEL_ENTITY "serv_axi_system"
# puts "    Top-Level: serv_axi_system\n"

# Lua chon 3: Dung serv_axi_system_ip (complete IP module)
# set_global_assignment -name TOP_LEVEL_ENTITY "serv_axi_system_ip"
# puts "    Top-Level: serv_axi_system_ip\n"

# Lua chon 4: Dung dual_master_system (SERV + ALU Master)
# set_global_assignment -name TOP_LEVEL_ENTITY "dual_master_system"
# puts "    Top-Level: dual_master_system\n"

# Lua chon 5: Dung dual_master_system_ip (complete IP module) ⭐ **KHUYEN NGHI**
set_global_assignment -name TOP_LEVEL_ENTITY "dual_master_system_ip"
puts "    Top-Level: dual_master_system_ip\n"

# Lua chon 6: Dung alu_master_system (ALU master system)
# set_global_assignment -name TOP_LEVEL_ENTITY "alu_master_system"
# puts "    Top-Level: alu_master_system\n"

# Lua chon 7: Dung AXI_Interconnect_Full (chi interconnect)
# set_global_assignment -name TOP_LEVEL_ENTITY "AXI_Interconnect_Full"
# puts "    Top-Level: AXI_Interconnect_Full\n"

# Lua chon 8: Giu nguyen top-level hien tai
# puts "   ℹ Keeping existing top-level entity\n"

# ============================================================================
# Set Include Directories (neu can)
# ============================================================================

puts "10. Setting Include Directories..."
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
puts "  - SERV Core files: $serv_count"
puts "  - WB2AXI Converters: $wb2axi_count"
puts "  - Wrapper files: [expr $system_count + $memory_count]"
puts "  - AXI Interconnect files: $interconnect_count"
if {$alu_count > 0} {
    puts "  - ALU Master files: $alu_count"
}
if {$slave_count > 0} {
    puts "  - Slave Memory files: $slave_count"
}
puts ""
puts "Top-Level Entity: dual_master_system_ip"
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

