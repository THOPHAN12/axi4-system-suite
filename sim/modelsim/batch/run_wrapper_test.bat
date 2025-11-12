@echo off
REM ============================================================================
REM Batch script để chạy testbench cho ALU Master System Wrapper
REM Usage: run_wrapper_test.bat
REM ============================================================================

echo ============================================================================
echo Running ALU Master System Wrapper Testbench
echo ============================================================================
echo.

REM Kiểm tra ModelSim có trong PATH không
where vsim >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ModelSim not found in PATH!
    echo Please add ModelSim bin directory to PATH or use full path
    pause
    exit /b 1
)

REM Di chuyển vào thư mục modelsim (lên 1 cấp từ batch/)
cd /d "%~dp0.."

REM Chạy ModelSim với script TCL
echo Starting ModelSim...
vsim -c -do "source scripts/sim/run_wrapper_test.tcl; quit -f"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================================
    echo Test completed successfully!
    echo ============================================================================
) else (
    echo.
    echo ============================================================================
    echo Test failed with errors!
    echo ============================================================================
)

pause

