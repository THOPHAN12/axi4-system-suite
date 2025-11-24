//=============================================================================
// AXI Slave Agent - UVM
// UVM Agent cho AXI Slave interface
//=============================================================================

`ifndef AXI_SLAVE_AGENT_SV
`define AXI_SLAVE_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "sequences/axi_base_sequence.sv"

//=============================================================================
// AXI Slave Driver
//=============================================================================
class axi_slave_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_slave_driver)
    
    virtual axi_slave_if vif;
    
    function new(string name = "axi_slave_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_transaction(axi_transaction tr);
        // Implement AXI Slave protocol driving
        // Similar to master but with reversed directions
    endtask
endclass

//=============================================================================
// AXI Slave Monitor
//=============================================================================
class axi_slave_monitor extends uvm_monitor;
    `uvm_component_utils(axi_slave_monitor)
    
    virtual axi_slave_if vif;
    uvm_analysis_port #(axi_transaction) ap;
    
    function new(string name = "axi_slave_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            axi_transaction tr;
            tr = axi_transaction::type_id::create("tr");
            monitor_transaction(tr);
            ap.write(tr);
        end
    endtask
    
    virtual task monitor_transaction(axi_transaction tr);
        // Monitor AXI transactions from slave perspective
    endtask
endclass

//=============================================================================
// AXI Slave Sequencer
//=============================================================================
class axi_slave_sequencer extends uvm_sequencer #(axi_transaction);
    `uvm_component_utils(axi_slave_sequencer)
    
    function new(string name = "axi_slave_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

//=============================================================================
// AXI Slave Agent
//=============================================================================
class axi_slave_agent extends uvm_agent;
    `uvm_component_utils(axi_slave_agent)
    
    axi_slave_driver driver;
    axi_slave_sequencer sequencer;
    axi_slave_monitor monitor;
    
    uvm_analysis_port #(axi_transaction) ap;
    
    function new(string name = "axi_slave_agent", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = axi_slave_monitor::type_id::create("monitor", this);
        
        if (get_is_active() == UVM_ACTIVE) begin
            driver = axi_slave_driver::type_id::create("driver", this);
            sequencer = axi_slave_sequencer::type_id::create("sequencer", this);
        end
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
        monitor.ap.connect(ap);
    endfunction
endclass

`endif // AXI_SLAVE_AGENT_SV

