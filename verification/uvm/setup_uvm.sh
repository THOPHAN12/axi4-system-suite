#!/usr/bin/env bash
# Helper script to locate and export UVM_HOME on Linux/macOS environments.

set -e

echo "Searching for UVM library..."

CANDIDATES=(
    "/opt/intelFPGA_lite/13.0/modelsim_ase/verilog_src/uvm-1.1d"
    "/opt/intelFPGA/modelsim_ase/verilog_src/uvm-1.1d"
    "$HOME/intelFPGA_lite/13.0/modelsim_ase/verilog_src/uvm-1.1d"
    "$HOME/intelFPGA/modelsim_ase/verilog_src/uvm-1.1d"
    "$QUESTA_HOME/verilog_src/uvm-1.1d"
)

for path in "${CANDIDATES[@]}"; do
    if [ -n "$path" ] && [ -d "$path" ]; then
        export UVM_HOME="$path"
        echo "Found UVM at: $UVM_HOME"
        echo "Run 'export UVM_HOME=$UVM_HOME' in your shell configuration to persist."
        exit 0
    fi
done

echo "UVM library not found in default locations."
echo "Please download UVM 1.1d from Accellera and set UVM_HOME manually."
exit 1


