//=============================================================================
// AXI4 Interface - SystemVerilog
// 
// Interface definition cho AXI4 protocol
//=============================================================================

// Include package with guard
`ifndef AXI_PKG_SV
`include "axi_pkg.sv"
`endif
import axi_pkg::*;

//=============================================================================
// AXI4 Write Address Channel Interface
//=============================================================================
interface axi4_aw_channel #(
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned ID_WIDTH = 4,
    parameter int unsigned AW_LEN = 8
) (
    input logic ACLK,
    input logic ARESETN
);
    
    // Write Address Channel Signals
    logic [ID_WIDTH-1:0]     awid;
    logic [ADDR_WIDTH-1:0]   awaddr;
    logic [AW_LEN-1:0]       awlen;
    logic [2:0]              awsize;
    logic [1:0]              awburst;
    logic [1:0]              awlock;
    logic [3:0]              awcache;
    logic [2:0]              awprot;
    logic [3:0]              awregion;  // AXI4 only
    logic [3:0]              awqos;
    logic                    awvalid;
    logic                    awready;
    
    // Modports for Master and Slave
    modport master (
        output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awregion, awqos, awvalid,
        input  awready,
        input  ACLK, ARESETN
    );
    
    modport slave (
        input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awregion, awqos, awvalid,
        output awready,
        input  ACLK, ARESETN
    );
    
    // Note: Clocking blocks removed for Quartus II 13.0 compatibility
    // Quartus II 13.0 does not fully support clocking blocks in interfaces
    
endinterface

//=============================================================================
// AXI4 Write Data Channel Interface
//=============================================================================
interface axi4_w_channel #(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned W_LEN = 8
) (
    input logic ACLK,
    input logic ARESETN
);
    
    // Write Data Channel Signals
    logic [DATA_WIDTH-1:0]   wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                    wlast;
    logic                    wvalid;
    logic                    wready;
    
    // Modports
    modport master (
        output wdata, wstrb, wlast, wvalid,
        input  wready,
        input  ACLK, ARESETN
    );
    
    modport slave (
        input  wdata, wstrb, wlast, wvalid,
        output wready,
        input  ACLK, ARESETN
    );
    
    // Note: Clocking blocks removed for Quartus II 13.0 compatibility
    
endinterface

//=============================================================================
// AXI4 Write Response Channel Interface
//=============================================================================
interface axi4_b_channel #(
    parameter int unsigned ID_WIDTH = 4
) (
    input logic ACLK,
    input logic ARESETN
);
    
    // Write Response Channel Signals
    logic [ID_WIDTH-1:0] bid;
    logic [1:0]          bresp;
    logic                bvalid;
    logic                bready;
    
    // Modports
    modport master (
        input  bid, bresp, bvalid,
        output bready,
        input  ACLK, ARESETN
    );
    
    modport slave (
        output bid, bresp, bvalid,
        input  bready,
        input  ACLK, ARESETN
    );
    
    // Note: Clocking blocks removed for Quartus II 13.0 compatibility
    
endinterface

//=============================================================================
// AXI4 Read Address Channel Interface
//=============================================================================
interface axi4_ar_channel #(
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned ID_WIDTH = 4,
    parameter int unsigned AR_LEN = 8
) (
    input logic ACLK,
    input logic ARESETN
);
    
    // Read Address Channel Signals
    logic [ID_WIDTH-1:0]     arid;
    logic [ADDR_WIDTH-1:0]   araddr;
    logic [AR_LEN-1:0]       arlen;
    logic [2:0]              arsize;
    logic [1:0]              arburst;
    logic [1:0]              arlock;
    logic [3:0]              arcache;
    logic [2:0]              arprot;
    logic [3:0]              arregion;  // AXI4 only
    logic [3:0]              arqos;
    logic                    arvalid;
    logic                    arready;
    
    // Modports
    modport master (
        output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arregion, arqos, arvalid,
        input  arready,
        input  ACLK, ARESETN
    );
    
    modport slave (
        input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arregion, arqos, arvalid,
        output arready,
        input  ACLK, ARESETN
    );
    
    // Note: Clocking blocks removed for Quartus II 13.0 compatibility
    
endinterface

//=============================================================================
// AXI4 Read Data Channel Interface
//=============================================================================
interface axi4_r_channel #(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned ID_WIDTH = 4
) (
    input logic ACLK,
    input logic ARESETN
);
    
    // Read Data Channel Signals
    logic [ID_WIDTH-1:0] rid;
    logic [DATA_WIDTH-1:0] rdata;
    logic [1:0]           rresp;
    logic                 rlast;
    logic                 rvalid;
    logic                 rready;
    
    // Modports
    modport master (
        input  rid, rdata, rresp, rlast, rvalid,
        output rready,
        input  ACLK, ARESETN
    );
    
    modport slave (
        output rid, rdata, rresp, rlast, rvalid,
        input  rready,
        input  ACLK, ARESETN
    );
    
    // Note: Clocking blocks removed for Quartus II 13.0 compatibility
    
endinterface

//=============================================================================
// Complete AXI4 Interface (All Channels)
//=============================================================================
// Note: Interface nesting in modports is not fully supported in Quartus II 13.0
// This interface is defined but may not be used by current modules
// Modules use port-based connections instead
interface axi4_if #(
    parameter int unsigned ADDR_WIDTH = 32,
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned ID_WIDTH = 4,
    parameter int unsigned AW_LEN = 8,
    parameter int unsigned AR_LEN = 8
) (
    input logic ACLK,
    input logic ARESETN
);
    
    // Write Address Channel - using direct signals instead of nested interface
    // This is a simplified version for Quartus II 13.0 compatibility
    logic [ID_WIDTH-1:0]     awid;
    logic [ADDR_WIDTH-1:0]   awaddr;
    logic [AW_LEN-1:0]       awlen;
    logic [2:0]              awsize;
    logic [1:0]              awburst;
    logic [1:0]              awlock;
    logic [3:0]              awcache;
    logic [2:0]              awprot;
    logic [3:0]              awregion;
    logic [3:0]              awqos;
    logic                    awvalid;
    logic                    awready;
    
    // Write Data Channel
    logic [DATA_WIDTH-1:0]   wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                    wlast;
    logic                    wvalid;
    logic                    wready;
    
    // Write Response Channel
    logic [ID_WIDTH-1:0]     bid;
    logic [1:0]              bresp;
    logic                    bvalid;
    logic                    bready;
    
    // Read Address Channel
    logic [ID_WIDTH-1:0]     arid;
    logic [ADDR_WIDTH-1:0]   araddr;
    logic [AR_LEN-1:0]       arlen;
    logic [2:0]              arsize;
    logic [1:0]              arburst;
    logic [1:0]              arlock;
    logic [3:0]              arcache;
    logic [2:0]              arprot;
    logic [3:0]              arregion;
    logic [3:0]              arqos;
    logic                    arvalid;
    logic                    arready;
    
    // Read Data Channel
    logic [ID_WIDTH-1:0]     rid;
    logic [DATA_WIDTH-1:0]   rdata;
    logic [1:0]              rresp;
    logic                    rlast;
    logic                    rvalid;
    logic                    rready;
    
    // Modports for Master and Slave (simplified for Quartus II 13.0)
    modport master (
        output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awregion, awqos, awvalid,
        input  awready,
        output wdata, wstrb, wlast, wvalid,
        input  wready,
        input  bid, bresp, bvalid,
        output bready,
        output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arregion, arqos, arvalid,
        input  arready,
        input  rid, rdata, rresp, rlast, rvalid,
        output rready,
        input  ACLK, ARESETN
    );
    
    modport slave (
        input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awregion, awqos, awvalid,
        output awready,
        input  wdata, wstrb, wlast, wvalid,
        output wready,
        output bid, bresp, bvalid,
        input  bready,
        input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arregion, arqos, arvalid,
        output arready,
        output rid, rdata, rresp, rlast, rvalid,
        input  rready,
        input  ACLK, ARESETN
    );
    
endinterface

