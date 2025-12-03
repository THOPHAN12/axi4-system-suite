# 🌊 Waveform Viewing Guide - Hướng Dẫn Xem Waveforms

## 🎯 **ModelSim GUI đã mở!**

Nếu ModelSim GUI đang hiển thị, đây là cách sử dụng nó.

---

## 📺 **Giao Diện ModelSim**

```
┌─────────────────────────────────────────────────┐
│ ModelSim - arb_test_verilog                     │
├─────────────┬───────────────────────────────────┤
│             │                                   │
│  Objects    │         Waveform Window          │
│  (signals)  │    (timing diagram here)         │
│             │                                   │
│  - M0_...   │  ___╱‾‾‾╲___╱‾‾‾╲___            │
│  - M1_...   │  ‾‾‾╲___╱‾‾‾╲___╱‾‾              │
│  - dut/     │                                   │
│    - grant  │  [Cursor]  [Markers]             │
│             │                                   │
├─────────────┴───────────────────────────────────┤
│ Transcript (console output)                     │
│ # M0 granted: 5 times                           │
│ # M1 granted: 5 times                           │
└─────────────────────────────────────────────────┘
```

---

## 🖱️ **Basic Controls**

### **Navigation:**
| Action | Method 1 | Method 2 |
|--------|----------|----------|
| **Zoom In** | `Ctrl` + `+` | Mouse wheel up |
| **Zoom Out** | `Ctrl` + `-` | Mouse wheel down |
| **Zoom Full** | `F` key | View → Zoom → Full |
| **Zoom to Selection** | Select area + `Z` | Right-click → Zoom |
| **Pan Left/Right** | Click & drag | Arrow keys |
| **Go to Time** | `Ctrl` + `G` | View → Goto Time |

### **Cursor:**
| Action | Method |
|--------|--------|
| Place cursor | Left click on waveform |
| Move cursor | Arrow keys |
| Set marker | `M` key |
| Clear markers | Tools → Clear All Markers |

---

## 📊 **Important Signals để Xem**

### **Level 1: Basic (Bắt Buộc Xem)**

```
📍 Top-level Signals:
├── M0_AWVALID     ← Master 0 request
├── M1_AWVALID     ← Master 1 request  
├── M0_AWREADY     ← Master 0 granted
├── M1_AWREADY     ← Master 1 granted
├── m0_granted_count ← M0 total grants
└── m1_granted_count ← M1 total grants
```

**Cách xem:**
1. Trong Objects window, tìm signals trên
2. Select → Right-click → "Add to Wave"
3. Hoặc drag & drop vào Wave window

### **Level 2: Arbitration Logic (Hiểu Sâu)**

```
📍 DUT Internal Signals:
├── dut/
│   ├── grant_m0        ← Internal grant to M0
│   ├── grant_m1        ← Internal grant to M1
│   ├── wr_turn         ← Round-robin state
│   ├── write_master    ← Which master is active
│   ├── write_active    ← Transaction in progress
│   └── write_slave     ← Which slave selected
```

**Cách xem:**
1. Expand "dut" trong Objects window
2. Select signals
3. Right-click → "Add to Wave"

### **Level 3: Advanced (Debug)**

```
📍 Detailed Signals:
├── dut/
│   ├── m0_aw_req       ← M0 request detection
│   ├── m1_aw_req       ← M1 request detection
│   ├── m0_awhandshake  ← M0 handshake event
│   ├── m1_awhandshake  ← M1 handshake event
│   ├── m0_aw_sel       ← M0 slave selection
│   └── m1_aw_sel       ← M1 slave selection
```

---

## 🎨 **Signal Display Options**

### **Change Signal Format:**

1. Right-click on signal name
2. Select "Radix" →
   - **Binary** - For single bits
   - **Hexadecimal** - For addresses
   - **Unsigned Decimal** - For counts
   - **Symbolic** - For enums

### **Recommended Formats:**

| Signal | Format |
|--------|--------|
| `M0_AWVALID` | Binary |
| `M0_AWREADY` | Binary |
| `M0_AWADDR` | Hexadecimal |
| `m0_granted_count` | Unsigned Decimal |
| `wr_turn` | Symbolic (MAST0/MAST1) |
| `write_slave` | Symbolic (SLV0/1/2/3) |

---

## 🔍 **What to Look For**

### **FIXED Mode Patterns:**

```
M0_AWVALID:  ‾‾‾‾‾╱‾‾‾‾‾‾‾‾╲_____╱‾‾‾‾‾‾‾‾╲
M1_AWVALID:  ‾‾‾‾‾╱‾‾‾‾‾‾‾‾‾‾‾‾‾╲_____╱‾‾‾‾
                   Both request
M0_AWREADY:  _____╱‾‾‾╲_______________╱‾‾‾╲  ← M0 wins
M1_AWREADY:  _______________________________  ← M1 loses

✅ Check: M0 always wins when both request
```

### **ROUND_ROBIN Mode Patterns:**

```
M0_AWVALID:  ‾‾‾╱‾‾‾‾‾╲_____╱‾‾‾‾‾╲_____╱‾‾
M1_AWVALID:  ‾‾‾╱‾‾‾‾‾‾‾‾‾‾╲_____╱‾‾‾‾‾‾‾‾‾
             
wr_turn:     MAST1 → MAST0 → MAST1 → MAST0
             
M0_AWREADY:  _________╱‾‾‾╲_________╱‾‾‾╲___  ← Alternates
M1_AWREADY:  ‾‾‾‾╱‾‾‾╲_________╱‾‾‾╲_________  ← Alternates

✅ Check: wr_turn toggles, grants alternate
```

### **QOS Mode Patterns:**

```
M0_AWQOS:    10 (constant)
M1_AWQOS:    2  (constant)
             
M0_AWVALID:  ‾‾‾╱‾‾‾‾‾‾‾‾╲_____╱‾‾‾‾‾‾‾‾╲
M1_AWVALID:  ‾‾‾╱‾‾‾‾‾‾‾‾‾‾‾‾‾╲_____╱‾‾‾‾
                Both request
M0_AWREADY:  _____╱‾‾‾╲_______________╱‾‾‾╲  ← Higher QoS wins
M1_AWREADY:  _______________________________  ← Lower QoS loses

✅ Check: M0 wins (10 > 2)
```

---

## 📏 **Measurements**

### **Time Between Events:**

1. Click to place Cursor 1 (at first M0_AWREADY rising)
2. Shift+Click to place Cursor 2 (at second M0_AWREADY rising)
3. Delta time shown at bottom: `Delta: 120.00 ns`

### **Transaction Duration:**

1. Measure from AWVALID rising to BVALID rising
2. Typical: ~60-70 ns per transaction

### **Arbitration Delay:**

1. From both AWVALID high
2. To first AWREADY high
3. Should be ~10-20 ns

---

## 🎯 **Verification Checklist**

### **In Waveform, Verify:**

- [ ] **Mutual Exclusion**: `M0_AWREADY` and `M1_AWREADY` never both high
- [ ] **No Deadlock**: At least one ready when requests exist
- [ ] **Fair Arbitration** (RR): `wr_turn` toggles correctly
- [ ] **Priority Works** (FIXED/QOS): Higher priority always wins
- [ ] **Transaction Count**: Sum equals number of requests
- [ ] **Timing**: No glitches or X states

---

## 🛠️ **Troubleshooting**

### **Problem: Can't see signals**

**Solution:**
```
1. In Objects window → Right-click → "Refresh"
2. Or: View → Update → Update All
3. Check simulation is running: "run -all"
```

### **Problem: Waveform is blank**

**Solution:**
```
1. Check time range: Zoom Full (F key)
2. Restart sim: restart -f
3. Re-run: run -all
4. Re-add waves: add wave -r /*
```

### **Problem: Signals show 'X' or 'Z'**

**Solution:**
```
'X' = uninitialized → Check reset
'Z' = high-impedance → Check connections
```

### **Problem: Can't see internal DUT signals**

**Solution:**
```
1. Click on "dut" in Objects
2. Should expand to show internal signals
3. If not visible: View → Structure → Design
```

---

## 💡 **Pro Tips**

### **Tip 1: Group Related Signals**

Right-click signals → "New Group" → Name it
```
Group: "Master 0"
  - M0_AWVALID
  - M0_AWREADY
  - M0_AWADDR
  - m0_granted_count

Group: "Master 1"
  - M1_AWVALID
  - M1_AWREADY  
  - M1_AWADDR
  - m1_granted_count

Group: "Arbitration"
  - grant_m0
  - grant_m1
  - wr_turn
  - write_master
```

### **Tip 2: Use Cursors for Analysis**

- **Yellow cursor**: Mark transaction start
- **White cursor**: Mark transaction end
- **Delta**: Automatic time difference

### **Tip 3: Save Your Wave Configuration**

```
File → Save Format → wave.do
# Next time: do wave.do to restore
```

### **Tip 4: Compare Modes**

1. Run FIXED mode → Save waveform as "fixed.wlf"
2. Run RR mode → Save as "rr.wlf"
3. Run QOS mode → Save as "qos.wlf"
4. Compare side-by-side!

---

## 📸 **What You Should See**

### **Successful ROUND_ROBIN:**

```
Timeline (zoom to 0-500ns):

0ns     100ns    200ns    300ns    400ns    500ns
|        |        |        |        |        |
M0_AWVALID:  __╱‾‾‾‾╲___╱‾‾‾‾╲___╱‾‾‾‾╲___
M1_AWVALID:  __╱‾‾‾‾‾‾‾‾╲___╱‾‾‾‾‾‾‾‾╲___

M0_AWREADY:  ________╱‾╲________╱‾╲________  ← Alternating
M1_AWREADY:  ____╱‾╲________╱‾╲________╱‾╲  ← Alternating

wr_turn:     1→0→1→0→1→0→1→0  (toggling)

m0_granted:  0  1  1  2  2  3  (increments)
m1_granted:  0  0  1  1  2  2  (increments)
```

### **Transaction Markers:**

```
@65ns:  M1 wins (wr_turn was MAST1)
@135ns: M0 wins (wr_turn was MAST0)  
@205ns: M1 wins (wr_turn was MAST1)
@275ns: M0 wins (wr_turn was MAST0)
...
```

---

## 🎬 **Quick Start Workflow**

### **1. Open Waveform (if not already)**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -gui work.arb_test_verilog -g ARBIT_MODE=1
```

### **2. Add Signals**
```tcl
add wave -r /*
# Or specific:
add wave /arb_test_verilog/M0_AWVALID
add wave /arb_test_verilog/M1_AWVALID
add wave /arb_test_verilog/M0_AWREADY
add wave /arb_test_verilog/M1_AWREADY
add wave /arb_test_verilog/dut/wr_turn
add wave /arb_test_verilog/m0_granted_count
add wave /arb_test_verilog/m1_granted_count
```

### **3. Run Simulation**
```tcl
run -all
```

### **4. View Results**
```tcl
# Zoom to see all
wave zoom full

# Or zoom to interesting region
wave zoom range 50ns 300ns
```

### **5. Analyze**
- Place cursors at transaction points
- Measure delta times
- Verify counts match expected
- Check no glitches or X states

---

## 📚 **Additional Resources**

**In ModelSim GUI:**
- `Help → PDF Manuals → User's Manual`
- `Help → Tcl Command Reference`

**In This Project:**
- `TEST_CASES_EXPLAINED.md` - Detailed test explanation
- `QUICK_START.md` - Quick setup guide
- `README_TCL_SCRIPTS.md` - All TCL commands

---

## 🎉 **Enjoy Your Waveforms!**

**You should now see:**
- ✅ Clear signal transitions
- ✅ Arbitration in action
- ✅ Transaction counts
- ✅ Mode-specific behavior

**Perfect for:**
- 📊 Demo/presentation
- 🐛 Debugging
- 📝 Documentation
- 🎓 Learning

---

**Happy waveform viewing!** 🌊

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Complete Guide

