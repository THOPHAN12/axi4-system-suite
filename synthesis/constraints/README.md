# AXI Interconnect Constraints for KV260

## Tổng Quan

File constraints này được thiết kế cho **Xilinx KV260 Kria Vision AI Starter Kit** với device **xczu5ev-sfvc784-1-e** (Zynq UltraScale+).

## File Constraints

### `axi_interconnect.xdc`

File constraints chính chứa:
- **Clock constraints**: ACLK @ 100MHz (có thể điều chỉnh)
- **Reset constraints**: ARESETN với async reset handling
- **I/O delays**: Input/Output delays cho masters và slaves
- **Timing exceptions**: False paths và timing exceptions (optional)

## Cách Sử Dụng

### 1. Thêm Constraints vào Project

**Cách A: Sử dụng TCL Script (Khuyến nghị)**
```tcl
# Trong Vivado TCL Console
source synthesis/scripts/vivado/add_constraints.tcl
```

**Cách B: Thêm thủ công trong GUI**
1. Mở project trong Vivado
2. Flow Navigator > Add Sources
3. Add or Create Constraints
4. Add Files → chọn `synthesis/constraints/axi_interconnect.xdc`
5. Finish

### 2. Điều Chỉnh Clock Frequency

Mặc định: **100MHz** (10ns period)

Để thay đổi, sửa dòng 15 trong `axi_interconnect.xdc`:
```tcl
# 100MHz (mặc định)
create_clock -period 10.000 -name ACLK [get_ports ACLK]

# 150MHz
create_clock -period 6.667 -name ACLK [get_ports ACLK]

# 200MHz
create_clock -period 5.000 -name ACLK [get_ports ACLK]

# 250MHz
create_clock -period 4.000 -name ACLK [get_ports ACLK]
```

**KV260 Clock Frequencies phổ biến:**
- **50MHz**: -period 20.000
- **100MHz**: -period 10.000 (mặc định)
- **150MHz**: -period 6.667
- **200MHz**: -period 5.000

### 3. Điều Chỉnh I/O Delays

Nếu masters/slaves nằm trong cùng FPGA (PL), bạn có thể comment out các I/O delays (dòng 40-120).

Nếu masters/slaves là external, điều chỉnh giá trị delay:
```tcl
# Max delay: 2.0ns (conservative)
# Min delay: 0.5ns (conservative)
set_input_delay -clock ACLK -max 2.0 [get_ports M0_AWADDR*]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_AWADDR*]
```

### 4. Chạy Synthesis với Constraints

```tcl
# Trong Vivado TCL Console
source synthesis/scripts/vivado/run_synthesis.tcl
```

Hoặc trong GUI:
1. Flow Navigator > Synthesis > Run Synthesis

## Cấu Trúc Constraints

### 1. Clock Constraints (Dòng 12-25)
- Định nghĩa clock ACLK
- Clock uncertainty (jitter + skew)
- Clock latency (nếu cần)

### 2. Reset Constraints (Dòng 30-40)
- Async reset handling
- Reset recovery/removal time
- False paths cho reset

### 3. I/O Delays (Dòng 45-120)
- Input delays cho Master 0 và Master 1
- Output delays cho Slave 0, 1, 2, 3
- Address, Data, và Control signals

### 4. Timing Exceptions (Dòng 125-150)
- False paths (commented out - chỉ dùng nếu cần)
- Max/Min delays (optional)

## Kiểm Tra Timing

Sau khi synthesis:

1. **Xem Timing Report:**
   ```tcl
   open_run synth_1
   report_timing_summary
   ```

2. **Xem Utilization Report:**
   ```tcl
   report_utilization
   ```

3. **Kiểm tra Timing Violations:**
   - Nếu có violations, điều chỉnh constraints
   - Có thể cần thêm false paths
   - Có thể cần điều chỉnh clock frequency

## Lưu Ý Quan Trọng

### 1. Clock Frequency
- **100MHz** là tần số an toàn và phổ biến cho AXI4
- Nếu cần performance cao hơn, có thể tăng lên 150MHz hoặc 200MHz
- Kiểm tra timing reports sau khi thay đổi

### 2. I/O Delays
- Nếu design chỉ có PL (không có external masters/slaves), comment out I/O delays
- Nếu có external interfaces, điều chỉnh delays dựa trên datasheet

### 3. Reset
- ARESETN là async reset - đã set false paths
- Đảm bảo design có reset synchronizers

### 4. PS Integration
- Nếu kết nối với PS (Processing System), clock sẽ từ PS
- Có thể cần điều chỉnh clock constraints
- Sử dụng Xilinx AXI Interconnect IP nếu cần

## Troubleshooting

### Lỗi: "Clock not found"
- Kiểm tra port name: `ACLK`
- Đảm bảo port được declare trong top module

### Lỗi: "Port not found" trong I/O delays
- Nếu masters/slaves là internal, comment out I/O delays
- Hoặc điều chỉnh port names cho đúng

### Timing Violations
1. Kiểm tra clock frequency - có thể cần giảm
2. Kiểm tra I/O delays - có thể cần điều chỉnh
3. Thêm false paths nếu cần (uncomment các dòng trong Timing Exceptions)

### Synthesis Fails
1. Kiểm tra syntax errors trong RTL
2. Kiểm tra constraints file syntax
3. Xem log file: `axi4_system_sv_kv260.runs/synth_1/runme.log`

## Files

```
synthesis/
├── constraints/
│   ├── axi_interconnect.xdc    # Main constraints file
│   └── README.md                # This file
└── scripts/
    └── vivado/
        ├── add_constraints.tcl  # Script to add constraints
        └── run_synthesis.tcl     # Script to run synthesis
```

## Tài Liệu Tham Khảo

- **KV260 User Guide**: Xilinx Kria KV260 Vision AI Starter Kit
- **Vivado Constraints Guide**: UG949 - Vivado Design Suite User Guide
- **AXI4 Protocol**: ARM AMBA AXI4 Protocol Specification

---

**AXI4 System Suite - KV260 Constraints**

















