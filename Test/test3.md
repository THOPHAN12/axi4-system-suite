# Test 3: Dual Master Arbitration with Computation

## Tổng quan

Test này mô tả quá trình hai AXI Master (M0 và M1) đồng thời yêu cầu truy cập đến các Slave khác nhau thông qua AXI Interconnect. Interconnect sử dụng fixed priority arbitration (M0 > M1) để phân xử các yêu cầu. Mỗi Master sẽ đọc một instruction từ Slave tương ứng, thực hiện tính toán, và ghi kết quả trở lại Slave.

**Đặc điểm chính:**
- **2 Masters**: M0 và M1 hoạt động đồng thời
- **2 Slaves**: S1 (base: `0x4000_0000`) và S3 (base: `0xC000_0000`)
- **Arbitration**: Fixed Priority (M0 có ưu tiên cao hơn M1)
- **Computation**: Mỗi Master thực hiện ALU operations (ADD, SUB, MUL)
- **Auto-completion**: Simulation tự động kết thúc khi cả hai Master hoàn thành và quay về IDLE

## Kiến trúc Testbench

### Components

1. **Master 0 (M0)**
   - State machine với 7 states: `IDLE`, `READ_REQ`, `READ_WAIT`, `COMPUTE`, `WRITE_REQ`, `WRITE_WAIT`, `DONE`
   - Giao tiếp với Slave 1 (S1)
   - Đọc instruction từ S1[0], tính toán, ghi kết quả vào S1[1]

2. **Master 1 (M1)**
   - State machine tương tự M0
   - Giao tiếp với Slave 3 (S3)
   - Đọc instruction từ S3[0], tính toán, ghi kết quả vào S3[1]

3. **AXI Interconnect (Simplified)**
   - Fixed Priority Arbitration: M0 > M1
   - Address Decoder: Route M0 → S1, M1 → S3
   - Xử lý cả Read và Write channels

4. **Slave 1 (S1)**
   - AXI-Lite RAM
   - Base address: `0x4000_0000`
   - Memory được khởi tạo từ `mem_init_s1.hex`

5. **Slave 3 (S3)**
   - AXI-Lite RAM
   - Base address: `0xC000_0000`
   - Memory được khởi tạo từ `mem_init_s3.hex`

## Address Mapping

### Slave 1 (S1)
- **Base Address:** `0x4000_0000`
- **Address Range:** `0x4000_0000` - `0x7FFF_FFFF` (1GB)
- **Memory Layout:**
  - `S1[0]` = `0x4000_0000`: Instruction cho M0
  - `S1[1]` = `0x4000_0004`: Result từ M0 (sẽ được ghi)

### Slave 3 (S3)
- **Base Address:** `0xC000_0000`
- **Address Range:** `0xC000_0000` - `0xFFFF_FFFF` (1GB)
- **Memory Layout:**
  - `S3[0]` = `0xC000_0000`: Instruction cho M1
  - `S3[1]` = `0xC000_0004`: Result từ M1 (sẽ được ghi)

## Memory Initialization

### Slave 1 Memory (`mem_init_s1.hex`)
- **S1[0]**: `0x01123456`
  - Opcode: `0x01` (ADD)
  - Operand 1: `0x123` (12-bit)
  - Operand 2: `0x456` (12-bit)
  - Expected result: `0x123 + 0x456 = 0x579`
- **S1[1]**: `0x00000000` (sẽ được ghi kết quả)

### Slave 3 Memory (`mem_init_s3.hex`)
- **S3[0]**: `0x02789ABC`
  - Opcode: `0x02` (SUB)
  - Operand 1: `0x789` (12-bit)
  - Operand 2: `0xABC` (12-bit)
  - Expected result: `0x789 - 0xABC = 0xFFFFFCCD` (signed subtraction)
- **S3[1]**: `0x00000000` (sẽ được ghi kết quả)

## Master State Machines

### Master 0 State Machine

```
IDLE → READ_REQ → READ_WAIT → COMPUTE → WRITE_REQ → WRITE_WAIT → DONE → IDLE
```

#### State Descriptions

1. **IDLE**
   - Chờ `m0_start` signal
   - Khi `m0_start = 1`, chuyển sang `READ_REQ`

2. **READ_REQ**
   - Assert `M0_ARVALID = 1`
   - Set `M0_ARADDR = SLAVE1_BASE + 0x00000000` (đọc instruction)
   - Đợi AR handshake (`M0_ARREADY = 1`)
   - Khi handshake xảy ra, chuyển sang `READ_WAIT`

3. **READ_WAIT**
   - Assert `M0_RREADY = 1`
   - Đợi R handshake (`M0_RVALID = 1`)
   - Capture `M0_RDATA` vào `m0_instruction`
   - Chuyển sang `COMPUTE`

4. **COMPUTE**
   - Decode instruction:
     - `m0_opcode = m0_instruction[31:24]`
     - `m0_op1 = m0_instruction[23:12]`
     - `m0_op2 = m0_instruction[11:0]`
   - Thực hiện tính toán dựa trên opcode:
     - `0x01`: ADD → `m0_result = op1 + op2`
     - `0x02`: SUB → `m0_result = op1 - op2`
     - `0x03`: MUL → `m0_result = op1 * op2`
   - Chuyển sang `WRITE_REQ`

5. **WRITE_REQ**
   - Assert `M0_AWVALID = 1` và `M0_WVALID = 1`
   - Set `M0_AWADDR = SLAVE1_BASE + 0x00000004` (ghi result)
   - Set `M0_WDATA = m0_result`
   - Set `M0_WSTRB = 4'b1111`
   - Đợi cả AW và W handshakes
   - Chuyển sang `WRITE_WAIT`

6. **WRITE_WAIT**
   - Assert `M0_BREADY = 1`
   - Đợi B handshake (`M0_BVALID = 1`)
   - Chuyển sang `DONE`

7. **DONE**
   - Set `m0_completed = 1`
   - Clear `m0_start = 0`
   - Chuyển về `IDLE`

### Master 1 State Machine

Tương tự Master 0, nhưng:
- Giao tiếp với Slave 3 (S3)
- Sử dụng `M1_*` signals
- Sử dụng `m1_*` internal signals

## Interconnect và Arbitration

### Fixed Priority Arbitration

**Priority Order:** M0 > M1

#### Read Address Channel Arbitration

```verilog
wire m0_read_req = M0_ARVALID;
wire m1_read_req = M1_ARVALID;

wire m0_read_grant = m0_read_req;  // M0 always wins if requesting
wire m1_read_grant = m1_read_req && !m0_read_req;  // M1 only if M0 not requesting
```

#### Write Address Channel Arbitration

```verilog
wire m0_write_req = M0_AWVALID && M0_WVALID;
wire m1_write_req = M1_AWVALID && M1_WVALID;

wire m0_write_grant = m0_write_req;
wire m1_write_grant = m1_write_req && !m0_write_req;
```

### Address Decoder

```verilog
wire route_to_s1 = m0_read_grant || m0_write_grant;
wire route_to_s3 = m1_read_grant || m1_write_grant;
```

**Routing Logic:**
- M0 requests → Route to S1
- M1 requests → Route to S3

### Channel Routing

#### M0 Read Channel (to S1)
- `M0_ARREADY` = `m0_read_grant && route_to_s1 ? S1_ARREADY : 1'b0`
- `S1_ARADDR` = `m0_read_grant && route_to_s1 ? M0_ARADDR : 32'h0`
- `S1_ARVALID` = `m0_read_grant && route_to_s1 ? M0_ARVALID : 1'b0`
- `M0_RDATA` = `S1_RDATA`
- `M0_RVALID` = `S1_RVALID`
- `S1_RREADY` = `M0_RREADY`

#### M0 Write Channel (to S1)
- Tương tự, route M0 write signals đến S1

#### M1 Read/Write Channels (to S3)
- Tương tự, route M1 signals đến S3

## Computation Logic

### Instruction Format

```
[31:24]  [23:12]  [11:0]
 Opcode  Operand1 Operand2
  8-bit   12-bit   12-bit
```

### Opcode Definitions

- **0x01**: ADD
  - `result = {16'h0, op1} + {16'h0, op2}`
  - Zero-extend 12-bit operands to 32-bit before addition

- **0x02**: SUB
  - `result = {16'h0, op1} - {16'h0, op2}`
  - Zero-extend 12-bit operands to 32-bit before subtraction

- **0x03**: MUL
  - `result = op1 * op2`
  - Direct multiplication of 12-bit operands (result may overflow 12-bit)

### Example Computations

#### M0: ADD Operation
- Instruction: `0x01123456`
- Opcode: `0x01` (ADD)
- Op1: `0x123` = 291 (decimal)
- Op2: `0x456` = 1110 (decimal)
- Result: `0x123 + 0x456 = 0x579` = 1401 (decimal)

#### M1: SUB Operation
- Instruction: `0x02789ABC`
- Opcode: `0x02` (SUB)
- Op1: `0x789` = 1929 (decimal)
- Op2: `0xABC` = 2748 (decimal)
- Result: `0x789 - 0xABC = 0xFFFFFCCD` = -819 (decimal, signed)

## Test Sequence

### Initialization

1. Reset được release sau 5 clock cycles
2. Memory files được tạo:
   - `mem_init_s1.hex`: Instruction cho M0
   - `mem_init_s3.hex`: Instruction cho M1
3. Slaves được khởi tạo với memory data

### Test Execution

1. **Start Both Masters Simultaneously**
   ```verilog
   m0_start = 1'b1;
   m1_start = 1'b1;
   @(posedge ACLK);
   m0_start = 1'b0;
   m1_start = 1'b0;
   ```

2. **Arbitration Behavior**
   - Cả M0 và M1 đều request đồng thời
   - Interconnect ưu tiên M0 (fixed priority)
   - M0 được grant trước, M1 phải đợi
   - Khi M0 hoàn thành, M1 được grant

3. **Master 0 Flow**
   - Read instruction từ S1[0]: `0x01123456`
   - Compute: `0x123 + 0x456 = 0x579`
   - Write result vào S1[1]: `0x579`

4. **Master 1 Flow**
   - Read instruction từ S3[0]: `0x02789ABC`
   - Compute: `0x789 - 0xABC = 0xFFFFFCCD`
   - Write result vào S3[1]: `0xFFFFFCCD`

5. **Completion Detection**
   - Mỗi Master set `m0_completed` hoặc `m1_completed` khi chuyển từ DONE về IDLE
   - Simulation tự động kết thúc khi:
     ```verilog
     m0_completed && m1_completed && 
     m0_state == M0_IDLE && m1_state == M1_IDLE
     ```

## Simulation Completion

### Auto-completion Logic

```verilog
always @(posedge ACLK) begin
    if (ARESETN && m0_completed && m1_completed && 
        m0_state == M0_IDLE && m1_state == M1_IDLE) begin
        $display("\n[TB] Both masters have completed and returned to IDLE");
        $display("[TB] Ending simulation...");
        #(CLK_PERIOD * 2);
        $finish;
    end
end
```

**Completion Conditions:**
1. Cả hai Master đã hoàn thành (`m0_completed && m1_completed`)
2. Cả hai Master đều ở trạng thái IDLE
3. Reset đã được release (`ARESETN = 1`)

**Benefits:**
- Không cần hardcode simulation time
- Tự động kết thúc khi test hoàn thành
- Đảm bảo cả hai Master đều hoàn thành trước khi kết thúc

## Arbitration Timing Analysis

### Scenario: Both Masters Request Simultaneously

```
Cycle 0: M0 và M1 đều assert ARVALID
Cycle 1: Interconnect grants M0 (higher priority)
         M0: AR handshake với S1
         M1: ARVALID vẫn high, nhưng ARREADY = 0 (waiting)
Cycle 2: M0: R handshake với S1, nhận instruction
         M1: Vẫn đợi
Cycle 3: M0: COMPUTE state
         M1: Vẫn đợi
Cycle 4: M0: WRITE_REQ, AW/W handshakes với S1
         M1: Vẫn đợi
Cycle 5: M0: WRITE_WAIT, B handshake với S1
         M1: Vẫn đợi
Cycle 6: M0: DONE → IDLE, m0_completed = 1
         M1: Bây giờ được grant, AR handshake với S3
Cycle 7: M1: R handshake với S3, nhận instruction
         M0: IDLE (completed)
...
```

**Key Points:**
- M0 luôn được ưu tiên khi cả hai cùng request
- M1 phải đợi M0 hoàn thành mới được grant
- Arbitration xảy ra ở mỗi channel (Read và Write) độc lập

## AXI Protocol Compliance

### Read Channels
- **AR Channel**: Master điều khiển `arvalid`, Slave điều khiển `arready`
- **R Channel**: Slave điều khiển `rvalid`, Master điều khiển `rready`

### Write Channels
- **AW Channel**: Master điều khiển `awvalid`, Slave điều khiển `awready`
- **W Channel**: Master điều khiển `wvalid`, Slave điều khiển `wready`
- **B Channel**: Slave điều khiển `bvalid`, Master điều khiển `bready`

### Handshake Rules
- Handshake xảy ra khi cả `_valid` và `_ready` đều = 1 tại cùng clock edge
- `_valid` không được deassert cho đến khi handshake xảy ra
- `_ready` có thể deassert bất cứ lúc nào (flow control)

## Debugging Tips

### Common Issues

1. **Master Stuck in READ_REQ/WRITE_REQ:**
   - Kiểm tra arbitration logic: Master có được grant không?
   - Kiểm tra address decoder: Route đúng đến Slave không?
   - Kiểm tra Slave `_ready` signals

2. **Wrong Arbitration Behavior:**
   - Kiểm tra `m0_read_grant` và `m1_read_grant` signals
   - Đảm bảo M0 có priority cao hơn M1
   - Kiểm tra `route_to_s1` và `route_to_s3` signals

3. **Wrong Computation Results:**
   - Kiểm tra instruction format: Opcode, Op1, Op2
   - Kiểm tra computation logic trong COMPUTE state
   - Kiểm tra operand extension (zero-extension cho ADD/SUB)

4. **Simulation Not Ending:**
   - Kiểm tra `m0_completed` và `m1_completed` flags
   - Kiểm tra Master state machines có chuyển về IDLE không
   - Kiểm tra completion detection logic

### Debug Signals

**Master 0:**
- `m0_state`: Current state
- `m0_instruction`: Instruction đã đọc
- `m0_result`: Kết quả tính toán
- `m0_completed`: Completion flag
- `M0_ARVALID`, `M0_ARREADY`: AR handshake
- `M0_RVALID`, `M0_RREADY`: R handshake
- `M0_AWVALID`, `M0_AWREADY`: AW handshake
- `M0_WVALID`, `M0_WREADY`: W handshake
- `M0_BVALID`, `M0_BREADY`: B handshake

**Master 1:**
- Tương tự với `m1_*` và `M1_*` signals

**Interconnect:**
- `m0_read_grant`, `m1_read_grant`: Read arbitration grants
- `m0_write_grant`, `m1_write_grant`: Write arbitration grants
- `route_to_s1`, `route_to_s3`: Address routing

**Slaves:**
- `S1_RDATA`, `S3_RDATA`: Read data
- `S1_WDATA`, `S3_WDATA`: Write data
- Memory contents trong Slaves

## Test Results Summary

### Expected Results

**Master 0:**
- Instruction read: `0x01123456`
- Computation: `0x123 + 0x456 = 0x579`
- Result written to S1[1]: `0x579`

**Master 1:**
- Instruction read: `0x02789ABC`
- Computation: `0x789 - 0xABC = 0xFFFFFCCD`
- Result written to S3[1]: `0xFFFFFCCD`

### Verification

```
========================================
Test Summary
========================================
Tests Passed: 1
Tests Failed: 0
========================================
ALL TESTS PASSED!
```

**Test Criteria:**
- ✅ Both masters completed successfully
- ✅ M0 result written correctly to S1[1]
- ✅ M1 result written correctly to S3[1]
- ✅ Arbitration worked correctly (M0 priority)
- ✅ Simulation ended automatically

## Files Reference

- **Testbench:** `verification/testbenches/dual_master_tb/dual_master_arbitration_tb.v`
- **Slave 1:** `src/peripherals/axi_lite/axi_lite_ram.v` (instantiated as S1)
- **Slave 3:** `src/peripherals/axi_lite/axi_lite_ram.v` (instantiated as S3)
- **TCL Script:** `sim/modelsim/AXI_Interconnect/run_dual_master_arbitration_tb.tcl`
- **Memory Files:**
  - `mem_init_s1.hex`: Initial data for Slave 1
  - `mem_init_s3.hex`: Initial data for Slave 3

## Conclusion

Test này đã chứng minh rằng:

1. **Dual Master System**: Hai Master có thể hoạt động đồng thời và độc lập
2. **Arbitration**: Fixed priority arbitration hoạt động đúng (M0 > M1)
3. **Address Decoding**: Interconnect route đúng requests đến Slaves tương ứng
4. **Computation**: Mỗi Master có thể đọc instruction, tính toán, và ghi kết quả
5. **Protocol Compliance**: Tất cả AXI handshakes hoạt động đúng
6. **Auto-completion**: Simulation tự động kết thúc khi cả hai Master hoàn thành

Test case này mô phỏng một hệ thống thực tế với nhiều processors (Masters) truy cập vào shared memory (Slaves) thông qua một interconnect với arbitration logic. Điều này rất quan trọng trong các hệ thống SoC (System-on-Chip) hiện đại.

