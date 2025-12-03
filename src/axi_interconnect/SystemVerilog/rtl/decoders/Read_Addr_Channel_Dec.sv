//=============================================================================
// Read_Addr_Channel_Dec.sv - SystemVerilog
// Address Decoder for AXI Read Address Channel
// Decodes Base-Addr from ARADDR to route to correct Slave
// Supports 4 Slaves (M00, M01, M02, M03)
//=============================================================================

`timescale 1ns/1ps

module Read_Addr_Channel_Dec #(
    parameter int unsigned Num_OF_Masters = 2,
    parameter int unsigned Masters_ID_Size = $clog2(Num_OF_Masters),
    parameter int unsigned Address_width = 32,
    parameter int unsigned AXI4_AR_len = 8,
    parameter int unsigned Num_Of_Slaves = 4,
    parameter int unsigned Base_Addr_Width = $clog2(Num_Of_Slaves)
) (
    // Ports of the selected master from the arbiter
    input  logic [Masters_ID_Size-1:0]   Master_AXI_araddr_ID,
    input  logic [Address_width-1:0]    Master_AXI_araddr,  // the read address
    input  logic [AXI4_AR_len-1:0]      Master_AXI_arlen,   // number of transfer per burst
    input  logic [2:0]                   Master_AXI_arsize,  // number of bytes within the transfer
    input  logic [1:0]                   Master_AXI_arburst,  // burst type
    input  logic [1:0]                   Master_AXI_arlock,  // lock type
    input  logic [3:0]                   Master_AXI_arcache, // optional signal for connecting to different types of memories
    input  logic [2:0]                   Master_AXI_arprot,  // identifies the level of protection
    input  logic [3:0]                   Master_AXI_arqos,   // for priority transactions
    input  logic [3:0]                   Master_AXI_arregion, // AXI4 region signal
    input  logic                         Master_AXI_arvalid, // Address read valid signal
    
    // Slave 0 (M00) Ports
    output logic [Masters_ID_Size-1:0]  M00_AXI_araddr_ID,
    output logic [Address_width-1:0]    M00_AXI_araddr,
    output logic [AXI4_AR_len-1:0]      M00_AXI_arlen,
    output logic [2:0]                  M00_AXI_arsize,
    output logic [1:0]                  M00_AXI_arburst,
    output logic [1:0]                  M00_AXI_arlock,
    output logic [3:0]                  M00_AXI_arcache,
    output logic [2:0]                  M00_AXI_arprot,
    output logic [3:0]                  M00_AXI_arregion,
    output logic [3:0]                  M00_AXI_arqos,
    output logic                        M00_AXI_arvalid,
    input  logic                        M00_AXI_arready,

    // Slave 1 (M01) Ports
    output logic [Masters_ID_Size-1:0]  M01_AXI_araddr_ID,
    output logic [Address_width-1:0]    M01_AXI_araddr,
    output logic [AXI4_AR_len-1:0]      M01_AXI_arlen,
    output logic [2:0]                  M01_AXI_arsize,
    output logic [1:0]                  M01_AXI_arburst,
    output logic [1:0]                  M01_AXI_arlock,
    output logic [3:0]                  M01_AXI_arcache,
    output logic [2:0]                  M01_AXI_arprot,
    output logic [3:0]                  M01_AXI_arregion,
    output logic [3:0]                  M01_AXI_arqos,
    output logic                        M01_AXI_arvalid,
    input  logic                        M01_AXI_arready,

    // Slave 2 (M02) Ports
    output logic [Masters_ID_Size-1:0]  M02_AXI_araddr_ID,
    output logic [Address_width-1:0]    M02_AXI_araddr,
    output logic [AXI4_AR_len-1:0]      M02_AXI_arlen,
    output logic [2:0]                  M02_AXI_arsize,
    output logic [1:0]                  M02_AXI_arburst,
    output logic [1:0]                  M02_AXI_arlock,
    output logic [3:0]                  M02_AXI_arcache,
    output logic [2:0]                  M02_AXI_arprot,
    output logic [3:0]                  M02_AXI_arregion,
    output logic [3:0]                  M02_AXI_arqos,
    output logic                        M02_AXI_arvalid,
    input  logic                        M02_AXI_arready,

    // Slave 3 (M03) Ports
    output logic [Masters_ID_Size-1:0]  M03_AXI_araddr_ID,
    output logic [Address_width-1:0]    M03_AXI_araddr,
    output logic [AXI4_AR_len-1:0]      M03_AXI_arlen,
    output logic [2:0]                  M03_AXI_arsize,
    output logic [1:0]                  M03_AXI_arburst,
    output logic [1:0]                  M03_AXI_arlock,
    output logic [3:0]                  M03_AXI_arcache,
    output logic [2:0]                  M03_AXI_arprot,
    output logic [3:0]                  M03_AXI_arregion,
    output logic [3:0]                  M03_AXI_arqos,
    output logic                        M03_AXI_arvalid,
    input  logic                        M03_AXI_arready,

    // Outputs
    output logic                        Sel_Slave_Ready,
    output logic [Num_Of_Slaves - 1 : 0] Q_Enables
);

    //==========================================================================
    // Base Address Definitions
    //==========================================================================
    localparam logic [1:0] Slave0_Base_Addr = 2'b00,
                           Slave1_Base_Addr = 2'b01,
                           Slave2_Base_Addr = 2'b10,
                           Slave3_Base_Addr = 2'b11;

    // Extract base address from MSBs of ARADDR
    logic [Base_Addr_Width - 1 : 0] Base_Addr_Master;
    assign Base_Addr_Master = Master_AXI_araddr[Address_width-1:Address_width-Base_Addr_Width];
    
    // Debug: print address decoding
    always_comb begin
        if (Master_AXI_arvalid) begin
            $display("[%0t] READ_DEC: addr=0x%08h base_addr=%02b -> Slave%0d", $time, Master_AXI_araddr, Base_Addr_Master, Base_Addr_Master);
        end
    end

    //==========================================================================
    // Address Decoding Logic
    // Routes AR channel signals to the correct Slave based on Base-Addr
    //==========================================================================
    always_comb begin
        // Default values - all slaves inactive and all signals set to default
        // Slave 0 (M00) defaults
        M00_AXI_arvalid = 1'b0;
        M00_AXI_araddr_ID = '0;
        M00_AXI_araddr = '0;
        M00_AXI_arlen = '0;
        M00_AXI_arsize = 3'h0;
        M00_AXI_arburst = 2'h0;
        M00_AXI_arlock = 2'h0;
        M00_AXI_arcache = 4'h0;
        M00_AXI_arprot = 3'h0;
        M00_AXI_arregion = 4'h0;
        M00_AXI_arqos = 4'h0;
        
        // Slave 1 (M01) defaults
        M01_AXI_arvalid = 1'b0;
        M01_AXI_araddr_ID = '0;
        M01_AXI_araddr = '0;
        M01_AXI_arlen = '0;
        M01_AXI_arsize = 3'h0;
        M01_AXI_arburst = 2'h0;
        M01_AXI_arlock = 2'h0;
        M01_AXI_arcache = 4'h0;
        M01_AXI_arprot = 3'h0;
        M01_AXI_arregion = 4'h0;
        M01_AXI_arqos = 4'h0;
        
        // Slave 2 (M02) defaults
        M02_AXI_arvalid = 1'b0;
        M02_AXI_araddr_ID = '0;
        M02_AXI_araddr = '0;
        M02_AXI_arlen = '0;
        M02_AXI_arsize = 3'h0;
        M02_AXI_arburst = 2'h0;
        M02_AXI_arlock = 2'h0;
        M02_AXI_arcache = 4'h0;
        M02_AXI_arprot = 3'h0;
        M02_AXI_arregion = 4'h0;
        M02_AXI_arqos = 4'h0;
        
        // Slave 3 (M03) defaults
        M03_AXI_arvalid = 1'b0;
        M03_AXI_araddr_ID = '0;
        M03_AXI_araddr = '0;
        M03_AXI_arlen = '0;
        M03_AXI_arsize = 3'h0;
        M03_AXI_arburst = 2'h0;
        M03_AXI_arlock = 2'h0;
        M03_AXI_arcache = 4'h0;
        M03_AXI_arprot = 3'h0;
        M03_AXI_arregion = 4'h0;
        M03_AXI_arqos = 4'h0;
        
        Q_Enables = 4'b0000;

        case (Base_Addr_Master)
            Slave0_Base_Addr: begin
                // Route to Slave 0 (M00)
                Q_Enables = 4'b0001;
                Sel_Slave_Ready = M00_AXI_arready;
                
                M00_AXI_araddr_ID  = Master_AXI_araddr_ID;
                M00_AXI_araddr    = Master_AXI_araddr;
                M00_AXI_arlen     = Master_AXI_arlen;
                M00_AXI_arsize    = Master_AXI_arsize;
                M00_AXI_arburst   = Master_AXI_arburst;
                M00_AXI_arlock    = Master_AXI_arlock;
                M00_AXI_arcache   = Master_AXI_arcache;
                M00_AXI_arprot    = Master_AXI_arprot;
                M00_AXI_arregion  = Master_AXI_arregion;
                M00_AXI_arqos     = Master_AXI_arqos;
                M00_AXI_arvalid   = Master_AXI_arvalid;
            end

            Slave1_Base_Addr: begin
                // Route to Slave 1 (M01)
                Q_Enables = 4'b0010;
                Sel_Slave_Ready = M01_AXI_arready;
                
                M01_AXI_araddr_ID  = Master_AXI_araddr_ID;
                M01_AXI_araddr    = Master_AXI_araddr;
                M01_AXI_arlen     = Master_AXI_arlen;
                M01_AXI_arsize    = Master_AXI_arsize;
                M01_AXI_arburst   = Master_AXI_arburst;
                M01_AXI_arlock    = Master_AXI_arlock;
                M01_AXI_arcache   = Master_AXI_arcache;
                M01_AXI_arprot    = Master_AXI_arprot;
                M01_AXI_arregion  = Master_AXI_arregion;
                M01_AXI_arqos     = Master_AXI_arqos;
                M01_AXI_arvalid   = Master_AXI_arvalid;
                
                // Ensure other slaves are inactive
                M00_AXI_arvalid   = 1'b0;
                M02_AXI_arvalid   = 1'b0;
                M03_AXI_arvalid   = 1'b0;
            end

            Slave2_Base_Addr: begin
                // Route to Slave 2 (M02)
                Q_Enables = 4'b0100;
                Sel_Slave_Ready = M02_AXI_arready;
                
                M02_AXI_araddr_ID  = Master_AXI_araddr_ID;
                M02_AXI_araddr    = Master_AXI_araddr;
                M02_AXI_arlen     = Master_AXI_arlen;
                M02_AXI_arsize    = Master_AXI_arsize;
                M02_AXI_arburst   = Master_AXI_arburst;
                M02_AXI_arlock    = Master_AXI_arlock;
                M02_AXI_arcache   = Master_AXI_arcache;
                M02_AXI_arprot    = Master_AXI_arprot;
                M02_AXI_arregion  = Master_AXI_arregion;
                M02_AXI_arqos     = Master_AXI_arqos;
                M02_AXI_arvalid   = Master_AXI_arvalid;
                
                // Ensure other slaves are inactive
                M00_AXI_arvalid   = 1'b0;
                M01_AXI_arvalid   = 1'b0;
                M03_AXI_arvalid   = 1'b0;
            end

            Slave3_Base_Addr: begin
                // Route to Slave 3 (M03)
                Q_Enables = 4'b1000;
                Sel_Slave_Ready = M03_AXI_arready;
                
                M03_AXI_araddr_ID  = Master_AXI_araddr_ID;
                M03_AXI_araddr    = Master_AXI_araddr;
                M03_AXI_arlen     = Master_AXI_arlen;
                M03_AXI_arsize    = Master_AXI_arsize;
                M03_AXI_arburst   = Master_AXI_arburst;
                M03_AXI_arlock    = Master_AXI_arlock;
                M03_AXI_arcache   = Master_AXI_arcache;
                M03_AXI_arprot    = Master_AXI_arprot;
                M03_AXI_arregion  = Master_AXI_arregion;
                M03_AXI_arqos     = Master_AXI_arqos;
                M03_AXI_arvalid   = Master_AXI_arvalid;
                
                // Ensure other slaves are inactive
                M00_AXI_arvalid   = 1'b0;
                M01_AXI_arvalid   = 1'b0;
                M02_AXI_arvalid   = 1'b0;
            end

            default: begin
                // Default to Slave 0 for invalid addresses
                Q_Enables = 4'b0001;
                M00_AXI_arvalid = Master_AXI_arvalid;
            end
        endcase
    end

endmodule
