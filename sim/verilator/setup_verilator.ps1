#==============================================================================
# setup_verilator.ps1
# Setup script for Verilator simulation
# Checks Verilator installation and sets up environment
#==============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Verilator Setup Script" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Verilator is installed
Write-Host "Checking Verilator installation..." -ForegroundColor Yellow
$verilatorVersion = & C:\msys64\mingw64\bin\verilator.exe --version 2>&1 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Verilator is installed: $verilatorVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Verilator is NOT installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Verilator:" -ForegroundColor Yellow
    Write-Host "  Windows (using MSYS2/MinGW):" -ForegroundColor Yellow
    Write-Host "    1. Install MSYS2 from https://www.msys2.org/" -ForegroundColor Yellow
    Write-Host "    2. In MSYS2 terminal, run: pacman -S verilator" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Linux (Ubuntu/Debian):" -ForegroundColor Yellow
    Write-Host "    sudo apt-get install verilator" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  macOS:" -ForegroundColor Yellow
    Write-Host "    brew install verilator" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check if C++ compiler is available
Write-Host ""
Write-Host "Checking C++ compiler..." -ForegroundColor Yellow
$cppCompiler = $null

# Try to find g++ or clang++
if (Get-Command g++ -ErrorAction SilentlyContinue) {
    $cppCompiler = "g++"
    $cppVersion = & g++ --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Found g++: $cppVersion" -ForegroundColor Green
} elseif (Get-Command clang++ -ErrorAction SilentlyContinue) {
    $cppCompiler = "clang++"
    $cppVersion = & clang++ --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Found clang++: $cppVersion" -ForegroundColor Green
} else {
    Write-Host "✗ No C++ compiler found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install a C++ compiler:" -ForegroundColor Yellow
    Write-Host "  Windows: Install MinGW-w64 or MSYS2" -ForegroundColor Yellow
    Write-Host "  Linux: sudo apt-get install build-essential" -ForegroundColor Yellow
    Write-Host "  macOS: Install Xcode Command Line Tools" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Check if Make is available
Write-Host ""
Write-Host "Checking Make..." -ForegroundColor Yellow
if (Get-Command make -ErrorAction SilentlyContinue) {
    $makeVersion = & make --version 2>&1 | Select-Object -First 1
    Write-Host "✓ Found make: $makeVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Make not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Make:" -ForegroundColor Yellow
    Write-Host "  Windows: Install MSYS2 or MinGW-w64" -ForegroundColor Yellow
    Write-Host "  Linux: sudo apt-get install build-essential" -ForegroundColor Yellow
    Write-Host "  macOS: Install Xcode Command Line Tools" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Run: .\compile_verilator.ps1" -ForegroundColor Yellow
Write-Host "  2. Run: .\run_simulation.ps1" -ForegroundColor Yellow
Write-Host ""



