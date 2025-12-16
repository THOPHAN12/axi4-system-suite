# Waveform Configuration Guide

## Tổng Quan

Hướng dẫn sử dụng waveform configuration scripts để xem signals trong simulation.

## Files

1. **ModelSim**: `sim/modelsim/wave_dual_riscv_clean.do`
2. **Vivado**: `synthesis/scripts/vivado/setup_waveform.tcl`

## Cách Sử Dụng

### ModelSim

1. **Launch simulation**:
   ```tcl
   vsim work.dual_riscv_system_tb
   ```

2. **Load waveform config**:
   ```tcl
   do wave_dual_riscv_clean.do
   ```

3. **Run simulation**:
   ```tcl
   run 50us
   ```

### Vivado

1. **Launch simulation**:
   ```tcl
   launch_simulation
   ```

2. **Load waveform config**:
   ```tcl
   source setup_waveform.tcl
   ```

3. **Run simulation**:
   ```tcl
   run 50us
   ```

## Signals Được Hiển Thị

### Clock & Reset
- `ACLK` - System clock (100MHz)
- `ARESETN` - Active-low reset

### GPIO
- `gpio_out[31:0]` - GPIO output (hex)
- `gpio_in[31:0]` - GPIO input (hex)

### UART
- `uart_tx_valid` - UART transmit valid
- `uart_tx_byte[7:0]` - UART transmit byte (hex)

### SPI
- `spi_cs_n` - SPI chip select (active low)
- `spi_sclk` - SPI clock
- `spi_mosi` - SPI master out slave in
- `spi_miso` - SPI master in slave out

### SERV Core 0
- **Instruction Fetch (M0)**:
  - `serv0_M0_arvalid/arready` - Read address handshake
  - `serv0_M0_araddr[31:0]` - Read address (hex)
  - `serv0_M0_rvalid/rready` - Read data handshake
  - `serv0_M0_rdata[31:0]` - Read data (hex)

- **Data Write (M1)**:
  - `serv0_M1_awvalid/awready` - Write address handshake
  - `serv0_M1_awaddr[31:0]` - Write address (hex)
  - `serv0_M1_wvalid/wready` - Write data handshake
  - `serv0_M1_wdata[31:0]` - Write data (hex)

### SERV Core 1
- Tương tự SERV Core 0 (serv1_M0_*, serv1_M1_*)

### AXI Interconnect - Slaves
- **Slave 0 (RAM)**: `S0_*` signals
- **Slave 1 (GPIO)**: `S1_*` signals
- **Slave 2 (UART)**: `S2_*` signals
- **Slave 3 (SPI)**: `S3_*` signals

## Tùy Chỉnh Waveform

### Thêm Signals

**ModelSim**:
```tcl
add_wave /dual_riscv_system_tb/<signal_path>
```

**Vivado**:
```tcl
add_wave /dual_riscv_system_tb/<signal_path>
```

### Xóa Signals

**ModelSim**:
```tcl
delete_wave /dual_riscv_system_tb/<signal_path>
```

**Vivado**:
```tcl
# Select signal in waveform window and press Delete
# Or use TCL:
remove_wave [get_waves /dual_riscv_system_tb/<signal_path>]
```

### Thêm Divider

**ModelSim & Vivado**:
```tcl
add_wave -divider "Section Name"
```

### Thay Đổi Radix

**ModelSim & Vivado**:
```tcl
add_wave -radix hex /dual_riscv_system_tb/<signal>
add_wave -radix binary /dual_riscv_system_tb/<signal>
add_wave -radix unsigned /dual_riscv_system_tb/<signal>
```

## Lưu Waveform Config

### ModelSim

```tcl
# Save current waveform
write format wave -window .main_pane.wave.interior.cs.body.pw.wf <filename>.do
```

### Vivado

```tcl
# Save waveform config
save_wave_config waveform.wcfg
```

Load lại:
```tcl
open_wave_config waveform.wcfg
```

## Tips

1. **Zoom**: 
   - ModelSim: `wave zoom full`
   - Vivado: `wave zoom full`

2. **Cursor**:
   - ModelSim: Click vào waveform để đặt cursor
   - Vivado: Click vào waveform để đặt cursor

3. **Measure Time**:
   - ModelSim: Đặt 2 cursors và xem delta time
   - Vivado: Đặt 2 markers và xem delta time

4. **Find Signal**:
   - ModelSim: `find signals -name <pattern>`
   - Vivado: Use search box in Objects window

## Troubleshooting

### Signals hiển thị 'X' (unknown)

1. **Chạy simulation lâu hơn**:
   ```tcl
   run 10us
   ```

2. **Kiểm tra reset**:
   - Đảm bảo `ARESETN` được release sau 100ns
   - Xem console output: `"[100] Reset released - Starting simulation"`

3. **Kiểm tra clock**:
   - Đảm bảo `ACLK` đang toggle

### Signals không hiển thị

1. **Kiểm tra signal path**:
   ```tcl
   # ModelSim
   find signals -name <signal_name>
   
   # Vivado
   get_objects -r /dual_riscv_system_tb/<signal_path>
   ```

2. **Kiểm tra scope**:
   - Đảm bảo đang ở đúng scope trong simulation

### Waveform quá nhiều signals

1. **Xóa tất cả và thêm lại**:
   ```tcl
   # ModelSim
   delete_wave -all
   do wave_dual_riscv_clean.do
   
   # Vivado
   # Clear manually or reload config
   source setup_waveform.tcl
   ```

## Expected Results

Sau khi chạy simulation, bạn sẽ thấy:

1. **Clock**: `ACLK` toggle với period 10ns (100MHz)
2. **Reset**: `ARESETN` = 0 trong 100ns đầu, sau đó = 1
3. **GPIO**: `gpio_out` thay đổi khi cores write vào GPIO
4. **UART**: `uart_tx_valid` pulse khi có data, `uart_tx_byte` hiển thị character
5. **AXI Transactions**: Handshake signals (valid/ready) pulse khi có transactions
6. **Addresses**: AXI addresses hiển thị địa chỉ truy cập (RAM, GPIO, UART, SPI)



