# ModelSim Simulation Documentation

## Tổng Quan

Thư mục này chứa tất cả tài liệu hướng dẫn sử dụng ModelSim simulation.

## Các Tài Liệu

### 1. [README_RUN_TESTS.md](README_RUN_TESTS.md) - Hướng Dẫn Chạy Testbench
Hướng dẫn chi tiết cách chạy các testbench:
- RISC-V System testbench
- Dual Master System IP testbench
- SERV AXI System IP testbench
- ALU Master System testbench
- Các testbench khác

### 2. [README_TCL_FILES.md](README_TCL_FILES.md) - Hướng Dẫn TCL Scripts
Giải thích các TCL scripts:
- Project management scripts
- Compilation scripts
- Simulation scripts
- Workflow đề xuất

### 3. [README_MAIN.md](README_MAIN.md) - Tổng Quan ModelSim
Tổng quan về cấu trúc files, project, và quick start guide.

## Quick Start

### Chạy Testbench Nhanh

```bash
# RISC-V System
cd sim/modelsim
run_riscv.bat

# Dual Master System IP
run_dual_master_ip_test.bat
```

### Quản Lý Project

```tcl
# Trong ModelSim
cd D:/AXI/sim/modelsim
source add_files_auto.tcl
```

## Cấu Trúc Files

Xem [README_MAIN.md](README_MAIN.md) để biết chi tiết về cấu trúc files trong thư mục `sim/modelsim`.

