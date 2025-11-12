# Cấu Trúc Hệ Thống Hoàn Chỉnh

## Tài liệu này mô tả chi tiết cấu trúc của 2 module chính:
1. **dual_master_system.v** - Hệ thống 2 Masters + 4 Slaves
2. **serv_axi_system_ip.v** - IP Module hoàn chỉnh cho SERV RISC-V

---

# 1. dual_master_system.v

## 1.1. Tổng Quan

Module tích hợp 2 masters (SERV RISC-V + ALU Master) với 4 slave memories thông qua AXI Interconnect.

### Mục đích:
- SERV RISC-V: Thực thi chương trình RISC-V
- ALU Master: Thực hiện các phép toán ALU độc lập
- 4 Slaves: Instruction Memory, Data Memory, ALU Memory, Reserved

---

## 1.2. Kiến Trúc Tổng Thể

```
┌─────────────────────────────────────────────────────────────────┐
│                    dual_master_system                            │
│                                                                  │
│  ┌──────────────────┐         ┌──────────────────┐            │
│  │  SERV RISC-V     │         │   ALU Master     │            │
│  │     Core         │         │  CPU_ALU_Master  │            │
│  └────────┬─────────┘         └────────┬─────────┘            │
│           │                             │                      │
│  ┌────────▼─────────┐                  │                      │
│  │ serv_axi_wrapper │                  │                      │
│  └────────┬─────────┘                  │                      │
│           │                                  │                      │
│    ┌──────┴──────┐                          │                      │
│    │            │                          │                      │
│ [M0_AXI]    [M1_AXI]                    [M_AXI]                  │
│ (Inst Bus) (Data Bus)                  (ALU Bus)                │
│    │            │                          │                      │
│    └──────┬─────┘                          │                      │
│           │                                │                      │
│           └────────┬───────────────────────┘                      │
│                    │                                              │
│         ┌──────────▼──────────┐                                   │
│         │ AXI_Interconnect_Full│                                   │
│         │  (2 Masters → 4 Slaves)                                │
│         └──────────┬──────────┘                                   │
│                    │                                              │
│    ┌───────────────┼───────────────┬───────────────┐            │
│    │               │               │               │            │
│ [M00_AXI]    [M01_AXI]      [M02_AXI]      [M03_AXI]            │
│ (Slave 0)    (Slave 1)      (Slave 2)      (Slave 3)            │
│ Instruction  Data Memory   ALU Memory     Reserved              │
│ Memory (ROM)  (RAM)         (RAM)         (Read-only)           │
│    │               │               │               │            │
│    └───────────────┴───────────────┴───────────────┘            │
│                    │                                              │
│         [External Slave Interfaces]                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1.3. Các Thành Phần

### 1.3.1. SERV RISC-V Wrapper (`serv_axi_wrapper`)
- **Module**: `serv_axi_wrapper`
- **Chức năng**: Kết nối SERV RISC-V core với AXI4
- **2 AXI Master Ports**:
  - **M0_AXI**: Instruction Bus (Read-only)
    - Chỉ có Read Address Channel (AR) và Read Data Channel (R)
    - Không có Write channels
  - **M1_AXI**: Data Bus (Read-write)
    - Đầy đủ Write Address (AW), Write Data (W), Write Response (B)
    - Đầy đủ Read Address (AR), Read Data (R)

### 1.3.2. ALU Master (`CPU_ALU_Master`)
- **Module**: `CPU_ALU_Master`
- **Chức năng**: Thực hiện các phép toán ALU độc lập
- **1 AXI Master Port**:
  - **M_AXI**: Full AXI4 interface (Read-write)
  - **Lưu ý**: ALU Master được kết nối TRỰC TIẾP với M02 (bypass interconnect)
  - **Lý do**: AXI_Interconnect_Full chỉ hỗ trợ 2 masters (S00, S01)

### 1.3.3. AXI Interconnect (`AXI_Interconnect_Full`)
- **Module**: `AXI_Interconnect_Full`
- **Cấu hình**:
  - **2 Master Ports** (S00, S01):
    - S00: SERV Instruction Bus (Read-only)
    - S01: SERV Data Bus (Read-write)
  - **4 Slave Ports** (M00, M01, M02, M03):
    - M00: Instruction Memory (Read-only)
    - M01: Data Memory (Read-write)
    - M02: ALU Memory (Read-write) - **KHÔNG qua interconnect**
    - M03: Reserved (Read-only)

### 1.3.4. Kết Nối ALU Master
- **Hiện tại**: ALU Master kết nối TRỰC TIẾP với M02 (bypass interconnect)
- **Cách kết nối**: Dùng `assign` statements (lines 521-563)
- **Lý do**: Interconnect chỉ hỗ trợ 2 masters, nhưng cần 3 masters
- **TODO**: Cần cải thiện để ALU Master đi qua interconnect

---

## 1.4. Address Mapping

### Decoding Logic:
- Sử dụng **bits [31:30]** của địa chỉ để decode slave
- Address ranges phải match với decoder logic

| Bits [31:30] | Slave | Address Range | Mô tả |
|---------------|-------|---------------|-------|
| `00` | M00 | `0x0000_0000 - 0x3FFF_FFFF` | Instruction Memory (ROM) |
| `01` | M01 | `0x4000_0000 - 0x7FFF_FFFF` | Data Memory (RAM) |
| `10` | M02 | `0x8000_0000 - 0xBFFF_FFFF` | ALU Memory (RAM) |
| `11` | M03 | `0xC000_0000 - 0xFFFF_FFFF` | Reserved |

### Routing Logic:
- **SERV Instruction Bus (S00)** → Luôn route đến **M00** (Instruction Memory)
- **SERV Data Bus (S01)** → Route đến **M01** (Data Memory) dựa trên address
- **ALU Master (S02)** → Kết nối trực tiếp với **M02** (bypass interconnect)

---

## 1.5. Interface Ports

### 1.5.1. Global Signals
```verilog
input  wire    ACLK,        // AXI Clock
input  wire    ARESETN,     // AXI Reset (active low)
input  wire    i_timer_irq, // Timer interrupt (optional)
```

### 1.5.2. ALU Master Control
```verilog
input  wire    alu_master_start,  // Start ALU operation
output wire    alu_master_busy,   // ALU is busy
output wire    alu_master_done,   // ALU operation done
```

### 1.5.3. Slave Interfaces (External)
Module expose 4 slave interfaces để kết nối với external memory slaves:

- **M00_AXI**: Instruction Memory Interface (Read-only)
  - AR channel: `araddr`, `arlen`, `arsize`, `arburst`, `arlock`, `arcache`, `arprot`, `arregion`, `arqos`, `arvalid`, `arready`
  - R channel: `rdata`, `rresp`, `rlast`, `rvalid`, `rready`

- **M01_AXI**: Data Memory Interface (Read-write)
  - AW channel: `awid`, `awaddr`, `awlen`, `awsize`, `awburst`, `awlock`, `awcache`, `awprot`, `awqos`, `awregion`, `awvalid`, `awready`
  - W channel: `wdata`, `wstrb`, `wlast`, `wvalid`, `wready`
  - B channel: `bid`, `bresp`, `bvalid`, `bready`
  - AR channel: `arid`, `araddr`, `arlen`, `arsize`, `arburst`, `arlock`, `arcache`, `arprot`, `arqos`, `arregion`, `arvalid`, `arready`
  - R channel: `rid`, `rdata`, `rresp`, `rlast`, `rvalid`, `rready`

- **M02_AXI**: ALU Memory Interface (Read-write) - Tương tự M01
- **M03_AXI**: Reserved Interface (Read-only) - Tương tự M00

---

## 1.6. Internal Signals

### 1.6.1. SERV Wrapper Signals
- **S00_AXI_***: Instruction Bus signals (Read-only)
- **S01_AXI_***: Data Bus signals (Read-write)

### 1.6.2. ALU Master Signals
- **S02_AXI_***: ALU Master signals (Read-write)

### 1.6.3. Tie-off Wires
- `M00_AXI_bready_tie = 1'b0`: Read-only slave, tie off write response

---

## 1.7. Data Flow

### 1.7.1. Instruction Fetch (SERV)
```
SERV Core → serv_axi_wrapper → M0_AXI (S00_AXI) 
→ AXI_Interconnect_Full → M00_AXI → External Instruction Memory
```

### 1.7.2. Data Access (SERV)
```
SERV Core → serv_axi_wrapper → M1_AXI (S01_AXI)
→ AXI_Interconnect_Full → M01_AXI → External Data Memory
```

### 1.7.3. ALU Operation
```
ALU Master → M_AXI (S02_AXI) → Direct Connection (assign)
→ M02_AXI → External ALU Memory
```

---

## 1.8. Parameters

### AXI Parameters
- `ADDR_WIDTH = 32`
- `DATA_WIDTH = 32`
- `ID_WIDTH = 4`

### SERV Parameters
- `WITH_CSR = 1`
- `W = 1`
- `PRE_REGISTER = 1`
- `RESET_STRATEGY = "MINI"`
- `RESET_PC = 32'h0000_0000`
- `DEBUG = 1'b0`
- `MDU = 1'b0`
- `COMPRESSED = 0`

### Interconnect Parameters
- `Masters_Num = 2`
- `Num_Of_Masters = 2`
- `Num_Of_Slaves = 4`
- `Address_width = 32`
- Various AXI4 burst length and bus width parameters

### Address Mapping Parameters
- `SLAVE0_ADDR1 = 32'h0000_0000`, `SLAVE0_ADDR2 = 32'h3FFF_FFFF`
- `SLAVE1_ADDR1 = 32'h4000_0000`, `SLAVE1_ADDR2 = 32'h7FFF_FFFF`
- `SLAVE2_ADDR1 = 32'h8000_0000`, `SLAVE2_ADDR2 = 32'hBFFF_FFFF`
- `SLAVE3_ADDR1 = 32'hC000_0000`, `SLAVE3_ADDR2 = 32'hFFFF_FFFF`

---

## 1.9. Limitations & TODO

### Limitations:
1. **ALU Master bypass interconnect**: ALU Master kết nối trực tiếp với M02, không qua interconnect
2. **Interconnect chỉ hỗ trợ 2 masters**: Cần upgrade để hỗ trợ 3+ masters
3. **M02 không được route qua interconnect**: M02 signals được tie-off trong interconnect

### TODO:
1. Upgrade `AXI_Interconnect_Full` để hỗ trợ 3 masters
2. Kết nối ALU Master qua interconnect thay vì direct connection
3. Implement proper arbitration cho 3 masters

---

# 2. serv_axi_system_ip.v

## 2.1. Tổng Quan

Module IP hoàn chỉnh tích hợp SERV RISC-V với AXI Interconnect và Memory Slaves.

### Mục đích:
- Tạo một IP module self-contained
- Bao gồm: CPU, Interconnect, và Memories
- Chỉ expose global signals và optional status signals

---

## 2.2. Kiến Trúc Tổng Thể

```
┌─────────────────────────────────────────────────────────────────┐
│                  serv_axi_system_ip                              │
│                                                                  │
│  ┌──────────────────┐                                           │
│  │  SERV RISC-V     │                                           │
│  │     Core         │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│  ┌────────▼─────────┐                                           │
│  │ serv_axi_wrapper │                                           │
│  └────────┬─────────┘                                           │
│           │                                                      │
│    ┌──────┴──────┐                                              │
│    │            │                                               │
│ [M0_AXI]    [M1_AXI]                                           │
│ (Inst Bus) (Data Bus)                                          │
│    │            │                                               │
│    └──────┬─────┘                                               │
│           │                                                      │
│         ┌─▼──────────────────────┐                              │
│         │ AXI_Interconnect_Full  │                              │
│         │  (2 Masters → 2 Slaves)                              │
│         └─┬──────────────────────┘                              │
│           │                                                      │
│    ┌──────┴──────┐                                              │
│    │            │                                               │
│ [M00_AXI]  [M01_AXI]                                           │
│    │            │                                               │
│    │            │                                               │
│ ┌──▼──┐    ┌────▼────┐                                         │
│ │ ROM │    │   RAM   │                                         │
│ │Slave│    │  Slave  │                                         │
│ │(Inst│    │ (Data   │                                         │
│ │ Mem)│    │  Mem)   │                                         │
│ └─────┘    └─────────┘                                         │
│                                                                  │
│  [Global Signals Only]                                          │
│  - ACLK, ARESETN                                                │
│  - i_timer_irq                                                  │
│  - inst_mem_ready, data_mem_ready (optional)                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2.3. Các Thành Phần

### 2.3.1. SERV RISC-V Wrapper (`serv_axi_wrapper`)
- **Module**: `serv_axi_wrapper`
- **Chức năng**: Tương tự như trong `dual_master_system.v`
- **2 AXI Master Ports**:
  - **M0_AXI**: Instruction Bus (Read-only)
  - **M1_AXI**: Data Bus (Read-write)

### 2.3.2. AXI Interconnect (`AXI_Interconnect_Full`)
- **Module**: `AXI_Interconnect_Full`
- **Cấu hình**:
  - **2 Master Ports** (S00, S01):
    - S00: SERV Instruction Bus (Read-only)
    - S01: SERV Data Bus (Read-write)
  - **2 Slave Ports** (M00, M01):
    - M00: Instruction Memory (Read-only)
    - M01: Data Memory (Read-write)
  - **M02, M03**: Tie-off (unused)

### 2.3.3. Memory Slaves (Internal)

#### Instruction Memory (`axi_rom_slave`)
- **Module**: `axi_rom_slave`
- **Chức năng**: Read-only memory cho instructions
- **Parameters**:
  - `ADDR_WIDTH = 32`
  - `DATA_WIDTH = 32`
  - `ID_WIDTH = 4`
  - `MEM_SIZE = INST_MEM_SIZE` (default: 1024 words)
  - `MEM_INIT_FILE = INST_MEM_INIT_FILE` (hex file path)
- **Interface**: AXI4 Read-only (AR + R channels)

#### Data Memory (`axi_memory_slave`)
- **Module**: `axi_memory_slave`
- **Chức năng**: Read-write memory cho data
- **Parameters**: Tương tự `axi_rom_slave`
- **Interface**: AXI4 Full (AW + W + B + AR + R channels)

---

## 2.4. Address Mapping

### Decoding Logic:
- Sử dụng **bits [31:30]** của địa chỉ để decode slave

| Bits [31:30] | Slave | Address Range | Mô tả |
|---------------|-------|---------------|-------|
| `00` | M00 | `0x0000_0000 - 0x3FFF_FFFF` | Instruction Memory (ROM) |
| `01` | M01 | `0x4000_0000 - 0x7FFF_FFFF` | Data Memory (RAM) |

### Routing Logic:
- **SERV Instruction Bus (S00)** → Luôn route đến **M00** (Instruction Memory)
- **SERV Data Bus (S01)** → Route đến **M01** (Data Memory) dựa trên address

---

## 2.5. Interface Ports

### 2.5.1. Global Signals (External)
```verilog
input  wire    ACLK,           // AXI Clock
input  wire    ARESETN,        // AXI Reset (active low)
input  wire    i_timer_irq,    // Timer interrupt (optional)
```

### 2.5.2. Status Outputs (Optional)
```verilog
output wire    inst_mem_ready,  // Instruction memory ready
output wire    data_mem_ready,  // Data memory ready
```

**Lưu ý**: Module này là **self-contained**, không expose AXI slave interfaces ra ngoài.

---

## 2.6. Internal Signals

### 2.6.1. SERV Wrapper Signals
- **S00_AXI_***: Instruction Bus signals (Read-only)
- **S01_AXI_***: Data Bus signals (Read-write)

### 2.6.2. Interconnect to Memory Signals
- **M00_AXI_***: Instruction Memory interface signals
- **M01_AXI_***: Data Memory interface signals

### 2.6.3. Tie-off Wires
- `M00_AXI_bready_tie = 1'b0`: Read-only slave, tie off write response
- `M02_AXI_rready_tie = 1'b0`: Unused slave, tie off
- `M03_AXI_rready_tie = 1'b0`: Unused slave, tie off

---

## 2.7. Data Flow

### 2.7.1. Instruction Fetch
```
SERV Core → serv_axi_wrapper → M0_AXI (S00_AXI)
→ AXI_Interconnect_Full → M00_AXI
→ axi_rom_slave (u_inst_mem)
```

### 2.7.2. Data Access
```
SERV Core → serv_axi_wrapper → M1_AXI (S01_AXI)
→ AXI_Interconnect_Full → M01_AXI
→ axi_memory_slave (u_data_mem)
```

---

## 2.8. Parameters

### AXI Parameters
- `ADDR_WIDTH = 32`
- `DATA_WIDTH = 32`
- `ID_WIDTH = 4`

### SERV Parameters
- Tương tự `dual_master_system.v`

### Memory Parameters
- `INST_MEM_SIZE = 1024` (words, default)
- `DATA_MEM_SIZE = 1024` (words, default)
- `INST_MEM_INIT_FILE = ""` (hex file path, optional)
- `DATA_MEM_INIT_FILE = ""` (hex file path, optional)

### Address Mapping Parameters
- `SLAVE0_ADDR1 = 32'h0000_0000`, `SLAVE0_ADDR2 = 32'h3FFF_FFFF`
- `SLAVE1_ADDR1 = 32'h4000_0000`, `SLAVE1_ADDR2 = 32'h7FFF_FFFF`

---

## 2.9. Memory Initialization

### Instruction Memory
- Có thể khởi tạo từ file hex thông qua parameter `INST_MEM_INIT_FILE`
- Format: Hex file với mỗi dòng là một instruction (32-bit)
- Ví dụ: `"../../sim/modelsim/test_program_simple.hex"`

### Data Memory
- Có thể khởi tạo từ file hex thông qua parameter `DATA_MEM_INIT_FILE`
- Format: Tương tự instruction memory

---

## 2.10. Status Outputs

### inst_mem_ready
- **Logic**: `M00_AXI_arready`
- **Ý nghĩa**: Instruction memory sẵn sàng nhận read request

### data_mem_ready
- **Logic**: `M01_AXI_awready | M01_AXI_arready`
- **Ý nghĩa**: Data memory sẵn sàng nhận write hoặc read request

---

## 2.11. So Sánh với dual_master_system.v

| Đặc điểm | dual_master_system.v | serv_axi_system_ip.v |
|----------|---------------------|---------------------|
| **Masters** | 2 (SERV + ALU) | 1 (SERV only) |
| **Slaves** | 4 (external) | 2 (internal) |
| **Memory** | External (exposed ports) | Internal (axi_rom_slave, axi_memory_slave) |
| **Interface** | Expose AXI slave ports | Only global signals |
| **Use Case** | System integration | IP module |
| **ALU Support** | Yes | No |

---

## 2.12. Usage Example

```verilog
serv_axi_system_ip #(
    .ADDR_WIDTH         (32),
    .DATA_WIDTH         (32),
    .ID_WIDTH           (4),
    .INST_MEM_SIZE      (1024),
    .DATA_MEM_SIZE      (1024),
    .INST_MEM_INIT_FILE ("path/to/program.hex"),
    .DATA_MEM_INIT_FILE ("")
) u_serv_system (
    .ACLK           (clk),
    .ARESETN        (rstn),
    .i_timer_irq    (1'b0),
    .inst_mem_ready (),
    .data_mem_ready ()
);
```

---

# 3. Tổng Kết

## 3.1. dual_master_system.v
- **Mục đích**: System-level integration với 2 masters và 4 external slaves
- **Đặc điểm**: Expose AXI slave interfaces để kết nối external memories
- **Use case**: Top-level system với nhiều masters và slaves

## 3.2. serv_axi_system_ip.v
- **Mục đích**: Self-contained IP module
- **Đặc điểm**: Bao gồm memories bên trong, chỉ expose global signals
- **Use case**: IP block để tích hợp vào system lớn hơn

## 3.3. Lựa Chọn Module

**Dùng `dual_master_system.v` khi:**
- Cần 2 masters (SERV + ALU)
- Cần kết nối external memories
- Cần control từng slave interface riêng biệt

**Dùng `serv_axi_system_ip.v` khi:**
- Chỉ cần SERV RISC-V
- Muốn IP module self-contained
- Không cần control chi tiết memory interfaces
- Muốn đơn giản hóa integration

---

# 4. Notes

## 4.1. Address Decoding
- Cả 2 modules đều sử dụng **bits [31:30]** để decode slave
- Address ranges phải match với decoder logic trong interconnect

## 4.2. AXI Protocol
- Tất cả interfaces đều tuân thủ AXI4 protocol
- Read-only slaves (M00) không có write channels
- Write channels được tie-off cho read-only slaves

## 4.3. Clock Domain
- Tất cả components share cùng clock (`ACLK`)
- Tất cả components share cùng reset (`ARESETN`)

---

*Tài liệu này được tạo tự động dựa trên phân tích code.*

