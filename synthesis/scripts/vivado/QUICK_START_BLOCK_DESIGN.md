# Quick Start: Tạo Block Design cho KV260

## ⚡ Cách Nhanh Nhất

### Mở Vivado và chạy:

```tcl
# Cách 1: Dùng đường dẫn trong dấu ngoặc kép (Khuyến nghị)
cd "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado"
source create_kv260_block_design.tcl
```

**Hoặc:**

```tcl
# Cách 2: Chạy trực tiếp với đường dẫn đầy đủ
source "C:/Users/Nguyen Ha Hai/axi4-system-suite/synthesis/scripts/vivado/create_kv260_block_design.tcl"
```

## ✅ Script Sẽ Tự Động:

1. Tạo project: `kv260_2m4s_block_design`
2. Tạo Block Design: `design_1`
3. Thêm Zynq PS với 2 AXI Masters
4. Add AXI Interconnect RTL files
5. Kết nối clock và reset
6. Validate và generate

## ⚠️ Sau Khi Script Chạy Xong:

Bạn cần **hoàn thiện kết nối AXI** trong Block Design GUI:

1. **Mở Block Design**: Flow Navigator → IP Integrator → Open Block Design

2. **Kết nối AXI**:
   - SmartConnect_0/M00_AXI → AXI_Interconnect M0 (individual signals)
   - SmartConnect_1/M00_AXI → AXI_Interconnect M1 (individual signals)

3. **Set Address Map**: Address Editor tab → Set ranges cho 4 slaves

4. **Validate**: Click Validate Design (F6)

5. **Generate**: Right-click → Generate Output Products

## 📝 Lưu Ý

- Script tự động xử lý đường dẫn có khoảng trắng
- AXI connections cần hoàn thiện thủ công trong GUI
- Xem `README_BLOCK_DESIGN.md` để biết chi tiết

---

**Script Location**: `synthesis/scripts/vivado/create_kv260_block_design.tcl`










