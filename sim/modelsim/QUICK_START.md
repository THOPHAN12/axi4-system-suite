# Quick Start - Dual RISC-V System Simulation

## Chạy Simulation - 2 Bước Đơn Giản

### Bước 1: Mở ModelSim
Mở project ModelSim của bạn hoặc cd vào thư mục:
```
cd C:/Users/Nguyen Ha Hai/axi4-system-suite/sim/modelsim
```

### Bước 2: Chạy Script
Trong ModelSim TCL console, gõ:
```tcl
do simulate_dual_riscv.tcl
```

**Xong!** Script sẽ tự động:
- ✅ Compile tất cả files (nếu cần)
- ✅ Compile testbench
- ✅ Load test program vào RAM
- ✅ Start simulation
- ✅ Setup waveforms
- ✅ Run 50us

## Kết Quả Mong Đợi

Bạn sẽ thấy trong console:
```
[100] Reset released - Starting simulation
Hi!
[...] GPIO Output: 0xDEADBEEF
```

Và waveform window hiển thị:
- 2 SERV RISC-V cores đang chạy
- AXI transactions
- UART output
- GPIO changes

## Commands Hữu Ích

```tcl
# Tiếp tục simulation
run 10us

# Chạy đến hết
run -all

# Restart simulation
restart -f

# Xem waveform
view wave

# Reload wave config
do wave_dual_riscv.do
```

## Nếu Có Lỗi

### Lỗi: "Design not compiled"
```tcl
do compile_all_files.tcl
```

### Lỗi: "Testbench not found"
Check rằng file tồn tại:
```tcl
file exists ../verification/testbenches/system_tb/dual_riscv_system_tb.v
```

### Lỗi: "Cannot load hex file"
Check đường dẫn:
```tcl
file exists ../verification/programs/simple_test.hex
```

## Kiến Trúc Hệ Thống

```
2 SERV RISC-V Cores
        ↓
   AXI Interconnect (Round-Robin)
        ↓
    ┌───┴───┬───┬───┐
  RAM   GPIO UART SPI
  8KB   I/O   TX   CS
```

## Address Map

| Device | Address        |
|--------|----------------|
| RAM    | 0x0000_0000    |
| GPIO   | 0x4000_0000    |
| UART   | 0x8000_0000    |
| SPI    | 0xC000_0000    |

## Test Program

File `simple_test.hex` thực hiện:
1. Write 0xDEADBEEF → GPIO
2. Write "Hi!\n" → UART
3. Loop

## Debugging

### Xem RAM contents:
```tcl
examine -radix hex /dual_riscv_system_tb/dut/u_sram/mem(0)
```

### Xem SERV core state:
```tcl
add wave /dual_riscv_system_tb/dut/u_serv0/*
```

### Monitor UART output:
UART output tự động hiển thị trong console!

## Documentation Đầy Đủ

- Testbench: `verification/testbenches/system_tb/README.md`
- Architecture: `docs/architecture/`
- Source code: `src/systems/dual_riscv_axi_system.v`

## Tạo Test Program Mới

1. Viết RISC-V assembly
2. Convert sang hex format
3. Save vào `verification/programs/your_test.hex`
4. Run:
```tcl
vsim work.dual_riscv_system_tb -G RAM_INIT_HEX=verification/programs/your_test.hex
```

## Performance Tips

Để simulation nhanh hơn:
```tcl
# Chạy không GUI (batch mode)
vsim -c work.dual_riscv_system_tb
run -all
quit -f
```

Hoặc giảm logging:
```tcl
# Trong testbench, comment out các $display không cần thiết
```

## Next Steps

1. ✅ Chạy simulation cơ bản
2. 🔄 Modify test program
3. 🔄 Test cả 2 cores cùng lúc
4. 🔄 Test SPI transactions
5. 🔄 Verify round-robin arbitration

---

**Chúc bạn simulation thành công! 🚀**

Nếu cần hỗ trợ, check `README.md` trong thư mục testbench.

