# 🐛 BUG FIX REPORT - Dual RISC-V AXI System

## 📋 SUMMARY

**Problem**: Dual RISC-V system simulation showed **0 transactions** despite RISC-V cores running.

**Root Cause Found**: **ARBITRATION_MODE parameter type mismatch**

**Status**: ✅ **FIXED** (Parameter corrected, recompiled, needs final verification with waveform)

---

## 🔍 DEBUGGING PROCESS

### Step 1: Initial Observation
```
Transaction Statistics:
  Master 0 Writes: 0
  Master 1 Writes: 0
  Master 0 Reads:  0
  Master 1 Reads:  0
  Total: 0 transactions  ← ❌ NO ACTIVITY
```

### Step 2: Signal Analysis
Using debug TCL scripts, traced the signal path:

```
SERV Core → WB2AXI → AXI Master → Interconnect → RAM
```

**Key Findings:**
1. ✅ SERV core `ibus_cyc = 1` (fetching instructions)
2. ✅ WB2AXI `wb_cyc = 1` (converting to AXI)
3. ✅ Master 0 `arvalid = 1` (requesting)
4. ❌ Master 0 `arready = 0` (NOT granted by interconnect!)

### Step 3: Interconnect Analysis
Traced inside `axi_rr_interconnect_2x4`:

```
m0_ar_req:   1  ← Master 0 requesting ✓
m1_ar_req:   1  ← Master 1 ALSO requesting ✓
rd_turn:     1  ← Turn = MAST1
grant_r_m0:  0  ← M0 NOT granted (because turn = M1)
grant_r_m1:  1  ← M1 granted ✓
```

**This is NORMAL behavior for round-robin!** But why is arbitration logic broken?

### Step 4: Parameter Investigation
Checked `ARBITRATION_MODE` parameter value:

```
ARBITRATION_MODE: 1329744206  ← ❌ GARBAGE VALUE!
```

Expected: `1` (ROUND_ROBIN)
Actual: `1329744206` (string interpreted as integer)

### Step 5: Root Cause Identified

**File**: `src/systems/dual_riscv_axi_system.v`  
**Line**: 600

```verilog
// BEFORE (WRONG):
axi_rr_interconnect_2x4 #(
    .ARBITRATION_MODE("ROUND_ROBIN")  // ❌ STRING!
) u_rr_xbar (
```

**Module Definition** (axi_rr_interconnect_2x4.v, line 19):
```verilog
parameter integer ARBITRATION_MODE = 1  // Expects INTEGER!
```

**Problem**: Verilog interpreted string `"ROUND_ROBIN"` as integer (ASCII encoding), resulting in garbage value `1329744206`.

---

## 🔧 THE FIX

### Changed Line 600 in `dual_riscv_axi_system.v`:

```verilog
// AFTER (CORRECT):
axi_rr_interconnect_2x4 #(
    .ARBITRATION_MODE(1)  // 0=FIXED, 1=ROUND_ROBIN, 2=QOS
) u_rr_xbar (
```

### Verification:
```
ARBITRATION_MODE: 1  ✅ CORRECT!
```

---

## 📊 EXPECTED BEHAVIOR AFTER FIX

With proper round-robin arbitration:

1. **Both SERV cores fetch instructions concurrently**
2. **Interconnect arbitrates fairly between M0 and M1**
3. **Transactions alternate**: M1 → M0 → M1 → M0...
4. **Transaction counters should increment**

---

## 🎯 NEXT STEPS

1. ✅ **Recompile**: Done (64 files compiled successfully)
2. 🔄 **Run with waveform**: In progress (GUI open)
3. ⏳ **Verify transactions**: Need to check waveform for actual AXI activity
4. ⏳ **Update testbench** (if needed): Transaction counter logic may need review

---

## 📝 FILES MODIFIED

- `src/systems/dual_riscv_axi_system.v` (line 600)

---

## 🧪 DEBUG SCRIPTS CREATED

- `debug_dual_riscv.tcl` - Initial debug with signals
- `console_debug.tcl` - Console-based signal value checking
- `quick_debug.tcl` - Simplified GUI waveform setup
- `detailed_debug.tcl` - Full read path analysis
- `arb_debug.tcl` - Arbitration logic focus

---

## 💡 LESSONS LEARNED

1. **Parameter Type Matters**: Always match parameter types (integer vs string)
2. **Verilog's Silent Failure**: String-to-integer conversion doesn't throw errors
3. **Hierarchical Debugging**: Trace signals through entire path to find bottleneck
4. **Arbitration Complexity**: Multi-master systems need careful debugging

---

**Report Generated**: `date +%Y-%m-%d`  
**Engineer**: AI Assistant (Claude Sonnet 4.5)  
**Status**: Awaiting final waveform verification


