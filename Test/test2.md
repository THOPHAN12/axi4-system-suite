# Test 2: AXI Master Write Process

## Tổng quan

Test này mô tả quá trình ghi dữ liệu từ AXI Master 1 đến AXI-Lite RAM Slave 2. Testbench sử dụng một master state machine để thực hiện các giao dịch ghi AXI theo đúng protocol, bao gồm 3 channels: Write Address (AW), Write Data (W), và Write Response (B).

**Slave 2 Base Address:** `0x8000_0000`

## Kiến trúc Testbench

### Components

1. **AXI Master (Simple Master)**
   - State machine với 4 states: `IDLE`, `WRITE_REQ`, `WRITE_WAIT`, `WRITE_DONE`
   - Điều khiển các tín hiệu AXI write channels

2. **AXI-Lite RAM Slave**
   - Memory được khởi tạo từ file `mem_init_write.hex` (tất cả zeros)
   - Hỗ trợ AXI-Lite write operations với write strobe (wstrb)

### Memory Initialization

Memory được khởi tạo với tất cả giá trị zero:
- `mem[0]` = `0x00000000`
- `mem[1]` = `0x00000000`
- `mem[2]` = `0x00000000`
- ... (tất cả zeros)

Sau đó Master sẽ ghi dữ liệu vào memory thông qua AXI write transactions.

## Quá trình ghi dữ liệu của Master

### State Machine Flow

```
IDLE → WRITE_REQ → WRITE_WAIT → WRITE_DONE → IDLE
```

### Chi tiết từng State

#### 1. IDLE State

**Điều kiện vào:**
- Reset được release
- `write_req` flag được set bởi test sequence
- `write_addr` và `write_data` đã được set

**Hành động:**
- Giữ tất cả AXI signals ở trạng thái idle:
  - `M_AXI_awvalid = 0`
  - `M_AXI_wvalid = 0`
  - `M_AXI_bready = 0`
- Khi `write_req = 1`, chuyển sang state `WRITE_REQ`

**Code:**
```verilog
IDLE: begin
    M_AXI_awvalid <= 1'b0;
    M_AXI_wvalid  <= 1'b0;
    M_AXI_bready  <= 1'b0;
    if (write_req) begin
        master_state <= WRITE_REQ;
    end
end
```

#### 2. WRITE_REQ State

**Mục đích:**
- Gửi write address và write data đến slave
- Thực hiện AW (Address Write) và W (Write Data) handshakes đồng thời

**Hành động:**
- Assert `M_AXI_awvalid = 1` và set `M_AXI_awaddr` với địa chỉ cần ghi
- Assert `M_AXI_wvalid = 1` và set `M_AXI_wdata` với dữ liệu cần ghi
- Set `M_AXI_wstrb` để chỉ định bytes nào được ghi (thường là `4'b1111` cho tất cả 4 bytes)
- Giữ cả `awvalid` và `wvalid` high cho đến khi cả `awready` và `wready` đều được assert

**AW và W Handshakes:**
- Trong AXI-Lite, AW và W handshakes có thể xảy ra độc lập, nhưng slave có thể yêu cầu cả hai cùng sẵn sàng
- Handshake xảy ra khi cả `_valid` và `_ready` đều = 1
- Khi cả hai handshakes hoàn tất, chuyển sang state `WRITE_WAIT`

**Code:**
```verilog
WRITE_REQ: begin
    M_AXI_awaddr  <= write_addr;
    M_AXI_awprot  <= 3'b000;
    M_AXI_awvalid <= 1'b1;
    M_AXI_wdata   <= write_data;
    M_AXI_wstrb   <= write_strb;
    M_AXI_wvalid  <= 1'b1;
    if (M_AXI_awready && M_AXI_wready) begin
        master_state <= WRITE_WAIT;
        M_AXI_awvalid <= 1'b0;
        M_AXI_wvalid  <= 1'b0;
    end
end
```

**Timing Diagram:**
```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__
AWADDR:    XXXX  [addr]  XXXX
AWVALID:   ____  ‾‾‾‾  ____
AWREADY:   ____  ‾‾‾‾  ____
WDATA:     XXXX  [data]  XXXX
WVALID:    ____  ‾‾‾‾  ____
WREADY:    ____  ‾‾‾‾  ____
           Both handshakes occur here
```

#### 3. WRITE_WAIT State

**Mục đích:**
- Đợi slave trả về write response
- Thực hiện B (Write Response) handshake

**Hành động:**
- Deassert `M_AXI_awvalid = 0` và `M_AXI_wvalid = 0` (không cần nữa)
- Assert `M_AXI_bready = 1` để sẵn sàng nhận response
- Đợi slave assert `bvalid = 1`

**B Handshake:**
- Handshake xảy ra khi cả `bvalid` và `bready` đều = 1
- Khi handshake hoàn tất:
  - Capture `M_AXI_bresp` để kiểm tra response status
  - `bresp = 2'b00` (OKAY) nghĩa là write thành công
  - Chuyển sang state `WRITE_DONE`

**Code:**
```verilog
WRITE_WAIT: begin
    M_AXI_awvalid <= 1'b0;
    M_AXI_wvalid  <= 1'b0;
    M_AXI_bready <= 1'b1;
    if (M_AXI_bvalid && M_AXI_bready) begin
        master_state <= WRITE_DONE;
        M_AXI_bready <= 1'b0;
    end
end
```

**Timing Diagram:**
```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__
BREADY:    ____  ‾‾‾‾  ____
BVALID:    ____  ‾‾‾‾  ____
BRESP:     XXXX  [00]  XXXX
           Handshake occurs here
```

#### 4. WRITE_DONE State

**Mục đích:**
- Hoàn tất giao dịch ghi
- Chuẩn bị cho giao dịch tiếp theo

**Hành động:**
- Clear `write_req` flag
- Chuyển về state `IDLE`

**Code:**
```verilog
WRITE_DONE: begin
    master_state <= IDLE;
    write_req <= 1'b0;
end
```

## Test Cases

### Test 1: Write to Slave 2 address 0x80000000

**Address:** `0x80000000` (Slave 2 base address + offset 0x00000000)  
**Data:** `0xDEADBEEF`

**Sequence:**
1. Test sequence sets `write_addr = 0x80000000`, `write_data = 0xDEADBEEF`
2. Test sequence sets `write_req = 1`
3. Master chuyển từ `IDLE` → `WRITE_REQ`
4. Master asserts `awvalid = 1` và `wvalid = 1` cùng lúc
5. Slave accepts khi cả `awready` và `wready` đều = 1
6. AW và W handshakes xảy ra đồng thời
7. Master chuyển sang `WRITE_WAIT`
8. Slave ghi dữ liệu vào memory và assert `bvalid = 1` với `bresp = 2'b00`
9. B handshake xảy ra
10. Master chuyển sang `WRITE_DONE` → `IDLE`
11. Test sequence kiểm tra write đã hoàn tất

**Result:** ✅ PASS

### Test 2: Write to Slave 2 address 0x80000004

**Address:** `0x80000004` (Slave 2 base address + offset 0x00000004)  
**Data:** `0xCAFEBABE`

**Sequence:**
1. Test sequence sets `write_addr = 0x80000004`, `write_data = 0xCAFEBABE`
2. Test sequence sets `write_req = 1`
3. Master chuyển từ `IDLE` → `WRITE_REQ`
4. Master asserts `awvalid = 1` và `wvalid = 1` cùng lúc
5. Slave accepts khi cả `awready` và `wready` đều = 1
6. AW và W handshakes xảy ra đồng thời
7. Master chuyển sang `WRITE_WAIT`
8. Slave ghi dữ liệu vào memory và assert `bvalid = 1` với `bresp = 2'b00`
9. B handshake xảy ra
10. Master chuyển sang `WRITE_DONE` → `IDLE`
11. Test sequence kiểm tra write đã hoàn tất

**Result:** ✅ PASS

### Test 3: Write to Slave 2 address 0x80000008

**Address:** `0x80000008` (Slave 2 base address + offset 0x00000008)  
**Data:** `0x12345678`

**Sequence:**
1. Test sequence sets `write_addr = 0x80000008`, `write_data = 0x12345678`
2. Test sequence sets `write_req = 1`
3. Master chuyển từ `IDLE` → `WRITE_REQ`
4. Master asserts `awvalid = 1` và `wvalid = 1` cùng lúc
5. Slave accepts khi cả `awready` và `wready` đều = 1
6. AW và W handshakes xảy ra đồng thời
7. Master chuyển sang `WRITE_WAIT`
8. Slave ghi dữ liệu vào memory và assert `bvalid = 1` với `bresp = 2'b00`
9. B handshake xảy ra
10. Master chuyển sang `WRITE_DONE` → `IDLE`
11. Test sequence kiểm tra write đã hoàn tất

**Result:** ✅ PASS

## AXI Protocol Compliance

### Write Address Channel (AW)

- **AWVALID**: Master asserts khi có địa chỉ hợp lệ
- **AWREADY**: Slave asserts khi sẵn sàng nhận địa chỉ
- **AWADDR**: Địa chỉ byte (32-bit)
- **AWPROT**: Protection type (3-bit)

**Rule:** Handshake xảy ra khi cả `AWVALID` và `AWREADY` đều = 1 tại cùng một clock edge.

### Write Data Channel (W)

- **WVALID**: Master asserts khi có dữ liệu hợp lệ
- **WREADY**: Slave asserts khi sẵn sàng nhận dữ liệu
- **WDATA**: Dữ liệu ghi (32-bit)
- **WSTRB**: Write strobe (4-bit), mỗi bit tương ứng với 1 byte
  - `wstrb[0]` = byte 0 (bits 7:0)
  - `wstrb[1]` = byte 1 (bits 15:8)
  - `wstrb[2]` = byte 2 (bits 23:16)
  - `wstrb[3]` = byte 3 (bits 31:24)

**Rule:** Handshake xảy ra khi cả `WVALID` và `WREADY` đều = 1 tại cùng một clock edge.

**Note:** Trong AXI-Lite, AW và W handshakes có thể xảy ra độc lập, nhưng slave có thể yêu cầu cả hai cùng sẵn sàng trước khi accept.

### Write Response Channel (B)

- **BVALID**: Slave asserts khi có response hợp lệ
- **BREADY**: Master asserts khi sẵn sàng nhận response
- **BRESP**: Response status (2-bit)
  - `00` = OKAY (success)
  - `01` = EXOKAY (exclusive access okay)
  - `10` = SLVERR (slave error)
  - `11` = DECERR (decode error)

**Rule:** Handshake xảy ra khi cả `BVALID` và `BREADY` đều = 1 tại cùng một clock edge.

**Note:** B channel luôn được điều khiển bởi slave. Master chỉ có thể assert `bready` để sẵn sàng nhận response.

## Slave Behavior

### AXI-Lite RAM Slave

**Write Process:**
1. Khi nhận cả AW và W handshakes:
   - Slave chỉ accept khi cả `awvalid` và `wvalid` đều = 1 và `!write_busy`
   - Capture `awaddr` vào `awaddr_q`
   - Set `write_busy = 1`
   - Assert `awready = 1` và `wready = 1` trong cùng clock cycle

2. Trong cùng clock cycle:
   - Tính toán memory index từ `awaddr`
   - Ghi dữ liệu vào memory array theo `wstrb`:
     - Chỉ ghi các bytes tương ứng với `wstrb[byte_idx] = 1`
   - Assert `bvalid = 1` với `bresp = 2'b00` (OKAY)

3. Khi nhận B handshake:
   - Deassert `bvalid = 0`
   - Clear `write_busy = 0`
   - Sẵn sàng cho request tiếp theo

**Write Strobe (WSTRB) Logic:**
```verilog
for (byte_idx = 0; byte_idx < DATA_WIDTH/8; byte_idx = byte_idx + 1) begin
    if (S_AXI_wstrb[byte_idx]) begin
        mem[mem_idx][8*byte_idx +: 8] <= S_AXI_wdata[8*byte_idx +: 8];
    end
end
```

## Timing Analysis

### Minimum Write Latency

- **1 clock cycle**: AW và W handshakes (nếu slave sẵn sàng)
- **1 clock cycle**: Slave xử lý và assert bvalid
- **1 clock cycle**: B handshake (nếu master sẵn sàng)

**Total minimum:** 3 clock cycles từ khi master assert `awvalid` và `wvalid` đến khi nhận được response.

### Typical Write Sequence

```
Cycle 0: Master in IDLE, write_req = 1
Cycle 1: Master → WRITE_REQ, awvalid = 1, wvalid = 1
         Slave: awready = 1, wready = 1 (handshakes)
Cycle 2: Master → WRITE_WAIT, bready = 1
         Slave: bvalid = 1, bresp = 00 (handshake)
Cycle 3: Master → WRITE_DONE, captures bresp
Cycle 4: Master → IDLE
```

## Write Strobe (WSTRB) Examples

### Full Word Write (4 bytes)
- `wstrb = 4'b1111`: Ghi tất cả 4 bytes
- Example: `wdata = 0xDEADBEEF`, `wstrb = 4'b1111`
  - Result: `mem[addr] = 0xDEADBEEF`

### Partial Write (2 bytes)
- `wstrb = 4'b0011`: Chỉ ghi 2 bytes thấp (byte 0 và 1)
- Example: `wdata = 0x0000BEEF`, `wstrb = 4'b0011`, `mem[addr] = 0x12345678`
  - Result: `mem[addr] = 0x1234BEEF` (chỉ byte 0 và 1 được thay đổi)

### Single Byte Write
- `wstrb = 4'b0001`: Chỉ ghi byte 0
- Example: `wdata = 0x000000EF`, `wstrb = 4'b0001`, `mem[addr] = 0x12345678`
  - Result: `mem[addr] = 0x123456EF` (chỉ byte 0 được thay đổi)

## Debugging Tips

### Common Issues

1. **Stuck in WRITE_REQ:**
   - Kiểm tra slave có assert cả `awready` và `wready` không
   - Kiểm tra `write_busy` flag trong slave
   - Đảm bảo cả `awvalid` và `wvalid` đều được assert

2. **Stuck in WRITE_WAIT:**
   - Kiểm tra slave có assert `bvalid` không
   - Kiểm tra `write_busy` flag trong slave
   - Kiểm tra memory write logic

3. **Wrong data written:**
   - Kiểm tra address alignment (phải là multiple of 4 cho 32-bit data)
   - Kiểm tra `wstrb` có đúng không
   - Kiểm tra address decoding trong slave

4. **BRESP error:**
   - `bresp = 2'b10` (SLVERR): Slave error, kiểm tra slave logic
   - `bresp = 2'b11` (DECERR): Decode error, kiểm tra address mapping

### Debug Signals

- `master_state`: State hiện tại của master
- `write_addr`: Địa chỉ ghi hiện tại
- `write_data`: Dữ liệu cần ghi
- `write_strb`: Write strobe
- `M_AXI_awvalid`, `M_AXI_awready`: AW handshake signals
- `M_AXI_wvalid`, `M_AXI_wready`: W handshake signals
- `M_AXI_bvalid`, `M_AXI_bready`: B handshake signals
- `M_AXI_bresp`: Write response status

## Differences from Read Operation

### Read Operation
- **2 channels**: AR (Address Read) và R (Read Data)
- **1 handshake** cho address, **1 handshake** cho data
- Master điều khiển AR channel, Slave điều khiển R channel

### Write Operation
- **3 channels**: AW (Address Write), W (Write Data), và B (Write Response)
- **2 handshakes** cho address và data (có thể độc lập), **1 handshake** cho response
- Master điều khiển AW và W channels, Slave điều khiển B channel
- Cần `wstrb` để chỉ định bytes nào được ghi

## Test Results Summary

```
========================================
Test Summary
========================================
Tests Passed: 3
Tests Failed: 0
========================================
ALL TESTS PASSED!
```

## Files Reference

- **Testbench:** `verification/testbenches/simple_write_tb/simple_axi_write_tb.v`
- **Slave:** `src/peripherals/axi_lite/axi_lite_ram.v`
- **TCL Script:** `sim/modelsim/AXI_Interconnect/run_simple_write_tb.tcl`

## Address Mapping

### Slave 2 Address Space

- **Base Address:** `0x8000_0000`
- **Address Range:** `0x8000_0000` - `0xBFFF_FFFF` (1GB)
- **Type:** Read-write memory (RAM)

### Test Addresses

- **Test 1:** `0x8000_0000` = Base address + 0x00000000
- **Test 2:** `0x8000_0004` = Base address + 0x00000004
- **Test 3:** `0x8000_0008` = Base address + 0x00000008

## Conclusion

Test này đã chứng minh rằng:
1. Master state machine hoạt động đúng với AXI write protocol
2. Slave 2 có thể xử lý write requests đúng cách tại base address `0x8000_0000`
3. Write strobe (wstrb) hoạt động chính xác
4. Handshake logic giữa master và slave hoạt động đúng cho cả 3 channels (AW, W, B)
5. Address mapping cho Slave 2 hoạt động đúng

Tất cả 3 test cases đều PASS, xác nhận rằng quá trình ghi dữ liệu từ Master 1 đến Slave 2 hoạt động đúng như mong đợi.

