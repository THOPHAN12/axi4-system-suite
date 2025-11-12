# README - Mô Tả Các Test Cases

## Tổng Quan

File testbench `dual_master_system_ip_tb.v` chứa **20 test cases** để kiểm tra hệ thống Dual Master System IP với các thành phần:
- **SERV RISC-V Core** (Master 0): Xử lý lệnh và truy cập bộ nhớ
- **ALU Master** (Master 1): Thực hiện các phép toán ALU
- **4 Memory Slaves**: Instruction Memory, Data Memory, ALU Memory, Reserved Memory

## Address Mapping

| Slave | Memory Type | Address Range | Master | Mô Tả |
|-------|------------|---------------|--------|-------|
| SLAVE0 | Instruction Memory (ROM) | 0x0000_0000 - 0x3FFF_FFFF | SERV | Bộ nhớ chứa chương trình |
| SLAVE1 | Data Memory (RAM) | 0x4000_0000 - 0x7FFF_FFFF | SERV | Bộ nhớ dữ liệu |
| SLAVE2 | ALU Memory (RAM) | 0x8000_0000 - 0xBFFF_FFFF | ALU Master | Bộ nhớ cho ALU Master |
| SLAVE3 | Reserved Memory (ROM) | 0xC000_0000 - 0xFFFF_FFFF | ALU Master | Bộ nhớ dự phòng |

---

## TEST CASE 1: SERV Master -> Instruction Memory (Read tại Reset PC)

**Mục đích**: Kiểm tra SERV Master có thể đọc instruction từ Instruction Memory tại địa chỉ reset PC.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Instruction Memory (SLAVE0)
- **Địa chỉ**: 0x0000_0000 (Reset PC)
- **Thao tác**: Read
- **Kỳ vọng**: SERV đọc được instruction đầu tiên từ bộ nhớ chương trình

**Pass Criteria**: Quan sát được instruction fetch tại địa chỉ 0x0000_0000

---

## TEST CASE 2: SERV Master -> Instruction Memory (Sequential Read)

**Mục đích**: Kiểm tra SERV Master có thể đọc tuần tự các instruction tiếp theo.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Instruction Memory (SLAVE0)
- **Địa chỉ**: 0x0000_0004 (PC + 4)
- **Thao tác**: Sequential Read
- **Kỳ vọng**: SERV đọc được instruction tiếp theo sau instruction đầu tiên

**Pass Criteria**: Quan sát được sequential instruction fetch tại địa chỉ 0x0000_0004

---

## TEST CASE 3: SERV Master -> Instruction Memory (Read tại offset 8)

**Mục đích**: Kiểm tra SERV Master có thể đọc instruction tại offset 8 bytes.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Instruction Memory (SLAVE0)
- **Địa chỉ**: 0x0000_0008
- **Thao tác**: Read
- **Kỳ vọng**: SERV đọc được instruction tại offset 8 bytes

**Pass Criteria**: Quan sát được instruction fetch tại offset 8

---

## TEST CASE 4: SERV Master -> Data Memory (Write Operation)

**Mục đích**: Kiểm tra SERV Master có thể ghi dữ liệu vào Data Memory.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Data Memory (SLAVE1)
- **Địa chỉ**: 0x4000_0000 (trong phạm vi SLAVE1)
- **Thao tác**: Write
- **Kỳ vọng**: SERV có thể ghi dữ liệu vào Data Memory trong quá trình thực thi chương trình

**Pass Criteria**: Xác nhận khả năng thực hiện write operation (có thể xảy ra trong quá trình thực thi chương trình)

---

## TEST CASE 5: SERV Master -> Data Memory (Read Operation)

**Mục đích**: Kiểm tra SERV Master có thể đọc dữ liệu từ Data Memory.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Data Memory (SLAVE1)
- **Địa chỉ**: 0x4000_0000+ (trong phạm vi SLAVE1)
- **Thao tác**: Read
- **Kỳ vọng**: SERV có thể đọc dữ liệu từ Data Memory

**Pass Criteria**: Xác nhận khả năng thực hiện read operation

---

## TEST CASE 6: ALU Master -> ALU Memory (Write Operation)

**Mục đích**: Kiểm tra ALU Master có thể ghi dữ liệu vào ALU Memory.

**Chi tiết**:
- **Master**: ALU Master
- **Slave**: ALU Memory (SLAVE2)
- **Địa chỉ**: 0x8000_0000 (trong phạm vi SLAVE2)
- **Thao tác**: Write
- **Kỳ vọng**: ALU Master ghi kết quả tính toán vào ALU Memory

**Pass Criteria**: ALU Master hoàn thành write operation và signal `done` được set

**Lưu ý**: Test case này start ALU Master và chờ đến khi hoàn thành

---

## TEST CASE 7: ALU Master -> ALU Memory (Read Operation)

**Mục đích**: Kiểm tra ALU Master có thể đọc dữ liệu từ ALU Memory.

**Chi tiết**:
- **Master**: ALU Master
- **Slave**: ALU Memory (SLAVE2)
- **Địa chỉ**: 0x8000_0000+ (trong phạm vi SLAVE2)
- **Thao tác**: Read
- **Kỳ vọng**: ALU Master đọc được dữ liệu từ ALU Memory để thực hiện phép toán

**Pass Criteria**: ALU Master hoàn thành read operation và signal `done` được set

**Lưu ý**: Test case này chờ ALU Master reset về IDLE trước khi start (tránh timeout)

---

## TEST CASE 8: ALU Master -> Reserved Memory (Read Operation)

**Mục đích**: Kiểm tra ALU Master có thể đọc từ Reserved Memory (ROM).

**Chi tiết**:
- **Master**: ALU Master
- **Slave**: Reserved Memory (SLAVE3)
- **Địa chỉ**: 0xC000_0000 (trong phạm vi SLAVE3)
- **Thao tác**: Read (ROM - chỉ đọc)
- **Kỳ vọng**: ALU Master đọc được dữ liệu từ Reserved Memory

**Pass Criteria**: ALU Master hoàn thành read operation và signal `done` được set

**Lưu ý**: Reserved Memory là ROM nên chỉ hỗ trợ read, không hỗ trợ write

---

## TEST CASE 9: Concurrent Access - SERV(Inst) + ALU Master(ALU Mem)

**Mục đích**: Kiểm tra khả năng truy cập đồng thời của 2 masters vào các slaves khác nhau.

**Chi tiết**:
- **Master 1**: SERV RISC-V Core
  - **Slave**: Instruction Memory (SLAVE0)
  - **Địa chỉ**: 0x0000_0000
  - **Thao tác**: Read (fetch instruction)
- **Master 2**: ALU Master
  - **Slave**: ALU Memory (SLAVE2)
  - **Địa chỉ**: 0x8000_0000
  - **Thao tác**: Read/Write
- **Kỳ vọng**: Cả 2 masters có thể truy cập đồng thời vào các slaves khác nhau mà không xung đột

**Pass Criteria**: ALU Master hoàn thành operation trong khi SERV vẫn tiếp tục fetch instruction

**Lưu ý**: Sử dụng `fork-join` để mô phỏng concurrent access và chờ ALU Master reset trước khi start

---

## TEST CASE 10: Concurrent Access - SERV(Data) + ALU Master(Reserved)

**Mục đích**: Kiểm tra concurrent access khi SERV truy cập Data Memory và ALU Master truy cập Reserved Memory.

**Chi tiết**:
- **Master 1**: SERV RISC-V Core
  - **Slave**: Data Memory (SLAVE1)
  - **Địa chỉ**: 0x4000_0000
  - **Thao tác**: Read/Write
- **Master 2**: ALU Master
  - **Slave**: Reserved Memory (SLAVE3)
  - **Địa chỉ**: 0xC000_0000
  - **Thao tác**: Read
- **Kỳ vọng**: Cả 2 masters truy cập đồng thời vào các slaves khác nhau

**Pass Criteria**: ALU Master hoàn thành operation trong khi SERV tiếp tục truy cập Data Memory

---

## TEST CASE 11: SERV Master -> Instruction Memory (Boundary Address)

**Mục đích**: Kiểm tra SERV Master xử lý địa chỉ gần biên trên của Instruction Memory.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Instruction Memory (SLAVE0)
- **Địa chỉ**: Gần 0x3FFF_FFFF (biên trên của SLAVE0)
- **Thao tác**: Read
- **Kỳ vọng**: SERV có thể truy cập địa chỉ gần biên mà không gặp lỗi

**Pass Criteria**: Xác nhận boundary address handling hoạt động đúng

---

## TEST CASE 12: SERV Master -> Data Memory (Boundary Address)

**Mục đích**: Kiểm tra SERV Master xử lý địa chỉ gần biên trên của Data Memory.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Data Memory (SLAVE1)
- **Địa chỉ**: Gần 0x7FFF_FFFF (biên trên của SLAVE1)
- **Thao tác**: Read/Write
- **Kỳ vọng**: SERV có thể truy cập địa chỉ gần biên mà không gặp lỗi

**Pass Criteria**: Xác nhận Data Memory boundary handling hoạt động đúng

---

## TEST CASE 13: ALU Master -> ALU Memory (Boundary Address)

**Mục đích**: Kiểm tra ALU Master xử lý địa chỉ gần biên trên của ALU Memory.

**Chi tiết**:
- **Master**: ALU Master
- **Slave**: ALU Memory (SLAVE2)
- **Địa chỉ**: Gần 0xBFFF_FFFF (biên trên của SLAVE2)
- **Thao tác**: Read/Write
- **Kỳ vọng**: ALU Master có thể truy cập địa chỉ gần biên mà không gặp lỗi

**Pass Criteria**: ALU Master hoàn thành operation và boundary handling được xác nhận

---

## TEST CASE 14: ALU Master -> Reserved Memory (Boundary Address)

**Mục đích**: Kiểm tra ALU Master xử lý địa chỉ gần biên trên của Reserved Memory.

**Chi tiết**:
- **Master**: ALU Master
- **Slave**: Reserved Memory (SLAVE3)
- **Địa chỉ**: Gần 0xFFFF_FFFF (biên trên của SLAVE3)
- **Thao tác**: Read
- **Kỳ vọng**: ALU Master có thể truy cập địa chỉ gần biên mà không gặp lỗi

**Pass Criteria**: ALU Master hoàn thành operation và Reserved Memory boundary handling được xác nhận

**Lưu ý**: Chờ ALU Master reset trước khi start

---

## TEST CASE 15: Multiple ALU Master Operations (Sequential)

**Mục đích**: Kiểm tra ALU Master có thể thực hiện nhiều operations tuần tự.

**Chi tiết**:
- **Master**: ALU Master
- **Slave**: ALU Memory (SLAVE2)
- **Địa chỉ**: 0x8000_0000+
- **Thao tác**: Multiple writes/reads tuần tự
- **Kỳ vọng**: ALU Master thực hiện được nhiều operations liên tiếp

**Pass Criteria**: ALU Master hoàn thành tất cả sequential operations

---

## TEST CASE 16: SERV Instruction Fetch Sequence

**Mục đích**: Kiểm tra SERV Master fetch tuần tự nhiều instructions.

**Chi tiết**:
- **Master**: SERV RISC-V Core
- **Slave**: Instruction Memory (SLAVE0)
- **Địa chỉ**: 0x0000_0000, 0x0000_0004, 0x0000_0008, ...
- **Thao tác**: Sequential Read
- **Kỳ vọng**: SERV fetch tuần tự các instructions theo thứ tự PC tăng dần

**Pass Criteria**: Quan sát được instruction fetch sequence

---

## TEST CASE 17: Memory Status Signals Verification

**Mục đích**: Kiểm tra các memory status signals có thể đọc được.

**Chi tiết**:
- **Signals**: 
  - `inst_mem_ready`: Instruction Memory ready signal
  - `data_mem_ready`: Data Memory ready signal
  - `alu_mem_ready`: ALU Memory ready signal
  - `reserved_mem_ready`: Reserved Memory ready signal
- **Kỳ vọng**: Tất cả signals có thể đọc được (có thể = 0 hoặc 1 tùy trạng thái)

**Pass Criteria**: Signals có thể đọc được (không yêu cầu phải = 1)

**Lưu ý**: Signals = 0 là bình thường nếu memory chưa được access hoặc chưa sẵn sàng

---

## TEST CASE 18: ALU Master Busy/Done Signal Verification

**Mục đích**: Kiểm tra các control signals của ALU Master hoạt động đúng.

**Chi tiết**:
- **Signals**:
  - `alu_master_busy`: ALU Master đang busy
  - `alu_master_done`: ALU Master đã hoàn thành
- **Kỳ vọng**: 
  - Initial: `busy=0`, `done=0`
  - Sau khi start: `busy=1`, `done=0`
  - Sau khi complete: `busy=1`, `done=1`

**Pass Criteria**: Signals thay đổi đúng theo trạng thái của ALU Master

---

## TEST CASE 19: System Stability Under Continuous Operation

**Mục đích**: Kiểm tra hệ thống ổn định khi hoạt động liên tục.

**Chi tiết**:
- **Hoạt động**:
  - SERV liên tục fetch instructions
  - ALU Master thực hiện 5 operations liên tiếp
- **Kỳ vọng**: Hệ thống vẫn ổn định, không có lỗi hoặc deadlock

**Pass Criteria**: Hệ thống hoạt động ổn định trong suốt quá trình test

**Lưu ý**: Mỗi ALU Master operation được reset trước khi start operation tiếp theo

---

## TEST CASE 20: Complete System Integration Test

**Mục đích**: Kiểm tra toàn bộ hệ thống hoạt động đúng khi tất cả components làm việc cùng nhau.

**Chi tiết**:
- **Hoạt động**:
  - SERV Master -> Instruction Memory (read)
  - SERV Master -> Data Memory (read/write)
  - ALU Master -> ALU Memory (read/write)
  - ALU Master -> Reserved Memory (read)
- **Kỳ vọng**: Tất cả components hoạt động đúng, không xung đột

**Pass Criteria**: Tất cả operations hoàn thành thành công, hệ thống hoạt động ổn định

**Lưu ý**: Test case này chạy comprehensive test với nhiều operations từ cả 2 masters

---

## Tổng Kết

### Test Results Summary

Sau khi chạy test suite, kết quả sẽ hiển thị:
- **Total Test Cases**: 20
- **Passed**: Số test cases pass
- **Failed**: Số test cases fail

### Các Helper Tasks

1. **`wait_alu_master_busy_with_timeout()`**: Chờ ALU Master busy với timeout 10000 cycles
2. **`wait_alu_master_done_with_timeout()`**: Chờ ALU Master done với timeout 10000 cycles
3. **`wait_alu_master_reset()`**: Chờ ALU Master reset về IDLE (done = 0) với timeout 100 cycles

### Lưu Ý Quan Trọng

1. **ALU Master Reset**: Nhiều test cases cần chờ ALU Master reset về IDLE trước khi start lại để tránh timeout
2. **Concurrent Access**: Test cases 9 và 10 sử dụng `fork-join` để mô phỏng concurrent access
3. **Memory Status Signals**: Signals có thể = 0 là bình thường, không phải lỗi
4. **Timeout Protection**: Tất cả wait statements đều có timeout để tránh simulation hang

### Cách Chạy Test

```bash
# Trong ModelSim
vsim -gui work.dual_master_system_ip_tb
run -all
```

Hoặc sử dụng script:
```bash
source sim/modelsim/scripts/sim/run_dual_master_ip_test.tcl
```

---

**Tác giả**: Auto-generated  
**Ngày tạo**: 2024  
**Phiên bản**: 1.0

