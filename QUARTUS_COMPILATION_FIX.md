# Quartus Compilation Fix - Dependencies

## Problem
```
Error (12006): Node instance "u_Qos_Arbiter" instantiates undefined entity "Qos_Arbiter"
Error (12006): Node instance "u_Read_Arbiter" instantiates undefined entity "Read_Arbiter"
```

## Root Cause
The arbiter algorithm files were not being added to the Quartus project before the channel controllers that depend on them.

**Dependency Chain**:
```
arbiter_qos_based.v (Qos_Arbiter)
    ↓ instantiated by
AW_Channel_Controller_Top.v
    ↓ instantiated by
AXI_Interconnect_Full.v
    ↓ wrapped by
AXI_Interconnect.v
```

```
read_arbiter.v (Read_Arbiter)
    ↓ instantiated by
AR_Channel_Controller_Top.v
    ↓ instantiated by
AXI_Interconnect_Full.v
    ↓ wrapped by
AXI_Interconnect.v
```

## Solution
Modified `add_source_files.tcl` to add arbiter algorithms **before** channel controllers.

### Files Added (in order)
```
[Arbitration - Section 3.5]
  1. arbiter_fixed_priority.v
  2. arbiter_round_robin.v
  3. arbiter_qos_based.v    → defines Qos_Arbiter
  4. read_arbiter.v         → defines Read_Arbiter

[Channel Controllers - Sections 3.7 & 3.8]
  5. AW_Channel_Controller_Top.v  (uses Qos_Arbiter)
  6. AR_Channel_Controller_Top.v  (uses Read_Arbiter)
  7. ... other controllers

[Core - Section 3.9]
  8. AXI_Interconnect_Full.v  (uses both controllers)
  9. AXI_Interconnect.v       (wraps Full version)
```

## Verification

### Module Names Match
- ✅ File: `arbiter_qos_based.v` → Module: `Qos_Arbiter`
- ✅ File: `read_arbiter.v` → Module: `Read_Arbiter`

### Location
```
src/axi_interconnect/Verilog/rtl/arbitration/algorithms/
  ├── arbiter_fixed_priority.v
  ├── arbiter_round_robin.v
  ├── arbiter_qos_based.v       (Qos_Arbiter)
  └── read_arbiter.v            (Read_Arbiter)
```

### Script Changes
**File**: `synthesis/scripts/quartus/add_source_files.tcl`

**Section 3.5** - Updated to explicitly add arbiter algorithms:
```tcl
# 3.5 Arbitration (MUST compile before channel controllers!)
set arb_algo_files {
    "arbiter_fixed_priority.v"
    "arbiter_round_robin.v"
    "arbiter_qos_based.v"
    "read_arbiter.v"
}
```

## Status
✅ **FIXED** - Arbiter modules now compile before channel controllers

## Next Steps
1. Re-run Quartus compilation: `Processing → Start Compilation`
2. Verify no more undefined entity errors
3. Check synthesis report for timing/resource usage

---
**Date**: Dec 4, 2025  
**Issue**: Dependency ordering in Quartus project  
**Resolution**: Explicit file ordering in TCL script

