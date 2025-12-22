@echo off
REM ==============================================================================
REM Batch Script - Run Busy Signal Testbench
REM ==============================================================================
REM This script runs the busy signal testbench using ModelSim
REM Usage: run_busy_signal_tb.bat
REM ==============================================================================

echo ============================================================================
echo Running Busy Signal Testbench
echo ============================================================================
echo.

REM Check if ModelSim is in PATH
where vsim >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: ModelSim not found in PATH
    echo Please add ModelSim to your PATH or run from ModelSim command prompt
    pause
    exit /b 1
)

REM Get script directory
set SCRIPT_DIR=%~dp0
cd /d "%SCRIPT_DIR%"

echo Current directory: %CD%
echo.

REM Run ModelSim with TCL script
echo Starting ModelSim...
vsim -c -do "run_busy_signal_tb.tcl"

echo.
echo ============================================================================
echo Simulation Complete
echo ============================================================================
pause


































