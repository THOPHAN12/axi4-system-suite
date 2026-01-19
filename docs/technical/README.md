# Tài Liệu Kỹ Thuật (Technical Documentation)

## Tổng Quan

Thư mục này chứa tất cả các tài liệu kỹ thuật của dự án AXI4 System Suite, bao gồm:
- Đặc tả hệ thống (Specifications)
- Tài liệu giải thuật (Algorithms)
- Tài liệu tham khảo (References)
- Hướng dẫn vận hành (User Guide)
- Cấu trúc dự án (Project Structure)

## Danh Sách Tài Liệu

### 1. [SPECIFICATIONS.md](SPECIFICATIONS.md)
**Đặc Tả Hệ Thống**

Tài liệu này mô tả chi tiết:
- Tổng quan hệ thống và mục đích
- Kiến trúc AXI Interconnect
- Các Channel Controllers
- Arbitration algorithms
- Address decoding
- RISC-V cores integration
- Peripherals
- Performance specifications
- Verification specifications
- Giới hạn hệ thống

**Đối tượng**: Designers, Architects, Verification Engineers

---

### 2. [ALGORITHMS.md](ALGORITHMS.md)
**Tài Liệu Giải Thuật**

Tài liệu này mô tả chi tiết các thuật toán:
- **Arbitration Algorithms**:
  - Fixed Priority Arbiter
  - Round-Robin Arbiter
  - QoS-Based Arbiter
- **Channel Controllers**:
  - AW Channel Controller
  - WD Channel Controller
  - BR Channel Controller
  - AR Channel Controller
  - Read Data Channel
- **Address Decoding**
- **Handshake Protocols**
- **Performance Analysis**

**Đối tượng**: Developers, Algorithm Engineers

---

### 3. [REFERENCES.md](REFERENCES.md)
**Tài Liệu Tham Khảo**

Danh sách đầy đủ các tài liệu tham khảo:
- AXI Protocol Specifications
- AXI Interconnect Design
- RISC-V Architecture
- System-on-Chip Design
- Verification và Testing
- FPGA Design và Synthesis
- Simulation Tools
- Related Projects
- Standards và Formats
- Educational Resources

**Đối tượng**: Researchers, Students, Developers

---

### 4. [USER_GUIDE.md](USER_GUIDE.md)
**Hướng Dẫn Vận Hành**

Hướng dẫn chi tiết cách sử dụng hệ thống:
- Cài đặt và thiết lập
- Simulation với ModelSim
- Simulation với Verilator
- Synthesis với Vivado
- Synthesis với Quartus
- Sử dụng AXI Interconnect
- RISC-V Cores Integration
- Peripherals
- Verification
- Troubleshooting
- Best Practices
- Advanced Usage
- Examples

**Đối tượng**: Users, Test Engineers, System Integrators

---

### 5. [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)
**Cấu Trúc Dự Án**

Mô tả chi tiết cấu trúc dự án:
- Cấu trúc thư mục chính
- SystemVerilog source code organization
- Documentation structure
- Simulation files
- Synthesis files
- Verification files
- Naming conventions
- Comment guidelines
- Dependencies
- Build process
- Testing structure
- Documentation structure
- Maintenance guidelines

**Đối tượng**: Developers, Maintainers, New Contributors

---

## Cách Sử Dụng Tài Liệu

### Cho Người Mới Bắt Đầu
1. Đọc [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) để hiểu cấu trúc dự án
2. Đọc [SPECIFICATIONS.md](SPECIFICATIONS.md) để hiểu hệ thống
3. Đọc [USER_GUIDE.md](USER_GUIDE.md) để bắt đầu sử dụng

### Cho Developers
1. Đọc [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) để hiểu code organization
2. Đọc [ALGORITHMS.md](ALGORITHMS.md) để hiểu các thuật toán
3. Tham khảo [REFERENCES.md](REFERENCES.md) khi cần

### Cho Verification Engineers
1. Đọc [SPECIFICATIONS.md](SPECIFICATIONS.md) để hiểu specifications
2. Đọc [USER_GUIDE.md](USER_GUIDE.md) phần Verification
3. Tham khảo testbenches trong `SystemVerilog/testbenches/`

### Cho Researchers
1. Đọc [ALGORITHMS.md](ALGORITHMS.md) để hiểu algorithms
2. Đọc [REFERENCES.md](REFERENCES.md) để tìm papers liên quan
3. Tham khảo [SPECIFICATIONS.md](SPECIFICATIONS.md) cho system specs

## Cập Nhật Tài Liệu

Khi cập nhật code hoặc thêm features mới:
1. Update [SPECIFICATIONS.md](SPECIFICATIONS.md) nếu có thay đổi specs
2. Update [ALGORITHMS.md](ALGORITHMS.md) nếu có thuật toán mới
3. Update [USER_GUIDE.md](USER_GUIDE.md) nếu có thay đổi usage
4. Update [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) nếu có thay đổi structure
5. Update [REFERENCES.md](REFERENCES.md) nếu có references mới

## Liên Kết Nhanh

- **Source Code**: `SystemVerilog/`
- **Testbenches**: `SystemVerilog/testbenches/`
- **Simulation**: `sim/`
- **Synthesis**: `synthesis/`
- **Architecture Docs**: `docs/architecture/`
- **Main README**: `README.md`

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-XX  
**Author**: AXI4 System Suite Team

