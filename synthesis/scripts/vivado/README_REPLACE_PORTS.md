# Replace External Ports with AXI IP Peripherals

Script này thay thế các external AXI ports (S0_AXI, S1_AXI, S2_AXI, S3_AXI) bằng các AXI IP peripherals để giảm số lượng I/O pins.

## Vấn đề

Khi sử dụng external ports cho các AXI interfaces, mỗi interface có ~170 signals, dẫn đến:
- **687 I/O ports** cần thiết
- Device chỉ có **274 available user I/O pins**
- Implementation **FAILED** với lỗi I/O overutilization

## Giải pháp

Thay thế external ports bằng các AXI IP peripherals:
- **S0_AXI** → AXI BRAM Controller + Block Memory Generator (RAM)
- **S1_AXI** → AXI GPIO (GPIO)
- **S2_AXI** → AXI UART Lite (UART)
- **S3_AXI** → AXI Quad SPI (SPI)

Kết quả: Giảm từ ~687 I/O pins xuống chỉ còn ~40 pins cho các peripheral interfaces.

## Cách sử dụng

### Bước 1: Mở Block Design

Trong Vivado TCL Console:

```tcl
# Mở Block Design
open_bd_design [get_files design_1.bd]
```

Hoặc trong GUI:
- Flow Navigator → IP Integrator → Open Block Design
- Hoặc double-click `design_1.bd` trong Sources window

### Bước 2: Chạy script

```tcl
# Chạy script (điều chỉnh path nếu cần)
source synthesis/scripts/vivado/replace_external_ports_with_peripherals.tcl
```

Script sẽ tự động:
1. ✅ Xóa các external ports (S0_AXI, S1_AXI, S2_AXI, S3_AXI)
2. ✅ Thêm AXI BRAM Controller + Block Memory Generator
3. ✅ Thêm AXI GPIO
4. ✅ Thêm AXI UART Lite
5. ✅ Thêm AXI Quad SPI
6. ✅ Kết nối tất cả với AXI Interconnect
7. ✅ Kết nối clock và reset
8. ✅ Tạo external ports cho peripheral signals
9. ✅ Validate design

### Bước 3: Kiểm tra Address Map

Script sẽ tự động assign addresses, nhưng bạn nên kiểm tra trong Address Editor:

- **S0 (BRAM)**: `0x0000_0000 - 0x1FFF_FFFF` (512MB)
- **S1 (GPIO)**: `0x4000_0000 - 0x5FFF_FFFF` (512MB)
- **S2 (UART)**: `0x8000_0000 - 0x9FFF_FFFF` (512MB)
- **S3 (SPI)**: `0xC000_0000 - 0xDFFF_FFFF` (512MB)

### Bước 4: Regenerate Output Products

1. Right-click Block Design → **Regenerate Block Design**
2. Right-click Block Design → **Generate Output Products**
   - ✅ Synthesis
   - ✅ Implementation
   - ✅ IP Integrator

### Bước 5: Run Implementation

```tcl
# Reset Implementation run (nếu đã chạy trước đó)
reset_run impl_1

# Chạy Implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1
```

## IPs được thêm vào

| IP | VLNV | Purpose |
|----|------|---------|
| AXI BRAM Controller | xilinx.com:ip:axi_bram_ctrl:4.1 | RAM interface |
| Block Memory Generator | xilinx.com:ip:blk_mem_gen:8.4 | RAM memory |
| AXI GPIO | xilinx.com:ip:axi_gpio:2.0 | GPIO interface |
| AXI UART Lite | xilinx.com:ip:axi_uartlite:2.0 | UART interface |
| AXI Quad SPI | xilinx.com:ip:axi_quad_spi:3.2 | SPI interface |

## External Ports được tạo

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `gpio_io` | IO | [31:0] | GPIO signals |
| `uart_tx` | O | 1 | UART transmit |
| `uart_rx` | I | 1 | UART receive |
| `spi_sck` | O | 1 | SPI clock |
| `spi_mosi` | O | 1 | SPI master out slave in |
| `spi_miso` | I | 1 | SPI master in slave out |
| `spi_ss` | O | 1 | SPI slave select |

**Tổng cộng: ~40 pins** (thay vì ~687 pins)

## Lưu ý

1. **Address Map**: Addresses sẽ được tự động assign, nhưng bạn có thể điều chỉnh trong Address Editor nếu cần.

2. **Physical Pin Constraints**: Nếu muốn sử dụng các external ports (GPIO, UART, SPI), bạn cần tạo XDC file với pin constraints cho KV260 board.

3. **BRAM**: Block Memory Generator sử dụng BRAM resources trong FPGA, không cần external pins.

4. **Validation**: Script sẽ tự động validate design. Nếu có errors, kiểm tra connections trong Block Design GUI.

## Troubleshooting

### Lỗi: "IP instance already exists"
- Script đã kiểm tra và bỏ qua nếu IP đã tồn tại
- Nếu muốn xóa và tạo lại, xóa IP instance thủ công trước

### Lỗi: "Connection already exists"
- Script đã kiểm tra và bỏ qua nếu connection đã tồn tại
- Không ảnh hưởng đến kết quả

### Address Map không đúng
- Mở Address Editor và kiểm tra/cập nhật addresses thủ công
- Đảm bảo không có overlap giữa các address ranges









