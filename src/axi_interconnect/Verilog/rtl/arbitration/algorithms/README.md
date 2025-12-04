# AXI Arbitration Algorithms

**Purpose**: 3 arbitration algorithms for AXI interconnect  
**Status**: ✅ Production ready

---

## 🎯 3 Thuật Toán Arbiter

### **1. FIXED PRIORITY (Mode 0)** 🔴

**File**: `arbiter_fixed_priority.v`

**Module**: `Write_Arbiter` (legacy name - for Fixed Priority)

**Algorithm**:
```
Priority: Master 0 > Master 1 (always)

if (M0_request) → Grant M0
else → Grant M1
```

**Characteristics**:
- ✅ **Deterministic**: M0 always wins if both request
- ✅ **Low latency**: No turn tracking
- ✅ **Simple logic**: Minimal gates
- ⚠️ **Starvation risk**: M1 can be starved if M0 busy

**Use when**:
- M0 is time-critical (e.g., real-time)
- M1 is best-effort
- Need deterministic behavior

**Parameters**:
```verilog
Write_Arbiter #(
    // No mode parameter - always fixed priority
) u_arb (
    .S0_Request(m0_request),
    .S1_Request(m1_request),
    .Channel_Granted(granted),
    .Selected_Slave(winner)
);
```

---

### **2. ROUND-ROBIN (Mode 1)** 🔵 DEFAULT

**File**: `arbiter_round_robin.v`

**Module**: `Write_Arbiter_RR`

**Algorithm**:
```
Fair alternating turns:

Turn = M0:
    if (M0_request) → Grant M0, next_turn = M1
    else if (M1_request) → Grant M1, next_turn = M0
    
Turn = M1:
    if (M1_request) → Grant M1, next_turn = M0
    else if (M0_request) → Grant M0, next_turn = M1
```

**Characteristics**:
- ✅ **Fair**: Both masters get equal opportunity
- ✅ **No starvation**: Guaranteed service for both
- ✅ **Balanced**: Good for equal-priority masters
- ⚠️ **Slight overhead**: Turn tracking logic

**Use when**:
- Equal priority masters
- Fairness required
- No starvation tolerance

**Parameters**:
```verilog
Write_Arbiter_RR #(
    .RESET_TURN(0)  // Initial turn (0=M0, 1=M1)
) u_arb (
    .clkk(clk),
    .resett(rst_n),
    .S0_Request(m0_request),
    .S1_Request(m1_request),
    .Channel_Granted(granted),
    .Selected_Slave(winner)
);
```

---

### **3. QOS-BASED (Mode 2)** 🟢

**File**: `arbiter_qos_based.v`

**Module**: `Qos_Arbiter`

**Algorithm**:
```
Priority by QoS value (4-bit):

if (M0_QoS >= M1_QoS) → Grant M0
else → Grant M1

(M0 wins on tie)
```

**Characteristics**:
- ✅ **Dynamic priority**: Based on QoS values
- ✅ **Flexible**: Change priority per transaction
- ✅ **Differentiated service**: High QoS gets priority
- ⚠️ **Complexity**: Need QoS assignment logic

**Use when**:
- Differentiated service levels
- Dynamic priority needed
- Traffic classes (e.g., real-time vs best-effort)

**Parameters**:
```verilog
Qos_Arbiter #(
    .QOS_WIDTH(4)
) u_arb (
    .S0_Request(m0_request),
    .S1_Request(m1_request),
    .S0_Qos(m0_qos),
    .S1_Qos(m1_qos),
    .Selected_Slave(winner)
);
```

---

## 📊 Comparison Table

| Feature | Fixed Priority | Round-Robin | QoS-Based |
|---------|----------------|-------------|-----------|
| **Fairness** | ❌ Low | ✅ High | 🟡 Medium |
| **Latency (M0)** | ✅ Lowest | 🟡 Medium | 🟡 Varies |
| **Latency (M1)** | ❌ High | 🟡 Medium | 🟡 Varies |
| **Starvation** | ❌ M1 can starve | ✅ No | 🟡 Depends on QoS |
| **Complexity** | ✅ Simple | 🟡 Medium | 🟡 Medium |
| **Determinism** | ✅ Yes | 🟡 Cyclic | ❌ No |
| **Use Case** | Real-time M0 | Equal priority | Traffic classes |

---

## 🔧 Usage in Interconnect

### **axi_rr_interconnect_2x4** supports all 3:

```verilog
axi_rr_interconnect_2x4 #(
    .ARBITRATION_MODE(0)  // 0=FIXED, 1=RR, 2=QOS
) u_ic (
    .M0_AWQOS(m0_qos),  // Used in QoS mode
    .M1_AWQOS(m1_qos),  // Used in QoS mode
    // ...
);
```

**Internal**: Uses inline arbitration logic (not these component files)

---

## 📝 Notes

### **These arbiter files**:
- Standalone components
- Can be used independently
- NOT used by axi_rr_interconnect_2x4 (has internal logic)

### **axi_rr_interconnect_2x4**:
- Full interconnect (2M×4S)
- Has arbitration BUILT-IN
- Configurable via ARBITRATION_MODE parameter

---

## 🎯 Which to Use?

### **For new interconnect design**:
Use these arbiter components as building blocks

### **For dual RISC-V system**:
Use `axi_rr_interconnect_2x4` with ARBITRATION_MODE parameter

---

**Status**: ✅ **3 Algorithms Clear & Documented!**

