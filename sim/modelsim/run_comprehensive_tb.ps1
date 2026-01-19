#==============================================================================
# run_comprehensive_tb.ps1
# Run comprehensive_system_tb.sv simulation with ModelSim
#==============================================================================

$ErrorActionPreference = "Stop"

# Get script directory
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $SCRIPT_DIR)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Run Comprehensive System Testbench" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Check for ModelSim
$VSIM_EXE = $null
$MODELSIM_PATHS = @(
    "C:\intelFPGA\*\modelsim_ase\win32aloem\vsim.exe",
    "C:\intelFPGA\*\modelsim_ae\win32aloem\vsim.exe",
    "C:\altera\*\modelsim_ase\win32aloem\vsim.exe",
    "C:\altera\*\modelsim_ae\win32aloem\vsim.exe",
    "C:\Modeltech_*\win64\vsim.exe",
    "C:\Program Files\Intel\Quartus Prime\*\modelsim_ase\win32aloem\vsim.exe"
)

foreach ($path in $MODELSIM_PATHS) {
    $found = Get-ChildItem -Path $path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $VSIM_EXE = $found.FullName
        break
    }
}

# Also check PATH
if (-not $VSIM_EXE) {
    $VSIM_EXE = Get-Command vsim -ErrorAction SilentlyContinue
    if ($VSIM_EXE) {
        $VSIM_EXE = $VSIM_EXE.Source
    }
}

if (-not $VSIM_EXE -or -not (Test-Path $VSIM_EXE)) {
    Write-Host "ERROR: ModelSim not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install ModelSim or add it to PATH" -ForegroundColor Yellow
    Write-Host "Or specify ModelSim path manually:" -ForegroundColor Yellow
    Write-Host "  `$env:VSIM_PATH = 'C:\path\to\modelsim\vsim.exe'" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Found ModelSim: $VSIM_EXE" -ForegroundColor Green
Write-Host ""

# TCL script path
$TCL_SCRIPT = Join-Path $SCRIPT_DIR "run_comprehensive_tb.tcl"

if (-not (Test-Path $TCL_SCRIPT)) {
    Write-Host "ERROR: TCL script not found: $TCL_SCRIPT" -ForegroundColor Red
    exit 1
}

Write-Host "TCL Script: $TCL_SCRIPT" -ForegroundColor Yellow
Write-Host ""

# Change to script directory
Set-Location $SCRIPT_DIR

# Run ModelSim
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Starting ModelSim..." -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Run ModelSim in batch mode with TCL script
# Use Start-Process or direct call with proper quoting
$TCL_SCRIPT_QUOTED = "`"$TCL_SCRIPT`""
& $VSIM_EXE -do $TCL_SCRIPT_QUOTED

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Simulation failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Simulation Complete" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan

