# 📚 Tài Liệu Dự Án AXI

## 📖 Mục Lục

### 🏗️ Kiến Trúc & Thiết Kế

- **[architecture/](architecture/)** ⭐ **BẮT ĐẦU TỪ ĐÂY**
  - **[SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md)** - Sơ đồ tổng thể hệ thống (ASCII art)
  - **[SYSTEM_DIAGRAM_MERMAID.md](architecture/SYSTEM_DIAGRAM_MERMAID.md)** - Sơ đồ Mermaid (interactive)
  - **[SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md)** - Chi tiết kiến trúc từng module
  - **[CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)** - Sơ đồ kết nối chi tiết
  - **[AXI_INTERCONNECT_CONFLICTS.md](architecture/AXI_INTERCONNECT_CONFLICTS.md)** - Phân tích xung đột và arbitration
  - **Phù hợp cho**: Người mới bắt đầu, developer, integrator

### 🔧 Hướng Dẫn Sử Dụng

- **[user_guides/](user_guides/)** - Hướng dẫn sử dụng (đang phát triển)
  - Quick start guide
  - ModelSim simulation guide
  - Quartus synthesis guide
  - Testbench guide

### 📋 Đặc Tả Kỹ Thuật

- **[specifications/](specifications/)** - Đặc tả kỹ thuật (đang phát triển)
  - AXI4 protocol specification
  - Module interface specifications
  - Timing constraints

### 📝 Ghi Chú Thiết Kế

- **[design_notes/](design_notes/)** - Ghi chú thiết kế
  - **[AXI_INTERCONNECT_TEST_DESIGN.txt](design_notes/AXI_INTERCONNECT_TEST_DESIGN.txt)** - Đề án test AXI Interconnect
  - Design decisions
  - Trade-offs
  - Known issues

### 📊 Tài Liệu Tham Khảo

- **[api_reference/](api_reference/)** - API Reference (đang phát triển)
  - Module interfaces
  - Function descriptions
  - Parameter lists

- **[changelog/](changelog/)** - Lịch sử thay đổi (đang phát triển)
  - Version history
  - Change logs

### 📋 Meta Documentation

- **[meta/](meta/)** - Tài liệu quản lý
  - **[DOCUMENTATION_REVIEW.md](meta/DOCUMENTATION_REVIEW.md)** - Đánh giá tài liệu

### 📐 Sơ Đồ Chi Tiết

- **[diagram_axi_interconnect/](diagram_axi_interconnect/)**
  - Sơ đồ DrawIO
  - Flow diagrams

---

## 🚀 Bắt Đầu Nhanh

### Cho Người Mới

1. **Đọc**: [architecture/SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md) - Tổng quan hệ thống
2. **Xem**: [architecture/SYSTEM_DIAGRAM_MERMAID.md](architecture/SYSTEM_DIAGRAM_MERMAID.md) - Sơ đồ trực quan
3. **Hiểu**: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md) - Chi tiết kiến trúc

### Cho Developer

1. **Thiết kế**: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md)
2. **Kết nối**: [architecture/CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)
3. **Xung đột**: [architecture/AXI_INTERCONNECT_CONFLICTS.md](architecture/AXI_INTERCONNECT_CONFLICTS.md)
4. **Test**: [design_notes/AXI_INTERCONNECT_TEST_DESIGN.txt](design_notes/AXI_INTERCONNECT_TEST_DESIGN.txt)

### Cho Integrator

1. **Tổng quan**: [architecture/SYSTEM_DIAGRAM.md](architecture/SYSTEM_DIAGRAM.md)
2. **Ports**: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md) - Section 1.5
3. **Wiring**: [architecture/CONNECTION_DIAGRAM.md](architecture/CONNECTION_DIAGRAM.md)
4. **Xung đột**: [architecture/AXI_INTERCONNECT_CONFLICTS.md](architecture/AXI_INTERCONNECT_CONFLICTS.md)

---

## 📂 Cấu Trúc Tài Liệu

```
docs/
├── README.md                          # File này - Index chính
│
├── architecture/                      # 🏗️ Kiến trúc & Thiết kế
│   ├── README.md
│   ├── SYSTEM_DIAGRAM.md             # ⭐ Sơ đồ tổng thể (ASCII art)
│   ├── SYSTEM_DIAGRAM_MERMAID.md      # Sơ đồ Mermaid (interactive)
│   ├── SYSTEM_ARCHITECTURE.md         # Chi tiết kiến trúc
│   ├── CONNECTION_DIAGRAM.md          # Sơ đồ kết nối
│   └── AXI_INTERCONNECT_CONFLICTS.md  # Phân tích xung đột
│
├── design_notes/                     # 📝 Ghi chú thiết kế
│   ├── README.md
│   └── AXI_INTERCONNECT_TEST_DESIGN.txt
│
├── meta/                             # 📋 Meta documentation
│   ├── README.md
│   └── DOCUMENTATION_REVIEW.md
│
├── user_guides/                      # 🔧 Hướng dẫn sử dụng
├── specifications/                   # 📋 Đặc tả kỹ thuật
├── api_reference/                    # 📊 API Reference
├── changelog/                        # 📝 Lịch sử thay đổi
│
└── diagram_axi_interconnect/         # 📐 Sơ đồ DrawIO
    ├── axi_interconnect.drawio.png
    └── axiflow.drawio.png
```

---

## ⚠️ Lưu Ý Quan Trọng

### Thông Tin Cần Cập Nhật

1. **ALU Master Connection**: 
   - Trong `dual_master_system_ip`, ALU Master **bypass interconnect** (kết nối trực tiếp với M02)
   - Xem: [architecture/SYSTEM_ARCHITECTURE.md](architecture/SYSTEM_ARCHITECTURE.md) - Section 1.3.4

2. **Module Hierarchy**:
   - Top-level IP: `dual_master_system_ip`
   - System module: `dual_master_system` (external memory)
   - Xem: [src/wrapper/README.md](../src/wrapper/README.md)

### Trùng Lặp Nội Dung

- Các file trong `architecture/` có một số nội dung trùng lặp nhưng phục vụ mục đích khác nhau
- **SYSTEM_DIAGRAM.md**: Tập trung vào sơ đồ và tổng quan
- **SYSTEM_ARCHITECTURE.md**: Tập trung vào chi tiết implementation
- **AXI_INTERCONNECT_CONFLICTS.md**: Tập trung vào xung đột và arbitration
- **Khuyến nghị**: Đọc cả các file để có cái nhìn đầy đủ

---

## 🔗 Liên Kết Ngoài

- **Source Code**: [src/wrapper/README.md](../src/wrapper/README.md)
- **Testbenches**: [tb/wrapper_tb/README.md](../tb/wrapper_tb/README.md)
- **ModelSim**: [sim/modelsim/docs/README.md](../sim/modelsim/docs/README.md)
- **Quartus**: [sim/quartus/README.md](../sim/quartus/README.md)

---

## 📝 Cập Nhật Tài Liệu

Khi thêm tài liệu mới:

1. **Thêm vào mục lục** trong `README.md` này
2. **Cập nhật cross-references** giữa các file
3. **Kiểm tra tính nhất quán** với code thực tế
4. **Cập nhật version/changelog** nếu cần

---

*Tài liệu này được cập nhật lần cuối: 2024*

