# AXI Interconnect Arbitration Testbenches

## Overview

Testbenches để verify 3 arbitration modes của AXI Interconnect:
- **FIXED Priority** (Master 0 > Master 1)
- **ROUND_ROBIN** (Fair alternation)
- **QOS** (Priority based on QoS values)

---

## Testbench Files

### **1. Verilog Version**
**File:** `Verilog/arb_test_verilog.v`

**Features:**
- ✅ Verilog-2001 compatible
- ✅ Works with all simulators
- ✅ Integer parameter for mode selection
- ✅ Simple procedural testbench

**Mode Selection:**
```verilog
parameter ARBIT_MODE = 1;  // 0=FIXED, 1=ROUND_ROBIN, 2=QOS
```

---

### **2. SystemVerilog Version**
**File:** `SystemVerilog/arb_test_systemverilog.sv`

**Features:**
- ✅ SystemVerilog features (logic, string parameters)
- ✅ More readable code
- ✅ String parameter for mode selection
- ✅ Modern syntax

**Mode Selection:**
```systemverilog
parameter string ARBIT_MODE = "ROUND_ROBIN";  // "FIXED", "ROUND_ROBIN", "QOS"
```

---

## How to Run Tests

### **Option 1: QuestaSim/ModelSim**

#### **Test Verilog Version:**

```bash
# Navigate to simulation directory
cd D:\AXI\sim\modelsim\scripts\sim

# Test FIXED mode
vlog -work work D:\AXI\src\axi_interconnect\Verilog\rtl\arbitration\axi_rr_interconnect_2x4.v
vlog -work work D:\AXI\tb\interconnect_tb\Verilog\arb_test_verilog.v
vsim -c -g ARBIT_MODE=0 work.arb_test_verilog -do "run -all; quit"

# Test ROUND_ROBIN mode
vsim -c -g ARBIT_MODE=1 work.arb_test_verilog -do "run -all; quit"

# Test QOS mode
vsim -c -g ARBIT_MODE=2 work.arb_test_verilog -do "run -all; quit"
```

#### **Test SystemVerilog Version:**

```bash
# Compile
vlog -sv -work work D:\AXI\src\axi_interconnect\SystemVerilog\rtl\arbitration\axi_rr_interconnect_2x4.sv
vlog -sv -work work D:\AXI\tb\interconnect_tb\SystemVerilog\arb_test_systemverilog.sv

# Test FIXED mode
vsim -c -g ARBIT_MODE="FIXED" work.arb_test_systemverilog -do "run -all; quit"

# Test ROUND_ROBIN mode
vsim -c -g ARBIT_MODE="ROUND_ROBIN" work.arb_test_systemverilog -do "run -all; quit"

# Test QOS mode
vsim -c -g ARBIT_MODE="QOS" work.arb_test_systemverilog -do "run -all; quit"
```

---

### **Option 2: Edit Parameter in Source**

#### **Verilog:**
Edit `arb_test_verilog.v`:
```verilog
// Line ~13: Change ARBIT_MODE
parameter ARBIT_MODE = 0;  // Test FIXED
// or
parameter ARBIT_MODE = 1;  // Test ROUND_ROBIN
// or
parameter ARBIT_MODE = 2;  // Test QOS
```

Then compile and run:
```bash
vlog D:\AXI\src\axi_interconnect\Verilog\rtl\arbitration\axi_rr_interconnect_2x4.v
vlog D:\AXI\tb\interconnect_tb\Verilog\arb_test_verilog.v
vsim -c work.arb_test_verilog -do "run -all; quit"
```

#### **SystemVerilog:**
Edit `arb_test_systemverilog.sv`:
```systemverilog
// Line ~14: Change ARBIT_MODE
parameter string ARBIT_MODE = "FIXED";         // Test FIXED
// or
parameter string ARBIT_MODE = "ROUND_ROBIN";   // Test ROUND_ROBIN
// or
parameter string ARBIT_MODE = "QOS";           // Test QOS
```

Then compile and run:
```bash
vlog -sv D:\AXI\src\axi_interconnect\SystemVerilog\rtl\arbitration\axi_rr_interconnect_2x4.sv
vlog -sv D:\AXI\tb\interconnect_tb\SystemVerilog\arb_test_systemverilog.sv
vsim -c work.arb_test_systemverilog -do "run -all; quit"
```

---

## Expected Results

### **FIXED Priority Mode**
```
========================================
ARBITRATION TEST: FIXED PRIORITY
========================================

[TEST] Both masters request 10 times
[65000] M0 Write granted (total=1)
[135000] M0 Write granted (total=2)
[205000] M0 Write granted (total=3)
...
[695000] M0 Write granted (total=10)

========================================
RESULTS
========================================
Mode: FIXED
M0 QoS=10, M1 QoS=2
M0 granted: 10 times
M1 granted: 0 times
>>> PASS: FIXED mode works (M0 always wins)
========================================
```

**Expected:** M0 = 10, M1 = 0 (M0 always wins)

---

### **ROUND_ROBIN Mode**
```
========================================
ARBITRATION TEST: ROUND_ROBIN
========================================

[TEST] Both masters request 10 times
[65000] M1 Write granted (total=1)
[135000] M0 Write granted (total=1)
[205000] M1 Write granted (total=2)
[275000] M0 Write granted (total=2)
...

========================================
RESULTS
========================================
Mode: ROUND_ROBIN
M0 QoS=10, M1 QoS=2
M0 granted: 5 times
M1 granted: 5 times
>>> PASS: ROUND_ROBIN mode works (fair 50/50)
========================================
```

**Expected:** M0 = 5, M1 = 5 (Perfect fairness)

---

### **QOS Mode**
```
========================================
ARBITRATION TEST: QOS
========================================

[TEST] Both masters request 10 times
[65000] M0 Write granted (total=1)
[135000] M0 Write granted (total=2)
[205000] M0 Write granted (total=3)
...
[695000] M0 Write granted (total=10)

========================================
RESULTS
========================================
Mode: QOS
M0 QoS=10, M1 QoS=2
M0 granted: 10 times
M1 granted: 0 times
>>> PASS: QOS mode works (M0 QoS=10 > M1 QoS=2)
========================================
```

**Expected:** M0 = 10, M1 = 0 (M0 has higher QoS)

---

## Testbench Description

### **Test Scenario:**
1. Both masters request **simultaneously** 10 times
2. M0 writes to Slave 0 (address `0x0000_1000`)
3. M1 writes to Slave 1 (address `0x4000_2000`)
4. Monitor counts how many times each master is granted

### **QoS Configuration:**
- **M0 QoS = 10** (Higher priority)
- **M1 QoS = 2** (Lower priority)

### **Slave Models:**
- All 4 slaves always ready (AWREADY=1, WREADY=1)
- Immediate response (1 cycle delay)
- Response = OKAY (2'b00)

### **Timeout:**
- 50,000 ns (50 µs)

---

## Troubleshooting

### **Issue 1: "Module not found"**
**Solution:** Compile RTL before testbench:
```bash
# Verilog
vlog D:\AXI\src\axi_interconnect\Verilog\rtl\arbitration\axi_rr_interconnect_2x4.v
vlog D:\AXI\tb\interconnect_tb\Verilog\arb_test_verilog.v

# SystemVerilog
vlog -sv D:\AXI\src\axi_interconnect\SystemVerilog\rtl\arbitration\axi_rr_interconnect_2x4.sv
vlog -sv D:\AXI\tb\interconnect_tb\SystemVerilog\arb_test_systemverilog.sv
```

---

### **Issue 2: "FAIL: Expected results not met"**
**Possible causes:**
1. **FIXED mode:** Check M0 is always granted when both request
2. **ROUND_ROBIN mode:** Check turn pointer toggles correctly
3. **QOS mode:** Check M0_AWQOS (10) > M1_AWQOS (2)

**Debug:**
- Add waveform dump: `$dumpfile("waves.vcd"); $dumpvars(0, arb_test_verilog);`
- Check internal signals: `wr_turn`, `grant_m0`, `grant_m1`

---

### **Issue 3: "Only 1 transaction granted instead of 10"**
**Cause:** This is expected! The interconnect has a **write_active** state machine that only allows 1 outstanding write transaction at a time.

**Solution:** The testbench already accounts for this by:
1. Waiting for previous transaction to complete (4 cycles)
2. Then issuing next transaction

If you see < 10 grants, check:
- Slave response timing (BVALID/BREADY)
- Write data channel (WVALID/WREADY)

---

## Customization

### **Change Number of Tests:**
```verilog
// Verilog
integer total_tests;
initial begin
    total_tests = 20;  // Test 20 times instead of 10
    // ...
end
```

```systemverilog
// SystemVerilog
int total_tests = 20;  // Test 20 times
```

---

### **Change QoS Values:**
```verilog
// Make M1 higher priority than M0
M0_AWQOS = 4'd2;   // Low
M1_AWQOS = 4'd10;  // High
```

Then in QOS mode, M1 should win all arbitrations.

---

### **Add Waveform Dump:**

**Verilog:**
```verilog
initial begin
    $dumpfile("arb_test.vcd");
    $dumpvars(0, arb_test_verilog);
    // ... rest of test
end
```

**SystemVerilog:**
```systemverilog
initial begin
    $dumpfile("arb_test.vcd");
    $dumpvars(0, arb_test_systemverilog);
    // ... rest of test
end
```

View with GTKWave:
```bash
gtkwave arb_test.vcd
```

---

## Summary

| Feature | Verilog TB | SystemVerilog TB |
|---------|------------|------------------|
| **Compatibility** | All simulators | Modern simulators |
| **Syntax** | Verilog-2001 | SystemVerilog |
| **Mode Parameter** | Integer (0,1,2) | String ("FIXED",...) |
| **Readability** | Good | Excellent |
| **Functionality** | Identical | Identical |

**Recommendation:**
- Use **Verilog version** for maximum compatibility
- Use **SystemVerilog version** for better readability

Both produce identical test results and verify all 3 arbitration modes!

---

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Ready to Use


