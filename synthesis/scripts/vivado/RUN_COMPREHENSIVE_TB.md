# Hướng dẫn chạy Comprehensive Testbench trong Vivado

## Cách 1: Chạy từ Vivado GUI (Khuyến nghị)

1. **Mở Vivado**

2. **Mở project:**
   - File > Open Project
   - Chọn: `synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr`
   - Hoặc trong TCL Console:
     ```tcl
     open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr
     ```

3. **Chạy simulation:**
   
   **Option A: Sử dụng script đầy đủ (tự động mở project):**
   ```tcl
   source [file normalize "synthesis/scripts/vivado/run_comprehensive_tb.tcl"]
   ```
   
   **Option B: Nếu project đã mở, dùng script đơn giản:**
   ```tcl
   source [file normalize "synthesis/scripts/vivado/run_comprehensive_simple.tcl"]
   ```
   
   **Option C: Chạy trực tiếp từ thư mục script:**
   - Trong TCL Console, chuyển đến thư mục script:
     ```tcl
     cd "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"
     source run_comprehensive_tb.tcl
     ```

## Cách 2: Chạy từ Command Line (Batch Mode)

### Windows PowerShell:
```powershell
cd "C:\Users\Nguyen Ha Hai\axi4-system-suite"
vivado -mode batch -source synthesis/scripts/vivado/run_comprehensive_tb.tcl
```

### Hoặc nếu Vivado không trong PATH:
```powershell
cd "C:\Users\Nguyen Ha Hai\axi4-system-suite"
& "C:\Xilinx\Vivado\2023.2\bin\vivado.bat" -mode batch -source synthesis/scripts/vivado/run_comprehensive_tb.tcl
```

## Kết quả mong đợi

Sau khi chạy simulation, bạn sẽ thấy:
- Tất cả 10 test cases PASS (100% pass rate)
- M1 hoàn thành đúng cách (không còn timeout)
- Write Address, Write Data, và Write Response channels hoạt động đúng
- Simulation sẽ tự động kết thúc với `$finish`

## Lưu ý

- ModelSim đã chạy thành công với tất cả test cases PASS
- Các sửa đổi đã được áp dụng để fix M1 timeout issue
- Vivado nên chạy tương tự như ModelSim vì cùng SystemVerilog code
- Nếu gặp lỗi về đường dẫn, sử dụng `[file normalize ...]` trong TCL

## Troubleshooting

**Lỗi: "no such file or directory"**
- Đảm bảo bạn đang ở đúng thư mục hoặc sử dụng đường dẫn tuyệt đối
- Sử dụng: `source [file normalize "synthesis/scripts/vivado/run_comprehensive_tb.tcl"]`

**Lỗi: "No project is currently open"**
- Mở project trước: `open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr`
- Hoặc sử dụng `run_comprehensive_tb.tcl` (script sẽ tự động mở project)
