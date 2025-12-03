//=============================================================================
// AXI Scoreboard - UVM
// Scoreboard để verify AXI transactions
//=============================================================================

`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "sequences/axi_base_sequence.sv"

//=============================================================================
// AXI Scoreboard
//=============================================================================
class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)
    
    uvm_analysis_export #(axi_transaction) master_export[2];
    uvm_tlm_analysis_fifo #(axi_transaction) master_fifo[2];
    
    int transaction_count;
    int error_count;
    
    function new(string name = "axi_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        foreach (master_export[i]) begin
            master_export[i] = new($sformatf("master_export[%0d]", i), this);
            master_fifo[i] = new($sformatf("master_fifo[%0d]", i), this);
        end
        transaction_count = 0;
        error_count = 0;
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach (master_export[i]) begin
            master_export[i].connect(master_fifo[i].analysis_export);
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        fork
            check_master(0);
            check_master(1);
        join
    endtask
    
    task check_master(int master_id);
        axi_transaction tr;
        forever begin
            master_fifo[master_id].get(tr);
            transaction_count++;
            `uvm_info("SCOREBOARD", 
                     $sformatf("Master[%0d]: %s", master_id, tr.convert2string()), 
                     UVM_MEDIUM)
            
            // Add verification logic here
            if (tr.resp != 2'b00) begin  // Check for errors
                `uvm_error("SCOREBOARD", 
                          $sformatf("Transaction error: resp=%0b", tr.resp))
                error_count++;
            end
        end
    endtask
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD", 
                 $sformatf("Total transactions: %0d, Errors: %0d", 
                          transaction_count, error_count), 
                 UVM_MEDIUM)
    endfunction
endclass

`endif // AXI_SCOREBOARD_SV

