# Test Scripts Index

## 🚀 **QUICK ACCESS**

### **Want to test RIGHT NOW?**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
run_tests.bat
```
**OR**
```bash
vsim -c -do "do run_quick_arb_test.tcl"
```

---

## 📂 **All Files in This Directory**

### **🎯 Launchers (Start Here!)**
| File | Type | Purpose |
|------|------|---------|
| `run_tests.bat` | Batch | Windows menu launcher |
| `run_tests.ps1` | PowerShell | PowerShell menu launcher |

### **🧪 Test Scripts**
| File | What it Tests | Time |
|------|---------------|------|
| `run_quick_arb_test.tcl` | Quick check (Verilog, 3 modes) | 10s |
| `run_all_tests.tcl` | Everything (Verilog + SV + System) | 2min |
| `compile_and_sim_verilog_arb.tcl` | Verilog arbitration (all modes) | 30s |
| `compile_and_sim_sv_arb.tcl` | SystemVerilog arbitration (all modes) | 30s |
| `compile_dual_riscv_system.tcl` | Full system compilation | 60s |

### **📖 Documentation**
| File | Content |
|------|---------|
| `QUICK_START.md` | 5-minute getting started |
| `README_TCL_SCRIPTS.md` | Complete documentation (20+ pages) |
| `INDEX.md` | This file |

---

## 🎯 **Choose Your Path**

### **Path 1: "I just want to test!"**
```bash
run_tests.bat
# Select option 1 (Quick Test)
```
**→ Result in 10 seconds**

### **Path 2: "I want to understand first"**
1. Read `QUICK_START.md` (5 min)
2. Run `vsim -c -do "do run_quick_arb_test.tcl"`
3. Read `README_TCL_SCRIPTS.md` for details

### **Path 3: "I need everything tested"**
```bash
vsim -c -do "do run_all_tests.tcl"
```
**→ Complete report in 2 minutes**

### **Path 4: "I want to debug with waveforms"**
```bash
vsim -gui work.arb_test_verilog -g ARBIT_MODE=1
add wave -r /*
run -all
```

---

## 🏆 **Recommended First Command**

```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -c -do "do run_quick_arb_test.tcl"
```

This will verify:
- ✅ Your setup is working
- ✅ All 3 arbitration modes work
- ✅ Expected results match actual results
- ✅ Takes only 10 seconds

---

## 📊 **Scripts Comparison**

| Script | Scope | Coverage | Time | Output |
|--------|-------|----------|------|--------|
| `run_quick_arb_test.tcl` | Basic | 3 modes | 10s | PASS/FAIL |
| `compile_and_sim_verilog_arb.tcl` | Arbitration | 3 modes | 30s | Detailed |
| `compile_and_sim_sv_arb.tcl` | Arbitration | 3 modes | 30s | Detailed |
| `compile_dual_riscv_system.tcl` | System | Compile only | 60s | Status |
| `run_all_tests.tcl` | Complete | 6+ tests | 2min | Summary |

---

## 🎓 **Learning Resources**

**New to the project?**
1. Start: `QUICK_START.md`
2. Run: `run_quick_arb_test.tcl`
3. Learn: `README_TCL_SCRIPTS.md`

**Need troubleshooting?**
→ See `README_TCL_SCRIPTS.md` § Troubleshooting

**Want to customize tests?**
→ See `README_TCL_SCRIPTS.md` § Manual Workflow

**Looking for arbitration details?**
→ See `../../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/ARBITRATION_README.md`

---

## 🔗 **External Links**

| Resource | Location |
|----------|----------|
| **Testbench Details** | `../../../../tb/interconnect_tb/TESTBENCH_README.md` |
| **Arbitration Modes** | `../../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/ARBITRATION_README.md` |
| **Project Summary** | `../../../../ARBITRATION_UPGRADE_SUMMARY.md` |
| **TCL Summary** | `../../../../TCL_SCRIPTS_SUMMARY.md` |

---

## ⚡ **Keyboard Shortcuts**

In this directory:

```bash
# Quick test
vsim -c -do "do run_quick_arb_test.tcl"

# Full test
vsim -c -do "do run_all_tests.tcl"

# Menu
run_tests.bat

# Help
cat QUICK_START.md
```

---

**Last Updated:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Ready

