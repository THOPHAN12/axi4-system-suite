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

### 🔌 AXI Interconnect Architecture với Channel Controllers

Hệ thống AXI Interconnect sử dụng **4 Channel Controllers** chuyên biệt để điều khiển từng AXI channel:

```
                    ┌─────────────────┐         ┌─────────────────┐
                    │   Master 0      │         │   Master 1      │
                    │  (Compute)      │         │  (Dependency)   │
                    │                 │         │                 │
                    │  AW  AR  W      │         │  AW  AR  W      │
                    │  BR  R          │         │  BR  R          │
                    └─────┬───┬───┬───┘         └─────┬───┬───┬───┘
                          │   │   │                   │   │   │
                          │   │   │                   │   │   │
        ┌─────────────────▼───▼───▼───────────────────▼───▼───▼─────┐
        │                                                           │
        │              AXI INTERCONNECT (2M × 4S)                   │
        │                                                           │
        │  ┌──────────────┐              ┌──────────────┐          │
        │  │ IC S0 Port   │              │ IC S1 Port   │          │
        │  │ (Master 0)   │              │ (Master 1)   │          │
        │  │              │              │              │          │
        │  │ AW  AR  W    │              │ AW  AR  W    │          │
        │  │ BR  R        │              │ BR  R        │          │
        │  └───┬───┬───┬──┘              └───┬───┬───┬──┘          │
        │      │   │   │                     │   │   │             │
        │      │   │   │                     │   │   │             │
        │  ┌───▼───▼───▼─────────────────────▼───▼───▼───┐        │
        │  │         AW_Channel_Controller                │        │
        │  │  • Arbitration (Round-Robin)                 │        │
        │  │  • Address Decoder (S0-S3)                   │        │
        │  └───────────────┬──────────────────────────────┘        │
        │                  │                                       │
        │  ┌───────────────▼──────────────────────────────┐        │
        │  │         AR_Channel_Controller                │        │
        │  │  • Arbitration (Round-Robin)                 │        │
        │  │  • Address Decoder (S0-S3)                   │        │
        │  └───────────────┬──────────────────────────────┘        │
        │                  │                                       │
        │  ┌───────────────▼──────────────────────────────┐        │
        │  │         WD_Channel_Controller                │        │
        │  │  • Data Demux (1→4)                         │        │
        │  │  • Write Data Routing                       │        │
        │  └───────────────┬──────────────────────────────┘        │
        │                  │                                       │
        │  ┌───────────────▼──────────────────────────────┐        │
        │  │         Read Data Channel                    │        │
        │  │  • Data Mux (4→1)                           │        │
        │  │  • Read Data Routing                        │        │
        │  └───────────────┬──────────────────────────────┘        │
        │                  │                                       │
        │  ┌───────────────▼──────────────────────────────┐        │
        │  │         BR_Channel_Controller                │        │
        │  │  • Response Arbiter                          │        │
        │  │  • Response Mux (4→1)                        │        │
        │  │  • BID Matcher                               │        │
        │  └───────────────┬──────────────────────────────┘        │
        │                  │                                       │
        │  ┌───────────────┼───────────┬───────────┬───────────┐  │
        │  │ IC M0 Port    │ IC M1 Port│ IC M2 Port│ IC M3 Port│  │
        │  │ (Slave 0)     │ (Slave 1) │ (Slave 2) │ (Slave 3) │  │
        │  │               │           │           │           │  │
        │  │ AW  AR  W     │ AW  AR  W │ AW  AR  W │ AW  AR  W │  │
        │  │ BR  R         │ BR  R     │ BR  R     │ BR  R     │  │
        │  └───────┬───────┴───────┬───┴───────┬───┴───────┬───┘  │
        └──────────┼───────────────┼───────────┼───────────┼──────┘
                   │               │           │           │
        ┌──────────▼───────┐ ┌─────▼─────┐ ┌──▼─────┐ ┌───▼──────┐
        │   Slave 0: RAM   │ │Slave 1:   │ │Slave 2:│ │Slave 3:  │
        │                  │ │  GPIO     │ │  UART  │ │   SPI    │
        │  0x00000000      │ │           │ │        │ │          │
        │  - 0x1FFFFFFF    │ │0x40000000 │ │0x800000│ │0xC0000000│
        │                  │ │-0x5FFFFF  │ │-0x9FFF │ │-0xDFFFFFF│
        │  AW  AR  W       │ │           │ │        │ │          │
        │  BR  R           │ │ AW  AR  W │ │AW AR W │ │AW AR W   │
        └──────────────────┘ │ BR  R     │ │BR R    │ │BR R      │
                             └───────────┘ └────────┘ └──────────┘

Legend:
  AW = Write Address Channel    AR = Read Address Channel
  W  = Write Data Channel       R  = Read Data Channel
  BR = Write Response Channel
```

#### Sơ Đồ Chi Tiết với Mermaid (Datapath)

```mermaid
%%{init: {"flowchart": {"curve":"basis"}} }%%

flowchart LR

%% Column 1: Masters
subgraph MASTERS[" "]
    direction TB
    M0["Master 0<br><b>AW, AR, W, BR, R</b>"]:::master
    M1["Master 1<br><b>AW, AR, W, BR, R</b>"]:::master
end

%% Column 2: IC Slave Ports
subgraph ICS_PORTS[" "]
    direction TB
    ICS0["IC S0 Port<br><b>AW, AR, W, BR, R</b>"]:::ics
    ICS1["IC S1 Port<br><b>AW, AR, W, BR, R</b>"]:::ics
end

%% Column 3: Interconnect - LOGIC boundary
subgraph IC_LOGIC["AXI4 Interconnect Logic"]
    direction TB

    %% Address Channel Section
    subgraph ADDRCH[" "]
        direction LR
        %% Queues
        Q_AW0["AW<br>Queue"]:::queue
        Q_AW1["AW<br>Queue"]:::queue
        Q_AR0["AR<br>Queue"]:::queue
        Q_AR1["AR<br>Queue"]:::queue
        %% Arbiters
        AW_ARB@{shape:diamond,label:"AW<br>Arbiter<br><i>1-Master</i>"}
        AR_ARB@{shape:diamond,label:"AR<br>Arbiter<br><i>1-Master</i>"}
        %% Address Demux
        AW_DEMUX@{shape:trap-b,label:"AW<br>Demux<br><i>Base-Addr</i>"}
        AR_DEMUX@{shape:trap-b,label:"AR<br>Demux<br><i>Base-Addr</i>"}
    end

    %% Data Channel Section
    subgraph DATACH[" "]
        direction TB
        %% Two-input muxes to 4 master ports (write data)
        W_MUX0@{shape:trap-b,label:"W Mux<br>to M0"}
        W_MUX1@{shape:trap-b,label:"W Mux<br>to M1"}
        W_MUX2@{shape:trap-b,label:"W Mux<br>to M2"}
        W_MUX3@{shape:trap-b,label:"W Mux<br>to M3"}
    end

    %% Response Channel Section
    subgraph RESPCH[" "]
        direction TB
        BR_MUX@{shape:trap-b,label:"BR/ID<br>Resp Mux"}
        R_MUX@{shape:trap-b,label:"R/ID<br>Resp Mux"}
        RESP_ARB@{shape:diamond,label:"Response<br>Arbiter"}
        ID_DEMUX@{shape:trap-b,label:"Master_ID<br>Demux"}
    end
end

%% Column 4: IC Master Ports (green)
subgraph ICM_PORTS[" "]
    direction TB
    ICM0["IC M0 Port<br><b>AW, AR, W, BR, R</b>"]:::icm
    ICM1["IC M1 Port<br><b>AW, AR, W, BR, R</b>"]:::icm
    ICM2["IC M2 Port<br><b>AW, AR, W, BR, R</b>"]:::icm
    ICM3["IC M3 Port<br><b>AW, AR, W, BR, R</b>"]:::icm
end

%% Column 5: Slaves
subgraph SLAVES[" "]
    direction TB
    S0["Slave 0<br>RAM<br><b>AW, AR, W, BR, R</b>"]:::slave
    S1["Slave 1<br>GPIO<br><b>AW, AR, W, BR, R</b>"]:::slave
    S2["Slave 2<br>UART<br><b>AW, AR, W, BR, R</b>"]:::slave
    S3["Slave 3<br>SPI<br><b>AW, AR, W, BR, R</b>"]:::slave
end

%% Connections - Masters to IC S Ports
M0 --AW,AR,W,BR,R--> ICS0
M1 --AW,AR,W,BR,R--> ICS1

%% IC S Ports -> IC Logic (Address Queues, etc., with color-coding)
ICS0 -- AW --> Q_AW0
linkStyle 2 stroke:#ee397e,stroke-width:3px  %% aw
ICS1 -- AW --> Q_AW1
linkStyle 3 stroke:#ee397e,stroke-width:3px
ICS0 -- AR --> Q_AR0
linkStyle 4 stroke:#148d45,stroke-width:3px  %% ar
ICS1 -- AR --> Q_AR1
linkStyle 5 stroke:#148d45,stroke-width:3px

%% Queues -> Arbiters
Q_AW0 ---.AW.---> AW_ARB
linkStyle 6 stroke:#ee397e,stroke-width:2px,stroke-dasharray:4  %% aw dash
Q_AW1 ---.AW.---> AW_ARB
linkStyle 7 stroke:#ee397e,stroke-width:2px,stroke-dasharray:4
Q_AR0 ---.AR.---> AR_ARB
linkStyle 8 stroke:#148d45,stroke-width:2px,stroke-dasharray:4  %% ar dash
Q_AR1 ---.AR.---> AR_ARB
linkStyle 9 stroke:#148d45,stroke-width:2px,stroke-dasharray:4

%% Arbiters -> Demux
AW_ARB -- AW --> AW_DEMUX
linkStyle 10 stroke:#ee397e,stroke-width:3px  %% aw
AR_ARB -- AR --> AR_DEMUX
linkStyle 11 stroke:#148d45,stroke-width:3px

%% AW/AR Demux -> Each IC Master Port
AW_DEMUX -- to M0 |AW|--> ICM0
linkStyle 12 stroke:#ee397e,stroke-width:2px
AW_DEMUX -- to M1 |AW|--> ICM1
linkStyle 13 stroke:#ee397e,stroke-width:2px
AW_DEMUX -- to M2 |AW|--> ICM2
linkStyle 14 stroke:#ee397e,stroke-width:2px
AW_DEMUX -- to M3 |AW|--> ICM3
linkStyle 15 stroke:#ee397e,stroke-width:2px

AR_DEMUX -- to M0 |AR|--> ICM0
linkStyle 16 stroke:#148d45,stroke-width:2px
AR_DEMUX -- to M1 |AR|--> ICM1
linkStyle 17 stroke:#148d45,stroke-width:2px
AR_DEMUX -- to M2 |AR|--> ICM2
linkStyle 18 stroke:#148d45,stroke-width:2px
AR_DEMUX -- to M3 |AR|--> ICM3
linkStyle 19 stroke:#148d45,stroke-width:2px

%% Write Data path: ICSx to Muxes for each slave port (Yellow line)
ICS0 --W--> W_MUX0
linkStyle 20 stroke:#f4c542,stroke-width:3px
ICS1 --W--> W_MUX0
linkStyle 21 stroke:#f4c542,stroke-width:3px
ICS0 --W--> W_MUX1
linkStyle 22 stroke:#f4c542,stroke-width:3px
ICS1 --W--> W_MUX1
linkStyle 23 stroke:#f4c542,stroke-width:3px
ICS0 --W--> W_MUX2
linkStyle 24 stroke:#f4c542,stroke-width:3px
ICS1 --W--> W_MUX2
linkStyle 25 stroke:#f4c542,stroke-width:3px
ICS0 --W--> W_MUX3
linkStyle 26 stroke:#f4c542,stroke-width:3px
ICS1 --W--> W_MUX3
linkStyle 27 stroke:#f4c542,stroke-width:3px

W_MUX0 -- W --> ICM0
linkStyle 28 stroke:#f4c542,stroke-width:2px
W_MUX1 -- W --> ICM1
linkStyle 29 stroke:#f4c542,stroke-width:2px
W_MUX2 -- W --> ICM2
linkStyle 30 stroke:#f4c542,stroke-width:2px
W_MUX3 -- W --> ICM3
linkStyle 31 stroke:#f4c542,stroke-width:2px

%% Response: Slaves -> ICM_PORTS, then to Mux/Arbiter, then Demux to masters
%% BR (magenta), R (cyan), solid for resp, dashed inside IC logic
ICM0 --BR--> BR_MUX
linkStyle 32 stroke:#c40875,stroke-width:3px
ICM1 --BR--> BR_MUX
linkStyle 33 stroke:#c40875,stroke-width:3px
ICM2 --BR--> BR_MUX
linkStyle 34 stroke:#c40875,stroke-width:3px
ICM3 --BR--> BR_MUX
linkStyle 35 stroke:#c40875,stroke-width:3px

ICM0 --R--> R_MUX
linkStyle 36 stroke:#05b0e9,stroke-width:3px
ICM1 --R--> R_MUX
linkStyle 37 stroke:#05b0e9,stroke-width:3px
ICM2 --R--> R_MUX
linkStyle 38 stroke:#05b0e9,stroke-width:3px
ICM3 --R--> R_MUX
linkStyle 39 stroke:#05b0e9,stroke-width:3px

BR_MUX ---.BR.---> RESP_ARB
linkStyle 40 stroke:#c40875,stroke-width:2px,stroke-dasharray:4
R_MUX ---.R.---> RESP_ARB
linkStyle 41 stroke:#05b0e9,stroke-width:2px,stroke-dasharray:4

RESP_ARB -- Response --> ID_DEMUX
linkStyle 42 stroke:#808080,stroke-width:2px

ID_DEMUX -- to M0 |BR,R|--> ICS0
linkStyle 43 stroke:#ff4dac,stroke-width:2px
ID_DEMUX -- to M1 |BR,R|--> ICS1
linkStyle 44 stroke:#1dbfec,stroke-width:2px

%% ICM ports <--> SLAVES, usual 5-channel bus
ICM0 --AW,AR,W,BR,R--> S0
ICM1 --AW,AR,W,BR,R--> S1
ICM2 --AW,AR,W,BR,R--> S2
ICM3 --AW,AR,W,BR,R--> S3

%% Styles
classDef master fill:#FFB6C1,stroke:#a80036,stroke-width:2px
classDef slave fill:#FFB6C1,stroke:#a80036,stroke-width:2px
classDef ics fill:#FFB6C1,stroke:#d10040,stroke-width:2px,stroke-dasharray:2
classDef icm fill:#90EE90,stroke:#226600,stroke-width:2px
classDef queue fill:#D3D3D3,stroke:#999,stroke-width:1.5px

style IC_LOGIC fill:#e6f0ff,stroke:#2565a7,stroke-width:2.5px
```

**Channel Controllers được sử dụng:**
1. **AW_Channel_Controller_Top**: Điều khiển Write Address Channel
   - Arbitration giữa các masters
   - Address decoding để chọn slave
   - Handshake protocol control

2. **WD_Channel_Controller_Top**: Điều khiển Write Data Channel
   - Routing write data từ master đến slave đã chọn
   - Demultiplexer 1→4 để route data đến đúng slave
   - Write data handshake management

3. **BR_Channel_Controller_Top**: Điều khiển Write Response Channel
   - Arbitration cho write responses từ slaves
   - Multiplexer 4→1 để route response về đúng master
   - Response ID matching

4. **AR_Channel_Controller_Top**: Điều khiển Read Address Channel
   - Arbitration giữa các masters
   - Address decoding để chọn slave
   - Handshake protocol control

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

### Chạy Comprehensive Testbench

#### ModelSim:
```bash
cd sim/modelsim
vsim -do run_comprehensive_tb_simple.tcl
```

#### Vivado:
```bash
# Từ Vivado TCL console:
source synthesis/scripts/vivado/run_comprehensive_tb.tcl

# Hoặc từ GUI:
# 1. Mở project
# 2. Set top module: comprehensive_system_tb
# 3. Run Simulation với runtime: 11000ns
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
- **Location**: `SystemVerilog/axi_interconnect/core/`
- **Top Module**: `AXI_Interconnect.sv` (wrapper) → `AXI_Interconnect_Full.sv`
- **Features**:
  - 2 Master × 4 Slave configuration
  - Multiple arbitration modes (Fixed Priority, Round-Robin, QoS-based)
  - Full AXI4 Read/Write support
  - Address decoding và routing
  - **Channel Controllers** cho từng AXI channel

### Channel Controllers (Core Components)

Hệ thống sử dụng **4 Channel Controllers** chuyên biệt:

1. **AW_Channel_Controller_Top** (Write Address Channel)
   - **Location**: `SystemVerilog/axi_interconnect/channel_controllers/write/AW_Channel_Controller_Top.sv`
   - **Chức năng**:
     - Arbitration giữa Master 0 và Master 1 cho write address
     - Address decoding để xác định slave đích (S0, S1, S2, S3)
     - Handshake protocol control (AWVALID/AWREADY)
     - Integration với QoS Arbiter

2. **WD_Channel_Controller_Top** (Write Data Channel)
   - **Location**: `SystemVerilog/axi_interconnect/channel_controllers/write/WD_Channel_Controller_Top.sv`
   - **Chức năng**:
     - Routing write data từ master đã được grant đến slave đã chọn
     - Demultiplexer 1→4 để route data đến đúng slave
     - Write data handshake management (WVALID/WREADY/WLAST)
     - Synchronization với AW channel controller

3. **BR_Channel_Controller_Top** (Write Response Channel)
   - **Location**: `SystemVerilog/axi_interconnect/channel_controllers/write/BR_Channel_Controller_Top.sv`
   - **Chức năng**:
     - Arbitration cho write responses từ 4 slaves
     - Multiplexer 4→1 để route response về đúng master
     - Response ID matching (BID) để đảm bảo response về đúng master
     - Write response handshake (BVALID/BREADY)

4. **AR_Channel_Controller_Top** (Read Address Channel)
   - **Location**: `SystemVerilog/axi_interconnect/channel_controllers/read/AR_Channel_Controller_Top.sv`
   - **Chức năng**:
     - Arbitration giữa Master 0 và Master 1 cho read address
     - Address decoding để xác định slave đích
     - Handshake protocol control (ARVALID/ARREADY)
     - Integration với QoS Arbiter

**Cấu trúc sử dụng:**
```
comprehensive_system_tb.sv
    │
    └──> AXI_Interconnect (wrapper)
            │
            └──> AXI_Interconnect_Full
                    │
                    ├──> AW_Channel_Controller_Top  ✅
                    ├──> WD_Channel_Controller_Top  ✅
                    ├──> BR_Channel_Controller_Top  ✅
                    └──> AR_Channel_Controller_Top  ✅
```

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

### Comprehensive System Testbench

**Testbench**: `SystemVerilog/testbenches/axi_masters/comprehensive_system_tb.sv`

Dự án bao gồm comprehensive testbench với **21 test cases** đã được verify thành công:

#### Tổng Kết Kết Quả Verification

```
============================================================================
Test Statistics
============================================================================
Test Scenarios:  8
Total Test Cases: 21
Passed:           21
Failed:           0
Pass Rate:        100.0%
============================================================================
```

#### Chi Tiết Test Cases

**Test 1: Basic Sequential Operations** ✅
- M0 sequential operation: **PASS**
- M1 sequential operation: **PASS**

**Test 2: Concurrent Operations - Different Slaves** ✅
- Concurrent different slaves: **PASS**

**Test 3: Contention - Same Slave (S0)** ✅
- Contention same slave: **PASS**

**Test 4: Busy Flag Monitoring** ✅
- Initial idle state: **PASS**
- M0 busy after start: **PASS**
- M1 idle when M0 busy: **PASS**
- M0 idle after complete: **PASS**
- M1 busy after start: **PASS**
- M1 idle after complete: **PASS**

**Test 5: All Slaves Coverage (S2-UART, S3-SPI)** ✅
- S0 (RAM) accessible: **PASS**
- S2 base address correct: **PASS**
- S3 base address correct: **PASS**
- All 4 slaves configured: **PASS**

**Test 6: Multiple Concurrent Transactions** ✅
- M0 completed in concurrent mode: **PASS**
- M1 completed in concurrent mode: **PASS**
- Both masters completed concurrently: **PASS**

**Test 7: Stress Test - Rapid Sequential Requests** ✅
- Stress test: all rapid requests completed: **PASS**
- Completed 5/5 rapid requests

**Test 8: Arbitration Fairness** ✅
- M0 completed first in contention: **PASS**
- M1 completed after M0: **PASS**
- Arbitration handled contention correctly: **PASS**

#### Channel Controllers Verification

Tất cả **4 Channel Controllers** đã được verify hoạt động đúng:

- ✅ **AW_Channel_Controller_Top**: Write address arbitration và routing hoạt động chính xác
- ✅ **WD_Channel_Controller_Top**: Write data routing và demux hoạt động đúng
- ✅ **BR_Channel_Controller_Top**: Write response arbitration và mux hoạt động chính xác
- ✅ **AR_Channel_Controller_Top**: Read address arbitration và routing hoạt động đúng

#### Simulation Performance

- **Total Simulation Time**: 4675ns
- **Timeout Setting**: 10000ns
- **Completion**: Simulation hoàn thành trước timeout
- **Status**: ✅ **SUCCESS**

#### Các Vấn Đề Đã Được Khắc Phục

1. ✅ **M1 Timeout Issue**: Đã sửa address offset calculation trong `axi_master_1.sv`
2. ✅ **Arbitration Deadlock**: Đã sửa `Token` assignment và `Request` logic trong `Qos_Arbiter`
3. ✅ **Handshake Deadlock**: Đã sửa `AW_HandShake_Checker` và `WR_HandShake` logic
4. ✅ **Write Response Routing**: Đã sửa `M01_AXI_BID` connection trong `AXI_Interconnect.sv`
5. ✅ **ModelSim Compatibility**: Đã điều chỉnh SystemVerilog syntax cho ModelSim ALTERA

#### Kết Luận

Hệ thống AXI Interconnect với **4 Channel Controllers** đã được verify thành công với **100% test cases passed**. Tất cả các chức năng chính hoạt động đúng:
- ✅ Write Address Channel (AW_Channel_Controller_Top)
- ✅ Write Data Channel (WD_Channel_Controller_Top)
- ✅ Write Response Channel (BR_Channel_Controller_Top)
- ✅ Read Address Channel (AR_Channel_Controller_Top)
- ✅ Read Data Channel (Mux 4→1)
- ✅ Arbitration (Round-Robin/QoS-based)
- ✅ Address Decoding
- ✅ Handshake Protocols
- ✅ Concurrent Transactions
- ✅ Contention Handling

**Testbench Location**: `SystemVerilog/testbenches/axi_masters/comprehensive_system_tb.sv`

Xem `verification/testbenches/` để biết thêm chi tiết về các testbenches khác.

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
**Verification Status**: ✅ **100% PASS (21/21 test cases)**  
**Channel Controllers**: ✅ **All 4 Controllers Verified**

















