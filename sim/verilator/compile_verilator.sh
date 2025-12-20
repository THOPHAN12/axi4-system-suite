#!/bin/bash
#==============================================================================
# compile_verilator.sh
# Compile dual RISC-V system with Verilator (Linux/macOS)
#==============================================================================

set -e

# Get script directory (handle both Unix and Windows/MSYS2 paths)
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Convert Windows paths to MSYS2 format if needed
SCRIPT_DIR=$(cygpath -u "$SCRIPT_DIR" 2>/dev/null || echo "$SCRIPT_DIR")
ROOT_DIR=$(cygpath -u "$ROOT_DIR" 2>/dev/null || echo "$ROOT_DIR")

echo "============================================================================"
echo "Verilator Compilation Script"
echo "============================================================================"
echo ""
echo "Root directory: $ROOT_DIR"
echo "Script directory: $SCRIPT_DIR"
echo ""

# Change to script directory
cd "$SCRIPT_DIR"

# Create build directory
BUILD_DIR="$SCRIPT_DIR/build"
mkdir -p "$BUILD_DIR"
echo "Created build directory: $BUILD_DIR"

# Paths
SRC_BASE="$ROOT_DIR/src"
VERIF_BASE="$ROOT_DIR/verification"
TB_FILE="$VERIF_BASE/testbenches/system_tb/dual_riscv_system_tb.v"
CPP_FILE="$SCRIPT_DIR/dual_riscv_system_tb.cpp"

# Check if testbench exists
if [ ! -f "$TB_FILE" ]; then
    echo "ERROR: Testbench file not found: $TB_FILE"
    exit 1
fi

# Default test program
HEX_FILE="$VERIF_BASE/programs/dual_core_test.hex"
if [ -n "$TEST_PROGRAM" ]; then
    HEX_FILE="$VERIF_BASE/programs/$TEST_PROGRAM"
fi

echo "Testbench: $TB_FILE"
echo "Test program: $HEX_FILE"
echo ""

# Verilator compilation command
echo "Compiling with Verilator..."
echo ""

VERILATOR_CMD="verilator --cc --exe --build --trace -Wno-fatal \
    -I\"$SRC_BASE\" \
    -I\"$SRC_BASE/cores/serv/rtl\" \
    -I\"$SRC_BASE/axi_bridge/rtl/legacy/serv_bridge\" \
    -I\"$SRC_BASE/axi_interconnect/Verilog/rtl\" \
    -I\"$SRC_BASE/axi_interconnect/Verilog/rtl/core\" \
    -I\"$SRC_BASE/axi_interconnect/Verilog/rtl/decoders\" \
    -I\"$SRC_BASE/axi_interconnect/Verilog/rtl/slaves\" \
    -I\"$SRC_BASE/systems\" \
    -I\"$VERIF_BASE/testbenches/system_tb\" \
    -CFLAGS \"-DVERILATOR -DRAM_INIT_HEX=\\\"$HEX_FILE\\\"\" \
    \"$TB_FILE\" \
    \"$CPP_FILE\" \
    -o \"$BUILD_DIR/dual_riscv_system\""

echo "Running: $VERILATOR_CMD"
echo ""

# Run Verilator
eval $VERILATOR_CMD

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Verilator compilation failed!"
    exit 1
fi

echo ""
echo "============================================================================"
echo "Compilation completed successfully!"
echo "============================================================================"
echo ""
echo "Executable: $BUILD_DIR/dual_riscv_system"
echo ""
echo "Next step: Run ./run_simulation.sh"
echo ""

