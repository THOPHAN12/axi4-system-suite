# Hướng Dẫn Sử Dụng AXI Master Bridge

## Tổng Quan

**AXI Master Bridge** là một IP custom được tạo để thay thế SmartConnect trong Block Design, kết nối Zynq PS AXI Masters với Custom AXI Interconnect.

## Kiến Trúc

```
┌──────────────┐
│  Zynq PS     │
│  M_AXI_HPM0  │──┐
│  M_AXI_HPM1  │──┤
└──────────────┘  │
                  │
        ┌─────────▼─────────┐
        │ AXI Master Bridge │  ← Custom Bridge (thay SmartConnect)
        │   Bridge_0 & _1   │
        └─────────┬─────────┘
                  │
        ┌─────────▼─────────┐
        │ AXI_Interconnect  │  ← Your custom IP
        │     (2M × 4S)     │
        └─────────┬─────────┘
```

## Quy Trình Sử Dụng

### Bước 1: Package AXI Master Bridge IP

Chạy script package IP:

```tcl
cd "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"
source package_axi_master_bridge_ip.tcl
```

Script sẽ:
- ✅ Tạo IP từ module `axi_master_bridge.sv`
- ✅ Package vào IP repository: `synthesis/ip_repo/axi_master_bridge/`
- ✅ VLNV: `user.org:user:axi_master_bridge:1.0`

### Bước 2: Add IP Repository vào Project

Nếu chưa có IP repository trong project:

```tcl
set ip_repo_path "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/ip_repo"
set_property ip_repo_paths [list $ip_repo_path] [current_project]
update_ip_catalog
```

Hoặc dùng GUI:
- Settings → IP → Repository → Add
- Chọn: `synthesis/ip_repo`

### Bước 3: Thay SmartConnect bằng AXI Bridge

#### Option A: Tự động (nếu đã có SmartConnect)

Mở Block Design và chạy:

```tcl
source replace_smartconnect_with_bridge.tcl
```

Script sẽ tự động:
- ✅ Xóa SmartConnect instances
- ✅ Add AXI Master Bridge IPs
- ✅ Reconnect tất cả connections
- ✅ Connect clock và reset

#### Option B: Thủ công

**Bước 3.1: Xóa SmartConnect (nếu có)**

```tcl
# Xóa SmartConnect cells
delete_bd_objs [get_bd_cells smartconnect_0]
delete_bd_objs [get_bd_cells smartconnect_1]
```

**Bước 3.2: Add AXI Master Bridge IPs**

```tcl
# Add Bridge 0 (cho Master 0)
create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_0

# Add Bridge 1 (cho Master 1)
create_bd_cell -type ip -vlnv user.org:user:axi_master_bridge:1.0 axi_master_bridge_1
```

**Bước 3.3: Connect Clock và Reset**

```tcl
# Connect clock
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_master_bridge_0/ACLK]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_master_bridge_1/ACLK]

# Connect reset
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_master_bridge_0/ARESETN]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_master_bridge_1/ARESETN]
```

**Bước 3.4: Connect AXI Interfaces**

```tcl
# Master 0: PS → Bridge 0 → AXI Interconnect M0
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] \
    [get_bd_intf_pins axi_master_bridge_0/s_axi]

connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_0/m_axi] \
    [get_bd_intf_pins axi_interconnect_0/M0]

# Master 1: PS → Bridge 1 → AXI Interconnect M1
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD] \
    [get_bd_intf_pins axi_master_bridge_1/s_axi]

connect_bd_intf_net [get_bd_intf_pins axi_master_bridge_1/m_axi] \
    [get_bd_intf_pins axi_interconnect_0/M1]
```

### Bước 4: Validate và Generate

```tcl
# Validate design
validate_bd_design

# Regenerate layout
regenerate_bd_layout

# Generate output products
generate_target all [get_files design_1.bd]
```

## So Sánh: SmartConnect vs AXI Master Bridge

| Aspect | SmartConnect (Xilinx IP) | AXI Master Bridge (Custom) |
|--------|--------------------------|----------------------------|
| Source | Xilinx IP Catalog | Custom RTL Code |
| Purpose | Protocol conversion | Protocol adapter/bridge |
| Complexity | High (many features) | Simple (pass-through) |
| Customizable | Limited | Full control |
| Đồ án requirement | ❌ | ✅ (yêu cầu dùng AXI Bridge) |

## Implementation Details

### AXI Master Bridge Features:

1. **Protocol Conversion**:
   - Input: AXI4 GP (General Purpose) từ Zynq PS
   - Output: AXI4 Full cho AXI Interconnect

2. **Signal Mapping**:
   - Pass-through các signals chính (AWADDR, ARADDR, WDATA, RDATA, etc.)
   - Drop optional signals (lock, cache, prot, qos, region, user)
   - Map response signals (BRESP, RRESP)

3. **Clock Domain**:
   - Single clock domain (ACLK từ Zynq PS)
   - Synchronous reset (ARESETN)

## Troubleshooting

### Lỗi: "IP not found in catalog"
- **Nguyên nhân**: IP repository chưa được add hoặc chưa update catalog
- **Giải pháp**:
  ```tcl
  set_property ip_repo_paths [list $ip_repo_path] [current_project]
  update_ip_catalog
  ```

### Lỗi: "Interface connection failed"
- **Nguyên nhân**: Tên interface không khớp
- **Giải pháp**: Kiểm tra tên interface:
  ```tcl
  get_bd_intf_pins -of_objects [get_bd_cells axi_master_bridge_0]
  ```

### Lỗi: "Clock not connected"
- **Nguyên nhân**: Clock chưa được connect
- **Giải pháp**: Connect clock như hướng dẫn ở Bước 3.3

## Files Liên Quan

- **RTL Source**: `SystemVerilog/axi_bridge/axi_master_bridge.sv`
- **Package Script**: `synthesis/scripts/vivado/package_axi_master_bridge_ip.tcl`
- **Replace Script**: `synthesis/scripts/vivado/replace_smartconnect_with_bridge.tcl`
- **IP Location**: `synthesis/ip_repo/axi_master_bridge/`

## Lưu Ý

1. **AXI Bridge đơn giản**: Implementation hiện tại là pass-through, phù hợp khi protocols tương thích
2. **Có thể mở rộng**: Nếu cần protocol conversion phức tạp hơn, có thể modify `axi_master_bridge.sv`
3. **Testing**: Sau khi thay SmartConnect, nên validate và test kỹ để đảm bảo functionality

---

**Last Updated**: 2025-01-XX









