# 📚 Tài Liệu Tổng Hợp Dự Án AXI - Comprehensive Documentation

> **Tài liệu này tổng hợp tất cả thông tin từ các README.md trong dự án, được tổ chức một cách logic và dễ tìm kiếm.**

**Cập nhật lần cuối**: 2025-11-24

---

## 📖 Mục Lục

1. [Tổng Quan Dự Án](#tổng-quan-dự-án)
2. [Kiến Trúc Hệ Thống](#kiến-trúc-hệ-thống)
3. [Source Code](#source-code)
4. [Documentation](#documentation)
5. [Simulation & Synthesis](#simulation--synthesis)
6. [Testbenches](#testbenches)
7. [Hướng Dẫn Sử Dụng](#hướng-dẫn-sử-dụng)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Tổng Quan Dự Án

### Mục Đích

Dự án AXI là một hệ thống tích hợp AXI4 Interconnect với:
- **SERV RISC-V Processor**: Bit-serial RISC-V core (world's smallest RISC-V CPU)
- **ALU Master**: Custom AXI master cho ALU operations
- **AXI4 Interconnect**: Full-featured interconnect hỗ trợ 2 masters, 4 slaves
- **Memory Slaves**: AXI4 memory slaves (ROM, RAM)

### Cấu Trúc Dự Án

```
AXI/
├── src/              # Source code RTL
│   ├── axi_interconnect/  # AXI Interconnect core
│   ├── wrapper/          # Wrapper modules
│   ├── cores/            # CPU cores (SERV, ALU)
│   └── common/           # Common utilities
│
├── docs/             # Documentation
│   ├── architecture/     # Kiến trúc hệ thống
│   ├── axi_interconnect_signals/  # Signals documentation
│   ├── design_notes/     # Ghi chú thiết kế
│   └── meta/             # Meta documentation
│
├── sim/              # Simulation files
│   ├── quartus/          # Quartus project
│   └── modelsim/         # ModelSim project
│
├── tb/               # Testbenches
│   ├── interconnect_tb/  # AXI Interconnect testbenches
│   ├── wrapper_tb/       # Wrapper testbenches
│   └── utils_tb/         # Utility testbenches
│
└── tools/            # Utility scripts
```

---

## 🏗️ Kiến Trúc Hệ Thống

### Hệ Thống Chính: Dual Master System IP

**Top-Level Module**: `dual_master_system_ip`

```
[SERV RISC-V]    [ALU Master]
      |                |
      +--------+-------+
               |
    [AXI Interconnect (2M, 4S)]
               |
      +--------+--------+--------+--------+
      |        |        |        |        |
  [Inst Mem] [Data Mem] [ALU Mem] [Reserved]
```

### Kiến Trúc Chi Tiết

#### 1. SERV RISC-V to AXI4 Flow

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

#### 2. AXI Interconnect

- **2 Masters**: SERV (2 ports), ALU Master
- **4 Slaves**: Instruction Memory, Data Memory, ALU Memory, Reserved
- **Arbitration**: Round-robin, QoS-based
- **Address Decoding**: Configurable address ranges

### Tài Liệu Kiến Trúc

📖 **Bắt đầu từ đây**: [architecture/SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md)

- **[SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md)** - Sơ đồ tổng thể (ASCII art)
- **[SYSTEM_DIAGRAM_MERMAID.md](architecture/SYSTEM_DIAGRAM_MERMAID.md)** - Sơ đồ Mermaid (interactive)
- **[SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md)** - Chi tiết kiến trúc từng module
- **[CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)** - Sơ đồ kết nối chi tiết
- **[AXI_INTERCONNECT_CONFLICTS.md](architecture/AXI_INTERCONNECT_CONFLICTS.md)** - Phân tích xung đột và arbitration

---

## 💻 Source Code

### Wrapper Modules (`src/wrapper/`)

Wrapper modules tích hợp SERV RISC-V và ALU Master với AXI4 Interconnect.

#### Cấu Trúc

```
src/wrapper/
├── converters/           # Wishbone to AXI converters
│   ├── wb2axi_read.v    # Wishbone → AXI4 Read
│   ├── wb2axi_write.v   # Wishbone → AXI4 Write
│   └── serv_axi_wrapper.v  # SERV to AXI4 wrapper
│
├── systems/             # System integration modules
│   ├── serv_axi_system.v           # SERV system
│   ├── dual_master_system.v       # SERV + ALU Master
│   ├── alu_master_system.v        # ALU Master system
│   ├── axi_interconnect_wrapper.v  # AXI Interconnect wrapper (read-only)
│   └── axi_interconnect_2m4s_wrapper.v  # AXI Interconnect wrapper (2M, 4S, full AXI4)
│
├── ip/                  # Self-contained IP modules
│   ├── serv_axi_system_ip.v       # SERV IP module
│   └── dual_master_system_ip.v    # Dual Master IP module ⭐
│
└── memory/              # AXI memory slave modules
    ├── axi_rom_slave.v            # Read-only memory
    ├── axi_memory_slave.v         # Read-write memory
    └── Simple_Memory_Slave.v     # Simple memory (no ID)
```

#### Modules Chi Tiết

**📖 Xem chi tiết**: [src/wrapper/README.md](../../src/wrapper/README.md)

##### Converters
- **wb2axi_read.v**: Chuyển đổi Wishbone read-only → AXI4 Read channels
- **wb2axi_write.v**: Chuyển đổi Wishbone read-write → AXI4 Write channels
- **serv_axi_wrapper.v**: Top-level wrapper kết nối SERV với AXI4

##### Systems
- **serv_axi_system.v**: Complete SERV RISC-V system với AXI Interconnect
- **dual_master_system.v**: Dual master system (SERV + ALU Master) với external memory
- **alu_master_system.v**: ALU Master system với multiple masters
- **axi_interconnect_wrapper.v**: Wrapper cho AXI_Interconnect (read-only interface)
- **axi_interconnect_2m4s_wrapper.v**: Wrapper cho AXI_Interconnect_Full (2M, 4S, full AXI4)

##### IP Modules (Khuyến Nghị)
- **serv_axi_system_ip.v**: Self-contained SERV RISC-V IP module
- **dual_master_system_ip.v**: ⭐ **Self-contained Dual Master System IP** (Khuyến nghị sử dụng)

##### Memory Slaves
- **axi_rom_slave.v**: AXI4 Read-Only Memory (instruction memory)
- **axi_memory_slave.v**: AXI4 Read-Write Memory (data memory)
- **Simple_Memory_Slave.v**: Simple memory slave (không dùng ID)

### AXI Interconnect Core (`src/axi_interconnect/rtl/`)

```
src/axi_interconnect/rtl/
├── core/                    # Top-level modules
│   ├── AXI_Interconnect_Full.v    # Full AXI4 (2M, 4S)
│   ├── AXI_Interconnect.v         # Read-only wrapper
│   └── AXI_Interconnect_2S_RDONLY.v
│
├── arbitration/            # Arbitration logic
│   ├── Read_Arbiter.v
│   ├── Write_Arbiter.v
│   ├── Write_Arbiter_RR.v
│   └── Qos_Arbiter.v
│
├── channel_controllers/    # Channel controllers
│   ├── read/
│   │   ├── AR_Channel_Controller_Top.v
│   │   └── Controller.v
│   └── write/
│       ├── AW_Channel_Controller_Top.v
│       ├── WD_Channel_Controller_Top.v
│       └── BR_Channel_Controller_Top.v
│
├── datapath/              # MUX/DEMUX
│   ├── mux/
│   └── demux/
│
├── decoders/              # Address decoders
│   ├── Read_Addr_Channel_Dec.v
│   ├── Write_Addr_Channel_Dec.v
│   └── Write_Resp_Channel_Dec.v
│
├── handshake/             # Handshake logic
│   ├── AW_HandShake_Checker.v
│   ├── WD_HandShake.v
│   └── WR_HandShake.v
│
├── buffers/               # FIFO/Queue buffers
│   ├── Queue.v
│   └── Resp_Queue.v
│
└── utils/                 # Utility modules
    ├── Raising_Edge_Det.v
    └── Faling_Edge_Detc.v
```

### CPU Cores (`src/cores/`)

- **serv/**: SERV RISC-V processor (bit-serial, world's smallest RISC-V CPU)
- **alu/**: ALU Master (custom AXI master)

---

## 📚 Documentation

### Tài Liệu Chính

#### 1. Kiến Trúc & Thiết Kế (`docs/architecture/`)

📖 **Bắt đầu từ đây**: [architecture/README.md](architecture/README.md)

- **[SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md)** ⭐ - Sơ đồ tổng thể hệ thống
- **[SYSTEM_DIAGRAM_MERMAID.md](architecture/SYSTEM_DIAGRAM_MERMAID.md)** - Sơ đồ Mermaid
- **[SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md)** - Chi tiết kiến trúc
- **[CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)** - Sơ đồ kết nối
- **[AXI_INTERCONNECT_CONFLICTS.md](architecture/AXI_INTERCONNECT_CONFLICTS.md)** - Phân tích xung đột

#### 2. Signals Documentation (`docs/axi_interconnect_signals/`)

📖 **Xem**: [axi_interconnect_signals/README.md](axi_interconnect_signals/README.md)

- **[README.md](axi_interconnect_signals/README.md)** - Bảng tín hiệu đầu vào/đầu ra
- **[Quartus_Warnings_Analysis.md](axi_interconnect_signals/Quartus_Warnings_Analysis.md)** - Phân tích warnings từ Quartus
- **[Device_Change_Summary.md](axi_interconnect_signals/Device_Change_Summary.md)** - Tóm tắt thay đổi device
- **[Wrapper_Optimization_Guide.md](axi_interconnect_signals/Wrapper_Optimization_Guide.md)** - Hướng dẫn tối ưu wrapper
- **[Controller_Warnings_Analysis.md](axi_interconnect_signals/Controller_Warnings_Analysis.md)** - Phân tích warnings trong Controller

#### 3. Design Notes (`docs/design_notes/`)

📖 **Xem**: [design_notes/README.md](design_notes/README.md)

- **[AXI_INTERCONNECT_TEST_DESIGN.txt](design_notes/AXI_INTERCONNECT_TEST_DESIGN.txt)** - Đề án test AXI Interconnect

#### 4. Meta Documentation (`docs/meta/`)

📖 **Xem**: [meta/README.md](meta/README.md)

- **[DOCUMENTATION_REVIEW.md](meta/DOCUMENTATION_REVIEW.md)** - Đánh giá tài liệu
- **[REORGANIZATION_PLAN.md](meta/REORGANIZATION_PLAN.md)** - Kế hoạch tổ chức lại
- **[PROJECT_STRUCTURE_ANALYSIS.md](meta/PROJECT_STRUCTURE_ANALYSIS.md)** - Phân tích cấu trúc dự án
- **[PROJECT_STRUCTURE_SUMMARY.md](meta/PROJECT_STRUCTURE_SUMMARY.md)** - Tóm tắt cấu trúc

### Tài Liệu Khác

- **user_guides/**: Hướng dẫn sử dụng (đang phát triển)
- **specifications/**: Đặc tả kỹ thuật (đang phát triển)
- **api_reference/**: API Reference (đang phát triển)
- **changelog/**: Lịch sử thay đổi (đang phát triển)

---

## 🔬 Simulation & Synthesis

### Quartus II (`sim/quartus/`)

📖 **Xem chi tiết**: [sim/quartus/README.md](../../sim/quartus/README.md)

#### Quick Start

```bash
# Mở Quartus
quartus AXI_PROJECT.qpf
```

#### Thêm File Mới

```tcl
# Trong Quartus TCL Console
cd D:/AXI/sim/quartus
source add_files.tcl
```

#### Top-Level Entity Options

1. **dual_master_system_ip** ⭐ **KHUYẾN NGHỊ**
   - Complete IP module với SERV + ALU Master
   - Integrated memory slaves
   - No external connections needed

2. **serv_axi_system_ip**
   - SERV RISC-V IP module
   - Integrated instruction và data memory

3. **AXI_Interconnect_Full**
   - Chỉ AXI Interconnect

4. Các options khác: `dual_master_system`, `serv_axi_system`, `serv_axi_wrapper`, `alu_master_system`

#### Scripts

- **add_files.tcl** ⭐ - Tự động thêm file mới vào project
- **add_all_source_files.tcl** - Reset lại project (thêm tất cả file)

#### Device Configuration

- **Current Device**: EP2C70F672C6 (Cyclone II)
- **Previous Devices**: EP2C35F672C6, EP2C50F672C6 (không đủ I/O pins)

### ModelSim (`sim/modelsim/`)

📖 **Xem chi tiết**: [sim/modelsim/docs/README.md](../../sim/modelsim/docs/README.md)

#### Quick Start

```bash
# RISC-V System
cd sim/modelsim
run_riscv.bat

# Dual Master System IP
run_dual_master_ip_test.bat
```

#### TCL Scripts

- **scripts/compile/**: Compilation scripts
- **scripts/sim/**: Simulation scripts
- **scripts/project/**: Project management scripts

---

## 🧪 Testbenches

### Wrapper Testbenches (`tb/wrapper_tb/`)

📖 **Xem chi tiết**: [tb/wrapper_tb/README.md](../../tb/wrapper_tb/README.md)

#### Cấu Trúc

```
tb/wrapper_tb/
├── testbenches/
│   ├── serv/              # SERV RISC-V testbenches
│   ├── dual_master/       # Dual Master System testbenches
│   └── alu_master/        # ALU Master System testbenches
└── programs/              # Test programs (hex files)
```

#### Chạy Testbench

```tcl
# Trong ModelSim TCL Console
cd D:/AXI/sim/modelsim

# SERV RISC-V
source scripts/sim/run_riscv_test.tcl

# Dual Master IP
source scripts/sim/run_dual_master_ip_test.tcl

# ALU Master
source scripts/sim/run_wrapper_test.tcl
```

### Utils Testbenches (`tb/utils_tb/`)

📖 **Xem chi tiết**: [tb/utils_tb/README.md](../../tb/utils_tb/README.md)

- **edge_detectors/**: Edge detector testbenches
- **mux_demux/**: MUX/Demux testbenches
- **utils_tb_all.v**: All-in-one testbench suite

### Interconnect Testbenches (`tb/interconnect_tb/`)

- **core/**: Core testbenches
- **channel_controllers/**: Controller testbenches
- **datapath/**: Datapath testbenches
- **arbitration/**: Arbitration testbenches

---

## 🚀 Hướng Dẫn Sử Dụng

### Cho Người Mới

1. **Đọc**: [architecture/SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md) - Tổng quan hệ thống
2. **Xem**: [architecture/SYSTEM_DIAGRAM_MERMAID.md](architecture/SYSTEM_DIAGRAM_MERMAID.md) - Sơ đồ trực quan
3. **Hiểu**: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md) - Chi tiết kiến trúc

### Cho Developer

1. **Thiết kế**: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md)
2. **Kết nối**: [architecture/CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)
3. **Xung đột**: [architecture/AXI_INTERCONNECT_CONFLICTS.md](architecture/AXI_INTERCONNECT_CONFLICTS.md)
4. **Test**: [design_notes/AXI_INTERCONNECT_TEST_DESIGN.txt](design_notes/AXI_INTERCONNECT_TEST_DESIGN.txt)

### Cho Integrator

1. **Tổng quan**: [architecture/SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md)
2. **Ports**: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md) - Section 1.5
3. **Wiring**: [architecture/CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)
4. **Wrapper**: [src/wrapper/README.md](../../src/wrapper/README.md)

### Sử Dụng IP Modules (Khuyến Nghị)

```verilog
// Dual Master System IP
dual_master_system_ip #(
    .INST_MEM_SIZE(8192),
    .DATA_MEM_SIZE(8192),
    .ALU_MEM_SIZE(4096)
) u_dual_master_ip (
    .ACLK(aclk),
    .ARESETN(aresetn),
    .i_timer_irq(timer_irq),
    .alu_master_start(start),
    .alu_master_busy(busy),
    .alu_master_done(done),
    .inst_mem_ready(inst_ready),
    .data_mem_ready(data_ready),
    .alu_mem_ready(alu_ready)
);
```

---

## 🔧 Troubleshooting

### Quartus Issues

#### Pin Placement Errors

**Lỗi**: `Can't place X pins with 3.3-V LVTTL I/O standard because Fitter has only Y such free pins available`

**Giải pháp**:
1. Thay đổi device sang EP2C70F672C6 (hoặc device lớn hơn)
2. Tối ưu wrapper để giảm I/O pins (xem [Wrapper_Optimization_Guide.md](axi_interconnect_signals/Wrapper_Optimization_Guide.md))

#### Top-Level Entity Not Found

**Giải pháp**:
- Set top-level entity trong Project Settings
- Hoặc chạy `add_all_source_files.tcl` (tự động set)

#### Design Unit Not Found

**Giải pháp**:
- Kiểm tra file đã được thêm vào project chưa
- Chạy `add_files.tcl` để add file
- Kiểm tra thứ tự compile (dependencies phải compile trước)

### ModelSim Issues

#### File Not Found

**Giải pháp**:
- Kiểm tra paths trong TCL scripts
- Sử dụng relative paths từ `sim/modelsim/`

#### Compilation Errors

**Giải pháp**:
- Compile dependencies trước
- Kiểm tra include paths

---

## 📊 Tổng Kết

### Điểm Mạnh

✅ Cấu trúc rõ ràng và logic  
✅ Tài liệu đầy đủ và có tổ chức  
✅ Wrapper modules dễ sử dụng  
✅ IP modules self-contained  
✅ Testbenches đầy đủ  

### Cần Cải Thiện

⚠️ Một số tài liệu đang phát triển (user_guides, specifications, api_reference)  
⚠️ Cần tối ưu wrapper để giảm I/O pins (nếu cần)  

---

## 🔗 Liên Kết Nhanh

### Source Code
- [Wrapper Modules](../../src/wrapper/README.md)
- [AXI Interconnect Signals](axi_interconnect_signals/README.md)

### Documentation
- [Architecture](architecture/README.md)
- [Design Notes](design_notes/README.md)
- [Meta Documentation](meta/README.md)

### Simulation
- [Quartus](../../sim/quartus/README.md)
- [ModelSim](../../sim/modelsim/docs/README.md)

### Testbenches
- [Wrapper Testbenches](../../tb/wrapper_tb/README.md)
- [Utils Testbenches](../../tb/utils_tb/README.md)

---

## 📝 Cập Nhật Tài Liệu

Khi thêm tài liệu mới:

1. **Thêm vào mục lục** trong README.md tương ứng
2. **Cập nhật cross-references** giữa các file
3. **Kiểm tra tính nhất quán** với code thực tế
4. **Cập nhật file này** nếu cần

---

**Tài liệu này tổng hợp từ tất cả README.md trong dự án, được cập nhật lần cuối: 2025-11-24**

