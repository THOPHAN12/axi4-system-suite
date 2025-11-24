# Quartus Project Organization

## Cấu Trúc Thư Mục

Dự án Quartus đã được tổ chức thành 2 folder riêng biệt:

```
sim/quartus/
├── quartus_verilog/          # Project Verilog (gốc)
│   ├── AXI_PROJECT.qpf
│   ├── AXI_PROJECT.qsf
│   ├── add_all_source_files.tcl
│   ├── add_files.tcl
│   ├── db/
│   ├── incremental_db/
│   └── output_files/
│
└── quartus_systemverilog/     # Project SystemVerilog (mới)
    ├── AXI_PROJECT_SV.qpf
    ├── AXI_PROJECT_SV.qsf
    ├── add_all_source_files_sv.tcl
    ├── db/
    ├── incremental_db/
    └── output_files/
```

## Mô Tả

### `quartus_verilog/`
- **Mục đích**: Project Quartus sử dụng các file Verilog gốc (`.v`)
- **Top-level entity**: `AXI_Interconnect_Full` (Verilog)
- **Source files**: Tất cả file từ `src/axi_interconnect/rtl/` (Verilog)
- **Project file**: `AXI_PROJECT.qpf`
- **Settings file**: `AXI_PROJECT.qsf`

### `quartus_systemverilog/`
- **Mục đích**: Project Quartus sử dụng các file SystemVerilog mới (`.sv`)
- **Top-level entity**: `AXI_Interconnect_Full` (SystemVerilog)
- **Source files**: Tất cả file từ `src/axi_interconnect/sv/` (SystemVerilog)
- **Project file**: `AXI_PROJECT_SV.qpf`
- **Settings file**: `AXI_PROJECT_SV.qsf`

## Cách Sử Dụng

### Mở Project Verilog

1. Mở Quartus II
2. File → Open Project
3. Chọn `sim/quartus/quartus_verilog/AXI_PROJECT.qpf`
4. Hoặc chạy TCL script: `source add_all_source_files.tcl`

### Mở Project SystemVerilog

1. Mở Quartus II
2. File → Open Project
3. Chọn `sim/quartus/quartus_systemverilog/AXI_PROJECT_SV.qpf`
4. Hoặc chạy TCL script: `source add_all_source_files_sv.tcl`

## Khác Biệt Chính

### Verilog Project (`quartus_verilog`)
- Sử dụng `VERILOG_FILE` assignment cho tất cả file AXI Interconnect
- Đường dẫn: `src/axi_interconnect/rtl/`
- File extension: `.v`

### SystemVerilog Project (`quartus_systemverilog`)
- Sử dụng `SYSTEMVERILOG_FILE` assignment cho file AXI Interconnect
- Sử dụng `VERILOG_FILE` assignment cho các file khác (SERV, wrapper, etc.)
- Đường dẫn: `src/axi_interconnect/sv/`
- File extension: `.sv` cho AXI Interconnect, `.v` cho các module khác

## Search Paths

### Verilog Project
- `D:/AXI/src/cores/serv/rtl`
- `D:/AXI/src/axi_interconnect/rtl/includes`

### SystemVerilog Project
- `D:/AXI/src/cores/serv/rtl`
- `D:/AXI/src/axi_interconnect/sv/packages`
- `D:/AXI/src/axi_interconnect/sv/interfaces`
- `D:/AXI/src/axi_interconnect/rtl/includes`

## Lưu Ý

1. **Cả 2 project đều sử dụng cùng FPGA device**: `EP2C70F672C6`
2. **Cả 2 project đều có cùng top-level entity**: `AXI_Interconnect_Full`
3. **Các file không phải AXI Interconnect** (SERV, wrapper, memory, ALU) vẫn là Verilog trong cả 2 project
4. **Chỉ có AXI Interconnect modules** được chuyển đổi sang SystemVerilog

## TCL Scripts

### `add_all_source_files.tcl` (Verilog)
- Thêm tất cả file Verilog vào project
- Sử dụng `VERILOG_FILE` assignment
- Đường dẫn tương đối từ `quartus_verilog/`

### `add_all_source_files_sv.tcl` (SystemVerilog)
- Thêm file SystemVerilog cho AXI Interconnect
- Thêm file Verilog cho các module khác
- Sử dụng `SYSTEMVERILOG_FILE` và `VERILOG_FILE` assignments
- Đường dẫn tương đối từ `quartus_systemverilog/`

## Next Steps

1. Mở và compile cả 2 project để so sánh kết quả
2. Kiểm tra warnings và errors
3. So sánh resource utilization giữa 2 versions
4. Test functionality của cả 2 versions
