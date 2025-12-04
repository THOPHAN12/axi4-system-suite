# AXI Bridge IP Cores - Ready-to-Use IPs

**Purpose**: Complete, packaged IP cores for protocol conversion  
**Status**: ✅ Production ready

---

## 🎯 Available IPs

### **1. WB_TO_AXI_BRIDGE_IP** ⭐ Generic Protocol Bridge

**Location**: `wb_to_axi_bridge_ip/wb_to_axi_bridge_ip.v`

**Purpose**: Universal Wishbone to AXI-Lite bridge

**Top Module**: `wb_to_axi_bridge_ip`

**Usage**:
```verilog
wb_to_axi_bridge_ip #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
) u_wb_axi_ip (
    .ACLK(clk),
    .ARESETN(rst_n),
    // Wishbone interface
    .WB_ADR_I(wb_address),
    .WB_DAT_I(wb_write_data),
    .WB_DAT_O(wb_read_data),
    .WB_SEL_I(wb_byte_sel),
    .WB_WE_I(wb_write_enable),
    .WB_CYC_I(wb_cycle),
    .WB_STB_I(wb_strobe),
    .WB_ACK_O(wb_acknowledge),
    .WB_ERR_O(wb_error),
    // AXI-Lite master
    .M_AXI_*(axi_*)
);
```

**Use for**:
- Generic CPUs with Wishbone
- Microcontrollers
- Custom processors
- IP core integration

---

### **2. RISCV_AXI_BRIDGE_IP** ⭐ RISC-V Optimized Bridge

**Location**: `riscv_axi_bridge_ip/riscv_axi_bridge_ip.v`

**Purpose**: RISC-V to AXI-Lite bridge (Harvard architecture)

**Top Module**: `riscv_axi_bridge_ip`

**Usage**:
```verilog
riscv_axi_bridge_ip #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .DUAL_BUS(1),      // Harvard architecture
    .MERGE_OUTPUT(1)   // Single AXI output
) u_riscv_axi_ip (
    .ACLK(clk),
    .ARESETN(rst_n),
    // Instruction bus (read-only)
    .IBUS_ADR_I(ibus_address),
    .IBUS_CYC_I(ibus_cycle),
    .IBUS_STB_I(ibus_strobe),
    .IBUS_DAT_O(ibus_read_data),
    .IBUS_ACK_O(ibus_acknowledge),
    // Data bus (read-write)
    .DBUS_ADR_I(dbus_address),
    .DBUS_DAT_I(dbus_write_data),
    .DBUS_DAT_O(dbus_read_data),
    .DBUS_SEL_I(dbus_byte_sel),
    .DBUS_WE_I(dbus_write_enable),
    .DBUS_CYC_I(dbus_cycle),
    .DBUS_STB_I(dbus_strobe),
    .DBUS_ACK_O(dbus_acknowledge),
    .DBUS_ERR_O(dbus_error),
    // Single merged AXI master
    .M_AXI_*(axi_*)
);
```

**Use for**:
- SERV cores
- PicoRV32
- VexRiscv
- NEORV32
- Any RISC-V with Wishbone

---

## 📁 IP Package Structure

Each IP is self-contained:

```
wb_to_axi_bridge_ip/
├── wb_to_axi_bridge_ip.v   ← IP TOP (use this!)
├── rtl/                    ← Internal implementation
│   ├── wb_to_axilite_bridge.v
│   └── (uses components from ../../lib/)
└── docs/                   ← Documentation (future)

riscv_axi_bridge_ip/
├── riscv_axi_bridge_ip.v   ← IP TOP (use this!)
├── rtl/                    ← Internal implementation
│   ├── riscv_to_axi_bridge.v
│   └── (uses components from ../../lib/)
└── docs/                   ← Documentation (future)
```

---

## 🎯 Which IP to Use?

### **Decision Tree**:

```
Do you have a RISC-V core?
├── YES → Use RISCV_AXI_BRIDGE_IP
│         (Optimized for Harvard arch, dual-bus)
│
└── NO → What interface does your CPU have?
          ├── Wishbone → Use WB_TO_AXI_BRIDGE_IP
          │              (Generic, works with any WB CPU)
          └── Other → Build custom from lib/ components
```

---

## 📊 IP Comparison

| Feature | WB_TO_AXI_BRIDGE_IP | RISCV_AXI_BRIDGE_IP |
|---------|---------------------|---------------------|
| **Input** | Single Wishbone bus | Dual Wishbone (I+D) |
| **Output** | AXI-Lite master | AXI-Lite master |
| **Architecture** | Von Neumann | Harvard (configurable) |
| **Optimized for** | Generic CPUs | RISC-V cores |
| **Complexity** | Simple | Medium |
| **Port count** | ~25 | ~35 |
| **Use case** | Universal | RISC-V specific |

---

## 🚀 Quick Start

### **Step 1: Choose IP**
- Generic CPU → `wb_to_axi_bridge_ip`
- RISC-V → `riscv_axi_bridge_ip`

### **Step 2: Instantiate**
Copy-paste example from above

### **Step 3: Connect**
- Connect Wishbone to your CPU
- Connect AXI to interconnect
- Done!

---

## 📚 Dependencies

Both IPs depend on:
- `../../lib/wb_to_axi_addr_channel.v`
- `../../lib/wb_to_axi_data_channel.v`
- `../../lib/wb_to_axi_resp_handler.v`
- `../../lib/axi_bus_merger.v` (RISC-V IP only)

**Make sure to include lib/ in compilation!**

---

## ✅ Advantages

**vs Legacy** (serv_axi_wrapper):
- ✅ Clear IP naming
- ✅ Self-contained packages
- ✅ Easy to find and use
- ✅ Professional structure

**vs Direct component use**:
- ✅ Pre-packaged, tested
- ✅ Single top module
- ✅ No assembly needed

---

**Status**: ✅ **Ready to use!**  
**Quality**: ⭐⭐⭐⭐⭐ IP-grade
