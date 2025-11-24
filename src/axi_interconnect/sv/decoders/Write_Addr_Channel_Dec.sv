//=============================================================================
// Write_Addr_Channel_Dec.sv - SystemVerilog
// Write Address Channel Decoder
//=============================================================================

`timescale 1ns/1ps

module Write_Addr_Channel_Dec #(
    parameter int unsigned Num_OF_Masters = 2,
    parameter int unsigned Masters_ID_Size = $clog2(Num_OF_Masters),
    parameter int unsigned Address_width = 32,
    parameter int unsigned AXI4_Aw_len = 8,
    parameter int unsigned Num_Of_Slaves = 4,
    parameter int unsigned Base_Addr_Width = $clog2(Num_Of_Slaves)
) (
    // Ports of the selected master from the arbiter
    input  logic [Masters_ID_Size-1:0]   Master_AXI_awaddr_ID,
    input  logic [Address_width-1:0]    Master_AXI_awaddr,  // the write address
    input  logic [AXI4_Aw_len-1:0]      Master_AXI_awlen,  // number of transfer per burst
    input  logic [2:0]                   Master_AXI_awsize, // number of bytes within the transfer
    input  logic [1:0]                   Master_AXI_awburst, // burst type
    input  logic [1:0]                   Master_AXI_awlock,  // lock type
    input  logic [3:0]                   Master_AXI_awcache, // optional signal for connecting to different types of memories
    input  logic [2:0]                   Master_AXI_awprot,  // identifies the level of protection
    input  logic [3:0]                   Master_AXI_awqos,   // for priority transactions
    input  logic                         Master_AXI_awvalid, // Address write valid signal
    
    output logic [Masters_ID_Size-1:0]  M00_AXI_awaddr_ID,
    output logic [Address_width-1:0]    M00_AXI_awaddr,
    output logic [AXI4_Aw_len-1:0]      M00_AXI_awlen,
    output logic [2:0]                  M00_AXI_awsize,  // number of bytes within the transfer
    output logic [1:0]                  M00_AXI_awburst, // burst type
    output logic [1:0]                  M00_AXI_awlock,  // lock type
    output logic [3:0]                  M00_AXI_awcache, // optional signal for connecting to different types of memories
    output logic [2:0]                  M00_AXI_awprot,  // identifies the level of protection
    output logic [3:0]                  M00_AXI_awqos,   // for priority transactions
    output logic                        M00_AXI_awvalid, // Address write valid signal
    input  logic                        M00_AXI_awready, // Address write ready signal

    output logic [Masters_ID_Size-1:0]  M01_AXI_awaddr_ID,
    output logic [Address_width-1:0]    M01_AXI_awaddr,
    output logic [AXI4_Aw_len-1:0]      M01_AXI_awlen,
    output logic [2:0]                  M01_AXI_awsize,  // number of bytes within the transfer
    output logic [1:0]                  M01_AXI_awburst, // burst type
    output logic [1:0]                  M01_AXI_awlock,  // lock type
    output logic [3:0]                  M01_AXI_awcache, // optional signal for connecting to different types of memories
    output logic [2:0]                  M01_AXI_awprot,  // identifies the level of protection
    output logic [3:0]                  M01_AXI_awqos,   // for priority transactions
    output logic                        M01_AXI_awvalid, // Address write valid signal
    input  logic                        M01_AXI_awready, // Address write ready signal

    output logic [Masters_ID_Size-1:0]  M02_AXI_awaddr_ID,
    output logic [Address_width-1:0]    M02_AXI_awaddr,
    output logic [AXI4_Aw_len-1:0]      M02_AXI_awlen,
    output logic [2:0]                  M02_AXI_awsize,  // number of bytes within the transfer
    output logic [1:0]                  M02_AXI_awburst, // burst type
    output logic [1:0]                  M02_AXI_awlock,  // lock type
    output logic [3:0]                  M02_AXI_awcache, // optional signal for connecting to different types of memories
    output logic [2:0]                  M02_AXI_awprot,  // identifies the level of protection
    output logic [3:0]                  M02_AXI_awqos,   // for priority transactions
    output logic                        M02_AXI_awvalid, // Address write valid signal
    input  logic                        M02_AXI_awready, // Address write ready signal

    output logic [Masters_ID_Size-1:0]  M03_AXI_awaddr_ID,
    output logic [Address_width-1:0]    M03_AXI_awaddr,
    output logic [AXI4_Aw_len-1:0]      M03_AXI_awlen,
    output logic [2:0]                  M03_AXI_awsize,  // number of bytes within the transfer
    output logic [1:0]                  M03_AXI_awburst, // burst type
    output logic [1:0]                  M03_AXI_awlock,  // lock type
    output logic [3:0]                  M03_AXI_awcache, // optional signal for connecting to different types of memories
    output logic [2:0]                  M03_AXI_awprot,  // identifies the level of protection
    output logic [3:0]                  M03_AXI_awqos,   // for priority transactions
    output logic                        M03_AXI_awvalid, // Address write valid signal
    input  logic                        M03_AXI_awready, // Address write ready signal

    output logic                        Sel_Slave_Ready,
    output logic [Num_Of_Slaves - 1 : 0] Q_Enables
);

    localparam logic [1:0] Slave0_Base_Addr = 2'b00,
                           Slave1_Base_Addr = 2'b01,
                           Slave2_Base_Addr = 2'b10,
                           Slave3_Base_Addr = 2'b11;
    
    logic [Base_Addr_Width - 1 : 0] Base_Addr_Master;
    assign Base_Addr_Master = Master_AXI_awaddr[Address_width-1:Address_width-Base_Addr_Width];

    // Debug visibility for write address decoding
    always_comb begin
        if (Master_AXI_awvalid) begin
            $display("[%0t] WRITE_DEC: addr=0x%08h base_addr=%02b -> Slave%0d",
                     $time, Master_AXI_awaddr, Base_Addr_Master, Base_Addr_Master);
        end
    end

    always_comb begin
        // Default values - All outputs should have default to avoid multiple drivers
        M00_AXI_awvalid = 1'b0;
        M01_AXI_awvalid = 1'b0;
        M02_AXI_awvalid = 1'b0;
        M03_AXI_awvalid = 1'b0;
        Q_Enables = 4'b0000;
        Sel_Slave_Ready = 1'b0;
        
        // Default address/data signals
        M00_AXI_awaddr_ID = '0;
        M00_AXI_awaddr = '0;
        M00_AXI_awlen = '0;
        M00_AXI_awsize = 3'b0;
        M00_AXI_awburst = 2'b0;
        M00_AXI_awlock = 2'b0;
        M00_AXI_awcache = 4'b0;
        M00_AXI_awprot = 3'b0;
        M00_AXI_awqos = 4'b0;
        
        M01_AXI_awaddr_ID = '0;
        M01_AXI_awaddr = '0;
        M01_AXI_awlen = '0;
        M01_AXI_awsize = 3'b0;
        M01_AXI_awburst = 2'b0;
        M01_AXI_awlock = 2'b0;
        M01_AXI_awcache = 4'b0;
        M01_AXI_awprot = 3'b0;
        M01_AXI_awqos = 4'b0;
        
        M02_AXI_awaddr_ID = '0;
        M02_AXI_awaddr = '0;
        M02_AXI_awlen = '0;
        M02_AXI_awsize = 3'b0;
        M02_AXI_awburst = 2'b0;
        M02_AXI_awlock = 2'b0;
        M02_AXI_awcache = 4'b0;
        M02_AXI_awprot = 3'b0;
        M02_AXI_awqos = 4'b0;
        
        M03_AXI_awaddr_ID = '0;
        M03_AXI_awaddr = '0;
        M03_AXI_awlen = '0;
        M03_AXI_awsize = 3'b0;
        M03_AXI_awburst = 2'b0;
        M03_AXI_awlock = 2'b0;
        M03_AXI_awcache = 4'b0;
        M03_AXI_awprot = 3'b0;
        M03_AXI_awqos = 4'b0;
        
        case (Base_Addr_Master)
            Slave0_Base_Addr: begin
                Q_Enables = 4'b0001;
                Sel_Slave_Ready = M00_AXI_awready;
                M00_AXI_awaddr_ID = Master_AXI_awaddr_ID;
                M00_AXI_awaddr = Master_AXI_awaddr;
                M00_AXI_awlen = Master_AXI_awlen;
                M00_AXI_awsize = Master_AXI_awsize;
                M00_AXI_awburst = Master_AXI_awburst;
                M00_AXI_awlock = Master_AXI_awlock;
                M00_AXI_awcache = Master_AXI_awcache;
                M00_AXI_awprot = Master_AXI_awprot;
                M00_AXI_awqos = Master_AXI_awqos;
                M00_AXI_awvalid = Master_AXI_awvalid;
            end

            Slave1_Base_Addr: begin
                Q_Enables = 4'b0010;
                Sel_Slave_Ready = M01_AXI_awready;
                M01_AXI_awaddr_ID = Master_AXI_awaddr_ID;
                M01_AXI_awaddr = Master_AXI_awaddr;
                M01_AXI_awlen = Master_AXI_awlen;
                M01_AXI_awsize = Master_AXI_awsize;
                M01_AXI_awburst = Master_AXI_awburst;
                M01_AXI_awlock = Master_AXI_awlock;
                M01_AXI_awcache = Master_AXI_awcache;
                M01_AXI_awprot = Master_AXI_awprot;
                M01_AXI_awqos = Master_AXI_awqos;
                M01_AXI_awvalid = Master_AXI_awvalid;
                M00_AXI_awvalid = 1'b0;
                M02_AXI_awvalid = 1'b0;
                M03_AXI_awvalid = 1'b0;
            end

            Slave2_Base_Addr: begin
                Q_Enables = 4'b0100;
                Sel_Slave_Ready = M02_AXI_awready;
                M02_AXI_awaddr_ID = Master_AXI_awaddr_ID;
                M02_AXI_awaddr = Master_AXI_awaddr;
                M02_AXI_awlen = Master_AXI_awlen;
                M02_AXI_awsize = Master_AXI_awsize;
                M02_AXI_awburst = Master_AXI_awburst;
                M02_AXI_awlock = Master_AXI_awlock;
                M02_AXI_awcache = Master_AXI_awcache;
                M02_AXI_awprot = Master_AXI_awprot;
                M02_AXI_awqos = Master_AXI_awqos;
                M02_AXI_awvalid = Master_AXI_awvalid;
                M00_AXI_awvalid = 1'b0;
                M01_AXI_awvalid = 1'b0;
                M03_AXI_awvalid = 1'b0;
            end

            Slave3_Base_Addr: begin
                Q_Enables = 4'b1000;
                Sel_Slave_Ready = M03_AXI_awready;
                M03_AXI_awaddr_ID = Master_AXI_awaddr_ID;
                M03_AXI_awaddr = Master_AXI_awaddr;
                M03_AXI_awlen = Master_AXI_awlen;
                M03_AXI_awsize = Master_AXI_awsize;
                M03_AXI_awburst = Master_AXI_awburst;
                M03_AXI_awlock = Master_AXI_awlock;
                M03_AXI_awcache = Master_AXI_awcache;
                M03_AXI_awprot = Master_AXI_awprot;
                M03_AXI_awqos = Master_AXI_awqos;
                M03_AXI_awvalid = Master_AXI_awvalid;
                M00_AXI_awvalid = 1'b0;
                M01_AXI_awvalid = 1'b0;
                M02_AXI_awvalid = 1'b0;
            end

            default: begin
                Q_Enables = 4'b0001;
                M00_AXI_awvalid = Master_AXI_awvalid;
            end
        endcase
    end

endmodule
