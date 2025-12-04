module AXI_Interconnect_Full #(
    parameter Masters_Num='d2,Slaves_ID_Size=$clog2(Masters_Num),Address_width='d32,
              S00_Aw_len='d8,//!AXI4 - 8 bits for burst length
              S00_Write_data_bus_width='d32,S00_Write_data_bytes_num=S00_Write_data_bus_width/8,
              S00_AR_len='d8, //!AXI4 - 8 bits for burst length
              S00_Read_data_bus_width='d32,
              S01_Aw_len='d8,//!AXI4 - 8 bits for burst length
              S01_AR_len='d8, //!AXI4 - 8 bits for burst length
              S01_Write_data_bus_width='d32,

              AXI4_Aw_len='d8,

              M00_Aw_len='d8,//!AXI4 - 8 bits for burst length
              M00_Write_data_bus_width='d32,M00_Write_data_bytes_num=M00_Write_data_bus_width/8,
              M00_AR_len='d8, //!AXI4 - 8 bits for burst length
              M00_Read_data_bus_width='d32,
              
              M01_Aw_len='d8,//!AXI4 - 8 bits for burst length
              M01_AR_len='d8, //!AXI4 - 8 bits for burst length

              // Added for M02, M03 support
              M02_Aw_len='d8,//!AXI4 - 8 bits for burst length
              M02_Write_data_bus_width='d32,
              M02_Write_data_bytes_num=M02_Write_data_bus_width/8,
              M02_AR_len='d8, //!AXI4 - 8 bits for burst length
              M02_Read_data_bus_width='d32,
              M03_Aw_len='d8,//!AXI4 - 8 bits for burst length
              M03_Write_data_bus_width='d32,
              M03_Write_data_bytes_num=M03_Write_data_bus_width/8,
              M03_AR_len='d8, //!AXI4 - 8 bits for burst length
              M03_Read_data_bus_width='d32,

              Is_Master_AXI_4='b1, //!All interfaces use AXI4

              // Added by Mahmoud
              M1_ID='d0,
              M2_ID='d1,
              Resp_ID_width   = 'd2,
              Num_Of_Masters  = 'd2,
              Num_Of_Slaves   = 'd4,  // Updated: Support 4 slaves
              Master_ID_Width = $clog2(Num_Of_Masters),
              AXI4_AR_len='d8,

              // ====== Arbitration Mode Parameter ======
              // Added: Configurable arbitration for 2 masters
              ARBITRATION_MODE = 1  // 0=FIXED_PRIORITY, 1=ROUND_ROBIN, 2=QOS_BASED



) (
//                /****** Slave S01 Ports *******/
//                    /******************************/
//* Slave General Ports
    input  wire                          S01_ACLK,
    input  wire                          S01_ARESETN,
//* Address Write Channel
    input  wire  [Address_width-1:0]     S01_AXI_awaddr,// the write address
    input  wire  [S01_Aw_len-1:0]        S01_AXI_awlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input  wire  [2:0]                   S01_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   S01_AXI_awburst, // burst type
    input  wire  [1:0]                   S01_AXI_awlock , // lock type
    input  wire  [3:0]                   S01_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S01_AXI_awprot ,// identifies the level of protection
    input  wire  [3:0]                   S01_AXI_awqos  , // for priority transactions
    input  wire                          S01_AXI_awvalid, // Address write valid signal 
    output wire                          S01_AXI_awready, // Address write ready signal 

//* Write Data Channel
    
    input  wire  [S00_Write_data_bus_width-1:0]   S01_AXI_wdata,//Write data bus
    input  wire  [S00_Write_data_bytes_num-1:0]   S01_AXI_wstrb, // strops identifes the active data lines
    input  wire                                   S01_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                   S01_AXI_wvalid, // write valid signal
    output wire                                   S01_AXI_wready, // write ready signal

//*Write Response Channel
    output wire  [1:0]                   S01_AXI_bresp,//Write response
    output wire                          S01_AXI_bvalid, //Write response valid signal
    input  wire                          S01_AXI_bready, //Write response ready signal

//*Address Read Channel
    input  wire  [Address_width-1:0]     S01_AXI_araddr,// the write address
    input  wire  [S01_AR_len-1:0]        S01_AXI_arlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input  wire  [2:0]                   S01_AXI_arsize,//number of bytes within the transfer
    input  wire  [1:0]                   S01_AXI_arburst, // burst type
    input  wire  [1:0]                   S01_AXI_arlock , // lock type
    input  wire  [3:0]                   S01_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S01_AXI_arprot ,// identifies the level of protection
    input  wire  [3:0]                   S01_AXI_arregion, // AXI4 region signal
    input  wire  [3:0]                   S01_AXI_arqos  , // for priority transactions
    input  wire                          S01_AXI_arvalid, // Address write valid signal 
    output wire                          S01_AXI_arready, // Address write ready signal 
    
//*Read Data Channel
    output wire  [S00_Read_data_bus_width-1:0]  S01_AXI_rdata,//Read Data Bus
    output wire  [1:0]                          S01_AXI_rresp, // Read Response
    output wire                                 S01_AXI_rlast, // Read Last Signal
    output wire                                 S01_AXI_rvalid, // Read Valid Signal 
    input  wire                                 S01_AXI_rready, // Read Ready Signal
//                /***** Interconnect Ports *****/
//                    /******************************/
    input  wire                          ACLK,
    input  wire                          ARESETN,
                
//                /****** Slave S00 Ports *******/
//                    /******************************/
//* Slave General Ports
    input  wire                          S00_ACLK,
    input  wire                          S00_ARESETN,

//* Address Write Channel
    input  wire  [Address_width-1:0]     S00_AXI_awaddr,// the write address
    input  wire  [S00_Aw_len-1:0]        S00_AXI_awlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input  wire  [2:0]                   S00_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   S00_AXI_awburst, // burst type
    input  wire  [1:0]                   S00_AXI_awlock , // lock type
    input  wire  [3:0]                   S00_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S00_AXI_awprot ,// identifies the level of protection
    input  wire  [3:0]                   S00_AXI_awqos  , // for priority transactions
    input  wire                          S00_AXI_awvalid, // Address write valid signal 
    output wire                          S00_AXI_awready, // Address write ready signal 

//* Write Data Channel
    
    input  wire  [S00_Write_data_bus_width-1:0]   S00_AXI_wdata,//Write data bus
    input  wire  [S00_Write_data_bytes_num-1:0]   S00_AXI_wstrb, // strops identifes the active data lines
    input  wire                                   S00_AXI_wlast, // last signal to identify the last transfer in a burst
    input  wire                                   S00_AXI_wvalid, // write valid signal
    output wire                                   S00_AXI_wready, // write ready signal

//*Write Response Channel
    output wire  [1:0]                   S00_AXI_bresp,//Write response
    output wire                          S00_AXI_bvalid, //Write response valid signal
    input  wire                          S00_AXI_bready, //Write response ready signal

//*Address Read Channel
    input  wire  [Address_width-1:0]     S00_AXI_araddr,// the write address
    input  wire  [S00_AR_len-1:0]        S00_AXI_arlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input  wire  [2:0]                   S00_AXI_arsize,//number of bytes within the transfer
    input  wire  [1:0]                   S00_AXI_arburst, // burst type
    input  wire  [1:0]                   S00_AXI_arlock , // lock type
    input  wire  [3:0]                   S00_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   S00_AXI_arprot ,// identifies the level of protection
    input  wire  [3:0]                   S00_AXI_arregion, // AXI4 region signal
    input  wire  [3:0]                   S00_AXI_arqos  , // for priority transactions
    input  wire                          S00_AXI_arvalid, // Address write valid signal 
    output wire                          S00_AXI_arready, // Address write ready signal 
    
//*Read Data Channel
    output wire  [S00_Read_data_bus_width-1:0]  S00_AXI_rdata,//Read Data Bus
    output wire  [1:0]                          S00_AXI_rresp, // Read Response
    output wire                                 S00_AXI_rlast, // Read Last Signal
    output wire                                 S00_AXI_rvalid, // Read Valid Signal 
    input  wire                                 S00_AXI_rready, // Read Ready Signal



//                /****** Master M00 Ports *****/   
//                  /*****************************/
//* Slave General Ports
    input  wire                          M00_ACLK,
    input  wire                          M00_ARESETN,

//* Address Write Channel              
    output wire [Slaves_ID_Size-1:0]     M00_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M00_AXI_awaddr,
    output wire [M00_Aw_len-1:0]         M00_AXI_awlen ,
    output wire [2:0]                    M00_AXI_awsize,  //number of bytes within the transfer
    output wire [1:0]                    M00_AXI_awburst,// burst type
    output wire [1:0]                    M00_AXI_awlock ,// lock type
    output wire [3:0]                    M00_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output wire [2:0]                    M00_AXI_awprot ,// identifies the level of protection
    output wire [3:0]                    M00_AXI_awqos  , // for priority transactions
    output wire                          M00_AXI_awvalid,// Address write valid signal 
    input  wire                          M00_AXI_awready,// Address write ready signal 
    
//* Write Data Channel
    output wire  [M00_Write_data_bus_width-1:0]   M00_AXI_wdata,//Write data bus
    output wire  [M00_Write_data_bytes_num-1:0]   M00_AXI_wstrb, // strops identifes the active data lines
    output wire                                   M00_AXI_wlast, // last signal to identify the last transfer in a burst
    output wire                                   M00_AXI_wvalid, // write valid signal
    input  wire                                   M00_AXI_wready, // write ready signal

//*Write Response Channel
    input  wire [Master_ID_Width-1:0]     M00_AXI_BID  ,
    input  wire [1:0]                    M00_AXI_bresp,//Write response
    input  wire                          M00_AXI_bvalid, //Write response valid signal
    output wire                          M00_AXI_bready, //Write response ready signal

//*Address Read Channel
    output wire  [Address_width-1:0]     M00_AXI_araddr,// the write address
    output wire  [M00_AR_len-1:0]        M00_AXI_arlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    output wire  [2:0]                   M00_AXI_arsize,//number of bytes within the transfer
    output wire  [1:0]                   M00_AXI_arburst, // burst type
    output wire  [1:0]                   M00_AXI_arlock , // lock type
    output wire  [3:0]                   M00_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    output wire  [2:0]                   M00_AXI_arprot ,// identifies the level of protection
    output wire  [3:0]                   M00_AXI_arregion, // AXI4 region signal
    output wire  [3:0]                   M00_AXI_arqos  , // for priority transactions
    output wire                          M00_AXI_arvalid, // Address write valid signal 
    input  wire                          M00_AXI_arready, // Address write ready signal 

//*Read Data Channel
    input  wire  [M00_Read_data_bus_width-1:0]  M00_AXI_rdata,//Read Data Bus
    input  wire  [1:0]                          M00_AXI_rresp, // Read Response
    input  wire                                 M00_AXI_rlast, // Read Last Signal
    input  wire                                 M00_AXI_rvalid, // Read Valid Signal 
    output wire                                 M00_AXI_rready, // Read Ready Signal

//                /****** Master M01 Ports *****/   
//                  /*****************************/
    //* Slave General Ports
    input  wire                          M01_ACLK,
    input  wire                          M01_ARESETN,

    //* Address Write Channel              
     output wire [Slaves_ID_Size-1:0]    M01_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M01_AXI_awaddr,
    output wire [M01_Aw_len-1:0]         M01_AXI_awlen ,
    output wire [2:0]                    M01_AXI_awsize,  //number of bytes within the transfer
    output wire [1:0]                    M01_AXI_awburst,// burst type
    output wire [1:0]                    M01_AXI_awlock ,// lock type
    output wire [3:0]                    M01_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output wire [2:0]                    M01_AXI_awprot ,// identifies the level of protection
    output wire [3:0]                    M01_AXI_awqos  , // for priority transactions
    output wire                          M01_AXI_awvalid,// Address write valid signal 
    input  wire                          M01_AXI_awready,// Address write ready signal 

    //* Write Data Channel
    output wire  [M00_Write_data_bus_width-1:0]   M01_AXI_wdata,//Write data bus
    output wire  [M00_Write_data_bytes_num-1:0]   M01_AXI_wstrb, // strops identifes the active data lines
    output wire                                   M01_AXI_wlast, // last signal to identify the last transfer in a burst
    output wire                                   M01_AXI_wvalid, // write valid signal
    input  wire                                   M01_AXI_wready, // write ready signal

    //*Write Response Channel
    input  wire [Master_ID_Width-1:0]     M01_AXI_BID  ,
    input  wire [1:0]                    M01_AXI_bresp,//Write response
    input  wire                          M01_AXI_bvalid, //Write response valid signal
    output wire                          M01_AXI_bready, //Write response ready signal

    //*Address Read Channel
    output wire  [Address_width-1:0]     M01_AXI_araddr,// the write address
    output wire  [M01_AR_len-1:0]        M01_AXI_arlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    output wire  [2:0]                   M01_AXI_arsize,//number of bytes within the transfer
    output wire  [1:0]                   M01_AXI_arburst, // burst type
    output wire  [1:0]                   M01_AXI_arlock , // lock type
    output wire  [3:0]                   M01_AXI_arcache, // a opptional signal for connecting to diffrent types of  memories
    output wire  [2:0]                   M01_AXI_arprot ,// identifies the level of protection
    output wire  [3:0]                   M01_AXI_arregion, // AXI4 region signal
    output wire  [3:0]                   M01_AXI_arqos  , // for priority transactions
    output wire                          M01_AXI_arvalid, // Address write valid signal 
    input  wire                          M01_AXI_arready, // Address write ready signal 

    //*Read Data Channel
    input  wire  [M00_Read_data_bus_width-1:0]  M01_AXI_rdata,//Read Data Bus
    input  wire  [1:0]                          M01_AXI_rresp, // Read Response
    input  wire                                 M01_AXI_rlast, // Read Last Signal
    input  wire                                 M01_AXI_rvalid, // Read Valid Signal 
    output wire                                 M01_AXI_rready, // Read Ready Signal

    // Ports added by Mahmoud
    //input  wire [Master_ID_Width - 1 : 0]       M1_ID, M2_ID



   //!addresses ranges for each slave 
    input [31:0] slave0_addr1,
    input [31:0] slave0_addr2,

    input [31:0] slave1_addr1,
    input [31:0] slave1_addr2,

    input [31:0] slave2_addr1,
    input [31:0] slave2_addr2,

    input [31:0] slave3_addr1,
    input [31:0] slave3_addr2,

//                /****** Master M02 Ports *****/   
//                  /*****************************/
    //* Slave General Ports
    input  wire                          M02_ACLK,
    input  wire                          M02_ARESETN,

    //* Address Write Channel              
    output wire [Slaves_ID_Size-1:0]     M02_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M02_AXI_awaddr,
    output wire [M02_Aw_len-1:0]         M02_AXI_awlen,
    output wire [2:0]                    M02_AXI_awsize,
    output wire [1:0]                    M02_AXI_awburst,
    output wire [1:0]                    M02_AXI_awlock,
    output wire [3:0]                    M02_AXI_awcache,
    output wire [2:0]                    M02_AXI_awprot,
    output wire [3:0]                    M02_AXI_awqos,
    output wire                          M02_AXI_awvalid,
    input  wire                          M02_AXI_awready,

    //* Write Data Channel
    output wire [M02_Write_data_bus_width-1:0]  M02_AXI_wdata,
    output wire [M02_Write_data_bytes_num-1:0]  M02_AXI_wstrb,
    output wire                                  M02_AXI_wlast,
    output wire                                  M02_AXI_wvalid,
    input  wire                                  M02_AXI_wready,

    //* Write Response Channel
    input  wire [Master_ID_Width-1:0]    M02_AXI_BID,
    input  wire [1:0]                    M02_AXI_bresp,
    input  wire                          M02_AXI_bvalid,
    output wire                          M02_AXI_bready,

    //*Address Read Channel
    output wire  [Address_width-1:0]     M02_AXI_araddr,
    output wire  [M02_AR_len-1:0]        M02_AXI_arlen,
    output wire  [2:0]                   M02_AXI_arsize,
    output wire  [1:0]                   M02_AXI_arburst,
    output wire  [1:0]                   M02_AXI_arlock,
    output wire  [3:0]                   M02_AXI_arcache,
    output wire  [2:0]                   M02_AXI_arprot,
    output wire  [3:0]                   M02_AXI_arregion,
    output wire  [3:0]                   M02_AXI_arqos,
    output wire                          M02_AXI_arvalid,
    input  wire                          M02_AXI_arready,

    //*Read Data Channel
    input  wire  [M02_Read_data_bus_width-1:0]  M02_AXI_rdata,
    input  wire  [1:0]                          M02_AXI_rresp,
    input  wire                                 M02_AXI_rlast,
    input  wire                                 M02_AXI_rvalid,
    output wire                                 M02_AXI_rready,

//                /****** Master M03 Ports *****/   
//                  /*****************************/
    //* Slave General Ports
    input  wire                          M03_ACLK,
    input  wire                          M03_ARESETN,

    //* Address Write Channel              
    output wire [Slaves_ID_Size-1:0]     M03_AXI_awaddr_ID,
    output wire [Address_width-1:0]      M03_AXI_awaddr,
    output wire [M03_Aw_len-1:0]         M03_AXI_awlen,
    output wire [2:0]                    M03_AXI_awsize,
    output wire [1:0]                    M03_AXI_awburst,
    output wire [1:0]                    M03_AXI_awlock,
    output wire [3:0]                    M03_AXI_awcache,
    output wire [2:0]                    M03_AXI_awprot,
    output wire [3:0]                    M03_AXI_awqos,
    output wire                          M03_AXI_awvalid,
    input  wire                          M03_AXI_awready,

    //* Write Data Channel
    output wire [M03_Write_data_bus_width-1:0]  M03_AXI_wdata,
    output wire [M03_Write_data_bytes_num-1:0]  M03_AXI_wstrb,
    output wire                                  M03_AXI_wlast,
    output wire                                  M03_AXI_wvalid,
    input  wire                                  M03_AXI_wready,

    //* Write Response Channel
    input  wire [Master_ID_Width-1:0]    M03_AXI_BID,
    input  wire [1:0]                    M03_AXI_bresp,
    input  wire                          M03_AXI_bvalid,
    output wire                          M03_AXI_bready,

    //*Address Read Channel
    output wire  [Address_width-1:0]     M03_AXI_araddr,
    output wire  [M03_AR_len-1:0]        M03_AXI_arlen,
    output wire  [2:0]                   M03_AXI_arsize,
    output wire  [1:0]                   M03_AXI_arburst,
    output wire  [1:0]                   M03_AXI_arlock,
    output wire  [3:0]                   M03_AXI_arcache,
    output wire  [2:0]                   M03_AXI_arprot,
    output wire  [3:0]                   M03_AXI_arregion,
    output wire  [3:0]                   M03_AXI_arqos,
    output wire                          M03_AXI_arvalid,
    input  wire                          M03_AXI_arready,

    //*Read Data Channel
    input  wire  [M03_Read_data_bus_width-1:0]  M03_AXI_rdata,
    input  wire  [1:0]                          M03_AXI_rresp,
    input  wire                                 M03_AXI_rlast,
    input  wire                                 M03_AXI_rvalid,
    output wire                                 M03_AXI_rready

);
//------------------- Internal Signals -------------------
//****************Write Channels*********************/
wire AW_Access_Grant;
wire Write_Data_Finsh;
wire [Slaves_ID_Size-1:0] AW_Selected_Slave;
wire [Slaves_ID_Size-1:0] Write_Data_Master;
wire Last_Signal_Data;
wire Queue_Is_Full;
wire Token;
  wire [(S00_Aw_len/'d2)-1:0] Rem; //Reminder of the divsion
  wire [(S00_Aw_len/'d2)-1:0] Num_Of_Compl_Bursts; // Number of Complete Bursts
  wire Is_Master_Part_Of_Split;
  wire Load_The_Original_Signals;
  // Added by mahmoud 
  // Q_Enable_W_Data should match Num_Of_Slaves (4) not Masters_Num (2)
  wire [Num_Of_Slaves - 1 : 0] Q_Enable_W_Data_Signal;
wire Is_Master_Part_Of_Split2,Write_Data_Finsh2,Write_Data_Master2;
// --------------------------------------------------------

//**************** Read Channels*********************/
//select lines for muxs and demuxs coming from controller:
wire             S_addr_wire;
wire [1:0]       M0_data_wire;  // Updated: 2-bit for 4 Slaves
wire [1:0]       M1_data_wire;  // Updated: 2-bit for 4 Slaves
wire             M_addr_wire;

//wires connecting between a mux and a demux:
wire             ARVALID_wire;
wire  [31:0]     ARADDR_wire;
wire  [7:0]      ARLEN_wire;
wire  [2:0]      ARSIZE_wire;
wire  [1:0]      ARBURST_wire;

wire [1:0]       en_S0_wire;
wire [1:0]       en_S1_wire;
wire [1:0]       en_S2_wire;
wire [1:0]       en_S3_wire;

wire             enable_S0_wire;
wire             enable_S1_wire;
wire             enable_S2_wire;
wire             enable_S3_wire;

wire             RREADY_S0_wire;
wire             RREADY_S1_wire;
wire             RREADY_S2_wire;
wire             RREADY_S3_wire;

wire             RREADY_S0_wire_2;
wire             RREADY_S1_wire_2;
wire             RREADY_S2_wire_2;
wire             RREADY_S3_wire_2;
// --------------------------------------------------------

// ============================================================================
// ARBITRATION WIRES AND REGISTERS
// Added: Support for 3 arbitration modes (FIXED, ROUND_ROBIN, QOS)
// ============================================================================
// Round-robin turn registers
reg [1:0] wr_turn;  // Write arbitration turn (0=M0, 1=M1)
reg [1:0] rd_turn;  // Read arbitration turn (0=M0, 1=M1)

// Master request signals
wire m0_write_req = S00_AXI_awvalid && !AW_Access_Grant;
wire m1_write_req = S01_AXI_awvalid && !AW_Access_Grant;
wire m0_read_req = S00_AXI_arvalid;
wire m1_read_req = S01_AXI_arvalid;

// Grant signals (output of arbitration logic)
wire grant_m0_write;
wire grant_m1_write;
wire grant_m0_read;
wire grant_m1_read;
// ============================================================================


//******************** Write Channel Comp ********************//
AW_Channel_Controller_Top #(
    .Masters_Num     (Masters_Num     ),
    .Address_width   (Address_width   ),
    .S00_Aw_len      (S00_Aw_len      ),
    .S01_Aw_len      (S01_Aw_len      ),
    .Is_Master_AXI_4 (Is_Master_AXI_4 ),
    .AXI4_Aw_len     (AXI4_Aw_len     ),
    .M00_Aw_len      (M00_Aw_len      ),
    .M01_Aw_len      (M01_Aw_len      ),
    .Num_Of_Slaves   (Num_Of_Slaves   )
)
u_AW_Channel_Controller_Top(
    .AW_Access_Grant           (AW_Access_Grant           ),
    .AW_Selected_Slave         (AW_Selected_Slave         ),
    .Queue_Is_Full             (Queue_Is_Full             ),
    .Token                     (Token                     ),
    .Rem                       (Rem                       ),
    .Num_Of_Compl_Bursts       (Num_Of_Compl_Bursts       ),
    .Load_The_Original_Signals (Load_The_Original_Signals ),
    .ACLK                      (ACLK                      ),
    .ARESETN                   (ARESETN                   ),
    .S00_ACLK                  (S00_ACLK                  ),
    .S00_ARESETN               (S00_ARESETN               ),
    .S00_AXI_awaddr            (S00_AXI_awaddr            ),
    .S00_AXI_awlen             (S00_AXI_awlen             ),
    .S00_AXI_awsize            (S00_AXI_awsize            ),
    .S00_AXI_awburst           (S00_AXI_awburst           ),
    .S00_AXI_awlock            (S00_AXI_awlock            ),
    .S00_AXI_awcache           (S00_AXI_awcache           ),
    .S00_AXI_awprot            (S00_AXI_awprot            ),
    .S00_AXI_awqos             (S00_AXI_awqos             ),
    .S00_AXI_awvalid           (S00_AXI_awvalid           ),
    .S00_AXI_awready           (S00_AXI_awready           ),
    .S01_ACLK                  (S01_ACLK                  ),
    .S01_ARESETN               (S01_ARESETN               ),
    .S01_AXI_awaddr            (S01_AXI_awaddr            ),
    .S01_AXI_awlen             (S01_AXI_awlen             ),
    .S01_AXI_awsize            (S01_AXI_awsize            ),
    .S01_AXI_awburst           (S01_AXI_awburst           ),
    .S01_AXI_awlock            (S01_AXI_awlock            ),
    .S01_AXI_awcache           (S01_AXI_awcache           ),
    .S01_AXI_awprot            (S01_AXI_awprot            ),
    .S01_AXI_awqos             (S01_AXI_awqos             ),
    .S01_AXI_awvalid           (S01_AXI_awvalid           ),
    .S01_AXI_awready           (S01_AXI_awready           ),
    .M00_ACLK                  (M00_ACLK                  ),
    .M00_ARESETN               (M00_ARESETN               ),
    .M00_AXI_awaddr_ID         (M00_AXI_awaddr_ID         ),
    .M00_AXI_awaddr            (M00_AXI_awaddr            ),
    .M00_AXI_awlen             (M00_AXI_awlen             ),
    .M00_AXI_awsize            (M00_AXI_awsize            ),
    .M00_AXI_awburst           (M00_AXI_awburst           ),
    .M00_AXI_awlock            (M00_AXI_awlock            ),
    .M00_AXI_awcache           (M00_AXI_awcache           ),
    .M00_AXI_awprot            (M00_AXI_awprot            ),
    .M00_AXI_awqos             (M00_AXI_awqos             ),
    .M00_AXI_awvalid           (M00_AXI_awvalid           ),
    .M00_AXI_awready           (M00_AXI_awready           ),
    .M01_ACLK                  (M01_ACLK                  ),
    .M01_ARESETN               (M01_ARESETN               ),
    .M01_AXI_awaddr_ID         (M01_AXI_awaddr_ID         ),
    .M01_AXI_awaddr            (M01_AXI_awaddr            ),
    .M01_AXI_awlen             (M01_AXI_awlen             ),
    .M01_AXI_awsize            (M01_AXI_awsize            ),
    .M01_AXI_awburst           (M01_AXI_awburst           ),
    .M01_AXI_awlock            (M01_AXI_awlock            ),
    .M01_AXI_awcache           (M01_AXI_awcache           ),
    .M01_AXI_awprot            (M01_AXI_awprot            ),
    .M01_AXI_awqos             (M01_AXI_awqos             ),
    .M01_AXI_awvalid           (M01_AXI_awvalid           ),
    .M01_AXI_awready           (M01_AXI_awready           ),
    .Q_Enable_W_Data           (Q_Enable_W_Data_Signal    )
);

/*Data Write Channel Mangers and MUXs*/


WD_Channel_Controller_Top #(
    .Slaves_Num               (Masters_Num               ),
    .Slaves_ID_Size           (Slaves_ID_Size           ),
    .Address_width            (Address_width            ),
    .S00_Write_data_bus_width (S00_Write_data_bus_width ),
    .S01_Write_data_bus_width (S01_Write_data_bus_width ),
    .M00_Write_data_bus_width (M00_Write_data_bus_width ),
    .Num_Of_Slaves            (Num_Of_Slaves            )
)
u_WD_Channel_Controller_Top(
    .AW_Selected_Slave (AW_Selected_Slave ),
    .AW_Access_Grant   (AW_Access_Grant   ),
    .Write_Data_Master (Write_Data_Master ),
    .Write_Data_Master2(Write_Data_Master2),
    .Write_Data_Finsh  (Write_Data_Finsh  ),
    .Write_Data_Finsh2(Write_Data_Finsh2  ),
    
    .Queue_Is_Full     (Queue_Is_Full     ),
    .Is_Master_Part_Of_Split(Is_Master_Part_Of_Split),
    .Is_Master_Part_Of_Split2(Is_Master_Part_Of_Split2),
    .Token             (Token             ),
    .ACLK              (ACLK              ),
    .ARESETN           (ARESETN           ),
    .S00_AXI_wdata     (S00_AXI_wdata     ),
    .S00_AXI_wstrb     (S00_AXI_wstrb     ),
    .S00_AXI_wlast     (S00_AXI_wlast     ),
    .S00_AXI_wvalid    (S00_AXI_wvalid    ),
    .S00_AXI_wready    (S00_AXI_wready    ),
    .S01_AXI_wdata     (S01_AXI_wdata     ),
    .S01_AXI_wstrb     (S01_AXI_wstrb     ),
    .S01_AXI_wlast     (S01_AXI_wlast     ),
    .S01_AXI_wvalid    (S01_AXI_wvalid    ),
    .S01_AXI_wready    (S01_AXI_wready    ),
    .M00_AXI_wdata     (M00_AXI_wdata     ),
    .M00_AXI_wstrb     (M00_AXI_wstrb     ),
    .M00_AXI_wlast     (M00_AXI_wlast     ),
    .M00_AXI_wvalid    (M00_AXI_wvalid    ),
    .M00_AXI_wready    (M00_AXI_wready    ),

    // ------------ Added by Mahmoud --------------------------- 
                 
    .M01_AXI_wdata      (M01_AXI_wdata         ),//Write data bus
    .M01_AXI_wstrb      (M01_AXI_wstrb         ), // strops identifes the active data lines
    .M01_AXI_wlast      (M01_AXI_wlast         ), // last signal to identify the last transfer in a burst
    .M01_AXI_wvalid     (M01_AXI_wvalid        ), // write valid signal
    .M01_AXI_wready     (M01_AXI_wready        ), // write ready signal
    .Q_Enable_W_Data_In (Q_Enable_W_Data_Signal)
);

//Write Responese Channel


BR_Channel_Controller_Top #(
    .Slaves_Num      (Masters_Num      ),
    .AXI4_Aw_len     (AXI4_Aw_len     ),
    .Num_Of_Masters  (Num_Of_Masters  ),
    .Num_Of_Slaves   (Num_Of_Slaves   ),
    .Master_ID_Width (Master_ID_Width ),
    .M1_ID           (M1_ID           ),
    .M2_ID           (M2_ID           )
)
u_BR_Channel_Controller_Top(
    .Write_Data_Master         (Write_Data_Master         ),
    .Write_Data_Finsh          (Write_Data_Finsh          ),
    .Rem                       (Rem                       ),
    .Num_Of_Compl_Bursts       (Num_Of_Compl_Bursts       ),
    .Is_Master_Part_Of_Split   (Is_Master_Part_Of_Split   ),
    .Load_The_Original_Signals (Load_The_Original_Signals ),
    .ACLK                      (ACLK                      ),
    .ARESETN                   (ARESETN                   ),
    .S01_AXI_bresp             (S01_AXI_bresp             ),
    .S01_AXI_bvalid            (S01_AXI_bvalid            ),
    .S01_AXI_bready            (S01_AXI_bready            ),
    .S00_AXI_bresp             (S00_AXI_bresp             ),
    .S00_AXI_bvalid            (S00_AXI_bvalid            ),
    .S00_AXI_bready            (S00_AXI_bready            ),
    .M00_AXI_BID               (M00_AXI_BID               ),
    .M00_AXI_bresp             (M00_AXI_bresp             ),
    .M00_AXI_bvalid            (M00_AXI_bvalid            ),
    .M00_AXI_bready            (M00_AXI_bready            ),
    .M01_AXI_BID               (M01_AXI_BID               ),
    .M01_AXI_bresp             (M01_AXI_bresp             ),
    .M01_AXI_bvalid            (M01_AXI_bvalid            ),
    .M01_AXI_bready            (M01_AXI_bready            )
);

//******************** Read Channel Comp ********************//
//---------------------- Code Start ----------------------

// Internal signals for AR Channel Controller
wire AR_Access_Grant;
wire [Slaves_ID_Size-1:0] AR_Selected_Slave;
wire AR_Channel_Request;

// AR Channel Controller Top - Handles arbitration, decoding, and routing
AR_Channel_Controller_Top #(
    .Masters_Num     (Masters_Num     ),
    .Address_width   (Address_width   ),
    .S00_AR_len      (S00_AR_len      ),
    .S01_AR_len      (S01_AR_len      ),
    .M00_AR_len      (M00_AR_len      ),
    .M01_AR_len      (M01_AR_len      ),
    .M02_AR_len      (M02_AR_len      ),
    .M03_AR_len      (M03_AR_len      ),
    .AXI4_AR_len     (AXI4_AR_len     ),
    .Num_Of_Slaves   (Num_Of_Slaves   )
)
u_AR_Channel_Controller_Top(
    .AR_Access_Grant    (AR_Access_Grant    ),
    .AR_Selected_Slave  (AR_Selected_Slave  ),
    .AR_Channel_Request(AR_Channel_Request ),
    .ACLK               (ACLK               ),
    .ARESETN            (ARESETN            ),
    // Master 0 (S00) ports
    .S00_ACLK           (S00_ACLK           ),
    .S00_ARESETN        (S00_ARESETN        ),
    .S00_AXI_araddr     (S00_AXI_araddr     ),
    .S00_AXI_arlen       (S00_AXI_arlen       ),
    .S00_AXI_arsize     (S00_AXI_arsize     ),
    .S00_AXI_arburst    (S00_AXI_arburst    ),
    .S00_AXI_arlock     (S00_AXI_arlock     ),
    .S00_AXI_arcache    (S00_AXI_arcache    ),
    .S00_AXI_arprot     (S00_AXI_arprot     ),
    .S00_AXI_arqos      (S00_AXI_arqos      ),
    .S00_AXI_arregion   (S00_AXI_arregion   ),
    .S00_AXI_arvalid    (S00_AXI_arvalid    ),
    .S00_AXI_arready    (S00_AXI_arready    ),
    // Master 1 (S01) ports
    .S01_ACLK           (S01_ACLK           ),
    .S01_ARESETN        (S01_ARESETN        ),
    .S01_AXI_araddr     (S01_AXI_araddr     ),
    .S01_AXI_arlen       (S01_AXI_arlen       ),
    .S01_AXI_arsize     (S01_AXI_arsize     ),
    .S01_AXI_arburst    (S01_AXI_arburst    ),
    .S01_AXI_arlock     (S01_AXI_arlock     ),
    .S01_AXI_arcache    (S01_AXI_arcache    ),
    .S01_AXI_arprot     (S01_AXI_arprot     ),
    .S01_AXI_arqos      (S01_AXI_arqos      ),
    .S01_AXI_arregion   (S01_AXI_arregion   ),
    .S01_AXI_arvalid    (S01_AXI_arvalid    ),
    .S01_AXI_arready    (S01_AXI_arready    ),
    // Slave 0 (M00) ports
    .M00_ACLK           (M00_ACLK           ),
    .M00_ARESETN        (M00_ARESETN        ),
    .M00_AXI_araddr_ID   (),  // Not used for Read channel, leave unconnected
    .M00_AXI_araddr      (M00_AXI_araddr      ),
    .M00_AXI_arlen       (M00_AXI_arlen       ),
    .M00_AXI_arsize      (M00_AXI_arsize      ),
    .M00_AXI_arburst     (M00_AXI_arburst     ),
    .M00_AXI_arlock      (M00_AXI_arlock      ),
    .M00_AXI_arcache     (M00_AXI_arcache     ),
    .M00_AXI_arprot      (M00_AXI_arprot      ),
    .M00_AXI_arregion    (M00_AXI_arregion    ),
    .M00_AXI_arqos       (M00_AXI_arqos       ),
    .M00_AXI_arvalid     (M00_AXI_arvalid     ),
    .M00_AXI_arready     (M00_AXI_arready     ),
    // Slave 1 (M01) ports
    .M01_ACLK           (M01_ACLK           ),
    .M01_ARESETN        (M01_ARESETN        ),
    .M01_AXI_araddr_ID   (),  // Not used for Read channel, leave unconnected
    .M01_AXI_araddr      (M01_AXI_araddr      ),
    .M01_AXI_arlen       (M01_AXI_arlen       ),
    .M01_AXI_arsize      (M01_AXI_arsize      ),
    .M01_AXI_arburst     (M01_AXI_arburst     ),
    .M01_AXI_arlock      (M01_AXI_arlock      ),
    .M01_AXI_arcache     (M01_AXI_arcache     ),
    .M01_AXI_arprot      (M01_AXI_arprot      ),
    .M01_AXI_arregion    (M01_AXI_arregion    ),
    .M01_AXI_arqos       (M01_AXI_arqos       ),
    .M01_AXI_arvalid     (M01_AXI_arvalid     ),
    .M01_AXI_arready     (M01_AXI_arready     ),
    // Slave 2 (M02) ports
    .M02_ACLK           (M02_ACLK           ),
    .M02_ARESETN        (M02_ARESETN        ),
    .M02_AXI_araddr_ID   (),  // Not used for Read channel, leave unconnected
    .M02_AXI_araddr      (M02_AXI_araddr      ),
    .M02_AXI_arlen       (M02_AXI_arlen       ),
    .M02_AXI_arsize      (M02_AXI_arsize      ),
    .M02_AXI_arburst     (M02_AXI_arburst     ),
    .M02_AXI_arlock      (M02_AXI_arlock      ),
    .M02_AXI_arcache     (M02_AXI_arcache     ),
    .M02_AXI_arprot      (M02_AXI_arprot      ),
    .M02_AXI_arregion    (M02_AXI_arregion    ),
    .M02_AXI_arqos       (M02_AXI_arqos       ),
    .M02_AXI_arvalid     (M02_AXI_arvalid     ),
    .M02_AXI_arready     (M02_AXI_arready     ),
    // Slave 3 (M03) ports
    .M03_ACLK           (M03_ACLK           ),
    .M03_ARESETN        (M03_ARESETN        ),
    .M03_AXI_araddr_ID   (),  // Not used for Read channel, leave unconnected
    .M03_AXI_araddr      (M03_AXI_araddr      ),
    .M03_AXI_arlen       (M03_AXI_arlen       ),
    .M03_AXI_arsize      (M03_AXI_arsize      ),
    .M03_AXI_arburst     (M03_AXI_arburst     ),
    .M03_AXI_arlock      (M03_AXI_arlock      ),
    .M03_AXI_arcache     (M03_AXI_arcache     ),
    .M03_AXI_arprot      (M03_AXI_arprot      ),
    .M03_AXI_arregion    (M03_AXI_arregion    ),
    .M03_AXI_arqos       (M03_AXI_arqos       ),
    .M03_AXI_arvalid     (M03_AXI_arvalid     ),
    .M03_AXI_arready     (M03_AXI_arready     )
);

// Internal signals for Read Data channel routing
// Note: Using Controller for R channel routing (can be updated later)
// Note: M0_data_wire, M1_data_wire, en_S0_wire, en_S1_wire already declared above (line 341-342, 352-353)

// Mux to select address from active master for Controller
wire [Address_width-1:0] M_ADDR_muxed;
Mux_2x1 #(.width(Address_width-1)) mux_m_addr (
    .in1        (S00_AXI_araddr),
    .in2        (S01_AXI_araddr),
    .sel        (AR_Selected_Slave),
    .out        (M_ADDR_muxed)
);

Controller Read_controller (
    .clkk                          (ACLK),
    .resett                        (ARESETN),
    .slave0_addr1                  (slave0_addr1),
    .slave0_addr2                  (slave0_addr2),
    .slave1_addr1                  (slave1_addr1),
    .slave1_addr2                  (slave1_addr2),
    .slave2_addr1                  (slave2_addr1),
    .slave2_addr2                  (slave2_addr2),
    .slave3_addr1                  (slave3_addr1),
    .slave3_addr2                  (slave3_addr2),
    .M_ADDR                        (M_ADDR_muxed),  // Muxed address from active master
    .S0_ARREADY                    (M00_AXI_arready),
    .S1_ARREADY                    (M01_AXI_arready),
    .S2_ARREADY                    (M02_AXI_arready),
    .S3_ARREADY                    (M03_AXI_arready),
    .M0_ARVALID                    (S00_AXI_arvalid),
    .M1_ARVALID                    (S01_AXI_arvalid),
    .M0_RREADY                     (S00_AXI_rready),
    .M1_RREADY                     (S01_AXI_rready),
    .S0_RVALID                     (M00_AXI_rvalid),
    .S1_RVALID                     (M01_AXI_rvalid),
    .S2_RVALID                     (M02_AXI_rvalid),
    .S3_RVALID                     (M03_AXI_rvalid),
    .S0_RLAST                      (M00_AXI_rlast),
    .S1_RLAST                      (M01_AXI_rlast),
    .S2_RLAST                      (M02_AXI_rlast),
    .S3_RLAST                      (M03_AXI_rlast),
    .select_slave_address          (),  // Not used - AR handled by AR_Channel_Controller
    .select_data_M0                (M0_data_wire),
    .select_data_M1                (M1_data_wire),
    .select_master_address         (),  // Not used - AR handled by AR_Channel_Controller
    .en_S0                         (en_S0_wire),
    .en_S1                         (en_S1_wire),
    .en_S2                         (en_S2_wire),  // ✅ CONNECTED for Slave 2
    .en_S3                         (en_S3_wire)   // ✅ CONNECTED for Slave 3
);

//---------------- Data Channel ---------------------

//------------------ RREADY -------------------------
/*Demux_1x2_en #(.width(0)) rready_demux (
    .in             (S00_AXI_rready),
    .select         (M0_data_wire),
    .enable         (),
    .out1           (M00_AXI_rready),
    .out2           (RREADY_S1)
);
Demux_1x2_en #(.width(0)) rready_demux2 (
    .in             (S01_AXI_rready),
    .select         (M1_data_wire),
    .enable         (),
    .out1           (M00_AXI_rready),
    .out2           (RREADY_S1)
);*/
Demux_1x4 #(.width(0)) rready_demux_M0 (
    .in             (S00_AXI_rready),
    .sel            (M0_data_wire),
    .out0           (RREADY_S0_wire),
    .out1           (RREADY_S1_wire),
    .out2           (RREADY_S2_wire),
    .out3           (RREADY_S3_wire)
);
Demux_1x4 #(.width(0)) rready_demux_M1 (
    .in             (S01_AXI_rready),
    .sel            (M1_data_wire),
    .out0           (RREADY_S0_wire_2),
    .out1           (RREADY_S1_wire_2),
    .out2           (RREADY_S2_wire_2),
    .out3           (RREADY_S3_wire_2)
);

// RREADY routing to Slaves from both Masters
// Slave 0 (M00) - Use LSB of en_S0_wire to select M0 or M1
Mux_2x1 #(.width(0)) rready_mux_M00 (
    .in1        (RREADY_S0_wire),
    .in2        (RREADY_S0_wire_2),
    .sel        (en_S0_wire[0]),  // LSB selects master
    .out        (M00_AXI_rready)
);
// Slave 1 (M01)
Mux_2x1 #(.width(0)) rready_mux_M01 (
    .in1        (RREADY_S1_wire),
    .in2        (RREADY_S1_wire_2),
    .sel        (en_S1_wire[0]),  // LSB selects master
    .out        (M01_AXI_rready)
);
// Slave 2 (M02) - Route to slave based on en_S2
Mux_2x1 #(.width(0)) rready_mux_M02 (
    .in1        (RREADY_S2_wire),
    .in2        (RREADY_S2_wire_2),
    .sel        (en_S2_wire[0]),  // LSB selects master
    .out        (M02_AXI_rready)
);
// Slave 3 (M03)
Mux_2x1 #(.width(0)) rready_mux_M03 (
    .in1        (RREADY_S3_wire),
    .in2        (RREADY_S3_wire_2),
    .sel        (en_S3_wire[0]),  // LSB selects master
    .out        (M03_AXI_rready)
);
/*Mux_2x1_en #(.width(0)) rready_mux (
    .in1        (S00_AXI_rready),
    .in2        (S01_AXI_rready),
    .sel        (en_S0_wire), 
    .enable     (enable_S0_wire),

    .out        (M00_AXI_rready)
);
Mux_2x1_en #(.width(0)) rready_mux2 (
    .in1        (S00_AXI_rready),
    .in2        (S01_AXI_rready),
    .sel        (en_S1_wire), 
    .enable     (enable_S1_wire),

    .out        (RREADY_S1)
);*/
//------------------ RVALID -------------------------
Mux_4x1 #(.width(0)) rvalid_mux_M0 (
    .in0        (M00_AXI_rvalid),
    .in1        (M01_AXI_rvalid),
    .in2        (M02_AXI_rvalid),
    .in3        (M03_AXI_rvalid),
    .sel        (M0_data_wire),  // Now 2-bit: direct connection
    .out        (S00_AXI_rvalid)
);
Mux_4x1 #(.width(0)) rvalid_mux_M1 (
    .in0        (M00_AXI_rvalid),
    .in1        (M01_AXI_rvalid),
    .in2        (M02_AXI_rvalid),
    .in3        (M03_AXI_rvalid),
    .sel        (M1_data_wire),  // Now 2-bit: direct connection
    .out        (S01_AXI_rvalid)
);

//------------------ RDATA -------------------------
Mux_4x1 #(.width(31)) rdata_mux_M0 (
    .in0        (M00_AXI_rdata),
    .in1        (M01_AXI_rdata),
    .in2        (M02_AXI_rdata),
    .in3        (M03_AXI_rdata),
    .sel        (M0_data_wire),  // Now 2-bit: direct connection
    .out        (S00_AXI_rdata)
);
Mux_4x1 #(.width(31)) rdata_mux_M1 (
    .in0        (M00_AXI_rdata),
    .in1        (M01_AXI_rdata),
    .in2        (M02_AXI_rdata),
    .in3        (M03_AXI_rdata),
    .sel        (M1_data_wire),  // Now 2-bit: direct connection
    .out        (S01_AXI_rdata)
);

//------------------ RLAST -------------------------
Mux_4x1 #(.width(0)) rlast_mux_M0 (
    .in0        (M00_AXI_rlast),
    .in1        (M01_AXI_rlast),
    .in2        (M02_AXI_rlast),
    .in3        (M03_AXI_rlast),
    .sel        (M0_data_wire),  // Now 2-bit: direct connection
    .out        (S00_AXI_rlast)
);
Mux_4x1 #(.width(0)) rlast_mux_M1 (
    .in0        (M00_AXI_rlast),
    .in1        (M01_AXI_rlast),
    .in2        (M02_AXI_rlast),
    .in3        (M03_AXI_rlast),
    .sel        (M1_data_wire),  // Now 2-bit: direct connection
    .out        (S01_AXI_rlast)
);

//------------------ RRESP -------------------------
Mux_4x1 #(.width(1)) rresp_mux_M0 (
    .in0        (M00_AXI_rresp),
    .in1        (M01_AXI_rresp),
    .in2        (M02_AXI_rresp),
    .in3        (M03_AXI_rresp),
    .sel        (M0_data_wire),  // Now 2-bit: direct connection
    .out        (S00_AXI_rresp)
);
Mux_4x1 #(.width(1)) rresp_mux_M1 (
    .in0        (M00_AXI_rresp),
    .in1        (M01_AXI_rresp),
    .in2        (M02_AXI_rresp),
    .in3        (M03_AXI_rresp),
    .sel        (M1_data_wire),  // Now 2-bit: direct connection
    .out        (S01_AXI_rresp)
);

// ============================================================================
// WRITE CHANNEL ARBITRATION (3 MODES)
// Added: Configurable arbitration between 2 masters
// ============================================================================
generate
    if (ARBITRATION_MODE == 0) begin : gen_fixed_write
        // MODE 0: FIXED PRIORITY (Master 0 > Master 1)
        assign grant_m0_write = m0_write_req;
        assign grant_m1_write = m1_write_req && !m0_write_req;
        
    end else if (ARBITRATION_MODE == 2) begin : gen_qos_write
        // MODE 2: QOS-BASED (Higher QoS value wins)
        wire m0_higher_qos = (S00_AXI_awqos >= S01_AXI_awqos);
        assign grant_m0_write = m0_write_req && (!m1_write_req || m0_higher_qos);
        assign grant_m1_write = m1_write_req && (!m0_write_req || !m0_higher_qos);
        
    end else begin : gen_rr_write
        // MODE 1: ROUND-ROBIN (Fair alternating - DEFAULT)
        assign grant_m0_write = m0_write_req && (!m1_write_req || (wr_turn == 2'b00));
        assign grant_m1_write = m1_write_req && (!m0_write_req || (wr_turn == 2'b01));
    end
endgenerate

// ============================================================================
// READ CHANNEL ARBITRATION (3 MODES)
// Added: Configurable arbitration between 2 masters
// ============================================================================
generate
    if (ARBITRATION_MODE == 0) begin : gen_fixed_read
        // MODE 0: FIXED PRIORITY (Master 0 > Master 1)
        assign grant_m0_read = m0_read_req;
        assign grant_m1_read = m1_read_req && !m0_read_req;
        
    end else if (ARBITRATION_MODE == 2) begin : gen_qos_read
        // MODE 2: QOS-BASED (Higher QoS value wins)
        wire m0_higher_qos = (S00_AXI_arqos >= S01_AXI_arqos);
        assign grant_m0_read = m0_read_req && (!m1_read_req || m0_higher_qos);
        assign grant_m1_read = m1_read_req && (!m0_read_req || !m0_higher_qos);
        
    end else begin : gen_rr_read
        // MODE 1: ROUND-ROBIN (Fair alternating - DEFAULT)
        assign grant_m0_read = m0_read_req && (!m1_read_req || (rd_turn == 2'b00));
        assign grant_m1_read = m1_read_req && (!m0_read_req || (rd_turn == 2'b01));
    end
endgenerate

// ============================================================================
// TURN UPDATE LOGIC (For Round-Robin Mode)
// Updated on each granted transaction
// ============================================================================
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        wr_turn <= 2'b01;  // Start with M1 having priority
        rd_turn <= 2'b01;
    end else begin
        // Update write turn (only in ROUND_ROBIN mode)
        if (ARBITRATION_MODE == 1) begin
            if (grant_m0_write && S00_AXI_awready) begin
                wr_turn <= 2'b01;  // Next turn: M1
            end else if (grant_m1_write && S01_AXI_awready) begin
                wr_turn <= 2'b00;  // Next turn: M0
            end
        end
        
        // Update read turn (only in ROUND_ROBIN mode)
        if (ARBITRATION_MODE == 1) begin
            if (grant_m0_read && S00_AXI_arready) begin
                rd_turn <= 2'b01;  // Next turn: M1
            end else if (grant_m1_read && S01_AXI_arready) begin
                rd_turn <= 2'b00;  // Next turn: M0
            end
        end
    end
end


endmodule
