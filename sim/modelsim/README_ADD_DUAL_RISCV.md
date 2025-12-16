# Hướng Dẫn Add Dual RISC-V System Files vào ModelSim

## Tổng Quan

Script `add_dual_riscv_files.tcl` sẽ tự động add tất cả các file Verilog liên quan đến `dual_riscv_axi_system` vào ModelSim project.

## Cách Sử Dụng

### Bước 1: Mở ModelSim

Mở ModelSim và cd vào thư mục project:
```tcl
cd C:/Users/Nguyen Ha Hai/axi4-system-suite/sim/modelsim
```

### Bước 2: Chạy Script

Trong ModelSim TCL Console, gõ:
```tcl
do add_dual_riscv_files.tcl
```

### Bước 3: Compile Files

Sau khi add files, compile tất cả:
```tcl
do compile_all_files.tcl
```

Hoặc compile thủ công:
- Trong ModelSim GUI: `Compile -> Compile All`
- Hoặc trong TCL: `vlog -work work [file paths]`

## Files Được Add

Script sẽ add các files theo thứ tự dependency:

### PART 1: SERV RISC-V Core Files
- serv_alu.v
- serv_bufreg.v
- serv_bufreg2.v
- serv_compdec.v
- serv_csr.v
- serv_ctrl.v
- serv_decode.v
- serv_immdec.v
- serv_mem_if.v
- serv_rf_if.v
- serv_rf_ram_if.v
- serv_rf_ram.v
- serv_rf_top.v
- serv_state.v
- serv_aligner.v
- serv_top.v

### PART 2: Wishbone to AXI Converters
- wb2axi_read.v
- wb2axi_write.v

### PART 3: SERV AXI Wrapper and Adapter
- serv_axi_wrapper.v
- serv_axi_dualbus_adapter.v

### PART 4-9: AXI Interconnect Components
- Utils (Raising_Edge_Det.v, Faling_Edge_Detc.v)
- Handshake (AW_HandShake_Checker.v, WD_HandShake.v, WR_HandShake.v)
- Buffers (Queue.v, Resp_Queue.v)
- Datapath (MUX/DEMUX modules)
- Decoders (Address decoders)
- Arbitration (Round-Robin, Fixed Priority, QoS)
- Channel Controllers (Read/Write controllers)

### PART 10: AXI Interconnect Core
- AXI_Interconnect.v

### PART 11: AXI-Lite Peripherals
- axi_lite_ram.v
- axi_lite_gpio.v
- axi_lite_uart.v
- axi_lite_spi.v

### PART 12: Top System Module
- dual_riscv_axi_system.v

## Kiến Trúc Hệ Thống

```
2 × SERV RISC-V Cores
        ↓
   serv_axi_wrapper (×2)
        ↓
   serv_axi_dualbus_adapter (×2)
        ↓
   AXI_Interconnect (Round-Robin)
        ↓
   ┌────┴────┬────┬────┐
 RAM    GPIO  UART  SPI
```

## Troubleshooting

### Lỗi: "Project file not found"
- Script sẽ tự động tạo project mới nếu không tìm thấy
- Hoặc tạo project thủ công: `project new AXI_Project.mpf`

### Lỗi: "File not found"
- Kiểm tra đường dẫn trong script
- Đảm bảo bạn đã clone đầy đủ repository

### Lỗi khi compile
- Kiểm tra thứ tự compile (phải compile dependencies trước)
- Xem `compile_all_files.tcl` để biết thứ tự đúng

## Notes

- Script chỉ add files vào project, không compile
- Phải compile files sau khi add
- Files được add theo thứ tự dependency để dễ debug

## Xem Thêm

- `compile_all_files.tcl` - Script compile tất cả files
- `simulate_dual_riscv.tcl` - Script chạy simulation
- `verification/testbenches/system_tb/README.md` - Hướng dẫn testbench

