# AXI Interconnect Arbitration Modes

## 📚 3 Chế Độ Arbitration

Khi có **tranh chấp** (2 masters cùng request), interconnect dùng **arbiter** để quyết định master nào được phục vụ trước.

---

## 🎯 Khi Nào Dùng Mode Nào?

### **Mode 0: FIXED_PRIORITY** 👑

**Khi nào dùng:**
- ✅ Khi có 1 master **QUAN TRỌNG** hơn master khác
- ✅ Real-time system cần đảm bảo latency cho master ưu tiên
- ✅ Master 0 = Critical, Master 1 = Background tasks

**Đặc điểm:**
```
Priority: Master 0 > Master 1

Tranh chấp:
  M0 request + M1 request → M0 LUÔN LUÔN thắng
  
Example:
  M0 = Video controller (time-critical)
  M1 = DMA transfer (can wait)
  → M0 always gets bus first
```

**Ưu điểm:**
- ✅ Đơn giản, dễ hiểu
- ✅ Latency thấp cho master ưu tiên
- ✅ Deterministic (predictable)

**Nhược điểm:**
- ❌ Master 1 có thể bị **starvation** (chờ mãi)
- ❌ Không công bằng

**Code:**
```verilog
// In dual_riscv_axi_system.v
AXI_Interconnect #(
    .ARBITRATION_MODE(0)  // ← FIXED_PRIORITY
) u_axi_interconnect (
    ...
);
```

---

### **Mode 1: ROUND_ROBIN** 🔄 **(DEFAULT)**

**Khi nào dùng:**
- ✅ **MẶC ĐỊNH** - Dùng trong hầu hết trường hợp
- ✅ Khi muốn **CÔNG BẰNG** giữa các masters
- ✅ Không có master nào quan trọng hơn
- ✅ Muốn tránh starvation

**Đặc điểm:**
```
Turn-based: Masters take turns

State:
  turn = 0 → M0's turn (M0 has priority)
  turn = 1 → M1's turn (M1 has priority)

Tranh chấp:
  If turn=0: M0 request + M1 request → M0 thắng, turn → 1
  If turn=1: M0 request + M1 request → M1 thắng, turn → 0
  
Example sequence:
  Request 1: M0 & M1 → M0 wins (turn was 0) → turn=1
  Request 2: M0 & M1 → M1 wins (turn was 1) → turn=0
  Request 3: M0 & M1 → M0 wins (turn was 0) → turn=1
  → Perfect alternation!
```

**Ưu điểm:**
- ✅ **Công bằng** - Both masters get fair share
- ✅ **No starvation** - M1 won't wait forever
- ✅ Predictable average latency
- ✅ Good for balanced workloads

**Nhược điểm:**
- ⚠️ Phức tạp hơn Fixed Priority
- ⚠️ Cần state register (wr_turn, rd_turn)

**Code:**
```verilog
AXI_Interconnect #(
    .ARBITRATION_MODE(1)  // ← ROUND_ROBIN (default)
) u_axi_interconnect (
    ...
);
```

**Implementation trong AXI_Interconnect_Full.v:**
```verilog
// Round-Robin state
reg [1:0] wr_turn;  // Write arbiter turn
reg [1:0] rd_turn;  // Read arbiter turn

// Grant logic
assign grant_m0_write = m0_write_req && 
                       (!m1_write_req || (wr_turn == 2'b00));
assign grant_m1_write = m1_write_req && 
                       (!m0_write_req || (wr_turn == 2'b01));

// Update turn after grant
always @(posedge ACLK) begin
    if (!ARESETN) begin
        wr_turn <= 2'b01;  // Start with M1 priority
    end else begin
        if (grant_m0_write) begin
            wr_turn <= 2'b01;  // Next: M1's turn
        end else if (grant_m1_write) begin
            wr_turn <= 2'b00;  // Next: M0's turn
        end
    end
end
```

---

### **Mode 2: QOS_BASED** ⭐

**Khi nào dùng:**
- ✅ Khi có **dynamic priorities**
- ✅ Masters có **QoS (Quality of Service) values** khác nhau
- ✅ Priority thay đổi theo workload
- ✅ Advanced scheduling requirements

**Đặc điểm:**
```
Priority: Depends on QoS value (higher = more priority)

Each master has QoS signals:
  M0_QoS = 4-bit value (0-15)
  M1_QoS = 4-bit value (0-15)

Tranh chấp:
  M0_QoS=5, M1_QoS=3 → M0 wins (higher QoS)
  M0_QoS=2, M1_QoS=8 → M1 wins (higher QoS)
  M0_QoS=5, M1_QoS=5 → Tie-breaker (usually M0)

Example:
  Normal: M0_QoS=3, M1_QoS=3 → Equal priority
  Critical task on M1: M1_QoS → 15 → M1 wins!
```

**Ưu điểm:**
- ✅ **Dynamic** - Priorities can change
- ✅ **Flexible** - Adapt to workload
- ✅ Supports QoS differentiation
- ✅ Advanced traffic management

**Nhược điểm:**
- ⚠️ Phức tạp nhất
- ⚠️ Cần QoS signals từ masters
- ⚠️ Harder to verify

**Code:**
```verilog
AXI_Interconnect #(
    .ARBITRATION_MODE(2)  // ← QOS_BASED
) u_axi_interconnect (
    ...
);
```

**Implementation:**
```verilog
// QoS-based comparison
assign grant_m0_write = m0_write_req && 
                       (!m1_write_req || (M0_QoS >= M1_QoS));
assign grant_m1_write = m1_write_req && 
                       (!m0_write_req || (M1_QoS > M0_QoS));
```

---

## 📊 So Sánh 3 Modes

| Feature | Fixed Priority | Round-Robin | QoS-Based |
|---------|---------------|-------------|-----------|
| **Complexity** | ⭐ Low | ⭐⭐ Medium | ⭐⭐⭐ High |
| **Fairness** | ❌ No | ✅ Yes | ⚖️ Weighted |
| **Predictable** | ✅ Yes | ✅ Yes | ⚠️ Depends |
| **Starvation Risk** | ❌ High (M1) | ✅ None | ⚠️ Low |
| **Use Case** | Critical M0 | Balanced | Dynamic QoS |
| **State Needed** | None | Turn register | QoS compare |
| **Performance** | ⚡ Fast | ⚡ Fast | ⚡ Fast |

---

## 🧪 Test Results

### **Test với Mode 1 (Round-Robin)**

**Scenario**: 10 simultaneous WRITE requests

```
Expected:
  M0 wins: ~5 times (50%)
  M1 wins: ~5 times (50%)
  Pattern: Alternating

Actual (From testbench):
  M0 wins: X times
  M1 wins: Y times
  
  If |X - Y| ≤ 2: ✅ Fair
  If |X - Y| > 2: ⚠️ Imbalanced
```

---

## 🎯 Khi Nào Tranh Chấp Xảy Ra?

### **Scenario 1: Cả 2 Masters Request Cùng Lúc**

```
Cycle N:
  ┌─────────┐           ┌─────────┐
  │ Master 0│───AWVALID=1──→│         │
  └─────────┘           │  AXI    │
                        │  Inter- │
  ┌─────────┐           │ connect │
  │ Master 1│───AWVALID=1──→│         │
  └─────────┘           └─────────┘
  
  ⚠️ CONTENTION! Both requesting!
  
  Arbiter Decision:
    Mode 0: M0 wins
    Mode 1: Depends on turn (M0 or M1)
    Mode 2: Compare QoS
```

### **Scenario 2: Chỉ 1 Master Request**

```
Cycle N:
  ┌─────────┐           ┌─────────┐
  │ Master 0│───AWVALID=1──→│         │
  └─────────┘           │  AXI    │
                        │  Inter- │
  ┌─────────┐           │ connect │
  │ Master 1│───AWVALID=0──→│         │
  └─────────┘           └─────────┘
  
  ✅ NO CONTENTION
  
  Arbiter Decision:
    All modes: M0 wins (only requester)
    No arbitration needed
```

---

## 📋 Truth Table: Round-Robin

| Cycle | turn | M0_req | M1_req | Winner | New turn | Why |
|-------|------|--------|--------|--------|----------|-----|
| 1 | 0 | 1 | 0 | M0 | 1 | M0 only requester |
| 2 | 1 | 0 | 1 | M1 | 0 | M1 only requester |
| 3 | 0 | 1 | 1 | **M0** | 1 | M0's turn |
| 4 | 1 | 1 | 1 | **M1** | 0 | M1's turn |
| 5 | 0 | 1 | 1 | **M0** | 1 | M0's turn |
| 6 | 1 | 1 | 1 | **M1** | 0 | M1's turn |

**Pattern**: Perfect alternation when both request! ✅

---

## 🚀 How to Test Different Modes

### **Test Mode 0 (Fixed Priority)**

Edit `dual_riscv_axi_system.v` line ~597:
```verilog
AXI_Interconnect #(
    .ARBITRATION_MODE(0)  // ← Change to 0
) u_axi_interconnect (
```

Recompile và run `tb_arbitration_test.v`:
```tcl
vlog -work work -sv dual_riscv_axi_system.v
vlog -work work -sv tb_arbitration_test.v
vsim work.tb_arbitration_test
run -all
```

**Expected**: M0 wins ~10/10 (100%)

### **Test Mode 1 (Round-Robin)** ✅ Current

Already set to mode 1. Run testbench:
```tcl
vlog -work work -sv tb_arbitration_test.v
vsim work.tb_arbitration_test
run -all
```

**Expected**: M0 wins ~5/10, M1 wins ~5/10 (50/50)

### **Test Mode 2 (QoS-based)**

Edit to mode 2, recompile, run:

**Expected**: Depends on QoS values from masters

---

## 📊 Expected Test Output

```
//////////////////////////////////////////////////////////////////
/  ARBITRATION TEST - AXI Interconnect                          /
//////////////////////////////////////////////////////////////////

 Current Arbitration Mode: 1
 Mode Name: ROUND_ROBIN (DEFAULT)

//////////////////////////////////////////////////////////////////
/  TEST: WRITE Contention - Current Mode
//////////////////////////////////////////////////////////////////

  Scenario: Both masters request WRITE simultaneously

  Creating contention: Forcing both masters to request...

  [Request 1] Both masters requesting WRITE:
    M0: Addr=0x00000100 Data=0xAAAA0000
    M1: Addr=0x00000200 Data=0xBBBB0000
[120000] 🏆 WRITE GRANT → Master 0
[120000] 🔄 WR_TURN changed → 1

  [Request 2] Both masters requesting WRITE:
    M0: Addr=0x00000104 Data=0xAAAA0001
    M1: Addr=0x00000204 Data=0xBBBB0001
[260000] 🏆 WRITE GRANT → Master 1
[260000] 🔄 WR_TURN changed → 0

  [Request 3] Both masters requesting WRITE:
    M0: Addr=0x00000108 Data=0xAAAA0002
    M1: Addr=0x00000208 Data=0xBBBB0002
[400000] 🏆 WRITE GRANT → Master 0
[400000] 🔄 WR_TURN changed → 1

  ... (continues alternating)

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Results:
    Master 0 Write Grants: 5
    Master 1 Write Grants: 5

  Expected (Round-Robin): ~50/50 split
  ✅ CORRECT: Fair split (M0=5, M1=5)

... (Similar for READ)

//////////////////////////////////////////////////////////////////
/                    ARBITRATION TEST SUMMARY                    /
//////////////////////////////////////////////////////////////////

 Arbitration Mode: 1
 Mode: ROUND_ROBIN

 Total Grants:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Write Channel:
    Master 0: 5 grants
    Master 1: 5 grants
    Total:    10

  Read Channel:
    Master 0: 5 grants
    Master 1: 5 grants
    Total:    10

  Grand Total: 20 grants

 Arbitration Behavior Analysis:
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Write difference: 0 (Should be ≤2 for fair RR)
  Read difference:  0 (Should be ≤2 for fair RR)

  ✅ ROUND_ROBIN: Working correctly!
  Fair arbitration confirmed

//////////////////////////////////////////////////////////////////
/                    TEST COMPLETE                               /
//////////////////////////////////////////////////////////////////

 ✅ Arbitration logic verified
 ✅ Contention scenarios tested
 ✅ Both Write and Read channels tested
```

---

## 🎓 Decision Flow

### **When Contention Occurs:**

```
START: 2 masters request
  ↓
Check Arbitration Mode
  ↓
  ├─ Mode 0: FIXED_PRIORITY
  │    ├─ M0 request? → Grant M0
  │    └─ M0 no request? → Grant M1
  │
  ├─ Mode 1: ROUND_ROBIN
  │    ├─ Check turn register
  │    ├─ turn=0? → Grant M0, set turn=1
  │    └─ turn=1? → Grant M1, set turn=0
  │
  └─ Mode 2: QOS_BASED
       ├─ Compare M0_QoS vs M1_QoS
       ├─ M0_QoS > M1_QoS? → Grant M0
       ├─ M1_QoS > M0_QoS? → Grant M1
       └─ M0_QoS = M1_QoS? → Grant M0 (tie-breaker)
```

---

## 💡 Practical Examples

### **Example 1: Video System**

```
System:
  M0 = Video DMA (time-critical, needs constant bandwidth)
  M1 = CPU (can tolerate delays)
  
Best Mode: 0 (FIXED_PRIORITY)
  
Why?
  • Video DMA can't afford delays (frame drops)
  • CPU can wait a few cycles
  • M0 always gets priority
```

### **Example 2: Dual-Core System** ✅ (Current!)

```
System:
  M0 = SERV Core 0
  M1 = SERV Core 1
  
Best Mode: 1 (ROUND_ROBIN)
  
Why?
  • Both cores equally important
  • Fair scheduling
  • No starvation
  • Balanced performance
```

### **Example 3: Mixed Workload**

```
System:
  M0 = Real-time controller (variable priority)
  M1 = Background processor (variable priority)
  
Best Mode: 2 (QOS_BASED)
  
Why?
  • Priorities change dynamically
  • Sometimes M0 critical (high QoS)
  • Sometimes M1 critical (high QoS)
  • Flexible scheduling
```

---

## 🧪 Testing Recommendations

### **Để Test Arbitration Đầy Đủ:**

1. **Compile testbench**:
   ```tcl
   vlog -work work -sv tb_arbitration_test.v
   ```

2. **Run test**:
   ```tcl
   vsim work.tb_arbitration_test
   run -all
   ```

3. **Verify grants**:
   - Mode 1: Check M0 ≈ M1 (fair split)
   - Monitor turn changes
   - Verify alternation pattern

4. **Test all 3 modes**:
   - Change ARBITRATION_MODE in dual_riscv_axi_system.v
   - Recompile & rerun
   - Compare results

---

## ✅ Summary

| Mode | Khi Nào Dùng | Ưu Điểm | Nhược Điểm |
|------|--------------|---------|------------|
| **0: Fixed** | M0 critical | Simple, low latency M0 | M1 starvation |
| **1: RR** ⭐ | Equal importance | Fair, no starvation | Slightly complex |
| **2: QoS** | Dynamic priorities | Flexible, adaptive | Most complex |

**Current System**: Mode 1 (Round-Robin) ✅ **BEST cho dual SERV!**

---

**Document**: `ARBITRATION_MODES.md`  
**Testbench**: `tb_arbitration_test.v`  
**Status**: 🟢 Ready to test! ✅

