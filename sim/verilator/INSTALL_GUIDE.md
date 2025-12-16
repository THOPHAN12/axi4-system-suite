# Hướng Dẫn Cài Đặt Verilator trên Windows với MSYS2

## Cài Đặt Thủ Công (Khuyến Nghị)

1. **Mở MSYS2 MinGW 64-bit terminal:**
   - Tìm "MSYS2 MinGW 64-bit" trong Start Menu
   - Hoặc chạy: `C:\msys64\mingw64.exe`

2. **Cài đặt Verilator:**
   ```bash
   pacman -S mingw-w64-x86_64-verilator
   ```
   - Nhấn `Y` khi được hỏi

3. **Kiểm tra cài đặt:**
   ```bash
   verilator --version
   ```

4. **Thêm vào PATH (tùy chọn):**
   - Thêm `C:\msys64\mingw64\bin` vào System PATH
   - Hoặc sử dụng script đã được cập nhật (tự động thêm PATH)

## Sử Dụng Scripts

Sau khi cài đặt Verilator:

```powershell
cd sim\verilator
.\compile_verilator.ps1
.\run_simulation.ps1
```

## Troubleshooting

### Verilator không tìm thấy
- Đảm bảo đã cài đặt trong MSYS2 MinGW 64-bit terminal (không phải MSYS terminal)
- Kiểm tra: `C:\msys64\mingw64\bin\verilator.exe` có tồn tại không

### Lỗi compile
- Đảm bảo đã cài đặt gcc: `pacman -S mingw-w64-x86_64-gcc`
- Đảm bảo đã cài đặt make: `pacman -S make`

### Lỗi PATH
- Scripts đã được cập nhật để tự động thêm MSYS2 vào PATH
- Nếu vẫn lỗi, thêm thủ công: `C:\msys64\mingw64\bin` vào System PATH


