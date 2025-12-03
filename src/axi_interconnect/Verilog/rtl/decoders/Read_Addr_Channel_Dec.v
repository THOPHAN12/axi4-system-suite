////////////////////////////////////////////////////////////////////////////////
// Module Name: Read_Addr_Channel_Dec
// Description: Address Decoder for AXI Read Address Channel
//              Decodes Base-Addr from ARADDR to route to correct Slave
//              Supports 4 Slaves (M00, M01, M02, M03)
//
// Address Mapping:
//   - Base-Addr = ARADDR[31:30] (2 MSBs for 4 Slaves)
//   - Slave0_Base_Addr = 2'b00 → Route to M00
//   - Slave1_Base_Addr = 2'b01 → Route to M01
//   - Slave2_Base_Addr = 2'b10 → Route to M02
//   - Slave3_Base_Addr = 2'b11 → Route to M03
//
// Parameters:
//   - Num_OF_Masters: Number of masters (default: 2)
//   - Masters_ID_Size: Bit width for master ID
//   - Address_width: AXI address width (default: 32)
//   - AXI4_AR_len: AXI4 ARLEN width (default: 8)
//   - Num_Of_Slaves: Number of slaves (default: 4)
//   - Base_Addr_Width: Bit width for base address decoding
////////////////////////////////////////////////////////////////////////////////

module Read_Addr_Channel_Dec #(
    parameter  Num_OF_Masters='d2,
    parameter  Masters_ID_Size=$clog2(Num_OF_Masters),
    parameter  Address_width='d32,
    parameter  AXI4_AR_len='d8,
    parameter  Num_Of_Slaves = 4,
    parameter  Base_Addr_Width = $clog2(Num_Of_Slaves)
) (
    // Ports of the selected master from the arbiter
    input  wire  [Masters_ID_Size-1:0]   Master_AXI_araddr_ID,
    input  wire  [Address_width-1:0]      Master_AXI_araddr,  // the read address
    input  wire  [AXI4_AR_len-1:0]       Master_AXI_arlen,   // number of transfer per burst
    input  wire  [2:0]                   Master_AXI_arsize,  // number of bytes within the transfer
    input  wire  [1:0]                   Master_AXI_arburst,  // burst type
    input  wire  [1:0]                   Master_AXI_arlock,  // lock type
    input  wire  [3:0]                   Master_AXI_arcache, // optional signal for connecting to different types of memories
    input  wire  [2:0]                   Master_AXI_arprot,  // identifies the level of protection
    input  wire  [3:0]                   Master_AXI_arqos,   // for priority transactions
    input  wire  [3:0]                   Master_AXI_arregion, // AXI4 region signal
    input  wire                          Master_AXI_arvalid, // Address read valid signal
    
    // Slave 0 (M00) Ports
    output reg   [Masters_ID_Size-1:0]   M00_AXI_araddr_ID,
    output reg  [Address_width-1:0]      M00_AXI_araddr,
    output reg  [AXI4_AR_len-1:0]        M00_AXI_arlen,
    output reg  [2:0]                    M00_AXI_arsize,
    output reg  [1:0]                    M00_AXI_arburst,
    output reg  [1:0]                    M00_AXI_arlock,
    output reg  [3:0]                    M00_AXI_arcache,
    output reg  [2:0]                    M00_AXI_arprot,
    output reg  [3:0]                    M00_AXI_arregion,
    output reg  [3:0]                    M00_AXI_arqos,
    output reg                           M00_AXI_arvalid,
    input  wire                          M00_AXI_arready,

    // Slave 1 (M01) Ports
    output reg   [Masters_ID_Size-1:0]   M01_AXI_araddr_ID,
    output reg  [Address_width-1:0]      M01_AXI_araddr,
    output reg  [AXI4_AR_len-1:0]        M01_AXI_arlen,
    output reg  [2:0]                    M01_AXI_arsize,
    output reg  [1:0]                    M01_AXI_arburst,
    output reg  [1:0]                    M01_AXI_arlock,
    output reg  [3:0]                    M01_AXI_arcache,
    output reg  [2:0]                    M01_AXI_arprot,
    output reg  [3:0]                    M01_AXI_arregion,
    output reg  [3:0]                    M01_AXI_arqos,
    output reg                           M01_AXI_arvalid,
    input  wire                          M01_AXI_arready,

    // Slave 2 (M02) Ports
    output reg   [Masters_ID_Size-1:0]   M02_AXI_araddr_ID,
    output reg  [Address_width-1:0]      M02_AXI_araddr,
    output reg  [AXI4_AR_len-1:0]        M02_AXI_arlen,
    output reg  [2:0]                    M02_AXI_arsize,
    output reg  [1:0]                    M02_AXI_arburst,
    output reg  [1:0]                    M02_AXI_arlock,
    output reg  [3:0]                    M02_AXI_arcache,
    output reg  [2:0]                    M02_AXI_arprot,
    output reg  [3:0]                    M02_AXI_arregion,
    output reg  [3:0]                    M02_AXI_arqos,
    output reg                           M02_AXI_arvalid,
    input  wire                          M02_AXI_arready,

    // Slave 3 (M03) Ports
    output reg   [Masters_ID_Size-1:0]   M03_AXI_araddr_ID,
    output reg  [Address_width-1:0]      M03_AXI_araddr,
    output reg  [AXI4_AR_len-1:0]        M03_AXI_arlen,
    output reg  [2:0]                    M03_AXI_arsize,
    output reg  [1:0]                    M03_AXI_arburst,
    output reg  [1:0]                    M03_AXI_arlock,
    output reg  [3:0]                    M03_AXI_arcache,
    output reg  [2:0]                    M03_AXI_arprot,
    output reg  [3:0]                    M03_AXI_arregion,
    output reg  [3:0]                    M03_AXI_arqos,
    output reg                           M03_AXI_arvalid,
    input  wire                          M03_AXI_arready,

    // Outputs
    output reg                           Sel_Slave_Ready,
    output reg [Num_Of_Slaves - 1 : 0]   Q_Enables
);

    //==========================================================================
    // Base Address Definitions
    //==========================================================================
    localparam Slave0_Base_Addr = 2'b00,
               Slave1_Base_Addr = 2'b01,
               Slave2_Base_Addr = 2'b10,
               Slave3_Base_Addr = 2'b11;

    // Extract base address from MSBs of ARADDR
    wire [Base_Addr_Width - 1 : 0] Base_Addr_Master;
    assign Base_Addr_Master = Master_AXI_araddr[Address_width-1:Address_width-Base_Addr_Width];
    
    // Debug: print address decoding
    always @(*) begin
        if (Master_AXI_arvalid) begin
            $display("[%0t] READ_DEC: addr=0x%08h base_addr=%02b -> Slave%0d", $time, Master_AXI_araddr, Base_Addr_Master, Base_Addr_Master);
        end
    end

    //==========================================================================
    // Address Decoding Logic
    // Routes AR channel signals to the correct Slave based on Base-Addr
    //==========================================================================
    always @(*) begin
        // Default values - all slaves inactive and all signals set to default
        // Slave 0 (M00) defaults
        M00_AXI_arvalid = 1'b0;
        M00_AXI_araddr_ID = {Masters_ID_Size{1'b0}};
        M00_AXI_araddr = {Address_width{1'b0}};
        M00_AXI_arlen = {AXI4_AR_len{1'b0}};
        M00_AXI_arsize = 3'h0;
        M00_AXI_arburst = 2'h0;
        M00_AXI_arlock = 2'h0;
        M00_AXI_arcache = 4'h0;
        M00_AXI_arprot = 3'h0;
        M00_AXI_arregion = 4'h0;
        M00_AXI_arqos = 4'h0;
        
        // Slave 1 (M01) defaults
        M01_AXI_arvalid = 1'b0;
        M01_AXI_araddr_ID = {Masters_ID_Size{1'b0}};
        M01_AXI_araddr = {Address_width{1'b0}};
        M01_AXI_arlen = {AXI4_AR_len{1'b0}};
        M01_AXI_arsize = 3'h0;
        M01_AXI_arburst = 2'h0;
        M01_AXI_arlock = 2'h0;
        M01_AXI_arcache = 4'h0;
        M01_AXI_arprot = 3'h0;
        M01_AXI_arregion = 4'h0;
        M01_AXI_arqos = 4'h0;
        
        // Slave 2 (M02) defaults
        M02_AXI_arvalid = 1'b0;
        M02_AXI_araddr_ID = {Masters_ID_Size{1'b0}};
        M02_AXI_araddr = {Address_width{1'b0}};
        M02_AXI_arlen = {AXI4_AR_len{1'b0}};
        M02_AXI_arsize = 3'h0;
        M02_AXI_arburst = 2'h0;
        M02_AXI_arlock = 2'h0;
        M02_AXI_arcache = 4'h0;
        M02_AXI_arprot = 3'h0;
        M02_AXI_arregion = 4'h0;
        M02_AXI_arqos = 4'h0;
        
        // Slave 3 (M03) defaults
        M03_AXI_arvalid = 1'b0;
        M03_AXI_araddr_ID = {Masters_ID_Size{1'b0}};
        M03_AXI_araddr = {Address_width{1'b0}};
        M03_AXI_arlen = {AXI4_AR_len{1'b0}};
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

