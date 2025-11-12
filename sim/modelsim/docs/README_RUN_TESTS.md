# Hướng Dẫn Chạy Testbench - Quick Start

## Cách Nhanh Nhất (Windows)

### 1. Chạy RISC-V Testbench

```bash
# Mở Command Prompt hoặc PowerShell
cd D:\AXI\sim\modelsim
run_riscv.bat
```

Hoặc chạy trực tiếp:
```bash
cd D:\AXI\sim\modelsim
vsim -c -do "source run_riscv_test.tcl; quit -f"
```

### 2. Chạy Dual Master System IP Testbench

```bash
cd D:\AXI\sim\modelsim
run_dual_master_ip_test.bat
```

## Cách Chạy Chi Tiết

### Option 1: Command Line (Khuyến nghị)

```bash
# 1. Di chuyển vào thư mục modelsim
cd D:\AXI\sim\modelsim

# 2. Chạy RISC-V testbench
vsim -c -do "source run_riscv_test.tcl; quit -f"

# 3. Xem kết quả trong console
```

### Option 2: ModelSim GUI

1. Mở ModelSim
2. Trong ModelSim console:
   ```tcl
   cd D:/AXI/sim/modelsim
   source run_riscv_test.tcl
   ```
3. Xem waveform trong ModelSim

### Option 3: Sử dụng Batch File (Windows)

Double-click vào:
- `sim/modelsim/run_riscv.bat` - Chạy RISC-V testbench
- `sim/modelsim/run_dual_master_ip_test.bat` - Chạy Dual Master System IP testbench

## Kết Quả

Sau khi chạy thành công, bạn sẽ thấy:

```
INFO: Loaded memory from file: ../../sim/modelsim/test_program_simple.hex
INFO: Memory[0] = 0x00010037, Memory[1] = 0x00508093, Memory[2] = 0x00102023
=========================================
SERV AXI System Testbench Started
=========================================
[455000] Instruction Fetch: Address = 0x00000000
[465000] Instruction Read: Data = 0x00010037
[1175000] Instruction Fetch: Address = 0x00000004
[1185000] Instruction Read: Data = 0x00508093
...
```

## Xem Waveform

Sau khi simulation chạy xong, file waveform được tạo tự động:
- `serv_axi_system_tb.vcd` - RISC-V testbench
- `dual_master_system_ip_tb.vcd` - Dual Master System IP testbench
- `serv_axi_system_ip_tb.vcd` - SERV AXI System IP testbench
- `alu_master_system_tb_enhanced.vcd` - ALU enhanced testbench

**Lưu ý**: Các file VCD này có thể bị xóa sau khi cleanup. Chúng sẽ được tạo lại khi chạy simulation.

Xem bằng GTKWave:
```bash
gtkwave serv_axi_system_tb.vcd
```

Hoặc trong ModelSim:
```tcl
vsim -view serv_axi_system_tb.vcd
```

## Các Testbench Có Sẵn

1. **RISC-V System** (`run_riscv_test.tcl`)
   - Test toàn bộ SERV RISC-V processor
   - Load test program từ hex file
   - Test instruction fetch và data access

2. **Dual Master System IP** (`run_dual_master_ip_test.tcl`) ⭐ **MỚI**
   - Test complete IP module (SERV + ALU Master)
   - Integrated memory slaves
   - No external connections needed

3. **SERV AXI System IP** (`run_ip_test.tcl`)
   - Test SERV RISC-V IP module
   - Integrated instruction và data memory

4. **Dual Master System** (`run_dual_master_test.tcl`)
   - Test dual master system (SERV + ALU)
   - Test 4 memory slaves
   - Test address routing

5. **ALU Master Enhanced** (`run_wrapper_test.tcl`)
   - Test ALU masters với enhanced testbench
   - Test multiple masters và slaves
   - Test data integrity
   - Xem chi tiết trong phần [ALU Master System Testbench](#alu-master-system-testbench)

6. **ALU Master Simple** (`run_simple_test.tcl`)
   - Test routing cơ bản
   - Sử dụng Simple AXI Master Test

## ALU Master System Testbench

### Mục đích
Testbench này kiểm tra xem wrapper `alu_master_system` có truyền dữ liệu đúng qua AXI Interconnect hay không.

### Files liên quan
- `tb/wrapper_tb/alu_master_system_tb.v` - Testbench cơ bản
- `tb/wrapper_tb/alu_master_system_tb_enhanced.v` - Testbench nâng cao (có monitoring)
- `sim/modelsim/run_wrapper_test.tcl` - Script TCL để compile và chạy
- `sim/modelsim/run_wrapper_test.bat` - Batch file để chạy trên Windows

### Cách chạy

**Cách 1: Dùng Batch File (Windows)**
```bash
cd sim/modelsim
run_wrapper_test.bat
```

**Cách 2: Dùng ModelSim TCL Console**
```tcl
cd sim/modelsim
source run_wrapper_test.tcl
```

**Cách 3: Dùng Command Line**
```bash
cd sim/modelsim
vsim -c -do "source run_wrapper_test.tcl; quit -f"
```

### Tính năng Testbench Enhanced

Testbench enhanced (`alu_master_system_tb_enhanced.v`) có các tính năng:

1. **Monitoring AXI Transactions**:
   - Monitor tất cả AXI channels (AW, WD, BR, AR, RD)
   - Hiển thị address, data, và control signals
   - Verify routing đến đúng slave

2. **Automatic Test Checking**:
   - Tự động kiểm tra master completion
   - Timeout detection
   - Test summary với pass/fail count

3. **Waveform Dump**:
   - Tự động tạo VCD file
   - Có thể xem bằng GTKWave

### Các Test Cases

1. **Test 1**: Master 0 → Slave 0
   - Kiểm tra Master 0 có thể truy cập Slave 0 không
   - Verify address routing

2. **Test 2**: Master 1 → Slave 2
   - Kiểm tra Master 1 có thể truy cập Slave 2 không
   - Verify address routing

3. **Test 3**: Both Masters Simultaneously
   - Kiểm tra arbitration khi cả 2 masters cùng truy cập
   - Verify không có conflict

4. **Test 4**: Master 0 → Slave 1
   - Kiểm tra Master 0 có thể truy cập Slave 1 không

5. **Test 5**: Master 1 → Slave 3
   - Kiểm tra Master 1 có thể truy cập Slave 3 không

### Kết quả mong đợi

Testbench Enhanced sẽ hiển thị:
```
============================================================================
Test Summary
============================================================================
Total Tests: 5
Passed:      5
Failed:      0
Status:      ✓ ALL TESTS PASSED
============================================================================
```

Monitoring Output sẽ hiển thị:
- M0->AW: Write address từ Master 0
- M0->WD: Write data từ Master 0
- M0<-BR: Write response đến Master 0
- M0->AR: Read address từ Master 0
- M0<-RD: Read data đến Master 0
- Tương tự cho Master 1
- S0<-AW, S1<-AW, S2<-AR, S3<-AR: Routing đến slaves

## Troubleshooting

### Lỗi: "vsim: command not found"
- Đảm bảo ModelSim đã được cài đặt
- Thêm ModelSim vào PATH hoặc sử dụng full path

### Lỗi: "File not found"
- Kiểm tra đang ở đúng thư mục: `D:\AXI\sim\modelsim`
- Kiểm tra file `test_program_simple.hex` có tồn tại

### Lỗi: Compilation errors
- Xem log để biết file nào bị lỗi
- Kiểm tra tất cả source files có tồn tại

### Nếu test timeout:
1. Kiểm tra waveform để xem AXI signals
2. Verify reset đã được release
3. Kiểm tra address routing có đúng không
4. Kiểm tra slave memory có respond không

### Nếu compilation error:
1. Kiểm tra tất cả source files có tồn tại không
2. Kiểm tra đường dẫn trong script
3. Xóa work library và compile lại: `vdel -all`

## Chi Tiết Hơn

Xem [README_MAIN.md](README_MAIN.md) để biết chi tiết về:
- Cấu trúc test program
- Tùy chỉnh testbench
- Monitoring và debugging
