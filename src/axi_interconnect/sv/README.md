# SystemVerilog Source Code

Thư mục này chứa các file SystemVerilog (.sv) được chuyển đổi từ Verilog (.v).

## Cấu Trúc

```
sv/
├── packages/          # Packages và type definitions
│   └── axi_pkg.sv    # AXI4 package với constants, types, functions
│
├── interfaces/       # Interface definitions
│   └── axi4_if.sv    # AXI4 interface definitions cho tất cả channels
│
└── core/             # Core modules (đang chuyển đổi)
    └── (modules sẽ được thêm vào đây)
```

## Sử Dụng

### Import Package
```systemverilog
`include "axi_pkg.sv"
import axi_pkg::*;

// Sử dụng types và constants
axi_resp_t resp = AXI_RESP_OKAY;
axi_burst_t burst = AXI_BURST_INCR;
```

### Sử Dụng Interfaces
```systemverilog
`include "axi4_if.sv"

module my_module (
    axi4_if.master m_axi
);
    // Sử dụng m_axi.aw, m_axi.w, m_axi.b, m_axi.ar, m_axi.r
endmodule
```

## Compilation Order

1. Packages (`axi_pkg.sv`)
2. Interfaces (`axi4_if.sv`)
3. Modules sử dụng packages/interfaces

## Tương Thích

- SystemVerilog modules có thể instantiate Verilog modules
- Verilog modules có thể instantiate SystemVerilog modules (nếu signals compatible)
- Cần đảm bảo signal names và widths match khi mix Verilog và SystemVerilog

## Xem Thêm

- [SystemVerilog Migration Guide](../../../docs/SYSTEMVERILOG_MIGRATION.md)

