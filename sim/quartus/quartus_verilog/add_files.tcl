# ============================================================================
# TCL Script tự động thêm file vào Quartus Project
# Script này tự động quét và chỉ thêm những file chưa có trong project
# Có thể chạy nhiều lần mà không bị duplicate - DÙNG FILE NÀY HÀNG NGÀY
# 
# Cách dùng: Trong Quartus Tcl Console, chạy: source add_files.tcl
# ============================================================================

# ============================================================================
# Cấu hình
# ============================================================================
set project_name "AXI_PROJECT"

# Lấy thư mục project hiện tại
set project_dir [file normalize [file dirname [info script]]]
# Từ sim/quartus, lên 2 cấp để đến AXI root
set root_dir [file normalize [file join $project_dir .. ..]]

puts "\n============================================================================"
puts "Auto-Adding New Source Files to Quartus Project"
puts "============================================================================"
puts "Project: $project_name"
puts "Root Directory: $root_dir"
puts "============================================================================\n"

# Mở project
if {[catch {project_open $project_name}]} {
    puts "ERROR: Không thể mở project $project_name"
    return
}

# ============================================================================
# Hàm lấy danh sách file đã có trong project từ QSF file
# ============================================================================
proc get_existing_files {qsf_path} {
    set existing_files {}
    if {![file exists $qsf_path]} {
        return $existing_files
    }
    
    set fp [open $qsf_path r]
    while {[gets $fp line] >= 0} {
        # Tìm dòng VERILOG_FILE
        if {[string match "*VERILOG_FILE*" $line]} {
            # Extract file path - có thể có quotes hoặc không
            set file_path ""
            if {[regexp {VERILOG_FILE\s+"([^"]+)"} $line match file_path]} {
                # Path có quotes
            } elseif {[regexp {VERILOG_FILE\s+([^\s]+)} $line match file_path]} {
                # Path không có quotes
            }
            
            if {$file_path != ""} {
                # Xử lý relative path
                if {[string match "../../*" $file_path] || [string match "../*" $file_path]} {
                    set qsf_dir [file dirname $qsf_path]
                    set full_path [file normalize [file join $qsf_dir $file_path]]
                } else {
                    set full_path [file normalize $file_path]
                }
                lappend existing_files $full_path
            }
        }
    }
    close $fp
    return $existing_files
}

# Lấy danh sách file hiện có từ QSF
set qsf_path [file join $project_dir "${project_name}.qsf"]
puts "Đang kiểm tra files đã có trong project..."
puts "   QSF file: $qsf_path"
set existing_files [get_existing_files $qsf_path]
set existing_count [llength $existing_files]
puts "   Đã có $existing_count files trong project\n"

# ============================================================================
# Hàm quét đệ quy tất cả file .v và thêm file mới
# ============================================================================
proc scan_and_add_new_files {base_dir {exclude_patterns {}} {exclude_dirs {}}} {
    global existing_files
    set new_files {}
    set skipped_files {}
    
    # Quét tất cả file .v trong thư mục và subdirectories
    if {![file exists $base_dir]} {
        return [list 0 {} {}]
    }
    
    # Sử dụng glob để tìm tất cả file .v
    set all_files [glob -nocomplain -directory $base_dir -types f *.v]
    
    # Quét subdirectories
    set subdirs [glob -nocomplain -directory $base_dir -types d *]
    foreach subdir $subdirs {
        set subdir_name [file tail $subdir]
        
        # Kiểm tra exclude directories
        set skip_dir 0
        foreach exclude_dir $exclude_dirs {
            if {[string match $exclude_dir $subdir_name] || [string match "*$exclude_dir*" $subdir]} {
                set skip_dir 1
                break
            }
        }
        if {$skip_dir} {
            continue
        }
        
        # Quét đệ quy
        set result [scan_and_add_new_files $subdir $exclude_patterns $exclude_dirs]
        set count [lindex $result 0]
        set new_list [lindex $result 1]
        set skipped_list [lindex $result 2]
        
        foreach file $new_list {
            lappend new_files $file
        }
        foreach file $skipped_list {
            lappend skipped_files $file
        }
    }
    
    # Xử lý files trong thư mục hiện tại
    foreach file $all_files {
        set normalized_path [file normalize $file]
        set file_name [file tail $file]
        
        # Bỏ qua file backup
        if {[string match "*.bak" $file_name]} {
            continue
        }
        
        # Bỏ qua testbench files
        if {[string match "*_tb.v" $file_name] || [string match "*_test.v" $file_name]} {
            continue
        }
        
        # Kiểm tra exclude patterns
        set skip 0
        foreach pattern $exclude_patterns {
            if {[string match $pattern $file_name]} {
                set skip 1
                break
            }
        }
        if {$skip} {
            continue
        }
        
        # Kiểm tra xem file đã có trong project chưa
        set already_exists 0
        foreach existing $existing_files {
            if {[string equal -nocase $normalized_path $existing]} {
                set already_exists 1
                break
            }
        }
        
        if {!$already_exists} {
            # Thêm file mới vào project
            set_global_assignment -name VERILOG_FILE $normalized_path
            lappend new_files $normalized_path
            puts "   ✓ Added: [file tail $file]"
        } else {
            lappend skipped_files $normalized_path
        }
    }
    
    set new_count [llength $new_files]
    return [list $new_count $new_files $skipped_files]
}

# ============================================================================
# Quét và thêm files từ các thư mục chính
# ============================================================================

set total_new_files 0
set exclude_patterns {"*_tb.v" "*_test.v" "*.bak"}
set exclude_dirs {"bench" "test" "tb" "simulation" "work" "build" "output_files" "db" "incremental_db"}

puts "============================================================================"
puts "Scanning for new files..."
puts "============================================================================\n"

# 1. SERV Core files
puts "1. Scanning SERV Core files..."
set serv_dir [file join $root_dir "src" "cores" "serv" "rtl"]
if {[file exists $serv_dir]} {
    set result [scan_and_add_new_files $serv_dir $exclude_patterns $exclude_dirs]
    set count [lindex $result 0]
    set total_new_files [expr $total_new_files + $count]
    puts "   → Found $count new SERV core files"
} else {
    puts "   ⚠ SERV directory not found"
}

# 2. AXI Interconnect files
puts "\n2. Scanning AXI Interconnect files..."
set interconnect_dir [file join $root_dir "src" "axi_interconnect" "rtl"]
if {[file exists $interconnect_dir]} {
    set result [scan_and_add_new_files $interconnect_dir $exclude_patterns $exclude_dirs]
    set count [lindex $result 0]
    set total_new_files [expr $total_new_files + $count]
    puts "   → Found $count new AXI Interconnect files"
} else {
    puts "   ⚠ AXI Interconnect directory not found"
}

# 3. Wrapper files (bao gom IP modules)
puts "\n3. Scanning Wrapper files..."
set wrapper_dir [file join $root_dir "src" "wrapper"]
if {[file exists $wrapper_dir]} {
    set result [scan_and_add_new_files $wrapper_dir $exclude_patterns $exclude_dirs]
    set count [lindex $result 0]
    set total_new_files [expr $total_new_files + $count]
    puts "   → Found $count new wrapper files (including IP modules)"
} else {
    puts "   ⚠ Wrapper directory not found"
}

# 4. Master ALU files
puts "\n4. Scanning Master ALU files..."
set alu_dir [file join $root_dir "Master_ALU" "ALU"]
if {[file exists $alu_dir]} {
    set result [scan_and_add_new_files $alu_dir $exclude_patterns $exclude_dirs]
    set count [lindex $result 0]
    set total_new_files [expr $total_new_files + $count]
    puts "   → Found $count new ALU master files"
} else {
    puts "   ⚠ Master ALU directory not found"
}

# 5. Slave Memory files
puts "\n5. Scanning Slave Memory files..."
set slave_dir [file join $root_dir "Slave_Memory"]
if {[file exists $slave_dir]} {
    set result [scan_and_add_new_files $slave_dir $exclude_patterns $exclude_dirs]
    set count [lindex $result 0]
    set total_new_files [expr $total_new_files + $count]
    puts "   → Found $count new slave memory files"
} else {
    puts "   ⚠ Slave Memory directory not found"
}

# ============================================================================
# Set Include Directories (nếu chưa có)
# ============================================================================
puts "\n6. Checking Include Directories..."
set serv_includes [file join $root_dir "src" "cores" "serv" "rtl"]
set interconnect_includes [file join $root_dir "src" "axi_interconnect" "rtl" "includes"]

# Kiểm tra SEARCH_PATH từ QSF file
set serv_path_exists 0
set interconnect_path_exists 0

if {[file exists $qsf_path]} {
    set fp [open $qsf_path r]
    while {[gets $fp line] >= 0} {
        if {[string match "*SEARCH_PATH*" $line]} {
            if {[string match "*$serv_includes*" $line]} {
                set serv_path_exists 1
            }
            if {[string match "*$interconnect_includes*" $line]} {
                set interconnect_path_exists 1
            }
        }
    }
    close $fp
}

if {[file exists $serv_includes] && !$serv_path_exists} {
    set_global_assignment -name SEARCH_PATH $serv_includes
    puts "   ✓ Added SERV includes"
} else {
    puts "   ℹ SERV includes already set"
}

if {[file exists $interconnect_includes] && !$interconnect_path_exists} {
    set_global_assignment -name SEARCH_PATH $interconnect_includes
    puts "   ✓ Added AXI Interconnect includes"
} else {
    puts "   ℹ AXI Interconnect includes already set"
}

# ============================================================================
# Tóm tắt
# ============================================================================
puts "\n============================================================================"
puts "Summary"
puts "============================================================================"
puts "Files already in project: $existing_count"
puts "New files added: $total_new_files"
puts "Total files in project now: [expr $existing_count + $total_new_files]"
puts ""
if {$total_new_files > 0} {
    puts "✓ $total_new_files new file(s) đã được thêm vào project!"
} else {
    puts "ℹ Không có file mới nào. Tất cả files đã có trong project."
}
puts ""
puts "============================================================================"
puts "✓ Script hoàn thành!"
puts "============================================================================"
puts ""
puts "Lưu ý:"
puts "- Script này có thể chạy nhiều lần mà không bị duplicate"
puts "- Chỉ thêm những file mới chưa có trong project"
puts "- Tự động bỏ qua testbench và backup files"
puts "============================================================================"

# Lưu project
project_close

puts "\n✓ Project saved successfully!"

