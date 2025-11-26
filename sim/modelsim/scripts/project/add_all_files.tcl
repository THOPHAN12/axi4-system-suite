# ============================================================================
# TCL Script to Auto-Add All Verilog Files to ModelSim Project
# Usage: 
#   1. Mở ModelSim GUI
#   2. File -> New -> Project (hoặc mở project hiện có)
#   3. Trong Transcript window: source add_all_files.tcl
#
# Chức năng:
# - Tự động tìm và add TẤT CẢ file .v trong các thư mục source
# - CHỈ add file MỚI (file đã có trong project sẽ bị bỏ qua)
# - Có thể chạy nhiều lần mà không bị duplicate
# - Tự động phát hiện file mới được thêm vào thư mục
# - Hiển thị số lượng file mới được add và file đã có sẵn
# ============================================================================

# ============================================================================
# Cấu hình
# ============================================================================
# Get script directory and calculate root
# ModelSim có thể không trả về [info script] đúng, nên dùng nhiều cách

# Cách 1: Thử dùng [info script]
set script_file [info script]
if {[string equal $script_file ""] || ![file exists $script_file]} {
    # Cách 2: Nếu không có, dùng current directory và giả định đang ở sim/modelsim
    set script_dir [pwd]
    puts "Using current directory: $script_dir"
    
    # Kiểm tra xem có phải đang ở sim/modelsim không
    if {![string match "*modelsim*" $script_dir]} {
        # Nếu không, thử set trực tiếp
        set script_dir "D:/AXI/sim/modelsim"
        puts "Assuming script directory: $script_dir"
    }
} else {
    # Normalize path để xử lý cả forward và backslash
    set script_dir [file dirname [file normalize $script_file]]
    puts "Script directory from [info script]: $script_dir"
}

# Calculate project root (lên 2 cấp từ sim/modelsim)
# Từ D:/AXI/sim/modelsim -> D:/AXI
set project_root [file normalize [file join $script_dir .. ..]]

# Debug: In ra để kiểm tra
puts "Script directory: $script_dir"
puts "Calculated project root: $project_root"

# Nếu tính sai, dùng hardcode path (fallback)
if {![file exists $project_root] || ![file exists [file join $project_root "src"]]} {
    puts "Warning: Calculated path may be wrong, trying hardcoded path..."
    set project_root "D:/AXI"
    puts "Using hardcoded project root: $project_root"
}

# Verify project root exists
if {![file exists $project_root]} {
    puts "ERROR: Project root not found: $project_root"
    puts "Please set project_root manually in the script or check the path"
    return
}

# Verify src directory exists
if {![file exists [file join $project_root "src"]]} {
    puts "ERROR: Source directory not found in: $project_root"
    puts "Please check if this is the correct project root"
    return
}

set src_path [file join $project_root "src"]
set tb_path [file join $project_root "tb"]
set intercon_path [file join $src_path "axi_interconnect" "rtl"]
set serv_path [file join $src_path "cores" "serv" "rtl"]
set wrapper_path [file join $src_path "wrapper"]

# Debug: Print paths
puts "\n============================================================================"
puts "Auto-Adding Files to ModelSim Project"
puts "============================================================================"
puts "Project root: $project_root"
puts "============================================================================\n"

# ============================================================================
# Ensure Project is Open
# ============================================================================
set project_name "AXI_Project"
set project_dir [file normalize [file join $script_dir $project_name]]
set project_file [file normalize [file join $project_dir "${project_name}.mpf"]]
set project_is_open 0

# Function to verify project is actually open (with retry)
# Try multiple methods to verify project is open
proc verify_project_open {{max_retries 5} {delay_ms 200}} {
    for {set i 0} {$i < $max_retries} {incr i} {
        # Method 1: Try project file list (most reliable, works in all ModelSim versions)
        if {![catch {set files [project file]}]} {
            return 1
        }
        
        # Method 2: Try project info (may not work in all ModelSim versions)
        if {![catch {set project_info [project info]}]} {
            return 1
        }
        
        if {$i < [expr $max_retries - 1]} {
            after $delay_ms
        }
    }
    return 0
}

# Function to get project info safely (with fallback)
proc get_project_info {} {
    if {![catch {set info [project info]}]} {
        return $info
    }
    # Fallback: return project file count
    if {![catch {set files [project file]}]} {
        return "Project ([llength $files] files)"
    }
    return "Project (unknown)"
}

# Function to open project
proc open_project_force {} {
    global project_dir project_file project_name
    # Close any existing project first
    catch {project close}
    after 200
    
    if {[file exists $project_file]} {
        puts "Opening existing project: $project_file"
        if {![catch {project open $project_file}]} {
            # Give more time for project to load
            after 500
            return 1
        }
    } else {
        puts "Creating new project: $project_dir (name: $project_name)"
        if {![file exists $project_dir]} {
            file mkdir $project_dir
        }
        if {![catch {project new $project_dir $project_name}]} {
            # Give more time for project to be created
            after 500
            return 1
        }
    }
    return 0
}

# Step 1: Force open our target project (always close existing)
puts "Ensuring ModelSim project '$project_name' is open..."
if {[open_project_force]} {
    puts "Project open command issued, verifying..."
} else {
    puts "ERROR: Unable to open or create project at $project_dir"
}

# Step 2: Verify project actually opened
if {[verify_project_open 10 200]} {
    puts "Project is open: [get_project_info]"
    set project_is_open 1
} else {
    puts "ERROR: Unable to verify that project is open."
}

# Final verification - must pass before proceeding (with generous retry)
if {!$project_is_open} {
    # Last chance: try one more time with very generous timing
    puts "Final attempt to verify project..."
    after 1000
    if {[verify_project_open 10 500]} {
        set project_is_open 1
        puts "Project verified on final attempt: [get_project_info]"
    }
}

# Alternative: If verification still fails but project open succeeded, 
# try to proceed anyway (project might be ready even if info command fails)
if {!$project_is_open} {
    # Try one more verification with even more patience
    puts "Attempting one more verification with extended delay..."
    after 2000
    if {[verify_project_open 15 500]} {
        set project_is_open 1
        puts "Project verified after extended delay"
    }
}

# If still not verified, but project file exists and was opened, 
# try to proceed with a test add operation
if {!$project_is_open && [file exists $project_file]} {
    puts "WARNING: Verification failed but project file exists."
    puts "Attempting to proceed - will test by trying to add files..."
    puts "If this fails, files will not be added."
    set project_is_open 1  # Proceed with caution
}

if {!$project_is_open} {
    puts "ERROR: Could not open or verify project!"
    puts "Please try one of the following:"
    puts "  1. Open project manually: project open $project_file"
    puts "  2. Or use: source D:/AXI/sim/modelsim/scripts/project/add_files_auto.tcl"
    puts "  3. Or create project: project new $project_dir $project_name"
    return
}

# Display project status
puts "Project verified and ready: [get_project_info]"
puts ""

puts ""

# ============================================================================
# Hàm add tất cả file .v trong một thư mục vào project
# ============================================================================
proc add_directory_files {dir_path {pattern "*.v"} {desc ""}} {
    if {![file exists $dir_path]} {
        puts "  ⚠ Directory not found: $dir_path"
        return 0
    }
    
    if {$desc != ""} {
        puts "$desc"
    }
    
    # Tìm tất cả file .v trong thư mục (không recursive)
    set files [glob -nocomplain -directory $dir_path $pattern]
    
    if {[llength $files] == 0} {
        puts "  ⚠ No files found in: $dir_path"
        return 0
    }
    
    # Sắp xếp files
    set files [lsort $files]
    
    set count 0
    set skipped 0
    foreach file $files {
        # Bỏ qua file backup
        if {[string match "*.bak" $file]} {
            continue
        }
        
        # Kiểm tra xem file đã có trong project chưa
        set normalized_file [file normalize $file]
        set already_added 0
        
        # Lấy danh sách files trong project
        set project_files [project file]
        foreach proj_file $project_files {
            if {[string equal -nocase $normalized_file [file normalize $proj_file]]} {
                set already_added 1
                break
            }
        }
        
        if {!$already_added} {
            # Add file vào project (with error handling)
            if {[catch {project addfile $normalized_file} err]} {
                puts "  ✗ Error adding [file tail $file]: $err"
                # If addfile fails, project might not be ready
                # But continue with other files
            } else {
                puts "  ✓ Added: [file tail $file]"
                incr count
            }
        } else {
            puts "  ○ Already in project: [file tail $file]"
            incr skipped
        }
    }
    
    puts "  → Added: $count, Skipped: $skipped"
    return $count
}

# ============================================================================
# Hàm add file cụ thể vào project
# ============================================================================
proc add_specific_file {file_path {desc ""}} {
    if {![file exists $file_path]} {
        if {$desc != ""} {
            puts "$desc"
        }
        puts "  ⚠ File not found: $file_path"
        return 0
    }
    
    set normalized_file [file normalize $file_path]
    
    # Kiểm tra xem file đã có trong project chưa
    set already_added 0
    set project_files [project file]
    foreach proj_file $project_files {
        if {[string equal -nocase $normalized_file [file normalize $proj_file]]} {
            set already_added 1
            break
        }
    }
    
    if {!$already_added} {
        project addfile $normalized_file
        if {$desc != ""} {
            puts "$desc"
        }
        puts "  ✓ Added: [file tail $file_path]"
        return 1
    } else {
        if {$desc != ""} {
            puts "$desc"
        }
        puts "  ○ Already in project: [file tail $file_path]"
        return 0
    }
}

# ============================================================================
# Add files theo thứ tự
# ============================================================================
# Note: Project should already be verified and open at this point
# Do one final check before adding files (using safe method)
# ============================================================================
if {!$project_is_open} {
    puts "ERROR: Project is not marked as open! Cannot add files."
    puts "Please try opening the project manually first."
    return
}

# Final verification using safe method (project file list)
if {[catch {set project_files [project file]}]} {
    puts "WARNING: Cannot access project file list, but proceeding anyway..."
    puts "Project was verified earlier, attempting to add files..."
} else {
    puts "Project ready: [llength $project_files] file(s) currently in project"
}

puts "============================================================================"
puts "Adding Source Files to Project..."
puts "============================================================================"
puts "Project: [get_project_info]"
puts ""

set total_added 0

# 1. AXI Interconnect - Utils
set count [add_directory_files [file join $intercon_path "utils"] "*.v" "1. Adding AXI Interconnect Utils..."]
set total_added [expr $total_added + $count]

# 2. AXI Interconnect - Handshake
set count [add_directory_files [file join $intercon_path "handshake"] "*.v" "2. Adding AXI Interconnect Handshake..."]
set total_added [expr $total_added + $count]

# 3. AXI Interconnect - Datapath MUX
set count [add_directory_files [file join $intercon_path "datapath" "mux"] "*.v" "3. Adding AXI Interconnect Datapath MUX..."]
set total_added [expr $total_added + $count]

# 4. AXI Interconnect - Datapath DEMUX
set count [add_directory_files [file join $intercon_path "datapath" "demux"] "*.v" "4. Adding AXI Interconnect Datapath DEMUX..."]
set total_added [expr $total_added + $count]

# 5. AXI Interconnect - Buffers
set count [add_directory_files [file join $intercon_path "buffers"] "*.v" "5. Adding AXI Interconnect Buffers..."]
set total_added [expr $total_added + $count]

# 6. AXI Interconnect - Arbitration
set count [add_directory_files [file join $intercon_path "arbitration"] "*.v" "6. Adding AXI Interconnect Arbitration..."]
set total_added [expr $total_added + $count]

# 7. AXI Interconnect - Decoders
set count [add_directory_files [file join $intercon_path "decoders"] "*.v" "7. Adding AXI Interconnect Decoders..."]
set total_added [expr $total_added + $count]

# 8. AXI Interconnect - Channel Controllers (Write)
set count [add_directory_files [file join $intercon_path "channel_controllers" "write"] "*.v" "8. Adding AXI Interconnect Write Channel Controllers..."]
set total_added [expr $total_added + $count]

# 9. AXI Interconnect - Channel Controllers (Read)
set count [add_directory_files [file join $intercon_path "channel_controllers" "read"] "*.v" "9. Adding AXI Interconnect Read Channel Controllers..."]
set total_added [expr $total_added + $count]

# 10. AXI Interconnect - Core
set count [add_directory_files [file join $intercon_path "core"] "*.v" "10. Adding AXI Interconnect Core..."]
set total_added [expr $total_added + $count]

# 11. SERV RISC-V Core (theo thứ tự dependency)
puts "\n11. Adding SERV RISC-V Core..."
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
    set file_path [file join $serv_path $file]
    if {[add_specific_file $file_path]} {
        incr serv_count
    }
}
puts "  → Added $serv_count SERV core file(s)"
set total_added [expr $total_added + $serv_count]

# 12. Wishbone to AXI Converters
set count [add_directory_files [file join $wrapper_path "converters"] "*.v" "12. Adding Wishbone to AXI Converters..."]
set total_added [expr $total_added + $count]

# 13. System Modules
set count [add_directory_files [file join $wrapper_path "systems"] "*.v" "13. Adding System Modules..."]
set total_added [expr $total_added + $count]

# 14. IP Modules
set count [add_directory_files [file join $wrapper_path "ip"] "*.v" "14. Adding IP Modules..."]
set total_added [expr $total_added + $count]

# 15. Memory Slaves
set count [add_directory_files [file join $wrapper_path "memory"] "*.v" "15. Adding Memory Slaves..."]
set total_added [expr $total_added + $count]

# 16. ALU Core Files (src/cores/alu)
set count [add_directory_files [file join $project_root "src" "cores" "alu"] "*.v" "16. Adding ALU Core Files..."]
set total_added [expr $total_added + $count]

# 17. Testbench (optional - có thể bỏ qua nếu không muốn)
puts "\n17. Adding Testbench Files (optional)..."
# Scan testbenches subdirectories
set count [add_directory_files [file join $tb_path "wrapper_tb" "testbenches" "serv"] "*.v" ""]
set count2 [add_directory_files [file join $tb_path "wrapper_tb" "testbenches" "dual_riscv"] "*.v" ""]
set count [expr $count + $count2]
set total_added [expr $total_added + $count]

# Add SystemVerilog benches
set count_sv [add_directory_files [file join $tb_path "wrapper_tb" "testbenches" "dual_riscv"] "*.sv" ""] 
set total_added [expr $total_added + $count_sv]

# 18. SERV Core standalone benches
puts "\n18. Adding SERV Core standalone benches..."
set serv_bench_path [file join $project_root "src" "cores" "serv" "bench"]
set count [add_directory_files $serv_bench_path "*.v" ""]
set total_added [expr $total_added + $count]

# 19. AXI-Lite Peripherals
set count [add_directory_files [file join $project_root "src" "peripherals" "axi_lite"] "*.v" "19. Adding AXI-Lite peripherals..."]
set total_added [expr $total_added + $count]

# 20. Custom AXI SV blocks
set count [add_directory_files [file join $intercon_path "custom"] "*.sv" "20. Adding custom AXI SV blocks..."]
set total_added [expr $total_added + $count]

# ============================================================================
# Summary
# ============================================================================
puts "\n============================================================================"
puts "Summary"
puts "============================================================================"
puts "Total new files added: $total_added"
if {![catch {set project_files [project file]}]} {
    puts "Total project files: [llength $project_files]"
} else {
    puts "Total project files: (unable to count)"
}
puts ""
puts "✓ Files have been added to the project!"
puts "  You can now see them in the Project tab."
puts "============================================================================"

# ============================================================================
# Optional: Auto-compile to check for errors
# ============================================================================
puts ""
puts "============================================================================"
puts "Auto-Compile Check (Optional)"
puts "============================================================================"
puts "Do you want to compile all files to check for errors? (This may take a while)"
puts "Type 'yes' to compile, or press Enter to skip:"
flush stdout

# Note: In ModelSim, we can't easily get user input in TCL script
# So we'll just attempt to compile with error handling
puts "Attempting to compile project files..."
puts "(Note: This is a basic syntax check)"

# Try to compile (with error handling)
if {![catch {project compileall} compile_result]} {
    puts "✓ Compilation completed!"
    puts "  Check the Transcript window for any errors or warnings."
} else {
    puts "⚠ Compilation check skipped or failed."
    puts "  You can manually compile later using: project compileall"
}

puts ""
puts "============================================================================"
puts "Next Steps:"
puts "============================================================================"
puts "1. Check the Project tab to see all added files"
puts "2. Compile files: project compileall"
puts "3. Run simulation: vsim <testbench_name>"
puts "4. Or use test scripts in: sim/modelsim/scripts/sim/"
puts "============================================================================"

