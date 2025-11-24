# UVM Setup Guide

## Vấn Đề

ModelSim ALTERA 13.0 có thể không có UVM library built-in. Cần cài đặt UVM riêng.

## Giải Pháp

### Option 1: Download UVM Library (Windows & Linux)

1. Download UVM 1.1d từ: http://www.accellera.org/downloads/standards/uvm
2. Extract vào thư mục:
   - Windows: `C:\uvm-1.1d`
   - Linux: `/opt/uvm-1.1d` (hoặc `$HOME/uvm-1.1d`)
3. Set environment variable:
   - **Windows (PowerShell/CMD)**
     ```cmd
     set UVM_HOME=C:\uvm-1.1d
     ```
   - **Linux/macOS**
     ```bash
     export UVM_HOME=/opt/uvm-1.1d
     ```

### Option 2: Sử dụng Questa Sim (nếu có)

Questa Sim thường có UVM built-in. Chỉ cần set UVM_HOME:
```cmd
set UVM_HOME=C:\questasim\verilog_src\uvm-1.1d
```

### Option 3: Kiểm tra ModelSim ALTERA / Questa Install

Một số version ModelSim ALTERA/Questa đã có sẵn:
- Windows: `C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d`
- Linux: `/opt/intelFPGA_lite/13.0/modelsim_ase/verilog_src/uvm-1.1d`
- Nếu đã cài Questa, kiểm tra `$QUESTA_HOME/verilog_src/uvm-1.1d`

Scripts hỗ trợ tự động tìm:
- Windows:
  ```cmd
  setup_uvm.bat
  ```
- Linux/macOS:
  ```bash
  chmod +x setup_uvm.sh
  ./setup_uvm.sh
  ```

## Sau Khi Setup UVM

1. Set UVM_HOME trong shell hiện tại (ví dụ `set` hoặc `export`)

2. Compile và run test:
   - Windows:
     ```cmd
     make compile
     make run
     ```
   - Linux/macOS:
     ```bash
     make compile
     make run
     ```

## Alternative: Simplified Testbench (Không dùng UVM)

Nếu không có UVM, có thể tạo testbench đơn giản hơn không dùng UVM để test basic functionality.

