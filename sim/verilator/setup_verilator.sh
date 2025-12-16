#!/bin/bash
#==============================================================================
# setup_verilator.sh
# Setup script for Verilator simulation (Linux/macOS)
# Checks Verilator installation and sets up environment
#==============================================================================

echo "============================================================================"
echo "Verilator Setup Script"
echo "============================================================================"
echo ""

# Check if Verilator is installed
echo "Checking Verilator installation..."
if command -v verilator &> /dev/null; then
    VERILATOR_VERSION=$(verilator --version)
    echo "✓ Verilator is installed: $VERILATOR_VERSION"
else
    echo "✗ Verilator is NOT installed!"
    echo ""
    echo "Please install Verilator:"
    echo "  Linux (Ubuntu/Debian):"
    echo "    sudo apt-get install verilator"
    echo ""
    echo "  macOS:"
    echo "    brew install verilator"
    echo ""
    exit 1
fi

# Check if C++ compiler is available
echo ""
echo "Checking C++ compiler..."
if command -v g++ &> /dev/null; then
    CPP_VERSION=$(g++ --version | head -n 1)
    echo "✓ Found g++: $CPP_VERSION"
    CPP_COMPILER="g++"
elif command -v clang++ &> /dev/null; then
    CPP_VERSION=$(clang++ --version | head -n 1)
    echo "✓ Found clang++: $CPP_VERSION"
    CPP_COMPILER="clang++"
else
    echo "✗ No C++ compiler found!"
    echo ""
    echo "Please install a C++ compiler:"
    echo "  Linux: sudo apt-get install build-essential"
    echo "  macOS: Install Xcode Command Line Tools"
    echo ""
    exit 1
fi

# Check if Make is available
echo ""
echo "Checking Make..."
if command -v make &> /dev/null; then
    MAKE_VERSION=$(make --version | head -n 1)
    echo "✓ Found make: $MAKE_VERSION"
else
    echo "✗ Make not found!"
    echo ""
    echo "Please install Make:"
    echo "  Linux: sudo apt-get install build-essential"
    echo "  macOS: Install Xcode Command Line Tools"
    echo ""
    exit 1
fi

echo ""
echo "============================================================================"
echo "Setup completed successfully!"
echo "============================================================================"
echo ""
echo "Next steps:"
echo "  1. Run: ./compile_verilator.sh"
echo "  2. Run: ./run_simulation.sh"
echo ""


