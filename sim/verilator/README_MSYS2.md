# Hướng Dẫn Sử Dụng Verilator trong MSYS2 Bash Terminal

## Vấn Đề

Bạn đang ở trong **MSYS2 MinGW64 terminal (bash)**, không phải PowerShell. Do đó:
- ❌ Không thể chạy `.ps1` files (PowerShell scripts)
- ✅ Cần sử dụng `.sh` files (bash scripts)

## Giải Pháp

### Bước 1: Chuyển đến thư mục đúng

Trong MSYS2 bash, sử dụng đường dẫn Unix-style:

```bash
# Cách 1: Từ home directory
cd /c/Users/Nguyen\ Ha\ Hai/axi4-system-suite/sim/verilator

# Cách 2: Nếu bạn đã ở trong project root
cd sim/verilator

# Cách 3: Sử dụng đường dẫn tuyệt đối (thay đổi theo user của bạn)
cd "/c/Users/Nguyen Ha Hai/axi4-system-suite/sim/verilator"
```

**Lưu ý:** 
- Sử dụng `/c/` thay vì `C:\`
- Escape khoảng trắng bằng `\` hoặc dùng dấu ngoặc kép `"`

### Bước 2: Cài đặt Verilator (nếu chưa có)

```bash
pacman -S mingw-w64-x86_64-verilator
```

Nhấn `Y` khi được hỏi.

### Bước 3: Chạy scripts

```bash
# Làm scripts có thể thực thi
chmod +x *.sh

# Chạy setup (kiểm tra cài đặt)
./setup_verilator.sh

# Compile
./compile_verilator.sh

# Run simulation
./run_simulation.sh
```

### Hoặc sử dụng helper script (tự động làm tất cả):

```bash
chmod +x run_in_msys2.sh
./run_in_msys2.sh
```

## So Sánh: MSYS2 Bash vs PowerShell

| Feature | MSYS2 Bash | PowerShell |
|---------|------------|------------|
| Đường dẫn | `/c/Users/...` | `C:\Users\...` |
| Scripts | `.sh` files | `.ps1` files |
| Chạy script | `./script.sh` | `.\script.ps1` |
| Escape spaces | `\ ` hoặc `"..."` | `"..."` |

## Troubleshooting

### Lỗi: "No such file or directory"
```bash
# Kiểm tra bạn đang ở đâu
pwd

# Kiểm tra file có tồn tại không
ls -la

# Chuyển đến đúng thư mục
cd /c/Users/Nguyen\ Ha\ Hai/axi4-system-suite/sim/verilator
```

### Lỗi: "command not found: verilator"
```bash
# Cài đặt Verilator
pacman -S mingw-w64-x86_64-verilator

# Kiểm tra đã cài đặt
verilator --version
```

### Lỗi: "Permission denied"
```bash
# Làm scripts có thể thực thi
chmod +x *.sh
```

## Ví Dụ Đầy Đủ

```bash
# 1. Chuyển đến thư mục
cd /c/Users/Nguyen\ Ha\ Hai/axi4-system-suite/sim/verilator

# 2. Kiểm tra Verilator
verilator --version

# 3. Nếu chưa có, cài đặt
pacman -S mingw-w64-x86_64-verilator

# 4. Làm scripts executable
chmod +x *.sh

# 5. Chạy
./setup_verilator.sh
./compile_verilator.sh
./run_simulation.sh
```


