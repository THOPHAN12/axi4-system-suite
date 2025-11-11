================================================================================
AXI INTERCONNECT TEST SUITE - HƯỚNG DẪN SỬ DỤNG
================================================================================

Hệ thống test này kiểm tra kết nối giữa 2 AXI Masters và 4 AXI Slaves thông qua
AXI Interconnect.

CẤU TRÚC HỆ THỐNG:
------------------
  - 2 Simple AXI Master Test modules (Master 0, Master 1)
  - 4 Simple Memory Slave modules (Slave 0, 1, 2, 3)
  - 1 AXI Interconnect Full module

ÁNH XẠ ĐỊA CHỈ:
---------------
  Slave 0: 0x0000_0000 - 0x3FFF_FFFF (MSB [31:30] = 00)
  Slave 1: 0x4000_0000 - 0x7FFF_FFFF (MSB [31:30] = 01)
  Slave 2: 0x8000_0000 - 0xBFFF_FFFF (MSB [31:30] = 10)
  Slave 3: 0xC000_0000 - 0xFFFF_FFFF (MSB [31:30] = 11)

CÁC TESTCASE:
------------
  Test 1-4:   Master 0 giao tiếp với từng Slave (0, 1, 2, 3)
  Test 5-8:   Master 1 giao tiếp với từng Slave (0, 1, 2, 3)
  Test 9-12:  Cả 2 Master cùng giao tiếp với 1 Slave (test arbitration)
  Test 13:    Cả 2 Master giao tiếp với 2 Slave khác nhau (test parallel)

CÁCH CHẠY SIMULATION:
--------------------

Option 1: Sử dụng batch file (Windows)
  1. Mở Command Prompt
  2. cd sim/modelsim
  3. run_test.bat

Option 2: Sử dụng ModelSim GUI
  1. Mở ModelSim
  2. File -> Change Directory -> chọn sim/modelsim
  3. Tools -> TCL -> Execute Macro -> chọn run_test.tcl

Option 3: Dòng lệnh ModelSim
  1. cd sim/modelsim
  2. vsim -c -do run_test.tcl

KẾT QUẢ MONG ĐỢI:
-----------------
  - Tất cả 13 test cases chạy thành công
  - Hiển thị chi tiết các AXI transactions:
    * M0_AW, M0_W, M0_B: Master 0 Write transactions
    * M0_AR, M0_R:       Master 0 Read transactions
    * M1_AW, M1_W, M1_B: Master 1 Write transactions
    * M1_AR, M1_R:       Master 1 Read transactions
    * S0-S3_AW, S0-S3_W, S0-S3_B: Slave Write transactions
    * S0-S3_AR, S0-S3_R: Slave Read transactions
  - Test summary report ở cuối simulation

WAVEFORM:
---------
  - File VCD được tạo tự động: alu_master_system_tb.vcd
  - Có thể xem bằng GTKWave hoặc ModelSim waveform viewer
  - Để enable waveform trong ModelSim, uncomment các dòng "add wave" trong run_test.tcl

LƯU Ý:
------
  - Slave 2 và Slave 3 CHỈ hỗ trợ READ trong interconnect (do cấu hình)
  - Các test case viết vào Slave 2/3 sẽ chỉ thực hiện được phần Read
  - Mỗi Master test thực hiện: Write -> Read -> Verify

TROUBLESHOOTING:
---------------
  1. Nếu gặp lỗi "file not found":
     - Kiểm tra đường dẫn trong run_test.tcl
     - Đảm bảo đang ở đúng thư mục sim/modelsim

  2. Nếu test timeout:
     - Kiểm tra waveform để xem AXI signals
     - Xem transcript để tìm lỗi
     - Kiểm tra interconnect routing

  3. Nếu compilation error:
     - Xóa thư mục work: vdel -all
     - Chạy lại run_test.tcl

================================================================================

