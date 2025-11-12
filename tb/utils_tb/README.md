# Utils Testbenches

## Cấu Trúc Thư Mục

Thư mục này chứa các testbench cho utility modules của AXI Interconnect. Các file đã được tổ chức theo chức năng để dễ quản lý:

```
tb/utils_tb/
├── edge_detectors/       # Edge detector testbenches
│   ├── Raising_Edge_Det_tb.v
│   └── Faling_Edge_Detc_tb.v
├── mux_demux/            # MUX/Demux testbenches
│   ├── Mux_2x1_tb.v
│   ├── Mux_2x1_en_tb.v
│   ├── BReady_MUX_2_1_tb.v
│   ├── Demux_1_2_tb.v
│   ├── Demux_1x2_tb.v
│   └── Demux_1x2_en_tb.v
└── utils_tb_all.v        # All-in-one testbench suite
```

## Testbenches

### Edge Detectors (`edge_detectors/`)

#### `Raising_Edge_Det_tb.v`
- **Mục đích**: Test Rising Edge Detector module
- **Module được test**: `Raising_Edge_Det.v`
- **Chức năng**: 
  - Test rising edge detection
  - Test output pulse generation
  - Test timing behavior

#### `Faling_Edge_Detc_tb.v`
- **Mục đích**: Test Falling Edge Detector module
- **Module được test**: `Faling_Edge_Detc.v`
- **Chức năng**:
  - Test falling edge detection
  - Test output pulse generation
  - Test timing behavior

### MUX/Demux (`mux_demux/`)

#### `Mux_2x1_tb.v`
- **Mục đích**: Test 2-to-1 Multiplexer
- **Module được test**: `Mux_2x1.v`
- **Chức năng**:
  - Test basic 2-to-1 multiplexing
  - Test selection logic
  - Test data path integrity

#### `Mux_2x1_en_tb.v`
- **Mục đích**: Test 2-to-1 Multiplexer with Enable
- **Module được test**: `Mux_2x1_en.v`
- **Chức năng**:
  - Test multiplexing with enable signal
  - Test enable/disable behavior
  - Test output when disabled

#### `BReady_MUX_2_1_tb.v`
- **Mục đích**: Test BReady MUX (AXI-specific)
- **Module được test**: `BReady_MUX_2_1.v`
- **Chức năng**:
  - Test AXI BREADY signal multiplexing
  - Test AXI-specific behavior
  - Test handshake signals

#### `Demux_1_2_tb.v`
- **Mục đích**: Test 1-to-2 Demultiplexer
- **Module được test**: `Demux_1_2.v`
- **Chức năng**:
  - Test basic 1-to-2 demultiplexing
  - Test selection logic
  - Test output routing

#### `Demux_1x2_tb.v`
- **Mục đích**: Test 1-to-2 Demultiplexer (variant)
- **Module được test**: `Demux_1x2.v`
- **Chức năng**:
  - Test alternative demux implementation
  - Test data routing
  - Test selection behavior

#### `Demux_1x2_en_tb.v`
- **Mục đích**: Test 1-to-2 Demultiplexer with Enable
- **Module được test**: `Demux_1x2_en.v`
- **Chức năng**:
  - Test demultiplexing with enable signal
  - Test enable/disable behavior
  - Test output when disabled

### All-in-One Testbench

#### `utils_tb_all.v`
- **Mục đích**: Documentation và reference cho tất cả utils testbenches
- **Chức năng**:
  - Lists all available testbenches
  - Provides instructions for running individual testbenches
  - Serves as documentation

## Cách Sử Dụng

### Chạy Individual Testbench

#### Từ ModelSim TCL Console:
```tcl
# Compile source module first
vlog +acc -work work ../../src/axi_interconnect/rtl/utils/Raising_Edge_Det.v

# Compile testbench
vlog +acc -work work edge_detectors/Raising_Edge_Det_tb.v

# Run simulation
vsim -voptargs=+acc work.Raising_Edge_Det_tb
run -all
```

### Chạy MUX/Demux Testbench

```tcl
# Compile source module
vlog +acc -work work ../../src/axi_interconnect/rtl/datapath/mux/Mux_2x1.v

# Compile testbench
vlog +acc -work work mux_demux/Mux_2x1_tb.v

# Run simulation
vsim -voptargs=+acc work.Mux_2x1_tb
run -all
```

### Chạy All Testbenches

Xem `utils_tb_all.v` để biết danh sách tất cả testbenches và cách chạy từng cái.

## Source Modules

Các source modules tương ứng nằm trong:
- Edge Detectors: `src/axi_interconnect/rtl/utils/`
- MUX/Demux: `src/axi_interconnect/rtl/datapath/mux/` và `datapath/demux/`

## File Organization Benefits

1. **Dễ tìm kiếm**: Testbenches được phân loại theo chức năng
2. **Dễ quản lý**: Mỗi loại module có thư mục riêng
3. **Dễ mở rộng**: Dễ dàng thêm testbench mới vào đúng thư mục
4. **Rõ ràng**: Phân biệt rõ edge detectors và mux/demux modules

## Lưu Ý

- Tất cả testbenches sử dụng relative paths để reference source files
- Khi thêm testbench mới, đặt vào đúng thư mục chức năng tương ứng
- `utils_tb_all.v` giữ ở root để dễ truy cập

