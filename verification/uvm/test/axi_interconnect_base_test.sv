//=============================================================================
// AXI Interconnect Base Test - UVM
// Base test class cho AXI Interconnect verification
//=============================================================================

`ifndef AXI_INTERCONNECT_BASE_TEST_SV
`define AXI_INTERCONNECT_BASE_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "env/axi_interconnect_env.sv"

//=============================================================================
// AXI Interconnect Base Test
//=============================================================================
class axi_interconnect_base_test extends uvm_test;
    `uvm_component_utils(axi_interconnect_base_test)
    
    axi_interconnect_env env;
    
    function new(string name = "axi_interconnect_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_interconnect_env::type_id::create("env", this);
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST", "Starting test", UVM_MEDIUM)
        
        // Run test sequences here
        
        phase.drop_objection(this);
    endtask
endclass

`endif // AXI_INTERCONNECT_BASE_TEST_SV

