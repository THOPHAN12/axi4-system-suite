#==============================================================================
# install_and_test.ps1
# Install Verilator via MSYS2 and test compilation
#==============================================================================

$ErrorActionPreference = "Stop"

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Verilator Installation and Test Script" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# MSYS2 paths
$MSYS2_BASE = "C:\msys64"
$MSYS2_BASH = Join-Path $MSYS2_BASE "usr\bin\bash.exe"
$VERILATOR_PATH = Join-Path $MSYS2_BASE "mingw64\bin\verilator.exe"

# Check if MSYS2 exists
if (-not (Test-Path $MSYS2_BASH)) {
    Write-Host "ERROR: MSYS2 not found at $MSYS2_BASE" -ForegroundColor Red
    Write-Host "Please install MSYS2 from https://www.msys2.org/" -ForegroundColor Yellow
    exit 1
}

Write-Host "MSYS2 found at: $MSYS2_BASE" -ForegroundColor Green
Write-Host ""

# Check if Verilator is already installed
if (Test-Path $VERILATOR_PATH) {
    Write-Host "Verilator is already installed!" -ForegroundColor Green
    & $VERILATOR_PATH --version
    Write-Host ""
} else {
    Write-Host "Verilator not found. Installing..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes..." -ForegroundColor Yellow
    Write-Host ""
    
    # Install Verilator via MSYS2
    $installCmd = "pacman -S --noconfirm mingw-w64-x86_64-verilator"
    & $MSYS2_BASH -lc $installCmd
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "ERROR: Installation failed!" -ForegroundColor Red
        Write-Host "Please install manually in MSYS2 terminal:" -ForegroundColor Yellow
        Write-Host "  pacman -S mingw-w64-x86_64-verilator" -ForegroundColor Yellow
        exit 1
    }
    
    # Check again
    if (Test-Path $VERILATOR_PATH) {
        Write-Host ""
        Write-Host "Verilator installed successfully!" -ForegroundColor Green
        & $VERILATOR_PATH --version
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "ERROR: Verilator installation completed but executable not found!" -ForegroundColor Red
        Write-Host "Please check MSYS2 installation." -ForegroundColor Yellow
        exit 1
    }
}

# Now test compilation
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Testing Verilator compilation..." -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Update PATH to include MSYS2 mingw64 bin
$env:PATH = "$MSYS2_BASE\mingw64\bin;$MSYS2_BASE\usr\bin;$env:PATH"

# Run setup script
Write-Host "Running setup script..." -ForegroundColor Yellow
& "$PSScriptRoot\setup_verilator.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: Setup check failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Setup completed! You can now run:" -ForegroundColor Green
Write-Host "  .\compile_verilator.ps1" -ForegroundColor Yellow
Write-Host "  .\run_simulation.ps1" -ForegroundColor Yellow
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""


