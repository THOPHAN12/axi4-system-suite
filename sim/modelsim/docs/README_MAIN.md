# ModelSim Simulation Guide

## Tổng Quan

Thư mục này chứa tất cả các script và file cần thiết để chạy simulation trong ModelSim.

## Cấu Trúc Files

### Project Files
- `AXI_Project.mpf` - ModelSim project file (quan trọng, không xóa)
- `modelsim.ini` - ModelSim configuration file
- `work/` - ModelSim work library (tự động tạo, có thể xóa và regenerate)

### Test Programs
- `test_program_simple.hex` - Simple RISC-V test program

### Scripts Chính (Đã được tổ chức thành thư mục)

#### 1. Compilation Scripts (`scripts/compile/`)

**RISC-V System:**
- `scripts/compile/compile_riscv.tcl` - Chỉ compile RISC-V system
- `scripts/compile/compile_and_run_riscv.tcl` - Compile rồi chạy simulation
- `batch/compile_riscv.bat`, `batch/compile_and_run_riscv.bat` - Windows batch files

#### 2. Simulation Scripts (`scripts/sim/`)

**RISC-V System:**
- `scripts/sim/run_riscv_test.tcl` - Compile và chạy (all-in-one)
- `scripts/sim/run_riscv_sim.tcl` - Chỉ chạy simulation (đã compile)
- `batch/run_riscv.bat`, `batch/run_riscv_sim.bat` - Windows batch files

**Dual Master System:**
- `scripts/sim/run_dual_master_test.tcl` - Test dual master system (SERV + ALU)
- `scripts/sim/run_dual_master_ip_test.tcl` - Test dual master system IP module
- `batch/run_dual_master_ip_test.bat` - Windows batch file

**IP Modules:**
- `scripts/sim/run_ip_test.tcl` - Test SERV AXI System IP

**Other Tests:**
- `scripts/sim/run_wrapper_test.tcl` - Test ALU master system wrapper
- `scripts/sim/run_simple_test.tcl` - Simple routing test
- `batch/run_wrapper_test.bat` - Windows batch file

#### 3. Project Management Scripts (`scripts/project/`)

- `scripts/project/add_all_files.tcl` - Add tất cả Verilog files vào ModelSim project (khi project đã mở)
- `scripts/project/add_files_auto.tcl` - Tự động tạo/mở project và add files
- `scripts/project/add_all_file.tcl` - Alias cho add_all_files.tcl

### Documentation

Tất cả tài liệu được lưu trong thư mục `docs/`:
- `docs/README.md` - Tổng quan tài liệu
- `docs/README_MAIN.md` - File này (tổng quan ModelSim)
- `docs/README_RUN_TESTS.md` - Hướng dẫn chạy testbench
- `docs/README_TCL_FILES.md` - Giải thích các TCL scripts

## Quick Start

### 1. Chạy RISC-V Testbench

```bash
# Windows (từ thư mục sim/modelsim)
cd sim/modelsim
batch\run_riscv.bat

# Hoặc trong ModelSim
cd D:/AXI/sim/modelsim
source scripts/sim/run_riscv_test.tcl
```

### 2. Chạy Dual Master System IP Testbench

```bash
# Windows (từ thư mục sim/modelsim)
cd sim/modelsim
batch\run_dual_master_ip_test.bat

# Hoặc trong ModelSim
cd D:/AXI/sim/modelsim
source scripts/sim/run_dual_master_ip_test.tcl
```

### 3. Tạo/Quản lý ModelSim Project

```tcl
# Trong ModelSim
cd D:/AXI/sim/modelsim
source scripts/project/add_files_auto.tcl
```

## Workflow Đề Xuất

### Lần Đầu Setup

1. Mở ModelSim
2. Chạy `add_files_auto.tcl` để tạo project và add files
3. Compile và chạy testbench

### Hàng Ngày

1. Mở ModelSim project: `project open AXI_Project`
2. Nếu có file mới: `source scripts/project/add_all_files.tcl`
3. Chạy testbench cần thiết: `batch\<testbench>.bat` hoặc `source scripts/sim/<testbench>.tcl`

### Khi Có File Mới

1. Mở project: `project open AXI_Project`
2. Add files: `source scripts/project/add_all_files.tcl`
3. Hoặc dùng GUI: Project → Add to Project → Existing File

## Các Testbench Có Sẵn

1. **RISC-V System** (`scripts/sim/run_riscv_test.tcl`)
   - Test SERV RISC-V processor
   - Load test program từ hex file
   - Test instruction fetch và data access

2. **Dual Master System** (`scripts/sim/run_dual_master_test.tcl`)
   - Test SERV + ALU Master
   - Test 4 memory slaves
   - Test address routing

3. **Dual Master System IP** (`scripts/sim/run_dual_master_ip_test.tcl`)
   - Test complete IP module
   - Integrated memory slaves
   - No external connections needed

4. **SERV AXI System IP** (`scripts/sim/run_ip_test.tcl`)
   - Test SERV IP module
   - Integrated instruction và data memory

5. **ALU Master System** (`scripts/sim/run_wrapper_test.tcl`)
   - Test ALU masters
   - Test multiple masters và slaves
   - Test data integrity

## File Quan Trọng (KHÔNG XÓA)

- `AXI_Project.mpf` - ModelSim project file
- `modelsim.ini` - Configuration
- Tất cả `.tcl` scripts trong `scripts/`
- Tất cả `.bat` scripts trong `batch/`
- `test_program_simple.hex` - Test program
- `work/` directory - Work library (có thể regenerate nhưng cần thiết khi chạy)

## File Có Thể Xóa (Tự Động Tạo Lại)

- `*.vcd` - Waveform dumps (tự động tạo khi chạy simulation)
- `*.wlf` - ModelSim waveform files
- `transcript` - Log file
- `*.cr.mti` - Cache files
- `work/` - Có thể xóa và regenerate

## Troubleshooting

### Lỗi: "Project not found"
- Chạy `scripts/project/add_files_auto.tcl` để tạo project

### Lỗi: "File not found"
- Kiểm tra đang ở đúng thư mục
- Kiểm tra file có tồn tại trong project

### Lỗi: "Design unit not found"
- Kiểm tra file đã được compile chưa
- Kiểm tra thứ tự compile (dependencies phải compile trước)

## Chi Tiết Hơn

- Xem `docs/README_RUN_TESTS.md` để biết cách chạy testbench
- Xem `docs/README_TCL_FILES.md` để hiểu các TCL scripts
