# Vivado Project Setup for KV260

## Tổng Quan

Scripts để tạo và quản lý Vivado project cho KV260 với `dual_riscv_axi_system`.

## Target Hardware

- **Board**: Xilinx Kria KV260 Vision AI Starter Kit
- **Device**: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
- **Purpose**: Simulation

## Files

1. `create_kv260_project.tcl` - Tạo Vivado project và add tất cả source files
2. `run_simulation.tcl` - Chạy simulation với testbench
3. `README.md` - Hướng dẫn này

## Cách Sử Dụng

### Bước 1: Tạo Project

Mở Vivado và trong TCL Console:

```tcl
cd C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado
source create_kv260_project.tcl
```

Script sẽ:
- Tạo project mới: `kv260_dual_riscv`
- Set target device: xczu5ev-sfvc784-1-e (KV260)
- Add tất cả source files
- Add testbench
- Set compile order

### Bước 2: Kiểm Tra Compilation

```tcl
# Check for syntax errors
synth_design -rtl -name rtl_1
```

Hoặc trong GUI: `Flow -> Run Synthesis`

### Bước 3: Chạy Simulation

```tcl
source run_simulation.tcl
```

Hoặc trong GUI:
1. `Flow -> Run Simulation -> Run Behavioral Simulation`
2. Hoặc click "Run Simulation" button

## Project Structure

```
synthesis/scripts/vivado/
├── kv260_dual_riscv/          # Project directory (created by script)
│   ├── kv260_dual_riscv.xpr   # Vivado project file
│   ├── kv260_dual_riscv.srcs/ # Source files
│   └── kv260_dual_riscv.sim/  # Simulation files
├── create_kv260_project.tcl   # Create project script
├── run_simulation.tcl         # Run simulation script
└── README.md                  # This file
```

## Source Files Added

Script sẽ add các files theo thứ tự dependency:

1. SERV RISC-V Core (16 files)
2. Wishbone to AXI Converters (2 files)
3. SERV AXI Wrapper & Adapter (2 files)
4. AXI Interconnect components (~30+ files)
5. AXI-Lite Peripherals (4 files)
6. Top System Module (1 file)
7. Testbench (1 file)

## Simulation

### Testbench

- File: `verification/testbenches/system_tb/dual_riscv_system_tb.v`
- Top module: `dual_riscv_system_tb`
- Test program: `verification/programs/simple_test.hex`

### Expected Results

- 2 SERV RISC-V cores execute instructions
- UART output: "Hi!\n"
- GPIO output: 0xDEADBEEF
- AXI transactions visible in waveform

## Troubleshooting

### Lỗi: "Project already exists"
- Script sẽ tự động overwrite project cũ
- Hoặc xóa thư mục `kv260_dual_riscv/` trước

### Lỗi: "File not found"
- Kiểm tra đường dẫn trong script
- Đảm bảo bạn đã clone đầy đủ repository

### Lỗi khi compile
- Kiểm tra thứ tự compile (dependencies)
- Xem messages trong Vivado console

## Notes

- Project chỉ setup cho simulation, không có constraints
- Nếu cần synthesis, thêm constraints file (.xdc)
- KV260 device được set nhưng chỉ dùng cho simulation

## Xem Thêm

- Architecture docs: `docs/architecture/DUAL_RISCV_2M4S_HARDWARE_ARCHITECTURE.md`
- Testbench docs: `verification/testbenches/system_tb/README.md`

