# Quick Start Guide - ModelSim Project Scripts

## Vị Trí Scripts

Tất cả scripts nằm trong: `sim/modelsim/scripts/project/`

## Cách Sử Dụng

### Từ ModelSim Console

#### Option 1: Sử dụng đường dẫn đầy đủ (Khuyến nghị)

```tcl
source D:/AXI/sim/modelsim/scripts/project/add_files_auto.tcl
```

#### Option 2: Thay đổi thư mục trước

```tcl
cd D:/AXI/sim/modelsim/scripts/project
source add_files_auto.tcl
```

#### Option 3: Sử dụng đường dẫn tương đối từ project root

Nếu bạn đang ở thư mục `D:/AXI/sim/modelsim`:

```tcl
source scripts/project/add_files_auto.tcl
```

### Từ Command Line (Windows)

```batch
cd D:\AXI\sim\modelsim
vsim -do "source scripts/project/add_files_auto.tcl"
```

## Các Scripts Có Sẵn

1. **add_files_auto.tcl** ⭐ (Khuyến nghị)
   - Tự động tạo/mở project
   - Tự động add tất cả files
   - Chạy một lần là xong

2. **add_all_files.tcl**
   - Chỉ add files (không tạo project)
   - Yêu cầu project đã được mở trước

3. **add_all_file.tcl**
   - Alias cho `add_all_files.tcl`

## Troubleshooting

### Lỗi: "no such file or directory"

**Nguyên nhân:** Đường dẫn không đúng hoặc không ở đúng thư mục.

**Giải pháp:**
1. Kiểm tra đường dẫn: `pwd` (trong ModelSim console)
2. Sử dụng đường dẫn đầy đủ: `source D:/AXI/sim/modelsim/scripts/project/add_files_auto.tcl`
3. Hoặc thay đổi thư mục: `cd D:/AXI/sim/modelsim/scripts/project` rồi `source add_files_auto.tcl`

### Lỗi: "A project is already open"

**Nguyên nhân:** Đã có project đang mở.

**Giải pháp:** Script sẽ tự động xử lý, hoặc đóng project cũ:
```tcl
project close
source D:/AXI/sim/modelsim/scripts/project/add_files_auto.tcl
```

## Ví Dụ Đầy Đủ

```tcl
# Mở ModelSim
# Trong ModelSim console:

# Kiểm tra thư mục hiện tại
pwd

# Chạy script (sử dụng đường dẫn đầy đủ)
source D:/AXI/sim/modelsim/scripts/project/add_files_auto.tcl

# Hoặc thay đổi thư mục trước
cd D:/AXI/sim/modelsim/scripts/project
source add_files_auto.tcl
```

## Lưu Ý

- Luôn sử dụng đường dẫn đầy đủ để tránh lỗi
- Scripts sử dụng đường dẫn tuyệt đối, không phụ thuộc vào thư mục hiện tại
- Project sẽ được tạo/mở tại `D:/AXI/sim/modelsim/AXI_Project.mpf`

