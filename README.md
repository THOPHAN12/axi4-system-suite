# AXI4 System Suite

## 📋 Tổng Quan Dự Án

**AXI4 System Suite** là một hệ thống SoC (System-on-Chip) tích hợp các bộ xử lý RISC-V kết nối với các thiết bị ngoại vi thông qua AXI4 Interconnect. Dự án cung cấp một nền tảng hoàn chỉnh để phát triển, mô phỏng, kiểm thử và triển khai các hệ thống nhúng dựa trên RISC-V và AXI4.

### 🎯 Tính Năng Chính

- **AXI4 Interconnect**: Hỗ trợ 2 Master × 4 Slave với các thuật toán arbitration (Fixed Priority, Round-Robin, QoS-based)
- **RISC-V Cores**: Tích hợp nhiều loại RISC-V cores:
  - SERV (bit-serial architecture)
  - fRISC-V
  - 5-stage Pipeline RISC-V
- **AXI Bridges**: Chuyển đổi giữa Wishbone và AXI4 protocols
- **Peripherals**: RAM, GPIO, UART, SPI (AXI-Lite)
- **Verification**: Testbenches đầy đủ cho từng module và hệ thống
- **Simulation**: Hỗ trợ ModelSim, Quartus, và Verilator
- **FPGA Deployment**: Hỗ trợ triển khai lên FPGA (Xilinx KV260)

### 🏗️ Kiến Trúc Hệ Thống

Hệ thống điển hình bao gồm:
- **2 RISC-V Cores** (SERV) với Instruction Bus và Data Bus riêng biệt
- **AXI Master Aggregators** để gộp các bus từ mỗi core
- **AXI Interconnect** (2M × 4S) với Round-Robin arbitration
- **4 Slaves**: RAM, GPIO, UART, SPI

```
┌─────────────┐         ┌─────────────┐
│ SERV Core 0 │         │ SERV Core 1 │
└──────┬──────┘         └──────┬──────┘
       │                       │
       │ AXI Wrappers          │ AXI Wrappers
       ▼                       ▼
┌─────────────────────────────────────┐
│     AXI Interconnect (2M × 4S)      │
│      Round-Robin Arbitration        │
└──────┬──────┬──────┬──────┬─────────┘
       │      │      │      │
       ▼      ▼      ▼      ▼
    ┌────┐ ┌────┐ ┌────┐ ┌────┐
    │RAM │ │GPIO│ │UART│ │SPI │
    └────┘ └────┘ └────┘ └────┘
```

---

## 📂 Cấu Trúc Thư Mục

```
axi4-system-suite/
│
├── src/                          # Source code RTL
│   ├── axi_bridge/              # AXI bridges và wrappers
│   │   ├── serv_axi_wrapper.v
│   │   ├── friscv_axi_wrapper.v
│   │   └── riscv_pipeline_axi_wrapper.v
│   │
│   ├── axi_interconnect/        # AXI Interconnect core
│   │   ├── rtl/
│   │   │   ├── core/            # Core modules (Interconnect, Aggregator)
│   │   │   ├── arbitration/     # Arbitration algorithms
│   │   │   ├── channel_controllers/  # Read/Write channel controllers
│   │   │   ├── datapath/        # Mux/Demux modules
│   │   │   ├── decoders/        # Address decoders
│   │   │   ├── buffers/         # FIFO buffers
│   │   │   ├── handshake/       # Handshake modules
│   │   │   └── utils/           # Utility modules
│   │   └── SystemVerilog/       # SystemVerilog implementations
│   │
│   ├── axi_full/                # AXI4 Full interface modules
│   ├── axi_stream/              # AXI Stream modules
│   │
│   ├── cores/                   # RISC-V processor cores
│   │   ├── serv/                # SERV RISC-V core
│   │   ├── friscv/              # fRISC-V core
│   │   └── riscv-5stage-pipeline/  # 5-stage pipeline RISC-V
│   │
│   ├── peripherals/             # Peripheral modules
│   │   └── axi_lite/            # AXI-Lite peripherals
│   │       ├── axi_lite_ram.v
│   │       ├── axi_lite_gpio.v
│   │       ├── axi_lite_uart.v
│   │       └── axi_lite_spi.v
│   │
│   └── systems/                 # Top-level system modules
│       ├── dual_serv_axi_system.v
│       ├── dual_pipeline_serv_axi_system.v
│       └── dual_axi_shell.v
│
├── verification/                # Verification và testbenches
│   ├── testbenches/             # Testbench modules
│   │   ├── interconnect_tb/     # AXI Interconnect testbenches
│   │   ├── system_tb/           # System-level testbenches
│   │   ├── bridge_tb/           # Bridge testbenches
│   │   ├── dual_master_tb/      # Dual master testbenches
│   │   └── simple_*_tb/         # Simple testbenches
│   │
│   ├── programs/                # Test programs (hex files)
│   │   ├── dual_core_test.hex
│   │   ├── comprehensive_test.hex
│   │   └── ...
│   │
│   ├── testcases/               # Test case scripts
│   ├── coverage/                # Coverage reports
│   └── formal/                  # Formal verification
│
├── sim/                         # Simulation files
│   ├── modelsim/                # ModelSim simulation
│   │   ├── compile_*.tcl        # Compilation scripts
│   │   ├── simulate_*.tcl       # Simulation scripts
│   │   └── wave_*.do            # Waveform scripts
│   │
│   ├── quartus/                 # Quartus simulation
│   │   └── AXI_PROJECT.qws
│   │
│   ├── verilator/               # Verilator simulation
│   │   ├── compile_verilator.sh
│   │   ├── run_simulation.sh
│   │   └── INSTALL_GUIDE.md
│   │
│   ├── logs/                    # Simulation logs
│   └── waveforms/               # Waveform files
│
├── synthesis/                   # Synthesis scripts và outputs
│   ├── scripts/
│   │   ├── quartus/             # Quartus synthesis scripts
│   │   ├── vivado/              # Vivado synthesis scripts
│   │   └── synplify/            # Synplify synthesis scripts
│   │
│   ├── constraints/             # Timing constraints
│   ├── netlists/                # Synthesized netlists
│   └── reports/                 # Synthesis reports
│
├── deployment/                  # FPGA deployment
│   └── boards/                  # Board-specific configurations
│       └── kv260/               # Xilinx Kria KV260
│           ├── scripts/         # Build scripts
│           ├── constraints/     # Pin constraints
│           ├── bitstreams/      # Generated bitstreams
│           ├── reports/         # Implementation reports
│           └── logs/            # Build logs
│
├── software/                    # Embedded software
│   ├── applications/            # User applications
│   ├── drivers/                 # Device drivers
│   │   ├── baremetal/           # Bare-metal drivers
│   │   └── linux/               # Linux kernel drivers
│   └── scripts/                 # Build scripts
│
├── docs/                        # Documentation
│   ├── architecture/            # Architecture documentation
│   │   ├── DUAL_RISCV_2M4S_HARDWARE_ARCHITECTURE.md
│   │   └── SYSTEM_ARCHITECTURE.png
│   │
│   ├── user_guides/             # User guides
│   ├── specifications/          # Technical specifications
│   ├── design_notes/            # Design notes
│   ├── api_reference/           # API reference
│   └── changelog/               # Change logs
│
├── tools/                       # Utilities và tools
│   ├── scripts/                 # Helper scripts
│   ├── lint/                    # Linting tools
│   └── utilities/               # Utility programs
│
├── build/                       # Build artifacts
│   ├── cache/
│   ├── obj/
│   └── work/
│
└── Test/                        # Test files
    └── test*.md
```

---

## 🚀 Bắt Đầu Nhanh

### Yêu Cầu

- **Simulation Tools**: ModelSim/QuestaSim, Quartus, hoặc Verilator
- **Synthesis Tools**: Quartus (Intel) hoặc Vivado (Xilinx)
- **RISC-V Toolchain**: Để compile software (nếu cần)

### Chạy Simulation

#### ModelSim:
```bash
cd sim/modelsim
# Xem QUICK_START.md để biết chi tiết
```

#### Verilator:
```bash
cd sim/verilator
./compile_verilator.sh
./run_simulation.sh
```

### Synthesis

#### Quartus:
```bash
cd synthesis/scripts/quartus
# Chạy synthesis script
```

#### Vivado:
```bash
cd synthesis/scripts/vivado
# Chạy synthesis script
```

### FPGA Deployment

#### KV260:
```bash
cd deployment/boards/kv260
# Xem README.md trong thư mục này
```

---

## 📚 Tài Liệu

- **Kiến trúc hệ thống**: Xem `docs/architecture/`
- **Hướng dẫn sử dụng**: Xem `docs/user_guides/`
- **API Reference**: Xem `docs/api_reference/`
- **Tài liệu tổng hợp**: Xem `docs/README.md`

---

## 🔧 Các Module Chính

### AXI Interconnect
- **Location**: `src/axi_interconnect/rtl/core/`
- **Features**:
  - 2 Master × 4 Slave configuration
  - Multiple arbitration modes (Fixed Priority, Round-Robin, QoS)
  - Full AXI4 Read/Write support
  - Address decoding và routing

### RISC-V Cores
- **SERV**: `src/cores/serv/` - Bit-serial RISC-V implementation
- **fRISC-V**: `src/cores/friscv/`
- **5-stage Pipeline**: `src/cores/riscv-5stage-pipeline/`

### AXI Bridges
- **Location**: `src/axi_bridge/`
- Chuyển đổi Wishbone → AXI4 cho các RISC-V cores

### Peripherals
- **RAM**: `src/peripherals/axi_lite/axi_lite_ram.v`
- **GPIO**: `src/peripherals/axi_lite/axi_lite_gpio.v`
- **UART**: `src/peripherals/axi_lite/axi_lite_uart.v`
- **SPI**: `src/peripherals/axi_lite/axi_lite_spi.v`

---

## 🧪 Verification

Dự án bao gồm testbenches đầy đủ cho:
- AXI Interconnect và các sub-modules
- AXI Bridges
- System-level integration
- Arbitration algorithms
- Channel controllers

Xem `verification/testbenches/` để biết chi tiết.

---

## 📝 License

Xem LICENSE file trong từng module để biết thông tin license cụ thể.

---

## 🤝 Đóng Góp

Dự án này đang trong quá trình phát triển. Mọi đóng góp đều được chào đón!

---

## 📞 Liên Hệ

Để biết thêm thông tin, vui lòng xem tài liệu trong thư mục `docs/`.

---

**Last Updated**: 2025-01-XX














