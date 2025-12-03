//=============================================================================
// AXI Interconnect Environment - UVM
// Top-level UVM environment cho AXI Interconnect verification
//=============================================================================

`ifndef AXI_INTERCONNECT_ENV_SV
`define AXI_INTERCONNECT_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "agents/axi_master_agent.sv"
`include "sequences/axi_base_sequence.sv"
`include "scoreboard/axi_scoreboard.sv"
`include "coverage/axi_coverage.sv"

//=============================================================================
// AXI Interconnect Environment
//=============================================================================
class axi_interconnect_env extends uvm_env;
    `uvm_component_utils(axi_interconnect_env)
    
    // Master Agents (2 masters)
    axi_master_agent master_agent[2];
    
    // Slave Agents (4 slaves) - có thể thêm sau
    // axi_slave_agent slave_agent[4];
    
    // Scoreboard
    axi_scoreboard scoreboard;
    
    // Coverage
    axi_coverage coverage;
    
    function new(string name = "axi_interconnect_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create master agents
        foreach (master_agent[i]) begin
            master_agent[i] = axi_master_agent::type_id::create(
                $sformatf("master_agent[%0d]", i), this);
            master_agent[i].set_is_active(UVM_ACTIVE);
        end
        
        // Create scoreboard
        scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
        
        // Create coverage
        coverage = axi_coverage::type_id::create("coverage", this);
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect master agents to scoreboard
        foreach (master_agent[i]) begin
            master_agent[i].ap.connect(scoreboard.master_export[i]);
        end
        
        // Connect to coverage
        foreach (master_agent[i]) begin
            master_agent[i].ap.connect(coverage.analysis_export);
        end
    endfunction
endclass

`endif // AXI_INTERCONNECT_ENV_SV

