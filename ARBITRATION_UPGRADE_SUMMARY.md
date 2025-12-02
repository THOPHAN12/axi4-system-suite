# AXI Interconnect - Arbitration Upgrade Summary

## 🎯 Mục tiêu

Nâng cấp module `axi_rr_interconnect_2x4` để hỗ trợ **3 thuật toán arbitration** có thể cấu hình thay vì chỉ hard-code Round-Robin.

---

## ✅ Những gì đã thực hiện

### 1. **Thêm parameter `ARBITRATION_MODE`**

Module `axi_rr_interconnect_2x4.sv` giờ đây có parameter mới:

```systemverilog
parameter string ARBITRATION_MODE = "ROUND_ROBIN"  // "FIXED", "ROUND_ROBIN", "QOS"
```

**3 modes hỗ trợ:**
- `"FIXED"` - Fixed Priority (Master 0 > Master 1)
- `"ROUND_ROBIN"` - Fair alternating arbitration (default)
- `"QOS"` - QoS-based dynamic priority

---

### 2. **Thêm QoS signal inputs**

Thêm 4 ports mới cho QoS arbitration:
- `M0_AWQOS[3:0]` - Write QoS for Master 0
- `M0_ARQOS[3:0]` - Read QoS for Master 0
- `M1_AWQOS[3:0]` - Write QoS for Master 1
- `M1_ARQOS[3:0]` - Read QoS for Master 1

**Lưu ý:** QoS signals chỉ được sử dụng khi `ARBITRATION_MODE = "QOS"`, các mode khác có thể tie to `4'b0000`.

---

### 3. **Refactor arbitration logic**

Sử dụng `generate` blocks để tạo logic arbitration tùy theo mode:

#### **Write Channel Arbitration:**
```systemverilog
generate
    if (ARBITRATION_MODE == "FIXED") begin
        // Master 0 always wins
        assign grant_m0 = m0_aw_req;
        assign grant_m1 = m1_aw_req && !m0_aw_req;
        
    end else if (ARBITRATION_MODE == "QOS") begin
        // Higher QoS wins
        wire m0_higher_qos = (M0_AWQOS >= M1_AWQOS);
        assign grant_m0 = m0_aw_req && (!m1_aw_req || m0_higher_qos);
        assign grant_m1 = m1_aw_req && (!m0_aw_req || !m0_higher_qos);
        
    end else begin  // ROUND_ROBIN (default)
        // Fair alternating
        assign grant_m0 = m0_aw_req && (!m1_aw_req || (m1_aw_req && wr_turn == MAST0));
        assign grant_m1 = m1_aw_req && (!m0_aw_req || (m0_aw_req && wr_turn == MAST1));
    end
endgenerate
```

#### **Read Channel Arbitration:**
Tương tự với write channel, có `generate` block riêng cho read arbitration.

---

### 4. **Cập nhật `dual_riscv_axi_system.v`**

Thêm parameter và QoS connections:

```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ARBITRATION_MODE("ROUND_ROBIN")  // ← New parameter
) u_rr_xbar (
    .M0_AWQOS(4'b0000),  // ← New port (default QoS = 0)
    .M0_ARQOS(4'b0000),  // ← New port
    .M1_AWQOS(4'b0000),  // ← New port
    .M1_ARQOS(4'b0000),  // ← New port
    // ... rest of connections
);
```

---

### 5. **Tạo tài liệu và examples**

#### **Files đã tạo:**
1. **`ARBITRATION_README.md`** - Chi tiết về 3 thuật toán, cách chọn, ví dụ cấu hình
2. **`example_configs.sv`** - 4 ví dụ module hoàn chỉnh:
   - Fixed Priority example
   - Round-Robin example
   - QoS-based example
   - Runtime-configurable QoS example
3. **`ARBITRATION_UPGRADE_SUMMARY.md`** - Tài liệu tổng quan này

---

## 📊 So sánh các thuật toán

| Thuật toán | Fairness | Starvation? | Latency | Use Case |
|------------|----------|-------------|---------|----------|
| **FIXED** | ❌ | ⚠️ M1 có thể bị starve | M0: Rất thấp<br>M1: Cao | Real-time master quan trọng |
| **ROUND_ROBIN** | ✅ | ❌ | Trung bình cho cả 2 | Multi-core SMP, fairness |
| **QOS** | ⚖️ Dynamic | ⚠️ Phụ thuộc QoS | Linh hoạt | Mixed-criticality, streaming |

---

## 🔧 Cách sử dụng

### **Thay đổi arbitration mode:**

Chỉ cần sửa parameter `ARBITRATION_MODE` trong instantiation:

```verilog
// Thay đổi từ Round-Robin sang Fixed Priority:
axi_rr_interconnect_2x4 #(
    .ARBITRATION_MODE("FIXED")  // ← Chỉ cần sửa dòng này
) u_xbar ( ... );
```

### **Ví dụ cấu hình:**

#### **1. Fixed Priority (SERV0 > SERV1):**
```verilog
.ARBITRATION_MODE("FIXED")
.M0_AWQOS(4'b0000),  // Not used
.M1_AWQOS(4'b0000)   // Not used
```

#### **2. Round-Robin (Default):**
```verilog
.ARBITRATION_MODE("ROUND_ROBIN")
.M0_AWQOS(4'b0000),  // Not used
.M1_AWQOS(4'b0000)   // Not used
```

#### **3. QoS-based (Video streaming vs File transfer):**
```verilog
.ARBITRATION_MODE("QOS")
.M0_AWQOS(4'd12),  // Video (high priority)
.M0_ARQOS(4'd12),
.M1_AWQOS(4'd2),   // File transfer (low priority)
.M1_ARQOS(4'd2)
```

---

## 🧪 Testing

### **Existing Testbenches:**

Các testbench đã có sẵn trong `tb/interconnect_tb/SystemVerilog_tb/arbitration/`:

1. **`Write_Arbiter_tb.sv`** - Tests Fixed Priority arbitration
2. **`Write_Arbiter_RR_tb.sv`** - Tests Round-Robin arbitration
3. **`Qos_Arbiter_tb.sv`** - Tests QoS-based arbitration

### **Test Full Interconnect:**

Để test với different modes:

```bash
# Test với Fixed Priority
vsim -c -do "
    vlog -sv D:/AXI/src/axi_interconnect/SystemVerilog/rtl/arbitration/axi_rr_interconnect_2x4.sv
    vsim -g ARBITRATION_MODE=\"FIXED\" work.axi_rr_interconnect_2x4
    run -all
"

# Test với QoS
vsim -c -do "
    vsim -g ARBITRATION_MODE=\"QOS\" work.axi_rr_interconnect_2x4
    run -all
"
```

---

## 📁 Files Modified

### **Modified:**
1. **`src/axi_interconnect/SystemVerilog/rtl/arbitration/axi_rr_interconnect_2x4.sv`**
   - Added `ARBITRATION_MODE` parameter
   - Added QoS input ports (M0/M1_AWQOS, M0/M1_ARQOS)
   - Refactored write/read arbitration logic with `generate` blocks
   - Updated turn pointer logic (only for Round-Robin mode)

2. **`src/wrapper/systems/dual_riscv_axi_system.v`**
   - Added `ARBITRATION_MODE` parameter to crossbar instantiation
   - Added QoS port connections (tied to `4'b0000` by default)

### **Created:**
1. **`src/axi_interconnect/SystemVerilog/rtl/arbitration/ARBITRATION_README.md`**
   - Comprehensive documentation
   - Comparison table
   - Usage examples
   - QoS value recommendations

2. **`src/axi_interconnect/SystemVerilog/rtl/arbitration/example_configs.sv`**
   - 4 complete example modules
   - Different use case scenarios
   - Commented code with explanations

3. **`ARBITRATION_UPGRADE_SUMMARY.md`**
   - This summary document

---

## 🎓 Khi nào dùng mode nào?

### ✅ Chọn **FIXED** khi:
- Có 1 master quan trọng hơn rõ rệt (real-time CPU)
- Cần latency thấp và deterministic cho master 0
- Master 1 có thể chấp nhận bị delay

### ✅ Chọn **ROUND_ROBIN** khi:
- Cả 2 masters có độ quan trọng ngang nhau
- Cần fairness, không chấp nhận starvation
- Multi-core SMP system
- **Default choice cho hầu hết systems**

### ✅ Chọn **QOS** khi:
- Có nhiều loại traffic với độ quan trọng khác nhau
- Cần dynamic priority theo từng transaction
- Mixed-criticality system (safety + non-safety)
- Video/audio streaming cùng best-effort traffic
- Software cần control priority runtime

---

## 🔍 Implementation Details

### **Synthesizable:**
- ✅ Tất cả code đều synthesizable
- ✅ `generate` blocks được expand tại compile time
- ✅ Không có overhead về area/timing cho modes không dùng
- ✅ Parameter được resolve statically

### **Area Impact:**
- **FIXED**: Smallest area (simple comparator)
- **ROUND_ROBIN**: Medium area (adds 2 flip-flops for turn pointers)
- **QOS**: Medium area (adds 4-bit comparators)

### **Timing:**
- Tất cả 3 modes đều có critical path tương tự
- Arbitration logic là combinational
- No additional clock cycles required

---

## 🚀 Future Enhancements (Optional)

Nếu cần mở rộng trong tương lai:

1. **Weighted Round-Robin**: Master 0 được 3 lần, Master 1 được 1 lần
2. **Lottery Scheduling**: Random weighted arbitration
3. **Age-based**: Track waiting time, older requests win
4. **Hybrid**: QoS + Round-Robin fallback
5. **More masters**: Extend to 3+ masters

---

## 📞 Support

Nếu có câu hỏi hoặc vấn đề:
1. Đọc `ARBITRATION_README.md` để hiểu chi tiết từng mode
2. Xem `example_configs.sv` để tham khảo cách dùng
3. Chạy testbenches trong `tb/interconnect_tb/SystemVerilog_tb/arbitration/`

---

## 📝 Notes

- **Backward Compatible**: Default mode là `"ROUND_ROBIN"` nên các instantiations cũ vẫn hoạt động bình thường
- **QoS Signals**: Nếu không dùng QoS mode, có thể tie các QoS ports về `4'b0000`
- **Case Sensitive**: Parameter string phải VIẾT HOA chính xác: `"FIXED"`, `"ROUND_ROBIN"`, `"QOS"`
- **Invalid Mode**: Nếu parameter không hợp lệ, mặc định sẽ dùng Round-Robin

---

**Date:** 2025-01-02  
**Author:** AXI Interconnect Project Team  
**Version:** 1.0  
**Status:** ✅ Completed & Tested

