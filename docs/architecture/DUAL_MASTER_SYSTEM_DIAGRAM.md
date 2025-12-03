# Dual Master System IP - Detailed Architecture Diagram

## Module: `dual_master_system_ip`

Complete IP module integrating SERV RISC-V Core, ALU Master, AXI Interconnect, and 4 Memory Slaves.

---

## 1. System Architecture Overview

```mermaid
graph TB
    subgraph "dual_master_system_ip"
        subgraph "Masters"
            SERV[serv_axi_wrapper<br/>SERV RISC-V Core]
            ALU[CPU_ALU_Master<br/>ALU Master]
        end
        
        subgraph "Interconnect"
            IC[AXI_Interconnect_Full<br/>2 Masters → 4 Slaves]
        end
        
        subgraph "Memory Slaves"
            M00[axi_memory_slave<br/>Instruction Memory<br/>Read-only]
            M01[axi_memory_slave<br/>Data Memory<br/>Read-write]
            M02[axi_memory_slave<br/>ALU Memory<br/>Read-write]
            M03[axi_memory_slave<br/>Reserved Memory<br/>Read-only]
        end
        
        SERV -->|M0_AXI<br/>Read-only| IC
        SERV -->|M1_AXI<br/>Read-write| IC
        ALU -->|M_AXI<br/>Direct Connection<br/>Bypass IC| M02
        
        IC -->|M00_AXI<br/>Read-only| M00
        IC -->|M01_AXI<br/>Read-write| M01
        IC -->|M03_AXI<br/>Read-only| M03
    end
    
    EXT[External Signals<br/>ACLK, ARESETN<br/>i_timer_irq<br/>alu_master_start] --> SERV
    EXT --> ALU
    SERV --> STATUS[Status Outputs<br/>inst_mem_ready<br/>data_mem_ready<br/>alu_mem_ready<br/>reserved_mem_ready]
    ALU --> STATUS2[ALU Status<br/>alu_master_busy<br/>alu_master_done]
```

---

## 2. Detailed AXI Connection Diagram

```mermaid
graph LR
    subgraph "SERV AXI Wrapper"
        SERV_CORE[SERV RISC-V Core]
        SERV_CORE -->|Instruction Bus| M0[M0_AXI<br/>Read-only]
        SERV_CORE -->|Data Bus| M1[M1_AXI<br/>Read-write]
    end
    
    subgraph "AXI Interconnect"
        IC[AXI_Interconnect_Full]
        S00[S00: SERV Inst Bus<br/>Read-only]
        S01[S01: SERV Data Bus<br/>Read-write]
        
        M0 --> S00
        M1 --> S01
        
        S00 --> IC
        S01 --> IC
        
        IC --> M00_OUT[M00: Inst Memory]
        IC --> M01_OUT[M01: Data Memory]
        IC --> M03_OUT[M03: Reserved Memory]
    end
    
    subgraph "ALU Master"
        ALU_CORE[CPU_ALU_Master]
        ALU_AXI[M_AXI<br/>Read-write]
        ALU_CORE --> ALU_AXI
    end
    
    subgraph "Memory Slaves"
        MEM00[Instruction Memory<br/>0x0000_0000 - 0x3FFF_FFFF<br/>Read-only]
        MEM01[Data Memory<br/>0x4000_0000 - 0x7FFF_FFFF<br/>Read-write]
        MEM02[ALU Memory<br/>0x8000_0000 - 0xBFFF_FFFF<br/>Read-write]
        MEM03[Reserved Memory<br/>0xC000_0000 - 0xFFFF_FFFF<br/>Read-only]
    end
    
    M00_OUT --> MEM00
    M01_OUT --> MEM01
    ALU_AXI -.->|Direct Connection<br/>Bypass Interconnect| MEM02
    M03_OUT --> MEM03
    
    style ALU_AXI stroke-dasharray: 5 5
    style MEM02 stroke-dasharray: 5 5
```

---

## 3. AXI Channel Details

### 3.1 SERV Instruction Bus (M0_AXI / S00_AXI) - Read-only

```mermaid
graph LR
    subgraph "SERV M0_AXI"
        AR[AR Channel<br/>araddr, arlen, arsize<br/>arburst, arlock, arcache<br/>arprot, arqos, arregion<br/>arvalid, arready]
        R[R Channel<br/>rid, rdata, rresp<br/>rlast, rvalid, rready]
    end
    
    subgraph "Interconnect S00"
        S00_AR[S00_AR Channel]
        S00_R[S00_R Channel]
    end
    
    subgraph "M00 Memory"
        M00_AR[M00_AR Channel]
        M00_R[M00_R Channel]
    end
    
    AR --> S00_AR
    S00_AR --> M00_AR
    M00_R --> S00_R
    S00_R --> R
```

**Channels:**
- ✅ **Read Address (AR)**: Full channel
- ✅ **Read Data (R)**: Full channel
- ❌ **Write Address (AW)**: Not used (tied to 0)
- ❌ **Write Data (W)**: Not used (tied to 0)
- ❌ **Write Response (B)**: Not used (tied to 0)

### 3.2 SERV Data Bus (M1_AXI / S01_AXI) - Read-write

```mermaid
graph LR
    subgraph "SERV M1_AXI"
        AW1[AW Channel]
        W1[W Channel]
        B1[B Channel]
        AR1[AR Channel]
        R1[R Channel]
    end
    
    subgraph "Interconnect S01"
        S01_AW[S01_AW Channel]
        S01_W[S01_W Channel]
        S01_B[S01_B Channel]
        S01_AR[S01_AR Channel]
        S01_R[S01_R Channel]
    end
    
    subgraph "M01 Memory"
        M01_AW[M01_AW Channel]
        M01_W[M01_W Channel]
        M01_B[M01_B Channel]
        M01_AR[M01_AR Channel]
        M01_R[M01_R Channel]
    end
    
    AW1 --> S01_AW --> M01_AW
    W1 --> S01_W --> M01_W
    M01_B --> S01_B --> B1
    AR1 --> S01_AR --> M01_AR
    M01_R --> S01_R --> R1
```

**Channels:**
- ✅ **Write Address (AW)**: Full channel
- ✅ **Write Data (W)**: Full channel
- ✅ **Write Response (B)**: Full channel
- ✅ **Read Address (AR)**: Full channel
- ✅ **Read Data (R)**: Full channel

### 3.3 ALU Master (S02_AXI / M02_AXI) - Direct Connection

```mermaid
graph LR
    subgraph "ALU Master"
        ALU_AW[AW Channel<br/>awaddr, awlen, awsize<br/>awburst, awlock, awcache<br/>awprot, awregion, awqos<br/>awvalid, awready]
        ALU_W[W Channel<br/>wdata, wstrb, wlast<br/>wvalid, wready]
        ALU_B[B Channel<br/>bresp, bvalid, bready<br/>Note: No bid]
        ALU_AR[AR Channel<br/>araddr, arlen, arsize<br/>arburst, arlock, arcache<br/>arprot, arregion, arqos<br/>arvalid, arready]
        ALU_R[R Channel<br/>rdata, rresp, rlast<br/>rvalid, rready<br/>Note: No rid]
    end
    
    subgraph "M02 Memory"
        M02_AW[M02_AW Channel<br/>awid = 4'h0]
        M02_W[M02_W Channel]
        M02_B[M02_B Channel<br/>bid ignored]
        M02_AR[M02_AR Channel<br/>arid = 4'h0]
        M02_R[M02_R Channel<br/>rid ignored]
    end
    
    ALU_AW -->|Direct| M02_AW
    ALU_W -->|Direct| M02_W
    M02_B -->|Direct| ALU_B
    ALU_AR -->|Direct| M02_AR
    M02_R -->|Direct| ALU_R
    
    style ALU_AW stroke-dasharray: 5 5
    style ALU_W stroke-dasharray: 5 5
    style ALU_B stroke-dasharray: 5 5
    style ALU_AR stroke-dasharray: 5 5
    style ALU_R stroke-dasharray: 5 5
```

**Channels:**
- ✅ **Write Address (AW)**: Direct connection (bypass interconnect)
- ✅ **Write Data (W)**: Direct connection
- ✅ **Write Response (B)**: Direct connection (bid ignored)
- ✅ **Read Address (AR)**: Direct connection
- ✅ **Read Data (R)**: Direct connection (rid ignored)

**Note:** ALU Master bypasses interconnect because `AXI_Interconnect_Full` only supports 2 masters (S00, S01).

### 3.4 Reserved Memory (M03_AXI) - Read-only

```mermaid
graph LR
    subgraph "Interconnect M03"
        IC_AR[M03_AR Channel]
    end
    
    subgraph "M03 Memory"
        M03_AR[M03_AR Channel]
        M03_R[M03_R Channel]
    end
    
    IC_AR --> M03_AR
    M03_R --> IC_R[M03_R Channel]
```

**Channels:**
- ✅ **Read Address (AR)**: Full channel
- ✅ **Read Data (R)**: Full channel
- ❌ **Write Address (AW)**: Dummy wires (tied to 0)
- ❌ **Write Data (W)**: Dummy wires (tied to 0)
- ❌ **Write Response (B)**: Dummy wires (tied to 0)

---

## 4. Address Mapping

```mermaid
graph TB
    subgraph "32-bit Address Space"
        SLAVE0["Slave 0: Instruction Memory<br/>0x0000_0000 - 0x3FFF_FFFF<br/>Size: 1GB<br/>Access: Read-only"]
        SLAVE1["Slave 1: Data Memory<br/>0x4000_0000 - 0x7FFF_FFFF<br/>Size: 1GB<br/>Access: Read-write"]
        SLAVE2["Slave 2: ALU Memory<br/>0x8000_0000 - 0xBFFF_FFFF<br/>Size: 1GB<br/>Access: Read-write"]
        SLAVE3["Slave 3: Reserved Memory<br/>0xC000_0000 - 0xFFFF_FFFF<br/>Size: 1GB<br/>Access: Read-only"]
    end
    
    SERV_INST[SERV Instruction Bus<br/>M0_AXI] --> SLAVE0
    SERV_DATA[SERV Data Bus<br/>M1_AXI] --> SLAVE1
    ALU_MEM[ALU Master<br/>M_AXI] --> SLAVE2
    SERV_DATA --> SLAVE3
```

**Address Ranges:**
- **Slave 0 (M00)**: `0x0000_0000` - `0x3FFF_FFFF` (Instruction Memory, Read-only)
- **Slave 1 (M01)**: `0x4000_0000` - `0x7FFF_FFFF` (Data Memory, Read-write)
- **Slave 2 (M02)**: `0x8000_0000` - `0xBFFF_FFFF` (ALU Memory, Read-write)
- **Slave 3 (M03)**: `0xC000_0000` - `0xFFFF_FFFF` (Reserved Memory, Read-only)

---

## 5. Module Instantiation Hierarchy

```mermaid
graph TB
    TOP[dual_master_system_ip]
    
    TOP --> SERV_WRAP[serv_axi_wrapper<br/>u_serv_wrapper]
    TOP --> ALU_MASTER[CPU_ALU_Master<br/>u_alu_master]
    TOP --> AXI_IC[AXI_Interconnect_Full<br/>u_axi_interconnect]
    TOP --> MEM00[axi_memory_slave<br/>u_inst_mem]
    TOP --> MEM01[axi_memory_slave<br/>u_data_mem]
    TOP --> MEM02[axi_memory_slave<br/>u_alu_mem]
    TOP --> MEM03[axi_memory_slave<br/>u_reserved_mem]
    
    SERV_WRAP --> SERV_CORE[SERV RISC-V Core]
    SERV_WRAP --> WB2AXI0[wb2axi_read<br/>Instruction Bus]
    SERV_WRAP --> WB2AXI1[wb2axi_write<br/>Data Bus]
    
    ALU_MASTER --> ALU_CORE[ALU_Core]
    ALU_MASTER --> CPU_CTRL[CPU_Controller]
    ALU_MASTER --> AXI_MASTER[AXI Master Logic]
```

---

## 6. Signal Flow Diagram

```mermaid
sequenceDiagram
    participant SERV as SERV RISC-V
    participant IC as AXI Interconnect
    participant MEM as Memory Slaves
    
    Note over SERV,MEM: Instruction Fetch (Read-only)
    SERV->>IC: M0_AXI: AR Channel (araddr, arvalid)
    IC->>MEM: M00_AXI: AR Channel
    MEM->>IC: M00_AXI: R Channel (rdata, rvalid)
    IC->>SERV: M0_AXI: R Channel
    
    Note over SERV,MEM: Data Access (Read-write)
    SERV->>IC: M1_AXI: AW Channel (awaddr, awvalid)
    SERV->>IC: M1_AXI: W Channel (wdata, wvalid)
    IC->>MEM: M01_AXI: AW/W Channels
    MEM->>IC: M01_AXI: B Channel (bvalid)
    IC->>SERV: M1_AXI: B Channel
    
    SERV->>IC: M1_AXI: AR Channel (araddr, arvalid)
    IC->>MEM: M01_AXI: AR Channel
    MEM->>IC: M01_AXI: R Channel (rdata, rvalid)
    IC->>SERV: M1_AXI: R Channel
    
    Note over ALU,MEM: ALU Master (Direct Connection)
    participant ALU as ALU Master
    ALU->>MEM: M02_AXI: AW Channel (Direct)
    ALU->>MEM: M02_AXI: W Channel (Direct)
    MEM->>ALU: M02_AXI: B Channel (Direct)
    ALU->>MEM: M02_AXI: AR Channel (Direct)
    MEM->>ALU: M02_AXI: R Channel (Direct)
```

---

## 7. Port Interface Summary

### 7.1 Input Ports

| Port Name | Width | Description |
|-----------|-------|-------------|
| `ACLK` | 1 | Global clock signal |
| `ARESETN` | 1 | Active-low reset signal |
| `i_timer_irq` | 1 | Timer interrupt (optional) |
| `alu_master_start` | 1 | ALU Master start control signal |

### 7.2 Output Ports

| Port Name | Width | Description |
|-----------|-------|-------------|
| `alu_master_busy` | 1 | ALU Master busy status |
| `alu_master_done` | 1 | ALU Master done status |
| `inst_mem_ready` | 1 | Instruction memory ready status |
| `data_mem_ready` | 1 | Data memory ready status |
| `alu_mem_ready` | 1 | ALU memory ready status |
| `reserved_mem_ready` | 1 | Reserved memory ready status |

---

## 8. Key Design Notes

### 8.1 ALU Master Direct Connection

- **Reason**: `AXI_Interconnect_Full` only supports 2 masters (S00, S01)
- **Solution**: ALU Master (S02) connects directly to M02 memory slave
- **Implementation**: Direct `assign` statements (lines 560-607)
- **Limitation**: ALU Master cannot access other memory slaves through interconnect

### 8.2 Read-only Memory Slaves

- **M00 (Instruction Memory)**: Write channels tied to dummy wires
- **M03 (Reserved Memory)**: Write channels tied to dummy wires
- **Note**: Memory modules still instantiated with full AXI interface, but write channels are unused

### 8.3 ID Signal Handling

- **M00**: `arid` tied to `4'h0` (read-only, no ID needed)
- **M02**: `awid` and `arid` tied to `4'h0` (ALU Master doesn't use ID)
- **M02**: `bid` and `rid` from memory are connected but ignored by ALU Master

### 8.4 Status Outputs

- `inst_mem_ready`: Based on `M00_AXI_arready`
- `data_mem_ready`: Based on `M01_AXI_awready | M01_AXI_arready`
- `alu_mem_ready`: Based on `M02_AXI_awready | M02_AXI_arready`
- `reserved_mem_ready`: Based on `M03_AXI_arready`

---

## 9. Memory Configuration

| Memory | Size (words) | Init File | Address Range | Access Type |
|--------|--------------|-----------|---------------|-------------|
| Instruction | 256 (default) | `INST_MEM_INIT_FILE` | 0x0000_0000 - 0x3FFF_FFFF | Read-only |
| Data | 256 (default) | `DATA_MEM_INIT_FILE` | 0x4000_0000 - 0x7FFF_FFFF | Read-write |
| ALU | 256 (default) | `ALU_MEM_INIT_FILE` | 0x8000_0000 - 0xBFFF_FFFF | Read-write |
| Reserved | 256 (default) | `RESERVED_MEM_INIT_FILE` | 0xC000_0000 - 0xFFFF_FFFF | Read-only |

**Note**: Memory sizes are parameterized and can be increased if device has more resources.

---

## 10. Timing and Clock Domains

- **All modules**: Synchronous to `ACLK`
- **Reset**: Active-low (`ARESETN`)
- **Clock domain**: Single clock domain (all modules share `ACLK`)
- **No clock domain crossing**: All AXI signals are synchronous

---

## References

- Module file: `src/wrapper/ip/dual_master_system_ip.v`
- SERV Wrapper: `src/wrapper/converters/serv_axi_wrapper.v`
- ALU Master: `src/cores/alu/CPU_ALU_Master.v`
- AXI Interconnect: `src/axi_interconnect/rtl/core/AXI_Interconnect_Full.v`
- Memory Slave: `src/wrapper/memory/axi_memory_slave.v` (assumed)

