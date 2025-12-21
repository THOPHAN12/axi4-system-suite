# Vivado Synthesis Fix Guide for KV260

## Tổng Quan

Tài liệu này giải thích các lỗi synthesis phổ biến và cách khắc phục cho dự án Block Design trên KV260.

## Lỗi và Nguyên Nhân Gốc Rễ

### 1. `[Synth 8-439] module 'design_1_zynq_ultra_ps_e_0_0' not found`

**Nguyên nhân:**
- Zynq UltraScale+ PS IP là **nested sub-design** trong Block Design
- IP này **không thể generate riêng lẻ** - phải generate từ parent Block Design
- Output products của Block Design chưa được generate đúng cách

**Giải pháp:**
- Generate output products cho **toàn bộ Block Design** (Global mode)
- Không generate từng IP riêng lẻ
- Sử dụng: `generate_target all [get_files design_1.bd]`

**Cascading errors:**
- Nếu Zynq PS module không tìm thấy, synthesis sẽ fail và các lỗi khác sẽ không được report

---

### 2. XDC Constraints: `set_input_delay/set_output_delay` trên Internal AXI Signals

**Nguyên nhân:**
- XDC constraints file (`axi_interconnect.xdc`) có các constraints cho external ports:
  - `M0_*`, `M1_*` (Master ports)
  - `S0_*`, `S1_*`, `S2_*`, `S3_*` (Slave ports)
- Khi Block Design được implement, các AXI interfaces này trở thành **internal signals** (không phải top-level ports)
- `get_ports M0_*` sẽ fail vì không có ports với tên này ở top-level

**Giải pháp:**
- Comment out tất cả constraints sử dụng `get_ports` với `M0_*`, `M1_*`, `S0_*`, `S1_*`, `S2_*`, `S3_*`
- Giữ lại constraints cho `ACLK` và `ARESETN` nếu chúng là top-level ports
- File `axi_interconnect.xdc` đã được fix (các constraints đã được comment)

**Lưu ý:**
- Nếu AXI interfaces là internal trong Block Design, không cần I/O delays
- Timing cho internal AXI signals được handle tự động bởi Vivado
- Chỉ cần constraints cho clock và reset nếu là top-level ports

---

### 3. Out-of-Context (OOC) Synthesis Failures

**Nguyên nhân:**
- Vivado mặc định enable OOC synthesis cho các IPs trong Block Design
- OOC synthesis tạo checkpoint riêng cho mỗi IP **trước khi** synthesis top-level
- Với AXI và Zynq PS IPs, OOC synthesis thường fail vì:
  - IPs này phụ thuộc vào top-level connectivity
  - Clock/reset connections chỉ được resolve ở top-level
  - Zynq PS cần thông tin từ Block Design context

**Giải pháp:**
- Disable OOC synthesis per-IP: `set_property GENERATE_SYNTH_CHECKPOINT false [get_ips *]`
- Synthesis tất cả IPs **in-context** với top-level design
- Điều này đảm bảo tất cả connections được resolve đúng

**Khi nào dùng OOC:**
- OOC synthesis hữu ích cho standalone IPs (không phụ thuộc context)
- Với Block Design, nên disable OOC để tránh dependency issues

---

## Quy Trình Fix Synthesis (Step-by-Step)

### Bước 1: Mở Block Design

```tcl
set bd_file [get_files design_1.bd]
open_bd_design $bd_file
```

**Kiểm tra:**
- Block Design có mở được không?
- Zynq PS instance có tồn tại không?

---

### Bước 2: Verify Zynq PS Configuration

```tcl
set zynq_cell [get_bd_cells *zynq_ultra_ps_e*]
get_property CONFIG.PSU__USE__M_AXI_GP0 $zynq_cell
get_property CONFIG.PSU__USE__M_AXI_GP1 $zynq_cell
```

**Kiểm tra:**
- HPM0_FPD (Master 0) đã enable chưa?
- HPM1_FPD (Master 1) đã enable chưa?

---

### Bước 3: Validate và Save Block Design

```tcl
validate_bd_design -force
save_bd_design
```

**Kiểm tra:**
- Validation có pass không?
- Có errors/warnings nào cần fix không?

---

### Bước 4: Generate Output Products (Global Mode)

```tcl
close_bd_design [current_bd_design]
generate_target all [get_files design_1.bd]
```

**Quan trọng:**
- **Đóng Block Design trước khi generate** (required)
- Generate cho **toàn bộ BD**, không generate từng IP riêng
- Điều này sẽ tự động generate tất cả nested IPs (Zynq PS, BRAM Controller, etc.)

---

### Bước 5: Tạo HDL Wrapper

```tcl
open_bd_design [get_files design_1.bd]
set wrapper_file [make_wrapper -files [get_files design_1.bd] -top]
add_files -norecurse $wrapper_file
set_property top [file rootname [file tail $wrapper_file]] [current_fileset]
update_compile_order -fileset sources_1
```

**Kiểm tra:**
- Wrapper file đã được tạo chưa?
- Top module đã được set chưa?

---

### Bước 6: Disable OOC Synthesis

```tcl
set all_ips [get_ips]
foreach ip $all_ips {
    set_property GENERATE_SYNTH_CHECKPOINT false $ip
}
```

**Kiểm tra:**
- Tất cả IPs đã disable OOC chưa?
- List IPs: `get_ips`

---

### Bước 7: Clean/Reset Synthesis Runs

```tcl
set synth_runs [get_runs -filter {IS_SYNTHESIS == 1}]
foreach run $synth_runs {
    delete_run $run
}
reset_run synth_1
```

**Hoặc:**
```tcl
create_run synth_1 -flow {Vivado Synthesis 2023} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
```

---

### Bước 8: Kiểm Tra XDC Constraints

**Kiểm tra main constraints file:**
```tcl
# File: synthesis/constraints/axi_interconnect.xdc
# Đảm bảo các constraints cho M0_*, M1_*, S0_*-S3_* đã được comment
```

**Kiểm tra generated IP XDC files:**
```tcl
# Các file trong: <project>.gen/sources_1/bd/design_1/ip/*/src/
# Nếu có references đến internal ports, cần comment
```

---

### Bước 9: Chạy Synthesis

```tcl
launch_runs synth_1 -jobs 4
wait_on_run synth_1
```

**Kiểm tra kết quả:**
```tcl
open_run synth_1
report_utilization
report_timing_summary
```

---

## Sử Dụng Script Tự Động

Để tự động thực hiện tất cả các bước trên:

```tcl
cd "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"
source fix_synthesis_flow.tcl
```

Script sẽ:
1. ✓ Mở và validate Block Design
2. ✓ Verify Zynq PS configuration
3. ✓ Generate output products globally
4. ✓ Tạo HDL wrapper và set as top
5. ✓ Disable OOC synthesis
6. ✓ Clean/reset synthesis runs
7. ✓ Kiểm tra XDC constraints
8. ✓ Hiển thị summary và next steps

---

## Checklist Đảm Bảo Synthesis Thành Công

### Trước khi chạy synthesis:

- [ ] Block Design đã được validate và save
- [ ] Output products đã được generate (check: `<project>.gen/sources_1/bd/design_1/`)
- [ ] HDL wrapper đã được tạo và set as top module
- [ ] OOC synthesis đã được disable cho tất cả IPs
- [ ] XDC constraints không có references đến internal AXI ports (M0_*, M1_*, S0_*-S3_*)
- [ ] Clock constraints chỉ áp dụng cho top-level clock ports (nếu có)
- [ ] Synthesis runs đã được clean/reset

### Sau khi synthesis:

- [ ] Synthesis completed successfully (STATUS = "synth_design Complete!")
- [ ] No critical errors
- [ ] Check utilization report (không quá 100%)
- [ ] Check timing summary (setup/hold timing)
- [ ] Check synthesis log for warnings (address critical warnings)

---

## Troubleshooting

### Lỗi: "Block Design file not found"

**Nguyên nhân:** Block Design chưa được add vào project hoặc path không đúng.

**Giải pháp:**
```tcl
# Kiểm tra BD files
get_files *.bd

# Nếu không có, add BD vào project
add_files <path_to_design_1.bd>
```

---

### Lỗi: "Zynq PS IP locked"

**Nguyên nhân:** IP đang ở trạng thái locked, không thể upgrade/generate.

**Giải pháp:**
```tcl
# Unlock IP
set_property IS_LOCKED false [get_ips *zynq_ultra_ps_e*]

# Upgrade IP
upgrade_ip [get_ips *zynq_ultra_ps_e*]
```

---

### Warning: "No valid object(s) found for get_ports"

**Nguyên nhân:** XDC constraints đang reference ports không tồn tại ở top-level.

**Giải pháp:**
- Comment out constraints trong XDC files
- Chỉ giữ constraints cho ports thực sự tồn tại ở top-level

---

### Lỗi: "Out-of-Context synthesis failed"

**Nguyên nhân:** IP synthesis failed khi chạy OOC.

**Giải pháp:**
- Disable OOC synthesis: `set_property GENERATE_SYNTH_CHECKPOINT false [get_ips *]`
- Synthesis in-context với top-level

---

## Tài Liệu Tham Khảo

- [Xilinx UG949 - Vivado Design Suite User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2023_2/ug949-vivado-design-suite-user-guide.pdf)
- [Xilinx UG1037 - UltraFast Design Methodology Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2023_2/ug949-vivado-design-suite-user-guide.pdf)
- [Xilinx PG201 - AXI Interconnect](https://www.xilinx.com/support/documentation/ip_documentation/axi_interconnect/v2_1/pg059-axi-interconnect.pdf)

---

## Kết Luận

Các lỗi synthesis thường gặp trên KV260 Block Design đều có nguyên nhân rõ ràng:

1. **Zynq PS module not found** → Generate BD output products globally
2. **XDC constraints on internal ports** → Comment out internal port constraints
3. **OOC synthesis failures** → Disable OOC, synthesis in-context

Sử dụng script `fix_synthesis_flow.tcl` để tự động fix tất cả các vấn đề trên.






