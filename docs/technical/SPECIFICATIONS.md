# Đặc Tả Hệ Thống (System Specifications)

## 1. Tổng Quan Hệ Thống

### 1.1. Mục Đích
AXI4 System Suite là một hệ thống SoC (System-on-Chip) tích hợp các bộ xử lý RISC-V kết nối với các thiết bị ngoại vi thông qua AXI4 Interconnect. Hệ thống cung cấp một nền tảng hoàn chỉnh để phát triển, mô phỏng, kiểm thử và triển khai các hệ thống nhúng dựa trên RISC-V và AXI4.

### 1.2. Phạm Vi Ứng Dụng
- **AXI4 Interconnect**: Hỗ trợ 2 Master × 4 Slave với đầy đủ AXI4 protocol
- **RISC-V Cores**: Tích hợp SERV, fRISC-V, và 5-stage Pipeline RISC-V
- **Peripherals**: RAM, GPIO, UART, SPI (AXI-Lite)
- **Verification**: Testbenches đầy đủ cho từng module và hệ thống
- **Simulation**: Hỗ trợ ModelSim, Quartus, và Verilator
- **FPGA Deployment**: Hỗ trợ triển khai lên FPGA (Xilinx KV260)

### 1.3. Yêu Cầu Hệ Thống
- **Simulation Tools**: ModelSim/QuestaSim, Quartus, hoặc Verilator
- **Synthesis Tools**: Vivado, Quartus, hoặc Synplify
- **FPGA Board**: Xilinx KV260 (hoặc tương thích)
- **Memory**: Tối thiểu 4GB RAM cho simulation

## 2. Kiến Trúc Hệ Thống

### 2.1. AXI Interconnect Architecture

#### 2.1.1. Cấu Hình
- **Topology**: 2 Masters × 4 Slaves
- **Protocol**: AXI4 Full (Read/Write)
- **Data Width**: 32-bit
- **Address Width**: 32-bit

#### 2.1.2. Channel Controllers

Hệ thống sử dụng **4 Channel Controllers** chuyên biệt:

1. **AW_Channel_Controller_Top** (Write Address Channel)
   - **Location**: `SystemVerilog/axi_interconnect/channel_controllers/write/AW_Channel_Controller_Top.sv`
   - **Chức năng**:
     - Arbitration giữa Master 0 và Master 1
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

5. **Read Data Channel** (Mux 4→1)
   - **Chức năng**:
     - Multiplexer 4→1 để route read data từ slave về master
     - Read data handshake management (RVALID/RREADY/RLAST)
     - Response ID matching (RID)

### 2.2. Arbitration Algorithms

#### 2.2.1. Fixed Priority
- **File**: `arbiter_fixed_priority.sv`
- **Policy**: Master 0 luôn có priority cao hơn Master 1
- **Use Case**: Khi Master 0 cần guaranteed bandwidth

#### 2.2.2. Round-Robin
- **File**: `arbiter_round_robin.sv`
- **Policy**: Luân phiên giữa Master 0 và Master 1
- **Use Case**: Fair bandwidth distribution, no starvation

#### 2.2.3. QoS-Based
- **File**: `arbiter_qos_based.sv`
- **Policy**: Dựa trên QoS value từ masters
- **Use Case**: Quality of Service requirements

### 2.3. Address Decoding

#### 2.3.1. Slave Address Map
```
S0 (RAM):     0x0000_0000 - 0x3FFF_FFFF
S1 (GPIO):    0x4000_0000 - 0x7FFF_FFFF
S2 (UART):    0x8000_0000 - 0xBFFF_FFFF
S3 (SPI):     0xC000_0000 - 0xFFFF_FFFF
```

#### 2.3.2. Decoders
- **Write_Addr_Channel_Dec**: Decode write address
- **Read_Addr_Channel_Dec**: Decode read address
- **Write_Resp_Channel_Dec**: Decode write response routing

### 2.4. RISC-V Cores Integration

#### 2.4.1. SERV Core
- **Architecture**: Bit-serial RISC-V implementation
- **Wrapper**: `serv_axi_wrapper.sv`
- **Features**: Instruction và Data bus riêng biệt

#### 2.4.2. fRISC-V Core
- **Architecture**: Fast RISC-V implementation
- **Wrapper**: `friscv_axi_wrapper.sv`

#### 2.4.3. 5-stage Pipeline RISC-V
- **Architecture**: Classic 5-stage pipeline
- **Wrapper**: `riscv_pipeline_axi_wrapper.sv`

### 2.5. Peripherals

#### 2.5.1. AXI-Lite RAM
- **File**: `axi_lite_ram.sv`
- **Size**: Configurable
- **Features**: Read/Write operations

#### 2.5.2. AXI-Lite GPIO
- **File**: `axi_lite_gpio.sv`
- **Features**: General Purpose I/O

#### 2.5.3. AXI-Lite UART
- **File**: `axi_lite_uart.sv`
- **Features**: Serial communication

#### 2.5.4. AXI-Lite SPI
- **File**: `axi_lite_spi.sv`
- **Features**: SPI communication

## 3. Đặc Tả Chức Năng

### 3.1. AXI4 Protocol Support

#### 3.1.1. Write Transaction
1. **Write Address Channel (AW)**:
   - AWADDR, AWLEN, AWSIZE, AWBURST
   - AWVALID/AWREADY handshake
   - Address decoding và routing

2. **Write Data Channel (W)**:
   - WDATA, WSTRB, WLAST
   - WVALID/WREADY handshake
   - Data routing đến slave

3. **Write Response Channel (B)**:
   - BRESP, BID
   - BVALID/BREADY handshake
   - Response routing về master

#### 3.1.2. Read Transaction
1. **Read Address Channel (AR)**:
   - ARADDR, ARLEN, ARSIZE, ARBURST
   - ARVALID/ARREADY handshake
   - Address decoding và routing

2. **Read Data Channel (R)**:
   - RDATA, RRESP, RLAST, RID
   - RVALID/RREADY handshake
   - Data routing từ slave về master

### 3.2. Arbitration Features

#### 3.2.1. Request Handling
- Multiple masters có thể request đồng thời
- Arbitration quyết định master nào được grant
- Grant được maintain cho đến khi transaction hoàn thành

#### 3.2.2. Fairness
- Round-Robin: Đảm bảo fair access
- Fixed Priority: Guaranteed priority
- QoS-Based: Dựa trên quality requirements

### 3.3. Concurrent Transactions

#### 3.3.1. Independent Channels
- Write và Read channels độc lập
- Có thể có concurrent write và read transactions

#### 3.3.2. Multiple Slaves
- Có thể access nhiều slaves đồng thời
- Address decoding đảm bảo routing đúng

## 4. Định Dạng Dữ Liệu

### 4.1. AXI4 Signal Widths
- **Address**: 32-bit
- **Data**: 32-bit
- **ID**: Configurable (default 4-bit)
- **Length**: 8-bit (AWLEN/ARLEN)
- **Size**: 3-bit (AWSIZE/ARSIZE)
- **Burst**: 2-bit (AWBURST/ARBURST)
- **Response**: 2-bit (BRESP/RRESP)

### 4.2. Address Mapping
- **Base Addresses**: 32-bit aligned
- **Address Ranges**: 1GB per slave (default)
- **Configurable**: Có thể thay đổi trong synthesis

## 5. Performance Specifications

### 5.1. Timing
- **Clock Frequency**: Up to 100MHz (FPGA dependent)
- **Latency**: 
  - Write: 3-5 cycles (address + data + response)
  - Read: 2-4 cycles (address + data)
- **Throughput**: 
  - Write: Up to 32 bits/cycle
  - Read: Up to 32 bits/cycle

### 5.2. Resource Usage (FPGA)
- **LUTs**: ~5000-8000 (tùy configuration)
- **FFs**: ~3000-5000
- **BRAM**: Tùy thuộc vào peripherals

## 6. Verification Specifications

### 6.1. Test Coverage
- **Functional Coverage**: 100% cho các test cases chính
- **Protocol Compliance**: AXI4 protocol verification
- **Concurrent Transactions**: Tested với multiple masters
- **Arbitration**: Tested với tất cả arbitration modes

### 6.2. Test Scenarios
1. Basic sequential operations
2. Concurrent operations (different slaves)
3. Contention (same slave)
4. Busy flag monitoring
5. All slaves coverage
6. Multiple concurrent transactions
7. Stress test (rapid sequential requests)
8. Arbitration fairness

### 6.3. Test Results
- **Total Test Cases**: 21
- **Passed**: 21
- **Failed**: 0
- **Pass Rate**: 100%

## 7. Giới Hạn Hệ Thống

### 7.1. Configuration Limits
- **Max Masters**: 2 (hardcoded)
- **Max Slaves**: 4 (hardcoded)
- **Data Width**: 32-bit (fixed)
- **Address Width**: 32-bit (fixed)

### 7.2. Protocol Limitations
- **Burst Types**: INCR và FIXED (WRAP chưa hỗ trợ đầy đủ)
- **Out-of-order**: Không hỗ trợ
- **Narrow Transfers**: Hỗ trợ nhưng chưa optimize

## 8. Output Formats

### 8.1. Simulation Outputs
- **Waveform**: VCD format (ModelSim)
- **Logs**: Text format
- **Reports**: HTML/Text format

### 8.2. Synthesis Outputs
- **Netlist**: Verilog/SystemVerilog
- **Constraints**: XDC (Vivado), SDC (Quartus)
- **Reports**: Timing, Area, Power

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Author**: AXI4 System Suite Team

