# AXI Interconnect Verilog - Configurable Arbitration

## Overview

Module `axi_rr_interconnect_2x4` (Verilog-2001) hỗ trợ 3 thuật toán arbitration có thể cấu hình thông qua parameter `ARBITRATION_MODE`.

---

## Arbitration Modes

Module sử dụng **integer parameter** thay vì string (do Verilog-2001 limitations):

| Mode Value | Name | Description |
|------------|------|-------------|
| `0` | **FIXED** | Fixed Priority (Master 0 > Master 1) |
| `1` | **ROUND_ROBIN** | Fair alternating arbitration (**default**) |
| `2` | **QOS** | QoS-based dynamic priority |

---

## Usage Examples

### 1. FIXED Priority Mode

```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE(0)  // 0 = FIXED
) u_xbar (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .M0_AWQOS(4'b0000),   // Not used in FIXED mode
    .M0_ARQOS(4'b0000),
    .M1_AWQOS(4'b0000),
    .M1_ARQOS(4'b0000),
    // ... other ports
);
```

**Behavior:** Master 0 always wins when both request simultaneously.

---

### 2. ROUND_ROBIN Mode (Default)

```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE(1)  // 1 = ROUND_ROBIN (can be omitted - default)
) u_xbar (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .M0_AWQOS(4'b0000),   // Not used in ROUND_ROBIN mode
    .M0_ARQOS(4'b0000),
    .M1_AWQOS(4'b0000),
    .M1_ARQOS(4'b0000),
    // ... other ports
);
```

**Behavior:** Fair 50/50 alternation between masters.

---

### 3. QOS Mode

```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE(2)  // 2 = QOS
) u_xbar (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    // Master 0 - High priority
    .M0_AWQOS(4'd12),     // High priority writes
    .M0_ARQOS(4'd12),     // High priority reads
    // Master 1 - Low priority
    .M1_AWQOS(4'd2),      // Low priority writes
    .M1_ARQOS(4'd2),      // Low priority reads
    // ... other ports
);
```

**Behavior:** Master with higher QoS value wins. M0 wins on tie.

---

## Integration Example

Update in your top-level Verilog design:

```verilog
// In dual_riscv_axi_system.v or similar

axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ARBITRATION_MODE(1)  // ← Add this line (0, 1, or 2)
) u_rr_xbar (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    
    // Master 0 ports
    .M0_AWADDR(serv0_axi_awaddr),
    .M0_AWPROT(serv0_axi_awprot),
    .M0_AWQOS(4'b0000),              // ← Add QoS ports
    .M0_AWVALID(serv0_axi_awvalid),
    .M0_AWREADY(serv0_axi_awready),
    // ... W channel
    .M0_ARADDR(serv0_axi_araddr),
    .M0_ARPROT(serv0_axi_arprot),
    .M0_ARQOS(4'b0000),              // ← Add QoS ports
    .M0_ARVALID(serv0_axi_arvalid),
    .M0_ARREADY(serv0_axi_arready),
    // ... R channel
    
    // Master 1 ports
    .M1_AWADDR(serv1_axi_awaddr),
    .M1_AWPROT(serv1_axi_awprot),
    .M1_AWQOS(4'b0000),              // ← Add QoS ports
    .M1_AWVALID(serv1_axi_awvalid),
    .M1_AWREADY(serv1_axi_awready),
    // ... W channel
    .M1_ARADDR(serv1_axi_araddr),
    .M1_ARPROT(serv1_axi_arprot),
    .M1_ARQOS(4'b0000),              // ← Add QoS ports
    .M1_ARVALID(serv1_axi_arvalid),
    .M1_ARREADY(serv1_axi_arready),
    // ... R channel
    
    // Slave ports...
);
```

---

## Comparison Table

| Mode | Value | Fairness | Starvation? | Latency | Use Case |
|------|-------|----------|-------------|---------|----------|
| **FIXED** | `0` | ❌ No | ⚠️ Yes (M1) | M0: Very Low<br>M1: High | Real-time master |
| **ROUND_ROBIN** | `1` | ✅ Yes | ❌ No | Medium (both) | SMP systems |
| **QOS** | `2` | ⚖️ Dynamic | ⚠️ Possible | Variable | Mixed-criticality |

---

## QoS Priority Levels (Mode 2)

| QoS Value | Priority | Use Case Example |
|-----------|----------|------------------|
| `4'd15` | Critical | Safety-critical control |
| `4'd12-14` | Very High | Real-time video/audio |
| `4'd8-11` | High | Interactive UI |
| `4'd4-7` | Normal | Application traffic |
| `4'd2-3` | Low | Background tasks |
| `4'd0-1` | Best Effort | Bulk transfer, debug |

---

## Verilog vs SystemVerilog Version

### Differences:

| Feature | SystemVerilog | Verilog-2001 |
|---------|---------------|--------------|
| **Mode Parameter** | `string ARBITRATION_MODE` | `integer ARBITRATION_MODE` |
| **Mode Values** | `"FIXED"`, `"ROUND_ROBIN"`, `"QOS"` | `0`, `1`, `2` |
| **Generate Syntax** | `if (MODE == "FIXED")` | `if (MODE == 0)` |
| **Everything Else** | Same logic | Same logic |

### Why two versions?

- **SystemVerilog**: More readable with string parameters
- **Verilog-2001**: Better compatibility with older tools

Both versions produce **identical hardware** and have same functionality.

---

## Synthesis Notes

1. **Area Impact:**
   - FIXED: Smallest (simple comparator)
   - ROUND_ROBIN: +2 flip-flops for turn pointers
   - QOS: +4-bit comparators

2. **Timing:**
   - All modes have similar critical paths
   - Arbitration is combinational
   - No additional clock cycles

3. **Power:**
   - FIXED: Lowest (simplest logic)
   - ROUND_ROBIN: Slightly higher (turn register)
   - QOS: Medium (comparator logic)

---

## Testing

Test with different modes using Verilog testbench:

```verilog
// Test FIXED mode
`define ARBIT_MODE 0
`include "axi_rr_interconnect_2x4.v"
// ... testbench code

// Test ROUND_ROBIN mode
`define ARBIT_MODE 1
`include "axi_rr_interconnect_2x4.v"

// Test QOS mode
`define ARBIT_MODE 2
`include "axi_rr_interconnect_2x4.v"
```

Or use parameter override in simulator:

```bash
# ModelSim/QuestaSim
vsim -g ARBITRATION_MODE=0 work.testbench  # FIXED
vsim -g ARBITRATION_MODE=1 work.testbench  # ROUND_ROBIN
vsim -g ARBITRATION_MODE=2 work.testbench  # QOS
```

---

## Quick Reference

### Change arbitration mode:

**Before:**
```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
    // Hard-coded Round-Robin
) u_xbar ( ... );
```

**After (FIXED priority):**
```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE(0)  // ← Just add this line!
) u_xbar (
    .M0_AWQOS(4'b0000),   // ← And QoS ports
    .M0_ARQOS(4'b0000),
    .M1_AWQOS(4'b0000),
    .M1_ARQOS(4'b0000),
    // ... rest
);
```

**After (QOS-based):**
```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE(2)  // ← QOS mode
) u_xbar (
    .M0_AWQOS(4'd10),     // ← Higher priority
    .M0_ARQOS(4'd10),
    .M1_AWQOS(4'd2),      // ← Lower priority
    .M1_ARQOS(4'd2),
    // ... rest
);
```

---

## See Also

- **SystemVerilog version**: `../SystemVerilog/rtl/arbitration/axi_rr_interconnect_2x4.sv`
- **Detailed docs**: `../SystemVerilog/rtl/arbitration/ARBITRATION_README.md`
- **Examples**: `../SystemVerilog/rtl/arbitration/example_configs.sv`

---

**Note:** For detailed explanation of each arbitration algorithm, use cases, and performance characteristics, see the comprehensive SystemVerilog README.

**Version:** 1.0  
**Date:** 2025-01-02  
**Status:** ✅ Production Ready

