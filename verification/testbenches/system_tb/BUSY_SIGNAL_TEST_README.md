# Busy Signal Testbench

## 📋 Tổng Quan

Testbench này kiểm tra cờ **Busy** từ các RISC-V Master cores. Cờ Busy báo hiệu khi core đang bận xử lý (có transaction đang diễn ra trên AXI bus hoặc register file đang được truy cập).

## 🎯 Mục Đích

- **Kiểm tra Busy Signal**: Xác minh cờ Busy hoạt động đúng
- **Monitor Busy Transitions**: Theo dõi các chuyển đổi trạng thái busy (0→1, 1→0)
- **Correlation với Transactions**: Kiểm tra busy signal có được assert đúng lúc khi có instruction fetch, data read/write
- **Thống kê**: Đếm số cycles busy, số transitions, và correlation với các transactions

## 📁 File

- **Testbench**: `verification/testbenches/system_tb/busy_signal_tb.v`
- **DUT**: `src/systems/dual_serv_axi_system.v`
- **AXI Bridge**: `src/axi_bridge/serv_axi_wrapper.v`

## 🔧 Cấu Hình

```verilog
- Clock Period: 10ns (100MHz)
- Simulation Time: 10000 cycles (10us)
- RAM Init: simple_test.hex
- Verbose Mode: 1 (detailed output)
```

## 🔄 Logic Busy Signal

Cờ `Busy` được tính toán trong `serv_axi_wrapper.v`:

```verilog
wire instr_busy = wb_ibus_cyc || instr_read_pending;
wire data_busy  = wb_dbus_cyc || data_read_pending || data_write_pending;
wire rf_busy    = rf_rreq || rf_wreq;  // Register file access

assign o_busy = instr_busy || data_busy || rf_busy;
```

Core được coi là **busy** khi:
1. **Instruction Bus Active**: `wb_ibus_cyc` hoặc có instruction read pending
2. **Data Bus Active**: `wb_dbus_cyc` hoặc có data read/write pending
3. **Register File Active**: Register file đang được đọc/ghi (`rf_rreq` hoặc `rf_wreq`)

## 📊 Test Cases

### TEST 1: Busy Signal Toggling
- **Mục đích**: Kiểm tra busy signals có chuyển đổi trạng thái không
- **Pass**: Cả SERV0 và SERV1 đều có busy transitions > 0
- **Fail**: Không có busy transitions

### TEST 2: SERV0 Busy During Instruction Fetch
- **Mục đích**: Kiểm tra busy được assert khi có instruction fetch
- **Pass**: Có instruction fetches và busy được assert trong ít nhất một lần
- **Fail**: Không có instruction fetches hoặc busy không được assert

### TEST 3: SERV1 Busy During Instruction Fetch
- **Mục đích**: Tương tự TEST 2 nhưng cho SERV1
- **Pass**: Có instruction fetches và busy được assert trong ít nhất một lần
- **Fail**: Không có instruction fetches hoặc busy không được assert

## 📈 Kết Quả Test

Testbench in ra các thông tin sau:

### SERV0 Statistics
```
Busy cycles: [số cycles] / [tổng cycles] ([tỷ lệ %])
Busy transitions: [số transitions]
Instruction fetches: [số fetches]
Data reads: [số reads]
Data writes: [số writes]
Busy during instr: [số lần] / [tổng fetches] ([tỷ lệ %])
Busy during data: [số lần] / [tổng data ops] ([tỷ lệ %])
```

### SERV1 Statistics
```
(Tương tự SERV0)
```

### Test Status
```
TEST 1: PASS/FAIL - Busy signals are toggling
TEST 2: PASS/FAIL - SERV0 busy during instruction fetches
TEST 3: PASS/FAIL - SERV1 busy during instruction fetches

SUMMARY:
Total tests: [số tests]
Passed: [số passed]
Failed: [số failed]
STATUS: ALL TESTS PASSED / SOME TESTS FAILED
```

## 🚀 Cách Chạy

### Cách 1: Sử dụng Batch Script (Windows - Khuyến nghị)

```batch
cd sim/modelsim/AXI_Interconnect
run_busy_signal_tb.bat
```

Script sẽ tự động:
- Compile tất cả dependencies
- Compile testbench
- Chạy simulation
- Hiển thị kết quả

### Cách 2: Sử dụng TCL Script từ ModelSim

**Từ ModelSim GUI:**
```
File -> Open -> AXI_Project.mpf
Tools -> TCL -> Execute Macro -> chọn run_busy_signal_tb.tcl
```

**Từ ModelSim Command Line:**
```tcl
cd sim/modelsim/AXI_Interconnect
do run_busy_signal_tb.tcl
```

**Từ Windows Command Prompt:**
```batch
cd sim/modelsim/AXI_Interconnect
vsim -c -do "run_busy_signal_tb.tcl"
```

### Cách 3: Compile và Run thủ công

```tcl
# Initialize work library
vlib work
vmap work work

# Set include directories
set INCDIR "+incdir+../../src +incdir+../../src/cores +incdir+../../src/cores/serv/rtl +incdir+../../src/axi_interconnect/rtl/core"

# Compile SERV core (minimal set)
vlog -work work $INCDIR ../../src/cores/serv/rtl/serv_*.v

# Compile AXI Interconnect
vlog -work work $INCDIR ../../src/axi_interconnect/rtl/core/*.v
vlog -work work $INCDIR ../../src/axi_interconnect/rtl/**/*.v

# Compile AXI Bridge
vlog -work work $INCDIR ../../src/axi_bridge/serv_axi_wrapper.v

# Compile Peripherals
vlog -work work $INCDIR ../../src/peripherals/axi_lite/*.v

# Compile System
vlog -work work $INCDIR ../../src/systems/dual_serv_axi_system.v

# Compile Testbench
vlog -work work $INCDIR ../../verification/testbenches/system_tb/busy_signal_tb.v

# Run simulation
vsim -voptargs="+acc" work.busy_signal_tb
run 10000ns
```

### Kết Quả Mẫu

```
[100000] ========================================
[100000] BUSY SIGNAL TEST STARTED
[100000] ========================================

[100000] [SERV0] Busy transition: 0 -> 1
[100010] [SERV0] Instruction fetch: Addr=0x00000000, Busy=1
[100020] [SERV0] Busy transition: 1 -> 0
...

[101000] ========================================
[101000] BUSY SIGNAL TEST RESULTS
[101000] ========================================

--- SERV0 (Core 0) ---
Busy cycles: 5234 / 10000 (52.3%)
Busy transitions: 124
Instruction fetches: 45
Data reads: 12
Data writes: 3
Busy during instr: 45 / 45 (100.0%)
Busy during data: 15 / 15 (100.0%)

--- SERV1 (Core 1) ---
Busy cycles: 4892 / 10000 (48.9%)
Busy transitions: 118
Instruction fetches: 42
Data reads: 10
Data writes: 2
Busy during instr: 42 / 42 (100.0%)
Busy during data: 12 / 12 (100.0%)

--- TEST STATUS ---
TEST 1: PASS - Busy signals are toggling
TEST 2: PASS - SERV0 busy during instruction fetches
TEST 3: PASS - SERV1 busy during instruction fetches

--- SUMMARY ---
Total tests: 3
Passed: 3
Failed: 0
STATUS: ALL TESTS PASSED
```

## 🔍 Giải Thích Kết Quả

### Busy Cycles Percentage
- **52.3%**: Core dành 52.3% thời gian ở trạng thái busy
- Điều này là bình thường vì core cần thời gian để fetch instructions và xử lý

### Busy Transitions
- **124 transitions**: Busy signal chuyển đổi 124 lần (0→1 hoặc 1→0)
- Số transitions cao cho thấy core hoạt động tích cực

### Busy During Transactions
- **100.0%**: Busy được assert trong 100% các instruction fetches
- Điều này cho thấy logic busy hoạt động đúng - core luôn busy khi fetch instruction

## 📝 Lưu Ý

1. **Busy Signal là Combinational**: Busy signal được tính toán từ các tín hiệu combinational, có thể có glitch nếu cần. Nếu muốn stable, có thể register nó.

2. **Busy During Transactions**: Không phải 100% các transactions đều có busy asserted ngay lập tức. Busy có thể được assert trước khi transaction bắt đầu (khi có pending) và deassert sau khi transaction hoàn thành.

3. **Register File Busy**: Busy cũng được assert khi register file đang được truy cập, không chỉ khi có AXI transactions.

## 🔗 Liên Kết

- [AXI Bridge Implementation](../../src/axi_bridge/serv_axi_wrapper.v)
- [Dual SERV AXI System](../../src/systems/dual_serv_axi_system.v)
- [System Testbench README](README.md)

