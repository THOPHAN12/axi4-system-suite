//=============================================================================
// AXI Write Sequence - UVM
// Sequence cho AXI write transactions
//=============================================================================

`ifndef AXI_WRITE_SEQUENCE_SV
`define AXI_WRITE_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "axi_base_sequence.sv"

//=============================================================================
// AXI Write Sequence
//=============================================================================
class axi_write_sequence extends axi_base_sequence;
    `uvm_object_utils(axi_write_sequence)
    
    rand bit [31:0] start_addr;
    rand int unsigned num_writes;
    
    constraint c_num_writes { num_writes inside {[1:10]}; }
    
    function new(string name = "axi_write_sequence");
        super.new(name);
    endfunction
    
    task body();
        axi_transaction tr;
        
        repeat (num_writes) begin
            tr = axi_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize() with {
                is_write == 1;
                is_read == 0;
                addr == start_addr;
            });
            finish_item(tr);
            
            start_addr += 32'h100;  // Increment address
        end
    endtask
endclass

`endif // AXI_WRITE_SEQUENCE_SV

