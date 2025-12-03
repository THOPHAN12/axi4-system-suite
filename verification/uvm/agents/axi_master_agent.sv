//=============================================================================
// AXI Master Agent - UVM
// UVM Agent cho AXI Master interface
//=============================================================================

`ifndef AXI_MASTER_AGENT_SV
`define AXI_MASTER_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

//=============================================================================
// AXI Master Driver
//=============================================================================
class axi_master_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_master_driver)
    
    virtual axi_master_if vif;
    
    function new(string name = "axi_master_driver", uvm_component parent = null);
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
        // Implement AXI Master protocol driving
        // Write Address Channel
        if (tr.is_write) begin
            @(posedge vif.ACLK);
            vif.awid <= tr.id;
            vif.awaddr <= tr.addr;
            vif.awlen <= tr.len;
            vif.awsize <= tr.size;
            vif.awburst <= tr.burst;
            vif.awvalid <= 1'b1;
            wait(vif.awready);
            @(posedge vif.ACLK);
            vif.awvalid <= 1'b0;
            
            // Write Data Channel
            for (int i = 0; i <= tr.len; i++) begin
                @(posedge vif.ACLK);
                vif.wdata <= tr.data[i];
                vif.wstrb <= tr.strb[i];
                vif.wlast <= (i == tr.len);
                vif.wvalid <= 1'b1;
                wait(vif.wready);
                @(posedge vif.ACLK);
                vif.wvalid <= 1'b0;
            end
            
            // Write Response Channel
            @(posedge vif.ACLK);
            vif.bready <= 1'b1;
            wait(vif.bvalid);
            tr.resp = vif.bresp;
            @(posedge vif.ACLK);
            vif.bready <= 1'b0;
        end
        
        // Read Address Channel
        if (tr.is_read) begin
            @(posedge vif.ACLK);
            vif.arid <= tr.id;
            vif.araddr <= tr.addr;
            vif.arlen <= tr.len;
            vif.arsize <= tr.size;
            vif.arburst <= tr.burst;
            vif.arvalid <= 1'b1;
            wait(vif.arready);
            @(posedge vif.ACLK);
            vif.arvalid <= 1'b0;
            
            // Read Data Channel
            for (int i = 0; i <= tr.len; i++) begin
                @(posedge vif.ACLK);
                vif.rready <= 1'b1;
                wait(vif.rvalid);
                tr.data[i] = vif.rdata;
                tr.resp = vif.rresp;
                if (vif.rlast) break;
            end
            @(posedge vif.ACLK);
            vif.rready <= 1'b0;
        end
    endtask
endclass

//=============================================================================
// AXI Master Monitor
//=============================================================================
class axi_master_monitor extends uvm_monitor;
    `uvm_component_utils(axi_master_monitor)
    
    virtual axi_master_if vif;
    uvm_analysis_port #(axi_transaction) ap;
    
    function new(string name = "axi_master_monitor", uvm_component parent = null);
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
        // Monitor AXI transactions
        // Implementation similar to driver but for monitoring
    endtask
endclass

//=============================================================================
// AXI Master Sequencer
//=============================================================================
class axi_master_sequencer extends uvm_sequencer #(axi_transaction);
    `uvm_component_utils(axi_master_sequencer)
    
    function new(string name = "axi_master_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction
endclass

//=============================================================================
// AXI Master Agent
//=============================================================================
class axi_master_agent extends uvm_agent;
    `uvm_component_utils(axi_master_agent)
    
    axi_master_driver driver;
    axi_master_sequencer sequencer;
    axi_master_monitor monitor;
    
    uvm_analysis_port #(axi_transaction) ap;
    
    function new(string name = "axi_master_agent", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = axi_master_monitor::type_id::create("monitor", this);
        
        if (get_is_active() == UVM_ACTIVE) begin
            driver = axi_master_driver::type_id::create("driver", this);
            sequencer = axi_master_sequencer::type_id::create("sequencer", this);
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

`endif // AXI_MASTER_AGENT_SV

