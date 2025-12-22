#==============================================================================
# Run Comprehensive Testbench in Vivado
#==============================================================================

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Join-Path $ScriptDir "axi4_system_sv_kv260"
$ProjectFile = Join-Path $ProjectDir "axi4_system_sv_kv260.xpr"
$RunScript = Join-Path $ScriptDir "run_comprehensive_simple.tcl"

Write-Host "============================================================================"
Write-Host "Running Comprehensive Testbench in Vivado"
Write-Host "============================================================================"
Write-Host ""

# Check if project exists
if (-not (Test-Path $ProjectFile)) {
    Write-Host "ERROR: Project file not found: $ProjectFile"
    exit 1
}

Write-Host "Project: $ProjectFile"
Write-Host "Run Script: $RunScript"
Write-Host ""

# Try to find Vivado
$VivadoPath = $null
$PossiblePaths = @(
    "C:\Xilinx\Vivado\*\bin\vivado.bat",
    "C:\Xilinx\Vivado\*\bin\xvlog.bat",
    "${env:ProgramFiles}\Xilinx\Vivado\*\bin\vivado.bat",
    "${env:ProgramFiles(x86)}\Xilinx\Vivado\*\bin\vivado.bat"
)

foreach ($Path in $PossiblePaths) {
    $Found = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($Found) {
        $VivadoPath = $Found.FullName
        break
    }
}

if (-not $VivadoPath) {
    # Try to find in PATH
    $VivadoInPath = Get-Command vivado -ErrorAction SilentlyContinue
    if ($VivadoInPath) {
        $VivadoPath = $VivadoInPath.Source
    }
}

if (-not $VivadoPath) {
    Write-Host "ERROR: Vivado not found!"
    Write-Host "Please ensure Vivado is installed and in PATH, or modify this script"
    Write-Host ""
    Write-Host "You can also run manually:"
    Write-Host "  1. Open Vivado"
    Write-Host "  2. Open project: $ProjectFile"
    Write-Host "  3. In TCL Console, run: source $RunScript"
    exit 1
}

Write-Host "Found Vivado: $VivadoPath"
Write-Host ""

# Create TCL script to run simulation
$TclScript = @"
# Open project
open_project "$ProjectFile"

# Source the run script
source "$RunScript"

# Exit
exit
"@

$TclScriptFile = Join-Path $ScriptDir "run_vivado_sim.tcl"
$TclScript | Out-File -FilePath $TclScriptFile -Encoding ASCII

Write-Host "Running simulation..."
Write-Host ""

# Run Vivado in batch mode
$VivadoDir = Split-Path -Parent $VivadoPath
$VivadoExe = Join-Path $VivadoDir "vivado.bat"

if (Test-Path $VivadoExe) {
    & $VivadoExe -mode batch -source $TclScriptFile 2>&1 | Tee-Object -Variable Output
} else {
    # Try xsim directly if available
    $XSimPath = Join-Path $VivadoDir "xsim.bat"
    if (Test-Path $XSimPath) {
        Write-Host "Note: Using xsim directly (project must be already compiled)"
        & $XSimPath -runall 2>&1 | Tee-Object -Variable Output
    } else {
        Write-Host "ERROR: Cannot find vivado.bat or xsim.bat"
        exit 1
    }
}

Write-Host ""
Write-Host "============================================================================"
Write-Host "Simulation Output:"
Write-Host "============================================================================"
Write-Host $Output
Write-Host ""

# Check for errors
if ($Output -match "ERROR|Error|error") {
    Write-Host "WARNING: Errors detected in simulation output"
    exit 1
}

# Check for test results
if ($Output -match "All Tests Complete|PASS|Pass Rate") {
    Write-Host "SUCCESS: Test results found in output"
} else {
    Write-Host "Note: Check output above for test results"
}

Write-Host ""
Write-Host "Done!"


















