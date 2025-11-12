# ModelSim TCL Scripts Guide

## Cấu Trúc Thư Mục

Các TCL scripts đã được tổ chức thành các thư mục để dễ quản lý:

```
sim/modelsim/
├── scripts/
│   ├── compile/          # Compilation scripts
│   │   ├── compile_riscv.tcl
│   │   └── compile_and_run_riscv.tcl
│   ├── sim/              # Simulation scripts
│   │   ├── run_riscv_test.tcl
│   │   ├── run_riscv_sim.tcl
│   │   ├── run_dual_master_test.tcl
│   │   ├── run_dual_master_ip_test.tcl
│   │   ├── run_ip_test.tcl
│   │   ├── run_wrapper_test.tcl
│   │   └── run_simple_test.tcl
│   └── project/          # Project management scripts
│       ├── add_all_files.tcl
│       ├── add_files_auto.tcl
│       └── add_all_file.tcl
├── batch/                # Batch files (Windows)
│   ├── compile_riscv.bat
│   ├── compile_and_run_riscv.bat
│   ├── run_riscv.bat
│   ├── run_riscv_sim.bat
│   ├── run_dual_master_ip_test.bat
│   └── run_wrapper_test.bat
└── docs/                 # Documentation
```

## Compilation Scripts

### `scripts/compile/compile_riscv.tcl`

**Mục đích**: Compile SERV RISC-V system và tất cả dependencies

**Cách dùng**:
```tcl
# Trong ModelSim TCL Console
cd D:/AXI/sim/modelsim
source scripts/compile/compile_riscv.tcl
```

**Hoặc dùng batch file**:
```batch
batch\compile_riscv.bat
```

**Chức năng**:
- Compile SERV RISC-V core files
- Compile AXI Interconnect components
- Compile wrapper modules (wb2axi_read, wb2axi_write, serv_axi_wrapper)
- Compile memory slaves (axi_rom_slave, axi_memory_slave)
- Compile ALU Master components (nếu có)
- Tạo work library nếu chưa có

### `scripts/compile/compile_and_run_riscv.tcl`

**Mục đích**: Compile rồi chạy simulation ngay

**Cách dùng**:
```tcl
source scripts/compile/compile_and_run_riscv.tcl
```

**Hoặc dùng batch file**:
```batch
batch\compile_and_run_riscv.bat
```

## Simulation Scripts

### `scripts/sim/run_riscv_test.tcl`

**Mục đích**: Compile và chạy `serv_axi_system_tb.v` testbench

**Cách dùng**:
```tcl
source scripts/sim/run_riscv_test.tcl
```

**Hoặc dùng batch file**:
```batch
batch\run_riscv.bat
```

**Chức năng**:
- Compile tất cả dependencies
- Compile testbench `serv_axi_system_tb.v`
- Chạy simulation
- Tạo waveform file `serv_axi_system_tb.vcd`

### `scripts/sim/run_riscv_sim.tcl`

**Mục đích**: Chạy simulation (giả định đã compile trước)

**Cách dùng**:
```tcl
# Phải compile trước
source scripts/compile/compile_riscv.tcl

# Sau đó chạy simulation
source scripts/sim/run_riscv_sim.tcl
```

**Hoặc dùng batch file**:
```batch
batch\compile_riscv.bat
batch\run_riscv_sim.bat
```

### `scripts/sim/run_dual_master_ip_test.tcl`

**Mục đích**: Compile và chạy `dual_master_system_ip_tb.v` testbench

**Cách dùng**:
```tcl
source scripts/sim/run_dual_master_ip_test.tcl
```

**Hoặc dùng batch file**:
```batch
batch\run_dual_master_ip_test.bat
```

**Chức năng**:
- Compile SERV core, AXI Interconnect, ALU Master
- Compile wrapper modules và IP modules
- Compile testbench `dual_master_system_ip_tb.v`
- Chạy simulation
- Tạo waveform file `dual_master_system_ip_tb.vcd`

### `scripts/sim/run_ip_test.tcl`

**Mục đích**: Compile và chạy `serv_axi_system_ip_tb.v` testbench

**Cách dùng**:
```tcl
source scripts/sim/run_ip_test.tcl
```

**Chức năng**:
- Compile SERV RISC-V IP system
- Compile testbench `serv_axi_system_ip_tb.v`
- Chạy simulation

### `scripts/sim/run_wrapper_test.tcl`

**Mục đích**: Compile và chạy ALU Master System wrapper testbench

**Cách dùng**:
```tcl
source scripts/sim/run_wrapper_test.tcl
```

**Hoặc dùng batch file**:
```batch
batch\run_wrapper_test.bat
```

### `scripts/sim/run_dual_master_test.tcl`

**Mục đích**: Compile và chạy `dual_master_system_tb.v` testbench

**Cách dùng**:
```tcl
source scripts/sim/run_dual_master_test.tcl
```

### `scripts/sim/run_simple_test.tcl`

**Mục đích**: Chạy simple routing test cho ALU Master System

**Cách dùng**:
```tcl
source scripts/sim/run_simple_test.tcl
```

## Project Management Scripts

### `scripts/project/add_all_files.tcl`

**Mục đích**: Thêm tất cả file .v vào ModelSim project (project phải đã mở)

**Cách dùng**:
```tcl
# 1. Mở ModelSim GUI
# 2. File -> New -> Project (hoặc mở project hiện có)
# 3. Trong Transcript window:
source scripts/project/add_all_files.tcl
```

**Chức năng**:
- Quét tất cả file .v trong các thư mục source
- Chỉ thêm file mới (bỏ qua file đã có)
- Có thể chạy nhiều lần mà không bị duplicate
- Tự động phát hiện file mới

**Lưu ý**: Project phải đã được mở trước khi chạy script này.

### `scripts/project/add_files_auto.tcl`

**Mục đích**: Tự động tạo/mở project và thêm tất cả files

**Cách dùng**:
```tcl
# Trong ModelSim TCL Console
source scripts/project/add_files_auto.tcl
```

**Chức năng**:
- Tự động tạo project `AXI_Project` nếu chưa có
- Hoặc mở project nếu đã tồn tại
- Đóng project hiện tại nếu đang mở
- Gọi `add_all_files.tcl` để thêm files

**Lưu ý**: Script này có thể đóng project hiện tại của bạn. Lưu công việc trước khi chạy.

### `scripts/project/add_all_file.tcl`

**Mục đích**: Alias script để gọi `add_all_files.tcl`

**Cách dùng**:
```tcl
source scripts/project/add_all_file.tcl
```

## Batch Files

Tất cả batch files nằm trong thư mục `batch/` để dễ quản lý:

- `batch/compile_riscv.bat` - Compile SERV RISC-V system
- `batch/compile_and_run_riscv.bat` - Compile và chạy simulation
- `batch/run_riscv.bat` - Chạy RISC-V testbench
- `batch/run_riscv_sim.bat` - Chạy simulation (đã compile)
- `batch/run_dual_master_ip_test.bat` - Chạy dual master IP testbench
- `batch/run_wrapper_test.bat` - Chạy wrapper testbench

**Cách dùng batch files**:
```batch
# Từ thư mục sim/modelsim
cd D:\AXI\sim\modelsim
batch\compile_riscv.bat
```

**Hoặc từ bất kỳ đâu**:
```batch
D:\AXI\sim\modelsim\batch\compile_riscv.bat
```

## Workflow Đề Xuất

### Lần Đầu Setup

1. Mở ModelSim GUI
2. Chạy `scripts/project/add_files_auto.tcl` để tạo project và thêm files
3. Compile: `batch\compile_riscv.bat`
4. Chạy test: `batch\run_riscv.bat`

### Hàng Ngày

1. **Compile**:
   ```batch
   batch\compile_riscv.bat
   ```

2. **Chạy Simulation**:
   ```batch
   batch\run_riscv_sim.bat
   ```

3. **Hoặc compile và chạy cùng lúc**:
   ```batch
   batch\compile_and_run_riscv.bat
   ```

### Khi Có File Mới

1. Mở ModelSim project
2. Chạy `scripts/project/add_all_files.tcl` để thêm file mới
3. Compile lại

## Path Resolution

Tất cả scripts sử dụng `[info script]` để tự động tính toán path, nên chúng hoạt động đúng dù bạn chạy từ đâu:

```tcl
# Script tự động tính:
# - Script directory: sim/modelsim/scripts/compile/
# - Project root: AXI root (lên 2 cấp)
# - Source paths: relative từ project root
```

## Troubleshooting

### Lỗi: "Project not found"
- Mở project trước: `project open AXI_Project`
- Hoặc chạy `scripts/project/add_files_auto.tcl`

### Lỗi: "File not found"
- Kiểm tra path calculation trong script
- Đảm bảo đang chạy từ đúng thư mục
- Scripts tự động tính path từ `[info script]`, nên thường không có vấn đề

### Lỗi: "Design unit not found"
- Compile dependencies trước
- Chạy `batch\compile_riscv.bat` để compile tất cả

### Batch file không tìm thấy script
- Đảm bảo batch file đang ở trong `batch/`
- Batch files tự động di chuyển lên 1 cấp để tìm scripts

## Lưu Ý

- Tất cả scripts tự động tính path từ `[info script]`
- Batch files tự động di chuyển vào thư mục modelsim
- Scripts có thể chạy từ bất kỳ đâu, không cần cd vào thư mục cụ thể
- Project files (`.mpf`) nằm ở `sim/modelsim/`
- Work library nằm ở `sim/modelsim/work/`
