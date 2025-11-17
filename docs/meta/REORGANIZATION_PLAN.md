# 📋 Kế Hoạch Tổ Chức Lại Tài Liệu

## 🎯 Mục Tiêu

Tổ chức lại các file tài liệu trong `docs/` để dễ tìm kiếm và quản lý hơn.

## 📂 Cấu Trúc Đề Xuất

```
docs/
├── README.md                          # ⭐ Index chính (giữ ở root)
│
├── architecture/                      # 🆕 Folder mới: Kiến trúc & Thiết kế
│   ├── README.md                      # Index cho architecture
│   ├── SYSTEM_DIAGRAM.md              # Sơ đồ tổng thể (ASCII)
│   ├── SYSTEM_DIAGRAM_MERMAID.md      # Sơ đồ Mermaid
│   ├── SYSTEM_ARCHITECTURE.md         # Chi tiết kiến trúc
│   └── CONNECTION_DIAGRAM.md          # Sơ đồ kết nối
│
├── design_notes/                      # Ghi chú thiết kế
│   ├── README.md
│   └── AXI_INTERCONNECT_TEST_DESIGN.txt  # Di chuyển vào đây
│
├── meta/                              # 🆕 Folder mới: Meta documentation
│   ├── README.md
│   └── DOCUMENTATION_REVIEW.md        # Đánh giá tài liệu
│
├── user_guides/                       # Hướng dẫn sử dụng
├── specifications/                    # Đặc tả kỹ thuật
├── api_reference/                     # API Reference
├── changelog/                         # Lịch sử thay đổi
│
└── diagram_axi_interconnect/          # Sơ đồ DrawIO (giữ nguyên)
```

## 📝 Lý Do Tổ Chức

### 1. Folder `architecture/`
**Lý do**: Tất cả các file về kiến trúc nên ở cùng một nơi
- `SYSTEM_DIAGRAM.md` - Sơ đồ tổng thể
- `SYSTEM_DIAGRAM_MERMAID.md` - Sơ đồ Mermaid
- `SYSTEM_ARCHITECTURE.md` - Chi tiết kiến trúc
- `CONNECTION_DIAGRAM.md` - Sơ đồ kết nối

**Lợi ích**:
- Dễ tìm tất cả tài liệu về kiến trúc
- Phân loại rõ ràng
- Có thể thêm README.md để giải thích từng file

### 2. Di chuyển `AXI_INTERCONNECT_TEST_DESIGN.txt` vào `design_notes/`
**Lý do**: Đây là ghi chú thiết kế về test, phù hợp với `design_notes/`

### 3. Folder `meta/`
**Lý do**: Các file về quản lý tài liệu (meta documentation)
- `DOCUMENTATION_REVIEW.md` - Đánh giá tài liệu
- Có thể thêm các file khác về quản lý docs sau này

## ✅ Thực Hiện

Sau khi tổ chức lại, cần:
1. ✅ Tạo folder mới
2. ✅ Di chuyển files
3. ✅ Cập nhật README.md chính
4. ✅ Cập nhật cross-references trong các file
5. ✅ Tạo README.md trong các folder mới

