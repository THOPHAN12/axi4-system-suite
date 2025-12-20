# Tài Liệu Tóm Tắt Vấn Đề và Giải Pháp

## 1. Tổng quan

### 1.1 Mô tả hệ thống

Hệ thống dual RISC-V với AXI Interconnect bao gồm:

- **2 RISC-V Cores (SERV)**: Core 0 (M0) và Core 1 (M1)
- **AXI Interconnect**: Kết nối 2 masters (cores) với 4 slaves:
  - **Slave 0 (M00)**: RAM (0x00000000 - 0x1FFFFFFF)
  - **Slave 1 (M01)**: GPIO (0x40000000 - 0x5FFFFFFF)
  - **Slave 2 (M02)**: UART (0x80000000 - 0xBFFFFFFF)
  - **Slave 3 (M03)**: SPI (0xC0000000 - 0xFFFFFFFF)
- **Wishbone to AXI Bridge**: Chuyển đổi protocol từ Wishbone (SERV cores) sang AXI4
- **Round-Robin Arbitration**: Phân phối công bằng requests giữa M0 và M1

### 1.2 Mục tiêu test

- Mỗi core thực thi instructions và có **5 unique addresses** (PC increment đúng)
- Cores không bị stuck (PC thay đổi đúng cách)
- Arbitration công bằng giữa M0 và M1
- Data routing đúng: mỗi master nhận đúng data từ slave tương ứng

---

## 2. Vấn đề hiện tại

### 2.1 Core Stuck (0 Unique Addresses)

#### Triệu chứng

| Metric | M0 | M1 |
|--------|----|----|
| Unique addresses | 0 | 0 |
| Total fetches | 11 | 5 |
| PC changes | 4 | 4 |
| Last fetch address | 0x04014004 | 0x00a02300 |

**Phân tích**:
- Cores fetch instructions nhưng không có unique addresses → PC không increment đúng
- PC changes = 4 cho cả 2 cores (quá ít, nên có nhiều hơn)
- Last fetch addresses có vẻ không đúng (0x04014004, 0x00a02300 thay vì 0x00000000, 0x00000100)

#### Nguyên nhân có thể

1. **Data routing sai**: Cores nhận sai instruction data từ RAM
   - Instruction data không đúng → PC không increment đúng
   - Data từ slave khác được route đến master sai

2. **Address latching không đúng**: Address không được latch đúng khi handshake xảy ra
   - Address mismatch giữa request và response

3. **Instruction data không đúng**: Data từ RAM không đúng hoặc bị corrupt
   - PC corruption do nhận sai instruction

### 2.2 Arbitration Không Công Bằng

#### Triệu chứng

| Metric | Giá trị |
|--------|---------|
| Conflicts | 6 |
| M0 wins | 6 (100%) |
| M1 wins | 0 (0%) |
| M0 requests | 11 |
| M1 requests | 5 |

**Phân tích**:
- M0 luôn thắng trong mọi conflict → arbitration không công bằng
- M0 có nhiều requests hơn M1 (11 vs 5) → có thể do M0 được ưu tiên

#### Nguyên nhân có thể

1. **Round-robin arbitration không hoạt động đúng**:
   - `rr_priority` trong `read_arbiter.v` không toggle đúng
   - Priority không thay đổi sau mỗi transaction

2. **Controller.v không sử dụng AR_Selected_Slave đúng cách**:
   - Controller có logic arbitration riêng (`ar_priority`) không đồng bộ với `Read_Arbiter`
   - Hai arbitration logics conflict với nhau

3. **Priority toggle logic sai**:
   - Priority chỉ toggle khi cả 2 masters active, không toggle khi chỉ 1 master request

### 2.3 RREADY Count Cao

#### Triệu chứng

| Metric | M0 | M1 |
|--------|----|----|
| R valid | 10 | 5 |
| R ready | 15 | 17 |
| Difference | +5 | +12 |

**Phân tích**:
- RREADY count cao hơn RVALID → RREADY được assert khi không cần thiết
- Có thể dẫn đến false handshakes hoặc data routing sai

#### Nguyên nhân có thể

1. **RREADY được assert khi không cần thiết**:
   - Logic routing RREADY không đúng
   - RREADY không được gate với state của master

2. **Logic routing RREADY không đúng**:
   - RREADY từ master được route đến slave ngay cả khi master không active
   - Không kiểm tra state của master trước khi route RREADY

---

## 3. Các sửa đổi quan trọng đã thực hiện

### 3.1 Sửa ARREADY Routing

**File**: [`src/axi_interconnect/Verilog/rtl/channel_controllers/read/AR_Channel_Controller_Top.v`](src/axi_interconnect/Verilog/rtl/channel_controllers/read/AR_Channel_Controller_Top.v)

**Vấn đề**: RAM luôn assert `arready`, và `AR_Channel_Controller_Top` không gate `arready` đúng cách, dẫn đến M0 AR ready count quá cao (20193).

**Thay đổi**: Gate `S00_AXI_arready` và `S01_AXI_arready` với `arvalid` để chỉ assert khi master thực sự request:

```354:356:src/axi_interconnect/Verilog/rtl/channel_controllers/read/AR_Channel_Controller_Top.v
    // Gate ARREADY with ARVALID - only assert when master is requesting
    assign S00_AXI_arready = S00_AXI_arready_temp && S00_AXI_arvalid;
    assign S01_AXI_arready = S01_AXI_arready_temp && S01_AXI_arvalid;
```

**Kết quả**: Giảm M0 AR ready từ **20193 xuống 14** ✅

### 3.2 Sửa Testbench AR Valid Counting

**File**: [`verification/testbenches/system_tb/dual_riscv_system_tb.v`](verification/testbenches/system_tb/dual_riscv_system_tb.v)

**Vấn đề**: Testbench đếm `arvalid` mỗi cycle thay vì rising edge, dẫn đến count quá cao (M1=20114).

**Thay đổi**: Count rising edges của `arvalid`:

```verilog
// Before: Count every cycle
if (dut.serv0_axi_arvalid) begin
    m0_arvalid_count = m0_arvalid_count + 1;
end

// After: Count rising edges
if (dut.serv0_axi_arvalid && !m0_prev_arvalid) begin
    m0_arvalid_count = m0_arvalid_count + 1;
end
```

**Kết quả**: Giảm M1 AR valid từ **20114 xuống 6** ✅

### 3.3 Thay đổi Arbitration từ QoS sang Round-Robin

**File**: [`src/axi_interconnect/Verilog/rtl/arbitration/algorithms/read_arbiter.v`](src/axi_interconnect/Verilog/rtl/arbitration/algorithms/read_arbiter.v)

**Vấn đề**: Arbitration ban đầu dựa trên QoS, không công bằng.

**Thay đổi**: Implement round-robin arbitration với `rr_priority`:

```67:81:src/axi_interconnect/Verilog/rtl/arbitration/algorithms/read_arbiter.v
    always @(*) begin
        if (S00_AXI_arvalid && S01_AXI_arvalid) begin
            // Both masters requesting - use round-robin
            Master = rr_priority;  // Select based on round-robin priority
        end else if (S00_AXI_arvalid) begin
            // Only Master 0 requesting
            Master = 1'b0;
        end else if (S01_AXI_arvalid) begin
            // Only Master 1 requesting
            Master = 1'b1;
        end else begin
            // No requests - default to M0
            Master = 1'b0;
        end
    end
```

**Kết quả**: Có logic round-robin nhưng chưa hoạt động đúng (M0 vẫn wins 100%) ⚠️

### 3.4 Sửa Address Latching

**File**: [`src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v`](src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v)

**Vấn đề**: Address được latch khi `S0_ARREADY` assert, nhưng cả 2 masters có thể latch cùng lúc.

**Thay đổi**: Sử dụng `M0_ARREADY`/`M1_ARREADY` (từ `AR_Channel_Controller_Top`) thay vì `S0_ARREADY`:

```157:159:src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v
        if (M0_ARVALID && M0_ARREADY) begin
            // M0 was selected by arbiter - latch address based on which slave it's reading from
            if (M0_ADDR >= slave0_addr1 && M0_ADDR <= slave0_addr2) begin
```

**Mục đích**: Chỉ latch address khi master được chọn bởi arbiter ✅

### 3.5 Sửa Data Routing Logic

**File**: [`src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v`](src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v)

**Vấn đề**: Data routing không đúng khi cả 2 masters đọc từ cùng 1 slave.

**Thay đổi**: 
1. Sử dụng `en_S0_wire[0]` để xác định master nào nhận data
2. Kiểm tra `rready` để đảm bảo master đang active
3. Gate `rdata` với `m0_should_get_rvalid`/`m1_should_get_rvalid`:

```933:948:src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v
// For Slave0: Route rvalid/rdata based on which master is selected by en_S0_wire[0]
// CRITICAL FIX: Use en_S0_wire[0] to determine which master should receive data
// en_S0_wire[0] = 0 means M0 is selected (en_S0 = en_S0_M0 = 2'b00)
// en_S0_wire[0] = 1 means M1 is selected (en_S0 = en_S0_M1 = 2'b01)
// This is controlled by round-robin arbitration in Controller.v
// Additionally, only route rvalid when the selected master's rready is actually asserted
// This ensures data is only routed when the master is actively ready to receive it
wire m0_in_slave0_state = (M0_state_wire == 3'b001);  // M0 is reading from Slave0
wire m1_in_slave0_state = (M1_state_wire == 3'b001);  // M1 is reading from Slave0
// M0 should get data from Slave0 if: M0 is in Slave0 state AND M0 is selected (en_S0_wire[0] == 0) AND M0 has rready AND slave is responding
wire m0_should_get_data_slave0 = m0_in_slave0_state && (en_S0_wire[0] == 1'b0) && (RREADY_S0_wire == 1'b1);
// M1 should get data from Slave0 if: M1 is in Slave0 state AND M1 is selected (en_S0_wire[0] == 1) AND M1 has rready AND slave is responding
wire m1_should_get_data_slave0 = m1_in_slave0_state && (en_S0_wire[0] == 1'b1) && (RREADY_S0_wire_2 == 1'b1);
// Only assert rvalid when slave is actually responding
wire m0_should_get_rvalid_slave0 = m0_should_get_data_slave0 && (M00_AXI_rvalid == 1'b1);
wire m1_should_get_rvalid_slave0 = m1_should_get_data_slave0 && (M00_AXI_rvalid == 1'b1);
```

**Mục đích**: Đảm bảo data được route đúng master ⚠️ (vẫn đang điều tra)

### 3.6 Sửa Controller để sử dụng AR_Selected_Slave

**File**: [`src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v`](src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v)

**Vấn đề**: Controller có logic arbitration riêng (`ar_priority`) không đồng bộ với `Read_Arbiter`.

**Thay đổi**: Thêm input `AR_Selected_Master` và sử dụng thay vì `ar_priority`:

```37:43:src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v
    input wire AR_Selected_Master,  // Selected master from AR_Channel_Controller_Top (0=M0, 1=M1)
    
    //two ready signals from masters on read address channel (from AR_Channel_Controller):
    // CRITICAL: These indicate which master was actually selected by the arbiter
    // Only the selected master will have its ARREADY = 1
    input wire M0_ARREADY,  // M0's ARREADY from AR_Channel_Controller
    input wire M1_ARREADY,  // M1's ARREADY from AR_Channel_Controller
```

**Mục đích**: Đồng bộ arbitration giữa address channel và data channel ✅

### 3.7 Sửa Data Transfer Detection

**File**: [`src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v`](src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v)

**Vấn đề**: `en_S0_priority` toggle không đúng, dẫn đến arbitration không công bằng.

**Thay đổi**: Chỉ toggle `en_S0_priority` khi master được chọn thực sự nhận data:

```649:663:src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v
wire m0_data_transfer_slave0 = (curr_state_slave == 3'b001) && (M0_RREADY && S0_RVALID) && m0_selected_slave0;
wire m0_data_transfer_slave1 = (curr_state_slave == 3'b010) && (M0_RREADY && S1_RVALID) && m0_selected_slave1;
wire m0_data_transfer_slave2 = (curr_state_slave == 3'b011) && (M0_RREADY && S2_RVALID) && m0_selected_slave2;
wire m0_data_transfer_slave3 = (curr_state_slave == 3'b100) && (M0_RREADY && S3_RVALID) && m0_selected_slave3;
wire m0_data_transfer = m0_data_transfer_slave0 || m0_data_transfer_slave1 || m0_data_transfer_slave2 || m0_data_transfer_slave3;

wire m1_selected_slave0 = both_active_slave0 ? (en_S0_priority == 1'b1) : (curr_state_slave2 == 3'b001);
wire m1_selected_slave1 = both_active_slave1 ? (en_S0_priority == 1'b1) : (curr_state_slave2 == 3'b010);
wire m1_selected_slave2 = both_active_slave2 ? (en_S0_priority == 1'b1) : (curr_state_slave2 == 3'b011);
wire m1_selected_slave3 = both_active_slave3 ? (en_S0_priority == 1'b1) : (curr_state_slave2 == 3'b100);
wire m1_data_transfer_slave0 = (curr_state_slave2 == 3'b001) && (M1_RREADY && S0_RVALID) && m1_selected_slave0;
wire m1_data_transfer_slave1 = (curr_state_slave2 == 3'b010) && (M1_RREADY && S1_RVALID) && m1_selected_slave1;
wire m1_data_transfer_slave2 = (curr_state_slave2 == 3'b011) && (M1_RREADY && S2_RVALID) && m1_selected_slave2;
wire m1_data_transfer_slave3 = (curr_state_slave2 == 3'b100) && (M1_RREADY && S3_RVALID) && m1_selected_slave3;
wire m1_data_transfer = m1_data_transfer_slave0 || m1_data_transfer_slave1 || m1_data_transfer_slave2 || m1_data_transfer_slave3;
```

**Mục đích**: Đảm bảo round-robin priority toggle đúng ⚠️ (vẫn đang điều tra)

---

## 4. Giải pháp đề xuất

### 4.1 Kiểm tra và sửa Data Routing

**Vấn đề**: Cores nhận sai instruction data, dẫn đến PC không increment đúng.

**Giải pháp**:

1. **Thêm debug output tạm thời** để log data routing decisions:
   - Log `en_S0_wire[0]`, `M0_state_wire`, `M1_state_wire` khi data routing xảy ra
   - Log `m0_should_get_data_slaveX`, `m1_should_get_data_slaveX` để verify logic
   - Log `S00_AXI_rdata`, `S01_AXI_rdata` và `M00_AXI_rdata` để verify data routing

2. **Kiểm tra waveform** để xác định:
   - Data có được route đúng master không?
   - Timing có đúng không (data xuất hiện đúng lúc)?
   - Có race condition giữa state update và data routing không?

3. **Verify `en_S0_wire[0]` có toggle đúng**:
   - Khi cả 2 masters active, `en_S0_wire[0]` phải toggle sau mỗi data transfer
   - Kiểm tra `en_S0_priority` trong `Controller.v` có toggle đúng không

4. **Kiểm tra timing**:
   - Có race condition giữa state update và data routing không?
   - `en_S0_wire[0]` có update đúng lúc không?

### 4.2 Sửa Arbitration Fairness

**Vấn đề**: M0 wins 100% conflicts, arbitration không công bằng.

**Giải pháp**:

1. **Verify `rr_priority` trong `read_arbiter.v` có toggle đúng không**:
   - Kiểm tra logic toggle `rr_priority` (lines 124-133)
   - Đảm bảo priority toggle sau mỗi grant, ngay cả khi chỉ 1 master request

2. **Kiểm tra `Channel_Granted` và `Token` signals**:
   - `Channel_Granted` có assert đúng không?
   - `Token` có block new requests đúng không?

3. **Đảm bảo `AR_Selected_Slave` được sử dụng đúng trong `Controller.v`**:
   - `Controller.v` có sử dụng `M0_ARREADY`/`M1_ARREADY` đúng không?
   - Address latching có dựa trên `M0_ARREADY`/`M1_ARREADY` không?

4. **Sửa logic toggle `rr_priority`**:
   - Toggle priority ngay cả khi chỉ 1 master request (để đảm bảo fair khi cả 2 request lại)
   - Xem code hiện tại (lines 124-133) có toggle đúng không

### 4.3 Sửa RREADY Routing

**Vấn đề**: RREADY count cao hơn RVALID, RREADY được assert khi không cần thiết.

**Giải pháp**:

1. **Kiểm tra logic routing RREADY trong `AXI_Interconnect_Full.v`**:
   - RREADY từ master có được route đến slave đúng không?
   - Có gate RREADY với state của master không?

2. **Đảm bảo RREADY chỉ được assert khi master thực sự cần data**:
   - Master phải ở state active (reading from slave)
   - Master phải có `rready` signal assert

3. **Gate RREADY với state của master**:
   - Chỉ route RREADY khi master ở state tương ứng (e.g., `M0_state_wire == 3'b001` cho Slave0)
   - Kiểm tra logic hiện tại có gate đúng không

### 4.4 Kiểm tra Address Latching

**Vấn đề**: Cores có thể nhận data từ sai address.

**Giải pháp**:

1. **Verify `M0_addr_latched` và `M1_addr_latched` có đúng không**:
   - Address có được latch đúng khi handshake xảy ra không?
   - Address có match với request không?

2. **Kiểm tra address matching giữa request và response**:
   - Address trong request có match với address trong response không?
   - Có address mismatch dẫn đến data routing sai không?

3. **Đảm bảo address được latch đúng khi handshake xảy ra**:
   - Address chỉ được latch khi `M0_ARVALID && M0_ARREADY` (hoặc `M1_ARVALID && M1_ARREADY`)
   - Kiểm tra logic hiện tại (lines 157-173) có đúng không

### 4.5 Debug và Verification

**Giải pháp**:

1. **Thêm debug output tạm thời** trong các module quan trọng:
   - `AXI_Interconnect_Full.v`: Log data routing decisions
   - `Controller.v`: Log state transitions và arbitration decisions
   - `read_arbiter.v`: Log priority toggles và master selection

2. **Sử dụng waveform để trace data flow**:
   - Trace từ master request → slave response → master receive
   - Verify timing và data correctness

3. **Tạo test case đơn giản hơn** để isolate vấn đề:
   - Test với chỉ 1 master trước
   - Test với 2 masters nhưng không conflict (đọc từ slaves khác nhau)
   - Test với 2 masters conflict (đọc từ cùng 1 slave)

4. **Kiểm tra từng component riêng biệt** trước khi test toàn bộ system:
   - Test `Read_Arbiter` riêng
   - Test `Controller` riêng
   - Test data routing riêng

---

## 5. Các file quan trọng cần kiểm tra

| File | Mô tả | Vấn đề chính |
|------|-------|--------------|
| [`src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v`](src/axi_interconnect/Verilog/rtl/core/AXI_Interconnect_Full.v) | Data routing logic | Data routing sai khi cả 2 masters đọc từ cùng 1 slave |
| [`src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v`](src/axi_interconnect/Verilog/rtl/channel_controllers/read/Controller.v) | State machine và arbitration | Arbitration không công bằng, state transitions không đúng |
| [`src/axi_interconnect/Verilog/rtl/arbitration/algorithms/read_arbiter.v`](src/axi_interconnect/Verilog/rtl/arbitration/algorithms/read_arbiter.v) | Address channel arbitration | Round-robin priority không toggle đúng |
| [`src/axi_interconnect/Verilog/rtl/channel_controllers/read/AR_Channel_Controller_Top.v`](src/axi_interconnect/Verilog/rtl/channel_controllers/read/AR_Channel_Controller_Top.v) | ARREADY routing | ✅ Đã fix: Gate ARREADY với ARVALID |
| [`verification/testbenches/system_tb/dual_riscv_system_tb.v`](verification/testbenches/system_tb/dual_riscv_system_tb.v) | Testbench monitoring | ✅ Đã fix: Count AR valid rising edges |

---

## 6. Kế hoạch thực hiện tiếp theo

### Bước 1: Thêm debug output tạm thời
- Thêm `$display` statements trong `AXI_Interconnect_Full.v` để log data routing decisions
- Thêm `$display` statements trong `Controller.v` để log state transitions và arbitration
- Thêm `$display` statements trong `read_arbiter.v` để log priority toggles

### Bước 2: Kiểm tra waveform
- Mở waveform và trace data flow từ master request → slave response → master receive
- Verify timing và data correctness
- Xác định vấn đề chính xác (data routing, arbitration, hoặc address latching)

### Bước 3: Sửa từng vấn đề một cách có hệ thống
- **Ưu tiên 1**: Sửa data routing (vì đây là nguyên nhân chính khiến cores stuck)
- **Ưu tiên 2**: Sửa arbitration fairness
- **Ưu tiên 3**: Sửa RREADY routing

### Bước 4: Test lại sau mỗi sửa đổi
- Chạy simulation sau mỗi sửa đổi
- Verify metrics: unique addresses, PC changes, arbitration fairness
- So sánh với kết quả trước đó

### Bước 5: Loại bỏ debug output sau khi fix xong
- Comment out hoặc xóa các `$display` statements
- Giữ lại comments giải thích logic quan trọng

---

## 7. Tóm tắt trạng thái

| Vấn đề | Trạng thái | Ghi chú |
|--------|-----------|---------|
| ARREADY routing | ✅ Fixed | Giảm từ 20193 xuống 14 |
| Testbench AR valid counting | ✅ Fixed | Giảm từ 20114 xuống 6 |
| Core stuck (0 unique addresses) | ⚠️ Investigating | Nguyên nhân chính: data routing sai |
| Arbitration fairness | ⚠️ Investigating | M0 wins 100%, cần sửa round-robin |
| RREADY routing | ⚠️ Investigating | RREADY count cao hơn RVALID |
| Address latching | ✅ Fixed | Sử dụng M0_ARREADY/M1_ARREADY |
| Data routing logic | ⚠️ Investigating | Đã sửa nhưng vẫn có vấn đề |

---

## 8. Kết luận

Hệ thống đã được cải thiện đáng kể với các fix cho ARREADY routing và testbench counting. Tuy nhiên, vẫn còn các vấn đề quan trọng cần giải quyết:

1. **Core stuck**: Cores không có unique addresses, PC không increment đúng → **Nguyên nhân chính: data routing sai**
2. **Arbitration không công bằng**: M0 wins 100% conflicts → **Cần sửa round-robin logic**
3. **RREADY routing**: RREADY count cao hơn RVALID → **Cần gate RREADY với state**

Các bước tiếp theo:
- Thêm debug output để xác định vấn đề chính xác
- Sửa data routing trước (ưu tiên cao nhất)
- Sau đó sửa arbitration và RREADY routing
- Test lại và verify metrics




