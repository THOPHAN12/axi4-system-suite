# TCL Scripts for ModelSim/QuestaSim Testing

## 📁 Available Scripts

### **1. Arbitration Tests (Verilog)**
**File:** `compile_and_sim_verilog_arb.tcl`

**Purpose:** Test all 3 arbitration modes using Verilog testbench

**Usage:**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -do "do compile_and_sim_verilog_arb.tcl"
```

**What it does:**
1. Compiles `axi_rr_interconnect_2x4.v` (Verilog RTL)
2. Compiles `arb_test_verilog.v` (testbench)
3. Runs 3 tests:
   - FIXED mode (ARBIT_MODE=0)
   - ROUND_ROBIN mode (ARBIT_MODE=1)
   - QOS mode (ARBIT_MODE=2)
4. Shows PASS/FAIL results for each mode

---

### **2. Arbitration Tests (SystemVerilog)**
**File:** `compile_and_sim_sv_arb.tcl`

**Purpose:** Test all 3 arbitration modes using SystemVerilog testbench

**Usage:**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -do "do compile_and_sim_sv_arb.tcl"
```

**What it does:**
1. Compiles `axi_rr_interconnect_2x4.sv` (SystemVerilog RTL)
2. Compiles `arb_test_systemverilog.sv` (testbench)
3. Runs 3 tests:
   - FIXED mode (ARBIT_MODE="FIXED")
   - ROUND_ROBIN mode (ARBIT_MODE="ROUND_ROBIN")
   - QOS mode (ARBIT_MODE="QOS")
4. Shows PASS/FAIL results for each mode

**Note:** Requires QuestaSim 2016+ or ModelSim 2016+ with SystemVerilog support

---

### **3. Complete System Compilation**
**File:** `compile_dual_riscv_system.tcl`

**Purpose:** Compile entire dual RISC-V AXI system (no simulation)

**Usage:**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -do "do compile_dual_riscv_system.tcl"
```

**What it compiles:**
1. SERV RISC-V cores (2 instances)
2. AXI adapters
3. AXI interconnect with arbitration
4. 4 AXI-Lite peripherals (RAM, GPIO, UART, SPI)
5. Top-level system wrapper

**After compilation:**
```tcl
# In ModelSim console:
vsim work.dual_riscv_axi_system
# Or with GUI:
vsim -gui work.dual_riscv_axi_system
```

---

### **4. Quick Arbitration Test**
**File:** `run_quick_arb_test.tcl`

**Purpose:** Fast test of arbitration without full system

**Usage:**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -do "do run_quick_arb_test.tcl"
```

**What it does:**
- Automatically detects available testbenches
- Compiles and runs all 3 arbitration modes
- Exits automatically after tests

---

## 🚀 Quick Start Guide

### **Option 1: Test Arbitration Only (Fastest)**

```bash
cd D:\AXI\sim\modelsim\scripts\sim

# Verilog version (more compatible)
vsim -do "do compile_and_sim_verilog_arb.tcl"

# OR SystemVerilog version (modern simulators)
vsim -do "do compile_and_sim_sv_arb.tcl"
```

**Expected output:**
```
========================================
ARBITRATION TEST: FIXED PRIORITY
========================================
...
>>> PASS: FIXED mode works (M0 always wins)
========================================

========================================
ARBITRATION TEST: ROUND_ROBIN
========================================
...
>>> PASS: ROUND_ROBIN mode works (fair 50/50)
========================================

========================================
ARBITRATION TEST: QOS
========================================
...
>>> PASS: QOS mode works (M0 QoS=10 > M1 QoS=2)
========================================
```

---

### **Option 2: Compile Full System**

```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -do "do compile_dual_riscv_system.tcl"
```

Then in ModelSim console:
```tcl
# View in waveform
vsim -gui work.dual_riscv_axi_system
add wave -r /*
run 1us
```

---

## 📊 Script Comparison

| Script | Target | Time | Output | GUI |
|--------|--------|------|--------|-----|
| `compile_and_sim_verilog_arb.tcl` | Arb only | ~10s | PASS/FAIL | No |
| `compile_and_sim_sv_arb.tcl` | Arb only | ~10s | PASS/FAIL | No |
| `compile_dual_riscv_system.tcl` | Full system | ~30s | Compiled | Optional |
| `run_quick_arb_test.tcl` | Arb only | ~8s | PASS/FAIL | No |

---

## 🔧 Troubleshooting

### **Issue 1: "vsim: command not found"**

**Solution:** Add ModelSim/QuestaSim to PATH:
```bash
# For PowerShell:
$env:PATH += ";C:\questasim64_10.2c\win64"
# OR
$env:PATH += ";C:\intelFPGA\20.1\modelsim_ase\win32aloem"

# Then verify:
vsim -version
```

---

### **Issue 2: "Error: (vlog-7) Failed to open design unit file"**

**Solution:** Check you're in correct directory:
```bash
cd D:\AXI\sim\modelsim\scripts\sim
pwd  # Should show: .../sim/modelsim/scripts/sim
```

---

### **Issue 3: Compilation succeeds but simulation hangs**

**Solution:** Add timeout to TCL script or kill with Ctrl+C

For manual control:
```bash
# Step 1: Compile only
vsim -c -do "do compile_and_sim_verilog_arb.tcl; quit"

# Step 2: Run simulation manually
vsim -c work.arb_test_verilog -g ARBIT_MODE=0
run 10us
```

---

### **Issue 4: "SystemVerilog features not supported"**

**Solution:** Use Verilog version instead:
```bash
vsim -do "do compile_and_sim_verilog_arb.tcl"
```

---

## 📝 Manual Workflow

If TCL scripts don't work, you can run manually:

### **Step 1: Start ModelSim**
```bash
cd D:\AXI\sim\modelsim\scripts\sim
vsim -c
```

### **Step 2: Compile in ModelSim console**
```tcl
# Clean and create library
vdel -lib work -all
vlib work
vmap work work

# Compile RTL
vlog ../../../../src/axi_interconnect/Verilog/rtl/arbitration/axi_rr_interconnect_2x4.v

# Compile testbench
vlog ../../../../tb/interconnect_tb/Verilog/arb_test_verilog.v
```

### **Step 3: Simulate**
```tcl
# Test FIXED mode
vsim -c -g ARBIT_MODE=0 work.arb_test_verilog
run -all
quit -sim

# Test ROUND_ROBIN mode
vsim -c -g ARBIT_MODE=1 work.arb_test_verilog
run -all
quit -sim

# Test QOS mode
vsim -c -g ARBIT_MODE=2 work.arb_test_verilog
run -all
quit -sim
```

---

## 🎯 Recommended Testing Order

1. **Quick arbitration test** (5 min)
   ```bash
   vsim -do "do run_quick_arb_test.tcl"
   ```

2. **Verilog arbitration with all modes** (10 min)
   ```bash
   vsim -do "do compile_and_sim_verilog_arb.tcl"
   ```

3. **Full system compilation** (15 min)
   ```bash
   vsim -do "do compile_dual_riscv_system.tcl"
   ```

4. **Manual exploration with GUI** (interactive)
   ```bash
   vsim -gui work.dual_riscv_axi_system
   ```

---

## 📈 Expected Results

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
M0 QoS=10, M1 QoS=2
M0 granted: 10 times
M1 granted: 0 times
>>> PASS: QOS mode works (M0 QoS=10 > M1 QoS=2)
```

---

## 💡 Tips

1. **Use Verilog testbench** for maximum compatibility
2. **Run in console mode** (`-c`) for faster execution
3. **Check transcript file** if output scrolls too fast
4. **Use GUI mode** (`-gui`) only for debugging with waveforms
5. **Compile once, simulate multiple times** - reuse work library

---

## 🔗 Related Documentation

- `../../../../tb/interconnect_tb/TESTBENCH_README.md` - Testbench details
- `../../../../src/axi_interconnect/SystemVerilog/rtl/arbitration/ARBITRATION_README.md` - Arbitration modes
- `../../../../ARBITRATION_UPGRADE_SUMMARY.md` - Feature overview

---

**Date:** 2025-01-02  
**Version:** 1.0  
**Status:** ✅ Ready to Use

