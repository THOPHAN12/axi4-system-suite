@echo off
REM Batch script to compile and run SERV RISC-V System
REM Usage: compile_and_run_riscv.bat

REM Di chuyển vào thư mục modelsim (lên 1 cấp từ batch/)
cd /d "%~dp0.."

REM Chạy compilation và simulation script
vsim -c -do "source scripts/compile/compile_and_run_riscv.tcl; quit -f"

pause

