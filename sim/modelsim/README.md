# ModelSim Simulation - Simple & Clean

## 🚀 Quick Start

### **Option 1: Quick Test (Recommended)**
```bash
cd D:\AXI\sim\modelsim
vsim -c -do "do test_arb.tcl"
```
**Result:** Test 3 arbitration modes in 30 seconds ✅

### **Option 2: Compile All Verilog**
```bash
vsim -c -do "do compile_verilog.tcl"
```

### **Option 3: Use ModelSim Project**
```bash
# 1. Open ModelSim GUI
# 2. File → New → Project → Create "AXI_PROJECT"
# 3. do add_verilog_files.tcl
# 4. Right-click → Compile → Compile All
```

---

## 📁 Directory Structure

```
modelsim/
├── test_arb.tcl                    ⭐ Quick test (30s)
├── compile_verilog.tcl             ⭐ Compile Verilog only
├── add_verilog_files.tcl           ⭐ Add .v files to project
├── add_systemverilog_files.tcl     ⭐ Add .sv files to project
├── compile_all.tcl                 (compile both .v + .sv)
├── add_all_files.tcl               (add both .v + .sv)
├── README.md                       (this file)
├── modelsim.ini                    (config)
└── work/                           (compiled library)
```

---

## 📝 Scripts Overview

### **For Verilog ONLY (Recommended):**
| Script | Purpose | Time |
|--------|---------|------|
| `test_arb.tcl` | ⭐ Test arbitration (3 modes) | 30s |
| `compile_verilog.tcl` | Compile all .v files | 60s |
| `add_verilog_files.tcl` | Add .v files to project | Instant |

### **For SystemVerilog:**
| Script | Purpose | Note |
|--------|---------|------|
| `add_systemverilog_files.tcl` | Add .sv files to project | Requires modern simulator |
| `compile_all.tcl` | Compile both .v + .sv | Requires SV support |

---

## 🎯 Top Modules

| Module | File | Purpose | Lang |
|--------|------|---------|------|
| `arb_test_verilog` | `arb_test_verilog.v` | Test arbitration | .v ⭐ |
| `arb_test_systemverilog` | `arb_test_systemverilog.sv` | Test arbitration | .sv |
| `dual_riscv_axi_system_tb` | `dual_riscv_axi_system_tb.sv` | Test full system | .sv |

---

## 🧪 Testing Workflow

### **Quick Arbitration Test (30 seconds):**
```bash
cd D:\AXI\sim\modelsim
vsim -c -do "do test_arb.tcl"
```

**Top Module:** `arb_test_verilog`  
**Tests:** FIXED + ROUND_ROBIN + QOS

### **Manual Test:**
```bash
# Compile
vsim -c -do "do compile_verilog.tcl; quit"

# Simulate ROUND_ROBIN mode
vsim -c -g ARBIT_MODE=1 work.arb_test_verilog
run -all
```

### **With GUI (Waveforms):**
```bash
vsim -gui work.arb_test_verilog -g ARBIT_MODE=1
add wave -r /*
run -all
```

---

## 📊 File Count (Verilog Only)

| Category | Files |
|----------|-------|
| SERV Core | 16 |
| Interconnect | 34 |
| Peripherals | 4 |
| AXI Bridge | 4 |
| Systems | 4 |
| Testbenches | 26 |
| **Total** | **88 Verilog files** |

---

## 💡 Tips

1. **Use Verilog scripts** for maximum compatibility
2. **test_arb.tcl** is fastest way to verify
3. **compile_verilog.tcl** compiles everything needed
4. **SystemVerilog requires** modern simulator (2016+)

---

## 🎯 Recommended Workflow

```bash
# Step 1: Navigate
cd D:\AXI\sim\modelsim

# Step 2: Quick test
vsim -c -do "do test_arb.tcl"

# Step 3: View results (should see PASS/FAIL)

# Step 4: (Optional) View waveforms
vsim -gui work.arb_test_verilog -g ARBIT_MODE=1
```

---

**Date:** 2025-01-02  
**Version:** 4.0 (Verilog/SystemVerilog Separated)  
**Status:** ✅ Clean, Simple, Working!
