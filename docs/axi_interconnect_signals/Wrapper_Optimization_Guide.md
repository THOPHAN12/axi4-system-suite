# Hướng Dẫn Tối Ưu Wrapper để Giảm I/O Pins

## Vấn Đề

Design yêu cầu **1,291 I/O pins** nhưng các device Cyclone II chỉ có:
- EP2C35F672C6: 470 pins
- EP2C50F672C6: 445 pins  
- EP2C70F672C6: Cần kiểm tra (nhiều nhất nhưng có thể vẫn không đủ)

**Thiếu ít nhất 846 pins** → Cần tối ưu wrapper để giảm I/O requirements.

---

## Phân Tích I/O Pins Hiện Tại

### Clock và Reset Signals (14 pins)
Wrapper hiện tại expose:
- `ACLK` (1 pin) - Global clock
- `ARESETN` (1 pin) - Global reset
- `S00_ACLK` (1 pin) - Master 0 clock
- `S00_ARESETN` (1 pin) - Master 0 reset
- `S01_ACLK` (1 pin) - Master 1 clock
- `S01_ARESETN` (1 pin) - Master 1 reset
- `M00_ACLK` (1 pin) - Slave 0 clock
- `M00_ARESETN` (1 pin) - Slave 0 reset
- `M01_ACLK` (1 pin) - Slave 1 clock
- `M01_ARESETN` (1 pin) - Slave 1 reset
- `M02_ACLK` (1 pin) - Slave 2 clock
- `M02_ARESETN` (1 pin) - Slave 2 reset
- `M03_ACLK` (1 pin) - Slave 3 clock
- `M03_ARESETN` (1 pin) - Slave 3 reset

**Tổng: 14 pins cho clock/reset**

### Tối Ưu: Sử Dụng Cùng Clock/Reset
- Chỉ cần `ACLK` và `ARESETN` (2 pins)
- **Tiết kiệm: 12 pins**

---

## Giải Pháp Tối Ưu

### 1. Loại Bỏ Clock/Reset Riêng Biệt

**Thay đổi trong `axi_interconnect_2m4s_wrapper.v`:**

#### A. Loại bỏ khỏi port list:
```verilog
// XÓA các dòng này:
input  wire                    S00_ACLK,
input  wire                    S00_ARESETN,
input  wire                    S01_ACLK,
input  wire                    S01_ARESETN,
input  wire                    M00_ACLK,
input  wire                    M00_ARESETN,
input  wire                    M01_ACLK,
input  wire                    M01_ARESETN,
input  wire                    M02_ACLK,
input  wire                    M02_ARESETN,
input  wire                    M03_ACLK,
input  wire                    M03_ARESETN,
```

#### B. Kết nối tất cả với global clock/reset:
```verilog
// Trong instantiation của AXI_Interconnect_Full:
.S00_ACLK                 (ACLK),      // Thay vì S00_ACLK
.S00_ARESETN             (ARESETN),   // Thay vì S00_ARESETN
.S01_ACLK                 (ACLK),      // Thay vì S01_ACLK
.S01_ARESETN             (ARESETN),   // Thay vì S01_ARESETN
.M00_ACLK                 (ACLK),      // Thay vì M00_ACLK
.M00_ARESETN             (ARESETN),   // Thay vì M00_ARESETN
.M01_ACLK                 (ACLK),      // Thay vì M01_ACLK
.M01_ARESETN             (ARESETN),   // Thay vì M01_ARESETN
.M02_ACLK                 (ACLK),      // Thay vì M02_ACLK
.M02_ARESETN             (ARESETN),   // Thay vì M02_ARESETN
.M03_ACLK                 (ACLK),      // Thay vì M03_ACLK
.M03_ARESETN             (ARESETN),   // Thay vì M03_ARESETN
```

**Tiết kiệm: 12 pins**

---

### 2. Loại Bỏ Unused Write Channels (Nếu Không Dùng)

Nếu S01 write channels không được sử dụng (đã bị stuck at GND), có thể loại bỏ:

**Loại bỏ khỏi port list:**
- Tất cả `S01_AXI_aw*` signals (Write Address Channel)
- Tất cả `S01_AXI_w*` signals (Write Data Channel)
- Tất cả `S01_AXI_b*` signals (Write Response Channel)

**Tiết kiệm: ~50 pins** (tùy thuộc vào số lượng signals)

---

### 3. Loại Bỏ Signals Bị Stuck at GND

Các signals sau đang bị stuck at GND (theo warning):
- `S01_AXI_awready`
- `S01_AXI_wready`
- `M00_AXI_awaddr_ID[0]`
- `M00_AXI_awaddr[30:31]`
- `M00_AXI_araddr[30:31]`
- `M01_AXI_awaddr_ID[0]`
- `M01_AXI_awaddr[31]`
- `M01_AXI_araddr[31]`
- `M02_AXI_araddr[30]`

**Có thể loại bỏ hoặc tie-off internally**

---

## Ước Tính Tiết Kiệm

### Tối Ưu Tối Thiểu (Chỉ Clock/Reset):
- **Tiết kiệm**: 12 pins
- **I/O còn lại**: ~1,279 pins
- **Vẫn có thể không đủ** nếu EP2C70F672C6 < 1,279 pins

### Tối Ưu Tối Đa (Clock/Reset + Unused Write Channels):
- **Tiết kiệm**: ~62 pins (12 + 50)
- **I/O còn lại**: ~1,229 pins
- **Có thể đủ** nếu EP2C70F672C6 >= 1,229 pins

---

## Các Bước Thực Hiện

### Bước 1: Backup File Hiện Tại
```bash
cp axi_interconnect_2m4s_wrapper.v axi_interconnect_2m4s_wrapper.v.backup
```

### Bước 2: Sửa Port List
- Loại bỏ các clock/reset riêng biệt
- (Tùy chọn) Loại bỏ unused write channels

### Bước 3: Sửa Instantiation
- Kết nối tất cả clock/reset với global ACLK/ARESETN

### Bước 4: Re-run Synthesis và Fitter
- Kiểm tra kết quả
- Verify functionality

---

## Lưu Ý

### Clock Domain
- Nếu các interfaces cần clock khác nhau, không thể tối ưu theo cách này
- Trong trường hợp này, cần sử dụng clock domain crossing (CDC)

### Reset Domain
- Tương tự, nếu cần reset khác nhau, không thể tối ưu
- Có thể sử dụng reset synchronizer nếu cần

### AXI Protocol
- AXI protocol cho phép các interfaces có clock khác nhau
- Nhưng trong nhiều trường hợp, cùng clock là đủ và đơn giản hơn

---

## Kết Quả Mong Đợi

Sau khi tối ưu:
- ✅ **Giảm I/O pins**: 12-62 pins
- ✅ **Fitter có thể thành công**: Nếu device có đủ pins
- ✅ **Functionality không thay đổi**: Nếu tất cả interfaces dùng cùng clock/reset

---

## Date
- **Date**: 2025-11-24
- **Created By**: Auto (AI Assistant)
- **Purpose**: Guide for optimizing wrapper to reduce I/O pin requirements

