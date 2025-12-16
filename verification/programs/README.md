# Test Programs for Dual RISC-V System

## Overview

This directory contains RISC-V test programs in hex format for testing the dual RISC-V system with 4 slaves (RAM, GPIO, UART, SPI).

## Test Programs

### 1. `simple_test.hex` (Core 0)

**Purpose**: Basic test program for Core 0
**Start Address**: 0x00000000
**Tests**:
- GPIO write (0xDEADBEEF)
- UART output ("Hello\n")
- SPI writes (0xAA, 0x55, 0x12, 0x34)

**Usage**: Default test program loaded into RAM

### 2. `simple_test_core1.hex` (Core 1)

**Purpose**: Test program for Core 1 to run concurrently with Core 0
**Start Address**: 0x00000100 (Core 1 reset PC)
**Tests**:
- RAM write/read (0xCAFEBABE at 0x00000100)
- GPIO write (0x12345678, then read value)
- UART output ("Core1\n")
- SPI writes (0xBB, 0xCC, 0xDD)

**Usage**: Load this program starting at address 0x00000100 in RAM

### 3. `comprehensive_test.hex` (Core 0)

**Purpose**: Comprehensive test with multiple transactions
**Start Address**: 0x00000000
**Tests**:
- Multiple RAM read/write operations
- Multiple GPIO writes (0x11111111, 0x22222222, 0x33333333, 0x44444444)
- Extended UART output ("Core0\n Test\n Done\n")
- Multiple SPI writes (0x1, 0x2, 0x3, 0x4, 0x5)

**Usage**: More thorough testing of all peripherals with many transactions

### 4. `dual_core_test.hex` (Combined)

**Purpose**: Combined test program with both Core 0 and Core 1 programs
**Start Addresses**: 
- Core 0: 0x00000000
- Core 1: 0x00000100
**Tests**: Same as `simple_test.hex` and `simple_test_core1.hex` combined

**Usage**: Recommended for dual core testing - loads both programs at once

**Purpose**: Comprehensive test with multiple transactions
**Start Address**: 0x00000000
**Tests**:
- Multiple RAM read/write operations
- Multiple GPIO writes (0x11111111, 0x22222222, 0x33333333, 0x44444444)
- Extended UART output ("Core0\n Test\n Done\n")
- Multiple SPI writes (0x1, 0x2, 0x3, 0x4, 0x5)

**Usage**: More thorough testing of all peripherals with many transactions

## Address Map

```
0x0000_0000 - 0x0000_1FFF  : RAM (8KB)
0x4000_0000                : GPIO
0x8000_0000                : UART
0xC000_0000                : SPI
```

## Instruction Format

All programs use RISC-V RV32I instruction set:
- **LUI**: Load upper immediate (U-type)
- **ADDI**: Add immediate (I-type)
- **SW**: Store word (S-type)
- **LW**: Load word (I-type)
- **JAL**: Jump and link (J-type)

## Loading Test Programs

### For ModelSim Simulation

The testbench automatically loads the hex file specified in the `RAM_INIT_HEX` parameter:

```tcl
# Default: simple_test.hex
do simulate_dual_riscv.tcl

# Use different test program
set env(TEST_PROGRAM) "comprehensive_test.hex"
do simulate_dual_riscv.tcl
```

### For Dual Core Testing

**Recommended**: Use `dual_core_test.hex` which contains both programs:
```tcl
set env(TEST_PROGRAM) "dual_core_test.hex"
do simulate_dual_riscv.tcl
```

**Alternative**: Load programs separately:
1. Load `simple_test.hex` starting at 0x00000000 (Core 0)
2. Load `simple_test_core1.hex` starting at 0x00000100 (Core 1)
3. Core 1 will automatically start at 0x00000100 (configured in `dual_riscv_axi_system.v`)

## Creating New Test Programs

1. Write RISC-V assembly or machine code
2. Convert to hex format (32-bit words, one per line)
3. Ensure addresses are 4-byte aligned
4. Add comments for documentation
5. Test with simulation

## Notes

- All addresses must be 4-byte aligned
- Programs end with infinite loop to prevent execution beyond program
- NOPs (0x00000013) used for padding
- Test programs are designed to create arbitration scenarios between cores

