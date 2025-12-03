# 📊 Test Cases Explained - Chi Tiết Hoạt Động

## 🎯 **Overview**

Document này giải thích chi tiết cách các test cases hoạt động và những gì bạn sẽ nhìn thấy.

---

## 🧪 **3 Test Cases Chính**

### **Test Case 1: FIXED Priority Mode** 🥇

#### **Mục đích:**
Test xem Master 0 có luôn được ưu tiên hơn Master 1 không.

#### **Setup:**
```verilog
ARBITRATION_MODE = 0  // or "FIXED"
M0_AWQOS = 10
M1_AWQOS = 2
```

#### **Kịch bản test:**
1. Cả 2 masters request đồng thời 10 lần
2. M0 writes to Slave 0 (address 0x0000_1000)
3. M1 writes to Slave 1 (address 0x4000_2000)

#### **Những gì bạn sẽ thấy trong waveform:**

```
Time    | M0_AWVALID | M1_AWVALID | M0_AWREADY | M1_AWREADY | Who Wins?
--------|------------|------------|------------|------------|----------
65ns    |     1      |     1      |     1      |     0      | M0 ✅
135ns   |     1      |     1      |     1      |     0      | M0 ✅
205ns   |     1      |     1      |     1      |     0      | M0 ✅
275ns   |     1      |     1      |     1      |     0      | M0 ✅
...     |    ...     |    ...     |    ...     |    ...     | ...
```

#### **Expected Result:**
```
✅ M0 granted: 10 times
✅ M1 granted: 0 times
>>> PASS: FIXED mode works (M0 always wins)
```

#### **Signals quan trọng để xem:**
- `grant_m0` - Luôn = 1 khi cả 2 request
- `grant_m1` - Luôn = 0 khi M0 request
- `write_master` - Luôn = 0 (MAST0)
- `M0_AWREADY` - Luôn = 1 khi M0 request
- `M1_AWREADY` - Luôn = 0 khi M0 cũng request

---

### **Test Case 2: ROUND_ROBIN Mode** 🔄

#### **Mục đích:**
Test xem arbitration có fair (công bằng) giữa 2 masters không.

#### **Setup:**
```verilog
ARBITRATION_MODE = 1  // or "ROUND_ROBIN"
M0_AWQOS = 10  // (không dùng trong RR mode)
M1_AWQOS = 2   // (không dùng trong RR mode)
```

#### **Kịch bản test:**
Giống Test 1, nhưng arbitration sẽ alternate (luân phiên).

#### **Những gì bạn sẽ thấy trong waveform:**

```
Time    | M0_AWVALID | M1_AWVALID | M0_AWREADY | M1_AWREADY | wr_turn | Who Wins?
--------|------------|------------|------------|------------|---------|----------
65ns    |     1      |     1      |     0      |     1      | MAST1   | M1 ✅
135ns   |     1      |     1      |     1      |     0      | MAST0   | M0 ✅
205ns   |     1      |     1      |     0      |     1      | MAST1   | M1 ✅
275ns   |     1      |     1      |     1      |     0      | MAST0   | M0 ✅
345ns   |     1      |     1      |     0      |     1      | MAST1   | M1 ✅
...     |    ...     |    ...     |    ...     |    ...     |  ...    | ...
```

#### **Expected Result:**
```
✅ M0 granted: 5 times
✅ M1 granted: 5 times
>>> PASS: ROUND_ROBIN mode works (fair 50/50)
```

#### **Signals quan trọng để xem:**
- `wr_turn` - Toggles: MAST0 ↔ MAST1 ↔ MAST0 ↔ MAST1
- `grant_m0` - Alternates với grant_m1
- `grant_m1` - Alternates với grant_m0
- `write_master` - Toggles: 0 → 1 → 0 → 1 → 0

#### **Animation trong waveform:**
```
wr_turn:     ___╱‾‾‾╲___╱‾‾‾╲___╱‾‾‾
grant_m0:    ‾‾‾╲___╱‾‾‾╲___╱‾‾‾╲___
grant_m1:    ___╱‾‾‾╲___╱‾‾‾╲___╱‾‾‾
```

---

### **Test Case 3: QOS Priority Mode** ⭐

#### **Mục đích:**
Test xem QoS values có điều khiển priority không.

#### **Setup:**
```verilog
ARBITRATION_MODE = 2  // or "QOS"
M0_AWQOS = 10  // Higher priority
M1_AWQOS = 2   // Lower priority
```

#### **Kịch bản test:**
Giống Test 1, nhưng priority dựa trên QoS value.

#### **Những gì bạn sẽ thấy trong waveform:**

```
Time    | M0_AWQOS | M1_AWQOS | M0_AWREADY | M1_AWREADY | Who Wins? | Why?
--------|----------|----------|------------|------------|-----------|------
65ns    |    10    |    2     |     1      |     0      | M0 ✅     | 10>2
135ns   |    10    |    2     |     1      |     0      | M0 ✅     | 10>2
205ns   |    10    |    2     |     1      |     0      | M0 ✅     | 10>2
...     |   ...    |   ...    |    ...     |    ...     |   ...     | ...
```

#### **Expected Result:**
```
✅ M0 granted: 10 times (QoS=10)
✅ M1 granted: 0 times  (QoS=2)
>>> PASS: QOS mode works (M0 QoS=10 > M1 QoS=2)
```

#### **Signals quan trọng để xem:**
- `M0_AWQOS` - Constant = 10
- `M1_AWQOS` - Constant = 2
- `m0_higher_qos` - Always = 1 (10 >= 2)
- `grant_m0` - Always = 1 when both request
- `grant_m1` - Always = 0 when M0 also requests

#### **Thử nghiệm khác:**
Nếu swap QoS values:
```verilog
M0_AWQOS = 2   // Lower
M1_AWQOS = 10  // Higher
// Result: M1 wins all 10 times!
```

---

## 📈 **Timing Diagram Chi Tiết**

### **ROUND_ROBIN Mode (Chi tiết nhất)**

```
Clock:     ___╱‾╲_╱‾╲_╱‾╲_╱‾╲_╱‾╲_╱‾╲_╱‾╲_╱‾╲_
           
M0_AWVALID: ‾‾‾‾‾‾╱‾‾‾‾‾‾╲_____╱‾‾‾‾‾‾╲_____
M1_AWVALID: ‾‾‾‾‾‾╱‾‾‾‾‾‾‾‾‾‾‾‾╲_____╱‾‾‾‾‾‾
           
wr_turn:    MAST1 → MAST0 → MAST1 → MAST0 →
           
grant_m0:   _________╱‾‾‾‾╲_________╱‾‾‾‾╲___
grant_m1:   ‾‾‾‾╱‾‾‾‾╲_________╱‾‾‾‾╲_________
           
M0_AWREADY: _________╱‾‾‾‾╲_________╱‾‾‾‾╲___
M1_AWREADY: ‾‾‾‾╱‾‾‾‾╲_________╱‾‾‾‾╲_________
           
Transaction:   M1      M0      M1      M0
```

---

## 🔍 **Làm Thế Nào Để Xem Waveforms**

### **Method 1: ModelSim GUI (Đã mở)**

Trong cửa sổ ModelSim GUI:

1. **Wave window** - Xem signals
2. **Zoom controls**:
   - Zoom in: `Ctrl +`
   - Zoom out: `Ctrl -`
   - Zoom full: `F`
   - Zoom range: Select area + `Z`

3. **Important signals đã add:**
   ```
   /arb_test_verilog/M0_AWVALID
   /arb_test_verilog/M1_AWVALID
   /arb_test_verilog/M0_AWREADY
   /arb_test_verilog/M1_AWREADY
   /arb_test_verilog/dut/grant_m0
   /arb_test_verilog/dut/grant_m1
   /arb_test_verilog/dut/wr_turn
   /arb_test_verilog/dut/write_master
   /arb_test_verilog/m0_granted_count
   /arb_test_verilog/m1_granted_count
   ```

4. **Cursor & Measurements**:
   - Click to place cursor
   - Select region to measure time
   - Right-click → Measure → Delta

### **Method 2: Command Line với Waveform Dump**

```bash
cd D:\AXI\sim\modelsim\scripts\sim

# Add to testbench:
$dumpfile("arb_test.vcd");
$dumpvars(0, arb_test_verilog);

# Then view with GTKWave:
gtkwave ../../waveforms/arb_test.vcd
```

---

## 📊 **Test Scenarios Breakdown**

### **Scenario 1: Both Masters Request**
```
@time 65ns:
  M0_AWVALID = 1, M0_AWADDR = 0x0000_1000
  M1_AWVALID = 1, M1_AWADDR = 0x4000_2000
  
  Arbitration decides → Who gets AWREADY=1?
  
  FIXED:        M0 ✅
  ROUND_ROBIN:  Depends on wr_turn
  QOS:          M0 ✅ (QoS 10 > 2)
```

### **Scenario 2: Only M0 Requests**
```
@time 100ns:
  M0_AWVALID = 1
  M1_AWVALID = 0
  
  Result: M0 always wins (no contention)
  All modes: M0_AWREADY = 1
```

### **Scenario 3: Only M1 Requests**
```
@time 150ns:
  M0_AWVALID = 0
  M1_AWVALID = 1
  
  Result: M1 always wins (no contention)
  All modes: M1_AWREADY = 1
```

---

## 🎨 **Visual Indicators**

### **In Waveform:**

**FIXED Mode:**
```
grant_m0:  ████████████████████████  (Always high when both)
grant_m1:  ________________________  (Always low when M0 requests)
```

**ROUND_ROBIN Mode:**
```
grant_m0:  ████____████____████____  (Alternating)
grant_m1:  ____████____████____████  (Alternating)
```

**QOS Mode:**
```
grant_m0:  ████████████████████████  (High when higher QoS)
grant_m1:  ________________________  (Low when lower QoS)
```

---

## 🧪 **Verification Points**

### **What to Check in Waveforms:**

| Check | Signal | Expected |
|-------|--------|----------|
| **Arbitration works** | `grant_m0` XOR `grant_m1` | Always true (mutual exclusive) |
| **No deadlock** | `M0_AWREADY` OR `M1_AWREADY` | At least one ready |
| **Fair RR** | `wr_turn` | Toggles after each grant |
| **QoS priority** | `m0_higher_qos` | = (M0_AWQOS >= M1_AWQOS) |
| **Transaction count** | `m0_granted_count` + `m1_granted_count` | = 10 total |

---

## 📝 **Console Output Explained**

### **Successful Test:**
```
[65000] M0 Write granted (total=1)   ← First transaction at 65ns
[135000] M1 Write granted (total=1)  ← Second transaction at 135ns
...

M0 granted: 5 times                   ← Final count
M1 granted: 5 times
>>> PASS: ROUND_ROBIN mode works     ← Test result
```

### **What Each Line Means:**
- `[time]` - Simulation time in ns
- `Mx Write granted` - Which master got access
- `(total=N)` - Cumulative count for that master
- `>>> PASS/FAIL` - Test verdict

---

## 💡 **Tips for Viewing**

### **Best Signals to Watch:**

**Level 1 (Basic):**
- `M0_AWVALID`, `M1_AWVALID` - Requests
- `M0_AWREADY`, `M1_AWREADY` - Grants
- `m0_granted_count`, `m1_granted_count` - Counters

**Level 2 (Intermediate):**
- `grant_m0`, `grant_m1` - Internal arbitration
- `wr_turn` - Round-robin state (RR mode only)
- `write_master` - Active master
- `write_active` - Transaction in progress

**Level 3 (Advanced):**
- `m0_aw_req`, `m1_aw_req` - Request detection
- `m0_awhandshake`, `m1_awhandshake` - Handshake events
- `write_slave` - Which slave is being accessed
- `slave_awready()` - Slave ready signals

### **Zoom Recommendations:**
- **Full view**: See all 10 transactions (0-1000ns)
- **Detail view**: Zoom to 50-200ns to see first few transactions
- **Arbitration view**: Zoom to grant transitions

---

## 🎯 **Summary**

| Mode | Master Priority | Result | Visual Pattern |
|------|----------------|--------|----------------|
| **FIXED** | M0 > M1 | M0 always wins | M0 solid high |
| **ROUND_ROBIN** | Alternating | 50/50 split | Alternating bars |
| **QOS** | Based on QoS value | Higher QoS wins | Based on QoS comparison |

---

## 🚀 **Next Steps**

### **To Run Different Modes:**

```bash
cd D:\AXI\sim\modelsim\scripts\sim

# FIXED mode
vsim -gui work.arb_test_verilog -g ARBIT_MODE=0 -do "add wave -r /*; run -all"

# ROUND_ROBIN mode
vsim -gui work.arb_test_verilog -g ARBIT_MODE=1 -do "add wave -r /*; run -all"

# QOS mode
vsim -gui work.arb_test_verilog -g ARBIT_MODE=2 -do "add wave -r /*; run -all"
```

### **To Test with Different QoS:**

Edit testbench `arb_test_verilog.v`:
```verilog
M0_AWQOS = 4'd2;   // Change from 10 to 2
M1_AWQOS = 4'd10;  // Change from 2 to 10
// Now M1 should win in QoS mode!
```

---

**Enjoy exploring your AXI interconnect arbitration!** 🎉

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Ready for Demo

