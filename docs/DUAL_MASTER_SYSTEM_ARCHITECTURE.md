# Kiến Trúc Dual Master System - 2 Masters & 4 Slaves

> **Hướng dẫn export sang JPG:**
> 1. Sử dụng Mermaid Live Editor: https://mermaid.live/
> 2. Copy diagram vào editor
> 3. Click "Actions" -> "Download PNG" hoặc "Download SVG"
> 4. Convert PNG sang JPG nếu cần

---

## Diagram Tổng Quát - Kiến Trúc Hệ Thống

```mermaid
graph TB
    subgraph "MASTERS"
        SERV["SERV RISC-V Core<br/>PC = 0x00000000<br/>Reset Vector"]
        ALU["ALU Master<br/>CPU Controller<br/>PC = 0x00000000"]
    end
    
    subgraph "CONVERTERS"
        SERV_WB["serv_axi_wrapper<br/>(Wishbone → AXI)<br/>Instruction Bus"]
        SERV_DATA_DIRECT["SERV Data Bus<br/>(Direct Connection)"]
        ALU_MASTER["CPU_ALU_Master<br/>(AXI Master Interface)"]
    end
    
    subgraph "AXI INTERCONNECT"
        INTERCONNECT["AXI Interconnect Full<br/>- Address Decoder<br/>- Read Arbiter (QoS)<br/>- Write Arbiter (Fixed Priority)<br/>- 2 Master Ports (S00, S01)<br/>- 4 Slave Ports (M00-M03)"]
    end
    
    subgraph "MEMORY SLAVES"
        M00["M00: Instruction Memory<br/>(ROM)<br/>Address: 0x0000_0000 - 0x3FFF_FFFF<br/>Size: 256 words"]
        M01["M01: Data Memory<br/>(RAM)<br/>Address: 0x4000_0000 - 0x7FFF_FFFF<br/>Size: 256 words"]
        M02["M02: ALU Memory<br/>(RAM)<br/>Address: 0x8000_0000 - 0xBFFF_FFFF<br/>Size: 256 words"]
        M03["M03: Reserved Memory<br/>(ROM)<br/>Address: 0xC000_0000 - 0xFFFF_FFFF<br/>Size: 256 words"]
    end
    
    %% SERV Connections
    SERV -->|"Wishbone<br/>Instruction Bus"| SERV_WB
    SERV -->|"Wishbone<br/>Data Bus"| SERV_DATA_DIRECT
    
    SERV_WB -->|"S00_AXI<br/>(Read Only)<br/>AR Channel"| INTERCONNECT
    SERV_DATA_DIRECT -->|"Direct AXI<br/>(Bypass Interconnect)<br/>AR/AW/W/B Channels"| M01
    
    %% ALU Master Connections
    ALU -->|"Control Signals<br/>start/busy/done"| ALU_MASTER
    ALU_MASTER -->|"S02_AXI<br/>(Direct Connection)<br/>AR/AW/W/B Channels"| M02
    
    %% Interconnect to Slaves
    INTERCONNECT -->|"M00_AXI<br/>(Read Only)<br/>AR/R Channels"| M00
    INTERCONNECT -->|"M01_AXI<br/>(Read-Write)<br/>AR/AW/W/B Channels"| M01
    INTERCONNECT -.->|"M02_AXI<br/>(Not Used)"| M02
    INTERCONNECT -->|"M03_AXI<br/>(Read Only)<br/>AR/R Channels"| M03
    
    %% Data Flow Labels
    SERV_WB -.->|"1. Instruction Fetch<br/>PC = 0x00000000<br/>→ 0x00000000"| INTERCONNECT
    SERV_DATA_DIRECT -.->|"2. Data Read/Write<br/>0x40000000+"| M01
    ALU_MASTER -.->|"3. ALU Operations<br/>0x80000000+<br/>Read: Instructions/Operands<br/>Write: Results"| M02
    
    %% Styling
    style SERV fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    style ALU fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    style SERV_WB fill:#fff4e1,stroke:#e65100,stroke-width:2px
    style SERV_DATA_DIRECT fill:#fff4e1,stroke:#e65100,stroke-width:2px
    style ALU_MASTER fill:#fff4e1,stroke:#e65100,stroke-width:2px
    style INTERCONNECT fill:#f3e5f5,stroke:#4a148c,stroke-width:3px
    style M00 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style M01 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style M02 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style M03 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
```

---

## Diagram Chi Tiết - Luồng Dữ Liệu AXI

```mermaid
graph LR
    subgraph "MASTER 0: SERV RISC-V"
        SERV_INST["SERV Instruction Bus<br/>S00_AXI"]
        SERV_DATA["SERV Data Bus<br/>(Bypass Interconnect)"]
    end
    
    subgraph "MASTER 1: ALU Master"
        ALU_AXI["ALU Master<br/>S02_AXI<br/>(Direct to M02)"]
    end
    
    subgraph "AXI INTERCONNECT"
        ARB["Arbitration &<br/>Address Decoding"]
    end
    
    subgraph "SLAVE 0: Instruction Memory"
        INST_MEM["ROM Slave<br/>M00_AXI<br/>0x0000_0000 - 0x3FFF_FFFF"]
    end
    
    subgraph "SLAVE 1: Data Memory"
        DATA_MEM["RAM Slave<br/>M01_AXI<br/>0x4000_0000 - 0x7FFF_FFFF"]
    end
    
    subgraph "SLAVE 2: ALU Memory"
        ALU_MEM["RAM Slave<br/>M02_AXI<br/>0x8000_0000 - 0xBFFF_FFFF"]
    end
    
    subgraph "SLAVE 3: Reserved Memory"
        RESERVED_MEM["ROM Slave<br/>M03_AXI<br/>0xC000_0000 - 0xFFFF_FFFF"]
    end
    
    %% Connections
    SERV_INST -->|"Read Channel<br/>AR/R"| ARB
    SERV_DATA -->|"Direct<br/>AR/AW/W/B"| DATA_MEM
    ALU_AXI -->|"Direct<br/>AR/AW/W/B"| ALU_MEM
    
    ARB -->|"M00_AXI<br/>Read Only"| INST_MEM
    ARB -->|"M01_AXI<br/>Read-Write"| DATA_MEM
    ARB -->|"M03_AXI<br/>Read Only"| RESERVED_MEM
    
    %% Styling
    style SERV_INST fill:#e1f5ff,stroke:#01579b
    style SERV_DATA fill:#e1f5ff,stroke:#01579b
    style ALU_AXI fill:#e1f5ff,stroke:#01579b
    style ARB fill:#f3e5f5,stroke:#4a148c,stroke-width:3px
    style INST_MEM fill:#e8f5e9,stroke:#1b5e20
    style DATA_MEM fill:#e8f5e9,stroke:#1b5e20
    style ALU_MEM fill:#e8f5e9,stroke:#1b5e20
    style RESERVED_MEM fill:#e8f5e9,stroke:#1b5e20
```

---

## Diagram Kết Nối AXI Channels

```mermaid
graph TB
    subgraph "SERV RISC-V Core"
        SERV_CORE["SERV Core<br/>Wishbone Interface"]
    end
    
    subgraph "SERV Instruction Path"
        SERV_WB["serv_axi_wrapper<br/>WB → AXI"]
        S00["S00_AXI Port<br/>(Interconnect Input)"]
    end
    
    subgraph "SERV Data Path"
        SERV_DATA_DIRECT["Direct AXI Connection<br/>(Bypass Interconnect)"]
    end
    
    subgraph "ALU Master Path"
        ALU_CTRL["CPU_Controller"]
        ALU_MASTER["CPU_ALU_Master<br/>AXI Master"]
        S02["S02_AXI Port<br/>(Direct to M02)"]
    end
    
    subgraph "AXI Interconnect"
        IC["AXI Interconnect Full<br/>S00 → M00, M01, M03<br/>S01 → (Not Used)"]
    end
    
    subgraph "Memory Slaves"
        M00_SLAVE["M00: Instruction Memory<br/>AR/R Channels"]
        M01_SLAVE["M01: Data Memory<br/>AR/AW/W/B Channels"]
        M02_SLAVE["M02: ALU Memory<br/>AR/AW/W/B Channels"]
        M03_SLAVE["M03: Reserved Memory<br/>AR/R Channels"]
    end
    
    %% SERV Instruction Flow
    SERV_CORE -->|"WB Instruction"| SERV_WB
    SERV_WB -->|"S00_AXI<br/>AR/R"| S00
    S00 --> IC
    IC -->|"M00_AXI<br/>AR/R"| M00_SLAVE
    
    %% SERV Data Flow (Bypass)
    SERV_CORE -->|"WB Data"| SERV_DATA_DIRECT
    SERV_DATA_DIRECT -->|"Direct AXI<br/>AR/AW/W/B"| M01_SLAVE
    
    %% ALU Master Flow (Bypass)
    ALU_CTRL -->|"Control"| ALU_MASTER
    ALU_MASTER -->|"S02_AXI<br/>AR/AW/W/B"| S02
    S02 -->|"Direct<br/>AR/AW/W/B"| M02_SLAVE
    
    %% Interconnect to other slaves
    IC -->|"M01_AXI<br/>(Not Used)"| M01_SLAVE
    IC -->|"M03_AXI<br/>AR/R"| M03_SLAVE
    
    %% Styling
    style SERV_CORE fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    style ALU_CTRL fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    style SERV_WB fill:#fff4e1,stroke:#e65100,stroke-width:2px
    style SERV_DATA_DIRECT fill:#fff4e1,stroke:#e65100,stroke-width:2px
    style ALU_MASTER fill:#fff4e1,stroke:#e65100,stroke-width:2px
    style IC fill:#f3e5f5,stroke:#4a148c,stroke-width:3px
    style M00_SLAVE fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style M01_SLAVE fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style M02_SLAVE fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style M03_SLAVE fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
```

---

## Bảng Tóm Tắt Kết Nối

| Master | Bus Type | Interconnect Port | Target Slave | Address Range | Operation |
|--------|----------|-------------------|--------------|--------------|-----------|
| SERV | Instruction | S00_AXI | M00 (Instruction Memory) | 0x0000_0000 - 0x3FFF_FFFF | Read Only |
| SERV | Data | Direct (Bypass) | M01 (Data Memory) | 0x4000_0000 - 0x7FFF_FFFF | Read/Write |
| ALU Master | ALU | S02_AXI (Direct) | M02 (ALU Memory) | 0x8000_0000 - 0xBFFF_FFFF | Read/Write |
| - | - | M03_AXI | M03 (Reserved Memory) | 0xC000_0000 - 0xFFFF_FFFF | Read Only |

---

## Ghi Chú Quan Trọng

1. **SERV Data Bus Bypass**: SERV Data Bus được kết nối trực tiếp đến M01 (Data Memory), không qua Interconnect để tối ưu hiệu suất.

2. **ALU Master Direct Connection**: ALU Master được kết nối trực tiếp đến M02 (ALU Memory), bypass Interconnect vì Interconnect chỉ hỗ trợ 2 master ports (S00, S01).

3. **Interconnect Master Ports**:
   - **S00**: SERV Instruction Bus (Read Only)
   - **S01**: Không sử dụng (SERV Data đã bypass)

4. **Interconnect Slave Ports**:
   - **M00**: Instruction Memory (từ S00)
   - **M01**: Data Memory (từ S00, nhưng SERV Data bypass nên không dùng)
   - **M02**: ALU Memory (direct từ ALU Master)
   - **M03**: Reserved Memory (từ S00)

5. **Address Decoding**: Interconnect sử dụng Address Decoder để route transactions dựa trên address range.

6. **Arbitration**:
   - **Read Channel**: QoS-based arbitration
   - **Write Channel**: Fixed Priority (Master 0 > Master 1)

---

## Cách Export Sang JPG

### Phương pháp 1: Mermaid Live Editor (Khuyến nghị)

1. Truy cập: https://mermaid.live/
2. Copy từng diagram (từ ````mermaid` đến ````) vào editor
3. Click "Actions" -> "Download PNG"
4. Convert PNG sang JPG nếu cần

### Phương pháp 2: Mermaid CLI

```bash
# Cài đặt Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export từng diagram
mmdc -i architecture.mmd -o architecture.jpg -b white
mmdc -i dataflow.mmd -o dataflow.jpg -b white
mmdc -i connections.mmd -o connections.jpg -b white
```

### Phương pháp 3: VS Code Extension

1. Cài đặt extension "Markdown Preview Mermaid Support"
2. Mở file .md trong VS Code
3. Preview diagram
4. Right-click -> "Save Image As..." -> chọn JPG



