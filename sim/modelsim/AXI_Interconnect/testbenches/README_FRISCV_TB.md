# FRISCV Testbench Guide

## Available Testbenches

### 1. `tb_friscv_auto_verify.sv` (Auto-generated)
- **Purpose**: Basic auto-verification testbench
- **Features**: 
  - Clock and reset sequencing
  - SW/LW instruction execution
  - AXI protocol compliance
  - Basic pass/fail reporting
- **Usage**: Quick smoke test

### 2. `tb_friscv_comprehensive.sv` ⭐ **RECOMMENDED**
- **Purpose**: Comprehensive testbench with full coverage
- **Features**:
  - Multiple test programs support
  - Instruction fetch monitoring
  - Data memory operations (SW/LW)
  - Peripheral access testing (GPIO, UART, SPI)
  - Cache behavior verification
  - Interrupt handling
  - AXI protocol compliance checks
  - Performance metrics
  - Detailed pass/fail reporting
- **Usage**: Full system verification

## Compilation

### Option 1: Using Script (Recommended)
```tcl
# In ModelSim console
cd D:/AXI/sim/modelsim/AXI_Interconnect
project open project/AXI_Project.mpf
source scripts/compile_friscv.tcl
```

### Option 2: Manual Compilation
```tcl
# Set paths
set FRISCV_DIR "D:/AXI/src/cores/friscv/friscv/rtl"
set INCDIR "+incdir+${FRISCV_DIR}"

# Compile FRISCV headers first
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_debug_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_memfy_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_control_h.sv
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_checkers.sv

# Compile FRISCV core
vlog -work work $INCDIR ${FRISCV_DIR}/friscv_rv32i_core.sv

# Compile AXI width adapter
vlog -work work ../../src/axi_bridge/rtl/axi_width_adapter_128to32.sv

# Compile FRISCV system
vlog -work work ../../src/systems/friscv_axi_system.sv

# Compile testbench
vlog -work work $INCDIR testbenches/tb_friscv_comprehensive.sv
```

## Simulation

### Run Comprehensive Testbench
```tcl
# Start simulation
vsim -voptargs=+acc work.tb_friscv_comprehensive

# Run simulation
run -all

# Or run for specific time
run 200us
```

### Run with Different Test Programs
```tcl
# Use arithmetic test
vsim -voptargs=+acc +test_arith work.tb_friscv_comprehensive
run -all

# Use memory test
vsim -voptargs=+acc +test_mem work.tb_friscv_comprehensive
run -all
```

## Test Programs

Place test programs in `testdata/` directory:
- `test_basic_sw_lw.hex` - Basic store/load operations
- `test_arithmetic.hex` - Arithmetic operations
- `test_memory.hex` - Memory access patterns

## Expected Output

The comprehensive testbench will report:
- ✅ System initialization
- ✅ Instruction fetch working
- ✅ Store operations (SW)
- ✅ Load operations (LW)
- ✅ RAM access
- ✅ AXI protocol compliance
- ✅ GPIO access (if used)
- ✅ Performance metrics

## Waveform Analysis

Waveforms are saved to:
- `waveforms/tb_friscv_comprehensive.vcd`

Key signals to monitor:
- `clk`, `rst_n` - Clock and reset
- `dut.m0_axi_*` - Instruction fetch AXI signals
- `dut.m1_axi_*` - Data memory AXI signals
- `debug_status`, `debug_regs` - CPU debug signals
- `gpio_in`, `gpio_out` - GPIO signals
- `uart_*`, `spi_*` - Peripheral signals

## Troubleshooting

### "Undefined variable: 'XLEN'"
- Ensure `friscv_h.sv` is compiled before `friscv_memfy_h.sv`
- Use `+incdir` option when compiling
- See `FRISCV_COMPILE_FIX.md` for details

### "No instruction fetches"
- Check if test program is loaded correctly
- Verify RAM initialization: `examine dut.u_ram.mem`
- Check reset sequence

### "No store/load operations"
- Verify test program contains SW/LW instructions
- Check address decoding in interconnect
- Monitor AXI write/read channels

### "AXI protocol violations"
- Check valid/ready handshaking
- Verify address alignment
- Check burst length and size

## Performance Metrics

The testbench reports:
- Instructions per microsecond
- Data operations per microsecond
- Total clock cycles
- Transaction counts per peripheral

## Next Steps

1. Run comprehensive testbench
2. Analyze waveforms
3. Verify all tests pass
4. Create custom test programs for specific scenarios
5. Add coverage analysis if needed

