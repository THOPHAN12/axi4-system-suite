#==============================================================================
# run_simulation.ps1
# Run Verilator simulation
#==============================================================================

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BUILD_DIR = Join-Path $SCRIPT_DIR "build"
$EXE_FILE = Join-Path $BUILD_DIR "dual_riscv_system.exe"

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Verilator Simulation" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if executable exists
if (-not (Test-Path $EXE_FILE)) {
    Write-Host "ERROR: Executable not found: $EXE_FILE" -ForegroundColor Red
    Write-Host "Please run .\compile_verilator.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "Running simulation..." -ForegroundColor Yellow
Write-Host "Executable: $EXE_FILE" -ForegroundColor Yellow
Write-Host ""

# Run simulation
& $EXE_FILE

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Simulation failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Simulation completed!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Check for waveform file
$VCD_FILE = Join-Path $BUILD_DIR "dual_riscv_system.vcd"
if (Test-Path $VCD_FILE) {
    Write-Host "Waveform file: $VCD_FILE" -ForegroundColor Yellow
    Write-Host "You can view it with GTKWave or other VCD viewers" -ForegroundColor Yellow
}

Write-Host ""


