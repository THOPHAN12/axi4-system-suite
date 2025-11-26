# Wrapper Testbenches

## Cấu Trúc Thư Mục

Thư mục này chứa tất cả các testbench và test programs cho wrapper modules. Các file đã được tổ chức theo module để dễ quản lý:

```
tb/wrapper_tb/
├── testbenches/
│   ├── serv/              # SERV RISC-V testbenches
│   │   ├── serv_axi_system_tb.v
│   │   └── serv_axi_system_ip_tb.v
│   └── dual_riscv/        # Dual SERV master testbench
│       └── dual_riscv_axi_system_tb.sv
└── programs/              # Test programs (hex files)
    ├── test_program.hex
    ├── test_program_advanced.hex
    └── simple_test.hex
```

## Testbenches

### SERV RISC-V Testbenches (`testbenches/serv/`)

#### `serv_axi_system_tb.v`
- **Mục đích**: Test SERV RISC-V system với external memory slaves
- **Chức năng**:
  - Test SERV processor với AXI interconnect
  - Test instruction fetch và data access
  - Load test program từ hex file
- **Chạy**: `batch\run_riscv.bat` hoặc `source scripts/sim/run_riscv_test.tcl`

#### `serv_axi_system_ip_tb.v`
- **Mục đích**: Test complete SERV RISC-V IP module
- **Chức năng**:
  - Test self-contained IP module
  - Integrated instruction và data memory
  - No external connections needed
- **Chạy**: `source scripts/sim/run_ip_test.tcl`

### Dual RISC-V Testbench (`testbenches/dual_riscv/`)

#### `dual_riscv_axi_system_tb.sv`
- **Mục đích**: Test hệ thống 2 SERV masters dùng AXI-Lite RAM/GPIO/UART/SPI
- **Chức năng**:
  - Dual SERV cores truy cập chung interconnect
  - Kiểm tra round-robin arbitration và ngoại vi AXI-Lite
- **Chạy**: `source scripts/sim/run_dual_riscv_axi_system.tcl`

## Test Programs (`programs/`)

### `test_program.hex`
- Basic RISC-V test program
- Simple instruction sequence

### `test_program_advanced.hex`
- Advanced RISC-V test program
- More complex instruction sequences
- Multiple memory accesses

### `simple_test.hex`
- Simple test program
- Minimal instruction set

**Lưu ý**: Các testbench thường sử dụng `test_program_simple.hex` từ `sim/modelsim/` directory. Các hex files trong `programs/` có thể được sử dụng cho các test khác.

## Cách Sử Dụng

### Chạy Testbench

#### Từ ModelSim TCL Console:
```tcl
cd D:/AXI/sim/modelsim

# SERV RISC-V
source scripts/sim/run_riscv_test.tcl

# SERV IP
source scripts/sim/run_ip_test.tcl

# Dual RISC-V AXI system
source scripts/sim/run_dual_riscv_axi_system.tcl
```

#### Từ Windows Batch Files:
```batch
cd D:\AXI\sim\modelsim

# SERV RISC-V
batch\run_riscv.bat
```

## Path References

Tất cả TCL scripts đã được cập nhật để sử dụng path mới:
- Testbenches: `tb/wrapper_tb/testbenches/<module>/<testbench>.v`
- Programs: `tb/wrapper_tb/programs/<program>.hex`

## Lưu Ý

- Tất cả testbenches sử dụng relative paths để reference source files
- Test programs (hex files) có thể được reference từ `sim/modelsim/` hoặc `tb/wrapper_tb/programs/`
- Khi thêm testbench mới, đặt vào đúng thư mục module tương ứng
- Khi thêm test program mới, đặt vào `programs/` directory

## File Organization Benefits

1. **Dễ tìm kiếm**: Testbenches được phân loại theo module
2. **Dễ quản lý**: Mỗi module có thư mục riêng
3. **Dễ mở rộng**: Dễ dàng thêm testbench mới vào đúng thư mục
4. **Rõ ràng**: Phân biệt rõ testbenches và test programs

