#!/bin/bash
#==============================================================================
# compile_verilator_simple.sh
# Simplified compilation script - compiles testbench with all dependencies
#==============================================================================

set -e

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$( cd "$SCRIPT_DIR/../.." && pwd )"

echo "============================================================================"
echo "Verilator Compilation (Simplified)"
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
echo ""

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

# Check Verilator
if ! command -v verilator &> /dev/null; then
    echo "ERROR: Verilator not found!"
    echo "Please install: pacman -S mingw-w64-x86_64-verilator"
    exit 1
fi

echo "Verilator version:"
verilator --version
echo ""

# Verilator compilation
# Note: Verilator will automatically find and compile all dependencies
echo "Compiling with Verilator..."
echo "This may take a few minutes..."
echo ""

# Build command with all include paths
verilator \
    --cc \
    --exe \
    --build \
    --trace \
    -Wno-fatal \
    -Wno-UNOPTFLAT \
    -Wno-WIDTH \
    -I"$SRC_BASE" \
    -I"$SRC_BASE/cores/serv/rtl" \
    -I"$SRC_BASE/axi_bridge/rtl/legacy/serv_bridge" \
    -I"$SRC_BASE/axi_interconnect/Verilog/rtl" \
    -I"$SRC_BASE/axi_interconnect/Verilog/rtl/core" \
    -I"$SRC_BASE/axi_interconnect/Verilog/rtl/decoders" \
    -I"$SRC_BASE/axi_interconnect/Verilog/rtl/slaves" \
    -I"$SRC_BASE/systems" \
    -I"$VERIF_BASE/testbenches/system_tb" \
    -CFLAGS "-DVERILATOR -DRAM_INIT_HEX=\\\"$HEX_FILE\\\"" \
    "$TB_FILE" \
    "$CPP_FILE" \
    -o "$BUILD_DIR/dual_riscv_system" 2>&1 | tee "$BUILD_DIR/compile.log"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo ""
    echo "ERROR: Verilator compilation failed!"
    echo "Check compile.log for details: $BUILD_DIR/compile.log"
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


