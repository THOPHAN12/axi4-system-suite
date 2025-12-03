////////////////////////////////////////////////////////////////////////////////
// Module Name: AR_Channel_Controller_Top
// Description: Top-level controller for AXI Read Address Channel
//              Handles arbitration, address decoding, and routing
//              Similar to AW_Channel_Controller_Top but for Read channel
//
// Architecture:
//   Master (S00/S01) → Arbiter → MUX → Decoder → Slave (M00/M01/M02/M03)
//
// Components:
//   - Read_Arbiter: QoS-based arbitration between masters
//   - MUX: Select master signals
//   - Read_Addr_Channel_Dec: Decode address and route to correct slave
//   - Handshake checker: Ensure AXI protocol compliance
////////////////////////////////////////////////////////////////////////////////

module AR_Channel_Controller_Top #(
    parameter Masters_Num='d2,
    parameter Slaves_ID_Size=$clog2(Masters_Num),
    parameter Address_width='d32,
    parameter S00_AR_len='d8,
    parameter S01_AR_len='d8,
    parameter M00_AR_len='d8,
    parameter M01_AR_len='d8,
    parameter M02_AR_len='d8,
    parameter M03_AR_len='d8,
    parameter AXI4_AR_len='d8,
    parameter Num_Of_Slaves = 4
) (
    // Outputs
    output wire                      AR_Access_Grant,
    output wire [Slaves_ID_Size-1:0] AR_Selected_Slave,
    output wire                      AR_Channel_Request,
    
    // Clock and Reset
    input  wire                      ACLK,
    input  wire                      ARESETN,
    
    // Master 0 (S00) Ports
    input  wire                          S00_ACLK,
    input  wire                          S00_ARESETN,
    input  wire  [Address_width-1:0]     S00_AXI_araddr,
    input  wire  [S00_AR_len-1:0]        S00_AXI_arlen,
    input  wire  [2:0]                   S00_AXI_arsize,
    input  wire  [1:0]                   S00_AXI_arburst,
    input  wire  [1:0]                   S00_AXI_arlock,
    input  wire  [3:0]                   S00_AXI_arcache,
    input  wire  [2:0]                   S00_AXI_arprot,
    input  wire  [3:0]                   S00_AXI_arqos,
    input  wire  [3:0]                   S00_AXI_arregion,
    input  wire                          S00_AXI_arvalid,
    output wire                          S00_AXI_arready,
    
    // Master 1 (S01) Ports
    input  wire                          S01_ACLK,
    input  wire                          S01_ARESETN,
    input  wire  [Address_width-1:0]     S01_AXI_araddr,
    input  wire  [S01_AR_len-1:0]        S01_AXI_arlen,
    input  wire  [2:0]                   S01_AXI_arsize,
    input  wire  [1:0]                   S01_AXI_arburst,
    input  wire  [1:0]                   S01_AXI_arlock,
    input  wire  [3:0]                   S01_AXI_arcache,
    input  wire  [2:0]                   S01_AXI_arprot,
    input  wire  [3:0]                   S01_AXI_arqos,
    input  wire  [3:0]                   S01_AXI_arregion,
    input  wire                          S01_AXI_arvalid,
    output wire                          S01_AXI_arready,
    
    // Slave 0 (M00) Ports
    input  wire                          M00_ACLK,
    input  wire                          M00_ARESETN,
    output wire [Slaves_ID_Size-1:0]     M00_AXI_araddr_ID,
    output wire [Address_width-1:0]      M00_AXI_araddr,
    output wire [M00_AR_len-1:0]         M00_AXI_arlen,
    output wire [2:0]                    M00_AXI_arsize,
    output wire [1:0]                    M00_AXI_arburst,
    output wire [1:0]                    M00_AXI_arlock,
    output wire [3:0]                    M00_AXI_arcache,
    output wire [2:0]                    M00_AXI_arprot,
    output wire [3:0]                    M00_AXI_arregion,
    output wire [3:0]                    M00_AXI_arqos,
    output wire                          M00_AXI_arvalid,
    input  wire                          M00_AXI_arready,
    
    // Slave 1 (M01) Ports
    input  wire                          M01_ACLK,
    input  wire                          M01_ARESETN,
    output wire [Slaves_ID_Size-1:0]     M01_AXI_araddr_ID,
    output wire [Address_width-1:0]      M01_AXI_araddr,
    output wire [M01_AR_len-1:0]         M01_AXI_arlen,
    output wire [2:0]                    M01_AXI_arsize,
    output wire [1:0]                    M01_AXI_arburst,
    output wire [1:0]                    M01_AXI_arlock,
    output wire [3:0]                    M01_AXI_arcache,
    output wire [2:0]                    M01_AXI_arprot,
    output wire [3:0]                    M01_AXI_arregion,
    output wire [3:0]                    M01_AXI_arqos,
    output wire                          M01_AXI_arvalid,
    input  wire                          M01_AXI_arready,
    
    // Slave 2 (M02) Ports
    input  wire                          M02_ACLK,
    input  wire                          M02_ARESETN,
    output wire [Slaves_ID_Size-1:0]     M02_AXI_araddr_ID,
    output wire [Address_width-1:0]      M02_AXI_araddr,
    output wire [M02_AR_len-1:0]         M02_AXI_arlen,
    output wire [2:0]                    M02_AXI_arsize,
    output wire [1:0]                    M02_AXI_arburst,
    output wire [1:0]                    M02_AXI_arlock,
    output wire [3:0]                    M02_AXI_arcache,
    output wire [2:0]                    M02_AXI_arprot,
    output wire [3:0]                    M02_AXI_arregion,
    output wire [3:0]                    M02_AXI_arqos,
    output wire                          M02_AXI_arvalid,
    input  wire                          M02_AXI_arready,
    
    // Slave 3 (M03) Ports
    input  wire                          M03_ACLK,
    input  wire                          M03_ARESETN,
    output wire [Slaves_ID_Size-1:0]     M03_AXI_araddr_ID,
    output wire [Address_width-1:0]      M03_AXI_araddr,
    output wire [M03_AR_len-1:0]         M03_AXI_arlen,
    output wire [2:0]                    M03_AXI_arsize,
    output wire [1:0]                    M03_AXI_arburst,
    output wire [1:0]                    M03_AXI_arlock,
    output wire [3:0]                    M03_AXI_arcache,
    output wire [2:0]                    M03_AXI_arprot,
    output wire [3:0]                    M03_AXI_arregion,
    output wire [3:0]                    M03_AXI_arqos,
    output wire                          M03_AXI_arvalid,
    input  wire                          M03_AXI_arready
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    wire AR_HandShake_Done;
    wire Token;
    wire [Address_width-1:0]      Sel_Master_araddr;
    wire [AXI4_AR_len-1:0]       Sel_Master_arlen;
    wire [2:0]                    Sel_Master_arsize;
    wire [1:0]                    Sel_Master_arburst;
    wire [1:0]                    Sel_Master_arlock;
    wire [3:0]                    Sel_Master_arcache;
    wire [2:0]                    Sel_Master_arprot;
    wire [3:0]                    Sel_Master_arqos;
    wire [3:0]                    Sel_Master_arregion;
    wire                         Sel_Master_arvalid;
    wire                         Sel_Slave_Ready;
    
    //==========================================================================
    // Read Arbiter - Select which Master to process
    //==========================================================================
    Read_Arbiter #(
        .Masters_Num     (Masters_Num     )
    )
    u_Read_Arbiter(
        .ACLK            (ACLK            ),
        .ARESETN         (ARESETN         ),
        .S00_AXI_arvalid (S00_AXI_arvalid ),
        .S00_AXI_arqos   (S00_AXI_arqos   ),
        .S01_AXI_arvalid (S01_AXI_arvalid ),
        .S01_AXI_arqos   (S01_AXI_arqos   ),
        .Channel_Granted (AR_HandShake_Done ),
        .Token           (Token           ),
        .Channel_Request (AR_Channel_Request ),
        .Selected_Master (AR_Selected_Slave )  // Note: Named Selected_Slave for consistency
    );

    //==========================================================================
    // Master MUX - Select signals from chosen master
    //==========================================================================
    // Using Mux_2x1 for each signal
    Mux_2x1 #(.width(Address_width-1)) araddr_mux (
        .in1        (S00_AXI_araddr),
        .in2        (S01_AXI_araddr),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_araddr)
    );
    
    Mux_2x1 #(.width(AXI4_AR_len-1)) arlen_mux (
        .in1        (S00_AXI_arlen[AXI4_AR_len-1:0]),
        .in2        (S01_AXI_arlen[AXI4_AR_len-1:0]),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arlen)
    );
    
    Mux_2x1 #(.width(2)) arsize_mux (
        .in1        (S00_AXI_arsize),
        .in2        (S01_AXI_arsize),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arsize)
    );
    
    Mux_2x1 #(.width(1)) arburst_mux (
        .in1        (S00_AXI_arburst),
        .in2        (S01_AXI_arburst),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arburst)
    );
    
    Mux_2x1 #(.width(1)) arlock_mux (
        .in1        (S00_AXI_arlock),
        .in2        (S01_AXI_arlock),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arlock)
    );
    
    Mux_2x1 #(.width(3)) arcache_mux (
        .in1        (S00_AXI_arcache),
        .in2        (S01_AXI_arcache),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arcache)
    );
    
    Mux_2x1 #(.width(2)) arprot_mux (
        .in1        (S00_AXI_arprot),
        .in2        (S01_AXI_arprot),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arprot)
    );
    
    Mux_2x1 #(.width(3)) arqos_mux (
        .in1        (S00_AXI_arqos),
        .in2        (S01_AXI_arqos),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arqos)
    );
    
    Mux_2x1 #(.width(3)) arregion_mux (
        .in1        (S00_AXI_arregion),
        .in2        (S01_AXI_arregion),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arregion)
    );
    
    Mux_2x1 #(.width(0)) arvalid_mux (
        .in1        (S00_AXI_arvalid),
        .in2        (S01_AXI_arvalid),
        .sel        (AR_Selected_Slave),
        .out        (Sel_Master_arvalid)
    );

    //==========================================================================
    // Read Address Decoder - Decode address and route to correct Slave
    //==========================================================================
    Read_Addr_Channel_Dec #(
        .Num_OF_Masters   (Masters_Num   ),
        .Address_width    (Address_width ),
        .AXI4_AR_len      (AXI4_AR_len   ),
        .Num_Of_Slaves    (Num_Of_Slaves )
    )
    u_Read_Addr_Channel_Dec(
        .Master_AXI_araddr_ID (AR_Selected_Slave ),
        .Master_AXI_araddr    (Sel_Master_araddr ),
        .Master_AXI_arlen     (Sel_Master_arlen  ),
        .Master_AXI_arsize    (Sel_Master_arsize ),
        .Master_AXI_arburst   (Sel_Master_arburst),
        .Master_AXI_arlock    (Sel_Master_arlock ),
        .Master_AXI_arcache   (Sel_Master_arcache),
        .Master_AXI_arprot    (Sel_Master_arprot ),
        .Master_AXI_arregion  (Sel_Master_arregion),
        .Master_AXI_arqos     (Sel_Master_arqos  ),
        .Master_AXI_arvalid   (Sel_Master_arvalid),
        
        // Slave 0 (M00)
        .M00_AXI_araddr_ID    (M00_AXI_araddr_ID ),
        .M00_AXI_araddr       (M00_AXI_araddr    ),
        .M00_AXI_arlen        (M00_AXI_arlen    ),
        .M00_AXI_arsize       (M00_AXI_arsize    ),
        .M00_AXI_arburst      (M00_AXI_arburst   ),
        .M00_AXI_arlock       (M00_AXI_arlock    ),
        .M00_AXI_arcache      (M00_AXI_arcache   ),
        .M00_AXI_arprot       (M00_AXI_arprot    ),
        .M00_AXI_arregion     (M00_AXI_arregion  ),
        .M00_AXI_arqos        (M00_AXI_arqos     ),
        .M00_AXI_arvalid      (M00_AXI_arvalid   ),
        .M00_AXI_arready      (M00_AXI_arready   ),
        
        // Slave 1 (M01)
        .M01_AXI_araddr_ID    (M01_AXI_araddr_ID ),
        .M01_AXI_araddr       (M01_AXI_araddr    ),
        .M01_AXI_arlen        (M01_AXI_arlen     ),
        .M01_AXI_arsize       (M01_AXI_arsize    ),
        .M01_AXI_arburst      (M01_AXI_arburst   ),
        .M01_AXI_arlock       (M01_AXI_arlock    ),
        .M01_AXI_arcache      (M01_AXI_arcache   ),
        .M01_AXI_arprot       (M01_AXI_arprot    ),
        .M01_AXI_arregion     (M01_AXI_arregion  ),
        .M01_AXI_arqos        (M01_AXI_arqos     ),
        .M01_AXI_arvalid      (M01_AXI_arvalid   ),
        .M01_AXI_arready      (M01_AXI_arready   ),
        
        // Slave 2 (M02)
        .M02_AXI_araddr_ID    (M02_AXI_araddr_ID ),
        .M02_AXI_araddr       (M02_AXI_araddr    ),
        .M02_AXI_arlen        (M02_AXI_arlen     ),
        .M02_AXI_arsize       (M02_AXI_arsize    ),
        .M02_AXI_arburst      (M02_AXI_arburst   ),
        .M02_AXI_arlock       (M02_AXI_arlock    ),
        .M02_AXI_arcache      (M02_AXI_arcache   ),
        .M02_AXI_arprot       (M02_AXI_arprot    ),
        .M02_AXI_arregion     (M02_AXI_arregion  ),
        .M02_AXI_arqos        (M02_AXI_arqos     ),
        .M02_AXI_arvalid      (M02_AXI_arvalid   ),
        .M02_AXI_arready      (M02_AXI_arready   ),
        
        // Slave 3 (M03)
        .M03_AXI_araddr_ID    (M03_AXI_araddr_ID ),
        .M03_AXI_araddr       (M03_AXI_araddr    ),
        .M03_AXI_arlen        (M03_AXI_arlen     ),
        .M03_AXI_arsize       (M03_AXI_arsize    ),
        .M03_AXI_arburst      (M03_AXI_arburst   ),
        .M03_AXI_arlock       (M03_AXI_arlock    ),
        .M03_AXI_arcache      (M03_AXI_arcache   ),
        .M03_AXI_arprot       (M03_AXI_arprot    ),
        .M03_AXI_arregion     (M03_AXI_arregion  ),
        .M03_AXI_arqos        (M03_AXI_arqos     ),
        .M03_AXI_arvalid      (M03_AXI_arvalid   ),
        .M03_AXI_arready      (M03_AXI_arready   ),
        
        .Sel_Slave_Ready      (Sel_Slave_Ready  ),
        .Q_Enables            ()  // Not used for Read channel
    );

    //==========================================================================
    // Handshake Checker - Ensure AXI protocol compliance
    //==========================================================================
    AW_HandShake_Checker u_AR_HandShake_Checker(
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .Valid_Signal   (Sel_Master_arvalid   ),
        .Ready_Signal   (Sel_Slave_Ready   ),
        .Channel_Request(AR_Channel_Request),
        .HandShake_Done (AR_HandShake_Done )
    );

    //==========================================================================
    // Demux ARREADY - Route ready signal back to correct Master
    //==========================================================================
    Demux_1_2 u_Demux_Address_Read_Ready(
        .Selection_Line (AR_Selected_Slave ),
        .Input_1        (Sel_Slave_Ready ),
        .Output_1       (S00_AXI_arready ),
        .Output_2       (S01_AXI_arready )
    );

    //==========================================================================
    // Edge Detection for Access Grant
    //==========================================================================
    wire AR_IS_Done;
    Raising_Edge_Det u_Raising_Edge_Det(
        .ACLK        (ACLK        ),
        .ARESETN     (ARESETN     ),
        .Test_Singal (AR_HandShake_Done ),
        .Raisung     (AR_IS_Done     )
    );

    Faling_Edge_Detc u_Faling_Edge_Detc(
        .ACLK        (ACLK        ),
        .ARESETN     (ARESETN     ),
        .Test_Singal (AR_HandShake_Done ),
        .Falling     (AR_Access_Grant     )
    );

    // Token assignment (simplified - no split transactions for now)
    assign Token = 1'b0;

endmodule

