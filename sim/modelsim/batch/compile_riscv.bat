@echo off
REM Batch script to compile SERV RISC-V System
REM Usage: compile_riscv.bat

REM Di chuyển vào thư mục modelsim (lên 1 cấp từ batch/)
cd /d "%~dp0.."

REM Chạy compilation script
vsim -c -do "source scripts/compile/compile_riscv.tcl; quit -f"

pause

