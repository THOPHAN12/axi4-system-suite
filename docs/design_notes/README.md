# Ghi Chú Thiết Kế

## 📚 Mục Lục

### Test Design
- **[AXI_INTERCONNECT_TEST_DESIGN.txt](AXI_INTERCONNECT_TEST_DESIGN.txt)** - Đề án test AXI Interconnect
  - Tổng quan hệ thống test
  - Test scenarios
  - Expected behavior
  - Monitor output format

### Synthesis & Quality
- **[QUARTUS_SYNTHESIS_WARNINGS.md](QUARTUS_SYNTHESIS_WARNINGS.md)** - Phân tích warnings từ Quartus synthesis
  - Inferred latches và cách sửa
  - Unused signals
  - Code quality issues
  - Khuyến nghị sửa lỗi

### Design Flexibility
- **[TIE_OFF_SIGNALS_ANALYSIS.md](TIE_OFF_SIGNALS_ANALYSIS.md)** - Phân tích tie-off signals
  - Các loại tie-off signals
  - Khả năng chuyển thành input ports
  - Trade-offs và khuyến nghị
- **[TIE_OFF_REFACTORING_EXAMPLE.md](TIE_OFF_REFACTORING_EXAMPLE.md)** - Ví dụ refactoring
  - Ví dụ cụ thể về cách refactor
  - So sánh các approaches
  - Checklist khi refactoring

### Design Decisions
- **Đang phát triển**: Các quyết định thiết kế quan trọng
- **Đang phát triển**: Trade-offs và lý do

### Known Issues
- **Đang phát triển**: Các vấn đề đã biết
- **Đang phát triển**: Workarounds

### Future Improvements
- **Đang phát triển**: Cải thiện dự kiến
- **Đang phát triển**: Roadmap

### Implementation Notes
- **ALU Master Bypass**: Xem [../architecture/SYSTEM_ARCHITECTURE.md](../architecture/SYSTEM_ARCHITECTURE.md) - Section 1.3.4
  - ALU Master kết nối trực tiếp với M02, bypass interconnect
  - Lý do: Interconnect chỉ hỗ trợ 2 masters

---

*Tài liệu này đang được phát triển. Vui lòng xem các tài liệu kiến trúc chính.*

