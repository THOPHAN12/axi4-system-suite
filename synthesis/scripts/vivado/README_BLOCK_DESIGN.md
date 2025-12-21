# Hướng Dẫn Tạo Block Design cho KV260 - 2M.4S System

## Tổng Quan

Script này tự động tạo Block Design trong Vivado cho hệ thống **2 Masters × 4 Slaves** trên KV260, sử dụng:
- **Zynq UltraScale+ Processing System (PS)** với 2 AXI Master ports
- **AXI Interconnect Custom IP** (từ RTL SystemVerilog)
- **AXI SmartConnect** cho protocol conversion

## Yêu Cầu

- Vivado 2020.2 hoặc cao hơn
- KV260 board support files đã được cài đặt
- SystemVerilog files trong `SystemVerilog/axi_interconnect/`

## Cách Sử Dụng

### Bước 1: Chạy Script

Mở Vivado và trong TCL Console:

**Cách 1: Dùng đường dẫn trong dấu ngoặc kép (Khuyến nghị)**
```tcl
cd "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"
source create_kv260_block_design.tcl
```

**Cách 2: Dùng file normalize (Tự động xử lý khoảng trắng)**
```tcl
set script_dir [file normalize "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"]
cd $script_dir
source create_kv260_block_design.tcl
```

**Cách 3: Chạy trực tiếp với đường dẫn đầy đủ**
```tcl
source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_kv260_block_design.tcl"
```

Script sẽ tự động:
1. ✅ Tạo Vivado project mới
2. ✅ Tạo Block Design
3. ✅ Thêm và configure Zynq PS
4. ✅ Add AXI Interconnect RTL files
5. ✅ Tạo AXI Interconnect instance
6. ✅ Kết nối clock và reset
7. ✅ Kết nối AXI buses
8. ✅ Tạo external ports cho 4 slaves
9. ✅ Validate và generate block design
10. ✅ Tạo HDL wrapper

### Bước 2: Hoàn Thiện Block Design (Thủ Công)

Sau khi script chạy xong, bạn cần:

#### 2.1. Mở Block Design
- Flow Navigator → IP Integrator → Open Block Design
- Hoặc double-click `design_1.bd` trong Sources window

#### 2.2. Kiểm Tra Kết Nối
- Kiểm tra tất cả connections đã được kết nối đúng
- Clock: `pl_clk0` → tất cả components
- Reset: `pl_resetn0` → tất cả components
- AXI: PS → SmartConnect → AXI Interconnect

#### 2.3. Set Address Map
- Click tab **Address Editor** (ở dưới canvas)
- Set address ranges cho 4 slaves:
  - **S0 (RAM)**: `0x0000_0000` - `0x1FFF_FFFF` (512MB)
  - **S1 (GPIO)**: `0x4000_0000` - `0x5FFF_FFFF` (512MB)
  - **S2 (UART)**: `0x8000_0000` - `0x9FFF_FFFF` (512MB)
  - **S3 (SPI)**: `0xC000_0000` - `0xDFFF_FFFF` (512MB)

#### 2.4. Thêm Peripherals (Tùy Chọn)

Nếu muốn kết nối với Xilinx IP peripherals:

**Thêm AXI BRAM Controller (cho S0 - RAM):**
1. Add IP → `AXI BRAM Controller`
2. Configure: 1 BRAM port
3. Connect: `S0_AXI` → `S_AXI` của BRAM Controller
4. Add Block Memory Generator → Connect với BRAM Controller

**Thêm AXI GPIO (cho S1 - GPIO):**
1. Add IP → `AXI GPIO`
2. Configure: 2 channels (1 input, 1 output), 32 bits
3. Connect: `S1_AXI` → `S_AXI` của GPIO
4. Create external ports cho GPIO signals

**Thêm AXI UART Lite (cho S2 - UART):**
1. Add IP → `AXI UART Lite`
2. Connect: `S2_AXI` → `S_AXI` của UART
3. Create external ports cho UART TX/RX

**Thêm AXI SPI (cho S3 - SPI):**
1. Add IP → `AXI Quad SPI`
2. Connect: `S3_AXI` → `S_AXI` của SPI
3. Create external ports cho SPI signals

#### 2.5. Validate Block Design
- Click **Validate Design** (hoặc `F6`)
- Kiểm tra không có errors hoặc critical warnings

#### 2.6. Regenerate Block Design
- Right-click block design → **Regenerate Block Design**
- Chọn **Generate** → OK

### Bước 3: Generate Output Products

1. Right-click block design → **Generate Output Products**
2. Chọn:
   - ✅ Synthesis
   - ✅ Implementation
   - ✅ IP Integrator
3. Click **Generate**

### Bước 4: Create HDL Wrapper

1. Right-click block design → **Create HDL Wrapper**
2. Chọn **Let Vivado manage wrapper and auto-update**
3. Click **OK**

### Bước 5: Set Top Module

1. Set `${bd_name}_wrapper` làm top module
2. Verify trong Sources window

### Bước 6: Add Constraints

1. Add Sources → Add or create constraints
2. Add file: `synthesis/constraints/axi_interconnect.xdc`
3. **Lưu ý**: Trong Block Design, clock constraints từ PS thường được tự động tạo

### Bước 7: Run Synthesis và Implementation

1. **Run Synthesis**:
   - Flow Navigator → Synthesis → Run Synthesis
   - Chờ synthesis hoàn thành

2. **Run Implementation**:
   - Flow Navigator → Implementation → Run Implementation
   - Chờ implementation hoàn thành

3. **Generate Bitstream**:
   - Flow Navigator → Program and Debug → Generate Bitstream
   - Chờ bitstream generation hoàn thành

## Cấu Trúc Block Design

```
┌─────────────────────────────────────────────────────────┐
│  Zynq UltraScale+ MPSoC (PS)                            │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │ M_AXI_HPM0   │  │ M_AXI_HPM1   │  (2 Masters)        │
│  └──────┬───────┘  └──────┬───────┘                     │
│         │                  │                              │
│         │ pl_clk0 (100MHz) │                              │
│         │ pl_resetn0       │                              │
└─────────┼──────────────────┼────────────────────────────┘
          │                  │
          ▼                  ▼
┌─────────────────┐  ┌─────────────────┐
│ SmartConnect_0  │  │ SmartConnect_1  │
└────────┬────────┘  └────────┬────────┘
         │                    │
         └──────────┬─────────┘
                    ▼
┌─────────────────────────────────────────────────────────┐
│  AXI Interconnect (2M × 4S) - Custom IP                │
│  ┌──────────┐  ┌──────────┐                             │
│  │ M0 Port  │  │ M1 Port  │                             │
│  └────┬─────┘  └────┬─────┘                             │
│       │             │                                    │
│       └─────┬───────┘                                    │
│             │                                            │
│    ┌────────┼────────┬────────┬────────┐                │
│    │        │        │        │        │                │
│    ▼        ▼        ▼        ▼        ▼                │
│   S0       S1       S2       S3       (4 Slaves)        │
└────┼────────┼────────┼────────┼─────────────────────────┘
     │        │        │        │
     ▼        ▼        ▼        ▼
  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐
  │ RAM │ │GPIO │ │UART │ │ SPI │
  └─────┘ └─────┘ └─────┘ └─────┘
```

## Address Map

| Slave | Device | Address Range | Size |
|-------|--------|---------------|------|
| S0 | RAM | 0x0000_0000 - 0x1FFF_FFFF | 512 MB |
| S1 | GPIO | 0x4000_0000 - 0x5FFF_FFFF | 512 MB |
| S2 | UART | 0x8000_0000 - 0x9FFF_FFFF | 512 MB |
| S3 | SPI | 0xC000_0000 - 0xDFFF_FFFF | 512 MB |

## Troubleshooting

### Lỗi: "Module not found"
- **Nguyên nhân**: RTL files chưa được compile
- **Giải pháp**: 
  ```tcl
  update_compile_order -fileset sources_1
  synth_design -rtl -name rtl_1
  ```

### Lỗi: "AXI interface connection failed"
- **Nguyên nhân**: AXI interface names không khớp
- **Giải pháp**: Kiểm tra lại tên interface trong module RTL và Block Design

### Lỗi: "Address map not set"
- **Nguyên nhân**: Chưa set address ranges trong Address Editor
- **Giải pháp**: Mở Address Editor và set address ranges cho 4 slaves

### Lỗi: "Clock domain crossing"
- **Nguyên nhân**: Components dùng clock khác nhau
- **Giải pháp**: Đảm bảo tất cả components dùng `pl_clk0` từ PS

## Lưu Ý Quan Trọng

1. **Clock Frequency**: Mặc định 100 MHz, có thể thay đổi trong Zynq PS configuration
2. **Reset**: Dùng `pl_resetn0` từ PS (active low)
3. **AXI Protocol**: AXI Interconnect hỗ trợ AXI4 Full, nhưng PS masters là AXI4 GP (General Purpose)
4. **SmartConnect**: Cần thiết để convert protocol giữa PS và custom AXI Interconnect
5. **Address Map**: Phải khớp với address decoder trong AXI Interconnect

## Files Được Tạo

Sau khi chạy script, các files sau sẽ được tạo:

```
kv260_2m4s_block_design/
├── kv260_2m4s_block_design.xpr          # Vivado project
├── kv260_2m4s_block_design.srcs/
│   ├── sources_1/
│   │   ├── bd/
│   │   │   └── design_1/
│   │   │       ├── design_1.bd          # Block Design file
│   │   │       └── hdl/
│   │   │           └── design_1_wrapper.v  # HDL Wrapper
│   │   └── imports/                     # RTL files
│   └── constrs_1/
│       └── axi_interconnect.xdc         # Constraints
└── kv260_2m4s_block_design.runs/        # Synthesis/Implementation runs
```

## Tài Liệu Tham Khảo

- [Vivado IP Integrator User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug994-vivado-ip-subsystems.pdf)
- [Zynq UltraScale+ MPSoC Technical Reference Manual](https://www.xilinx.com/support/documentation/user_guides/ug1085-zynq-ultrascale-trm.pdf)
- [AXI4 Protocol Specification](https://developer.arm.com/documentation/ihi0022/latest/)

---

**Script Location**: `synthesis/scripts/vivado/create_kv260_block_design.tcl`

**Last Updated**: 2025-01-XX

