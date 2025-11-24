//=============================================================================
// AXI Interconnect Configuration - UVM
// Configuration object cho AXI Interconnect verification
//=============================================================================

`ifndef AXI_INTERCONNECT_CONFIG_SV
`define AXI_INTERCONNECT_CONFIG_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

//=============================================================================
// AXI Interconnect Configuration
//=============================================================================
class axi_interconnect_config extends uvm_object;
    `uvm_object_utils(axi_interconnect_config)
    
    // Address ranges for slaves
    bit [31:0] slave0_addr1 = 32'h0000_0000;
    bit [31:0] slave0_addr2 = 32'h3FFF_FFFF;
    bit [31:0] slave1_addr1 = 32'h4000_0000;
    bit [31:0] slave1_addr2 = 32'h7FFF_FFFF;
    bit [31:0] slave2_addr1 = 32'h8000_0000;
    bit [31:0] slave2_addr2 = 32'hBFFF_FFFF;
    bit [31:0] slave3_addr1 = 32'hC000_0000;
    bit [31:0] slave3_addr2 = 32'hFFFF_FFFF;
    
    // Number of masters and slaves
    int num_masters = 2;
    int num_slaves = 4;
    
    // Test configuration
    bit enable_coverage = 1;
    bit enable_scoreboard = 1;
    int num_transactions = 100;
    
    function new(string name = "axi_interconnect_config");
        super.new(name);
    endfunction
    
    function string convert2string();
        string s;
        s = $sformatf("AXI Config: %0d masters, %0d slaves", num_masters, num_slaves);
        return s;
    endfunction
endclass

`endif // AXI_INTERCONNECT_CONFIG_SV

