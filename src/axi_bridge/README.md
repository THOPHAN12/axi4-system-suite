# AXI Bridge - Protocol Converters

## 📁 Directory Structure

```
axi_bridge/
└── rtl/
    ├── riscv_to_axi/           ⭐ RISC-V to AXI converters
    │   ├── serv_axi_wrapper.v
    │   ├── serv_axi_dualbus_adapter.v
    │   ├── wb2axi_read.v
    │   └── wb2axi_write.v
    │
    ├── axi4_to_stream/         (AXI4 to AXI-Stream)
    ├── stream_to_axi4/         (AXI-Stream to AXI4)
    ├── clock_domain/           (Clock crossing)
    └── width_converter/        (Data width conversion)
```

---

## 🎯 **RISC-V to AXI Converters**

### **Purpose:**
Convert RISC-V CPU interfaces (Wishbone) to AXI4-Lite protocol.

### **Files:**

| File | Purpose | I/O |
|------|---------|-----|
| `serv_axi_wrapper.v` | Wraps SERV core with AXI | SERV ↔ AXI4-Lite (dual bus) |
| `serv_axi_dualbus_adapter.v` | Merges instruction + data buses | Dual AXI4 ↔ Single AXI4-Lite |
| `wb2axi_read.v` | Wishbone to AXI read channel | Wishbone ↔ AXI AR/R |
| `wb2axi_write.v` | Wishbone to AXI write channel | Wishbone ↔ AXI AW/W/B |

---

## 🔄 **Connection Flow**

```
SERV RISC-V Core
├── Instruction Bus (Wishbone)
│   └── wb2axi_read → AXI4 Master (M0)
│
└── Data Bus (Wishbone)
    ├── wb2axi_read  → AXI4 Master (M1) Read
    └── wb2axi_write → AXI4 Master (M1) Write
    
    ↓ (via serv_axi_dualbus_adapter)
    
Single AXI4-Lite Master
    ↓
AXI Interconnect
    ↓
Slaves (RAM, GPIO, UART, SPI)
```

---

## 📝 **Module Details**

### **1. serv_axi_wrapper**
```verilog
module serv_axi_wrapper (
    // Clock & Reset
    input ACLK, ARESETN,
    
    // SERV signals (internal)
    input i_timer_irq,
    
    // AXI4 Master 0 (Instruction)
    output [ADDR_WIDTH-1:0] M0_AXI_araddr,
    output M0_AXI_arvalid,
    input M0_AXI_arready,
    // ... AR/R channels
    
    // AXI4 Master 1 (Data)
    output [ADDR_WIDTH-1:0] M1_AXI_awaddr,
    // ... AW/W/B/AR/R channels
);
```

**Function:** Integrates SERV RISC-V core with dual AXI4 masters

---

### **2. serv_axi_dualbus_adapter**
```verilog
module serv_axi_dualbus_adapter (
    // Dual AXI4 inputs (from SERV)
    input [ADDR_WIDTH-1:0] inst_araddr,  // Instruction bus
    input [ADDR_WIDTH-1:0] data_awaddr,  // Data bus write
    input [ADDR_WIDTH-1:0] data_araddr,  // Data bus read
    
    // Single AXI4-Lite output (to interconnect)
    output [ADDR_WIDTH-1:0] AXI_awaddr,
    output [ADDR_WIDTH-1:0] AXI_araddr,
    // ... merged channels
);
```

**Function:** Merges instruction + data buses into single AXI-Lite master

---

### **3. wb2axi_read/write**
```verilog
module wb2axi_read (
    // Wishbone slave
    input [ADDR_WIDTH-1:0] wb_adr_i,
    input wb_cyc_i,
    input wb_stb_i,
    output wb_ack_o,
    
    // AXI4 master (AR/R channels)
    output [ADDR_WIDTH-1:0] axi_araddr,
    output axi_arvalid,
    input axi_arready,
    // ...
);
```

**Function:** Protocol conversion Wishbone ↔ AXI4

---

## 🎯 **Usage in System**

### **In dual_riscv_axi_system.v:**

```verilog
// SERV core with AXI wrapper
serv_axi_wrapper u_serv0 (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // Outputs dual AXI4 masters
    .M0_AXI_araddr(...),  // Instruction
    .M1_AXI_awaddr(...),  // Data
);

// Merge dual bus to single AXI-Lite
serv_axi_dualbus_adapter u_serv0_adapter (
    // Input: dual AXI4
    .inst_araddr(...),
    .data_awaddr(...),
    
    // Output: single AXI-Lite
    .AXI_awaddr(serv0_axi_awaddr),
    .AXI_araddr(serv0_axi_araddr),
);

// Connect to interconnect
axi_rr_interconnect_2x4 u_interconnect (
    .M0_AWADDR(serv0_axi_awaddr),
    .M0_ARADDR(serv0_axi_araddr),
    // ...
);
```

---

## 📊 **Summary**

| Component | Files | Purpose |
|-----------|-------|---------|
| **RISC-V Converters** | 4 files | SERV → AXI |
| **Protocol Bridges** | 2 files | Wishbone → AXI |
| **Bus Adapters** | 2 files | Dual bus → Single |

**Total: 4 bridge files in logical location!**

---

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Reorganized & Clean

