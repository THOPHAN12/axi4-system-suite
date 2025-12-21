# Fix AXI Protocol Mismatch Script

## Mục đích

Script này tự động fix vấn đề protocol mismatch giữa AXI Interconnect (AXI4 Full) và các peripherals (AXI4-Lite).

## Vấn đề

- **AXI Interconnect** của bạn sử dụng **AXI4 Full** (có AWLEN, ARLEN, WLAST, RLAST)
- Các **peripherals** (GPIO, UART, SPI) sử dụng **AXI4-Lite** (không có các signals trên)
- Vivado không cho phép kết nối trực tiếp giữa AXI4 Full và AXI4-Lite

## Giải pháp

Script sẽ:
1. Thêm **AXI Protocol Converter** giữa AXI Interconnect và các peripherals cần AXI4-Lite
2. **S0 (BRAM Controller)**: Kết nối trực tiếp vì BRAM Controller hỗ trợ AXI4 Full
3. **S1 (GPIO)**: AXI Interconnect → Protocol Converter → GPIO
4. **S2 (UART)**: AXI Interconnect → Protocol Converter → UART
5. **S3 (SPI)**: AXI Interconnect → Protocol Converter → SPI

## Cách sử dụng

### Bước 1: Mở Block Design

Trong Vivado TCL Console:

```tcl
# Nếu đã có project mở
open_bd_design [get_files *.bd]

# Hoặc nếu chưa mở project
open_project <path_to_project>/<project_name>.xpr
open_bd_design [get_files *.bd]
```

### Bước 2: Chạy script

```tcl
source synthesis/scripts/vivado/fix_axi_protocol_mismatch.tcl
```

Script sẽ tự động:
- Kiểm tra các components cần thiết
- Disconnect các kết nối cũ (nếu có)
- Thêm AXI Protocol Converters
- Kết nối lại tất cả interfaces
- Kết nối clock và reset
- Regenerate layout và validate

### Bước 3: Regenerate Output Products

Sau khi script chạy xong:

1. Right-click vào Block Design trong Sources panel
2. Chọn **"Generate Output Products"** hoặc **"Create HDL Wrapper"**
3. Chọn **"Let Vivado manage wrapper and auto-update"**

### Bước 4: Chạy Synthesis

```tcl
launch_runs synth_1 -jobs 4
wait_on_run synth_1
```

## Cấu trúc kết nối sau khi chạy script

```
AXI Interconnect
    |
    ├── S0 ──────────────> BRAM Controller (AXI4 Full, direct)
    |
    ├── S1 ──> Protocol Converter ──> GPIO (AXI4 → AXI4-Lite)
    |
    ├── S2 ──> Protocol Converter ──> UART (AXI4 → AXI4-Lite)
    |
    └── S3 ──> Protocol Converter ──> SPI (AXI4 → AXI4-Lite)
```

## Lưu ý

- Script sẽ tự động kiểm tra và chỉ thêm Protocol Converter nếu chưa có
- Script an toàn để chạy nhiều lần (idempotent)
- Nếu có lỗi, kiểm tra console output để biết component nào thiếu
- Sau khi chạy script, nhớ regenerate output products trước khi synthesis

## Troubleshooting

### Error: "No Block Design is currently open"
- Đảm bảo đã mở Block Design trước khi chạy script

### Error: "AXI Interconnect instance 'axi_interconnect_0' not found"
- Kiểm tra tên instance của AXI Interconnect có đúng là `axi_interconnect_0` không
- Nếu khác, sửa tên trong script

### Warning: "axi_gpio_0 not found"
- Nếu bạn chưa chạy script `replace_external_ports_with_peripherals.tcl`, chạy script đó trước

## Xem thêm

- `replace_external_ports_with_peripherals.tcl`: Script để thay thế external ports bằng peripherals
- `README_REPLACE_PORTS.md`: Hướng dẫn sử dụng script replace ports









