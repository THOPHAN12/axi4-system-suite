# Wrapper Modules

## Cấu Trúc Thư Mục

Thư mục này chứa các wrapper modules để tích hợp SERV RISC-V processor (bao gồm cấu hình dual SERV) với AXI4 Interconnect. Các file đã được tổ chức theo chức năng để dễ quản lý:

```
src/wrapper/
├── converters/           # Wishbone to AXI converters
│   ├── wb2axi_read.v
│   ├── wb2axi_write.v
│   └── serv_axi_wrapper.v
├── systems/              # System integration modules
│   ├── serv_axi_system.v
│   ├── dual_riscv_axi_system.v
│   ├── axi_interconnect_wrapper.v
│   └── axi_interconnect_2m4s_wrapper.v
├── ip/                   # Self-contained IP modules (SoC-level IP)
│   └── serv_axi_system_ip.v
└── memory/               # AXI memory slave modules
    ├── axi_rom_slave.v
    ├── axi_memory_slave.v
    └── Simple_Memory_Slave.v
```

## Modules

### Converters (`converters/`)

#### `wb2axi_read.v`
- **Mục đích**: Chuyển đổi Wishbone read-only interface sang AXI4 Read channels
- **Sử dụng**: Instruction bus của SERV RISC-V
- **Interface**: Wishbone (input) → AXI4 Read (AR + R channels)

#### `wb2axi_write.v`
- **Mục đích**: Chuyển đổi Wishbone read-write interface sang AXI4 Write channels
- **Sử dụng**: Data bus của SERV RISC-V
- **Interface**: Wishbone (input) → AXI4 Write (AW + W + B channels)

#### `serv_axi_wrapper.v`
- **Mục đích**: Top-level wrapper kết nối SERV RISC-V với AXI4
- **Chức năng**:
  - Instantiates SERV RISC-V core
  - Connects instruction bus qua `wb2axi_read`
  - Connects data bus qua `wb2axi_write`
  - Exposes AXI4 Master interfaces

### Systems (`systems/`)

#### `serv_axi_system.v`
- **Mục đích**: Complete SERV RISC-V system với AXI Interconnect
- **Chức năng**:
  - SERV RISC-V processor
  - AXI Interconnect
  - External memory slaves (instruction và data memory)
  - Timer interrupt support

#### `dual_riscv_axi_system.v`
- **Mục đích**: Dual SERV master system với ngoại vi AXI-Lite
- **Chức năng**:
  - 2 SERV cores được gom qua `serv_axi_dualbus_adapter`
  - Round-robin interconnect (`axi_rr_interconnect_2x4`)
  - AXI-Lite RAM + GPIO + UART + SPI tích hợp
  - Phù hợp cho các kịch bản multi-master

#### `axi_interconnect_wrapper.v`
- **Mục đích**: Wrapper module cho AXI_Interconnect với interface đơn giản hóa
- **Chức năng**:
  - Bọc AXI_Interconnect với interface chuẩn AXI4 naming convention
  - Tự động xử lý reset signal conversion (ARESETN active low)
  - Hỗ trợ cấu hình address range qua parameters
  - Hỗ trợ override address range runtime (optional)
  - Tích hợp dễ dàng vào các hệ thống lớn hơn
- **Interface**:
  - 2 Master ports (M0, M1) - Read-only
  - 2 Slave ports (S0, S1) - Read-only
  - Standard AXI4 naming: ARADDR, ARLEN, ARSIZE, ARBURST, ARVALID, ARREADY, RDATA, RRESP, RLAST, RVALID, RREADY

#### `axi_interconnect_2m4s_wrapper.v`
- **Mục đích**: Wrapper module cho AXI_Interconnect_Full với 2 Master và 4 Slave
- **Chức năng**:
  - Bọc AXI_Interconnect_Full với interface đầy đủ AXI4
  - Bao gồm TẤT CẢ các tín hiệu Read và Write channels
  - Hỗ trợ 2 Master ports (S00, S01) - Full AXI4 (Read + Write)
  - Hỗ trợ 4 Slave ports:
    - M00, M01: Full AXI4 (Read + Write)
    - M02, M03: Read-only
  - Cấu hình address range cho 4 slaves qua parameters
  - Hỗ trợ override address range runtime (optional)
  - Tất cả các tín hiệu AXI4 chuẩn: AW, W, B, AR, R channels
- **Interface**:
  - Master 0 (S00): Full AXI4 - AW, W, B, AR, R channels
  - Master 1 (S01): Full AXI4 - AW, W, B, AR, R channels
  - Slave 0 (M00): Full AXI4 - AW, W, B, AR, R channels
  - Slave 1 (M01): Full AXI4 - AW, W, B, AR, R channels
  - Slave 2 (M02): Read-only - AR, R channels
  - Slave 3 (M03): Read-only - AR, R channels

### IP Modules (`ip/`)

#### `serv_axi_system_ip.v`
- **Mục đích**: Self-contained SERV RISC-V IP module
- **Chức năng**:
  - Complete SERV system
  - Integrated instruction và data memory
  - No external connections needed
  - Only exposes: ACLK, ARESETN, timer interrupt

### Memory Slaves (`memory/`)

#### `axi_rom_slave.v`
- **Mục đích**: AXI4 Read-Only Memory slave
- **Chức năng**:
  - Instruction memory cho SERV
  - Supports memory initialization từ hex file
  - Read-only AXI4 interface

#### `axi_memory_slave.v`
- **Mục đích**: AXI4 Read-Write Memory slave
- **Chức năng**:
  - Data memory cho SERV hoặc các master AXI khác
  - Read-write AXI4 interface
  - Supports memory initialization

#### `Simple_Memory_Slave.v`
- **Mục đích**: AXI4 Read-Write Memory slave đơn giản (không dùng ID)
- **Chức năng**:
  - Bộ nhớ nhỏ cho các IP riêng hoặc AXI Interconnect test
  - Giao diện AXI4 tối giản: không có `ID` và không dùng file init
  - Phù hợp cho các thiết kế nhẹ, dễ đọc, dễ debug

## Kiến Trúc

### SERV RISC-V to AXI4 Flow

```
[SERV RISC-V Core]
       |
   +---+---+
   |       |
[ibus]  [dbus]
(Wishbone RO) (Wishbone RW)
   |       |
[wb2axi_] [wb2axi_]
[read]    [write]
   |       |
[AXI M0]  [AXI M1]
   |       |
   +---+---+
       |
[AXI Interconnect]
       |
   +---+---+
   |       |
[Inst Mem] [Data Mem]
```

## Cách Sử Dụng

### Sử dụng IP Modules (Khuyến nghị)

IP modules là self-contained và dễ sử dụng nhất:

```verilog
// SERV AXI System IP
serv_axi_system_ip #(
    .INST_MEM_SIZE(4096),
    .DATA_MEM_SIZE(4096)
) u_serv_ip (
    .ACLK(aclk),
    .ARESETN(aresetn),
    .i_timer_irq(timer_irq)
);
```

### Sử dụng System Modules

System modules yêu cầu external memory slaves:

```verilog
// SERV AXI System
serv_axi_system u_serv_system (
    .ACLK(aclk),
    .ARESETN(aresetn),
    .i_timer_irq(timer_irq),
    // AXI Master interfaces
    .M00_AXI_*(...),  // Instruction memory
    .M01_AXI_*(...)   // Data memory
);

// External memory slaves
axi_rom_slave u_inst_mem (...);
axi_memory_slave u_data_mem (...);
```

## File Organization Benefits

1. **Dễ tìm kiếm**: Modules được phân loại theo chức năng
2. **Dễ quản lý**: Mỗi loại module có thư mục riêng
3. **Dễ mở rộng**: Dễ dàng thêm module mới vào đúng thư mục
4. **Rõ ràng**: Phân biệt rõ converters, systems, IP modules, và memory slaves

## Lưu Ý

- Tất cả modules sử dụng relative paths để reference dependencies
- IP modules là self-contained và không cần external connections
- System modules yêu cầu external memory slaves
- Converters được sử dụng bởi `serv_axi_wrapper`
- Memory slaves có thể được sử dụng độc lập hoặc trong IP modules
