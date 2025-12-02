# AXI Interconnect - Configurable Arbitration

## Overview

Module `axi_rr_interconnect_2x4` hỗ trợ 3 thuật toán arbitration có thể cấu hình thông qua parameter `ARBITRATION_MODE`.

---

## Các thuật toán hỗ trợ

### 1. **FIXED Priority** (`ARBITRATION_MODE = "FIXED"`)

**Mô tả:**
- Master 0 **luôn được ưu tiên** cao hơn Master 1
- Khi cả 2 masters đều request → Master 0 luôn được phục vụ trước
- Đơn giản, deterministic, latency thấp cho Master 0

**Ưu điểm:**
- ✅ Latency thấp và dự đoán được cho master có priority cao
- ✅ Đơn giản, dễ debug
- ✅ Phù hợp khi có master real-time quan trọng

**Nhược điểm:**
- ❌ **Master 1 có thể bị starvation** nếu Master 0 request liên tục
- ❌ Không công bằng

**Use case:**
- Master 0 là real-time CPU core
- Master 1 là DMA hoặc peripheral controller ít quan trọng hơn

**Ví dụ:**
```systemverilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE("FIXED")  // Master 0 > Master 1
) u_xbar (
    // ... connections
);
```

---

### 2. **ROUND_ROBIN** (`ARBITRATION_MODE = "ROUND_ROBIN"`) - **DEFAULT**

**Mô tả:**
- **Công bằng** giữa 2 masters
- Sử dụng biến `wr_turn`/`rd_turn` để track master vừa được phục vụ
- Khi cả 2 request → chọn master **chưa được phục vụ lần trước**
- Pattern: M0 → M1 → M0 → M1 → ...

**Ưu điểm:**
- ✅ **Không có starvation** - cả 2 masters đều được phục vụ công bằng
- ✅ Fair arbitration
- ✅ Phù hợp cho hệ thống multi-core với độ ưu tiên ngang nhau

**Nhược điểm:**
- ⚠️ Latency trung bình cao hơn Fixed Priority
- ⚠️ Cần thêm logic để track turn pointer

**Use case:**
- 2 CPU cores với độ quan trọng ngang nhau
- Multi-master system cần fairness
- **Đây là mode mặc định** trong hệ thống dual RISC-V

**Ví dụ:**
```systemverilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE("ROUND_ROBIN")  // Fair arbitration
) u_xbar (
    // ... connections
);
```

---

### 3. **QoS-based** (`ARBITRATION_MODE = "QOS"`)

**Mô tả:**
- **Dynamic priority** dựa trên giá trị QoS của mỗi transaction
- Mỗi master gửi kèm `awqos[3:0]` / `arqos[3:0]` (4-bit priority, 0-15)
- Master có QoS **cao hơn** được ưu tiên
- Nếu QoS **bằng nhau** → Master 0 được ưu tiên (tie-breaker)

**Logic:**
```
if (M0_AWQOS >= M1_AWQOS)
    → Grant to M0
else
    → Grant to M1
```

**Ưu điểm:**
- ✅ **Linh hoạt** - priority thay đổi theo từng transaction
- ✅ Phù hợp cho hệ thống phức tạp với nhiều loại traffic
- ✅ Critical transactions (QoS cao) được ưu tiên
- ✅ Best-effort traffic (QoS thấp) vẫn được phục vụ khi không có traffic quan trọng

**Nhược điểm:**
- ⚠️ Master với QoS thấp có thể bị starvation nếu luôn có traffic QoS cao
- ⚠️ Phức tạp hơn, cần software/hardware config QoS tags
- ⚠️ Cần thêm wiring cho QoS signals

**Use case:**
- Video streaming (QoS cao) vs. file transfer (QoS thấp)
- Real-time control (QoS cao) vs. logging/debug (QoS thấp)
- Mixed-criticality systems

**QoS Values (ví dụ):**
- `4'b1111` (15) - Critical real-time traffic
- `4'b1000` (8)  - High priority
- `4'b0100` (4)  - Normal priority
- `4'b0001` (1)  - Low priority
- `4'b0000` (0)  - Best effort

**Ví dụ:**
```systemverilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE("QOS")  // QoS-based priority
) u_xbar (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    
    // Master 0 - Video streaming (QoS = 12)
    .M0_AWADDR(m0_awaddr),
    .M0_AWPROT(m0_awprot),
    .M0_AWQOS(4'd12),      // High priority
    .M0_AWVALID(m0_awvalid),
    .M0_AWREADY(m0_awready),
    .M0_ARQOS(4'd12),      // High priority for reads
    
    // Master 1 - File transfer (QoS = 2)
    .M1_AWADDR(m1_awaddr),
    .M1_AWPROT(m1_awprot),
    .M1_AWQOS(4'd2),       // Low priority
    .M1_AWVALID(m1_awvalid),
    .M1_AWREADY(m1_awready),
    .M1_ARQOS(4'd2),       // Low priority for reads
    
    // ... slave connections
);
```

---

## So sánh các thuật toán

| Thuật toán | Fairness | Starvation? | Latency (M0) | Latency (M1) | Complexity | Dynamic Priority |
|------------|----------|-------------|--------------|--------------|------------|------------------|
| **FIXED** | ❌ No | ⚠️ Yes (M1) | ⭐ Very Low | ⚠️ High | ⭐ Low | ❌ No |
| **ROUND_ROBIN** | ✅ Yes | ❌ No | 🟡 Medium | 🟡 Medium | 🟡 Medium | ❌ No |
| **QOS** | ⚖️ Dynamic | ⚠️ Possible | 🟢 Variable | 🟢 Variable | 🔴 High | ✅ Yes |

---

## Cách chọn thuật toán phù hợp

### Chọn **FIXED** khi:
- ✅ Có 1 master quan trọng hơn rõ rệt (real-time CPU)
- ✅ Cần latency thấp và deterministic cho master 0
- ✅ Master 1 có thể chấp nhận bị delay
- ✅ Hệ thống đơn giản, không cần fairness

### Chọn **ROUND_ROBIN** khi:
- ✅ Cả 2 masters có độ quan trọng ngang nhau
- ✅ Cần fairness, không chấp nhận starvation
- ✅ Multi-core SMP system
- ✅ **Mặc định cho hầu hết các hệ thống**

### Chọn **QOS** khi:
- ✅ Có nhiều loại traffic với độ quan trọng khác nhau
- ✅ Cần dynamic priority theo từng transaction
- ✅ Mixed-criticality system
- ✅ Software cần control priority runtime
- ✅ Video/audio streaming cùng với best-effort traffic

---

## Ví dụ cấu hình trong `dual_riscv_axi_system`

### 1. Cấu hình Round-Robin (default - hiện tại):
```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE("ROUND_ROBIN")
) u_rr_xbar (
    .M0_AWQOS(4'b0000),  // Not used in RR mode
    .M1_AWQOS(4'b0000),  // Not used in RR mode
    // ...
);
```

### 2. Thay đổi sang Fixed Priority (SERV0 > SERV1):
```verilog
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE("FIXED")  // ← Chỉ cần thay đổi dòng này
) u_rr_xbar (
    .M0_AWQOS(4'b0000),  // Not used in FIXED mode
    .M1_AWQOS(4'b0000),  // Not used in FIXED mode
    // ...
);
```

### 3. Thay đổi sang QoS-based:
```verilog
// Ví dụ: SERV0 là real-time core (QoS=10), SERV1 là best-effort (QoS=2)
axi_rr_interconnect_2x4 #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .ARBITRATION_MODE("QOS")  // ← Enable QoS mode
) u_rr_xbar (
    .M0_AWQOS(4'd10),  // ← SERV0 higher priority
    .M0_ARQOS(4'd10),
    .M1_AWQOS(4'd2),   // ← SERV1 lower priority
    .M1_ARQOS(4'd2),
    // ...
);
```

**Lưu ý:** Để QoS mode hoạt động động (runtime changeable), bạn cần:
1. Thêm QoS registers trong master interface
2. Software config QoS value cho mỗi transaction
3. Connect QoS signals từ masters đến interconnect

---

## Test và Verification

Các testbench trong `tb/interconnect_tb/SystemVerilog_tb/arbitration/` đã hỗ trợ test cả 3 modes:

1. **`Write_Arbiter_tb.sv`** - Test Fixed Priority
2. **`Write_Arbiter_RR_tb.sv`** - Test Round-Robin
3. **`Qos_Arbiter_tb.sv`** - Test QoS-based

Để test với mode khác nhau trong full interconnect:
```bash
# Compile và run với parameter override
vsim -c -do "
    vlog +define+ARBITRATION_MODE=\"FIXED\" ...
    vsim -g ARBITRATION_MODE=FIXED top_tb
    run -all
"
```

---

## Performance Metrics (Example)

Giả sử 2 masters đều request liên tục:

| Mode | M0 granted | M1 granted | M0 avg latency | M1 avg latency |
|------|-----------|-----------|----------------|----------------|
| **FIXED** | 100% | 0% (starved) | 1 cycle | ∞ |
| **ROUND_ROBIN** | 50% | 50% | 2 cycles | 2 cycles |
| **QOS** (M0=10, M1=2) | ~83% | ~17% | 1.2 cycles | 6 cycles |

---

## Tài liệu tham khảo

- **AMBA AXI4 Specification** - ARM IHI 0022E
- **AXI QoS Signaling** - Section A4.7
- **Arbitration Schemes** - Computer Architecture textbooks

---

**Author:** AXI Interconnect Project  
**Last Updated:** 2025-01-02  
**Version:** 1.0

