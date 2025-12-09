# Arbitration Folder - Reorganized

**Updated**: December 3, 2025  
**Status**: ✅ Clear structure with 3 distinct algorithms

---

## 📁 New Structure

```
arbitration/
├── interconnect/              Full interconnect implementations
│   └── axi_rr_interconnect_2x4.v  (2 masters × 4 slaves)
│
├── algorithms/                Pure arbitration algorithms
│   ├── arbiter_fixed_priority.v   (Mode 0)
│   ├── arbiter_round_robin.v      (Mode 1)
│   ├── arbiter_qos_based.v        (Mode 2)
│   ├── read_arbiter.v             (Generic read)
│   └── README.md
│
└── README.md (this file)
```

---

## 🎯 3 Arbitration Algorithms

### **Mode 0: FIXED PRIORITY** 🔴
**File**: `algorithms/arbiter_fixed_priority.v`  
**Priority**: M0 > M1 (always)  
**Use**: When M0 is critical, M1 is best-effort

### **Mode 1: ROUND-ROBIN** 🔵 (Default)
**File**: `algorithms/arbiter_round_robin.v`  
**Priority**: Fair alternating  
**Use**: Equal priority, no starvation

### **Mode 2: QOS-BASED** 🟢
**File**: `algorithms/arbiter_qos_based.v`  
**Priority**: By QoS value (higher wins)  
**Use**: Traffic classes, differentiated service

**See**: `algorithms/README.md` for detailed comparison

---

## 🔧 What to Use

### **For Full System**:
**Use**: `interconnect/axi_rr_interconnect_2x4.v`
```verilog
axi_rr_interconnect_2x4 #(
    .ARBITRATION_MODE(1)  // 0=FIXED, 1=RR, 2=QOS
) u_ic (...);
```

**This file**:
- ✅ Complete 2×4 interconnect
- ✅ Has all 3 modes built-in
- ✅ Used in dual_riscv_axi_system.v
- ✅ Production ready (98%+ verified)

---

### **For Custom Interconnect**:
**Use**: Component arbiters from `algorithms/`
```verilog
// Build custom interconnect using:
arbiter_round_robin u_wr_arb (...);
arbiter_round_robin u_rd_arb (...);
// + your routing logic
```

**These files**:
- ✅ Standalone arbitration logic
- ✅ Reusable components
- ✅ Can mix and match

---

## 📊 Folder Organization

### **interconnect/** - Complete Implementations
```
Purpose: Full interconnect modules
Content: axi_rr_interconnect_2x4.v
Use: Drop-in complete interconnects
```

### **algorithms/** - Building Blocks
```
Purpose: Pure arbitration algorithms  
Content: 3 arbiter modes + generic read
Use: Build custom interconnects
```

---

## 🎯 Before vs After

### **BEFORE** (Confusing):
```
arbitration/
├── axi_rr_interconnect_2x4.v  ❓ Is this arbiter?
├── Write_Arbiter.v             ❓ Which mode?
├── Write_Arbiter_RR.v          ✓ RR clear
├── Qos_Arbiter.v               ✓ QoS clear
└── Read_Arbiter.v              ❓ Which mode?
```

**Problems**:
- Mixed complete IC with components
- Unclear which file is which mode
- Not obvious 3 algorithms

---

### **AFTER** (Crystal Clear!):
```
arbitration/
├── interconnect/                     ✅ Full ICs
│   └── axi_rr_interconnect_2x4.v    (supports all 3 modes)
│
└── algorithms/                       ✅ Pure arbiters
    ├── arbiter_fixed_priority.v     (Mode 0 - CLEAR!)
    ├── arbiter_round_robin.v        (Mode 1 - CLEAR!)
    ├── arbiter_qos_based.v          (Mode 2 - CLEAR!)
    └── read_arbiter.v               (Generic)
```

**Benefits**:
- ✅ Obvious 3 modes
- ✅ Clear separation
- ✅ Easy to find
- ✅ Self-documenting names

---

## 📚 Documentation

- **This file**: Overview
- **algorithms/README.md**: Detailed algorithm comparison
- **interconnect/**: Full interconnect usage

---

## ✅ Summary

**3 Modes**: Now obvious!
- Mode 0: arbiter_fixed_priority.v
- Mode 1: arbiter_round_robin.v
- Mode 2: arbiter_qos_based.v

**Full IC**: axi_rr_interconnect_2x4.v (supports all 3)

**Status**: ✅ **Clear & Professional!**

