# Sơ Đồ Tổng Thể Hệ Thống AXI (Mermaid Diagrams)

## 🏗️ Kiến Trúc Tổng Quan

```mermaid
graph TB
    subgraph "dual_master_system_ip (TOP-LEVEL IP)"
        subgraph SERV["SERV RISC-V Core"]
            SERV_CORE[serv_top<br/>RISC-V Processor]
            IBUS[ibus<br/>Wishbone RO]
            DBUS[dbus<br/>Wishbone RW]
        end
        
        subgraph CONV["Wishbone to AXI Converters"]
            WB2AXI_R[wb2axi_read<br/>Instruction Bus]
            WB2AXI_W[wb2axi_write<br/>Data Bus]
        end
        
        subgraph ALU["ALU Master"]
            ALU_MASTER[CPU_ALU_Master<br/>ALU Operations]
        end
        
        subgraph IC["AXI Interconnect"]
            AXI_IC[AXI_Interconnect_Full<br/>2 Masters → 4 Slaves]
        end
        
        subgraph MEM["Memory Slaves"]
            MEM0[axi_rom_slave<br/>M00: Instruction<br/>0x0000_0000]
            MEM1[axi_memory_slave<br/>M01: Data<br/>0x4000_0000]
            MEM2[axi_memory_slave<br/>M02: ALU<br/>0x8000_0000]
            MEM3[axi_rom_slave<br/>M03: Reserved<br/>0xC000_0000]
        end
        
        SERV_CORE -->|ibus| WB2AXI_R
        SERV_CORE -->|dbus| WB2AXI_W
        WB2AXI_R -->|M0_AXI| AXI_IC
        WB2AXI_W -->|M1_AXI| AXI_IC
        ALU_MASTER -->|M_AXI| AXI_IC
        AXI_IC -->|S00| MEM0
        AXI_IC -->|S01| MEM1
        AXI_IC -->|S02| MEM2
        AXI_IC -->|S03| MEM3
    end
    
    EXT_CLK[ACLK] --> SERV
    EXT_CLK --> ALU
    EXT_CLK --> IC
    EXT_CLK --> MEM
    EXT_RST[ARESETN] --> SERV
    EXT_RST --> ALU
    EXT_RST --> IC
    EXT_RST --> MEM
```

---

## 🔄 Luồng Dữ Liệu: SERV Instruction Fetch

```mermaid
sequenceDiagram
    participant SERV as SERV Core
    participant WB_R as wb2axi_read
    participant IC as AXI Interconnect
    participant MEM as Instruction Memory
    
    SERV->>WB_R: ibus: cyc, stb, adr[31:0]
    WB_R->>IC: AR: araddr=0x0000_0000, arvalid=1
    IC->>IC: Address Decode: bits[31:30]=00 → M00
    IC->>MEM: AR: araddr, arvalid
    MEM-->>IC: AR: arready=1
    IC-->>WB_R: AR: arready=1
    WB_R-->>SERV: ibus: ack
    MEM->>IC: R: rdata=0x00010037, rvalid=1
    IC->>WB_R: R: rdata, rvalid
    WB_R->>SERV: ibus: dat_r[31:0]
```

---

## 🔄 Luồng Dữ Liệu: SERV Data Write

```mermaid
sequenceDiagram
    participant SERV as SERV Core
    participant WB_W as wb2axi_write
    participant IC as AXI Interconnect
    participant MEM as Data Memory
    
    SERV->>WB_W: dbus: cyc, stb, we=1, adr=0x4000_0000, dat_w
    WB_W->>IC: AW: awaddr=0x4000_0000, awvalid=1
    IC->>IC: Address Decode: bits[31:30]=01 → M01
    IC->>MEM: AW: awaddr, awvalid
    MEM-->>IC: AW: awready=1
    IC-->>WB_W: AW: awready=1
    WB_W->>IC: W: wdata, wvalid=1, wlast=1
    IC->>MEM: W: wdata, wvalid, wlast
    MEM-->>IC: W: wready=1
    IC-->>WB_W: W: wready=1
    MEM->>IC: B: bresp=OKAY, bvalid=1
    IC->>WB_W: B: bresp, bvalid
    WB_W-->>SERV: dbus: ack
```

---

## 🔄 Luồng Dữ Liệu: ALU Master Operation

```mermaid
sequenceDiagram
    participant CTRL as Control Logic
    participant ALU as ALU Master
    participant IC as AXI Interconnect
    participant MEM as ALU Memory
    
    CTRL->>ALU: alu_master_start=1
    ALU->>ALU: Start ALU operation
    ALU->>IC: AR: araddr=0x8000_0000, arvalid=1
    IC->>IC: Address Decode: bits[31:30]=10 → M02
    IC->>MEM: AR: araddr, arvalid
    MEM-->>IC: AR: arready=1
    IC-->>ALU: AR: arready=1
    MEM->>IC: R: rdata, rvalid=1
    IC->>ALU: R: rdata, rvalid
    ALU->>ALU: Perform ALU operation
    ALU->>IC: AW: awaddr=0x8000_0004, awvalid=1
    IC->>MEM: AW: awaddr, awvalid
    MEM-->>IC: AW: awready=1
    ALU->>IC: W: wdata=result, wvalid=1, wlast=1
    IC->>MEM: W: wdata, wvalid, wlast
    MEM-->>IC: B: bresp=OKAY, bvalid=1
    IC->>ALU: B: bresp, bvalid
    ALU->>CTRL: alu_master_done=1
```

---

## 🗺️ Address Space Mapping

```mermaid
graph LR
    subgraph "32-bit Address Space"
        A1["0x0000_0000<br/>┌─────────────┐<br/>│ M00: Inst Mem │<br/>│ (ROM)        │<br/>│ 256 words     │<br/>└─────────────┘"]
        A2["0x4000_0000<br/>┌─────────────┐<br/>│ M01: Data Mem │<br/>│ (RAM)        │<br/>│ 256 words     │<br/>└─────────────┘"]
        A3["0x8000_0000<br/>┌─────────────┐<br/>│ M02: ALU Mem │<br/>│ (RAM)        │<br/>│ 256 words     │<br/>└─────────────┘"]
        A4["0xC000_0000<br/>┌─────────────┐<br/>│ M03: Reserved│<br/>│ (ROM)        │<br/>│ 256 words     │<br/>└─────────────┘"]
    end
    
    A1 -->|"bits[31:30]=00"| DEC[Address Decoder]
    A2 -->|"bits[31:30]=01"| DEC
    A3 -->|"bits[31:30]=10"| DEC
    A4 -->|"bits[31:30]=11"| DEC
```

---

## 📊 Module Hierarchy Tree

```mermaid
graph TD
    TOP[dual_master_system_ip]
    
    TOP --> SERV_WRAP[serv_axi_wrapper]
    SERV_WRAP --> SERV_CORE[serv_top]
    SERV_CORE --> SERV_STATE[serv_state]
    SERV_CORE --> SERV_DEC[serv_decode]
    SERV_CORE --> SERV_ALU[serv_alu]
    SERV_CORE --> SERV_CTRL[serv_ctrl]
    SERV_CORE --> SERV_CSR[serv_csr]
    SERV_CORE --> SERV_MEM[serv_mem_if]
    SERV_CORE --> SERV_RF[serv_rf_top]
    
    SERV_WRAP --> WB_R[wb2axi_read]
    SERV_WRAP --> WB_W[wb2axi_write]
    
    TOP --> ALU_MASTER[CPU_ALU_Master]
    ALU_MASTER --> ALU_CORE[ALU_Core]
    ALU_MASTER --> ALU_CTRL[CPU_Controller]
    
    TOP --> AXI_IC[AXI_Interconnect_Full]
    AXI_IC --> AW_DEC[Write_Addr_Channel_Dec]
    AXI_IC --> AR_DEC[Read_Addr_Channel_Dec]
    AXI_IC --> W_ARB[Write_Arbiter]
    AXI_IC --> R_ARB[Read_Arbiter]
    AXI_IC --> AW_CTRL[AW_Channel_Controller_Top]
    AXI_IC --> WD_CTRL[WD_Channel_Controller_Top]
    AXI_IC --> BR_CTRL[BR_Channel_Controller_Top]
    AXI_IC --> AR_CTRL[AR_Channel_Controller_Top]
    
    TOP --> MEM0[axi_rom_slave M00]
    TOP --> MEM1[axi_memory_slave M01]
    TOP --> MEM2[axi_memory_slave M02]
    TOP --> MEM3[axi_rom_slave M03]
```

---

## 🔌 AXI Interconnect Internal Structure

```mermaid
graph TB
    subgraph "AXI Interconnect Full"
        subgraph MASTERS["Master Ports"]
            M0[S00: SERV Inst Bus<br/>Read-only]
            M1[S01: SERV Data Bus<br/>Read-Write]
        end
        
        subgraph DECODERS["Address Decoders"]
            AW_DEC[Write_Addr_Channel_Dec<br/>Decode AW addresses]
            AR_DEC[Read_Addr_Channel_Dec<br/>Decode AR addresses]
        end
        
        subgraph ARBITERS["Arbiters"]
            W_ARB[Write_Arbiter<br/>Round-Robin]
            R_ARB[Read_Arbiter<br/>Round-Robin]
            QOS[Qos_Arbiter<br/>Quality of Service]
        end
        
        subgraph CONTROLLERS["Channel Controllers"]
            AW_CTRL[AW_Channel_Controller]
            WD_CTRL[WD_Channel_Controller]
            BR_CTRL[BR_Channel_Controller]
            AR_CTRL[AR_Channel_Controller]
        end
        
        subgraph DATAPATH["Datapath"]
            MUX[MUX Modules<br/>Combine signals]
            DEMUX[DEMUX Modules<br/>Route signals]
        end
        
        subgraph SLAVES["Slave Ports"]
            S0[M00: Inst Mem]
            S1[M01: Data Mem]
            S2[M02: ALU Mem]
            S3[M03: Reserved Mem]
        end
        
        M0 --> AR_DEC
        M1 --> AW_DEC
        M1 --> AR_DEC
        AW_DEC --> W_ARB
        AR_DEC --> R_ARB
        W_ARB --> AW_CTRL
        W_ARB --> WD_CTRL
        W_ARB --> BR_CTRL
        R_ARB --> AR_CTRL
        AW_CTRL --> MUX
        WD_CTRL --> MUX
        BR_CTRL --> MUX
        AR_CTRL --> MUX
        MUX --> DEMUX
        DEMUX --> S0
        DEMUX --> S1
        DEMUX --> S2
        DEMUX --> S3
    end
```

---

## 🎯 Testbench Architecture

```mermaid
graph TB
    subgraph TB_ENV["Testbench Environment"]
        CLK_GEN[Clock Generator<br/>ACLK = 100 MHz]
        RST_GEN[Reset Generator<br/>ARESETN]
        STIMULI[Test Stimuli<br/>RISC-V Program<br/>ALU Operations]
    end
    
    subgraph DUT["Device Under Test"]
        DUT_IP[dual_master_system_ip]
    end
    
    subgraph MONITOR["Monitors"]
        WAVE[Waveform Monitor]
        LOG[Transaction Logger]
        CHECK[Assertion Checker]
    end
    
    CLK_GEN --> DUT_IP
    RST_GEN --> DUT_IP
    STIMULI --> DUT_IP
    DUT_IP --> WAVE
    DUT_IP --> LOG
    DUT_IP --> CHECK
    
    CHECK --> RESULT[Test Results<br/>20 Test Cases]
```

---

## 📈 Data Flow: Concurrent Operations

```mermaid
sequenceDiagram
    par SERV Instruction Fetch
        SERV->>IC: AR: Inst addr
        IC->>MEM0: AR: Read
        MEM0-->>IC: R: Instruction
        IC-->>SERV: R: Instruction
    and SERV Data Write
        SERV->>IC: AW: Data addr
        IC->>MEM1: AW: Write
        SERV->>IC: W: Write data
        IC->>MEM1: W: Data
        MEM1-->>IC: B: Write done
        IC-->>SERV: B: Done
    and ALU Master Read
        ALU->>IC: AR: ALU addr
        IC->>MEM2: AR: Read
        MEM2-->>IC: R: Data
        IC-->>ALU: R: Data
    end
```

---

## 🔧 Component Details

### SERV RISC-V Core Components

```mermaid
graph LR
    subgraph SERV["SERV RISC-V"]
        FETCH[Instruction Fetch]
        DECODE[Decode]
        EXEC[Execute ALU]
        MEM_IF[Memory Interface]
        RF[Register File]
        CSR[CSR Registers]
    end
    
    FETCH --> DECODE
    DECODE --> EXEC
    EXEC --> MEM_IF
    EXEC --> RF
    EXEC --> CSR
    RF --> EXEC
    CSR --> EXEC
```

### ALU Master Components

```mermaid
graph LR
    subgraph ALU["ALU Master"]
        CTRL[CPU_Controller<br/>State Machine]
        ALU_CORE[ALU_Core<br/>Operations]
        AXI_IF[AXI Interface]
    end
    
    CTRL --> ALU_CORE
    ALU_CORE --> AXI_IF
    AXI_IF --> CTRL
```

---

*Các sơ đồ Mermaid này có thể được render trong GitHub, GitLab, hoặc các markdown viewer hỗ trợ Mermaid.*

