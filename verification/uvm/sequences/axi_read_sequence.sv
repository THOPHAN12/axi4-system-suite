//=============================================================================
// AXI Read Sequence - UVM
// Sequence cho AXI read transactions
//=============================================================================

`ifndef AXI_READ_SEQUENCE_SV
`define AXI_READ_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "axi_base_sequence.sv"

//=============================================================================
// AXI Read Sequence
//=============================================================================
class axi_read_sequence extends axi_base_sequence;
    `uvm_object_utils(axi_read_sequence)
    
    rand bit [31:0] start_addr;
    rand int unsigned num_reads;
    
    constraint c_num_reads { num_reads inside {[1:10]}; }
    
    function new(string name = "axi_read_sequence");
        super.new(name);
    endfunction
    
    task body();
        axi_transaction tr;
        
        repeat (num_reads) begin
            tr = axi_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize() with {
                is_read == 1;
                is_write == 0;
                addr == start_addr;
            });
            finish_item(tr);
            
            start_addr += 32'h100;  // Increment address
        end
    endtask
endclass

`endif // AXI_READ_SEQUENCE_SV

