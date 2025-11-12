# ============================================================================
# TCL Script to Auto-Create Project and Add All Files
# Usage: source add_files_auto.tcl
# 
# Chức năng:
# - Tự động tạo project nếu chưa có, hoặc mở project nếu đã tồn tại
# - Tự động add TẤT CẢ file .v vào project
# - CHỈ add file MỚI (file đã có trong project sẽ bị bỏ qua)
# - Có thể chạy nhiều lần mà không bị duplicate files
# - Tự động phát hiện file mới được thêm vào thư mục
# ============================================================================

set project_name "AXI_Project"
set project_homedir "D:/AXI/sim/modelsim"
set project_path [file join $project_homedir $project_name]

# Kiểm tra xem project đã tồn tại chưa
if {[file exists "$project_path.mpf"]} {
    puts "Project already exists. Opening..."
    # ModelSim sẽ tự động đóng project cũ khi mở project mới
    if {[catch {project open $project_path} err]} {
        # Nếu lỗi vì project đang mở, thử đóng trước
        puts "Trying to close current project first..."
        catch {project close}
        project open $project_path
    }
} else {
    puts "Creating new project: $project_name"
    puts "  Home directory: $project_homedir"
    puts "  Project name: $project_name"
    
    # Nếu có project đang mở, thử đóng trước
    if {![catch {project info}]} {
        puts "Closing current project..."
        catch {project close}
    }
    
    # Cú pháp đúng: project new homedir name
    # ModelSim sẽ tự động đóng project cũ nếu có
    if {[catch {project new $project_homedir $project_name} err]} {
        puts "Error creating project: $err"
        puts "Trying to close current project and retry..."
        catch {project close}
        project new $project_homedir $project_name
    }
}

# Đảm bảo project đã được mở - thử nhiều cách
set project_opened 0

# Cách 1: Kiểm tra project info
if {![catch {set project_info [project info]}]} {
    puts "Project is open: $project_info"
    set project_opened 1
} else {
    # Cách 2: Kiểm tra bằng project file
    if {![catch {project file}]} {
        puts "Project is open (detected via project file)"
        set project_opened 1
    } else {
        # Cách 3: Thử mở lại project
        puts "Project may not be open. Trying to open..."
        if {[file exists "$project_path.mpf"]} {
            if {![catch {project open $project_path}]} {
                puts "Project opened: $project_path"
                set project_opened 1
            }
        }
    }
}

if {!$project_opened} {
    puts "ERROR: Could not verify project is open!"
    puts "Please try opening project manually:"
    puts "  project open $project_path"
    return
}

# Đợi một chút để đảm bảo project đã sẵn sàng
after 100

# Sau đó source script add files
puts "\nNow adding files to project...\n"
source [file join [file dirname [file normalize [info script]]] "add_all_files.tcl"]

