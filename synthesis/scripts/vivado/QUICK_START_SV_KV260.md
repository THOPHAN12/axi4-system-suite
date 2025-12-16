# 🚀 Quick Start: Tạo Vivado Project SystemVerilog cho KV260

**Mục đích**: Hướng dẫn nhanh tạo và chạy simulation cho các module SystemVerilog trên Vivado với target KV260.

**Thời gian**: ~5 phút

---

## 📋 Yêu Cầu

- ✅ Vivado đã cài đặt (WebPack hoặc bản cao hơn)
- ✅ Dự án đã có các file `.sv` trong thư mục `SystemVerilog/`
- ✅ Testbench SystemVerilog (nếu có)

---

## 🎯 Bước 1: Mở Vivado và Tạo Project

### Cách 1: Dùng Script TCL (Nhanh nhất ⚡)

1. **Mở Vivado**
   - Khởi động Vivado
   - Chọn "Open Tcl Shell" hoặc mở TCL Console

2. **Chạy script tạo project**:
   ```tcl
   cd C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado
   source create_sv_kv260_project.tcl
   ```

   Script sẽ tự động:
   - ✅ Tạo project mới: `axi4_system_sv_kv260`
   - ✅ Set target device: KV260 (xczu5ev-sfvc784-1-e)
   - ✅ Add tất cả file `.sv` từ thư mục `SystemVerilog/`
   - ✅ Setup simulation environment

### Cách 2: Tạo Project Thủ Công (Nếu cần tùy chỉnh)

1. **Tạo Project**:
   - `File → New Project`
   - Project name: `axi4_system_sv_kv260`
   - Project location: `synthesis/scripts/vivado/`
   - Project type: `RTL Project`
   - Add sources: **Bỏ qua** (sẽ add sau)
   - Add constraints: **Bỏ qua**
   - Default Part: Chọn **Kria KV260** hoặc tìm `xczu5ev-sfvc784-1-e`

2. **Add SystemVerilog Files**:
   - `Add Sources → Add or create design sources`
   - Click `Add Files`
   - Chọn tất cả file `.sv` từ:
     - `SystemVerilog/axi_interconnect/**/*.sv`
     - `SystemVerilog/axi_bridge/*.sv`
     - `SystemVerilog/axi_masters/*.sv`
     - `SystemVerilog/peripherals/**/*.sv`
   - Click `Finish`

3. **Add Testbenches** (nếu có):
   - `Add Sources → Add or create simulation sources`
   - Add các file testbench `.sv`
   - Set testbench làm simulation top

---

## 🔧 Bước 2: Setup Project Properties

### Set Target Device (KV260)

Trong TCL Console:
```tcl
set_property part xczu5ev-sfvc784-1-e [current_project]
```

Hoặc trong GUI:
- `Settings → Project Settings → General → Project device`
- Chọn: `xczu5ev-sfvc784-1-e`

### Set SystemVerilog Language

```tcl
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
```

### Set Include Directories (nếu cần)

```tcl
set_property include_dirs {
    SystemVerilog/axi_interconnect
    SystemVerilog/axi_bridge
} [current_fileset]
```

---

## 🧪 Bước 3: Setup Simulation

### Option A: Dùng Script (Nhanh)

**Quan trọng**: Đảm bảo bạn đang ở đúng thư mục trước khi chạy:

```tcl
# Chuyển đến thư mục scripts
cd C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado

# Set testbench name
set tb Raising_Edge_Det_tb

# Chạy script
source run_sv_simulation.tcl
```

Hoặc dùng đường dẫn đầy đủ:

```tcl
set tb Raising_Edge_Det_tb
source C:/Users/Nguyen\ Ha\ Hai/axi4-system-suite/synthesis/scripts/vivado/run_sv_simulation.tcl
```

### Option B: Setup Thủ Công

1. **Set Simulation Top**:
   ```tcl
   set_property top <testbench_name> [get_filesets sim_1]
   set_property top_lib xil_defaultlib [get_filesets sim_1]
   ```

2. **Set Simulation Properties**:
   ```tcl
   # Enable SystemVerilog support
   set_property -name {xsim.compile.xvlog.more_options} -value {-sv} [get_filesets sim_1]
   
   # Enable debug logging
   set_property -name {xsim.elaborate.debug_level} -value {all} [get_filesets sim_1]
   set_property -name {xsim.simulate.log_all_signals} -value {true} [get_filesets sim_1]
   
   # Set simulation runtime
   set_property -name {xsim.simulate.runtime} -value {1000ns} [get_filesets sim_1]
   ```

3. **Launch Simulation**:
   ```tcl
   launch_simulation
   ```

   Hoặc trong GUI:
   - `Flow → Run Simulation → Run Behavioral Simulation`

---

## ▶️ Bước 4: Chạy Simulation

### Trong Simulation Console:

```tcl
# Chạy simulation
run 1000ns

# Hoặc chạy đến hết
run -all

# Restart simulation
restart

# Xem waveform
add_wave -radix hex /<testbench_name>/*
```

### Thêm Signals vào Waveform:

```tcl
# Add tất cả signals
add_wave -radix hex /<testbench_name>/*

# Hoặc add từng signal cụ thể
add_wave /<testbench_name>/ACLK
add_wave /<testbench_name>/ARESETN
add_wave /<testbench_name>/<signal_name>
```

---

## 📝 Bước 5: Tạo Testbench (Nếu chưa có)

### Ví dụ Testbench Đơn Giản:

Tạo file: `SystemVerilog/testbenches/axi_interconnect/utils/Raising_Edge_Det_tb.sv`

```systemverilog
`timescale 1ns/1ps

module Raising_Edge_Det_tb;

    // Clock and reset
    logic ACLK = 0;
    logic ARESETN = 1;
    logic Test_Signal = 0;
    logic Raising;

    // Clock generation
    always #5 ACLK = ~ACLK;

    // DUT instantiation
    Raising_Edge_Det dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .Test_Singal(Test_Signal),
        .Raisung(Raising)
    );

    // Test sequence
    initial begin
        $display("=== Raising_Edge_Det Testbench ===");
        
        // Reset
        ARESETN = 0;
        #20;
        ARESETN = 1;
        #10;

        // Test rising edge detection
        Test_Signal = 0;
        #20;
        Test_Signal = 1;  // Rising edge
        #10;
        assert (Raising == 1) else $error("Raising edge not detected!");
        
        #10;
        Test_Signal = 0;
        #10;
        Test_Signal = 1;  // Another rising edge
        #10;
        assert (Raising == 1) else $error("Raising edge not detected!");

        #100;
        $display("=== Test Passed ===");
        $finish;
    end

endmodule
```

Sau đó:
1. Add file vào project: `Add Sources → Add or create simulation sources`
2. Set làm simulation top: `set_property top Raising_Edge_Det_tb [get_filesets sim_1]`
3. Run simulation

---

## 🎨 Bước 6: Xem Waveform

### Trong Simulation Window:

1. **Thêm signals**:
   - Right-click vào signal trong `Scope` panel
   - Chọn `Add to Wave Window`
   - Hoặc dùng TCL: `add_wave <signal_path>`

2. **Zoom và Navigate**:
   - `Zoom Fit`: Hiển thị toàn bộ waveform
   - `Zoom In/Out`: Phóng to/thu nhỏ
   - `Pan`: Di chuyển waveform

3. **Radix**:
   - Right-click signal → `Radix` → Chọn format (Binary, Hex, Decimal, etc.)

---

## ⚡ Quick Commands Cheat Sheet

### Project Management:
```tcl
# Mở project
open_project synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.xpr

# Đóng project
close_project

# Lưu project
save_project
```

### Simulation:
```tcl
# Launch simulation
launch_simulation

# Run simulation
run 1000ns        # Run 1000 nanoseconds
run -all          # Run until finish
run -continue     # Continue from current time

# Restart
restart

# Close simulation
close_sim
```

### Waveform:
```tcl
# Add signals
add_wave /<testbench>/*
add_wave -radix hex /<testbench>/<signal>

# Zoom
wave zoom full    # Fit to window
wave zoom in      # Zoom in
wave zoom out     # Zoom out

# Reload waveform
reload_wave
```

### Debug:
```tcl
# Log all signals
log_wave -r /*

# Check signal value
examine /<testbench>/<signal>

# Set breakpoint (limited support in XSim)
# Note: XSim has limited breakpoint support
```

---

## 🔍 Troubleshooting

### ❌ Lỗi: "File not found"
**Giải pháp**:
- Kiểm tra đường dẫn file trong project
- Đảm bảo file `.sv` đã được add vào project
- Check file paths trong TCL console: `get_files`

### ❌ Lỗi: "Syntax error in SystemVerilog"
**Giải pháp**:
- Kiểm tra file có extension `.sv` (không phải `.v`)
- Đảm bảo đã set SystemVerilog mode: `set_property -name {xsim.compile.xvlog.more_options} -value {-sv}`
- Check syntax trong Messages panel

### ❌ Lỗi: "Module not found"
**Giải pháp**:
- Kiểm tra tất cả dependencies đã được add vào project
- Check include directories
- Verify module names match file names

### ❌ Lỗi: "Simulation top not set"
**Giải pháp**:
```tcl
set_property top <testbench_name> [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
```

### ❌ Simulation chạy quá chậm
**Giải pháp**:
- Giảm simulation time
- Tắt logging không cần thiết
- Sử dụng batch mode (không GUI)

### ❌ Lỗi: "The process cannot access the file because it is being used by another process"
**Nguyên nhân**: File log đang bị khóa bởi simulation trước đó chưa đóng đúng cách.

**Giải pháp**:
```tcl
# Cách 1: Chạy script fix
source fix_simulation_lock.tcl

# Cách 2: Đóng simulation thủ công
close_sim -force
after 500  ;# Đợi file handles release

# Cách 3: Nếu vẫn lỗi, restart Vivado
# Hoặc đóng tất cả cửa sổ simulation và thử lại
```

**Lưu ý**: 
- Đảm bảo đóng tất cả cửa sổ simulation trước khi chạy simulation mới
- Nếu dùng GUI, đóng Simulation window trước khi chạy lại

### ❌ Lỗi: "File or Directory 'C:/Users/Nguyen' does not exist"
**Nguyên nhân**: Đường dẫn có khoảng trắng không được xử lý đúng.

**Giải pháp**:
```tcl
# Dùng file join và file normalize
set project_root [file normalize {C:/Users/Nguyen Ha Hai/axi4-system-suite}]
set tb_file [file join $project_root SystemVerilog testbenches ...]

# Hoặc dùng script đơn giản
source add_and_run_tb.tcl
```

### ❌ Lỗi: "Unknown option '-fileset'"
**Nguyên nhân**: Cú pháp `get_files` sai.

**Giải pháp**:
```tcl
# SAI:
get_files -fileset sim_1 ...

# ĐÚNG:
get_files -of_objects [get_filesets sim_1] ...
```

### ❌ Lỗi: "Unable to auto find GCC executables"
**Nguyên nhân**: SystemVerilog có thể cần GCC cho một số tính năng (thường không cần).

**Giải pháp**:
- Lỗi này thường là warning, không ảnh hưởng đến simulation
- Nếu cần, cài đặt MinGW-w64 hoặc MSYS2
- Hoặc bỏ qua nếu simulation vẫn chạy được

---

## 📂 Cấu Trúc Project Sau Khi Tạo

```
synthesis/scripts/vivado/
├── axi4_system_sv_kv260/              # Project directory
│   ├── axi4_system_sv_kv260.xpr       # Vivado project file
│   ├── axi4_system_sv_kv260.srcs/     # Source files
│   │   ├── sources_1/                 # Design sources (.sv files)
│   │   └── sim_1/                     # Simulation sources (testbenches)
│   ├── axi4_system_sv_kv260.sim/      # Simulation results
│   └── axi4_system_sv_kv260.cache/    # Cache files
├── create_sv_kv260_project.tcl        # Script tạo project
├── run_sv_simulation.tcl              # Script chạy simulation
└── QUICK_START_SV_KV260.md            # File này
```

---

## 🎯 Workflow Nhanh (Tóm Tắt)

```tcl
# 1. Tạo project (1 lần)
cd C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado
source create_sv_kv260_project.tcl

# 2. Mở project (mỗi lần làm việc)
open_project axi4_system_sv_kv260/axi4_system_sv_kv260.xpr

# 3. Chạy simulation
source run_sv_simulation.tcl -tb <testbench_name>

# Hoặc manual:
set_property top <testbench_name> [get_filesets sim_1]
launch_simulation
run 1000ns
```

---

## 📚 Tài Liệu Tham Khảo

- **Vivado Design Suite User Guide**: UG910
- **XSim User Guide**: UG900
- **SystemVerilog Support**: Vivado hỗ trợ đầy đủ SystemVerilog IEEE 1800-2012
- **KV260 Documentation**: [Xilinx Kria KV260](https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit.html)

---

## ✅ Checklist

- [ ] Vivado đã cài đặt
- [ ] Project đã được tạo
- [ ] Tất cả file `.sv` đã được add
- [ ] Testbench đã được tạo và add
- [ ] Simulation top đã được set
- [ ] Simulation chạy thành công
- [ ] Waveform hiển thị đúng

---

**🎉 Chúc bạn simulation thành công!**

Nếu có vấn đề, check phần Troubleshooting hoặc xem Messages panel trong Vivado.


