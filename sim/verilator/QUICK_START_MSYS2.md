# Quick Start Guide - MSYS2 Bash Terminal

## Bạn đang ở MSYS2 MinGW64 terminal (bash)

### Cách 1: Sử dụng bash scripts (Khuyến nghị)

```bash
# Chuyển đến thư mục project (sử dụng đường dẫn Windows)
cd /c/Users/Nguyen\ Ha\ Hai/axi4-system-suite/sim/verilator

# Hoặc nếu bạn đã ở trong project:
cd sim/verilator

# Cài đặt Verilator (nếu chưa có)
pacman -S mingw-w64-x86_64-verilator

# Chạy setup
chmod +x *.sh
./setup_verilator.sh

# Compile
./compile_verilator.sh

# Run simulation
./run_simulation.sh
```

### Cách 2: Sử dụng helper script

```bash
# Chuyển đến thư mục project
cd /c/Users/Nguyen\ Ha\ Hai/axi4-system-suite/sim/verilator

# Chạy helper script (tự động cài đặt và chạy tất cả)
chmod +x run_in_msys2.sh
./run_in_msys2.sh
```

### Cách 3: Sử dụng PowerShell (từ Windows PowerShell, không phải MSYS2)

Mở **Windows PowerShell** (không phải MSYS2 terminal) và chạy:

```powershell
cd "C:\Users\Nguyen Ha Hai\axi4-system-suite\sim\verilator"
.\compile_verilator.ps1
.\run_simulation.ps1
```

## Lưu ý

- **MSYS2 bash** sử dụng đường dẫn Unix-style: `/c/Users/...`
- **PowerShell** sử dụng đường dẫn Windows-style: `C:\Users\...`
- `.ps1` files chỉ chạy trong PowerShell
- `.sh` files chỉ chạy trong bash/MSYS2

## Troubleshooting

### Lỗi: "No such file or directory"
- Kiểm tra đường dẫn: sử dụng `/c/` thay vì `C:\` trong MSYS2
- Kiểm tra khoảng trắng: dùng dấu `\` để escape: `Nguyen\ Ha\ Hai`

### Lỗi: "command not found"
- Đảm bảo đã `chmod +x *.sh` để làm scripts có thể thực thi
- Kiểm tra Verilator đã được cài đặt: `verilator --version`


