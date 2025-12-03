# 🚀 FPGA Deployment

**Purpose**: FPGA programming, bitstreams, and board-specific configurations  
**Updated**: December 3, 2025  
**Status**: ✅ Organized and ready

---

## 📁 Directory Structure

```
fpga/
├── boards/          # Board-specific configurations
│   └── kv260/       # Xilinx Kria KV260 Vision AI Starter Kit
│       ├── scripts/
│       ├── constraints/
│       ├── bitstreams/
│       ├── reports/
│       └── logs/
└── common/          # Shared resources
    ├── ip/          # Common IP cores
    └── scripts/     # Reusable scripts
```

---

## 🎯 Supported Boards

### **Kria KV260** (Xilinx Zynq UltraScale+ MPSoC)
- **Location**: `boards/kv260/`
- **Tool**: Vivado
- **FPGA**: Zynq UltraScale+ MPSoC ZU5EV
- **Documentation**: See `boards/kv260/README.md`

**Features**:
- ✅ ARM Cortex-A53 + Cortex-R5F
- ✅ Programmable logic (PL)
- ✅ Vision AI accelerators
- ✅ Ethernet, USB, Display interfaces

---

## 🚀 Quick Start

### **For KV260**:
```bash
cd boards/kv260
# See README.md for specific instructions
```

### **Adding New Board**:
```bash
# Create board directory
mkdir boards/<board_name>
cd boards/<board_name>

# Copy template structure
cp -r ../kv260/* .
# Customize for your board
```

---

## 🔧 Common Resources

### **IP Cores** (`common/ip/`):
- Shared IP modules
- Reusable components
- Common interfaces

### **Scripts** (`common/scripts/`):
- Build automation
- Testing utilities
- Deployment tools

---

## 📊 Project Integration

### **With Synthesis**:
- Synthesis scripts: `synthesis/scripts/quartus/` or `synthesis/scripts/vivado/`
- RTL source: `src/`
- This folder: FPGA-specific deployment

### **With Simulation**:
- Simulation: `sim/modelsim/`
- Waveforms: `sim/waveforms/`
- This folder: Hardware deployment

---

## 📚 Documentation

### **Per-Board**:
- KV260: `boards/kv260/README.md`

### **General**:
- Synthesis: `synthesis/scripts/quartus/README.md`
- System docs: `docs/`

---

## 🎊 Status

**Organization**: ✅ Board-specific structure  
**Ready for**: Multi-board deployment  
**Current boards**: 1 (KV260)  
**Scalability**: Ready for more boards

---

## 💡 Usage Examples

### **Build for KV260**:
```bash
cd boards/kv260/scripts
vivado -mode batch -source build_kv260.tcl
```

### **Program KV260**:
```bash
cd boards/kv260/scripts
vivado -mode batch -source program_kv260.tcl
```

### **View Reports**:
```bash
cd boards/kv260/reports
# Check timing, utilization reports
```

---

**Last Updated**: December 3, 2025  
**Status**: ✅ Production ready

