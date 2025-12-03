//=============================================================================
// AXI Interconnect Simple Test - UVM
// Simple test case cho AXI Interconnect
//=============================================================================

`ifndef AXI_INTERCONNECT_SIMPLE_TEST_SV
`define AXI_INTERCONNECT_SIMPLE_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "axi_interconnect_base_test.sv"
`include "sequences/axi_read_sequence.sv"
`include "sequences/axi_write_sequence.sv"

//=============================================================================
// AXI Interconnect Simple Test
//=============================================================================
class axi_interconnect_simple_test extends axi_interconnect_base_test;
    `uvm_component_utils(axi_interconnect_simple_test)
    
    function new(string name = "axi_interconnect_simple_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        axi_write_sequence write_seq;
        axi_read_sequence read_seq;
        
        phase.raise_objection(this);
        
        `uvm_info("TEST", "Starting simple test", UVM_MEDIUM)
        
        // Master 0: Write sequence
        write_seq = axi_write_sequence::type_id::create("write_seq");
        write_seq.start_addr = 32'h0000_0000;
        write_seq.num_writes = 5;
        write_seq.start(env.master_agent[0].sequencer);
        
        // Master 1: Read sequence
        read_seq = axi_read_sequence::type_id::create("read_seq");
        read_seq.start_addr = 32'h4000_0000;
        read_seq.num_reads = 5;
        read_seq.start(env.master_agent[1].sequencer);
        
        #1000;  // Wait for transactions to complete
        
        phase.drop_objection(this);
    endtask
endclass

`endif // AXI_INTERCONNECT_SIMPLE_TEST_SV

