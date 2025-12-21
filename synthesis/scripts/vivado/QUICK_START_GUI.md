# Hướng dẫn nhanh: Chạy Simulation trong Vivado GUI

## Các bước đơn giản:

### 1. Mở Project
- File > Open Project
- Chọn: `synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr`

### 2. Set Top Module (nếu chưa set)
- Flow Navigator > Simulation > sim_1 (click phải) > Simulation Settings
- Top module: `comprehensive_system_tb`
- Runtime: `11000ns`
- Click OK

### 3. Chạy Simulation
- Flow Navigator > Run Simulation > Run Behavioral Simulation
- Hoặc click nút **Run Simulation** (biểu tượng play) trên toolbar

### 4. Xem kết quả
- Transcript window sẽ hiển thị kết quả
- Kết quả mong đợi: **21/21 test cases PASS (100%)**

## Hoặc dùng TCL Console (nhanh hơn):

```tcl
# Nếu project chưa mở
open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr

# Set top và runtime
set_property top comprehensive_system_tb [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {11000ns} -objects [get_filesets sim_1]

# Chạy simulation
launch_simulation
run -all
```

## Kết quả mong đợi:

- **8 Test Scenarios**
- **21 Test Cases** (tất cả PASS)
- **100% Pass Rate**
- Simulation tự động kết thúc sau ~4795ns















