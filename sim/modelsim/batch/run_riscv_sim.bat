@echo off
REM Batch script to run SERV RISC-V System Simulation
REM Usage: run_riscv_sim.bat
REM Note: Must compile first with compile_riscv.bat

REM Di chuyển vào thư mục modelsim (lên 1 cấp từ batch/)
cd /d "%~dp0.."

REM Chạy simulation script
vsim -c -do "source scripts/sim/run_riscv_sim.tcl; quit -f"

pause

