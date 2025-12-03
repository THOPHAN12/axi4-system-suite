# Quick Start Guide - ModelSim/QuestaSim Testing

## 🚀 **Fastest Way to Test**

### **Windows Command Prompt:**
```batch
cd D:\AXI\sim\modelsim\scripts\sim
run_tests.bat
```

### **PowerShell:**
```powershell
cd D:\AXI\sim\modelsim\scripts\sim
.\run_tests.ps1
```

### **Direct TCL:**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -do "do run_all_tests.tcl"
```

---

## 📋 **Available Tests**

| Test | Command | Time | Description |
|------|---------|------|-------------|
| **Quick Test** | `vsim -c -do "do run_quick_arb_test.tcl"` | 10s | Fast arbitration check |
| **Verilog Full** | `vsim -c -do "do compile_and_sim_verilog_arb.tcl"` | 30s | All 3 modes (Verilog) |
| **SystemVerilog** | `vsim -c -do "do compile_and_sim_sv_arb.tcl"` | 30s | All 3 modes (SV) |
| **System Compile** | `vsim -c -do "do compile_dual_riscv_system.tcl"` | 60s | Full system |
| **All Tests** | `vsim -c -do "do run_all_tests.tcl"` | 2min | Complete suite |

---

## ✅ **Expected Results**

### **FIXED Mode:**
```
M0 granted: 10 times
M1 granted: 0 times
>>> PASS: FIXED mode works (M0 always wins)
```

### **ROUND_ROBIN Mode:**
```
M0 granted: 5 times
M1 granted: 5 times
>>> PASS: ROUND_ROBIN mode works (fair 50/50)
```

### **QOS Mode:**
```
M0 granted: 10 times
M1 granted: 0 times
>>> PASS: QOS mode works (M0 QoS=10 > M1 QoS=2)
```

---

## 🔧 **Setup (First Time Only)**

### **1. Add ModelSim/QuestaSim to PATH**

**Command Prompt:**
```batch
set PATH=%PATH%;C:\questasim64_10.2c\win64
```

**PowerShell:**
```powershell
$env:PATH += ";C:\questasim64_10.2c\win64"
```

### **2. Verify Installation**
```bash
vsim -version
```

Should show:
```
Model Technology ModelSim [version]
# or
Questa [version]
```

---

## 📁 **File Structure**

```
D:\AXI\sim\modelsim\scripts\sim\
├── run_tests.bat                        # Windows launcher
├── run_tests.ps1                        # PowerShell launcher
├── run_all_tests.tcl                    # Master test suite
├── run_quick_arb_test.tcl               # Quick test
├── compile_and_sim_verilog_arb.tcl      # Verilog tests
├── compile_and_sim_sv_arb.tcl           # SystemVerilog tests
├── compile_dual_riscv_system.tcl        # System compilation
├── README_TCL_SCRIPTS.md                # Full documentation
├── QUICK_START.md                       # This file
└── work/                                # Compiled library (created)
```

---

## 💡 **Pro Tips**

1. **Use batch/PowerShell scripts** for menu-driven testing
2. **Run quick test first** to verify setup
3. **Check transcript file** if output scrolls too fast
4. **Use Verilog tests** for maximum compatibility
5. **SystemVerilog requires** QuestaSim 2016+ or ModelSim 2016+

---

## 🐛 **Common Issues**

### **"vsim: command not found"**
➜ Add ModelSim/QuestaSim to PATH (see Setup above)

### **"Failed to open design unit file"**
➜ Make sure you're in `D:\AXI\sim\modelsim\scripts\sim` directory

### **"SystemVerilog features not supported"**
➜ Use Verilog tests instead: `compile_and_sim_verilog_arb.tcl`

### **Tests pass but want to see waveforms**
➜ Use GUI mode:
```bash
vsim -gui work.arb_test_verilog -g ARBIT_MODE=1
add wave -r /*
run -all
```

---

## 📊 **Test Coverage**

The test suite validates:
- ✅ **FIXED Priority** - M0 always wins
- ✅ **ROUND_ROBIN** - Fair 50/50 arbitration
- ✅ **QOS** - Priority based on QoS values
- ✅ **2 RISC-V Masters** - Dual core system
- ✅ **4 AXI-Lite Slaves** - RAM, GPIO, UART, SPI
- ✅ **Write/Read Channels** - Independent arbitration

---

## 📚 **More Information**

- **Full Documentation:** `README_TCL_SCRIPTS.md`
- **Testbench Details:** `../../../../tb/interconnect_tb/TESTBENCH_README.md`
- **Arbitration Modes:** `../../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/ARBITRATION_README.md`

---

## 🎯 **Recommended First Test**

```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -c -do "do run_quick_arb_test.tcl"
```

This will:
1. ✅ Verify your ModelSim setup
2. ✅ Test all 3 arbitration modes
3. ✅ Show PASS/FAIL results
4. ✅ Complete in ~10 seconds

---

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Ready to Use

