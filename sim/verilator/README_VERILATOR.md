# Verilator Simulation Guide

## Tổng Quan

Verilator là một bộ compiler mã nguồn mở, chuyển đổi Verilog/SystemVerilog thành C++ để simulation nhanh hơn 10-100x so với ModelSim interpreted mode.

## Yêu Cầu

### Windows
1. **MSYS2** (khuyến nghị) hoặc **MinGW-w64**
   - Download từ: https://www.msys2.org/
   - Cài đặt Verilator: `pacman -S verilator`
   - Cài đặt build tools: `pacman -S mingw-w64-x86_64-gcc make`

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install verilator build-essential
```

### macOS
```bash
brew install verilator
```

## Cài Đặt

### Bước 1: Kiểm tra cài đặt
```powershell
# Windows PowerShell
cd sim\verilator
.\setup_verilator.ps1
```

```bash
# Linux/macOS
cd sim/verilator
chmod +x setup_verilator.sh
./setup_verilator.sh
```

### Bước 2: Compile design
```powershell
# Windows PowerShell
.\compile_verilator.ps1
```

```bash
# Linux/macOS
chmod +x compile_verilator.sh
./compile_verilator.sh
```

### Bước 3: Chạy simulation
```powershell
# Windows PowerShell
.\run_simulation.ps1
```

```bash
# Linux/macOS
chmod +x run_simulation.sh
./run_simulation.sh
```

## Tùy Chỉnh

### Thay đổi test program
```powershell
# Windows
$env:TEST_PROGRAM="my_test.hex"
.\compile_verilator.ps1
```

```bash
# Linux/macOS
export TEST_PROGRAM="my_test.hex"
./compile_verilator.sh
```

### Thay đổi simulation time
Chỉnh sửa `SIM_TIMEOUT` trong testbench:
```verilog
parameter SIM_TIMEOUT = 20000;  // Số cycles
```

## So Sánh Hiệu Năng

| Simulator | Speed | License | Waveform |
|-----------|-------|---------|----------|
| ModelSim (interpreted) | 1x | Commercial | Full support |
| Verilator | 10-100x | Open source | VCD only |
| ModelSim (compiled) | 5-10x | Commercial | Full support |

## Lưu Ý

1. **Verilator không hỗ trợ một số SystemVerilog features:**
   - `$dumpfile`, `$dumpvars` (dùng `--trace` thay thế)
   - Một số timing checks
   - X-propagation

2. **Waveform:**
   - Verilator tạo VCD file (Value Change Dump)
   - Có thể xem bằng GTKWave, ModelSim, hoặc các VCD viewer khác

3. **Debug:**
   - Verilator tốt cho regression testing và performance testing
   - ModelSim tốt hơn cho debugging chi tiết

## Troubleshooting

### Lỗi: "Verilator not found"
- Kiểm tra PATH environment variable
- Đảm bảo Verilator được cài đặt đúng

### Lỗi: "C++ compiler not found"
- Cài đặt g++ hoặc clang++
- Windows: Cài MinGW-w64 hoặc MSYS2

### Lỗi: "Make not found"
- Cài đặt Make
- Windows: Cài MSYS2 hoặc MinGW-w64

### Compilation errors
- Kiểm tra include paths trong `compile_verilator.ps1`
- Đảm bảo tất cả source files có thể truy cập được

## Tài Liệu Tham Khảo

- Verilator Documentation: https://verilator.org/guide/latest/
- Verilator GitHub: https://github.com/verilator/verilator


