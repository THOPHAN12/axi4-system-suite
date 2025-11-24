# UVM Setup Guide

## Vấn Đề

ModelSim ALTERA 13.0 có thể không có UVM library built-in. Cần cài đặt UVM riêng.

## Giải Pháp

### Option 1: Download UVM Library

1. Download UVM 1.1d từ: http://www.accellera.org/downloads/standards/uvm
2. Extract vào thư mục, ví dụ: `C:\uvm-1.1d`
3. Set environment variable:
   ```cmd
   set UVM_HOME=C:\uvm-1.1d
   ```

### Option 2: Sử dụng Questa Sim (nếu có)

Questa Sim thường có UVM built-in. Chỉ cần set UVM_HOME:
```cmd
set UVM_HOME=C:\questasim\verilog_src\uvm-1.1d
```

### Option 3: Kiểm tra ModelSim ALTERA

Một số version ModelSim ALTERA có UVM trong:
- `C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d`
- `C:\altera\13.0sp1\modelsim_ase\uvm-1.1d`

Chạy script để tìm:
```cmd
setup_uvm.bat
```

## Sau Khi Setup UVM

1. Set UVM_HOME:
   ```cmd
   set UVM_HOME=C:\path\to\uvm-1.1d
   ```

2. Compile và run test:
   ```cmd
   make compile
   make run
   ```

## Alternative: Simplified Testbench (Không dùng UVM)

Nếu không có UVM, có thể tạo testbench đơn giản hơn không dùng UVM để test basic functionality.

