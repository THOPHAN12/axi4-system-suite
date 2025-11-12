# Quartus Project Guide

## Tổng Quan

Thư mục này chứa Quartus project và các script để quản lý project.

## Cấu Trúc Files

### Project Files (QUAN TRỌNG - KHÔNG XÓA)
- `AXI_PROJECT.qpf` - Quartus project file
- `AXI_PROJECT.qsf` - Quartus settings file
- `AXI_PROJECT.qws` - Quartus workspace file

### Build Directories (QUAN TRỌNG - KHÔNG XÓA)
- `db/` - Quartus database (chứa compilation results)
- `incremental_db/` - Incremental compilation database
- `output_files/` - Output files (bitstream, reports, etc.)

### Scripts

#### File Chính - Dùng Hàng Ngày
- `add_files.tcl` ⭐ **DÙNG FILE NÀY**
  - Tự động thêm file mới vào project
  - Chỉ thêm file chưa có trong project
  - Có thể chạy nhiều lần mà không bị duplicate
  - Tự động bỏ qua testbench và backup files
  - Bao gồm tất cả modules: SERV, AXI Interconnect, Wrappers, IP modules, ALU Master, Memory Slaves

#### File Backup
- `add_all_source_files.tcl`
  - Thêm tất cả file theo danh sách cụ thể
  - Dùng khi muốn reset lại project
  - Set top-level entity
  - Thêm file theo thứ tự compile đúng

## Quick Start

### 1. Mở Project

```bash
# Mở Quartus
quartus AXI_PROJECT.qpf
```

### 2. Thêm File Mới

```tcl
# Trong Quartus TCL Console
cd D:/AXI/sim/quartus
source add_files.tcl
```

### 3. Compile Project

- Trong Quartus GUI: Processing → Start Compilation
- Hoặc dùng TCL: `execute_module -tool map`

## Workflow Đề Xuất

### Lần Đầu Setup

1. Mở Quartus project
2. Chạy `add_all_source_files.tcl` để thêm tất cả file
3. Set top-level entity nếu cần (mặc định: `dual_master_system_ip`)
4. Compile project

### Hàng Ngày

1. Mở Quartus project
2. Nếu có file mới: Chạy `add_files.tcl`
3. Compile và test

### Khi Có File Mới

1. Mở project
2. Chạy `add_files.tcl` để add file mới
3. Hoặc dùng GUI: Project → Add/Remove Files in Project

## Top-Level Entity Options

Các top-level modules có sẵn:

1. **dual_master_system_ip** ⭐ **KHUYẾN NGHỊ** (Mặc định)
   - Complete IP module với SERV + ALU Master
   - Integrated memory slaves
   - No external connections needed

2. **serv_axi_system_ip**
   - SERV RISC-V IP module
   - Integrated instruction và data memory

3. **dual_master_system**
   - SERV + ALU Master với external memory slaves

4. **serv_axi_system**
   - SERV RISC-V với external memory slaves

5. **serv_axi_wrapper**
   - Standalone SERV wrapper

6. **alu_master_system**
   - ALU Master system

7. **AXI_Interconnect_Full**
   - Chỉ AXI Interconnect

Để thay đổi top-level entity, sửa trong `add_all_source_files.tcl` hoặc trong Quartus GUI:
- Project → Set as Top-Level Entity

## File Quan Trọng (KHÔNG XÓA)

- `*.qpf`, `*.qsf`, `*.qws` - Project files
- `db/` - Database (chứa compilation results)
- `incremental_db/` - Incremental compilation
- `output_files/` - Output files (bitstream, reports)
- `add_files.tcl` - Script chính
- `add_all_source_files.tcl` - Backup script

## File Có Thể Xóa (Tự Động Tạo Lại)

- `db/` - Có thể xóa và compile lại (nhưng mất thời gian)
- `incremental_db/` - Có thể xóa
- `output_files/` - Có thể regenerate bằng cách compile lại

## Scripts Chi Tiết

### `add_files.tcl`

**Mục đích**: Tự động thêm file mới vào project

**Tính năng**:
- Tự động quét tất cả file .v trong project
- Chỉ thêm file mới (chưa có trong project)
- Có thể chạy nhiều lần mà không bị duplicate
- Tự động bỏ qua testbench và backup files
- Quét các thư mục:
  - SERV Core files
  - AXI Interconnect files
  - Wrapper files (bao gồm IP modules)
  - Master ALU files
  - Slave Memory files

**Cách dùng**:
```tcl
source add_files.tcl
```

**Khi nào dùng**: Mỗi khi có file mới hoặc muốn đảm bảo tất cả file đã được thêm

### `add_all_source_files.tcl`

**Mục đích**: Thêm tất cả file theo danh sách cụ thể

**Tính năng**:
- Thêm file theo thứ tự compile đúng
- Kiểm soát chính xác file nào được thêm
- Set top-level entity (mặc định: `dual_master_system_ip`)
- Thêm file theo thứ tự:
  1. SERV RISC-V Core files
  2. Wishbone to AXI Converters
  3. SERV AXI Wrapper
  4. AXI Interconnect (utils → handshake → buffers → arbitration → datapath → decoders → controllers → core)
  5. System Integration Modules (bao gồm IP modules)
  6. Memory Slaves
  7. Master ALU files
  8. Slave Memory files

**Cách dùng**:
```tcl
source add_all_source_files.tcl
```

**Khi nào dùng**: 
- Khi muốn reset lại project
- Khi muốn đảm bảo thứ tự compile đúng
- Khi `add_files.tcl` không hoạt động

## Modules Được Thêm

### SERV RISC-V Core
- serv_state.v, serv_immdec.v, serv_decode.v, serv_alu.v, serv_ctrl.v, serv_csr.v
- serv_bufreg.v, serv_bufreg2.v, serv_aligner.v
- serv_mem_if.v, serv_rf_if.v, serv_rf_ram_if.v, serv_rf_ram.v
- serv_rf_top.v, serv_top.v

### AXI Interconnect
- Utilities, Handshake, Buffers, Arbitration
- Datapath (MUX/DEMUX), Decoders
- Channel Controllers (Write/Read)
- Core modules (AXI_Interconnect_Full, etc.)

### Wrapper & IP Modules
- wb2axi_read.v, wb2axi_write.v
- serv_axi_wrapper.v
- serv_axi_system.v
- serv_axi_system_ip.v ⭐ **MỚI**
- dual_master_system.v
- dual_master_system_ip.v ⭐ **MỚI**
- alu_master_system.v
- axi_rom_slave.v, axi_memory_slave.v

### Master ALU
- ALU_Core.v
- CPU_Controller.v
- CPU_ALU_Master.v
- Simple_AXI_Master_Test.v

### Slave Memory
- Simple_Memory_Slave.v

## Lưu Ý

- Tất cả scripts tự động bỏ qua:
  - Testbench files (`*_tb.v`, `*_test.v`)
  - Backup files (`*.bak`)
  - Thư mục không cần thiết (bench, test, tb, work, build, etc.)

- Scripts tự động set:
  - Include directories (SEARCH_PATH)
  - Top-level entity (trong `add_all_source_files.tcl`)

## Troubleshooting

### Lỗi: "Project not found"
- Kiểm tra file `AXI_PROJECT.qpf` có tồn tại
- Mở project từ Quartus GUI

### Lỗi: "File not found"
- Kiểm tra file có tồn tại trong project
- Chạy `add_files.tcl` để add file

### Lỗi: "Top-level entity not found"
- Set top-level entity trong Project Settings
- Hoặc chạy `add_all_source_files.tcl` (tự động set)

### Lỗi: "Design unit not found"
- Kiểm tra file đã được thêm vào project chưa
- Kiểm tra thứ tự compile (dependencies phải compile trước)
- Chạy `add_all_source_files.tcl` để đảm bảo thứ tự đúng

### Lỗi: "Cannot convert all sets of registers into RAM megafunctions"
- **Nguyên nhân**: Memory arrays được implement bằng registers thay vì RAM blocks
- **Giải pháp**: 
  - Memory modules đã được cập nhật với synthesis attributes `(* ramstyle = "M9K" *)`
  - Nếu vẫn gặp lỗi, giảm memory size trong `dual_master_system_ip.v`
  - Xem chi tiết trong `MEMORY_OPTIMIZATION.md`

### Lỗi: "Fitter requires X LABs but device contains only Y LABs"
- **Nguyên nhân**: Design quá lớn cho device hiện tại
- **Giải pháp**: 
  - Memory size mặc định đã được giảm từ 1024 xuống 256 words
  - Nếu vẫn gặp lỗi, giảm thêm memory size hoặc disable unused features
  - Xem chi tiết trong `RESOURCE_OPTIMIZATION.md`
