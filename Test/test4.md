# Test 4: Master Dependency - Shared Memory Communication

## Tổng quan

Test này mô tả quá trình hai AXI Master (M0 và M1) giao tiếp thông qua một shared memory (S0). M0 đọc instruction, thực hiện tính toán, và ghi kết quả vào S0. M1 đợi M0 hoàn thành, sau đó đọc kết quả từ S0 và sử dụng giá trị đó làm địa chỉ offset để gửi dữ liệu đến Slave 1 (S1).

**Đặc điểm chính:**
- **2 Masters**: M0 và M1 với dependency (M1 phải đợi M0)
- **2 Slaves**: S0 (base: `0x0000_0000`) - shared memory, S1 (base: `0x4000_0000`) - target
- **Dependency**: M1 phải đợi M0 hoàn thành trước khi đọc từ S0
- **Address Calculation**: M1 sử dụng kết quả từ M0 làm địa chỉ offset
- **Auto-completion**: Simulation tự động kết thúc khi cả hai Master hoàn thành và quay về IDLE

## Kiến trúc Testbench

### Components

1. **Master 0 (M0)**
   - State machine với 7 states: `IDLE`, `READ_REQ`, `READ_WAIT`, `COMPUTE`, `WRITE_REQ`, `WRITE_WAIT`, `DONE`
   - Đọc instruction từ S0[1]
   - Tính toán kết quả
   - Ghi kết quả vào S0[0]

2. **Master 1 (M1)**
   - State machine với 7 states: `IDLE`, `WAIT_M0`, `READ_S0_REQ`, `READ_S0_WAIT`, `SEND_REQ`, `SEND_WAIT`, `DONE`
   - Đợi M0 hoàn thành (`m0_completed = 1`)
   - Đọc kết quả từ S0[0]
   - Sử dụng kết quả làm địa chỉ offset
   - Gửi dữ liệu đến S1 tại địa chỉ `S1_BASE + offset`

3. **AXI Interconnect (Simplified)**
   - Fixed Priority Arbitration: M0 > M1
   - Address Decoder: 
     - M0 → S0 (read instruction, write result)
     - M1 → S0 (read result), S1 (write data)
   - Xử lý cả Read và Write channels

4. **Slave 0 (S0) - Shared Memory**
   - AXI-Lite RAM
   - Base address: `0x0000_0000`
   - Memory được khởi tạo từ `mem_init_s0_dep.hex`
   - Được truy cập bởi cả M0 và M1

5. **Slave 1 (S1) - Target for M1**
   - AXI-Lite RAM
   - Base address: `0x4000_0000`
   - Memory được khởi tạo từ `mem_init_s1_dep.hex`
   - Nhận dữ liệu từ M1 tại địa chỉ động

## Address Mapping

### Slave 0 (S0) - Shared Memory
- **Base Address:** `0x0000_0000`
- **Address Range:** `0x0000_0000` - `0x3FFF_FFFF` (1GB)
- **Memory Layout:**
  - `S0[0]` = `0x0000_0000`: Result từ M0 (sẽ được ghi), sau đó được M1 đọc
  - `S0[1]` = `0x0000_0004`: Instruction cho M0

### Slave 1 (S1) - Target for M1
- **Base Address:** `0x4000_0000`
- **Address Range:** `0x4000_0000` - `0x7FFF_FFFF` (1GB)
- **Memory Layout:**
  - `S1[offset]` = `0x4000_0000 + offset`: Địa chỉ động, offset được tính từ kết quả của M0

## Memory Initialization

### Slave 0 Memory (`mem_init_s0_dep.hex`)
- **S0[0]**: `0x00000000` (sẽ được ghi kết quả bởi M0)
- **S0[1]**: `0x01123456`
  - Opcode: `0x01` (ADD)
  - Operand 1: `0x123` (12-bit)
  - Operand 2: `0x456` (12-bit)
  - Expected result: `0x123 + 0x456 = 0x579`

### Slave 1 Memory (`mem_init_s1_dep.hex`)
- **S1[0]**: `0x00000000` (sẽ nhận dữ liệu từ M1)
- Tất cả các vị trí khác: `0x00000000`

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
   - Set `M0_ARADDR = SLAVE0_BASE + 0x00000004` (đọc instruction từ S0[1])
   - Đợi AR handshake
   - Chuyển sang `READ_WAIT`

3. **READ_WAIT**
   - Assert `M0_RREADY = 1`
   - Đợi R handshake
   - Capture `M0_RDATA` vào `m0_instruction`
   - Chuyển sang `COMPUTE`

4. **COMPUTE**
   - Decode instruction và tính toán
   - Example: `0x01123456` → ADD `0x123 + 0x456 = 0x579`
   - Lưu kết quả vào `m0_result`
   - Chuyển sang `WRITE_REQ`

5. **WRITE_REQ**
   - Assert `M0_AWVALID = 1` và `M0_WVALID = 1`
   - Set `M0_AWADDR = SLAVE0_BASE + 0x00000000` (ghi result vào S0[0])
   - Set `M0_WDATA = m0_result`
   - Đợi cả AW và W handshakes
   - Chuyển sang `WRITE_WAIT`

6. **WRITE_WAIT**
   - Assert `M0_BREADY = 1`
   - Đợi B handshake
   - Chuyển sang `DONE`

7. **DONE**
   - Set `m0_completed = 1` (signal cho M1)
   - Clear `m0_start = 0`
   - Chuyển về `IDLE`

### Master 1 State Machine

```
IDLE → WAIT_M0 → READ_S0_REQ → READ_S0_WAIT → SEND_REQ → SEND_WAIT → DONE → IDLE
```

#### State Descriptions

1. **IDLE**
   - Chờ `m1_start` signal
   - Khi `m1_start = 1`, chuyển sang `WAIT_M0`

2. **WAIT_M0**
   - **Dependency Point**: Đợi `m0_completed = 1`
   - Đảm bảo M0 đã ghi kết quả vào S0[0]
   - Khi `m0_completed = 1`, chuyển sang `READ_S0_REQ`

3. **READ_S0_REQ**
   - Assert `M1_ARVALID = 1`
   - Set `M1_ARADDR = SLAVE0_BASE + 0x00000000` (đọc result từ S0[0])
   - Đợi AR handshake
   - Chuyển sang `READ_S0_WAIT`

4. **READ_S0_WAIT**
   - Assert `M1_RREADY = 1`
   - Đợi R handshake
   - Capture `M1_RDATA` vào `m1_address_offset`
   - Chuyển sang `SEND_REQ`

5. **SEND_REQ**
   - **Address Calculation**: `target_addr = SLAVE1_BASE + m1_address_offset`
   - Assert `M1_AWVALID = 1` và `M1_WVALID = 1`
   - Set `M1_AWADDR = target_addr`
   - Set `M1_WDATA = 0xCAFEBABE` (test data)
   - Đợi cả AW và W handshakes
   - Chuyển sang `SEND_WAIT`

6. **SEND_WAIT**
   - Assert `M1_BREADY = 1`
   - Đợi B handshake
   - Chuyển sang `DONE`

7. **DONE**
   - Set `m1_completed = 1`
   - Clear `m1_start = 0`
   - Chuyển về `IDLE`

## Dependency Flow

### Sequence Diagram

```
M0:  IDLE → READ_REQ → READ_WAIT → COMPUTE → WRITE_REQ → WRITE_WAIT → DONE → IDLE
      |                                                                      |
      |                                                                      |
      └──────────────────────────────────────────────────────────────────────┘
                                                                              |
                                                                              v
                                                                    m0_completed = 1
                                                                              |
                                                                              |
M1:  IDLE → WAIT_M0 ──────────────────────────────────────────────────────────┘
      |                                                                      |
      |                                                                      |
      └→ READ_S0_REQ → READ_S0_WAIT → SEND_REQ → SEND_WAIT → DONE → IDLE
```

### Key Points

1. **M0 executes first**: M0 phải hoàn thành toàn bộ quá trình (read → compute → write) trước khi M1 bắt đầu
2. **Shared memory access**: Cả M0 và M1 đều truy cập S0, nhưng tại các địa chỉ khác nhau
3. **Address dependency**: M1 sử dụng kết quả từ M0 để tính toán địa chỉ đích

## Interconnect và Arbitration

### Fixed Priority Arbitration

**Priority Order:** M0 > M1

#### Read Address Channel Arbitration

```verilog
wire m0_read_grant = m0_read_req;  // M0 always wins if requesting
wire m1_read_grant = m1_read_req && !m0_read_req;  // M1 only if M0 not requesting
```

#### Address Decoder

```verilog
// M0 routes to S0
wire m0_to_s0 = (M0_ARADDR >= SLAVE0_BASE && M0_ARADDR < SLAVE1_BASE) ||
                 (M0_AWADDR >= SLAVE0_BASE && M0_AWADDR < SLAVE1_BASE);

// M1 routes to S0 for read, S1 for write
wire m1_to_s0 = (M1_ARADDR >= SLAVE0_BASE && M1_ARADDR < SLAVE1_BASE);
wire m1_to_s1 = (M1_AWADDR >= SLAVE1_BASE && M1_AWADDR < 32'h80000000);
```

### Shared S0 Read Channel

S0 có thể được đọc bởi cả M0 và M1, nhưng M0 có priority:

```verilog
// S0 Read Address Channel (M0 has priority)
assign S0_ARADDR = (m0_read_grant && m0_to_s0) ? M0_ARADDR : 
                   (m1_read_grant && m1_to_s0) ? M1_ARADDR : 32'h0;
assign S0_ARVALID = (m0_read_grant && m0_to_s0 && M0_ARVALID) || 
                    (m1_read_grant && m1_to_s0 && M1_ARVALID);
```

## Test Sequence

### Initialization

1. Reset được release sau 5 clock cycles
2. Memory files được tạo:
   - `mem_init_s0_dep.hex`: Instruction cho M0 tại S0[1]
   - `mem_init_s1_dep.hex`: Initialized với zeros
3. Slaves được khởi tạo với memory data

### Test Execution

1. **Start M0**
   ```verilog
   m0_start = 1'b1;
   @(posedge ACLK);
   m0_start = 1'b0;
   ```

2. **M0 Flow**
   - Read instruction từ S0[1]: `0x01123456`
   - Compute: `0x123 + 0x456 = 0x579`
   - Write result vào S0[0]: `0x579`
   - Set `m0_completed = 1`

3. **Start M1** (có thể start ngay, nhưng sẽ đợi M0)
   ```verilog
   m1_start = 1'b1;
   @(posedge ACLK);
   m1_start = 1'b0;
   ```

4. **M1 Flow**
   - Wait for `m0_completed = 1`
   - Read result từ S0[0]: `0x579`
   - Calculate target address: `0x40000000 + 0x579 = 0x40000579`
   - Send data `0xCAFEBABE` đến S1 tại address `0x40000579`

5. **Completion Detection**
   - Mỗi Master set `m0_completed` hoặc `m1_completed` khi chuyển từ DONE về IDLE
   - Simulation tự động kết thúc khi:
     ```verilog
     m0_completed && m1_completed && 
     m0_state == M0_IDLE && m1_state == M1_IDLE
     ```

## Expected Results

### Master 0
- Instruction read: `0x01123456`
- Computation: `0x123 + 0x456 = 0x579`
- Result written to S0[0]: `0x579`

### Master 1
- Address offset read from S0[0]: `0x579`
- Target address: `0x40000000 + 0x579 = 0x40000579`
- Data sent to S1: `0xCAFEBABE`
- Data written to S1[0x579]: `0xCAFEBABE`

## Timing Analysis

### Sequential Execution (Due to Dependency)

```
Cycle 0: M0 starts, M1 starts (but waits)
Cycle 1-6: M0 executes (read → compute → write)
Cycle 6: M0 completes, m0_completed = 1
Cycle 7: M1 detects m0_completed, starts reading from S0
Cycle 8-12: M1 executes (read S0 → send to S1)
Cycle 13: M1 completes, m1_completed = 1
Cycle 14: Both in IDLE, simulation ends
```

**Key Points:**
- M0 và M1 không chạy song song do dependency
- M1 phải đợi M0 hoàn thành
- Total execution time = M0_time + M1_time

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

1. **M1 Stuck in WAIT_M0:**
   - Kiểm tra `m0_completed` flag có được set không
   - Kiểm tra M0 có hoàn thành write vào S0[0] không
   - Kiểm tra M0 state machine có chuyển về IDLE không

2. **Wrong Address Calculation:**
   - Kiểm tra `m1_address_offset` có đúng giá trị đọc từ S0[0] không
   - Kiểm tra `SLAVE1_BASE + m1_address_offset` calculation
   - Kiểm tra address decoder có route đúng đến S1 không

3. **Shared Memory Access Conflict:**
   - Kiểm tra arbitration logic cho S0 read channel
   - Đảm bảo M0 và M1 không truy cập cùng địa chỉ đồng thời
   - Kiểm tra `S0_ARADDR` và `S0_ARVALID` mux logic

4. **Simulation Not Ending:**
   - Kiểm tra `m0_completed` và `m1_completed` flags
   - Kiểm tra Master state machines có chuyển về IDLE không
   - Kiểm tra completion detection logic

### Debug Signals

**Master 0:**
- `m0_state`: Current state
- `m0_instruction`: Instruction đã đọc
- `m0_result`: Kết quả tính toán
- `m0_completed`: Completion flag (signal cho M1)

**Master 1:**
- `m1_state`: Current state
- `m1_address_offset`: Address offset đọc từ S0[0]
- `m1_completed`: Completion flag

**Shared Memory (S0):**
- `S0_ARADDR`: Read address (from M0 or M1)
- `S0_RDATA`: Read data
- `S0_AWADDR`: Write address (from M0)
- `S0_WDATA`: Write data (from M0)
- Memory contents trong S0

**Target Slave (S1):**
- `S1_AWADDR`: Write address (calculated by M1)
- `S1_WDATA`: Write data (from M1)
- Memory contents trong S1

## Test Results Summary

### Expected Results

**Master 0:**
- Instruction read: `0x01123456`
- Computation: `0x123 + 0x456 = 0x579`
- Result written to S0[0]: `0x579`

**Master 1:**
- Address offset read from S0[0]: `0x579`
- Target address: `0x40000000 + 0x579 = 0x40000579`
- Data sent to S1: `0xCAFEBABE`
- Data written to S1[0x579]: `0xCAFEBABE`

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
- ✅ M0 completed successfully
- ✅ M1 completed successfully
- ✅ M0 result written correctly to S0[0]
- ✅ M1 read correct value from S0[0]
- ✅ M1 calculated correct target address
- ✅ M1 data written correctly to S1
- ✅ Dependency enforced (M1 waited for M0)
- ✅ Simulation ended automatically

## Files Reference

- **Testbench:** `verification/testbenches/dual_master_tb/master_dependency_tb.v`
- **Slave 0:** `src/peripherals/axi_lite/axi_lite_ram.v` (instantiated as S0)
- **Slave 1:** `src/peripherals/axi_lite/axi_lite_ram.v` (instantiated as S1)
- **TCL Script:** `sim/modelsim/AXI_Interconnect/run_master_dependency_tb.tcl`
- **Memory Files:**
  - `mem_init_s0_dep.hex`: Initial data for Slave 0
  - `mem_init_s1_dep.hex`: Initial data for Slave 1

## Conclusion

Test này đã chứng minh rằng:

1. **Master Dependency**: M1 có thể đợi M0 hoàn thành thông qua completion flag
2. **Shared Memory Communication**: Hai Master có thể giao tiếp thông qua shared memory (S0)
3. **Dynamic Address Calculation**: M1 sử dụng kết quả từ M0 để tính toán địa chỉ đích động
4. **Arbitration**: Interconnect xử lý đúng khi cả hai Master truy cập cùng một Slave (S0)
5. **Protocol Compliance**: Tất cả AXI handshakes hoạt động đúng
6. **Auto-completion**: Simulation tự động kết thúc khi cả hai Master hoàn thành

Test case này mô phỏng một pattern phổ biến trong các hệ thống SoC, nơi một processor tính toán và ghi kết quả vào shared memory, và processor khác đọc kết quả đó để thực hiện các operations tiếp theo. Điều này rất quan trọng trong các hệ thống multi-processor với shared memory architecture.

