//=============================================================================
// AXI Coverage - UVM
// Coverage models cho AXI Interconnect
//=============================================================================

`ifndef AXI_COVERAGE_SV
`define AXI_COVERAGE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "sequences/axi_base_sequence.sv"

//=============================================================================
// AXI Coverage
//=============================================================================
class axi_coverage extends uvm_subscriber #(axi_transaction);
    `uvm_component_utils(axi_coverage)
    
    // Coverage groups
    covergroup axi_cg;
        // Address coverage
        addr_cp: coverpoint item.addr {
            bins low_addr = {[32'h0000_0000:32'h3FFF_FFFF]};
            bins mid_addr = {[32'h4000_0000:32'h7FFF_FFFF]};
            bins high_addr = {[32'h8000_0000:32'hFFFF_FFFF]};
        }
        
        // Burst length coverage
        len_cp: coverpoint item.len {
            bins short_burst = {[0:3]};
            bins medium_burst = {[4:7]};
            bins long_burst = {[8:15]};
        }
        
        // Burst type coverage
        burst_cp: coverpoint item.burst {
            bins fixed = {0};
            bins incr = {1};
            bins wrap = {2};
        }
        
        // Transaction type coverage
        rw_cp: coverpoint item.is_write {
            bins read = {0};
            bins write = {1};
        }
        
        // Cross coverage
        addr_burst_cross: cross addr_cp, burst_cp;
        len_burst_cross: cross len_cp, burst_cp;
    endgroup
    
    function new(string name = "axi_coverage", uvm_component parent = null);
        super.new(name, parent);
        axi_cg = new();
    endfunction
    
    function void write(axi_transaction t);
        item = t;
        axi_cg.sample();
    endfunction
    
    axi_transaction item;
endclass

`endif // AXI_COVERAGE_SV

