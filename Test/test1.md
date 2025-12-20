# Test 1: AXI Master Read Process

## Tổng quan

Test này mô tả quá trình đọc dữ liệu từ AXI-Lite RAM Slave bởi một AXI Master đơn giản. Testbench sử dụng một master state machine để thực hiện các giao dịch đọc AXI theo đúng protocol.

## Kiến trúc Testbench

### Components

1. **AXI Master (Simple Master)**
   - State machine với 4 states: `IDLE`, `READ_REQ`, `READ_WAIT`, `READ_DONE`
   - Điều khiển các tín hiệu AXI read channel

2. **AXI-Lite RAM Slave**
   - Memory được khởi tạo từ file `mem_init.hex`
   - Hỗ trợ AXI-Lite read/write operations

### Memory Initialization

Memory được khởi tạo với các giá trị sau (từ `mem_init.hex`):
- `mem[0]` = `0xDEADBEEF`
- `mem[1]` = `0xCAFEBABE`
- `mem[2]` = `0x12345678`
- `mem[3]` = `0x87654321`
- `mem[4]` = `0xABCDEF00`
- `mem[5]` = `0x00FEDCBA`
- `mem[6]` = `0x11111111`
- `mem[7]` = `0x22222222`

## Quá trình đọc dữ liệu của Master

### State Machine Flow

```
IDLE → READ_REQ → READ_WAIT → READ_DONE → IDLE
```

### Chi tiết từng State

#### 1. IDLE State

**Điều kiện vào:**
- Reset được release
- `read_req` flag được set bởi test sequence
- `read_addr` đã được set với địa chỉ cần đọc

**Hành động:**
- Giữ tất cả AXI signals ở trạng thái idle:
  - `M_AXI_arvalid = 0`
  - `M_AXI_rready = 0`
- Khi `read_req = 1`, chuyển sang state `READ_REQ`

**Code:**
```verilog
IDLE: begin
    M_AXI_arvalid <= 1'b0;
    M_AXI_rready  <= 1'b0;
    if (read_req) begin
        master_state <= READ_REQ;
    end
end
```

#### 2. READ_REQ State

**Mục đích:**
- Gửi read address request đến slave
- Thực hiện AR (Address Read) handshake

**Hành động:**
- Assert `M_AXI_arvalid = 1`
- Set `M_AXI_araddr` với địa chỉ cần đọc
- Set `M_AXI_arprot = 3'b000` (normal, secure, data access)
- Giữ `arvalid` high cho đến khi `arready` được assert

**AR Handshake:**
- Handshake xảy ra khi cả `arvalid` và `arready` đều = 1
- Khi handshake hoàn tất, chuyển sang state `READ_WAIT`

**Code:**
```verilog
READ_REQ: begin
    M_AXI_araddr  <= read_addr;
    M_AXI_arprot  <= 3'b000;
    M_AXI_arvalid <= 1'b1;
    if (M_AXI_arready) begin
        master_state <= READ_WAIT;
    end
end
```

**Timing Diagram:**
```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__
ARADDR:    XXXX  [addr]  XXXX
ARVALID:   ____  ‾‾‾‾  ____
ARREADY:   ____  ‾‾‾‾  ____
           Handshake occurs here
```

#### 3. READ_WAIT State

**Mục đích:**
- Đợi slave trả về dữ liệu
- Thực hiện R (Read Data) handshake

**Hành động:**
- Deassert `M_AXI_arvalid = 0` (không cần nữa)
- Assert `M_AXI_rready = 1` để sẵn sàng nhận dữ liệu
- Đợi slave assert `rvalid = 1`

**R Handshake:**
- Handshake xảy ra khi cả `rvalid` và `rready` đều = 1
- Khi handshake hoàn tất:
  - Capture `M_AXI_rdata` vào `read_data`
  - Chuyển sang state `READ_DONE`

**Code:**
```verilog
READ_WAIT: begin
    M_AXI_arvalid <= 1'b0;
    M_AXI_rready <= 1'b1;
    if (M_AXI_rvalid && M_AXI_rready) begin
        read_data <= M_AXI_rdata;
        master_state <= READ_DONE;
        M_AXI_rready <= 1'b0;
    end
end
```

**Timing Diagram:**
```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__
RREADY:    ____  ‾‾‾‾  ____
RVALID:    ____  ‾‾‾‾  ____
RDATA:     XXXX  [data]  XXXX
           Handshake occurs here
```

#### 4. READ_DONE State

**Mục đích:**
- Hoàn tất giao dịch đọc
- Chuẩn bị cho giao dịch tiếp theo

**Hành động:**
- Clear `read_req` flag
- Chuyển về state `IDLE`

**Code:**
```verilog
READ_DONE: begin
    master_state <= IDLE;
    read_req <= 1'b0;
end
```

## Test Cases

### Test 1: Read from address 0x00000000

**Expected:** `0xDEADBEEF`

**Sequence:**
1. Test sequence sets `read_addr = 0x00000000`
2. Test sequence sets `read_req = 1`
3. Master chuyển từ `IDLE` → `READ_REQ`
4. AR handshake xảy ra
5. Master chuyển sang `READ_WAIT`
6. Slave trả về `rdata = 0xDEADBEEF` với `rvalid = 1`
7. R handshake xảy ra
8. Master capture `read_data = 0xDEADBEEF`
9. Master chuyển sang `READ_DONE` → `IDLE`
10. Test sequence kiểm tra `read_data === expected_data`

**Result:** ✅ PASS

### Test 2: Read from address 0x00000004

**Expected:** `0xCAFEBABE`

**Sequence:**
1. Test sequence sets `read_addr = 0x00000004`
2. Test sequence sets `read_req = 1`
3. Master chuyển từ `IDLE` → `READ_REQ`
4. AR handshake xảy ra
5. Master chuyển sang `READ_WAIT`
6. Slave trả về `rdata = 0xCAFEBABE` với `rvalid = 1`
7. R handshake xảy ra
8. Master capture `read_data = 0xCAFEBABE`
9. Master chuyển sang `READ_DONE` → `IDLE`
10. Test sequence kiểm tra `read_data === expected_data`

**Result:** ✅ PASS

### Test 3: Read from address 0x00000008

**Expected:** `0x12345678`

**Sequence:**
1. Test sequence sets `read_addr = 0x00000008`
2. Test sequence sets `read_req = 1`
3. Master chuyển từ `IDLE` → `READ_REQ`
4. AR handshake xảy ra
5. Master chuyển sang `READ_WAIT`
6. Slave trả về `rdata = 0x12345678` với `rvalid = 1`
7. R handshake xảy ra
8. Master capture `read_data = 0x12345678`
9. Master chuyển sang `READ_DONE` → `IDLE`
10. Test sequence kiểm tra `read_data === expected_data`

**Result:** ✅ PASS

## AXI Protocol Compliance

### Read Address Channel (AR)

- **ARVALID**: Master asserts khi có địa chỉ hợp lệ
- **ARREADY**: Slave asserts khi sẵn sàng nhận địa chỉ
- **ARADDR**: Địa chỉ byte (32-bit)
- **ARPROT**: Protection type (3-bit)

**Rule:** Handshake xảy ra khi cả `ARVALID` và `ARREADY` đều = 1 tại cùng một clock edge.

### Read Data Channel (R)

- **RVALID**: Slave asserts khi có dữ liệu hợp lệ
- **RREADY**: Master asserts khi sẵn sàng nhận dữ liệu
- **RDATA**: Dữ liệu đọc (32-bit)
- **RRESP**: Response status (2-bit, `00` = OKAY)

**Rule:** Handshake xảy ra khi cả `RVALID` và `RREADY` đều = 1 tại cùng một clock edge.

## Slave Behavior

### AXI-Lite RAM Slave

**Read Process:**
1. Khi nhận AR handshake:
   - Capture `araddr` vào `araddr_q`
   - Set `read_pending = 1`
   - Deassert `arready` (combinational: `arready = !read_pending`)

2. Trong clock cycle tiếp theo:
   - Tính toán memory index từ `araddr_q`
   - Đọc dữ liệu từ memory array
   - Assert `rvalid = 1` với `rdata` và `rresp = 2'b00`

3. Khi nhận R handshake:
   - Deassert `rvalid = 0`
   - Clear `read_pending = 0`
   - Sẵn sàng cho request tiếp theo

## Timing Analysis

### Minimum Read Latency

- **1 clock cycle**: AR handshake (nếu slave sẵn sàng)
- **1 clock cycle**: Slave xử lý và assert rvalid
- **1 clock cycle**: R handshake (nếu master sẵn sàng)

**Total minimum:** 3 clock cycles từ khi master assert `arvalid` đến khi nhận được dữ liệu.

### Typical Read Sequence

```
Cycle 0: Master in IDLE, read_req = 1
Cycle 1: Master → READ_REQ, arvalid = 1, arready = 1 (handshake)
Cycle 2: Master → READ_WAIT, rready = 1, slave processing
Cycle 3: Slave asserts rvalid = 1, rdata = [data], rready = 1 (handshake)
Cycle 4: Master → READ_DONE, captures read_data
Cycle 5: Master → IDLE
```

## Debugging Tips

### Common Issues

1. **Stuck in READ_WAIT:**
   - Kiểm tra slave có assert `rvalid` không
   - Kiểm tra `read_pending` flag trong slave
   - Kiểm tra memory có được load đúng không

2. **Wrong data read:**
   - Kiểm tra address alignment (phải là multiple of 4 cho 32-bit data)
   - Kiểm tra memory initialization
   - Kiểm tra address decoding trong slave

3. **Handshake timeout:**
   - Đảm bảo cả master và slave đều assert `_valid` và `_ready` đúng lúc
   - Kiểm tra reset signals

### Debug Signals

- `master_state`: State hiện tại của master
- `read_addr`: Địa chỉ đọc hiện tại
- `read_data`: Dữ liệu đã đọc
- `M_AXI_arvalid`, `M_AXI_arready`: AR handshake signals
- `M_AXI_rvalid`, `M_AXI_rready`: R handshake signals
- `M_AXI_rdata`: Dữ liệu từ slave

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

- **Testbench:** `verification/testbenches/simple_read_tb/simple_axi_read_tb.v`
- **Slave:** `src/peripherals/axi_lite/axi_lite_ram.v`
- **TCL Script:** `sim/modelsim/AXI_Interconnect/run_simple_read_tb.tcl`

## Conclusion

Test này đã chứng minh rằng:
1. Master state machine hoạt động đúng với AXI protocol
2. Slave có thể xử lý read requests đúng cách
3. Memory initialization hoạt động chính xác
4. Handshake logic giữa master và slave hoạt động đúng

Tất cả 3 test cases đều PASS, xác nhận rằng quá trình đọc dữ liệu của Master hoạt động đúng như mong đợi.

