# Quick Fix Guide - Remove Old RV32I Wrapper Files

## Problem
ModelSim is trying to open files from the old `riscv-axi-wrapper/original_backup/` directory that no longer exist:
- `D:/AXI/src/cores/riscv-axi-wrapper/original_backup/MUX2.v`
- `D:/AXI/src/cores/riscv-axi-wrapper/original_backup/CONTROL_PIPELINE.v`
- `D:/AXI/src/cores/riscv-axi-wrapper/original_backup/ID_EX.v`
- `D:/AXI/src/cores/riscv-axi-wrapper/original_backup/ADD.v`
- etc.

## Solution

### Option 1: Automatic Fix (Recommended)
Run this in ModelSim console:
```tcl
source scripts/fix_project.tcl
```

This will:
1. Remove all missing files and old RV32I wrapper files
2. Re-add all files with correct paths from `riscv-5stage-pipeline/RV32I_Pipeline/`

### Option 2: Manual Steps

**Step 1: Remove old files**
```tcl
source scripts/remove_missing_files.tcl
```

**Step 2: Re-add files**
```tcl
source scripts/add_files.tcl
```

### Option 3: Clean Rebuild
If you want to start fresh:
```tcl
source scripts/clean_and_rebuild.tcl
```

## After Fixing

1. **Compile all files:**
   ```tcl
   compile_all
   ```

2. **If compilation errors persist:**
   - Check that all RV32I files are in: `D:/AXI/src/cores/riscv-5stage-pipeline/RV32I_Pipeline/`
   - Verify file paths in `add_files.tcl` are correct

## File Locations

- **Old (removed):** `D:/AXI/src/cores/riscv-axi-wrapper/original_backup/`
- **New (correct):** `D:/AXI/src/cores/riscv-5stage-pipeline/RV32I_Pipeline/`

## Scripts Available

- `scripts/fix_project.tcl` - Complete fix (remove + re-add)
- `scripts/remove_missing_files.tcl` - Remove missing files only
- `scripts/remove_old_rv32i_files.tcl` - Remove old RV32I wrapper files only
- `scripts/add_files.tcl` - Add all files to project
- `scripts/clean_and_rebuild.tcl` - Clean rebuild everything

