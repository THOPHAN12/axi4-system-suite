# Cấu Trúc Dự Án (Project Structure)

## 1. Tổng Quan

Tài liệu này mô tả cấu trúc thư mục và tổ chức code của dự án AXI4 System Suite, 
giúp dễ dàng hiểu và kế thừa dự án.

## 2. Cấu Trúc Thư Mục Chính

```
axi4-system-suite/
├── SystemVerilog/          # Source code chính (SystemVerilog)
├── src/                    # Source code (Verilog)
├── docs/                   # Tài liệu
├── sim/                    # Simulation files
├── synthesis/              # Synthesis files
├── verification/           # Verification files
├── tools/                  # Utility tools
├── software/               # Software/firmware
├── ip_cores/              # IP cores
├── build/                  # Build outputs
├── deployment/             # Deployment files
└── Test/                  # Test documentation
```

## 3. SystemVerilog/ - Source Code Chính

### 3.1. axi_interconnect/

**Mô tả**: AXI Interconnect core và các components

```
axi_interconnect/
├── core/                           # Core modules
│   ├── AXI_Interconnect.sv        # Top-level wrapper
│   ├── AXI_Interconnect_Full.sv    # Full implementation
│   └── AXI_Master_Aggregator.sv    # Master aggregator
│
├── channel_controllers/            # Channel controllers
│   ├── write/
│   │   ├── AW_Channel_Controller_Top.sv    # Write Address
│   │   ├── WD_Channel_Controller_Top.sv    # Write Data
│   │   └── BR_Channel_Controller_Top.sv    # Write Response
│   └── read/
│       └── AR_Channel_Controller_Top.sv    # Read Address
│
├── arbitration/                     # Arbitration algorithms
│   └── algorithms/
│       ├── arbiter_fixed_priority.sv
│       ├── arbiter_round_robin.sv
│       ├── arbiter_qos_based.sv
│       └── read_arbiter.sv
│
├── decoders/                        # Address decoders
│   ├── Write_Addr_Channel_Dec.sv
│   ├── Read_Addr_Channel_Dec.sv
│   └── Write_Resp_Channel_Dec.sv
│
├── datapath/                        # Data path components
│   ├── mux/                        # Multiplexers
│   │   ├── Mux_2x1.sv
│   │   ├── Mux_4x1.sv
│   │   └── ...
│   └── demux/                      # Demultiplexers
│       ├── Demux_1x2.sv
│       ├── Demux_1x4.sv
│       └── ...
│
├── handshake/                       # Handshake controllers
│   ├── AW_HandShake_Checker.sv
│   ├── WR_HandShake.sv
│   └── WD_HandShake.sv
│
├── buffers/                         # Buffers và queues
│   ├── Queue.sv
│   └── Resp_Queue.sv
│
└── utils/                           # Utility modules
    ├── Raising_Edge_Det.sv
    └── Faling_Edge_Detc.sv
```

**Comment Guidelines**:
- Mỗi file phải có header comment mô tả module
- Mỗi port phải có comment mô tả chức năng
- Các state machine phải có comment mô tả states
- Các thuật toán phức tạp phải có comment giải thích

### 3.2. axi_masters/

**Mô tả**: AXI Master modules

```
axi_masters/
├── axi_master_0.sv          # Master 0 implementation
├── axi_master_1.sv          # Master 1 implementation
└── master_controller.sv    # Master controller
```

### 3.3. axi_bridge/

**Mô tả**: AXI Bridges và wrappers

```
axi_bridge/
├── serv_axi_wrapper.sv              # SERV core wrapper
├── friscv_axi_wrapper.sv            # fRISC-V wrapper
├── riscv_pipeline_axi_wrapper.sv    # 5-stage pipeline wrapper
├── axi_master_bridge.sv             # Master bridge
└── axi_slave_bridge.sv               # Slave bridge
```

### 3.4. peripherals/

**Mô tả**: Peripheral modules (AXI-Lite)

```
peripherals/
└── axi_lite/
    ├── axi_lite_ram.sv      # RAM peripheral
    ├── axi_lite_gpio.sv     # GPIO peripheral
    ├── axi_lite_uart.sv     # UART peripheral
    └── axi_lite_spi.sv      # SPI peripheral
```

### 3.5. testbenches/

**Mô tả**: Testbench files

```
testbenches/
├── axi_masters/
│   ├── comprehensive_system_tb.sv           # Comprehensive test
│   ├── dual_master_busy_contention_tb.sv     # Contention test
│   └── dual_master_with_controller_tb.sv     # Controller test
├── axi_interconnect/
│   └── core/
│       └── AXI_Interconnect_tb.sv            # Interconnect test
└── axi_bridge/
    ├── axi_master_bridge_tb.sv
    └── axi_slave_bridge_tb.sv
```

## 4. docs/ - Tài liệu

### 4.1. technical/

**Mô tả**: Tài liệu kỹ thuật

```
docs/technical/
├── SPECIFICATIONS.md       # Đặc tả hệ thống
├── ALGORITHMS.md           # Tài liệu giải thuật
├── REFERENCES.md            # Tài liệu tham khảo
├── USER_GUIDE.md           # Hướng dẫn vận hành
└── PROJECT_STRUCTURE.md    # Cấu trúc dự án (file này)
```

### 4.2. architecture/

**Mô tả**: Tài liệu kiến trúc và sơ đồ

```
docs/architecture/
├── DIAGRAMS.md                         # Mô tả diagrams
├── SYSTEM_ARCHITECTURE.png             # Sơ đồ hệ thống
├── DUAL_MASTER_SYSTEM_DIAGRAM.md       # Sơ đồ dual master
├── DUAL_RISCV_2M4S_HARDWARE_ARCHITECTURE.md
└── *.png                               # Các sơ đồ khác
```

### 4.3. specifications/

**Mô tả**: Đặc tả chi tiết

### 4.4. user_guides/

**Mô tả**: Hướng dẫn sử dụng

## 5. sim/ - Simulation

### 5.1. modelsim/

**Mô tả**: ModelSim simulation files

```
sim/modelsim/
├── AXI_Interconnect/           # AXI Interconnect simulation
│   ├── run_comprehensive_tb.tcl
│   ├── run_comprehensive_tb.ps1
│   └── *.do                   # Waveform scripts
├── compile_all_files.tcl      # Compilation script
└── QUICK_START.md             # Quick start guide
```

### 5.2. verilator/

**Mô tả**: Verilator simulation files

```
sim/verilator/
├── compile_verilator.sh       # Compile script
├── run_simulation.sh          # Run script
├── INSTALL_GUIDE.md           # Installation guide
└── README_VERILATOR.md        # Verilator README
```

## 6. synthesis/ - Synthesis

### 6.1. scripts/

**Mô tả**: Synthesis scripts

```
synthesis/scripts/
├── vivado/                    # Vivado scripts
│   └── *.tcl
├── quartus/                   # Quartus scripts
│   └── *.tcl
└── synplify/                  # Synplify scripts
```

### 6.2. constraints/

**Mô tả**: Constraint files

```
synthesis/constraints/
├── axi_interconnect.xdc       # Vivado constraints
└── README.md
```

## 7. verification/ - Verification

### 7.1. testbenches/

**Mô tả**: Verification testbenches

```
verification/testbenches/
├── interconnect_tb/           # Interconnect testbenches
│   └── arbitration/           # Arbitration tests
└── ...
```

### 7.2. testcases/

**Mô tả**: Test cases

## 8. Naming Conventions

### 8.1. Files
- **Modules**: `Module_Name.sv` (PascalCase)
- **Testbenches**: `module_name_tb.sv` (snake_case với _tb suffix)
- **Scripts**: `script_name.tcl` hoặc `script_name.sh` (snake_case)

### 8.2. Modules
- **Top-level**: `AXI_Interconnect`
- **Sub-modules**: `AW_Channel_Controller_Top`
- **Utilities**: `Raising_Edge_Det`

### 8.3. Signals
- **Ports**: `signal_name` (snake_case)
- **Internal**: `internal_signal` (snake_case)
- **Constants**: `CONSTANT_NAME` (UPPER_SNAKE_CASE)

## 9. Comment Guidelines

### 9.1. File Header

```systemverilog
////////////////////////////////////////////////////////////////////////////////
// Module Name: AW_Channel_Controller_Top
// Description: Write Address Channel Controller for AXI Interconnect
//              Handles arbitration, address decoding, and routing
//
// Features:
//   - Arbitration between Master 0 and Master 1
//   - Address decoding for 4 slaves
//   - Handshake protocol control
//
// Author: AXI Team
// Date: 2025-01-XX
// Version: 1.0
////////////////////////////////////////////////////////////////////////////////
```

### 9.2. Port Comments

```systemverilog
module AW_Channel_Controller_Top (
    // Clock and Reset
    input  logic ACLK,        // System clock
    input  logic ARESETN,     // Active-low reset
    
    // Master 0 Interface
    input  logic [31:0] M0_AWADDR,   // Write address from Master 0
    input  logic        M0_AWVALID,  // Write address valid from Master 0
    output logic        M0_AWREADY,  // Write address ready to Master 0
    
    // ...
);
```

### 9.3. Code Comments

```systemverilog
// Arbitration logic: Round-Robin
always_comb begin
    if (M0_AWVALID && M1_AWVALID) begin
        // Both masters request: round-robin
        Selected_Master = {1'b0, ~last_served};
    end else if (M0_AWVALID) begin
        // Only Master 0 requests
        Selected_Master = 2'b00;
    end
    // ...
end
```

## 10. Dependencies

### 10.1. Module Dependencies

```
AXI_Interconnect (Top)
    ├── AXI_Interconnect_Full
    │   ├── AW_Channel_Controller_Top
    │   │   ├── Write_Addr_Channel_Dec
    │   │   └── Write_Arbiter_RR
    │   ├── WD_Channel_Controller_Top
    │   │   └── Demux_1x4
    │   ├── BR_Channel_Controller_Top
    │   │   └── Mux_4x1
    │   └── AR_Channel_Controller_Top
    │       ├── Read_Addr_Channel_Dec
    │       └── Read_Arbiter
    └── AXI_Master_Aggregator
```

### 10.2. External Dependencies

- **RISC-V Cores**: SERV, fRISC-V, 5-stage Pipeline
- **Simulation Tools**: ModelSim, Verilator, Quartus
- **Synthesis Tools**: Vivado, Quartus, Synplify

## 11. Build Process

### 11.1. Simulation Build

```bash
# ModelSim
cd sim/modelsim/AXI_Interconnect
vsim -do compile_all_files.tcl

# Verilator
cd sim/verilator
./compile_verilator.sh
```

### 11.2. Synthesis Build

```bash
# Vivado
cd synthesis/scripts/vivado
vivado -mode batch -source synth_impl.tcl

# Quartus
cd synthesis/scripts/quartus
quartus_sh --flow compile
```

## 12. Testing Structure

### 12.1. Unit Tests

- Mỗi module có testbench riêng trong `testbenches/`
- Test cases được organize theo module

### 12.2. Integration Tests

- Comprehensive testbench trong `testbenches/axi_masters/`
- System-level tests

## 13. Documentation Structure

### 13.1. Technical Documentation

- `SPECIFICATIONS.md`: System specifications
- `ALGORITHMS.md`: Algorithm documentation
- `REFERENCES.md`: References và papers
- `USER_GUIDE.md`: User guide
- `PROJECT_STRUCTURE.md`: Project structure (file này)

### 13.2. Architecture Documentation

- Diagrams trong `docs/architecture/`
- Block diagrams
- State machine diagrams

## 14. Maintenance

### 14.1. Code Updates

- Update comments khi thay đổi code
- Update documentation khi thay đổi architecture
- Maintain version numbers

### 14.2. Testing

- Chạy testbenches sau mỗi thay đổi
- Đảm bảo 100% test cases pass
- Update test documentation

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Author**: AXI4 System Suite Team

