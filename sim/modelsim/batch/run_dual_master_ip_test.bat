@echo off
REM run_dual_master_ip_test.bat : Batch script to run dual_master_system_ip_tb.v

REM Di chuyển vào thư mục modelsim (lên 1 cấp từ batch/)
cd /d "%~dp0.."

echo ============================================================================
echo Running Dual Master System IP Testbench
echo ============================================================================
echo.

vsim -do "source scripts/sim/run_dual_master_ip_test.tcl; quit -f"

pause

