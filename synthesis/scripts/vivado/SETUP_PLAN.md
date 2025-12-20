# Kế Hoạch: Tạo Vivado Project cho KV260 - Dual RISC-V System

## Mục Tiêu

Tạo Vivado project để simulate `dual_riscv_axi_system` trên target hardware KV260 (Xilinx Kria KV260 Vision AI Starter Kit).

## Target Hardware

- **Board**: Xilinx Kria KV260 Vision AI Starter Kit
- **Device**: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
- **Purpose**: Simulation (không synthesis)

## Các Bước Thực Hiện

### Bước 1: Tạo Vivado Project

**File**: `synthesis/scripts/vivado/create_kv260_project.tcl`

**Chức năng**:
- Tạo project mới với tên `kv260_dual_riscv`
- Set target device: xczu5ev-sfvc784-1-e
- Set project properties (Verilog, XSim simulator)
- Add tất cả source files theo dependency order
- Add testbench files
- Set include directories
- Update compile order

**Cách chạy**:
```tcl
cd C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado
source create_kv260_project.tcl
```

### Bước 2: Add Source Files

Script sẽ tự động add các files theo thứ tự:

1. **SERV RISC-V Core** (16 files)
   - serv_alu.v, serv_bufreg.v, serv_ctrl.v, serv_top.v, etc.

2. **Wishbone to AXI Converters** (2 files)
   - wb2axi_read.v, wb2axi_write.v

3. **SERV AXI Wrapper & Adapter** (2 files)
   - serv_axi_wrapper.v, serv_axi_dualbus_adapter.v

4. **AXI Interconnect Components** (~30+ files)
   - Utils, Handshake, Buffers
   - Datapath (MUX/DEMUX)
   - Decoders, Arbitration
   - Channel Controllers

5. **AXI Interconnect Core** (1 file)
   - AXI_Interconnect.v

6. **AXI-Lite Peripherals** (4 files)
   - axi_lite_ram.v, axi_lite_gpio.v, axi_lite_uart.v, axi_lite_spi.v

7. **Top System Module** (1 file)
   - dual_riscv_axi_system.v (set as top)

8. **Testbench** (1 file)
   - dual_riscv_system_tb.v (set as simulation top)

### Bước 3: Setup Simulation

**File**: `synthesis/scripts/vivado/run_simulation.tcl`

**Chức năng**:
- Set simulation properties
- Set testbench generics (RAM_INIT_HEX)
- Launch simulation

**Cách chạy**:
```tcl
source run_simulation.tcl
```

### Bước 4: Verify và Test

1. **Check compilation**:
   - Run Synthesis để kiểm tra syntax errors
   - Hoặc: `synth_design -rtl -name rtl_1`

2. **Run simulation**:
   - GUI: `Flow -> Run Simulation -> Run Behavioral Simulation`
   - TCL: `launch_simulation`

3. **Expected results**:
   - 2 SERV RISC-V cores execute instructions
   - UART output: "Hi!\n"
   - GPIO output: 0xDEADBEEF
   - AXI transactions visible in waveform

## Files Được Tạo

1. `synthesis/scripts/vivado/create_kv260_project.tcl` - Script tạo project
2. `synthesis/scripts/vivado/run_simulation.tcl` - Script chạy simulation
3. `synthesis/scripts/vivado/README.md` - Hướng dẫn sử dụng
4. `synthesis/scripts/vivado/SETUP_PLAN.md` - Kế hoạch này

## Project Structure

Sau khi chạy script, project sẽ được tạo tại:
```
synthesis/scripts/vivado/kv260_dual_riscv/
├── kv260_dual_riscv.xpr          # Vivado project file
├── kv260_dual_riscv.srcs/        # Source files
│   ├── sources_1/                # Design sources
│   └── sim_1/                    # Simulation sources
└── kv260_dual_riscv.sim/         # Simulation results
```

## Lưu Ý

1. **Simulation only**: Project này chỉ setup cho simulation, không có constraints file
2. **Device selection**: KV260 device được set nhưng chỉ dùng cho simulation
3. **File types**: Tất cả files là Verilog (.v), không dùng SystemVerilog (.sv) để tương thích tốt hơn
4. **Test program**: Mặc định dùng `simple_test.hex`, có thể thay đổi trong run_simulation.tcl

## Troubleshooting

### Lỗi: "Project already exists"
- Script sẽ tự động overwrite
- Hoặc xóa thư mục `kv260_dual_riscv/` trước

### Lỗi: "File not found"
- Kiểm tra đường dẫn trong script
- Đảm bảo repository đã clone đầy đủ

### Lỗi compilation
- Kiểm tra thứ tự compile
- Xem messages trong Vivado console

## Next Steps (Optional)

1. **Add constraints file** (.xdc) nếu cần synthesis
2. **Create block design** nếu cần tích hợp với Zynq PS
3. **Add IP cores** nếu cần thêm peripherals
4. **Setup timing constraints** nếu cần synthesis

## Kết Quả Mong Đợi

Sau khi hoàn thành:
- ✅ Vivado project được tạo với đầy đủ source files
- ✅ Testbench được setup sẵn
- ✅ Có thể chạy simulation ngay
- ✅ Waveform hiển thị đầy đủ signals
- ✅ Simulation chạy thành công với test program

