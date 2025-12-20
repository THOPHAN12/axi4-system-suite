@echo off
REM ============================================================================
REM Batch script to run Simple AXI Read Testbench
REM ============================================================================
REM This script runs the testbench using ModelSim
REM ============================================================================

cd /d "%~dp0"
echo Running Simple AXI Read Testbench...
echo.

"C:\altera\13.0sp1\modelsim_ase\win32aloem\vsim.exe" -c -do "source run_simple_read_tb.tcl; quit -f"

pause



