# FRISCV Compilation Fix Guide

## Problem
`friscv_memfy_h.sv` fails to compile with error: `Undefined variable: 'XLEN'`

## Root Cause
ModelSim cannot find `friscv_h.sv` when compiling `friscv_memfy_h.sv` because:
1. Include directory is not set in ModelSim project settings
2. Files are compiled in wrong order (memfy_h before friscv_h)
3. Include path resolution fails

## Solution

### Option 1: Use Compile Script (RECOMMENDED)

**Step 1: Open ModelSim and navigate to project directory**
```tcl
cd D:/AXI/sim/modelsim/AXI_Interconnect
```

**Step 2: Open project**
```tcl
project open project/AXI_Project.mpf
```

**Step 3: Compile FRISCV files with include directory**
```tcl
source scripts/compile_friscv.tcl
```

This script will:
- Set include directory: `+incdir+D:/AXI/src/cores/friscv/friscv/rtl`
- Compile `friscv_h.sv` FIRST
- Then compile `friscv_memfy_h.sv` and other headers
- Compile FRISCV core and system files

### Option 2: Set Include Directory in Project Settings

**Step 1: Open Project Settings**
- Right-click on project in Project window
- Select "Project Settings" (or Project → Project Settings)

**Step 2: Set Include Directory**
- Go to "Compile" tab
- In "Include directories" field, add:
  ```
  D:/AXI/src/cores/friscv/friscv/rtl
  ```
- Click "OK"

**Step 3: Compile in Correct Order**
- Compile `friscv_h.sv` FIRST
- Then compile `friscv_memfy_h.sv`
- Then compile other FRISCV files

### Option 3: Manual Compile with Include Directory

```tcl
# Set paths
set FRISCV_DIR "D:/AXI/src/cores/friscv/friscv/rtl"
set INCDIR "+incdir+${FRISCV_DIR}"

# Compile in correct order:
# 1. friscv_h.sv FIRST (defines XLEN)
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_h.sv

# 2. Other headers
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_debug_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_memfy_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_control_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_checkers.sv

# 3. FRISCV core
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_rv32i_core.sv
```

## File Modifications Made

1. **friscv_memfy_h.sv**: Added fallback `XLEN` definition before include
   - `XLEN` is now defined as 32 before any use
   - This ensures compilation even if include fails

## Verification

After compilation, verify:
```tcl
# Check if files compiled successfully
vlog -work work -list

# Or check for errors
# Look for "Error" messages in transcript
```

## Troubleshooting

### Still getting "Undefined variable: 'XLEN'"?

1. **Check include directory is set:**
   ```tcl
   # In ModelSim, check current include directories
   # Project → Project Settings → Compile tab
   ```

2. **Verify friscv_h.sv is compiled first:**
   ```tcl
   # Check work library
   vdir work
   # Should see friscv_h in the list before friscv_memfy_h
   ```

3. **Recompile in correct order:**
   ```tcl
   # Remove old compilation
   vdel -work work friscv_memfy_h
   vdel -work work friscv_h
   
   # Recompile with script
   source scripts/compile_friscv.tcl
   ```

### Include file not found?

1. **Verify file exists:**
   ```tcl
   file exists D:/AXI/src/cores/friscv/friscv/rtl/friscv_h.sv
   # Should return 1
   ```

2. **Check path format:**
   - Use forward slashes `/` or double backslashes `\\`
   - Windows paths: `D:/AXI/...` or `D:\\AXI\\...`

## Summary

- **Best Practice**: Always use `compile_friscv.tcl` script
- **Fallback**: Set include directory in project settings
- **Manual**: Compile with `+incdir` option and correct order

The key is: **Compile `friscv_h.sv` BEFORE `friscv_memfy_h.sv`** and **set include directory**.

