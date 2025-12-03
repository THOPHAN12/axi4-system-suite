# SystemVerilog Migration Guide

## Tổng Quan

Dự án đã được bắt đầu chuyển đổi từ Verilog (.v) sang SystemVerilog (.sv). Các file SystemVerilog được đặt trong thư mục `sv/` song song với các file Verilog gốc trong `rtl/`.

## Cấu Trúc Thư Mục

```
src/
├── axi_interconnect/
│   ├── rtl/              # Verilog files (gốc)
│   └── sv/               # SystemVerilog files (mới)
│       ├── packages/     # AXI packages và types
│       ├── interfaces/   # AXI interface definitions
│       └── core/         # Core modules (đang chuyển đổi)
│
└── wrapper/
    ├── systems/          # Verilog files (gốc)
    └── sv/               # SystemVerilog files (mới)
        └── systems/      # System modules (đang chuyển đổi)
```

## File Đã Chuyển Đổi

### 1. AXI Package (`src/axi_interconnect/sv/packages/axi_pkg.sv`)
- Package chứa constants, types, và functions cho AXI4
- Định nghĩa enums cho response codes, burst types, size encoding
- Helper functions để tính toán widths và sizes

### 2. AXI Interfaces (`src/axi_interconnect/sv/interfaces/axi4_if.sv`)
- Interface definitions cho tất cả AXI4 channels
- Modports cho master và slave
- Clocking blocks cho synchronous sampling

### 3. Wrapper Module (`src/wrapper/sv/systems/axi_interconnect_2m4s_wrapper.sv`)
- SystemVerilog version của `axi_interconnect_2m4s_wrapper.v`
- Sử dụng `logic` thay vì `wire`/`reg`
- Sử dụng `always_comb` cho combinational logic
- Parameters với type annotations (`int unsigned`, `logic`)

## Các Thay Đổi Chính

### 1. Signal Types
```verilog
// Verilog
input  wire [31:0] addr;
output reg  [31:0] data;

// SystemVerilog
input  logic [31:0] addr;
output logic [31:0] data;
```

### 2. Parameters
```verilog
// Verilog
parameter ADDR_WIDTH = 32;
parameter [31:0] BASE_ADDR = 32'h0000_0000;

// SystemVerilog
parameter int unsigned ADDR_WIDTH = 32;
parameter logic [31:0] BASE_ADDR = 32'h0000_0000;
```

### 3. Always Blocks
```verilog
// Verilog
always @(*) begin
    // combinational logic
end

always @(posedge clk or negedge rst) begin
    // sequential logic
end

// SystemVerilog
always_comb begin
    // combinational logic
end

always_ff @(posedge clk or negedge rst) begin
    // sequential logic
end
```

### 4. Local Parameters
```verilog
// Verilog
localparam DATA_BYTES = DATA_WIDTH / 8;

// SystemVerilog
localparam int unsigned DATA_BYTES = DATA_WIDTH / 8;
```

### 5. Enums và Types
```systemverilog
// SystemVerilog only
typedef enum logic [1:0] {
    STATE_IDLE = 2'b00,
    STATE_BUSY = 2'b01,
    STATE_DONE = 2'b10
} state_t;

state_t current_state;
```

## Hướng Dẫn Chuyển Đổi

### Bước 1: Đổi Extension
- Đổi `.v` thành `.sv`

### Bước 2: Thay Đổi Signal Types
- `wire` → `logic`
- `reg` → `logic`
- Giữ nguyên `input`/`output`/`inout`

### Bước 3: Cập Nhật Parameters
- Thêm type annotations: `int unsigned`, `logic [N:0]`
- Giữ nguyên default values

### Bước 4: Cập Nhật Always Blocks
- `always @(*)` → `always_comb`
- `always @(posedge clk)` → `always_ff @(posedge clk)`
- `always @(posedge clk or negedge rst)` → `always_ff @(posedge clk or negedge rst)`

### Bước 5: Cập Nhật Local Parameters
- Thêm type annotations nếu cần

### Bước 6: Import Packages (Nếu Cần)
```systemverilog
`include "axi_pkg.sv"
import axi_pkg::*;
```

### Bước 7: Sử Dụng Interfaces (Tùy Chọn)
- Có thể sử dụng AXI interfaces thay vì individual signals
- Cần refactor module để sử dụng interfaces

## Lưu Ý Quan Trọng

### 1. Tương Thích Ngược
- SystemVerilog modules có thể instantiate Verilog modules
- Verilog modules có thể instantiate SystemVerilog modules (nếu signals compatible)
- Cần đảm bảo signal names và widths match

### 2. Compilation Order
- Packages phải được compile trước modules sử dụng chúng
- Interfaces phải được compile trước modules sử dụng chúng

### 3. Tool Support
- Quartus II: Hỗ trợ SystemVerilog từ version 13.0+
- ModelSim: Hỗ trợ SystemVerilog đầy đủ
- Kiểm tra version của tool trước khi sử dụng

### 4. File Naming
- Giữ nguyên tên module
- Chỉ đổi extension từ `.v` sang `.sv`
- Đặt file mới trong thư mục `sv/` tương ứng

## Ví Dụ Chuyển Đổi

### Module Đơn Giản

**Verilog (`simple_module.v`):**
```verilog
module simple_module #(
    parameter WIDTH = 8
) (
    input  wire              clk,
    input  wire              rst_n,
    input  wire [WIDTH-1:0]  data_in,
    output reg  [WIDTH-1:0]  data_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 0;
        end else begin
            data_out <= data_in;
        end
    end

endmodule
```

**SystemVerilog (`simple_module.sv`):**
```systemverilog
module simple_module #(
    parameter int unsigned WIDTH = 8
) (
    input  logic              clk,
    input  logic              rst_n,
    input  logic [WIDTH-1:0]  data_in,
    output logic [WIDTH-1:0]  data_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= '0;
        end else begin
            data_out <= data_in;
        end
    end

endmodule
```

## Checklist Chuyển Đổi

- [ ] Đổi extension `.v` → `.sv`
- [ ] Thay `wire`/`reg` → `logic`
- [ ] Cập nhật parameters với type annotations
- [ ] Cập nhật `always @(*)` → `always_comb`
- [ ] Cập nhật `always @(posedge clk)` → `always_ff @(posedge clk)`
- [ ] Cập nhật local parameters
- [ ] Kiểm tra instantiation của modules khác
- [ ] Test compilation
- [ ] Test simulation (nếu có testbench)

## Modules Cần Chuyển Đổi

### Priority 1 (Core Modules)
- [ ] `AXI_Interconnect_Full.v` → `AXI_Interconnect_Full.sv`
- [ ] `AXI_Interconnect.v` → `AXI_Interconnect.sv`
- [ ] `AXI_Interconnect_2S_RDONLY.v` → `AXI_Interconnect_2S_RDONLY.sv`

### Priority 2 (Channel Controllers)
- [ ] `AR_Channel_Controller_Top.v` → `AR_Channel_Controller_Top.sv`
- [ ] `AW_Channel_Controller_Top.v` → `AW_Channel_Controller_Top.sv`
- [ ] `WD_Channel_Controller_Top.v` → `WD_Channel_Controller_Top.sv`
- [ ] `BR_Channel_Controller_Top.v` → `BR_Channel_Controller_Top.sv`
- [ ] `Controller.v` → `Controller.sv`

### Priority 3 (Arbitration)
- [ ] `Read_Arbiter.v` → `Read_Arbiter.sv`
- [ ] `Write_Arbiter.v` → `Write_Arbiter.sv`
- [ ] `Write_Arbiter_RR.v` → `Write_Arbiter_RR.sv`
- [ ] `Qos_Arbiter.v` → `Qos_Arbiter.sv`

### Priority 4 (Datapath)
- [ ] MUX modules
- [ ] DEMUX modules

### Priority 5 (Utilities)
- [ ] `Queue.v` → `Queue.sv`
- [ ] `Resp_Queue.v` → `Resp_Queue.sv`
- [ ] Edge detectors

## Tài Liệu Tham Khảo

- [SystemVerilog LRM](https://ieeexplore.ieee.org/document/8299595)
- [SystemVerilog for Design](https://www.springer.com/gp/book/9780387333991)
- [Verilog to SystemVerilog Migration](https://www.verilog.com/)

## Cập Nhật Project Files

Sau khi chuyển đổi, cần cập nhật:
- Quartus project files (`.qsf`) để include `.sv` files
- ModelSim project files để include `.sv` files
- Compilation scripts để compile packages trước

## Hỗ Trợ

Nếu gặp vấn đề trong quá trình chuyển đổi:
1. Kiểm tra syntax với linter
2. Kiểm tra compilation order
3. Kiểm tra tool version support
4. Xem các file đã chuyển đổi làm reference

