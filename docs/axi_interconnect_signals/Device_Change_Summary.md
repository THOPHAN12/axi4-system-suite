# Tóm Tắt Thay Đổi Device

## Thay Đổi Đã Thực Hiện

### Device Configuration
- **Device Cũ**: EP2C35F672C6 (Cyclone II)
- **Device Mới**: EP2C50F672C6 (Cyclone II)
- **File Đã Sửa**: `D:\AXI\sim\quartus\AXI_PROJECT.qsf`

### Lý Do Thay Đổi

**Vấn đề:**
- Design yêu cầu **1,291 I/O pins**
- EP2C35F672C6 chỉ có **470 pins khả dụng** cho 3.3-V LVTTL I/O standard
- **Thiếu 823 pins** → Không thể fit design

**Giải pháp:**
- Thay đổi sang **EP2C50F672C6** - device lớn hơn với nhiều I/O pins hơn
- Device này đã được Quartus đề xuất là **compatible** với design

---

## Thông Tin Device

### EP2C35F672C6 (Device Cũ)
- **Family**: Cyclone II
- **Package**: FBGA 672 pins
- **Available I/O Pins (3.3-V LVTTL)**: 470
- **Status**: ❌ Không đủ I/O pins

### EP2C50F672C6 (Device Đã Thử)
- **Family**: Cyclone II
- **Package**: FBGA 672 pins (cùng package)
- **Available I/O Pins (3.3-V LVTTL)**: 445 pins
- **Status**: ❌ Vẫn không đủ I/O pins (thiếu 846 pins)

### EP2C70F672C6 (Device Hiện Tại)
- **Family**: Cyclone II
- **Package**: FBGA 672 pins (cùng package)
- **Available I/O Pins**: Nhiều nhất trong dòng Cyclone II
- **Status**: ⏳ Đang thử - Cần kiểm tra kết quả fitter

### EP2C70F672C6 (Alternative)
- **Family**: Cyclone II
- **Package**: FBGA 672 pins
- **Available I/O Pins**: Nhiều nhất trong dòng Cyclone II
- **Status**: ✅ Được Quartus đề xuất là compatible

---

## Các Bước Tiếp Theo

### 1. Re-run Synthesis và Fitter
```bash
# Trong Quartus II
# 1. Mở project AXI_PROJECT
# 2. Chạy Analysis & Synthesis
# 3. Chạy Fitter
# 4. Kiểm tra kết quả
```

### 2. Kiểm Tra Resource Usage
Sau khi fit thành công, kiểm tra:
- **Logic Cells**: Có đủ không?
- **I/O Pins**: Có đủ không?
- **Memory Blocks**: Có đủ không?

### 3. Tạo Pin Assignment File (Nếu Cần)
Nếu cần assign pins cụ thể:
- Tạo file `.qsf` với pin assignments
- Hoặc sử dụng Pin Planner trong Quartus II

### 4. Verify Design
- Kiểm tra timing constraints
- Kiểm tra resource utilization
- Verify functionality

---

## Lưu Ý

### Package Compatibility
- EP2C35F672C6, EP2C50F672C6, và EP2C70F672C6 đều dùng **cùng package FBGA 672 pins**
- **Pinout có thể khác nhau** giữa các device
- Cần kiểm tra pin compatibility nếu đã có board design

### Migration Path
Nếu EP2C50F672C6 vẫn không đủ:
1. Thử **EP2C70F672C6** (device lớn nhất)
2. Hoặc **tối ưu wrapper** để giảm I/O requirements:
   - Loại bỏ unused signals
   - Sử dụng internal signals thay vì external pins
   - Chỉ expose các signals cần thiết

---

## File Đã Thay Đổi

### `D:\AXI\sim\quartus\AXI_PROJECT.qsf`
**Line 40:**
```tcl
# Cũ:
set_global_assignment -name DEVICE EP2C35F672C6

# Mới:
set_global_assignment -name DEVICE EP2C50F672C6
```

---

## Kết Quả Mong Đợi

Sau khi thay đổi device và re-run fitter:
- ✅ **Fitter thành công**: Design có thể fit vào EP2C50F672C6
- ✅ **I/O pins đủ**: Không còn lỗi về pin placement
- ⚠️ **Có thể có warnings**: Một số warnings có thể vẫn còn (unused signals, etc.)

---

## Troubleshooting

### Nếu Vẫn Còn Lỗi Pin Placement

**Option 1: ✅ Đã Thử EP2C70F672C6**
- Device hiện tại: EP2C70F672C6
- Nếu vẫn không đủ, cần tối ưu wrapper

**Option 2: Tối Ưu Wrapper (Khuyến Nghị)**
- **Vấn đề**: Wrapper đang expose 6 cặp clock/reset riêng biệt:
  - S00_ACLK, S00_ARESETN
  - S01_ACLK, S01_ARESETN
  - M00_ACLK, M00_ARESETN
  - M01_ACLK, M01_ARESETN
  - M02_ACLK, M02_ARESETN
  - M03_ACLK, M03_ARESETN
- **Giải pháp**: Sử dụng global ACLK và ARESETN cho tất cả interfaces
- **Tiết kiệm**: 12 I/O pins (6 cặp clock/reset)
- **Cách thực hiện**: 
  - Loại bỏ các clock/reset riêng biệt khỏi port list
  - Kết nối tất cả interfaces với global ACLK và ARESETN
  - Xem file `axi_interconnect_2m4s_wrapper.v` để sửa

**Option 3: Loại Bỏ Unused Signals**
- Loại bỏ các write channels của S01 nếu không sử dụng
- Loại bỏ các signals bị stuck at GND
- Sử dụng internal signals cho các connections nội bộ

**Option 4: Thay Đổi I/O Standard**
- Thử I/O standard khác nếu có thể
- Kiểm tra board requirements

---

## Tài Liệu Tham Khảo

- **Quartus Warnings Analysis**: `D:\AXI\docs\axi_interconnect_signals\Quartus_Warnings_Analysis.md`
- **AXI Interconnect Signals**: `D:\AXI\docs\axi_interconnect_signals\README.md`
- **Wrapper Module**: `D:\AXI\src\wrapper\systems\axi_interconnect_2m4s_wrapper.v`

---

## Date
- **Date**: 2025-11-24
- **Changed By**: Auto (AI Assistant)
- **Reason**: Fix Fitter pin placement errors

