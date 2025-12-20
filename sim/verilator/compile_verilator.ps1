#==============================================================================
# compile_verilator.ps1
# Compile dual RISC-V system with Verilator
#==============================================================================

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Verilator Compilation Script" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Root directory: $ROOT_DIR" -ForegroundColor Yellow
Write-Host "Script directory: $SCRIPT_DIR" -ForegroundColor Yellow
Write-Host ""

# Change to script directory
Set-Location $SCRIPT_DIR

# Create build directory
$BUILD_DIR = Join-Path $SCRIPT_DIR "build"
if (-not (Test-Path $BUILD_DIR)) {
    New-Item -ItemType Directory -Path $BUILD_DIR | Out-Null
    Write-Host "Created build directory: $BUILD_DIR" -ForegroundColor Green
}

# Paths
$SRC_BASE = Join-Path $ROOT_DIR "src"
$VERIF_BASE = Join-Path $ROOT_DIR "verification"
$TB_FILE = Join-Path $VERIF_BASE "testbenches\system_tb\dual_riscv_system_tb.v"

# Check if testbench exists
if (-not (Test-Path $TB_FILE)) {
    Write-Host "ERROR: Testbench file not found: $TB_FILE" -ForegroundColor Red
    exit 1
}

# Default test program
$HEX_FILE = Join-Path $VERIF_BASE "programs\dual_core_test.hex"
if ($env:TEST_PROGRAM) {
    $HEX_FILE = Join-Path $VERIF_BASE "programs\$env:TEST_PROGRAM"
}

Write-Host "Testbench: $TB_FILE" -ForegroundColor Yellow
Write-Host "Test program: $HEX_FILE" -ForegroundColor Yellow
Write-Host ""

# Find Verilator executable
$MSYS2_BASE = "C:\msys64"
$VERILATOR_EXE = Join-Path $MSYS2_BASE "mingw64\bin\verilator.exe"

if (-not (Test-Path $VERILATOR_EXE)) {
    Write-Host "ERROR: Verilator not found at $VERILATOR_EXE" -ForegroundColor Red
    Write-Host "Please run .\install_and_test.ps1 first to install Verilator" -ForegroundColor Yellow
    exit 1
}

# Update PATH to include MSYS2 tools
$env:PATH = "$MSYS2_BASE\mingw64\bin;$MSYS2_BASE\usr\bin;$env:PATH"

# Verilator compilation command
# Note: Verilator requires SystemVerilog or Verilog, and generates C++ code
Write-Host "Compiling with Verilator..." -ForegroundColor Yellow
Write-Host "Using Verilator: $VERILATOR_EXE" -ForegroundColor Yellow
Write-Host ""

# Get C++ wrapper file
$CPP_FILE = Join-Path $SCRIPT_DIR "dual_riscv_system_tb.cpp"

# Verilator flags:
# --cc: Generate C++ code
# --exe: Generate executable wrapper
# --build: Build the executable
# --trace: Enable waveform tracing (VCD)
# -Wno-fatal: Don't stop on warnings
# -I: Include directories
# -CFLAGS: C++ compiler flags

$VERILATOR_ARGS = @(
    "--cc",
    "--exe",
    "--build",
    "--trace",
    "-Wno-fatal",
    "-I`"$SRC_BASE`"",
    "-I`"$SRC_BASE\cores\serv\rtl`"",
    "-I`"$SRC_BASE\axi_bridge\rtl\legacy\serv_bridge`"",
    "-I`"$SRC_BASE\axi_interconnect\Verilog\rtl`"",
    "-I`"$SRC_BASE\axi_interconnect\Verilog\rtl\core`"",
    "-I`"$SRC_BASE\axi_interconnect\Verilog\rtl\decoders`"",
    "-I`"$SRC_BASE\axi_interconnect\Verilog\rtl\slaves`"",
    "-I`"$SRC_BASE\systems`"",
    "-I`"$VERIF_BASE\testbenches\system_tb`"",
    "-CFLAGS", "`"-DVERILATOR -DRAM_INIT_HEX=\\\`"$HEX_FILE\\\`"`"",
    "`"$TB_FILE`"",
    "`"$CPP_FILE`"",
    "-o", "`"$BUILD_DIR\dual_riscv_system`""
)

Write-Host "Running: $VERILATOR_EXE $($VERILATOR_ARGS -join ' ')" -ForegroundColor Cyan
Write-Host ""

# Run Verilator
& $VERILATOR_EXE $VERILATOR_ARGS

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Verilator compilation failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Compilation completed successfully!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Executable: $BUILD_DIR\dual_riscv_system.exe" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next step: Run .\run_simulation.ps1" -ForegroundColor Yellow
Write-Host ""

