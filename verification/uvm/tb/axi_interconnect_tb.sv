//=============================================================================
// AXI Interconnect Testbench - UVM
// Top-level testbench cho AXI Interconnect verification
//=============================================================================

`ifndef AXI_INTERCONNECT_TB_SV
`define AXI_INTERCONNECT_TB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

`include "../../src/axi_interconnect/sv/packages/axi_pkg.sv"
`include "../../src/axi_interconnect/sv/core/AXI_Interconnect_Full.sv"
`include "test/axi_interconnect_base_test.sv"

//=============================================================================
// AXI Master Interface
//=============================================================================
interface axi_master_if (input logic ACLK, input logic ARESETN);
    // Write Address Channel
    logic [axi_pkg::ID_WIDTH-1:0]     awid;
    logic [axi_pkg::ADDR_WIDTH-1:0]   awaddr;
    logic [7:0]                        awlen;
    logic [2:0]                        awsize;
    logic [1:0]                        awburst;
    logic [1:0]                        awlock;
    logic [3:0]                        awcache;
    logic [2:0]                        awprot;
    logic [3:0]                        awqos;
    logic [3:0]                        awregion;
    logic                              awvalid;
    logic                              awready;
    
    // Write Data Channel
    logic [axi_pkg::DATA_WIDTH-1:0]    wdata;
    logic [(axi_pkg::DATA_WIDTH/8)-1:0] wstrb;
    logic                              wlast;
    logic                              wvalid;
    logic                              wready;
    
    // Write Response Channel
    logic [axi_pkg::ID_WIDTH-1:0]      bid;
    logic [1:0]                        bresp;
    logic                              bvalid;
    logic                              bready;
    
    // Read Address Channel
    logic [axi_pkg::ID_WIDTH-1:0]      arid;
    logic [axi_pkg::ADDR_WIDTH-1:0]    araddr;
    logic [7:0]                        arlen;
    logic [2:0]                        arsize;
    logic [1:0]                        arburst;
    logic [1:0]                        arlock;
    logic [3:0]                        arcache;
    logic [2:0]                        arprot;
    logic [3:0]                        arqos;
    logic [3:0]                        arregion;
    logic                              arvalid;
    logic                              arready;
    
    // Read Data Channel
    logic [axi_pkg::ID_WIDTH-1:0]      rid;
    logic [axi_pkg::DATA_WIDTH-1:0]    rdata;
    logic [1:0]                        rresp;
    logic                              rlast;
    logic                              rvalid;
    logic                              rready;
endinterface

//=============================================================================
// AXI Slave Interface
//=============================================================================
interface axi_slave_if (input logic ACLK, input logic ARESETN);
    // Similar to master interface but with reversed directions
    // (Implementation similar to master_if)
endinterface

//=============================================================================
// Testbench Top
//=============================================================================
module axi_interconnect_tb;
    // Clock and Reset
    logic ACLK;
    logic ARESETN;
    
    // Clock generation
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK;
    end
    
    // Reset generation
    initial begin
        ARESETN = 0;
        #100;
        ARESETN = 1;
    end
    
    // Master Interfaces (2 masters)
    axi_master_if master_if[2](ACLK, ARESETN);
    
    // Slave Interfaces (4 slaves)
    axi_slave_if slave_if[4](ACLK, ARESETN);
    
    // DUT Instantiation
    AXI_Interconnect_Full #(
        .Masters_Num(2),
        .Num_Of_Masters(2),
        .Num_Of_Slaves(4),
        .Address_width(32),
        .S00_Aw_len(8),
        .S00_Write_data_bus_width(32),
        .S00_AR_len(8),
        .S00_Read_data_bus_width(32),
        .S01_Aw_len(8),
        .S01_Write_data_bus_width(32),
        .S01_AR_len(8),
        .M00_Aw_len(8),
        .M00_Write_data_bus_width(32),
        .M00_AR_len(8),
        .M00_Read_data_bus_width(32),
        .M01_Aw_len(8),
        .M01_AR_len(8),
        .M02_Aw_len(8),
        .M02_AR_len(8),
        .M02_Read_data_bus_width(32),
        .M03_Aw_len(8),
        .M03_AR_len(8),
        .M03_Read_data_bus_width(32),
        .Is_Master_AXI_4(1),
        .Master_ID_Width(1),
        .AXI4_AR_len(8)
    ) dut (
        // Connect master interfaces
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S00_AXI_awaddr(master_if[0].awaddr),
        // ... (connect all signals)
        
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        .S01_AXI_awaddr(master_if[1].awaddr),
        // ... (connect all signals)
        
        // Connect slave interfaces
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        // ... (connect all signals)
        
        // Address ranges
        .slave0_addr1(32'h0000_0000),
        .slave0_addr2(32'h3FFF_FFFF),
        .slave1_addr1(32'h4000_0000),
        .slave1_addr2(32'h7FFF_FFFF),
        .slave2_addr1(32'h8000_0000),
        .slave2_addr2(32'hBFFF_FFFF),
        .slave3_addr1(32'hC000_0000),
        .slave3_addr2(32'hFFFF_FFFF)
    );
    
    // UVM Test
    initial begin
        uvm_config_db#(virtual axi_master_if)::set(null, "uvm_test_top.env.master_agent[0]", "vif", master_if[0]);
        uvm_config_db#(virtual axi_master_if)::set(null, "uvm_test_top.env.master_agent[1]", "vif", master_if[1]);
        
        run_test("axi_interconnect_base_test");
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("axi_interconnect_tb.vcd");
        $dumpvars(0, axi_interconnect_tb);
    end
endmodule

`endif // AXI_INTERCONNECT_TB_SV

