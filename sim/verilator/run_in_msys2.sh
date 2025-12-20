#!/bin/bash
# Quick start script for MSYS2 bash users

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "============================================================================"
echo "Verilator Quick Start - MSYS2"
echo "============================================================================"
echo "Current directory: $SCRIPT_DIR"
echo ""

# Check if Verilator is installed
if ! command -v verilator &> /dev/null; then
    echo "Verilator not found. Installing..."
    pacman -S --noconfirm mingw-w64-x86_64-verilator
fi

# Make scripts executable
chmod +x *.sh

# Run setup
echo "Running setup..."
./setup_verilator.sh

# Compile
echo ""
echo "Compiling..."
./compile_verilator.sh

# Run simulation
echo ""
echo "Running simulation..."
./run_simulation.sh
