# System Integration - Top-Level Designs

## 📁 Files

```
systems/
├── dual_riscv_axi_system.v          ⭐ Main - 2 RISC-V + Interconnect
├── serv_axi_system.v                ⭐ Single RISC-V system
├── axi_interconnect_wrapper.v       (Interconnect wrapper)
└── axi_interconnect_2m4s_wrapper.v  (2 masters, 4 slaves wrapper)
```

---

## 🎯 **Main System: dual_riscv_axi_system**

### **Architecture:**
```
dual_riscv_axi_system
├── 2x SERV RISC-V Cores
│   ├── u_serv0 (serv_axi_wrapper)
│   └── u_serv1 (serv_axi_wrapper)
│
├── 2x AXI Adapters
│   ├── u_serv0_adapter (dual bus → single AXI-Lite)
│   └── u_serv1_adapter (dual bus → single AXI-Lite)
│
├── 1x AXI Interconnect (2x4 crossbar)
│   └── u_rr_xbar (axi_rr_interconnect_2x4)
│       ├── Arbitration: ROUND_ROBIN (configurable)
│       └── Routing: 4 slaves
│
└── 4x AXI-Lite Slaves
    ├── u_sram (axi_lite_ram)      - 0x0xxx_xxxx
    ├── u_gpio (axi_lite_gpio)     - 0x4xxx_xxxx
    ├── u_uart (axi_lite_uart)     - 0x8xxx_xxxx
    └── u_spi  (axi_lite_spi)      - 0xCxxx_xxxx
```

---

## 🔌 **Connections**

### **RISC-V → AXI Bridge → Interconnect:**

```
SERV0 (RISC-V)
    ↓ (serv_axi_wrapper)
Dual AXI4 Masters (M0=Inst, M1=Data)
    ↓ (serv_axi_dualbus_adapter)
Single AXI4-Lite Master
    ↓
Interconnect Master Port 0
```

### **Arbitration:**
```
Master 0 (SERV0) ─┐
                  ├→ Arbitration (FIXED/RR/QOS) → Selected Slave
Master 1 (SERV1) ─┘
```

---

## 📝 **Parameters**

### **dual_riscv_axi_system:**
```verilog
parameter ADDR_WIDTH = 32
parameter DATA_WIDTH = 32
parameter ID_WIDTH = 4
parameter RAM_WORDS = 2048
parameter RAM_INIT_HEX = "path/to/program.hex"
```

### **Interconnect Configuration:**
```verilog
axi_rr_interconnect_2x4 #(
    .ARBITRATION_MODE("ROUND_ROBIN")  // or "FIXED", "QOS"
) u_rr_xbar (
    .M0_AWQOS(4'b0000),  // Default QoS
    .M1_AWQOS(4'b0000),  // Default QoS
    // ...
);
```

---

## 🎯 **Use Cases**

| System | Use Case |
|--------|----------|
| `dual_riscv_axi_system` | ⭐ Dual-core RISC-V SoC |
| `serv_axi_system` | Single-core simple system |
| `axi_interconnect_wrapper` | Standalone interconnect |
| `axi_interconnect_2m4s_wrapper` | Parametrized wrapper |

---

## 🚀 **How to Use**

### **In Testbench:**
```verilog
dual_riscv_axi_system #(
    .RAM_INIT_HEX("test_program.hex")
) dut (
    .ACLK(clk),
    .ARESETN(rst_n),
    .serv0_timer_irq(irq0),
    .serv1_timer_irq(irq1),
    .gpio_in(gpio_in),
    .gpio_out(gpio_out),
    // ...
);
```

### **Simulation:**
```bash
cd D:\AXI\sim\modelsim
vsim work.dual_riscv_axi_system_tb
run 10us
```

---

## 📊 **System Statistics**

| Component | Count | Type |
|-----------|-------|------|
| **RISC-V Cores** | 2 | SERV (bit-serial) |
| **AXI Masters** | 2 | AXI4-Lite |
| **AXI Slaves** | 4 | RAM, GPIO, UART, SPI |
| **Arbitration Modes** | 3 | FIXED, RR, QOS |
| **Address Space** | 4 regions | 1GB each |

---

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Production Ready

