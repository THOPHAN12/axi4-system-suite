# Software - Embedded Software for RISC-V Cores

**Purpose**: Embedded software, drivers, and applications for RISC-V cores  
**Status**: 🚧 Structure prepared, ready for development

---

## 📁 Directory Structure

```
software/
├── applications/    # User applications for RISC-V
├── drivers/         # Device drivers
│   ├── baremetal/  # Bare-metal drivers
│   └── linux/      # Linux kernel drivers
└── scripts/         # Build and deployment scripts
```

---

## 🎯 Purpose

This folder contains software that runs **on the RISC-V cores** in the AXI Interconnect system:

- **Applications**: User programs (bare-metal or OS-based)
- **Drivers**: Hardware drivers for peripherals (GPIO, UART, SPI, etc.)
- **Scripts**: Build automation and deployment tools

---

## 🚀 Development Workflow

### **1. Bare-Metal Application**:
```c
// applications/hello_world.c
#include "uart_driver.h"

int main() {
    uart_init();
    uart_print("Hello from RISC-V!\n");
    return 0;
}
```

### **2. Compile**:
```bash
riscv32-unknown-elf-gcc -o hello.elf hello_world.c
riscv32-unknown-elf-objcopy -O verilog hello.elf hello.hex
```

### **3. Load to Simulation**:
```bash
# Copy to sim/modelsim/testdata/
cp hello.hex ../sim/modelsim/testdata/
```

---

## 🔧 Drivers

### **Bare-Metal Drivers** (`drivers/baremetal/`):
- Direct hardware register access
- No OS dependencies
- Lightweight, fast

### **Linux Drivers** (`drivers/linux/`):
- For embedded Linux on RISC-V
- Kernel modules
- Character/block device drivers

---

## 📚 Integration with Hardware

### **Memory Map**:
```
0x0000_0000 - 0x1FFF_FFFF : RAM (program & data)
0x4000_0000 - 0x5FFF_FFFF : GPIO
0x8000_0000 - 0x9FFF_FFFF : UART
0xC000_0000 - 0xDFFF_FFFF : SPI
```

### **Peripheral Drivers**:
- **GPIO**: `drivers/baremetal/gpio/`
- **UART**: `drivers/baremetal/uart/`
- **SPI**: `drivers/baremetal/spi/`

---

## 🎯 Status

**Current**: Folder structure prepared  
**Next Steps**:
1. Create bare-metal drivers for peripherals
2. Develop test applications
3. Add build scripts
4. Test on simulation
5. Deploy to FPGA

---

## 📖 Related Documentation

- Hardware: `src/systems/dual_riscv_axi_system.v`
- Peripherals: `src/peripherals/axi_lite/`
- Simulation: `sim/modelsim/`
- Deployment: `deployment/boards/kv260/`

---

**Status**: ✅ Ready for software development

