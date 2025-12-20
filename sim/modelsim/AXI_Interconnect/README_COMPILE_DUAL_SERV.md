# Hướng dẫn Compile dual_serv_axi_system.v trên ModelSim GUI

## Cách 1: Sử dụng Script TCL (Khuyến nghị)

1. Mở ModelSim GUI
2. Mở project: `File -> Open -> AXI_Project.mpf`
3. Trong ModelSim TCL Console, gõ:
   ```
   source compile_dual_serv_gui.tcl
   ```

Script sẽ tự động:
- Set đúng include directories
- Compile file `dual_serv_axi_system.v`
- Hiển thị kết quả compile

## Cách 2: Compile thủ công từ GUI

1. Mở ModelSim GUI
2. Mở project: `File -> Open -> AXI_Project.mpf`
3. Right-click vào file `dual_serv_axi_system.v` trong Project window
4. Chọn `Properties`
5. Trong tab `Verilog`, thêm các Include directories:
   - `../../src`
   - `../../src/cores`
   - `../../src/cores/serv/rtl`
   - `../../src/axi_interconnect/rtl/core`
6. Click `OK`
7. Right-click vào file và chọn `Compile -> Compile Selected`

## Cách 3: Set Include Directories cho toàn bộ Project

1. Mở ModelSim GUI
2. Mở project: `File -> Open -> AXI_Project.mpf`
3. Vào `Project -> Project Settings`
4. Chọn tab `Verilog`
5. Trong phần "Include directories", thêm:
   - `../../src`
   - `../../src/cores`
   - `../../src/cores/serv/rtl`
   - `../../src/axi_interconnect/rtl/core`
6. Click `OK`
7. Compile file `dual_serv_axi_system.v`

## Kết quả

Sau khi compile thành công, bạn sẽ thấy:
- Top level module: `dual_serv_axi_system`
- Tất cả dependencies đã được compile

## Simulate

Để simulate design:
```
vsim work.dual_serv_axi_system
```



