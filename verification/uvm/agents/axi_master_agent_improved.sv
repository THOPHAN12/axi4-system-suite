//=============================================================================
// AXI Master Agent - UVM (Improved)
// UVM agent cho AXI master interface
//=============================================================================

`ifndef AXI_MASTER_AGENT_IMPROVED_SV
`define AXI_MASTER_AGENT_IMPROVED_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "../sequences/axi_base_sequence.sv"

//=============================================================================
// AXI Master Driver
//=============================================================================
class axi_master_driver_uvm extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_master_driver_uvm)
    
    virtual axi_master_if vif;
    
    function new(string name = "axi_master_driver_uvm", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_master_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for axi_master_driver_uvm")
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_transaction(axi_transaction tr);
        `uvm_info("DRV", $sformatf("Driving transaction: %s", tr.convert2string()), UVM_MEDIUM)
        
        if (tr.is_write) begin
            drive_write(tr);
        end else if (tr.is_read) begin
            drive_read(tr);
        end
    endtask
    
    virtual task drive_write(axi_transaction tr);
        // Write Address Channel
        @(posedge vif.ACLK);
        vif.awaddr = tr.addr;
        vif.awlen = tr.len;
        vif.awsize = tr.size;
        vif.awburst = tr.burst;
        vif.awvalid = 1'b1;
        
        wait(vif.awready);
        @(posedge vif.ACLK);
        vif.awvalid = 1'b0;
        
        // Write Data Channel
        for (int i = 0; i < tr.data.size(); i++) begin
            @(posedge vif.ACLK);
            vif.wdata = tr.data[i];
            vif.wstrb = tr.strb[i];
            vif.wlast = (i == tr.data.size() - 1);
            vif.wvalid = 1'b1;
            
            wait(vif.wready);
            @(posedge vif.ACLK);
            vif.wvalid = 1'b0;
        end
        
        // Write Response Channel
        vif.bready = 1'b1;
        wait(vif.bvalid);
        tr.resp = vif.bresp;
        @(posedge vif.ACLK);
        vif.bready = 1'b0;
    endtask
    
    virtual task drive_read(axi_transaction tr);
        // Read Address Channel
        @(posedge vif.ACLK);
        vif.araddr = tr.addr;
        vif.arlen = tr.len;
        vif.arsize = tr.size;
        vif.arburst = tr.burst;
        vif.arvalid = 1'b1;
        
        wait(vif.arready);
        @(posedge vif.ACLK);
        vif.arvalid = 1'b0;
        
        // Read Data Channel
        vif.rready = 1'b1;
        tr.data = new[tr.len + 1];
        for (int i = 0; i <= tr.len; i++) begin
            wait(vif.rvalid);
            tr.data[i] = vif.rdata;
            tr.resp = vif.rresp;
            tr.rlast = vif.rlast;
            @(posedge vif.ACLK);
            if (vif.rlast) break;
        end
        vif.rready = 1'b0;
    endtask
endclass

//=============================================================================
// AXI Master Sequencer
//=============================================================================
typedef uvm_sequencer #(axi_transaction) axi_master_sequencer;

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
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_master_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NO_VIF", "Virtual interface not set for axi_master_monitor")
        end
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.ACLK);
            if (vif.ARESETN) begin
                monitor_transactions();
            end
        end
    endtask
    
    virtual task monitor_transactions();
        // Monitor write transactions
        if (vif.awvalid && vif.awready) begin
            axi_transaction tr = axi_transaction::type_id::create("tr");
            tr.is_write = 1;
            tr.addr = vif.awaddr;
            tr.len = vif.awlen;
            // ... capture other fields
            ap.write(tr);
        end
        
        // Monitor read transactions
        if (vif.arvalid && vif.arready) begin
            axi_transaction tr = axi_transaction::type_id::create("tr");
            tr.is_read = 1;
            tr.addr = vif.araddr;
            tr.len = vif.arlen;
            // ... capture other fields
            ap.write(tr);
        end
    endtask
endclass

//=============================================================================
// AXI Master Agent
//=============================================================================
class axi_master_agent_improved extends uvm_agent;
    `uvm_component_utils(axi_master_agent_improved)
    
    axi_master_driver_uvm driver;
    axi_master_sequencer sequencer;
    axi_master_monitor monitor;
    uvm_analysis_port #(axi_transaction) ap;
    
    function new(string name = "axi_master_agent_improved", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        monitor = axi_master_monitor::type_id::create("monitor", this);
        
        if (get_is_active() == UVM_ACTIVE) begin
            driver = axi_master_driver_uvm::type_id::create("driver", this);
            sequencer = axi_master_sequencer::type_id::create("sequencer", this);
        end
    endfunction
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        monitor.ap.connect(ap);
        
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass

`endif // AXI_MASTER_AGENT_IMPROVED_SV

