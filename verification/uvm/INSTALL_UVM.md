# Hướng Dẫn Cài Đặt UVM cho ModelSim ALTERA

## Tổng Quan

UVM (Universal Verification Methodology) là một framework chuẩn cho verification trong SystemVerilog. ModelSim ALTERA 13.0 có thể không có UVM built-in, nên cần cài đặt riêng.

## Phương Pháp 1: Download UVM từ Accellera (Khuyến Nghị)

### Bước 1: Download UVM

1. Truy cập: http://www.accellera.org/downloads/standards/uvm
2. Download UVM 1.1d (tương thích với ModelSim 13.0)
3. Extract vào thư mục, ví dụ: `C:\uvm-1.1d`

### Bước 2: Compile UVM Library

Mở ModelSim và chạy các lệnh sau:

```tcl
# Tạo thư viện UVM
vlib uvm_lib

# Compile UVM source files
vlog -work uvm_lib +incdir+C:/uvm-1.1d/src C:/uvm-1.1d/src/uvm_pkg.sv

# Hoặc compile tất cả files
vlog -work uvm_lib +incdir+C:/uvm-1.1d/src C:/uvm-1.1d/src/*.sv
```

### Bước 3: Set Environment Variable

Trong Windows PowerShell hoặc Command Prompt:

```cmd
set UVM_HOME=C:\uvm-1.1d
```

Hoặc set permanently trong System Environment Variables.

### Bước 4: Update Makefile

Makefile đã được cấu hình để tự động tìm UVM. Nếu đã set `UVM_HOME`, nó sẽ tự động sử dụng.

## Phương Pháp 2: Sử dụng Questa Sim (Nếu có)

Questa Sim thường có UVM built-in:

```cmd
set UVM_HOME=C:\questasim\verilog_src\uvm-1.1d
```

## Phương Pháp 3: Kiểm tra ModelSim ALTERA Installation

Một số version có UVM trong:

```cmd
C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d
```

Chạy script để kiểm tra:
```cmd
cd verification\uvm
setup_uvm.bat
```

## Verify Installation

Sau khi cài đặt, test bằng cách compile một file UVM đơn giản:

```tcl
vlog -sv +incdir+$env(UVM_HOME)/src test_uvm.sv
```

Nếu compile thành công, UVM đã được cài đặt đúng.

## Troubleshooting

### Lỗi: "Cannot find uvm_pkg"

- Kiểm tra `UVM_HOME` đã được set chưa
- Kiểm tra path trong Makefile có đúng không
- Thử compile UVM library trước

### Lỗi: "UVM version mismatch"

- Đảm bảo sử dụng UVM 1.1d cho ModelSim 13.0
- Kiểm tra version trong `uvm_version.svh`

### Lỗi: "DPI functions not found"

- Cần compile UVM DPI library:
```tcl
vlog -work uvm_lib +incdir+$env(UVM_HOME)/src $env(UVM_HOME)/src/dpi/uvm_dpi.cc
```

## Alternative: Sử dụng Testbench Không UVM

Nếu không thể cài UVM, có thể sử dụng testbench đơn giản:

```bash
cd verification\uvm
make run  # Sử dụng axi_interconnect_simple_tb.sv
```

Testbench này không cần UVM và vẫn có thể test đầy đủ chức năng của AXI Interconnect.

## Tài Liệu Tham Khảo

- UVM User Guide: http://www.accellera.org/images/downloads/standards/uvm/UVM_Users_Guide_1.1.pdf
- UVM Reference: http://www.accellera.org/downloads/standards/uvm

