# Hướng Dẫn Tạo Peripheral Wrapper Block Designs

## Mục Đích

Để diagram Block Design gọn gàng, chỉ hiển thị:
- Zynq PS
- 2x AXI Master Bridges  
- AXI Interconnect
- 4 Slaves (BRAM Controller + 3 Wrapper instances)

Trong khi vẫn đảm bảo GPIO, UART, SPI hoạt động đúng. Các Protocol Converters sẽ được ẩn bên trong wrapper Block Designs.

## Tổng Quan Giải Pháp

Mỗi wrapper Block Design bao gồm:
- **AXI4 Full interface** (bên ngoài) - kết nối với AXI Interconnect
- **AXI Protocol Converter** (AXI4 → AXI4-Lite)
- **Peripheral** (GPIO/UART/SPI) - AXI4-Lite

Khi add vào main Block Design, mỗi wrapper sẽ xuất hiện như một block duy nhất, che giấu Protocol Converter bên trong.

## Các Bước Thực Hiện

### Bước 1: Tạo Wrapper Block Designs

Chạy script để tạo 3 wrapper Block Designs:

```tcl
# Trong Vivado TCL Console (sau khi đã mở project)
source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_peripheral_wrappers.tcl"
```

Script sẽ tạo:
- `gpio_wrapper.bd` - GPIO wrapper
- `uart_wrapper.bd` - UART wrapper  
- `spi_wrapper.bd` - SPI wrapper

### Bước 2: Generate Output Products cho Wrapper BDs

Sau khi tạo wrapper BDs, bạn cần generate output products cho từng wrapper:

**Cách 1: Via GUI**
1. Trong Sources panel, expand Block Designs
2. Right-click mỗi wrapper BD → **Generate Output Products**
3. Chọn tất cả options và click Generate

**Cách 2: Via TCL** (chạy từng lệnh cho mỗi wrapper)

```tcl
# GPIO Wrapper
open_bd_design [get_files gpio_wrapper.bd]
generate_target all [get_files gpio_wrapper.bd]
close_bd_design

# UART Wrapper
open_bd_design [get_files uart_wrapper.bd]
generate_target all [get_files uart_wrapper.bd]
close_bd_design

# SPI Wrapper
open_bd_design [get_files spi_wrapper.bd]
generate_target all [get_files spi_wrapper.bd]
close_bd_design

# Quay lại main BD
open_bd_design [get_files design_1.bd]
```

### Bước 3: Create HDL Wrapper cho Wrapper BDs

Tạo HDL wrapper cho mỗi wrapper BD:

```tcl
# GPIO Wrapper
open_bd_design [get_files gpio_wrapper.bd]
make_wrapper -files [get_files gpio_wrapper.bd] -top
close_bd_design

# UART Wrapper
open_bd_design [get_files uart_wrapper.bd]
make_wrapper -files [get_files uart_wrapper.bd] -top
close_bd_design

# SPI Wrapper
open_bd_design [get_files spi_wrapper.bd]
make_wrapper -files [get_files spi_wrapper.bd] -top
close_bd_design

# Quay lại main BD
open_bd_design [get_files design_1.bd]
```

### Bước 4: Thay Thế Peripherals bằng Wrapper Instances

**Cách 1: Sử dụng Script (Khuyến nghị - nhưng cần manual add wrappers)**

```tcl
source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/replace_peripherals_with_wrappers.tcl"
```

Script sẽ:
1. Xóa các Protocol Converters và Peripherals cũ
2. **Bạn cần manually add wrapper instances** (xem bước 4.1)
3. Script sẽ tự động kết nối interfaces, clock và reset

**Cách 2: Manual qua GUI**

1. **Xóa các Protocol Converters và Peripherals cũ:**
   - Delete `axi_protocol_converter_s1`, `axi_protocol_converter_s2`, `axi_protocol_converter_s3`
   - Delete `axi_gpio_0`, `axi_uartlite_0`, `axi_quad_spi_0`

2. **Add Wrapper Instances:**
   - Right-click trong Block Design canvas → **Add Module...**
   - Tìm và chọn `gpio_wrapper_wrapper` → OK
   - Repeat cho `uart_wrapper_wrapper` và `spi_wrapper_wrapper`

3. **Kết nối AXI Interfaces:**
   - `axi_interconnect_0/S1` → `gpio_wrapper_0/S_AXI`
   - `axi_interconnect_0/S2` → `uart_wrapper_0/S_AXI`
   - `axi_interconnect_0/S3` → `spi_wrapper_0/S_AXI`

4. **Kết nối Clock và Reset:**
   - `zynq_ultra_ps_e_0/pl_clk0` → `gpio_wrapper_0/ACLK`
   - `zynq_ultra_ps_e_0/pl_clk0` → `uart_wrapper_0/ACLK`
   - `zynq_ultra_ps_e_0/pl_clk0` → `spi_wrapper_0/ACLK`
   - `rst_ps8_0_99M/peripheral_aresetn` → `gpio_wrapper_0/ARESETN` (và tương tự cho UART, SPI)

### Bước 5: Validate và Regenerate

```tcl
validate_bd_design
regenerate_bd_layout
save_bd_design
```

### Bước 6: Regenerate Main Block Design

1. Right-click `design_1.bd` → **Regenerate Block Design**
2. Right-click `design_1.bd` → **Generate Output Products**

## Kết Quả

Sau khi hoàn thành, diagram của bạn sẽ chỉ hiển thị:
- Zynq PS
- 2x AXI Master Bridges
- AXI Interconnect
- BRAM Controller (S0)
- 3x Wrapper instances (S1, S2, S3)

Mỗi wrapper instance là một block duy nhất, che giấu Protocol Converter và Peripheral bên trong. Protocol Converters không còn hiển thị trong diagram chính.

## Lưu Ý

- Wrapper BDs là nested Block Designs, do đó khi double-click vào wrapper instance, bạn sẽ thấy Protocol Converter + Peripheral bên trong
- Đảm bảo generate output products cho cả wrapper BDs và main BD
- Nếu có lỗi validation, kiểm tra clock và reset connections

## Troubleshooting

### Error: "Wrapper module not found"
- Đảm bảo đã generate output products và create HDL wrapper cho wrapper BDs
- Kiểm tra tên module trong Sources panel

### Error: "Interface protocol mismatch"
- Đảm bảo wrapper BD có interface AXI4 Full ở bên ngoài (S_AXI port)
- Kiểm tra Protocol Converter configuration bên trong wrapper

### Wrapper không hiển thị đúng
- Regenerate layout: `regenerate_bd_layout`
- Validate design: `validate_bd_design`

## Xem Thêm

- `create_peripheral_wrappers.tcl`: Script tạo wrapper BDs
- `replace_peripherals_with_wrappers.tcl`: Script thay thế peripherals








