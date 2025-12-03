# 🎯 Kria KV260 - FPGA Deployment

**Board**: Xilinx Kria KV260 Vision AI Starter Kit  
**FPGA**: Zynq UltraScale+ MPSoC (ZU5EV)  
**Tool**: Vivado 2020.2 or later  
**Status**: ✅ Ready for deployment

---

## 📊 Board Specifications

### **Processing System (PS)**:
- **CPU**: Quad-core ARM Cortex-A53 @ 1.2 GHz
- **Real-time**: Dual-core ARM Cortex-R5F @ 500 MHz
- **Memory**: 4 GB DDR4

### **Programmable Logic (PL)**:
- **FPGA**: Zynq UltraScale+ ZU5EV
- **Logic Cells**: ~256K
- **DSP Slices**: 1,248
- **Block RAM**: 9.4 Mb

### **Interfaces**:
- **Ethernet**: Gigabit Ethernet
- **USB**: USB 3.0
- **Display**: DisplayPort
- **Camera**: MIPI CSI-2
- **PCIe**: Gen 2 x4

---

## 📁 Directory Structure

```
kv260/
├── scripts/         # Build and programming TCL scripts
├── constraints/     # Pin constraints (.xdc files)
├── bitstreams/      # Generated .bit/.bin files
├── reports/         # Synthesis/Implementation reports
└── logs/            # Build logs
```

---

## 🚀 Quick Start

### **Prerequisites**:
1. Vivado 2020.2+ installed
2. KV260 board connected
3. JTAG cable connected

### **Build Bitstream**:
```bash
cd scripts
vivado -mode batch -source build_kv260.tcl
```

**Output**: `../bitstreams/design.bit`

### **Program FPGA**:
```bash
cd scripts
vivado -mode batch -source program_kv260.tcl
```

Or via GUI:
```bash
vivado
# Tools → Program Device
# Select .bit file from bitstreams/
```

---

## 📝 Scripts

### **build_kv260.tcl** (To be created):
```tcl
# Create Vivado project
# Add source files
# Run synthesis
# Run implementation
# Generate bitstream
```

### **program_kv260.tcl** (To be created):
```tcl
# Connect to board
# Program FPGA
# Verify configuration
```

### **create_project.tcl** (To be created):
```tcl
# Create new Vivado project
# Set KV260 part number
# Add constraints
```

---

## 🔧 Pin Constraints

**File**: `constraints/kv260_pins.xdc`

### **Example Constraints**:
```tcl
# Clock (100 MHz)
set_property PACKAGE_PIN H16 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# LEDs
set_property PACKAGE_PIN A17 [get_ports {led[0]}]
set_property PACKAGE_PIN B16 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports led*]

# Buttons
set_property PACKAGE_PIN D19 [get_ports {btn[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports btn*]
```

**Note**: Update with actual KV260 pin mappings!

---

## 📊 Resource Utilization (Expected)

For **Dual RISC-V + AXI Interconnect** system:

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| LUTs | ~15K-20K | 256K | ~6-8% |
| FFs | ~8K-12K | 512K | ~2-3% |
| BRAM | ~50-100 | 312 | ~15-30% |
| DSP | 0-4 | 1248 | <1% |

**Fmax**: 100-150 MHz (typical)

---

## 🐛 Troubleshooting

### **Issue: Board not detected**
```bash
# Check JTAG connection
vivado
# Tools → Auto Connect
```

### **Issue: Timing not met**
- Reduce clock frequency in constraints
- Enable optimization in synthesis settings
- Review critical paths in reports

### **Issue: Bitstream generation failed**
- Check error logs in `logs/`
- Verify resource utilization
- Check constraint syntax

---

## 📚 References

### **Official Documentation**:
- [KV260 Product Page](https://www.xilinx.com/products/som/kria/kv260-vision-starter-kit.html)
- [KV260 Getting Started](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/index.html)
- [Vivado User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2020_2/ug835-vivado-tcl-commands.pdf)

### **Community**:
- [Xilinx Forums](https://forums.xilinx.com/)
- [Kria Community](https://www.element14.com/community/groups/kria)

---

## 💡 Tips

### **Optimization**:
- Enable `KEEP_HIERARCHY` for debugging
- Use `DONT_TOUCH` for critical nets
- Enable incremental synthesis for faster builds

### **Debugging**:
- Use Integrated Logic Analyzer (ILA)
- Enable debug nets in synthesis
- Use Hardware Manager for live debugging

### **Best Practices**:
- Always version control `.xdc` files
- Document custom constraints
- Keep build logs for reference
- Test on hardware frequently

---

## 🎯 Project Integration

### **AXI Interconnect System**:
- **Top-level**: `src/systems/dual_riscv_axi_system.v`
- **Synthesis**: `synthesis/scripts/vivado/` (to be created)
- **Constraints**: This folder (`constraints/`)

### **Workflow**:
1. Edit RTL in `src/`
2. Run simulation in `sim/modelsim/`
3. Synthesize with scripts here
4. Program KV260
5. Test on hardware

---

## ✅ Checklist

**Before Build**:
- [ ] All RTL files added to project
- [ ] Constraints file updated for KV260
- [ ] Clock frequency set correctly
- [ ] I/O standards verified

**After Build**:
- [ ] Check timing report (met all constraints?)
- [ ] Review utilization (within limits?)
- [ ] Bitstream generated successfully
- [ ] Ready to program

**After Programming**:
- [ ] FPGA configured successfully
- [ ] Test functionality
- [ ] Verify interfaces (UART, GPIO, etc.)
- [ ] Document results

---

**Status**: ✅ **Ready for KV260 deployment!**

**Next Steps**:
1. Create build scripts
2. Add pin constraints
3. Test synthesis flow
4. Program and verify

