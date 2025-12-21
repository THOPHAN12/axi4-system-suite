# Hướng Dẫn Package AXI Interconnect thành IP

## Tổng Quan

Script này tự động package AXI Interconnect SystemVerilog module thành Vivado IP để có thể sử dụng trong Block Design.

## Yêu Cầu

- Vivado 2020.2 hoặc cao hơn
- SystemVerilog files trong `SystemVerilog/axi_interconnect/`

## Cách Sử Dụng

### Bước 1: Chạy Script Package IP

Mở Vivado và trong TCL Console:

```tcl
cd "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"
source package_axi_interconnect_ip.tcl
```

Script sẽ tự động:
1. ✅ Tạo thư mục IP repository: `synthesis/ip_repo/`
2. ✅ Tạo temporary project
3. ✅ Add tất cả AXI Interconnect source files
4. ✅ Package IP với tên: `axi_interconnect_2m4s`
5. ✅ Configure IP properties và parameters
6. ✅ Verify IP package

### Bước 2: Kiểm Tra IP Đã Package

Sau khi script chạy xong, kiểm tra:

```tcl
# Kiểm tra IP đã được tạo
set ip_dir "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/ip_repo/axi_interconnect_2m4s"
if {[file exists [file join $ip_dir "component.xml"]]} {
    puts "✓ IP đã được package thành công!"
} else {
    puts "✗ IP chưa được package"
}
```

### Bước 3: Add IP Repository vào Project

Sau khi package IP, add IP repository vào project của bạn:

**Cách A: Dùng GUI**
1. Settings → IP → Repository
2. Click `+` → Browse
3. Chọn: `C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/ip_repo`
4. OK → Apply → OK

**Cách B: Dùng TCL**
```tcl
set ip_repo_path "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/ip_repo"
set_property ip_repo_paths [list $ip_repo_path] [current_project]
update_ip_catalog
```

### Bước 4: Add IP vào Block Design

Sau khi add IP repository, bạn có thể add IP vào Block Design:

**Cách A: Dùng GUI**
1. Mở Block Design
2. Add IP → Tìm `axi_interconnect_2m4s`
3. Double-click để add

**Cách B: Dùng TCL**
```tcl
create_bd_cell -type ip -vlnv user.org:user:axi_interconnect_2m4s:1.0 axi_interconnect_0
```

## IP Information

- **IP Name**: `axi_interconnect_2m4s`
- **Display Name**: `AXI Interconnect 2M.4S`
- **VLNV**: `user.org:user:axi_interconnect_2m4s:1.0`
- **Location**: `synthesis/ip_repo/axi_interconnect_2m4s/`
- **Top Module**: `AXI_Interconnect`
- **Parameter**: `ARBITRATION_MODE` (default: 1 = ROUND_ROBIN)

## Cấu Trúc IP Package

Sau khi package, IP sẽ có cấu trúc:

```
synthesis/ip_repo/
└── axi_interconnect_2m4s/
    ├── component.xml          # IP definition file
    ├── xgui/                   # GUI files (if any)
    ├── hdl/                    # HDL files
    │   └── *.sv               # SystemVerilog source files
    └── ...
```

## Troubleshooting

### Lỗi: "Module not found"
- **Nguyên nhân**: Source files chưa được add đúng
- **Giải pháp**: Kiểm tra đường dẫn files trong script

### Lỗi: "IP packaging failed"
- **Nguyên nhân**: Temporary project có vấn đề
- **Giải pháp**: Xóa thư mục temp project và chạy lại script

### Lỗi: "IP not found in catalog"
- **Nguyên nhân**: IP repository chưa được add hoặc chưa update catalog
- **Giải pháp**: 
  ```tcl
  set_property ip_repo_paths [list $ip_repo_path] [current_project]
  update_ip_catalog
  ```

### IP không xuất hiện trong IP Catalog
1. Kiểm tra IP repository đã được add chưa
2. Chạy `update_ip_catalog`
3. Refresh IP Catalog (Window → IP Catalog → Refresh)

## Lưu Ý Quan Trọng

1. **SystemVerilog Support**: IP được package từ SystemVerilog, Vivado sẽ xử lý đúng
2. **Parameters**: Parameter `ARBITRATION_MODE` có thể được config khi instantiate IP
3. **Dependencies**: Tất cả dependency files đã được include trong IP package
4. **Re-package**: Nếu sửa source files, cần re-package IP

## Files Được Package

Script sẽ package tất cả files sau:
- Utils: Faling_Edge_Detc.sv, Raising_Edge_Det.sv
- Buffers: Queue.sv, Resp_Queue.sv
- Handshake: AW_HandShake_Checker.sv, WD_HandShake.sv, WR_HandShake.sv
- Arbitration: arbiter_fixed_priority.sv, arbiter_round_robin.sv, arbiter_qos_based.sv, read_arbiter.sv
- Datapath: Tất cả mux/demux modules
- Decoders: Tất cả decoder modules
- Channel Controllers: Tất cả controller modules
- Core: AXI_Interconnect_Full.sv, AXI_Interconnect.sv (top)

---

**Script Location**: `synthesis/scripts/vivado/package_axi_interconnect_ip.tcl`

**Last Updated**: 2025-01-XX










