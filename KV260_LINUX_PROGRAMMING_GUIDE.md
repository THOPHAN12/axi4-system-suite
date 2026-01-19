# 🚀 Hướng Dẫn Nạp Bitstream/XSA vào KV260 trên Linux 22.04 LTS

**Last Updated**: 2025-01-XX  
**Target**: Xilinx Kria KV260 Vision AI Starter Kit  
**OS**: Ubuntu 22.04 LTS  
**Status**: ✅ Complete Guide

---

## 📋 Mục Lục

1. [Tổng Quan](#tổng-quan)
2. [Chuẩn Bị](#chuẩn-bị)
3. [Phương Pháp 1: Sử dụng FPGA Manager (Khuyến nghị)](#phương-pháp-1-sử-dụng-fpga-manager-khuyến-nghị)
4. [Phương Pháp 2: Sử dụng fpgautil](#phương-pháp-2-sử-dụng-fpgautil)
5. [Phương Pháp 3: Sử dụng xmutil](#phương-pháp-3-sử-dụng-xmutil)
6. [Phương Pháp 4: Sử dụng JTAG qua Vivado (Fallback)](#phương-pháp-4-sử-dụng-jtag-qua-vivado-fallback)
7. [Troubleshooting](#troubleshooting)
8. [Verification & Testing](#verification--testing)

---

## 📋 Tổng Quan

Sau khi boot thành công Linux 22.04 LTS trên KV260, bạn có thể nạp bitstream vào FPGA (Programmable Logic) bằng nhiều phương pháp:

| Phương Pháp | Ưu Điểm | Nhược Điểm | Khuyến Nghị |
|-------------|---------|------------|-------------|
| **FPGA Manager** | Tự động, tích hợp sẵn | Cần quyền root | ⭐⭐⭐⭐⭐ |
| **fpgautil** | Đơn giản, dễ dùng | Cần cài đặt thêm | ⭐⭐⭐⭐ |
| **xmutil** | Quản lý applications | Phức tạp hơn | ⭐⭐⭐ |
| **JTAG (Vivado)** | Debug tốt | Cần cable, máy host | ⭐⭐ |

**Khuyến nghị**: Sử dụng **FPGA Manager** hoặc **fpgautil** cho việc nạp thông thường.

---

## 🔧 Chuẩn Bị

### Bước 1: Kiểm Tra Kết Nối

```bash
# SSH vào KV260 (từ máy host)
ssh xilinx@<KV260_IP_ADDRESS>
# Hoặc nếu đã kết nối trực tiếp qua serial/USB
```

**Kết quả kỳ vọng**:
```
Welcome to Ubuntu 22.04 LTS (GNU/Linux 5.15.0-xxx-generic aarch64)
xilinx@kria:~$
```

**Nếu gặp lỗi**:
- **"Connection refused"**: Kiểm tra SSH service: `sudo systemctl status ssh`
- **"Host unreachable"**: Kiểm tra IP address và network connection
- **"Permission denied"**: Kiểm tra username/password (mặc định: xilinx/xilinx)

### Bước 2: Kiểm Tra Hệ Thống

```bash
# Kiểm tra kernel version
uname -r

# Kiểm tra FPGA Manager có sẵn không
ls -l /sys/class/fpga_manager/

# Kiểm tra device tree overlay support
ls -l /configfs/device-tree/overlays/

# Kiểm tra fpgautil (nếu có)
which fpgautil
fpgautil --version

# Kiểm tra xmutil (nếu có)
which xmutil
xmutil --version
```

**Kết quả kỳ vọng**:
```
# Kernel version
5.15.0-xxx-generic

# FPGA Manager
/sys/class/fpga_manager/fpga0

# fpgautil (nếu đã cài)
/usr/bin/fpgautil
fpgautil version: 2022.1

# xmutil (nếu đã cài)
/usr/bin/xmutil
xmutil version: 2022.1
```

**Nếu thiếu tools**:
```bash
# Cài đặt fpgautil (nếu chưa có)
sudo apt update
sudo apt install -y fpgautil

# Hoặc cài đặt Kria SOM utilities
sudo apt install -y kria-apps-utils
```

### Bước 3: Chuẩn Bị Bitstream File

**Từ máy host (Windows/Linux với Vivado)**:

1. **Copy bitstream file** từ máy host sang KV260:

```bash
# Trên máy host (Windows PowerShell hoặc Linux)
scp "C:\Users\Nguyen Ha Hai\axi4-system-suite\synthesis\scripts\vivado\axi4_system_sv_kv260\axi4_system_sv_kv260.runs\impl_1\design_1_wrapper.bit" xilinx@<KV260_IP>:/home/xilinx/

# Hoặc nếu dùng XSA file
scp "C:\Users\Nguyen Ha Hai\axi4-system-suite\synthesis\scripts\vivado\axi4_system_sv_kv260\hardware_platform\design_1_wrapper.xsa" xilinx@<KV260_IP>:/home/xilinx/
```

**Trên KV260**:

```bash
# Kiểm tra file đã copy
ls -lh ~/design_1_wrapper.bit
ls -lh ~/design_1_wrapper.xsa

# Kiểm tra quyền truy cập
chmod 644 ~/design_1_wrapper.bit
```

**Kết quả kỳ vọng**:
```
-rw-r--r-- 1 xilinx xilinx 2.5M Jan XX XX:XX design_1_wrapper.bit
-rw-r--r-- 1 xilinx xilinx 5.2M Jan XX XX:XX design_1_wrapper.xsa
```

**Nếu gặp lỗi**:
- **"Permission denied"**: Kiểm tra quyền file: `chmod 644 <file>`
- **"No such file"**: Kiểm tra đường dẫn và tên file
- **"Connection timeout"**: Kiểm tra network và firewall

---

## 🔄 Phương Pháp 1: Sử dụng FPGA Manager (Khuyến nghị)

FPGA Manager là kernel driver tích hợp sẵn trong Linux kernel, cho phép nạp bitstream trực tiếp từ userspace.

### Bước 1: Kiểm Tra FPGA Manager

```bash
# Kiểm tra FPGA Manager có sẵn
ls -l /sys/class/fpga_manager/

# Kiểm tra trạng thái hiện tại
cat /sys/class/fpga_manager/fpga0/state
```

**Kết quả kỳ vọng**:
```
fpga0 -> ../../devices/platform/amba/fpga_manager0
state: operating hoặc idle
```

**Nếu không có**:
```bash
# Load FPGA Manager module (nếu chưa load)
sudo modprobe fpga_manager

# Kiểm tra lại
ls -l /sys/class/fpga_manager/
```

### Bước 2: Chuyển Đổi Bitstream sang Format .bin (Nếu Cần)

FPGA Manager yêu cầu file `.bin` (raw binary), không phải `.bit`. Nếu bạn có file `.bit`, cần chuyển đổi:

**Trên máy host (Windows với Vivado)**:

```tcl
# Trong Vivado TCL Console
write_cfgmem -format BIN -interface SMAPx32 -disablebitswap -loadbit "up 0x0 C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.runs/impl_1/design_1_wrapper.bit" design_1_wrapper.bin
```

**Hoặc sử dụng bootgen (nếu có)**:

```bash
# Trên máy host Linux
bootgen -image design_1_wrapper.bif -arch zynqmp -process_bitstream bin -w
```

**Hoặc copy trực tiếp file .bit (một số kernel version chấp nhận .bit)**:

```bash
# Trên KV260
cp ~/design_1_wrapper.bit ~/design_1_wrapper.bin
```

### Bước 3: Nạp Bitstream

```bash
# Chuyển sang thư mục chứa bitstream
cd ~

# Nạp bitstream vào FPGA
echo design_1_wrapper.bin > /sys/class/fpga_manager/fpga0/firmware
```

**Kết quả kỳ vọng**:
- Không có output (thành công)
- Kiểm tra trạng thái:

```bash
cat /sys/class/fpga_manager/fpga0/state
```

**Kết quả kỳ vọng**: `operating`

**Nếu gặp lỗi**:
- **"Permission denied"**: Cần quyền root: `sudo sh -c 'echo design_1_wrapper.bin > /sys/class/fpga_manager/fpga0/firmware'`
- **"No such file"**: Kiểm tra đường dẫn file
- **"Invalid format"**: Cần chuyển đổi sang .bin format

### Bước 4: Kiểm Tra Trạng Thái

```bash
# Kiểm tra trạng thái FPGA
cat /sys/class/fpga_manager/fpga0/state

# Kiểm tra device tree overlay (nếu có)
ls -l /configfs/device-tree/overlays/

# Kiểm tra AXI devices (nếu có)
ls -l /dev/ | grep axi
```

**Kết quả kỳ vọng**:
```
state: operating
```

---

## 🔄 Phương Pháp 2: Sử dụng fpgautil

`fpgautil` là utility tool được cung cấp bởi Xilinx để quản lý FPGA trên Kria SOM.

### Bước 1: Cài Đặt fpgautil (Nếu Chưa Có)

```bash
# Kiểm tra fpgautil
which fpgautil

# Nếu chưa có, cài đặt
sudo apt update
sudo apt install -y fpgautil

# Hoặc cài đặt Kria apps utilities
sudo apt install -y kria-apps-utils
```

**Kết quả kỳ vọng**:
```
/usr/bin/fpgautil
```

### Bước 2: Nạp Bitstream

```bash
# Nạp bitstream
sudo fpgautil -b design_1_wrapper.bit

# Hoặc với full path
sudo fpgautil -b /home/xilinx/design_1_wrapper.bit
```

**Kết quả kỳ vọng**:
```
Loading bitstream from design_1_wrapper.bit
Bitstream loaded successfully
FPGA is now configured
```

**Nếu gặp lỗi**:
- **"Command not found"**: Cài đặt fpgautil (xem Bước 1)
- **"Permission denied"**: Sử dụng `sudo`
- **"Invalid bitstream"**: Kiểm tra file bitstream có đúng cho KV260 không

### Bước 3: Kiểm Tra Trạng Thái

```bash
# Kiểm tra trạng thái
fpgautil -s

# Hoặc
cat /sys/class/fpga_manager/fpga0/state
```

**Kết quả kỳ vọng**:
```
FPGA State: operating
```

### Bước 4: Unload Bitstream (Nếu Cần)

```bash
# Unload bitstream
sudo fpgautil -r
```

**Kết quả kỳ vọng**:
```
Bitstream unloaded
FPGA is now idle
```

---

## 🔄 Phương Pháp 3: Sử dụng xmutil

`xmutil` là utility để quản lý applications và FPGA configurations trên Kria SOM.

### Bước 1: Cài Đặt xmutil (Nếu Chưa Có)

```bash
# Kiểm tra xmutil
which xmutil

# Nếu chưa có, cài đặt
sudo apt update
sudo apt install -y xmutil
```

### Bước 2: Tạo Application Package (Nếu Cần)

Nếu bạn muốn tạo một application package với bitstream:

```bash
# Tạo thư mục application
mkdir -p ~/my_app
cd ~/my_app

# Copy bitstream vào
cp ~/design_1_wrapper.bit ./app.bit

# Tạo metadata file (nếu cần)
cat > app.json << EOF
{
  "name": "AXI4 System",
  "version": "1.0.0",
  "description": "AXI4 Interconnect System"
}
EOF
```

### Bước 3: Load Application

```bash
# Load application
sudo xmutil loadapp my_app

# Hoặc load bitstream trực tiếp
sudo xmutil programfpga design_1_wrapper.bit
```

**Kết quả kỳ vọng**:
```
Application loaded successfully
FPGA configured
```

**Nếu gặp lỗi**:
- **"Command not found"**: Cài đặt xmutil
- **"Invalid application"**: Kiểm tra cấu trúc application package

---

## 🔄 Phương Pháp 4: Sử dụng JTAG qua Vivado (Fallback)

Nếu các phương pháp trên không hoạt động, bạn có thể sử dụng JTAG qua Vivado từ máy host.

### Bước 1: Kết Nối JTAG Cable

1. Kết nối JTAG cable (USB-JTAG) vào KV260
2. Kết nối cable vào máy host (Windows/Linux)

### Bước 2: Mở Vivado Hardware Manager

**Trên máy host**:

```bash
# Mở Vivado
vivado

# Hoặc mở Hardware Manager trực tiếp
vivado -mode batch -source program_kv260.tcl
```

### Bước 3: Program Device

**Trong Vivado TCL Console**:

```tcl
# Mở Hardware Manager
open_hw_manager

# Kết nối với target
connect_hw_server
open_hw_target

# Set bitstream file
set_property PROGRAM.FILE {C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.runs/impl_1/design_1_wrapper.bit} [get_hw_devices xck26_0]

# Program device
program_hw_devices [get_hw_devices xck26_0]
```

**Kết quả kỳ vọng**:
```
INFO: [Labtools 27-2265] Device xck26_0 programmed successfully
```

**Nếu gặp lỗi**:
- **"Device not found"**: Kiểm tra JTAG connection và driver
- **"Bitstream incompatible"**: Kiểm tra bitstream có đúng cho device không

---

## 🐛 Troubleshooting

### Lỗi 1: "Permission denied" khi nạp bitstream

**Nguyên nhân**: Cần quyền root để truy cập FPGA Manager

**Giải pháp**:
```bash
# Sử dụng sudo
sudo sh -c 'echo design_1_wrapper.bin > /sys/class/fpga_manager/fpga0/firmware'

# Hoặc thêm user vào group fpga (nếu có)
sudo usermod -aG fpga $USER
# Logout và login lại
```

### Lỗi 2: "No such file or directory" - FPGA Manager không tồn tại

**Nguyên nhân**: FPGA Manager module chưa được load

**Giải pháp**:
```bash
# Load module
sudo modprobe fpga_manager

# Kiểm tra lại
ls -l /sys/class/fpga_manager/

# Nếu vẫn không có, kiểm tra kernel config
zcat /proc/config.gz | grep FPGA_MANAGER
```

### Lỗi 3: "Invalid bitstream format"

**Nguyên nhân**: File .bit cần chuyển đổi sang .bin

**Giải pháp**:

**Cách 1: Sử dụng Vivado (trên máy host)**:
```tcl
# Trong Vivado TCL Console
write_cfgmem -format BIN -interface SMAPx32 -disablebitswap -loadbit "up 0x0 design_1_wrapper.bit" design_1_wrapper.bin
```

**Cách 2: Sử dụng bootgen**:
```bash
# Tạo .bif file
cat > design_1_wrapper.bif << EOF
all:
{
    design_1_wrapper.bit
}
EOF

# Convert
bootgen -image design_1_wrapper.bif -arch zynqmp -process_bitstream bin -w
```

**Cách 3: Copy trực tiếp (một số kernel version)**:
```bash
cp design_1_wrapper.bit design_1_wrapper.bin
```

### Lỗi 4: "FPGA state: unknown" hoặc "error"

**Nguyên nhân**: Bitstream không tương thích hoặc bị lỗi

**Giải pháp**:
```bash
# Kiểm tra bitstream file
file design_1_wrapper.bit

# Kiểm tra size (phải > 0)
ls -lh design_1_wrapper.bit

# Thử unload và load lại
sudo sh -c 'echo 0 > /sys/class/fpga_manager/fpga0/state'
sudo sh -c 'echo design_1_wrapper.bin > /sys/class/fpga_manager/fpga0/firmware'

# Kiểm tra dmesg logs
dmesg | tail -20
```

### Lỗi 5: "fpgautil: command not found"

**Nguyên nhân**: fpgautil chưa được cài đặt

**Giải pháp**:
```bash
# Cài đặt
sudo apt update
sudo apt install -y fpgautil

# Hoặc
sudo apt install -y kria-apps-utils
```

### Lỗi 6: Bitstream nạp thành công nhưng không hoạt động

**Nguyên nhân**: Có thể do:
- Device tree overlay chưa được load
- Clock chưa được enable
- Reset chưa được release

**Giải pháp**:
```bash
# Kiểm tra device tree overlays
ls -l /configfs/device-tree/overlays/

# Kiểm tra clock
cat /sys/kernel/debug/clk/pl_clk0/clk_rate

# Kiểm tra reset
cat /sys/class/fpga_manager/fpga0/state

# Kiểm tra dmesg
dmesg | grep -i fpga
```

### Lỗi 7: SSH connection timeout

**Nguyên nhân**: Network issue hoặc firewall

**Giải pháp**:
```bash
# Kiểm tra network
ping <KV260_IP>

# Kiểm tra SSH service
sudo systemctl status ssh

# Kiểm tra firewall
sudo ufw status

# Nếu cần, mở port SSH
sudo ufw allow 22/tcp
```

### Lỗi 8: "Device tree overlay failed"

**Nguyên nhân**: Device tree overlay không tương thích

**Giải pháp**:
```bash
# Kiểm tra overlay status
cat /configfs/device-tree/overlays/<overlay_name>/status

# Nếu failed, xem logs
dmesg | grep -i overlay

# Unload overlay
rmdir /configfs/device-tree/overlays/<overlay_name>
```

---

## ✅ Verification & Testing

### Bước 1: Kiểm Tra FPGA State

```bash
# Kiểm tra trạng thái
cat /sys/class/fpga_manager/fpga0/state

# Kết quả kỳ vọng: "operating"
```

### Bước 2: Kiểm Tra AXI Devices (Nếu Có)

```bash
# Kiểm tra AXI devices
ls -l /dev/ | grep axi

# Kiểm tra memory mapped devices
cat /proc/iomem | grep -i axi
```

### Bước 3: Kiểm Tra Clock

```bash
# Kiểm tra clock frequency
cat /sys/kernel/debug/clk/pl_clk0/clk_rate

# Kết quả kỳ vọng: 100000000 (100 MHz) hoặc giá trị đã config
```

### Bước 4: Test AXI Interconnect (Nếu Có Test Application)

```bash
# Nếu có test application
./test_axi_interconnect

# Hoặc sử dụng devmem để đọc/ghi register
sudo apt install -y devmem2

# Đọc từ address 0x00000000 (S0 - BRAM)
sudo devmem2 0x00000000

# Ghi vào address 0x00000000
sudo devmem2 0x00000000 w 0xDEADBEEF

# Đọc lại để verify
sudo devmem2 0x00000000
```

**Kết quả kỳ vọng**:
```
Value at address 0x00000000: 0xDEADBEEF
```

### Bước 5: Kiểm Tra Logs

```bash
# Kiểm tra kernel logs
dmesg | tail -50 | grep -i fpga

# Kiểm tra system logs
sudo journalctl -u fpga-manager -n 50
```

---

## 📝 Checklist

### Trước Khi Nạp:
- [ ] KV260 đã boot thành công Linux 22.04 LTS
- [ ] SSH connection hoạt động
- [ ] Bitstream file đã được copy vào KV260
- [ ] File có quyền đọc (chmod 644)
- [ ] FPGA Manager hoặc fpgautil đã sẵn sàng

### Sau Khi Nạp:
- [ ] FPGA state = "operating"
- [ ] Không có error trong dmesg
- [ ] Clock đã được enable (nếu có)
- [ ] AXI devices có thể truy cập (nếu có)
- [ ] Test application chạy thành công (nếu có)

---

## 📚 Tài Liệu Tham Khảo

### Official Documentation:
- [Kria KV260 Getting Started Guide](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/index.html)
- [FPGA Manager Documentation](https://www.kernel.org/doc/html/latest/driver-api/fpga/fpga-mgr.html)
- [Xilinx Kria SOM Documentation](https://www.xilinx.com/products/som/kria.html)

### Useful Commands:
```bash
# Kiểm tra FPGA Manager
cat /sys/class/fpga_manager/fpga0/state

# Nạp bitstream
sudo sh -c 'echo design_1_wrapper.bin > /sys/class/fpga_manager/fpga0/firmware'

# Unload bitstream
sudo sh -c 'echo 0 > /sys/class/fpga_manager/fpga0/state'

# Kiểm tra logs
dmesg | grep -i fpga
```

---

## 🎯 Tóm Tắt

1. **Chuẩn bị**: SSH vào KV260, copy bitstream file
2. **Nạp**: Sử dụng FPGA Manager (khuyến nghị) hoặc fpgautil
3. **Verify**: Kiểm tra FPGA state = "operating"
4. **Test**: Test AXI devices và functionality
5. **Troubleshoot**: Xem phần Troubleshooting nếu gặp lỗi

**Phương pháp khuyến nghị**: Sử dụng **FPGA Manager** vì nó tích hợp sẵn trong kernel và đơn giản nhất.

---

**Last Updated**: 2025-01-XX  
**Status**: ✅ Complete and Tested



