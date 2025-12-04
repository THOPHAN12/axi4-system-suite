# Quartus Compilation Error - Fix Instructions

## Error Messages
```
Error (12006): Node instance "u_Qos_Arbiter" instantiates undefined entity "Qos_Arbiter"
Error (12006): Node instance "u_Read_Arbiter" instantiates undefined entity "Read_Arbiter"
```

## Root Cause
The arbiter algorithm files were not added to your existing Quartus project.

## Solution - Quick Fix (RECOMMENDED)

### Step 1: Open Quartus Project
1. Open **Quartus II** GUI
2. **File → Open Project**
3. Select your `.qpf` project file

### Step 2: Open Tcl Console
- **View → Utility Windows → Tcl Console**

### Step 3: Run Manual Fix Script
In the Tcl Console, type:
```tcl
cd D:/AXI/synthesis/scripts/quartus
source manual_add_arbiters.tcl
```

You should see:
```
✓ Added: arbiter_fixed_priority.v
✓ Added: arbiter_round_robin.v
✓ Added: arbiter_qos_based.v
✓ Added: read_arbiter.v
✓ Saved to project!
```

### Step 4: Recompile
- **Processing → Start Compilation**
- Or: **Processing → Start → Start Analysis & Elaboration** (faster test)

---

## Alternative - Full Project Rebuild

If the quick fix doesn't work, you may need to rebuild the project:

### Option 1: Add Files Manually in GUI
1. In Quartus: **Project → Add/Remove Files in Project**
2. Click **...** (Browse) button
3. Navigate to: `D:\AXI\src\axi_interconnect\Verilog\rtl\arbitration\algorithms\`
4. Add these 4 files:
   - `arbiter_fixed_priority.v`
   - `arbiter_round_robin.v`
   - `arbiter_qos_based.v` ← **Qos_Arbiter**
   - `read_arbiter.v` ← **Read_Arbiter**
5. Click **OK**
6. Recompile

### Option 2: Create New Project
1. Delete old project files (`.qpf`, `.qsf`)
2. Create new project via GUI:
   - **File → New Project Wizard**
   - Project name: `AXI_Interconnect_System`
   - Location: `D:\AXI\synthesis\scripts\quartus\`
3. In Tcl Console:
   ```tcl
   cd D:/AXI/synthesis/scripts/quartus
   source add_source_files.tcl
   ```
4. Compile

---

## Verification

After adding files, verify in **Project Navigator**:

```
Files
├── arbitration/
│   └── algorithms/
│       ├── arbiter_fixed_priority.v
│       ├── arbiter_round_robin.v
│       ├── arbiter_qos_based.v      ← Defines Qos_Arbiter
│       └── read_arbiter.v            ← Defines Read_Arbiter
├── channel_controllers/
│   └── write/
│       └── AW_Channel_Controller_Top.v  (uses Qos_Arbiter)
│   └── read/
│       └── AR_Channel_Controller_Top.v   (uses Read_Arbiter)
└── core/
    ├── AXI_Interconnect_Full.v
    └── AXI_Interconnect.v
```

**Key Check**: Arbiter files must appear **BEFORE** channel controllers in the file list!

---

## Troubleshooting

### If Error Persists
1. Check **Messages** window for actual file paths
2. Ensure arbiter files are in **correct order** (before controllers)
3. Try **Processing → Start → Start Analysis & Elaboration** for quick test
4. Check **Compilation Report → Analysis & Synthesis → Module Hierarchy**

### If Files Not Found
Verify files exist:
```powershell
cd D:\AXI
Get-ChildItem -Path "src\axi_interconnect\Verilog\rtl\arbitration\algorithms" -Filter "*.v"
```

Should show 4 files including `arbiter_qos_based.v` and `read_arbiter.v`.

---

## Files Available
- ✅ `add_source_files.tcl` - Full project setup (updated)
- ✅ `manual_add_arbiters.tcl` - Quick fix for existing projects
- ✅ `test_arbiter_paths.tcl` - Verify file paths

---

**Last Updated**: Dec 4, 2025  
**Status**: Scripts updated and tested

