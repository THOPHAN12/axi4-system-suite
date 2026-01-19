# Tài Liệu Giải Thuật (Algorithms Documentation)

## 1. Tổng Quan

Tài liệu này mô tả chi tiết các thuật toán được triển khai trong AXI4 System Suite, 
bao gồm arbitration algorithms, channel controllers, address decoding, và handshake protocols.

## 2. Arbitration Algorithms

### 2.1. Fixed Priority Arbiter

**File**: `SystemVerilog/axi_interconnect/arbitration/algorithms/arbiter_fixed_priority.sv`

**Mục đích**: Cung cấp arbitration với priority cố định

**Thuật toán**:
1. Master 0 luôn có priority cao hơn Master 1
2. Nếu Master 0 request → Grant Master 0
3. Nếu chỉ Master 1 request → Grant Master 1
4. Nếu cả hai request → Grant Master 0

**Độ phức tạp**: O(1)

**Use Case**: 
- Khi Master 0 cần guaranteed bandwidth
- Real-time applications với priority requirements

**Ưu điểm**:
- Đơn giản, dễ implement
- Predictable behavior
- Low latency cho high-priority master

**Nhược điểm**:
- Có thể gây starvation cho Master 1
- Không fair

**Code Example**:
```systemverilog
always_comb begin
    if (M0_AWVALID) begin
        Selected_Master = 2'b00;  // Master 0
    end else if (M1_AWVALID) begin
        Selected_Master = 2'b01;  // Master 1
    end else begin
        Selected_Master = 2'b00;  // Default
    end
end
```

### 2.2. Round-Robin Arbiter

**File**: `SystemVerilog/axi_interconnect/arbitration/algorithms/arbiter_round_robin.sv`

**Mục đích**: Cung cấp fair arbitration giữa các masters

**Thuật toán**:
1. Track last served master (0 hoặc 1)
2. Nếu chỉ một master request → Grant ngay
3. Nếu cả hai request:
   - Nếu last served = 0 → Grant Master 1
   - Nếu last served = 1 → Grant Master 0
4. Update last served sau mỗi grant

**Độ phức tạp**: O(1)

**Use Case**:
- Fair bandwidth distribution
- Equal-priority masters
- Prevent starvation

**Ưu điểm**:
- Fair access cho tất cả masters
- No starvation
- Predictable rotation

**Nhược điểm**:
- Có thể không optimal cho priority-based applications
- Slightly more complex than fixed priority

**State Machine**:
```
State: last_served (0 or 1)
Transition:
  - Both request → Grant opposite of last_served
  - Only M0 request → Grant M0, update last_served = 0
  - Only M1 request → Grant M1, update last_served = 1
```

**Code Example**:
```systemverilog
always_ff @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        last_served <= 1'b0;
    end else if (Channel_Granted) begin
        last_served <= Selected_Master[0];  // Update last served
    end
end

always_comb begin
    if (M0_AWVALID && M1_AWVALID) begin
        // Both request: round-robin
        Selected_Master = {1'b0, ~last_served};
    end else if (M0_AWVALID) begin
        Selected_Master = 2'b00;  // Only M0
    end else if (M1_AWVALID) begin
        Selected_Master = 2'b01;  // Only M1
    end else begin
        Selected_Master = 2'b00;  // Default
    end
end
```

### 2.3. QoS-Based Arbiter

**File**: `SystemVerilog/axi_interconnect/arbitration/algorithms/arbiter_qos_based.sv`

**Mục đích**: Arbitration dựa trên Quality of Service

**Thuật toán**:
1. Mỗi master có QoS value (0-3, cao hơn = priority cao hơn)
2. So sánh QoS values của các masters đang request
3. Grant master có QoS cao nhất
4. Nếu QoS bằng nhau → Fallback to round-robin

**Độ phức tạp**: O(1)

**Use Case**:
- Quality of Service requirements
- Different priority levels
- Dynamic priority adjustment

**Ưu điểm**:
- Flexible priority system
- Support QoS requirements
- Can combine với round-robin

**Nhược điểm**:
- Cần QoS signals từ masters
- More complex implementation

**Code Example**:
```systemverilog
always_comb begin
    if (M0_AWVALID && M1_AWVALID) begin
        if (M0_AWQOS > M1_AWQOS) begin
            Selected_Master = 2'b00;  // M0 has higher QoS
        end else if (M1_AWQOS > M0_AWQOS) begin
            Selected_Master = 2'b01;  // M1 has higher QoS
        end else begin
            // Equal QoS: round-robin
            Selected_Master = {1'b0, ~last_served};
        end
    end else if (M0_AWVALID) begin
        Selected_Master = 2'b00;
    end else if (M1_AWVALID) begin
        Selected_Master = 2'b01;
    end else begin
        Selected_Master = 2'b00;
    end
end
```

## 3. Channel Controllers

### 3.1. AW Channel Controller

**File**: `SystemVerilog/axi_interconnect/channel_controllers/write/AW_Channel_Controller_Top.sv`

**Chức năng**: Điều khiển Write Address Channel

**Thuật toán**:
1. **Arbitration**:
   - Nhận requests từ Master 0 và Master 1
   - Chạy arbitration algorithm (Fixed/Round-Robin/QoS)
   - Grant master được chọn

2. **Address Decoding**:
   - Nhận AWADDR từ master được grant
   - Decode address để xác định slave đích
   - Generate slave select signals

3. **Handshake Control**:
   - Assert AWREADY khi sẵn sàng
   - Wait for AWVALID từ master
   - Complete handshake

4. **Routing**:
   - Route AWADDR, AWLEN, AWSIZE, AWBURST đến slave đích
   - Route AWVALID đến slave
   - Route AWREADY về master

**State Machine**:
```
IDLE → Wait for request
REQUEST → Arbitration
GRANT → Address decode
ROUTE → Handshake
COMPLETE → Return to IDLE
```

### 3.2. WD Channel Controller

**File**: `SystemVerilog/axi_interconnect/channel_controllers/write/WD_Channel_Controller_Top.sv`

**Chức năng**: Điều khiển Write Data Channel

**Thuật toán**:
1. **Synchronization**:
   - Wait for AW channel grant
   - Track which master và slave đang active

2. **Data Routing**:
   - Demultiplexer 1→4: Route WDATA đến đúng slave
   - Route WSTRB, WLAST đến slave
   - Route WVALID đến slave

3. **Handshake Control**:
   - Assert WREADY khi slave sẵn sàng
   - Wait for WVALID từ master
   - Track WLAST để biết end of burst

4. **Burst Handling**:
   - Count beats trong burst
   - Assert WLAST cho beat cuối cùng

**Burst Counter**:
```systemverilog
always_ff @(posedge ACLK) begin
    if (WVALID && WREADY) begin
        if (WLAST) begin
            beat_count <= 0;
        end else begin
            beat_count <= beat_count + 1;
        end
    end
end
```

### 3.3. BR Channel Controller

**File**: `SystemVerilog/axi_interconnect/channel_controllers/write/BR_Channel_Controller_Top.sv`

**Chức năng**: Điều khiển Write Response Channel

**Thuật toán**:
1. **Response Collection**:
   - Nhận BVALID từ 4 slaves
   - Store BRESP, BID từ mỗi slave

2. **Response Arbitration**:
   - Arbitrate giữa các slaves có response pending
   - Select slave có response sẵn sàng

3. **Response Routing**:
   - Multiplexer 4→1: Route BRESP về đúng master
   - Route BID về master (matching với AWID)
   - Route BVALID về master

4. **ID Matching**:
   - Match BID với AWID để route về đúng master
   - Ensure response ordering

**ID Matching Logic**:
```systemverilog
always_comb begin
    if (S0_BVALID && S0_BID == stored_AWID) begin
        M_BRESP = S0_BRESP;
        M_BVALID = 1'b1;
    end else if (S1_BVALID && S1_BID == stored_AWID) begin
        M_BRESP = S1_BRESP;
        M_BVALID = 1'b1;
    end
    // ... similar for S2, S3
end
```

### 3.4. AR Channel Controller

**File**: `SystemVerilog/axi_interconnect/channel_controllers/read/AR_Channel_Controller_Top.sv`

**Chức năng**: Điều khiển Read Address Channel

**Thuật toán**:
1. **Arbitration**: Tương tự AW channel
2. **Address Decoding**: Tương tự AW channel
3. **Handshake Control**: Tương tự AW channel
4. **Routing**: Route ARADDR, ARLEN, ARSIZE, ARBURST đến slave

### 3.5. Read Data Channel (Mux 4→1)

**Chức năng**: Route read data từ slave về master

**Thuật toán**:
1. **Data Collection**:
   - Nhận RVALID từ 4 slaves
   - Store RDATA, RRESP, RLAST, RID từ mỗi slave

2. **Data Routing**:
   - Multiplexer 4→1: Route RDATA về master
   - Route RRESP, RLAST về master
   - Route RID về master (matching với ARID)

3. **ID Matching**:
   - Match RID với ARID để route về đúng master
   - Ensure response ordering

## 4. Address Decoding

### 4.1. Write Address Decoder

**File**: `SystemVerilog/axi_interconnect/decoders/Write_Addr_Channel_Dec.sv`

**Thuật toán**:
1. Extract address từ AWADDR
2. Compare với base addresses của slaves
3. Generate slave select signals

**Address Range Check**:
```systemverilog
always_comb begin
    // S0: 0x0000_0000 - 0x3FFF_FFFF
    S0_SEL = (AWADDR >= 32'h0000_0000) && (AWADDR < 32'h4000_0000);
    
    // S1: 0x4000_0000 - 0x7FFF_FFFF
    S1_SEL = (AWADDR >= 32'h4000_0000) && (AWADDR < 32'h8000_0000);
    
    // S2: 0x8000_0000 - 0xBFFF_FFFF
    S2_SEL = (AWADDR >= 32'h8000_0000) && (AWADDR < 32'hC000_0000);
    
    // S3: 0xC000_0000 - 0xFFFF_FFFF
    S3_SEL = (AWADDR >= 32'hC000_0000) && (AWADDR <= 32'hFFFF_FFFF);
end
```

### 4.2. Read Address Decoder

**File**: `SystemVerilog/axi_interconnect/decoders/Read_Addr_Channel_Dec.sv`

**Thuật toán**: Tương tự Write Address Decoder, nhưng cho ARADDR

## 5. Handshake Protocols

### 5.1. AXI Handshake Rules

**Valid-Ready Handshake**:
1. Source asserts VALID khi data/address sẵn sàng
2. Destination asserts READY khi sẵn sàng nhận
3. Transfer occurs khi cả VALID và READY đều HIGH
4. VALID không được deassert cho đến khi transfer complete

**Implementation**:
```systemverilog
// Source side
always_ff @(posedge ACLK) begin
    if (!ARESETN) begin
        VALID <= 1'b0;
    end else if (condition) begin
        VALID <= 1'b1;
    end else if (VALID && READY) begin
        VALID <= 1'b0;  // Transfer complete
    end
end

// Destination side
always_comb begin
    READY = (state == READY_STATE) && (no_backpressure);
end
```

### 5.2. Handshake Checker

**File**: `SystemVerilog/axi_interconnect/handshake/AW_HandShake_Checker.sv`

**Chức năng**: Kiểm tra handshake protocol compliance

**Checks**:
1. VALID không được deassert trước khi READY asserted
2. READY có thể deassert bất cứ lúc nào
3. Transfer occurs khi cả hai HIGH

## 6. Performance Analysis

### 6.1. Latency Analysis

**Write Transaction**:
- AW channel: 1-2 cycles (arbitration + routing)
- W channel: 1 cycle per beat
- B channel: 1-2 cycles (response routing)
- **Total**: 3-5 cycles (single beat) + (N-1) cycles (burst)

**Read Transaction**:
- AR channel: 1-2 cycles (arbitration + routing)
- R channel: 1 cycle per beat (slave dependent)
- **Total**: 2-4 cycles (single beat) + (N-1) cycles (burst)

### 6.2. Throughput Analysis

**Maximum Throughput**:
- Write: 32 bits/cycle (1 beat per cycle)
- Read: 32 bits/cycle (1 beat per cycle)
- **Bandwidth**: 32 bits × Clock Frequency

**Arbitration Overhead**:
- Fixed Priority: 0 cycles (combinational)
- Round-Robin: 0 cycles (combinational, 1 cycle for state update)
- QoS-Based: 0 cycles (combinational)

## 7. References

Xem file `REFERENCES.md` để biết các paper và tài liệu tham khảo cho các thuật toán này.

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Author**: AXI4 System Suite Team

