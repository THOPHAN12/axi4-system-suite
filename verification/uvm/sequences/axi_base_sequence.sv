//=============================================================================
// AXI Base Sequence - UVM
// Base sequence class cho AXI transactions
//=============================================================================

`ifndef AXI_BASE_SEQUENCE_SV
`define AXI_BASE_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

//=============================================================================
// AXI Transaction
//=============================================================================
class axi_transaction extends uvm_sequence_item;
    `uvm_object_utils(axi_transaction)
    
    // Transaction fields
    rand bit [axi_pkg::ID_WIDTH-1:0] id;
    rand bit [axi_pkg::ADDR_WIDTH-1:0] addr;
    rand bit [7:0] len;
    rand bit [2:0] size;
    rand bit [1:0] burst;
    rand bit [1:0] lock;
    rand bit [3:0] cache;
    rand bit [2:0] prot;
    rand bit [3:0] qos;
    rand bit [3:0] region;
    
    rand bit is_write;
    rand bit is_read;
    
    bit [axi_pkg::DATA_WIDTH-1:0] data[];
    bit [(axi_pkg::DATA_WIDTH/8)-1:0] strb[];
    bit [1:0] resp;
    bit rlast;
    
    // Constraints
    constraint c_len { len inside {[0:15]}; }  // Limit burst length for testing
    constraint c_size { size inside {[0:2]}; }  // 1, 2, 4 bytes
    constraint c_burst { burst inside {[0:2]}; }  // FIXED, INCR, WRAP
    constraint c_rw { is_write != is_read; }  // Must be either read or write
    
    function new(string name = "axi_transaction");
        super.new(name);
    endfunction
    
    function void post_randomize();
        int num_beats = len + 1;
        data = new[num_beats];
        strb = new[num_beats];
        
        foreach (data[i]) begin
            data[i] = $urandom();
            strb[i] = '1;  // All bytes valid
        end
    endfunction
    
    function string convert2string();
        string s;
        s = $sformatf("AXI Transaction: %s, ID=%0d, Addr=0x%08x, Len=%0d", 
                     is_write ? "WRITE" : "READ", id, addr, len);
        return s;
    endfunction
endclass

//=============================================================================
// AXI Base Sequence
//=============================================================================
class axi_base_sequence extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_base_sequence)
    
    function new(string name = "axi_base_sequence");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info("AXI_BASE_SEQ", "Starting base sequence", UVM_MEDIUM)
    endtask
endclass

`endif // AXI_BASE_SEQUENCE_SV

