# Danh sach file TCL trong project

## File CAN THIET (KHONG XOA)

### ModelSim:
1. **compile_and_sim.tcl** - Script chinh de compile va simulate toan bo system
   - Compile tat ca source files (SERV, AXI Interconnect, Wrapper, Memory slaves)
   - Compile testbench
   - Run simulation
   - **Usage**: `vsim -c -do "source compile_and_sim.tcl; quit -f"`

2. **run_simulation.tcl** - Script de run simulation sau khi da compile
   - Load top-level module
   - Add waves
   - Run simulation
   - **Usage**: `vsim -c -do "source run_simulation.tcl; quit -f"`

### Quartus:
3. **add_all_source_files.tcl** - Script de add tat ca source files vao Quartus project
   - Add SERV core files
   - Add AXI Interconnect files
   - Add Wrapper files
   - Add Memory slave files
   - Set top-level entity
   - **Usage**: Trong Quartus TCL console: `source add_all_source_files.tcl`

## File CO THE XOA (Test scripts rieng le)

### ModelSim test scripts:
1. **test_address_mapping.tcl** - Test rieng cho address mapping
   - Test wb2axi_read address capture logic
   - **Co the xoa**: Logic da duoc test va fix trong main simulation

2. **test_serv_axi_wrapper.tcl** - Test rieng cho serv_axi_wrapper
   - Test wrapper module isolation
   - **Co the xoa**: Logic da duoc test trong main simulation

3. **test_wb2axi_read.tcl** - Test rieng cho wb2axi_read module
   - Test wb2axi_read FSM va address capture
   - **Co the xoa**: Logic da duoc test va fix trong main simulation

4. **project.tcl** - ModelSim project file
   - Tao ModelSim project
   - **Co the xoa**: Khong can thiet, da co compile_and_sim.tcl

### Interconnect test script:
5. **tb/interconnect_tb/run_all_tests.tcl** - Test script cho interconnect components
   - Chay nhieu testbenches cho interconnect
   - **DA XOA**: Khong can thiet, da test trong main simulation

## File CO THE XOA (Do files - khong can thiet)

1. **compile.do** - Do file de compile (duplicate voi compile_and_sim.tcl)
2. **run.do** - Do file de run (duplicate voi run_simulation.tcl)
3. **wave.do** - Do file de add waves (duplicate voi run_simulation.tcl)

## File KHONG XOA (SERV core data files)

Cac file trong `src/cores/serv/data/*.tcl`:
- `sockit.tcl`, `params.tcl`, `nexys_2.tcl`, `max10_10m08evk.tcl`, `deca.tcl`, etc.
- **KHONG XOA**: Day la cac file config cho cac board khac nhau, can thiet cho SERV core

## Tom tat

### Xoa ngay:
- `sim/modelsim/test_address_mapping.tcl`
- `sim/modelsim/test_serv_axi_wrapper.tcl`
- `sim/modelsim/test_wb2axi_read.tcl`
- `sim/modelsim/project.tcl`
- `sim/modelsim/compile.do`
- `sim/modelsim/run.do`
- `sim/modelsim/wave.do`

### Da xoa:
- `tb/interconnect_tb/run_all_tests.tcl` - Test script cho interconnect (khong can thiet)

### Giu lai (3 files chinh):
- `sim/modelsim/compile_and_sim.tcl` - **CAN THIET** (Script chinh de compile va simulate)
- `sim/modelsim/run_simulation.tcl` - **CAN THIET** (Script de run simulation)
- `sim/quartus/add_all_source_files.tcl` - **CAN THIET** (Script de add files vao Quartus)

### Giu lai (SERV core configs):
- `src/cores/serv/data/*.tcl` - **CAN THIET** (SERV core configs cho cac board khac nhau)

