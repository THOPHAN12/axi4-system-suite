
module AW_Channel_Controller_Top #(
    parameter Masters_Num='d2,Slaves_ID_Size=$clog2(Masters_Num),Address_width='d32,
              S00_Aw_len='d8,//!AXI4 - 8 bits for burst length
              S01_Aw_len='d8,//!AXI4 - 8 bits for burst length
              Is_Master_AXI_4='b1, //!All interfaces use AXI4
              AXI4_Aw_len='d8,
              M00_Aw_len='d8,
              M01_Aw_len='d8,
              // Added by Mahmoud
              Num_Of_Slaves = 2

) (
 output logic                      AW_Access_Grant,
 output logic [Slaves_ID_Size-1:0] AW_Selected_Slave,
 input logic                      Queue_Is_Full,
 output logic                      Token,
 output logic [(AXI4_Aw_len/'d2)-1:0] Rem, //Reminder of the divsion
 output logic [(AXI4_Aw_len/'d2)-1:0] Num_Of_Compl_Bursts, // Number of Complete Bursts
 output logic                         Load_The_Original_Signals,
    // Interconnect Ports
    input logic                          ACLK,
    input logic                          ARESETN,
    // Slave S00 Ports
    // Slave General Ports
    input logic                          S00_ACLK,
    input logic                          S00_ARESETN,

    //* Address Write Channel
    input logic  [Address_width-1:0]     S00_AXI_awaddr,// the write address
    input logic  [S00_Aw_len-1:0]        S00_AXI_awlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input logic  [2:0]                   S00_AXI_awsize,//number of bytes within the transfer
    input logic  [1:0]                   S00_AXI_awburst, // burst type
    input logic  [1:0]                   S00_AXI_awlock , // lock type
    input logic  [3:0]                   S00_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input logic  [2:0]                   S00_AXI_awprot ,// identifies the level of protection
    input logic  [3:0]                   S00_AXI_awqos  , // for priority transactions
    input logic                          S00_AXI_awvalid, // Address write valid signal 
    output logic                          S00_AXI_awready, // Address write ready signal 

    // Slave S01 Ports
    // Slave General Ports
    input logic                          S01_ACLK,
    input logic                          S01_ARESETN,
    //* Address Write Channel
    input logic  [Address_width-1:0]     S01_AXI_awaddr,// the write address
    input logic  [S01_Aw_len-1:0]        S01_AXI_awlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input logic  [2:0]                   S01_AXI_awsize,//number of bytes within the transfer
    input logic  [1:0]                   S01_AXI_awburst, // burst type
    input logic  [1:0]                   S01_AXI_awlock , // lock type
    input logic  [3:0]                   S01_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input logic  [2:0]                   S01_AXI_awprot ,// identifies the level of protection
    input logic  [3:0]                   S01_AXI_awqos  , // for priority transactions
    input logic                          S01_AXI_awvalid, // Address write valid signal 
    output logic                          S01_AXI_awready, // Address write ready signal 

    // Master M00 Ports
    // Slave General Ports
    input logic                          M00_ACLK,
    input logic                          M00_ARESETN,

    //* Address Write Channel      
    output logic [Slaves_ID_Size-1:0]     M00_AXI_awaddr_ID,
    output logic [Address_width-1:0]      M00_AXI_awaddr,
    output logic [M00_Aw_len-1:0]         M00_AXI_awlen ,
    output logic [2:0]                    M00_AXI_awsize,  //number of bytes within the transfer
    output logic [1:0]                    M00_AXI_awburst,// burst type
    output logic [1:0]                    M00_AXI_awlock ,// lock type
    output logic [3:0]                    M00_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output logic [2:0]                    M00_AXI_awprot ,// identifies the level of protection
    output logic                          M00_AXI_awvalid,// Address write valid signal 
    output logic [3:0]                    M00_AXI_awqos  ,  // ? ADD THIS
    input logic                          M00_AXI_awready,// Address write ready signal 
    
                  /****** Master M01 Ports *****/ // Added by mahmoud  

                  /*****************************/
    //* Slave General Ports
    input logic                          M01_ACLK,
    input logic                          M01_ARESETN,

    //* Address Write Channel  
    output logic [Slaves_ID_Size-1:0]     M01_AXI_awaddr_ID,
    output logic [Address_width-1:0]      M01_AXI_awaddr,
    output logic [M01_Aw_len-1:0]         M01_AXI_awlen ,
    output logic [2:0]                    M01_AXI_awsize,  //number of bytes within the transfer
    output logic [1:0]                    M01_AXI_awburst,// burst type
    output logic [1:0]                    M01_AXI_awlock ,// lock type
    output logic [3:0]                    M01_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output logic [2:0]                    M01_AXI_awprot ,// identifies the level of protection
    output logic                          M01_AXI_awvalid,// Address write valid signal 
    output logic [3:0]                    M01_AXI_awqos  ,  // ? ADD THIS
    input logic                          M01_AXI_awready,// Address write ready signal 

    //Q Enables....... Added by Mahmoud

    output logic [Num_Of_Slaves - 1 : 0]   Q_Enable_W_Data

);

logic AW_HandShake_Done;
logic AW_Channel_Request;
logic Sel_S_AXI_awvalid ;// Address write valid signal  
// M00_AXI_awqos_Signal removed - awqos is now driven by Write_Addr_Channel_Dec
logic req;
logic Channel_Req_burst;

logic [Address_width-1:0]      AXI4_Sel_S_AXI_awaddr;
logic [AXI4_Aw_len-1:0]        AXI4_Sel_S_AXI_awlen;
logic [2:0]                    AXI4_Sel_S_AXI_awsize;
logic [1:0]                    AXI4_Sel_S_AXI_awburst;
logic [1:0]                    AXI4_Sel_S_AXI_awlock ;
logic [3:0]                    AXI4_Sel_S_AXI_awcache;
logic [2:0]                    AXI4_Sel_S_AXI_awprot ;
logic [3:0]                    AXI4_Sel_S_AXI_awqos  ;
logic AXI4_Sel_S_AXI_awvalid;
logic Disconnect_Master;

// Signal declarations
logic [Address_width-1:0]  M00_AXI_awaddr_Signal;  
logic [2:0]                M00_AXI_awsize_Signal;  
logic [M00_Aw_len-1:0]     M00_AXI_awlen_Signal;   
logic [1 : 0]              M00_AXI_awburst_Signal; 
logic Sel_S_AXI_awvalid_Signal; 
logic [1 : 0]              M00_AXI_awlock_Signal; 
logic [3 : 0]              M00_AXI_awcache_Signal;
logic [2 : 0]              M00_AXI_awprot_Signal; 
  logic Sel_Slave_Ready_Signal;
  logic Master_Valid_Flag;
  logic AW_IS_Done;
  
  // Unused wires for M02 and M03 (read-only masters, no write channels)
  logic [$clog2(Masters_Num)-1:0] M02_AXI_awaddr_ID_unused;
  logic [Address_width-1:0]   M02_AXI_awaddr_unused;
  logic [AXI4_Aw_len-1:0]     M02_AXI_awlen_unused;
  logic [2:0]                 M02_AXI_awsize_unused;
  logic [1:0]                 M02_AXI_awburst_unused;
  logic [1:0]                 M02_AXI_awlock_unused;
  logic [3:0]                 M02_AXI_awcache_unused;
  logic [2:0]                 M02_AXI_awprot_unused;
  logic [3:0]                 M02_AXI_awqos_unused;
  logic M02_AXI_awvalid_unused;
  logic [$clog2(Masters_Num)-1:0] M03_AXI_awaddr_ID_unused;
  logic [Address_width-1:0]   M03_AXI_awaddr_unused;
  logic [AXI4_Aw_len-1:0]     M03_AXI_awlen_unused;
  logic [2:0]                 M03_AXI_awsize_unused;
  logic [1:0]                 M03_AXI_awburst_unused;
  logic [1:0]                 M03_AXI_awlock_unused;
  logic [3:0]                 M03_AXI_awcache_unused;
  logic [2:0]                 M03_AXI_awprot_unused;
  logic [3:0]                 M03_AXI_awqos_unused;
  logic M03_AXI_awvalid_unused;

// Address Write Channel Mangers and MUXs
Qos_Arbiter #(
    .Slaves_Num     (Masters_Num     )
)
u_Qos_Arbiter(
	.ACLK            (ACLK            ),
    .ARESETN         (ARESETN         ),
    .S00_AXI_awvalid (S00_AXI_awvalid ),
    .S00_AXI_awqos   (S00_AXI_awqos   ),
    .S01_AXI_awvalid (S01_AXI_awvalid ),
    .S01_AXI_awqos   (S01_AXI_awqos   ),
    .Channel_Granted (AW_HandShake_Done ),
    .Token           (Token),
    .Channel_Request (AW_Channel_Request ),
    .Selected_Slave  (AW_Selected_Slave  )
);

assign req = Channel_Req_burst | AW_Channel_Request;

Faling_Edge_Detc u_Faling_Edge_Detc(
    .ACLK        (ACLK        ),
    .ARESETN     (ARESETN     ),
    .Test_Singal (AW_HandShake_Done ),
    .Falling     (AW_Access_Grant     )
);

Raising_Edge_Det u_Raising_Edge_Det(
    .ACLK        (ACLK        ),
    .ARESETN     (ARESETN     ),
    .Test_Singal (AW_HandShake_Done ),
    .Raisung     (AW_IS_Done     )
);

AW_HandShake_Checker u_Address_Write_HandShake_Checker(
    .ACLK           (ACLK           ),
    .ARESETN        (ARESETN        ),
    .Valid_Signal   (Sel_S_AXI_awvalid_Signal   ),
    .Ready_Signal   (Sel_Slave_Ready_Signal   ), //TODO
    .Channel_Request(req),
    .HandShake_Done (AW_HandShake_Done )
);

Demux_1_2 u_Demux_Address_Write_Ready(
    .Selection_Line (AW_Selected_Slave ),
    .Input_1        (Sel_Slave_Ready_Signal & (~Disconnect_Master)        ),
    .Output_1       (S00_AXI_awready       ),
    .Output_2       (S01_AXI_awready       )
);

AW_MUX_2_1 u_AW_MUX_2_1(
    .Selected_Slave   (AW_Selected_Slave   ),

    .S00_AXI_awaddr    (S00_AXI_awaddr    ),
    .S00_AXI_awlen     (S00_AXI_awlen     ),
    .S00_AXI_awsize    (S00_AXI_awsize    ),
    .S00_AXI_awburst   (S00_AXI_awburst   ),
    .S00_AXI_awlock    (S00_AXI_awlock    ),
    .S00_AXI_awcache   (S00_AXI_awcache   ),
    .S00_AXI_awprot    (S00_AXI_awprot    ),
    .S00_AXI_awqos     (S00_AXI_awqos     ),
    .S00_AXI_awvalid   (S00_AXI_awvalid   ),
    
    .S01_AXI_awaddr    (S01_AXI_awaddr    ),
    .S01_AXI_awlen     (S01_AXI_awlen     ),
    .S01_AXI_awsize    (S01_AXI_awsize    ),
    .S01_AXI_awburst   (S01_AXI_awburst   ),
    .S01_AXI_awlock    (S01_AXI_awlock    ),
    .S01_AXI_awcache   (S01_AXI_awcache   ),
    .S01_AXI_awprot    (S01_AXI_awprot    ),
    .S01_AXI_awqos     (S01_AXI_awqos     ),
    .S01_AXI_awvalid   (S01_AXI_awvalid   ),
    .Sel_S_AXI_awaddr  (AXI4_Sel_S_AXI_awaddr  ),
    .Sel_S_AXI_awlen   (AXI4_Sel_S_AXI_awlen   ),
    .Sel_S_AXI_awsize  (AXI4_Sel_S_AXI_awsize  ),
    .Sel_S_AXI_awburst (AXI4_Sel_S_AXI_awburst ),
    .Sel_S_AXI_awlock  ( AXI4_Sel_S_AXI_awlock ),
    .Sel_S_AXI_awcache ( AXI4_Sel_S_AXI_awcache),
    .Sel_S_AXI_awprot  ( AXI4_Sel_S_AXI_awprot ),
    .Sel_S_AXI_awqos   (AXI4_Sel_S_AXI_awqos   ),
    .Sel_S_AXI_awvalid (AXI4_Sel_S_AXI_awvalid )
);

// Write Address Channel Decoder
// Note: M00_AXI_awqos and M01_AXI_awqos are driven by Write_Addr_Channel_Dec, not assigned here
Write_Addr_Channel_Dec #(
    .Num_OF_Masters   (Masters_Num   ),
    .Address_width    (Address_width    ),
    .AXI4_Aw_len      (AXI4_Aw_len      ),
    .Num_Of_Slaves    (Num_Of_Slaves    )
)
u_Write_Addr_Channel_Dec(
    .Master_AXI_awaddr_ID (AW_Selected_Slave ),
    .Master_AXI_awaddr    (M00_AXI_awaddr_Signal    ),
    .Master_AXI_awlen     (M00_AXI_awlen_Signal     ),
    .Master_AXI_awsize    (M00_AXI_awsize_Signal    ),
    .Master_AXI_awburst   (M00_AXI_awburst_Signal   ),
    .Master_AXI_awlock    (M00_AXI_awlock_Signal    ),
    .Master_AXI_awcache   (M00_AXI_awcache_Signal   ),
    .Master_AXI_awprot    (M00_AXI_awprot_Signal    ),
    .Master_AXI_awqos     (AXI4_Sel_S_AXI_awqos     ),
    .Master_AXI_awvalid   (Sel_S_AXI_awvalid_Signal   ),

    .M00_AXI_awaddr_ID    (M00_AXI_awaddr_ID    ),
    .M00_AXI_awaddr       (M00_AXI_awaddr       ),
    .M00_AXI_awlen        (M00_AXI_awlen        ),
    .M00_AXI_awsize       (M00_AXI_awsize       ),
    .M00_AXI_awburst      (M00_AXI_awburst      ),
    .M00_AXI_awlock       (M00_AXI_awlock       ),
    .M00_AXI_awcache      (M00_AXI_awcache      ),
    .M00_AXI_awprot       (M00_AXI_awprot       ),
    .M00_AXI_awqos        (M00_AXI_awqos        ),
    .M00_AXI_awvalid      (M00_AXI_awvalid      ),
    .M00_AXI_awready      (M00_AXI_awready      ),
    .M01_AXI_awaddr_ID    (M01_AXI_awaddr_ID    ),
    .M01_AXI_awaddr       (M01_AXI_awaddr       ),
    .M01_AXI_awlen        (M01_AXI_awlen        ),
    .M01_AXI_awsize       (M01_AXI_awsize       ),
    .M01_AXI_awburst      (M01_AXI_awburst      ),
    .M01_AXI_awlock       (M01_AXI_awlock       ),
    .M01_AXI_awcache      (M01_AXI_awcache      ),
    .M01_AXI_awprot       (M01_AXI_awprot       ),
    .M01_AXI_awqos        (M01_AXI_awqos        ),
    .M01_AXI_awvalid      (M01_AXI_awvalid      ),
    .M01_AXI_awready      (M01_AXI_awready      ),
    // M02 and M03 are read-only masters, connect to unused wires
    .M02_AXI_awaddr_ID    (M02_AXI_awaddr_ID_unused    ),
    .M02_AXI_awaddr       (M02_AXI_awaddr_unused       ),
    .M02_AXI_awlen        (M02_AXI_awlen_unused        ),
    .M02_AXI_awsize       (M02_AXI_awsize_unused       ),
    .M02_AXI_awburst      (M02_AXI_awburst_unused      ),
    .M02_AXI_awlock       (M02_AXI_awlock_unused       ),
    .M02_AXI_awcache      (M02_AXI_awcache_unused      ),
    .M02_AXI_awprot       (M02_AXI_awprot_unused       ),
    .M02_AXI_awqos        (M02_AXI_awqos_unused        ),
    .M02_AXI_awvalid      (M02_AXI_awvalid_unused      ),
    .M02_AXI_awready      (1'b0                        ),
    .M03_AXI_awaddr_ID    (M03_AXI_awaddr_ID_unused    ),
    .M03_AXI_awaddr       (M03_AXI_awaddr_unused       ),
    .M03_AXI_awlen        (M03_AXI_awlen_unused        ),
    .M03_AXI_awsize       (M03_AXI_awsize_unused       ),
    .M03_AXI_awburst      (M03_AXI_awburst_unused      ),
    .M03_AXI_awlock       (M03_AXI_awlock_unused       ),
    .M03_AXI_awcache      (M03_AXI_awcache_unused      ),
    .M03_AXI_awprot       (M03_AXI_awprot_unused       ),
    .M03_AXI_awqos        (M03_AXI_awqos_unused        ),
    .M03_AXI_awvalid      (M03_AXI_awvalid_unused      ),
    .M03_AXI_awready      (1'b0                        ),
    .Sel_Slave_Ready      (Sel_Slave_Ready_Signal      ),
    .Q_Enables            (Q_Enable_W_Data            )
);

// Direct AXI4 connection - no conversion needed
assign M00_AXI_awaddr_Signal  = AXI4_Sel_S_AXI_awaddr;
assign M00_AXI_awlen_Signal   = AXI4_Sel_S_AXI_awlen;
assign M00_AXI_awsize_Signal  = AXI4_Sel_S_AXI_awsize;
assign M00_AXI_awburst_Signal = AXI4_Sel_S_AXI_awburst;
assign M00_AXI_awlock_Signal  = AXI4_Sel_S_AXI_awlock;
assign M00_AXI_awcache_Signal = AXI4_Sel_S_AXI_awcache;
assign M00_AXI_awprot_Signal  = AXI4_Sel_S_AXI_awprot;
assign Sel_S_AXI_awvalid_Signal = AXI4_Sel_S_AXI_awvalid;

// AXI4 signals that don't need conversion
assign Rem = {(AXI4_Aw_len/'d2){1'b0}};  // Explicit width to avoid truncation warning
assign Num_Of_Compl_Bursts = {(AXI4_Aw_len/'d2){1'b0}};  // Explicit width to avoid truncation warning
assign Disconnect_Master = 1'b0;
assign Load_The_Original_Signals = 1'b1;
assign Token = 1'b1;
assign Channel_Req_burst = 1'b1;

endmodule
