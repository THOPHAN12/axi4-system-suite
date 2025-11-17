# Sơ Đồ Kết Nối RISC-V System

## Kiến Trúc Tổng Quan

```
┌─────────────────────────────────────────────────────────────┐
│                    serv_axi_system_tb                        │
│  (Testbench)                                                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Ports: M00_AXI, M01_AXI
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  serv_axi_system                             │
│  (Top-level System)                                          │
│                                                              │
│  ┌──────────────────┐                                       │
│  │ serv_axi_wrapper │                                       │
│  │  (SERV + AXI)    │                                       │
│  └────────┬─────────┘                                       │
│           │                                                  │
│     ┌─────┴─────┐                                           │
│     │           │                                           │
│  M0_AXI      M1_AXI                                         │
│  (Inst)      (Data)                                         │
│     │           │                                           │
│     └─────┬─────┘                                           │
│           │                                                  │
│           ▼                                                  │
│  ┌──────────────────────┐                                  │
│  │ AXI_Interconnect_Full │                                  │
│  │                       │                                  │
│  │  S00 (Inst) ──┐       │                                  │
│  │  S01 (Data) ──┼───┐   │                                  │
│  │               │   │   │                                  │
│  │  M00 ─────────┘   │   │                                  │
│  │  M01 ─────────────┘   │                                  │
│  └──────────────────────┘                                  │
│           │                                                  │
│     ┌─────┴─────┐                                           │
│     │           │                                           │
│  M00_AXI    M01_AXI                                         │
│  (output)   (output)                                        │
└─────────────────────────────────────────────────────────────┘
     │           │
     │           │
     ▼           ▼
┌──────────┐ ┌──────────────┐
│ axi_rom  │ │ axi_memory   │
│ _slave   │ │ _slave       │
│          │ │              │
│ (ROM)    │ │ (RAM)        │
└──────────┘ └──────────────┘
```

## Chi Tiết Kết Nối

### 1. SERV Core → AXI Wrapper

**File**: `src/wrapper/serv_axi_system.v` (lines 230-313)

```
serv_axi_wrapper u_serv_wrapper (
    // Instruction Bus (M0_AXI) → S00_AXI (internal wires)
    .M0_AXI_araddr  (S00_AXI_araddr),
    .M0_AXI_arvalid (S00_AXI_arvalid),
    .M0_AXI_arready (S00_AXI_arready),
    .M0_AXI_rdata   (S00_AXI_rdata),
    ...
    
    // Data Bus (M1_AXI) → S01_AXI (internal wires)
    .M1_AXI_awaddr  (S01_AXI_awaddr),
    .M1_AXI_awvalid (S01_AXI_awvalid),
    .M1_AXI_awready (S01_AXI_awready),
    ...
)
```

### 2. AXI Wrapper → AXI Interconnect

**File**: `src/wrapper/serv_axi_system.v` (lines 337-495)

```
AXI_Interconnect_Full u_axi_interconnect (
    // Master 0 (Instruction) - S00 port
    .S00_AXI_araddr  (S00_AXI_araddr),   // From wrapper
    .S00_AXI_arvalid (S00_AXI_arvalid),
    .S00_AXI_arready (S00_AXI_arready),
    .S00_AXI_rdata   (S00_AXI_rdata),
    ...
    
    // Master 1 (Data) - S01 port
    .S01_AXI_awaddr  (S01_AXI_awaddr),   // From wrapper
    .S01_AXI_awvalid (S01_AXI_awvalid),
    ...
    
    // Slave 0 (Instruction Memory) - M00 port
    .M00_AXI_araddr  (M00_AXI_araddr),   // To memory slave
    .M00_AXI_arvalid (M00_AXI_arvalid),
    .M00_AXI_arready (M00_AXI_arready),
    .M00_AXI_rdata   (M00_AXI_rdata),
    ...
    
    // Slave 1 (Data Memory) - M01 port
    .M01_AXI_awaddr  (M01_AXI_awaddr),   // To memory slave
    .M01_AXI_awvalid (M01_AXI_awvalid),
    ...
)
```

### 3. AXI Interconnect → Memory Slaves (trong testbench)

**File**: `tb/wrapper_tb/serv_axi_system_tb.v` (lines 187-266)

```
// Instruction Memory Slave
axi_rom_slave u_inst_mem (
    .S_AXI_araddr  (M00_AXI_araddr),   // From serv_axi_system.M00_AXI
    .S_AXI_arvalid (M00_AXI_arvalid),
    .S_AXI_arready (M00_AXI_arready),
    .S_AXI_rdata   (M00_AXI_rdata),
    ...
)

// Data Memory Slave
axi_memory_slave u_data_mem (
    .S_AXI_awaddr  (M01_AXI_awaddr),   // From serv_axi_system.M01_AXI
    .S_AXI_awvalid (M01_AXI_awvalid),
    .S_AXI_awready (M01_AXI_awready),
    .S_AXI_wdata   (M01_AXI_wdata),
    ...
)
```

## Luồng Dữ Liệu

### Instruction Fetch (Read-only)

```
1. SERV Core cần fetch instruction
   ↓
2. serv_axi_wrapper tạo AXI read request
   M0_AXI_araddr = 0x00000000
   M0_AXI_arvalid = 1
   ↓
3. Kết nối với S00_AXI (internal wire)
   S00_AXI_araddr = 0x00000000
   ↓
4. AXI Interconnect nhận request
   - Decode address: bits[31:30] = 00 → Slave 0 (M00)
   - Route đến M00 port
   ↓
5. M00_AXI_araddr = 0x00000000 (output từ interconnect)
   ↓
6. axi_rom_slave nhận request
   - Read memory[0] = 0x00010037
   - Trả về qua M00_AXI_rdata
   ↓
7. Data quay lại qua interconnect → wrapper → SERV core
```

### Data Access (Read/Write)

```
1. SERV Core cần write data
   ↓
2. serv_axi_wrapper tạo AXI write request
   M1_AXI_awaddr = 0x10000000
   M1_AXI_wdata = 0x00010005
   ↓
3. Kết nối với S01_AXI (internal wire)
   ↓
4. AXI Interconnect nhận request
   - Decode address: bits[31:30] = 01 → Slave 1 (M01)
   - Route đến M01 port
   ↓
5. M01_AXI_awaddr = 0x10000000 (output từ interconnect)
   M01_AXI_wdata = 0x00010005
   ↓
6. axi_memory_slave nhận request
   - Write memory[0] = 0x00010005
   - Trả về write response
```

## Address Mapping

### Trong serv_axi_system.v

```verilog
parameter SLAVE0_ADDR1 = 32'h0000_0000,  // bits[31:30] = 00
parameter SLAVE0_ADDR2 = 32'h3FFF_FFFF,
parameter SLAVE1_ADDR1 = 32'h4000_0000,  // bits[31:30] = 01
parameter SLAVE1_ADDR2 = 32'h7FFF_FFFF
```

### Trong testbench

```verilog
serv_axi_system #(
    .SLAVE0_ADDR1 (32'h0000_0000),  // Instruction memory
    .SLAVE0_ADDR2 (32'h0000_FFFF),
    .SLAVE1_ADDR1 (32'h1000_0000),  // Data memory
    .SLAVE1_ADDR2 (32'h1FFF_FFFF)
) u_dut (...)
```

**Lưu ý**: Address mapping trong testbench khác với default trong module!

## Kiểm Tra Kết Nối

### Cách 1: Xem trong waveform

1. Mở waveform: `gtkwave serv_axi_system_tb.vcd`
2. Thêm signals:
   - `/serv_axi_system_tb/u_dut/M00_AXI_araddr`
   - `/serv_axi_system_tb/u_dut/M00_AXI_arvalid`
   - `/serv_axi_system_tb/u_inst_mem/S_AXI_araddr`
   - `/serv_axi_system_tb/u_inst_mem/S_AXI_arvalid`

### Cách 2: Thêm monitoring trong testbench

Thêm vào testbench để xem kết nối:

```verilog
// Monitor interconnect to slave connections
always @(posedge ACLK) begin
    if (M00_AXI_arvalid && M00_AXI_arready) begin
        $display("[%0t] Interconnect → ROM Slave: addr=0x%08h", 
                 $time, M00_AXI_araddr);
    end
    if (M01_AXI_awvalid && M01_AXI_awready) begin
        $display("[%0t] Interconnect → RAM Slave: write addr=0x%08h, data=0x%08h", 
                 $time, M01_AXI_awaddr, M01_AXI_wdata);
    end
end
```

## Kết Luận

✅ **Kết nối đúng!**

- SERV Core → AXI Wrapper: ✅
- AXI Wrapper → AXI Interconnect: ✅  
- AXI Interconnect → Memory Slaves: ✅

Tất cả đều được kết nối qua các ports M00_AXI và M01_AXI của `serv_axi_system`.

