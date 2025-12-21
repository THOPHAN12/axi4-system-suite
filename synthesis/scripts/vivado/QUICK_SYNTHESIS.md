# Hướng Dẫn Chạy Synthesis với Constraints

## Vấn Đề Với Đường Dẫn Có Khoảng Trắng

Nếu gặp lỗi `File or Directory 'C:/Users/Nguyen' does not exist`, đây là do đường dẫn có khoảng trắng.

## Giải Pháp: Thêm Constraints Thủ Công (Khuyến Nghị)

### Cách 1: Dùng GUI (Đơn Giản Nhất)

1. **Mở project trong Vivado**
   - File > Open Project
   - Chọn: `synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr`

2. **Thêm Constraints:**
   - Flow Navigator > **Add Sources**
   - Chọn **Add or Create Constraints**
   - Click **Add Files**
   - Browse đến: `synthesis/constraints/axi_interconnect.xdc`
   - Click **Finish**

3. **Kiểm tra constraints đã thêm:**
   - Sources window > Constraints > constrs_1
   - Xem file `axi_interconnect.xdc`

### Cách 2: Dùng TCL Trực Tiếp (Copy/Paste)

Copy và paste toàn bộ vào Vivado TCL Console:

```tcl
# Get project directory
set proj_dir [get_property DIRECTORY [current_project]]

# Calculate constraints file path
set constraints_file [file normalize [file join $proj_dir ".." ".." "constraints" "axi_interconnect.xdc"]]

# Check if file exists
if {[file exists $constraints_file]} {
    # Remove old constraints if exists
    set old_files [get_files -quiet -of_objects [get_filesets constrs_1] $constraints_file]
    if {[llength $old_files] > 0} {
        remove_files -fileset constrs_1 $old_files
    }
    
    # Add constraints file
    add_files -fileset constrs_1 -norecurse $constraints_file
    
    # Set as active
    set_property target_constrs_file $constraints_file [current_fileset -constrset]
    
    puts "Constraints added successfully!"
    puts "File: $constraints_file"
} else {
    puts "ERROR: Constraints file not found: $constraints_file"
}
```

## Chạy Synthesis

Sau khi đã thêm constraints, chạy synthesis:

### Cách A: Dùng GUI
1. Flow Navigator > **Synthesis** > **Run Synthesis**
2. Hoặc click nút **Run Synthesis** trên toolbar

### Cách B: Dùng TCL (Copy/Paste)

```tcl
# Set top module
set_property top AXI_Interconnect [current_fileset]

# Reset synthesis run (if already run)
reset_run synth_1

# Run synthesis
launch_runs synth_1 -jobs 4

# Wait for completion
wait_on_run synth_1

# Open results
open_run synth_1

# View reports
report_utilization -hierarchical
report_timing_summary -max_paths 10
```

## Xem Kết Quả

Sau khi synthesis hoàn thành:

1. **Utilization Report:**
   - Flow Navigator > Synthesis > synth_1 > **Utilization Report**
   - Hoặc: `report_utilization`

2. **Timing Report:**
   - Flow Navigator > Synthesis > synth_1 > **Timing Summary**
   - Hoặc: `report_timing_summary`

## Troubleshooting

### Lỗi: "Constraints file not found"
- Kiểm tra file tồn tại: `synthesis/constraints/axi_interconnect.xdc`
- Dùng GUI để thêm file thay vì script

### Lỗi: "Top module not found"
- Đảm bảo top module đúng: `set_property top AXI_Interconnect [current_fileset]`

### Synthesis Fails
- Kiểm tra log: `synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.runs/synth_1/runme.log`
- Kiểm tra syntax errors trong RTL
- Kiểm tra constraints file syntax

---

**Lưu ý:** Nếu gặp vấn đề với scripts do đường dẫn có khoảng trắng, luôn dùng GUI hoặc copy/paste TCL commands trực tiếp.














