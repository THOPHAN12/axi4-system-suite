#!/bin/bash
#==============================================================================
# run_simulation.sh
# Run Verilator simulation (Linux/macOS)
#==============================================================================

set -e

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/build"
EXE_FILE="$BUILD_DIR/dual_riscv_system"

echo "============================================================================"
echo "Verilator Simulation"
echo "============================================================================"
echo ""

# Check if executable exists
if [ ! -f "$EXE_FILE" ]; then
    echo "ERROR: Executable not found: $EXE_FILE"
    echo "Please run ./compile_verilator.sh first"
    exit 1
fi

echo "Running simulation..."
echo "Executable: $EXE_FILE"
echo ""

# Run simulation
"$EXE_FILE"

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Simulation failed!"
    exit 1
fi

echo ""
echo "============================================================================"
echo "Simulation completed!"
echo "============================================================================"
echo ""

# Check for waveform file
VCD_FILE="$BUILD_DIR/dual_riscv_system.vcd"
if [ -f "$VCD_FILE" ]; then
    echo "Waveform file: $VCD_FILE"
    echo "You can view it with GTKWave or other VCD viewers"
fi

echo ""


