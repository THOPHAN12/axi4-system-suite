@echo off
REM ============================================================================
REM Batch script to run Simple AXI Read Testbench in GUI Mode
REM ============================================================================
REM This script runs the testbench using ModelSim GUI
REM ============================================================================

cd /d "%~dp0"
echo Running Simple AXI Read Testbench in GUI Mode...
echo.

"C:\altera\13.0sp1\modelsim_ase\win32aloem\vsim.exe" -do run_simple_read_tb.tcl

pause



