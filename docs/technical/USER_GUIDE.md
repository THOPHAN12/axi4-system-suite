# Hướng Dẫn Vận Hành (User Guide)

## 1. Cài Đặt và Thiết Lập

### 1.1. Yêu Cầu Hệ Thống
- **Simulation Tools**: ModelSim/QuestaSim, Quartus, hoặc Verilator
- **Synthesis Tools**: Vivado, Quartus, hoặc Synplify
- **Operating System**: Windows, Linux, hoặc macOS
- **Memory**: Tối thiểu 4GB RAM cho simulation
- **Disk Space**: ~2GB cho tools và projects

### 1.2. Cài Đặt Simulation Tools

#### ModelSim/QuestaSim
```bash
# Windows: Download và cài đặt từ Intel hoặc Siemens
# Linux: 
sudo apt-get install modelsim

# macOS:
brew install --cask modelsim
```

#### Verilator
```bash
# Xem hướng dẫn chi tiết tại:
# sim/verilator/INSTALL_GUIDE.md
```

### 1.3. Clone Repository
```bash
git clone https://github.com/THOPHAN12/axi4-system-suite.git
cd axi4-system-suite
```

## 2. Simulation với ModelSim

### 2.1. Quick Start

```bash
cd sim/modelsim/AXI_Interconnect

# Chạy comprehensive testbench
vsim -do run_comprehensive_tb.tcl

# Hoặc sử dụng script PowerShell (Windows)
.\run_comprehensive_tb.ps1
```

### 2.2. Các Testbenches Có Sẵn

#### Comprehensive System Testbench
```bash
# File: SystemVerilog/testbenches/axi_masters/comprehensive_system_tb.sv
# Test: 21 test cases, 100% pass rate

vsim -do run_comprehensive_tb.tcl
```

#### Dual Master Busy Contention Testbench
```bash
# File: SystemVerilog/testbenches/axi_masters/dual_master_busy_contention_tb.sv
# Test: Contention scenarios

vsim -do run_busy_signal_tb.tcl
```

### 2.3. Xem Waveform

```bash
# Sau khi simulation chạy xong
vsim -view vsim.wlf

# Hoặc load waveform script
do wave_dual_riscv.do
```

## 3. Simulation với Verilator

### 3.1. Setup Verilator

```bash
cd sim/verilator

# Windows (MSYS2)
./setup_verilator.ps1

# Linux/macOS
./setup_verilator.sh
```

### 3.2. Compile và Run

```bash
# Compile
./compile_verilator.sh

# Run simulation
./run_simulation.sh
```

## 4. Synthesis với Vivado

### 4.1. Tạo Project

```bash
cd synthesis/scripts/vivado

# Chạy script tạo project
vivado -mode batch -source create_project.tcl
```

### 4.2. Synthesis và Implementation

```bash
# Trong Vivado Tcl console
source synthesis/scripts/vivado/synth_impl.tcl
```

### 4.3. Generate Bitstream

```bash
# Sau khi implementation thành công
write_bitstream -force output.bit
```

## 5. Synthesis với Quartus

### 5.1. Tạo Project

```bash
cd synthesis/scripts/quartus

# Mở Quartus và tạo project mới
# Add files từ SystemVerilog/
```

### 5.2. Compilation

```bash
# Trong Quartus
Processing → Start Compilation
```

## 6. Sử Dụng AXI Interconnect

### 6.1. Instantiation

```systemverilog
AXI_Interconnect #(
    .ARBITRATION_MODE(1)  // 0=Fixed, 1=Round-Robin, 2=QoS
) u_axi_interconnect (
    .ACLK(clk),
    .ARESETN(rst_n),
    
    // Master 0 interface
    .M0_AWADDR(m0_awaddr),
    .M0_AWVALID(m0_awvalid),
    .M0_AWREADY(m0_awready),
    // ... other signals
    
    // Master 1 interface
    .M1_AWADDR(m1_awaddr),
    // ... other signals
    
    // Slave 0-3 interfaces
    .S0_AXI_awaddr(s0_awaddr),
    // ... other signals
);
```

### 6.2. Configuration

#### Arbitration Mode
```systemverilog
parameter ARBITRATION_MODE = 1;  // Round-Robin
// 0: Fixed Priority
// 1: Round-Robin
// 2: QoS-Based
```

#### Address Mapping
```systemverilog
// Default mapping (có thể thay đổi trong synthesis)
// S0: 0x0000_0000 - 0x3FFF_FFFF
// S1: 0x4000_0000 - 0x7FFF_FFFF
// S2: 0x8000_0000 - 0xBFFF_FFFF
// S3: 0xC000_0000 - 0xFFFF_FFFF
```

## 7. RISC-V Cores Integration

### 7.1. SERV Core

```systemverilog
serv_axi_wrapper u_serv_core (
    .clk(clk),
    .rst_n(rst_n),
    // AXI Master interface
    .axi_awaddr(awaddr),
    .axi_awvalid(awvalid),
    // ... other signals
);
```

### 7.2. Dual RISC-V System

```systemverilog
// Xem examples trong:
// SystemVerilog/testbenches/axi_masters/comprehensive_system_tb.sv
```

## 8. Peripherals

### 8.1. AXI-Lite RAM

```systemverilog
axi_lite_ram #(
    .MEM_SIZE(1024)  // Size in words
) u_ram (
    .ACLK(clk),
    .ARESETN(rst_n),
    // AXI-Lite interface
);
```

### 8.2. AXI-Lite GPIO

```systemverilog
axi_lite_gpio u_gpio (
    .ACLK(clk),
    .ARESETN(rst_n),
    .GPIO_OUT(gpio_out),
    .GPIO_IN(gpio_in),
    // AXI-Lite interface
);
```

## 9. Verification

### 9.1. Chạy Test Suites

```bash
# Comprehensive testbench
cd sim/modelsim/AXI_Interconnect
vsim -do run_comprehensive_tb.tcl

# Kiểm tra kết quả trong log file
grep "PASS\|FAIL" comprehensive_system_tb.log
```

### 9.2. Test Results

**Expected Results**:
- Total Test Cases: 21
- Passed: 21
- Failed: 0
- Pass Rate: 100%

## 10. Troubleshooting

### 10.1. Simulation Issues

#### ModelSim Compatibility
```systemverilog
// Một số SystemVerilog features có thể không được hỗ trợ
// Sử dụng Verilog syntax thay thế nếu cần
```

#### Timing Issues
```systemverilog
// Đảm bảo clock và reset được setup đúng
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 0;
    #100;
    rst_n = 1;
end
```

### 10.2. Synthesis Issues

#### Constraint Files
```bash
# Đảm bảo constraint files được add vào project
# Xem: synthesis/constraints/axi_interconnect.xdc
```

#### Timing Violations
```bash
# Kiểm tra timing reports
# Adjust clock constraints nếu cần
```

### 10.3. Common Errors

#### Handshake Deadlock
```systemverilog
// Đảm bảo VALID và READY được assert đúng
// Không deassert VALID trước khi READY asserted
```

#### Address Decoding
```systemverilog
// Kiểm tra address mapping
// Đảm bảo addresses nằm trong valid ranges
```

## 11. Best Practices

### 11.1. Code Organization
```
SystemVerilog/
├── axi_interconnect/    # AXI Interconnect modules
├── axi_masters/         # AXI Master modules
├── peripherals/          # Peripheral modules
└── testbenches/         # Testbench files
```

### 11.2. Naming Conventions
- Modules: `Module_Name`
- Signals: `signal_name` (lowercase with underscores)
- Parameters: `PARAMETER_NAME` (uppercase)

### 11.3. Comments
```systemverilog
// Module description
// Author, Date
// Functionality

module MyModule (
    // Port descriptions
    input  logic clk,      // Clock signal
    input  logic rst_n,    // Reset signal (active low)
    output logic out       // Output signal
);
```

## 12. Advanced Usage

### 12.1. Custom Arbitration

```systemverilog
// Tạo custom arbiter
module Custom_Arbiter (
    // Implement custom arbitration logic
);
```

### 12.2. Additional Slaves

```systemverilog
// Extend address decoder để support thêm slaves
// Update channel controllers để route đến slaves mới
```

### 12.3. Performance Tuning

```systemverilog
// Adjust pipeline stages
// Optimize arbitration logic
// Add buffering nếu cần
```

## 13. Examples

Xem các examples trong:
- `SystemVerilog/testbenches/`: Testbench examples
- `examples/`: Design examples
- `docs/examples/`: Documentation examples

## 14. Support

- **Documentation**: Xem `docs/` directory
- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Author**: AXI4 System Suite Team

