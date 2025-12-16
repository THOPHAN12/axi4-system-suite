# Dual RISC-V System Testbench - RAM Communication Test

## 📋 Tổng Quan

Testbench này kiểm tra giao tiếp giữa 2 Master (M0, M1) với RAM Slave thông qua AXI Interconnect. Testbench monitor và thống kê các read/write transactions, đồng thời phát hiện các conflicts trong arbitration.

## 🎯 Mục Đích

- **Kiểm tra Read Transactions**: Master đọc dữ liệu từ RAM thông qua địa chỉ
- **Kiểm tra Write Transactions**: Master ghi dữ liệu vào RAM
- **Monitor Arbitration**: Phát hiện và thống kê conflicts khi cả 2 master cùng request RAM
- **Thống kê Transactions**: Đếm số requests, completed transactions cho mỗi master

## 📁 File

- **Testbench**: `verification/testbenches/system_tb/dual_riscv_system_tb.v`
- **Test Program**: `verification/programs/dual_core_test_clean.hex`
- **Simulation Script**: `sim/modelsim/AXI_Interconnect/run_simulation.tcl`

## 🔧 Cấu Hình

```verilog
- Clock Period: 10ns (100MHz)
- RAM Address Range: 0x00000000 - 0x1FFFFFFF
- Core 0 Reset PC: 0x00000000
- Core 1 Reset PC: 0x00000100
- Simulation Time: ~101ms (10100 cycles)
```

## 🔄 Quá Trình Test

### 1. Reset Sequence
```
1. Hold reset: 10 cycles
2. Release system reset (ARESETN = 1)
3. Release Core 1 reset (Core 1 starts first)
4. Delay 50 cycles
5. Release Core 0 reset (Core 0 starts after)
```

### 2. Transaction Monitoring

#### Read Transactions
- **Address Channel**: Monitor `arvalid`, `arready`, `araddr`
- **Data Channel**: Monitor `rvalid`, `rready`, `rdata`
- Đếm số requests và completed transactions

#### Write Transactions
- **Address Channel**: Monitor `awvalid`, `awready`, `awaddr`
- **Data Channel**: Monitor `wvalid`, `wready`, `wdata`
- **Response Channel**: Monitor `bvalid`, `bready`, `bresp`
- Đếm số requests và completed transactions

#### Arbitration Detection
- Phát hiện khi cả M0 và M1 cùng request RAM addresses
- Xác định winner dựa trên `arready` signal
- Thống kê số conflicts và wins

## 📊 Kết Quả Test

Testbench in ra các thông tin sau:

### READ TRANSACTIONS
```
M0 Read Requests:  [số requests]
M0 Read Completed: [số completed]
M1 Read Requests:  [số requests]
M1 Read Completed: [số completed]
```

### WRITE TRANSACTIONS
```
M0 Write Requests:  [số requests]
M0 Write Completed: [số completed]
M1 Write Requests:  [số requests]
M1 Write Completed: [số completed]
```

### ARBITRATION SUMMARY
```
Total Conflicts: [số conflicts]
M0 Wins: [số lần M0 thắng]
M1 Wins: [số lần M1 thắng]
M0 Win Rate: [tỷ lệ %]
M1 Win Rate: [tỷ lệ %]
```

### LAST TRANSACTIONS
```
M0 Last Read:  Addr=0x[address], Data=0x[data]
M1 Last Read:  Addr=0x[address], Data=0x[data]
M0 Last Write: Addr=0x[address], Data=0x[data]
M1 Last Write: Addr=0x[address], Data=0x[data]
```

### TEST STATUS
- `TEST PASSED`: Cả 2 masters đều giao tiếp thành công với RAM
- `TEST PARTIAL`: Chỉ 1 master giao tiếp với RAM
- `TEST WARNING`: Không có transactions hoặc có vấn đề

## 🚀 Cách Chạy

### Sử dụng ModelSim

```powershell
cd sim/modelsim/AXI_Interconnect
$env:TEST_PROGRAM = "dual_core_test_clean.hex"
vsim -c -do "source run_simulation.tcl"
```

### Kết Quả Mẫu

```
[645000] RAM COMMUNICATION TEST STARTED
[645000] Testing Read/Write transactions between M0/M1 and RAM

[101645000] RAM COMMUNICATION TEST RESULTS
--- READ TRANSACTIONS ---
M0 Read Requests:  2536
M0 Read Completed: 5070
M1 Read Requests:  2535
M1 Read Completed: 5070
--- WRITE TRANSACTIONS ---
M0 Write Requests:  0
M0 Write Completed: 0
M1 Write Requests:  0
M1 Write Completed: 0
--- ARBITRATION SUMMARY ---
Total Conflicts: 2
M0 Wins: 2
M1 Wins: 0
--- LAST TRANSACTIONS ---
M1 Last Read:  Addr=0x00000100, Data=0x400000b7
--- TEST STATUS ---
TEST PASSED: Both masters successfully communicated with RAM
```

## 🔍 Quá Trình Master Đọc Từ RAM

### Bước 1: Read Address Channel (Master → RAM)
```
Master gửi:
  - araddr = 0x00000100 (địa chỉ cần đọc)
  - arvalid = 1 (address valid)
  
RAM nhận:
  - arready = 1 (sẵn sàng nhận address)
  
Handshake: arvalid && arready → RAM nhận được địa chỉ
```

### Bước 2: Read Data Channel (RAM → Master)
```
RAM đọc:
  - mem[0x00000100] = 0x400000b7
  
RAM gửi:
  - rdata = 0x400000b7 (dữ liệu)
  - rvalid = 1 (data valid)
  
Master nhận:
  - rready = 1 (sẵn sàng nhận data)
  
Handshake: rvalid && rready → Master nhận được dữ liệu
```

## 📝 Lưu Ý

1. **Read Completed > Read Requests**: Có thể xảy ra do:
   - Multiple read responses cho cùng một address
   - Các transactions từ slaves khác (GPIO, UART, SPI) cũng được đếm

2. **Write Transactions = 0**: Trong test này, cores chỉ thực hiện instruction fetch (read-only), không có write operations

3. **Arbitration Conflicts**: Số conflicts thấp vì cores không thường xuyên request cùng lúc

## 🔗 Liên Kết

- [AXI Protocol Specification](https://developer.arm.com/documentation/ihi0022/latest/)
- [Dual RISC-V System Architecture](../docs/architecture/DUAL_MASTER_SYSTEM_BLOCK_DIAGRAM.md)
- [Arbitration Modes](../docs/ARBITRATION_MODES.md)
