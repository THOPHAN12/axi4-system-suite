# UVM Verification Environment for AXI Interconnect

## Cấu Trúc Thư Mục

```
verification/uvm/
├── agents/          # UVM Agents (Master và Slave)
│   ├── axi_master_agent.sv
│   └── axi_slave_agent.sv
├── sequences/       # Base Sequences
│   ├── axi_base_sequence.sv
│   ├── axi_read_sequence.sv
│   └── axi_write_sequence.sv
├── seq/            # Test Sequences
│   └── (test-specific sequences)
├── env/            # UVM Environment
│   ├── axi_interconnect_env.sv
│   └── axi_interconnect_config.sv
├── test/           # Test Cases
│   ├── axi_interconnect_base_test.sv
│   └── axi_interconnect_simple_test.sv
├── config/         # Configuration Objects
│   └── axi_interconnect_config.sv
├── scoreboard/     # Scoreboard và Checkers
│   └── axi_scoreboard.sv
├── coverage/       # Coverage Models
│   └── axi_coverage.sv
└── tb/             # Testbench Top
    └── axi_interconnect_tb.sv
```

## Mô Tả

### Agents (`agents/`)
- **axi_master_agent.sv**: UVM Agent cho AXI Master interface
- **axi_slave_agent.sv**: UVM Agent cho AXI Slave interface

### Sequences (`sequences/`)
- **axi_base_sequence.sv**: Base sequence cho AXI transactions
- **axi_read_sequence.sv**: Sequences cho read transactions
- **axi_write_sequence.sv**: Sequences cho write transactions

### Environment (`env/`)
- **axi_interconnect_env.sv**: Top-level UVM environment
- Chứa agents, scoreboard, coverage, và các components khác

### Test Cases (`test/`)
- **axi_interconnect_base_test.sv**: Base test class
- **axi_interconnect_simple_test.sv**: Simple test case

### Configuration (`config/`)
- **axi_interconnect_config.sv**: Configuration object cho address ranges, parameters

### Scoreboard (`scoreboard/`)
- **axi_scoreboard.sv**: Scoreboard để verify transactions

### Coverage (`coverage/`)
- **axi_coverage.sv**: Coverage models cho functional coverage

### Testbench (`tb/`)
- **axi_interconnect_tb.sv**: Top-level testbench với DUT instantiation

## Cách Sử Dụng

1. **Compile**: Sử dụng UVM-compatible simulator (ModelSim, VCS, Questa)
2. **Run Test**: `run_test("axi_interconnect_simple_test")`
3. **View Coverage**: Sử dụng coverage tools của simulator

## Dependencies

- UVM 1.2 hoặc cao hơn
- SystemVerilog 2012
- AXI Interconnect SystemVerilog modules từ `src/axi_interconnect/sv/`

