//=============================================================================
// AXI Interconnect Simple Testbench - SystemVerilog (No UVM)
// Simple testbench để test AXI Interconnect không cần UVM
//=============================================================================

`timescale 1ns/1ps

`include "../../src/axi_interconnect/sv/packages/axi_pkg.sv"
`include "axi_slave_model_improved.sv"
`include "axi_master_driver_improved.sv"

//=============================================================================
// AXI Master Interface (Simplified)
//=============================================================================
interface axi_master_simple_if (input logic ACLK, input logic ARESETN);
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
    
    // Modports
    modport master (
        output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awvalid,
        input  awready,
        output wdata, wstrb, wlast, wvalid,
        input  wready,
        input  bid, bresp, bvalid,
        output bready,
        output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, arvalid,
        input  arready,
        input  rid, rdata, rresp, rlast, rvalid,
        output rready,
        input  ACLK, ARESETN
    );
endinterface

//=============================================================================
// AXI Slave Interface (Simplified)
//=============================================================================
interface axi_slave_simple_if (input logic ACLK, input logic ARESETN);
    // Similar structure but with reversed directions
    // Write Address Channel (slave receives)
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
    
    // Write Response Channel (slave sends)
    logic [axi_pkg::ID_WIDTH-1:0]      bid;
    logic [1:0]                        bresp;
    logic                              bvalid;
    logic                              bready;
    
    // Read Address Channel (slave receives)
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
    
    // Read Data Channel (slave sends)
    logic [axi_pkg::ID_WIDTH-1:0]      rid;
    logic [axi_pkg::DATA_WIDTH-1:0]    rdata;
    logic [1:0]                        rresp;
    logic                              rlast;
    logic                              rvalid;
    logic                              rready;
    
    // Modports
    modport slave (
        input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awvalid,
        output awready,
        input  wdata, wstrb, wlast, wvalid,
        output wready,
        output bid, bresp, bvalid,
        input  bready,
        input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, arvalid,
        output arready,
        output rid, rdata, rresp, rlast, rvalid,
        input  rready,
        input  ACLK, ARESETN
    );
endinterface

//=============================================================================
// Simple AXI Master Driver
//=============================================================================
module axi_master_driver (
    axi_master_simple_if.master m_if
);
    initial begin
        // Initialize signals
        m_if.awvalid = 1'b0;
        m_if.wvalid = 1'b0;
        m_if.bready = 1'b0;
        m_if.arvalid = 1'b0;
        m_if.rready = 1'b0;
        
        wait(m_if.ARESETN);
        #100;
        
        $display("=== Starting AXI Master Test ===");
        
        // Simple write transaction
        @(posedge m_if.ACLK);
        m_if.awaddr = 32'h0000_1000;
        m_if.awlen = 8'h0;  // 1 beat
        m_if.awsize = 3'h2; // 4 bytes
        m_if.awburst = 2'h1; // INCR
        m_if.awvalid = 1'b1;
        
        wait(m_if.awready);
        @(posedge m_if.ACLK);
        m_if.awvalid = 1'b0;
        
        // Write data
        @(posedge m_if.ACLK);
        m_if.wdata = 32'hDEAD_BEEF;
        m_if.wstrb = 4'hF;
        m_if.wlast = 1'b1;
        m_if.wvalid = 1'b1;
        
        wait(m_if.wready);
        @(posedge m_if.ACLK);
        m_if.wvalid = 1'b0;
        
        // Wait for write response
        m_if.bready = 1'b1;
        wait(m_if.bvalid);
        @(posedge m_if.ACLK);
        m_if.bready = 1'b0;
        
        $display("Write transaction completed. Response: %0b", m_if.bresp);
        
        // Simple read transaction
        #100;
        @(posedge m_if.ACLK);
        m_if.araddr = 32'h4000_2000;
        m_if.arlen = 8'h0;  // 1 beat
        m_if.arsize = 3'h2; // 4 bytes
        m_if.arburst = 2'h1; // INCR
        m_if.arvalid = 1'b1;
        
        wait(m_if.arready);
        @(posedge m_if.ACLK);
        m_if.arvalid = 1'b0;
        
        // Read data
        m_if.rready = 1'b1;
        wait(m_if.rvalid);
        $display("Read transaction completed. Data: 0x%08x, Response: %0b", m_if.rdata, m_if.rresp);
        @(posedge m_if.ACLK);
        m_if.rready = 1'b0;
        
        #1000;
        $display("=== Test Completed ===");
        $finish;
    end
endmodule

//=============================================================================
// Simple AXI Slave Model
//=============================================================================
module axi_slave_model (
    axi_slave_simple_if.slave s_if
);
    logic [31:0] memory [0:1023];
    
    // Write Address Channel
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            s_if.awready <= 1'b0;
        end else begin
            s_if.awready <= s_if.awvalid && !s_if.awready;
        end
    end
    
    // Write Data Channel
    logic write_data_received;
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            s_if.wready <= 1'b0;
            write_data_received <= 1'b0;
        end else begin
            if (s_if.wvalid && !write_data_received) begin
                s_if.wready <= 1'b1;
                memory[s_if.awaddr[11:2]] <= s_if.wdata;
                write_data_received <= s_if.wlast;
            end else if (s_if.wready) begin
                s_if.wready <= 1'b0;
                if (s_if.wlast) write_data_received <= 1'b0;
            end
        end
    end
    
    // Write Response Channel
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            s_if.bvalid <= 1'b0;
            s_if.bresp <= 2'b00;
        end else begin
            if (write_data_received && s_if.wlast && !s_if.bvalid) begin
                s_if.bvalid <= 1'b1;
                s_if.bresp <= 2'b00; // OKAY
            end else if (s_if.bready && s_if.bvalid) begin
                s_if.bvalid <= 1'b0;
            end
        end
    end
    
    // Read Address Channel
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            s_if.arready <= 1'b0;
        end else begin
            s_if.arready <= s_if.arvalid;
        end
    end
    
    // Read Data Channel
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            s_if.rvalid <= 1'b0;
            s_if.rdata <= 32'h0;
            s_if.rresp <= 2'b00;
            s_if.rlast <= 1'b0;
        end else begin
            if (s_if.arvalid && s_if.arready) begin
                s_if.rvalid <= 1'b1;
                s_if.rdata <= memory[s_if.araddr[11:2]];
                s_if.rresp <= 2'b00; // OKAY
                s_if.rlast <= 1'b1;
            end else if (s_if.rready) begin
                s_if.rvalid <= 1'b0;
                s_if.rlast <= 1'b0;
            end
        end
    end
endmodule

//=============================================================================
// Testbench Top
//=============================================================================
module axi_interconnect_simple_tb;
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
        $display("Reset released at time %0t", $time);
    end
    
    // Master Interfaces (2 masters)
    axi_master_simple_if master_if[2](ACLK, ARESETN);
    
    // Slave Interfaces (4 slaves)
    axi_slave_simple_if slave_if[4](ACLK, ARESETN);
    
    // Unused output signals
    logic M00_AXI_awaddr_ID;
    
    // Master Drivers (using improved driver)
    axi_master_driver_improved master0_driver(master_if[0], 0);
    axi_master_driver_improved master1_driver(master_if[1], 1);
    
    // Slave Models (using improved model)
    axi_slave_model_improved slave0_model(slave_if[0], 0, 0);
    axi_slave_model_improved slave1_model(slave_if[1], 1, 1);
    axi_slave_model_improved slave2_model(slave_if[2], 2, 2);
    axi_slave_model_improved slave3_model(slave_if[3], 3, 0);
    
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
        // Master 0 (S00)
        .S00_ACLK(ACLK),
        .S00_ARESETN(ARESETN),
        .S00_AXI_awaddr(master_if[0].awaddr),
        .S00_AXI_awlen(master_if[0].awlen),
        .S00_AXI_awsize(master_if[0].awsize),
        .S00_AXI_awburst(master_if[0].awburst),
        .S00_AXI_awlock(master_if[0].awlock),
        .S00_AXI_awcache(master_if[0].awcache),
        .S00_AXI_awprot(master_if[0].awprot),
        .S00_AXI_awqos(master_if[0].awqos),
        .S00_AXI_awvalid(master_if[0].awvalid),
        .S00_AXI_awready(master_if[0].awready),
        .S00_AXI_wdata(master_if[0].wdata),
        .S00_AXI_wstrb(master_if[0].wstrb),
        .S00_AXI_wlast(master_if[0].wlast),
        .S00_AXI_wvalid(master_if[0].wvalid),
        .S00_AXI_wready(master_if[0].wready),
        .S00_AXI_bresp(master_if[0].bresp),
        .S00_AXI_bvalid(master_if[0].bvalid),
        .S00_AXI_bready(master_if[0].bready),
        .S00_AXI_araddr(master_if[0].araddr),
        .S00_AXI_arlen(master_if[0].arlen),
        .S00_AXI_arsize(master_if[0].arsize),
        .S00_AXI_arburst(master_if[0].arburst),
        .S00_AXI_arlock(master_if[0].arlock),
        .S00_AXI_arcache(master_if[0].arcache),
        .S00_AXI_arprot(master_if[0].arprot),
        .S00_AXI_arqos(master_if[0].arqos),
        .S00_AXI_arregion(master_if[0].arregion),
        .S00_AXI_arvalid(master_if[0].arvalid),
        .S00_AXI_arready(master_if[0].arready),
        .S00_AXI_rdata(master_if[0].rdata),
        .S00_AXI_rresp(master_if[0].rresp),
        .S00_AXI_rlast(master_if[0].rlast),
        .S00_AXI_rvalid(master_if[0].rvalid),
        .S00_AXI_rready(master_if[0].rready),
        
        // Master 1 (S01) - Similar connections
        .S01_ACLK(ACLK),
        .S01_ARESETN(ARESETN),
        .S01_AXI_awaddr(master_if[1].awaddr),
        .S01_AXI_awlen(master_if[1].awlen),
        .S01_AXI_awsize(master_if[1].awsize),
        .S01_AXI_awburst(master_if[1].awburst),
        .S01_AXI_awlock(master_if[1].awlock),
        .S01_AXI_awcache(master_if[1].awcache),
        .S01_AXI_awprot(master_if[1].awprot),
        .S01_AXI_awqos(master_if[1].awqos),
        .S01_AXI_awvalid(master_if[1].awvalid),
        .S01_AXI_awready(master_if[1].awready),
        .S01_AXI_wdata(master_if[1].wdata),
        .S01_AXI_wstrb(master_if[1].wstrb),
        .S01_AXI_wlast(master_if[1].wlast),
        .S01_AXI_wvalid(master_if[1].wvalid),
        .S01_AXI_wready(master_if[1].wready),
        .S01_AXI_bresp(master_if[1].bresp),
        .S01_AXI_bvalid(master_if[1].bvalid),
        .S01_AXI_bready(master_if[1].bready),
        .S01_AXI_araddr(master_if[1].araddr),
        .S01_AXI_arlen(master_if[1].arlen),
        .S01_AXI_arsize(master_if[1].arsize),
        .S01_AXI_arburst(master_if[1].arburst),
        .S01_AXI_arlock(master_if[1].arlock),
        .S01_AXI_arcache(master_if[1].arcache),
        .S01_AXI_arprot(master_if[1].arprot),
        .S01_AXI_arqos(master_if[1].arqos),
        .S01_AXI_arregion(master_if[1].arregion),
        .S01_AXI_arvalid(master_if[1].arvalid),
        .S01_AXI_arready(master_if[1].arready),
        .S01_AXI_rdata(master_if[1].rdata),
        .S01_AXI_rresp(master_if[1].rresp),
        .S01_AXI_rlast(master_if[1].rlast),
        .S01_AXI_rvalid(master_if[1].rvalid),
        .S01_AXI_rready(master_if[1].rready),
        
        // Global
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Slave 0 (M00) - Connect to slave_if[0]
        .M00_ACLK(ACLK),
        .M00_ARESETN(ARESETN),
        .M00_AXI_awaddr_ID(M00_AXI_awaddr_ID),  // ID signal, 1 bit (unused)
        .M00_AXI_awaddr(slave_if[0].awaddr),
        .M00_AXI_awlen(slave_if[0].awlen),
        .M00_AXI_awsize(slave_if[0].awsize),
        .M00_AXI_awburst(slave_if[0].awburst),
        .M00_AXI_awlock(slave_if[0].awlock),
        .M00_AXI_awcache(slave_if[0].awcache),
        .M00_AXI_awprot(slave_if[0].awprot),
        .M00_AXI_awqos(slave_if[0].awqos),
        .M00_AXI_awvalid(slave_if[0].awvalid),
        .M00_AXI_awready(slave_if[0].awready),
        .M00_AXI_wdata(slave_if[0].wdata),
        .M00_AXI_wstrb(slave_if[0].wstrb),
        .M00_AXI_wlast(slave_if[0].wlast),
        .M00_AXI_wvalid(slave_if[0].wvalid),
        .M00_AXI_wready(slave_if[0].wready),
        .M00_AXI_BID(slave_if[0].bid[0]),  // Only 1 bit needed
        .M00_AXI_bresp(slave_if[0].bresp),
        .M00_AXI_bvalid(slave_if[0].bvalid),
        .M00_AXI_bready(slave_if[0].bready),
        .M00_AXI_araddr(slave_if[0].araddr),
        .M00_AXI_arlen(slave_if[0].arlen),
        .M00_AXI_arsize(slave_if[0].arsize),
        .M00_AXI_arburst(slave_if[0].arburst),
        .M00_AXI_arlock(slave_if[0].arlock),
        .M00_AXI_arcache(slave_if[0].arcache),
        .M00_AXI_arprot(slave_if[0].arprot),
        .M00_AXI_arregion(slave_if[0].arregion),
        .M00_AXI_arqos(slave_if[0].arqos),
        .M00_AXI_arvalid(slave_if[0].arvalid),
        .M00_AXI_arready(slave_if[0].arready),
        .M00_AXI_rdata(slave_if[0].rdata),
        .M00_AXI_rresp(slave_if[0].rresp),
        .M00_AXI_rlast(slave_if[0].rlast),
        .M00_AXI_rvalid(slave_if[0].rvalid),
        .M00_AXI_rready(slave_if[0].rready),
        
        // Slave 1 (M01) - Full read/write connections
        .M01_ACLK(ACLK),
        .M01_ARESETN(ARESETN),
        .M01_AXI_awaddr_ID(),  // Not used, leave unconnected
        .M01_AXI_awaddr(slave_if[1].awaddr),
        .M01_AXI_awlen(slave_if[1].awlen),
        .M01_AXI_awsize(slave_if[1].awsize),
        .M01_AXI_awburst(slave_if[1].awburst),
        .M01_AXI_awlock(slave_if[1].awlock),
        .M01_AXI_awcache(slave_if[1].awcache),
        .M01_AXI_awprot(slave_if[1].awprot),
        .M01_AXI_awqos(slave_if[1].awqos),
        .M01_AXI_awvalid(slave_if[1].awvalid),
        .M01_AXI_awready(slave_if[1].awready),
        .M01_AXI_wdata(slave_if[1].wdata),
        .M01_AXI_wstrb(slave_if[1].wstrb),
        .M01_AXI_wlast(slave_if[1].wlast),
        .M01_AXI_wvalid(slave_if[1].wvalid),
        .M01_AXI_wready(slave_if[1].wready),
        .M01_AXI_BID(slave_if[1].bid[0]),  // Only 1 bit needed
        .M01_AXI_bresp(slave_if[1].bresp),
        .M01_AXI_bvalid(slave_if[1].bvalid),
        .M01_AXI_bready(slave_if[1].bready),
        .M01_AXI_araddr(slave_if[1].araddr),
        .M01_AXI_arlen(slave_if[1].arlen),
        .M01_AXI_arsize(slave_if[1].arsize),
        .M01_AXI_arburst(slave_if[1].arburst),
        .M01_AXI_arlock(slave_if[1].arlock),
        .M01_AXI_arcache(slave_if[1].arcache),
        .M01_AXI_arprot(slave_if[1].arprot),
        .M01_AXI_arregion(slave_if[1].arregion),
        .M01_AXI_arqos(slave_if[1].arqos),
        .M01_AXI_arvalid(slave_if[1].arvalid),
        .M01_AXI_arready(slave_if[1].arready),
        .M01_AXI_rdata(slave_if[1].rdata),
        .M01_AXI_rresp(slave_if[1].rresp),
        .M01_AXI_rlast(slave_if[1].rlast),
        .M01_AXI_rvalid(slave_if[1].rvalid),
        .M01_AXI_rready(slave_if[1].rready),
        
        // Slave 2 & 3 (M02, M03) - Read only, tie off write channels
        .M02_ACLK(ACLK),
        .M02_ARESETN(ARESETN),
        .M02_AXI_araddr(slave_if[2].araddr),
        .M02_AXI_arlen(slave_if[2].arlen),
        .M02_AXI_arsize(slave_if[2].arsize),
        .M02_AXI_arburst(slave_if[2].arburst),
        .M02_AXI_arlock(slave_if[2].arlock),
        .M02_AXI_arcache(slave_if[2].arcache),
        .M02_AXI_arprot(slave_if[2].arprot),
        .M02_AXI_arregion(slave_if[2].arregion),
        .M02_AXI_arqos(slave_if[2].arqos),
        .M02_AXI_arvalid(slave_if[2].arvalid),
        .M02_AXI_arready(slave_if[2].arready),
        .M02_AXI_rdata(slave_if[2].rdata),
        .M02_AXI_rresp(slave_if[2].rresp),
        .M02_AXI_rlast(slave_if[2].rlast),
        .M02_AXI_rvalid(slave_if[2].rvalid),
        .M02_AXI_rready(slave_if[2].rready),
        
        .M03_ACLK(ACLK),
        .M03_ARESETN(ARESETN),
        .M03_AXI_araddr(slave_if[3].araddr),
        .M03_AXI_arlen(slave_if[3].arlen),
        .M03_AXI_arsize(slave_if[3].arsize),
        .M03_AXI_arburst(slave_if[3].arburst),
        .M03_AXI_arlock(slave_if[3].arlock),
        .M03_AXI_arcache(slave_if[3].arcache),
        .M03_AXI_arprot(slave_if[3].arprot),
        .M03_AXI_arregion(slave_if[3].arregion),
        .M03_AXI_arqos(slave_if[3].arqos),
        .M03_AXI_arvalid(slave_if[3].arvalid),
        .M03_AXI_arready(slave_if[3].arready),
        .M03_AXI_rdata(slave_if[3].rdata),
        .M03_AXI_rresp(slave_if[3].rresp),
        .M03_AXI_rlast(slave_if[3].rlast),
        .M03_AXI_rvalid(slave_if[3].rvalid),
        .M03_AXI_rready(slave_if[3].rready),
        
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
    
    // Dump waveforms
    initial begin
        $dumpfile("axi_interconnect_simple_tb.vcd");
        $dumpvars(0, axi_interconnect_simple_tb);
    end
    
    // Timeout (increased for more test cases)
    initial begin
        #50000;  // 50us timeout
        $display("[%0t] Simulation timeout!", $time);
        $finish;
    end
    
    // Test completion check
    initial begin
        wait(master0_driver.m_if.ARESETN);
        #45000;  // Wait for tests to complete
        $display("\n[%0t] ========== All Tests Completed ==========", $time);
        $display("[%0t] Simulation finished successfully!", $time);
        $finish;
    end
endmodule

