# Hướng dẫn chạy Simulation trong Vivado GUI

## Bước 1: Mở Project

1. Mở Vivado
2. File > Open Project
3. Chọn: `synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr`
4. Hoặc trong TCL Console:
   ```tcl
   open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr
   ```

## Bước 2: Kiểm tra và Set Top Module

1. Trong **Flow Navigator** (bên trái), mở rộng **Simulation**
2. Click chuột phải vào **sim_1** > **Simulation Settings...**
3. Trong tab **General**:
   - **Top module name**: `comprehensive_system_tb`
   - **Simulation runtime**: `11000ns` (testbench có 10000ns timeout)
4. Click **OK**

Hoặc trong TCL Console:
```tcl
set_property top comprehensive_system_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {11000ns} -objects [get_filesets sim_1]
```

## Bước 3: Chạy Simulation

### Cách 1: Sử dụng nút Run Simulation
1. Trong **Flow Navigator**, click **Run Simulation** > **Run Behavioral Simulation**
2. Hoặc click nút **Run Simulation** trên thanh toolbar (biểu tượng play)

### Cách 2: Sử dụng TCL Console
```tcl
launch_simulation
run -all
```

## Bước 4: Xem kết quả

- **Transcript window**: Hiển thị log và kết quả test
- **Waveform window**: Hiển thị waveform (nếu cần)
- **TCL Console**: Có thể chạy các lệnh simulation

## Lưu ý

- Nếu simulation bị deadlock, nó sẽ tự động dừng sau 10000ns (timeout trong testbench)
- Kết quả test sẽ hiển thị trong Transcript window
- Để chạy lại, click **Restart** hoặc **Reload** trong simulation window
- Kết quả mong đợi: 21 test cases PASS (100% pass rate)

## Troubleshooting

**Lỗi: "Top module not found"**
- Đảm bảo `comprehensive_system_tb.sv` đã được thêm vào project
- Kiểm tra top module name đã đúng chưa

**Lỗi: "Simulation locked"**
- Đóng simulation hiện tại: `close_sim -force`
- Chạy lại simulation

**Simulation chạy mãi không dừng**
- Testbench có timeout 3000ns, sẽ tự động dừng
- Có thể dừng thủ công: Trong simulation window, click **Stop** hoặc gõ `stop` trong TCL Console

