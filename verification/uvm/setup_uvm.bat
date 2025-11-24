@echo off
REM Setup script to find and set UVM_HOME for ModelSim ALTERA
REM This script helps locate UVM library for verification

echo Searching for UVM library...

REM Check common ModelSim ALTERA locations
if exist "C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d" (
    set UVM_HOME=C:\altera\13.0sp1\modelsim_ase\verilog_src\uvm-1.1d
    echo Found UVM at: %UVM_HOME%
    goto :found
)

REM Check if UVM is in modelsim directory
if exist "C:\altera\13.0sp1\modelsim_ase\uvm-1.1d" (
    set UVM_HOME=C:\altera\13.0sp1\modelsim_ase\uvm-1.1d
    echo Found UVM at: %UVM_HOME%
    goto :found
)

echo.
echo UVM library not found in default locations.
echo.
echo Please download UVM from: http://www.accellera.org/downloads/standards/uvm
echo Extract it and set UVM_HOME environment variable:
echo   set UVM_HOME=C:\path\to\uvm-1.1d
echo.
echo Or modify this script to point to your UVM installation.
echo.
pause
exit /b 1

:found
echo UVM_HOME is set to: %UVM_HOME%
echo.
echo To use UVM, run this script before compiling:
echo   setup_uvm.bat
echo   make compile
echo.

