# SystemVerilog Conversion Status

## Tổng Quan

**Tổng số file RTL cần chuyển đổi**: 33 files  
**Đã chuyển đổi**: 33 files ✅  
**Còn lại**: 0 files  

**Tổng số file SystemVerilog đã tạo**: 36 files (bao gồm packages, interfaces, và wrapper)

## Tiến Độ

### ✅ Đã Hoàn Thành (100%)

#### Utils (2/2)
- ✅ `Raising_Edge_Det.sv`
- ✅ `Faling_Edge_Detc.sv`

#### Buffers (2/2)
- ✅ `Queue.sv`
- ✅ `Resp_Queue.sv`

#### Datapath - MUX (6/6)
- ✅ `Mux_2x1.sv`
- ✅ `Mux_2x1_en.sv`
- ✅ `Mux_4x1.sv`
- ✅ `AW_MUX_2_1.sv`
- ✅ `WD_MUX_2_1.sv`
- ✅ `BReady_MUX_2_1.sv`

#### Datapath - DEMUX (4/4)
- ✅ `Demux_1x2.sv`
- ✅ `Demux_1x2_en.sv`
- ✅ `Demux_1_2.sv`
- ✅ `Demux_1x4.sv`

#### Handshake (3/3)
- ✅ `AW_HandShake_Checker.sv`
- ✅ `WD_HandShake.sv`
- ✅ `WR_HandShake.sv`

#### Decoders (4/4)
- ✅ `Read_Addr_Channel_Dec.sv`
- ✅ `Write_Addr_Channel_Dec.sv`
- ✅ `Write_Resp_Channel_Dec.sv`
- ✅ `Write_Resp_Channel_Arb.sv`

#### Arbitration (4/4)
- ✅ `Read_Arbiter.sv`
- ✅ `Write_Arbiter.sv`
- ✅ `Write_Arbiter_RR.sv`
- ✅ `Qos_Arbiter.sv`

#### Channel Controllers (5/5)
- ✅ `AR_Channel_Controller_Top.sv`
- ✅ `Controller.sv`
- ✅ `AW_Channel_Controller_Top.sv`
- ✅ `WD_Channel_Controller_Top.sv`
- ✅ `BR_Channel_Controller_Top.sv`

#### Core Modules (3/3)
- ✅ `AXI_Interconnect_Full.sv` (~865 lines)
- ✅ `AXI_Interconnect.sv`
- ✅ `AXI_Interconnect_2S_RDONLY.sv`

#### Wrapper (1/1)
- ✅ `axi_interconnect_2m4s_wrapper.sv`

#### Packages & Interfaces (2/2)
- ✅ `axi_pkg.sv`
- ✅ `axi4_if.sv`

## Cấu Trúc Thư Mục SystemVerilog

```
src/axi_interconnect/sv/
├── packages/
│   └── axi_pkg.sv
├── interfaces/
│   └── axi4_if.sv
├── utils/
│   ├── Raising_Edge_Det.sv
│   └── Faling_Edge_Detc.sv
├── buffers/
│   ├── Queue.sv
│   └── Resp_Queue.sv
├── datapath/
│   ├── mux/
│   │   ├── Mux_2x1.sv
│   │   ├── Mux_2x1_en.sv
│   │   ├── Mux_4x1.sv
│   │   ├── AW_MUX_2_1.sv
│   │   ├── WD_MUX_2_1.sv
│   │   └── BReady_MUX_2_1.sv
│   └── demux/
│       ├── Demux_1x2.sv
│       ├── Demux_1x2_en.sv
│       ├── Demux_1_2.sv
│       └── Demux_1x4.sv
├── handshake/
│   ├── AW_HandShake_Checker.sv
│   ├── WD_HandShake.sv
│   └── WR_HandShake.sv
├── decoders/
│   ├── Read_Addr_Channel_Dec.sv
│   ├── Write_Addr_Channel_Dec.sv
│   ├── Write_Resp_Channel_Dec.sv
│   └── Write_Resp_Channel_Arb.sv
├── arbitration/
│   ├── Read_Arbiter.sv
│   ├── Write_Arbiter.sv
│   ├── Write_Arbiter_RR.sv
│   └── Qos_Arbiter.sv
├── channel_controllers/
│   ├── read/
│   │   ├── AR_Channel_Controller_Top.sv
│   │   └── Controller.sv
│   └── write/
│       ├── AW_Channel_Controller_Top.sv
│       ├── WD_Channel_Controller_Top.sv
│       └── BR_Channel_Controller_Top.sv
└── core/
    ├── AXI_Interconnect_Full.sv
    ├── AXI_Interconnect.sv
    └── AXI_Interconnect_2S_RDONLY.sv
```

## Các Thay Đổi Chính

### 1. Kiểu Dữ Liệu
- `wire` → `logic`
- `reg` → `logic`
- Thêm type annotations cho parameters: `int unsigned`, `int`

### 2. Always Blocks
- `always @(*)` → `always_comb`
- `always @(posedge clk or negedge rst)` → `always_ff @(posedge clk or negedge rst)`

### 3. Packages & Interfaces
- Tạo `axi_pkg.sv` với các constants, enums, structs, và helper functions
- Tạo `axi4_if.sv` với AXI4 interface và modports

### 4. Wrapper Module
- Chuyển đổi wrapper để sử dụng SystemVerilog syntax
- Vẫn instantiate Verilog modules (có thể chuyển đổi sau)

## Lưu Ý

- ✅ Tất cả file `.v` gốc KHÔNG bị sửa
- ✅ File `.sv` được tạo mới trong thư mục `sv/` tương ứng
- ⚠️ Cần test compilation sau khi chuyển đổi
- ⚠️ Một số file có debug statements (`$display`) - có thể giữ hoặc comment
- ⚠️ Các module SystemVerilog hiện tại vẫn instantiate Verilog modules - cần chuyển đổi dần

## Next Steps

1. ✅ **Hoàn thành chuyển đổi tất cả RTL files** - DONE
2. ⏳ **Cập nhật project files** để support cả `.v` và `.sv`
3. ⏳ **Test compilation** với Quartus II hoặc ModelSim
4. ⏳ **Cập nhật instantiation** trong các module SystemVerilog để sử dụng các module SystemVerilog khác thay vì Verilog
5. ⏳ **Tạo testbenches SystemVerilog** nếu cần

## Thống Kê

- **Tổng số dòng code**: ~15,000+ lines (ước tính)
- **File lớn nhất**: `AXI_Interconnect_Full.sv` (~865 lines)
- **File nhỏ nhất**: Các utility modules (~20-50 lines)
- **Thời gian chuyển đổi**: Hoàn thành trong 1 session
