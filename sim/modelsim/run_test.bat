@echo off
REM Batch file to run ModelSim simulation on Windows

echo ==========================================
echo AXI Interconnect Test Suite
echo ==========================================
echo.

REM Run ModelSim in batch mode
vsim -c -do run_test.tcl

echo.
echo ==========================================
echo Simulation finished. Check transcript.
echo ==========================================
pause

