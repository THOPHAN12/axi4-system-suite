@echo off
REM ============================================================================
REM Batch script để chạy RISC-V testbench
REM Usage: run_riscv.bat
REM ============================================================================

echo ============================================================================
echo Running RISC-V System Testbench
echo ============================================================================
echo.

REM Di chuyển vào thư mục modelsim (lên 1 cấp từ batch/)
cd /d "%~dp0.."

REM Chạy testbench
vsim -c -do "source scripts/sim/run_riscv_test.tcl; quit -f"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================================
    echo Test Completed Successfully!
    echo ============================================================================
    echo.
    echo Waveform file: serv_axi_system_tb.vcd
    echo To view waveform: gtkwave serv_axi_system_tb.vcd
    echo.
) else (
    echo.
    echo ============================================================================
    echo Test Failed!
    echo ============================================================================
)

pause

