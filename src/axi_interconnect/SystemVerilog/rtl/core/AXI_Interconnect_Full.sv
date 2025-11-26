//=============================================================================
// AXI_Interconnect_Full.sv - SystemVerilog
// Full AXI4 Interconnect supporting 2 Masters and 4 Slaves
//=============================================================================

`timescale 1ns/1ps

module AXI_Interconnect_Full #(
    parameter int unsigned Masters_Num = 2,
    parameter int unsigned Slaves_ID_Size = $clog2(Masters_Num),
    parameter int unsigned Address_width = 32,
    parameter int unsigned S00_Aw_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned S00_Write_data_bus_width = 32,
    parameter int unsigned S00_Write_data_bytes_num = S00_Write_data_bus_width / 8,
    parameter int unsigned S00_AR_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned S00_Read_data_bus_width = 32,
    parameter int unsigned S01_Aw_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned S01_AR_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned S01_Write_data_bus_width = 32,
    parameter int unsigned AXI4_Aw_len = 8,
    parameter int unsigned M00_Aw_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M00_Write_data_bus_width = 32,
    parameter int unsigned M00_Write_data_bytes_num = M00_Write_data_bus_width / 8,
    parameter int unsigned M00_AR_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M00_Read_data_bus_width = 32,
    parameter int unsigned M01_Aw_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M01_AR_len = 8,  // AXI4 - 8 bits for burst length
    // Added for M02, M03 support
    parameter int unsigned M02_Aw_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M02_AR_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M02_Read_data_bus_width = 32,
    parameter int unsigned M03_Aw_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M03_AR_len = 8,  // AXI4 - 8 bits for burst length
    parameter int unsigned M03_Read_data_bus_width = 32,
    parameter int unsigned Is_Master_AXI_4 = 1,  // All interfaces use AXI4
    // Added by Mahmoud
    parameter int unsigned M1_ID = 0,
    parameter int unsigned M2_ID = 1,
    parameter int unsigned Resp_ID_width = 2,
    parameter int unsigned Num_Of_Masters = 2,
    parameter int unsigned Num_Of_Slaves = 4,  // Updated: Support 4 slaves
    parameter int unsigned Master_ID_Width = $clog2(Num_Of_Masters),
    parameter int unsigned AXI4_AR_len = 8
) (
    // Slave S01 Ports
    // Slave General Ports
    input  logic                          S01_ACLK,
    input  logic                          S01_ARESETN,
    
    // Address Write Channel
    input  logic [Address_width-1:0]      S01_AXI_awaddr,  // the write address
    input  logic [S01_Aw_len-1:0]         S01_AXI_awlen,  // number of transfer per burst
    input  logic [2:0]                    S01_AXI_awsize,  // number of bytes within the transfer
    input  logic [1:0]                    S01_AXI_awburst,  // burst type
    input  logic [1:0]                    S01_AXI_awlock,   // lock type
    input  logic [3:0]                    S01_AXI_awcache,  // optional signal for connecting to different types of memories
    input  logic [2:0]                    S01_AXI_awprot,   // identifies the level of protection
    input  logic [3:0]                    S01_AXI_awqos,    // for priority transactions
    input  logic                          S01_AXI_awvalid, // Address write valid signal
    output logic                          S01_AXI_awready, // Address write ready signal

    // Write Data Channel
    input  logic [S00_Write_data_bus_width-1:0]   S01_AXI_wdata,  // Write data bus
    input  logic [S00_Write_data_bytes_num-1:0]   S01_AXI_wstrb,  // strobes identifies the active data lines
    input  logic                                 S01_AXI_wlast,  // last signal to identify the last transfer in a burst
    input  logic                                 S01_AXI_wvalid, // write valid signal
    output logic                                 S01_AXI_wready, // write ready signal

    // Write Response Channel
    output logic [1:0]                   S01_AXI_bresp,  // Write response
    output logic                         S01_AXI_bvalid, // Write response valid signal
    input  logic                         S01_AXI_bready, // Write response ready signal

    // Address Read Channel
    input  logic [Address_width-1:0]     S01_AXI_araddr,  // the read address
    input  logic [S01_AR_len-1:0]        S01_AXI_arlen,  // number of transfer per burst
    input  logic [2:0]                   S01_AXI_arsize,  // number of bytes within the transfer
    input  logic [1:0]                   S01_AXI_arburst,  // burst type
    input  logic [1:0]                   S01_AXI_arlock,   // lock type
    input  logic [3:0]                   S01_AXI_arcache,  // optional signal for connecting to different types of memories
    input  logic [2:0]                   S01_AXI_arprot,   // identifies the level of protection
    input  logic [3:0]                   S01_AXI_arregion, // AXI4 region signal
    input  logic [3:0]                   S01_AXI_arqos,    // for priority transactions
    input  logic                         S01_AXI_arvalid, // Address read valid signal
    output logic                         S01_AXI_arready, // Address read ready signal
    
    // Read Data Channel
    output logic [S00_Read_data_bus_width-1:0]  S01_AXI_rdata,  // Read Data Bus
    output logic [1:0]                          S01_AXI_rresp, // Read Response
    output logic                                 S01_AXI_rlast, // Read Last Signal
    output logic                                 S01_AXI_rvalid, // Read Valid Signal
    input  logic                                 S01_AXI_rready, // Read Ready Signal
    
    // Interconnect Ports
    input  logic                          ACLK,
    input  logic                          ARESETN,
    
    // Slave S00 Ports
    // Slave General Ports
    input  logic                          S00_ACLK,
    input  logic                          S00_ARESETN,

    // Address Write Channel
    input  logic [Address_width-1:0]     S00_AXI_awaddr,  // the write address
    input  logic [S00_Aw_len-1:0]         S00_AXI_awlen,  // number of transfer per burst
    input  logic [2:0]                    S00_AXI_awsize,  // number of bytes within the transfer
    input  logic [1:0]                    S00_AXI_awburst,  // burst type
    input  logic [1:0]                    S00_AXI_awlock,   // lock type
    input  logic [3:0]                    S00_AXI_awcache,  // optional signal for connecting to different types of memories
    input  logic [2:0]                    S00_AXI_awprot,   // identifies the level of protection
    input  logic [3:0]                    S00_AXI_awqos,    // for priority transactions
    input  logic                          S00_AXI_awvalid, // Address write valid signal
    output logic                          S00_AXI_awready, // Address write ready signal

    // Write Data Channel
    input  logic [S00_Write_data_bus_width-1:0]   S00_AXI_wdata,  // Write data bus
    input  logic [S00_Write_data_bytes_num-1:0]   S00_AXI_wstrb,  // strobes identifies the active data lines
    input  logic                                 S00_AXI_wlast,  // last signal to identify the last transfer in a burst
    input  logic                                 S00_AXI_wvalid, // write valid signal
    output logic                                 S00_AXI_wready, // write ready signal

    // Write Response Channel
    output logic [1:0]                   S00_AXI_bresp,  // Write response
    output logic                         S00_AXI_bvalid, // Write response valid signal
    input  logic                         S00_AXI_bready, // Write response ready signal

    // Address Read Channel
    input  logic [Address_width-1:0]     S00_AXI_araddr,  // the read address
    input  logic [S00_AR_len-1:0]        S00_AXI_arlen,  // number of transfer per burst
    input  logic [2:0]                    S00_AXI_arsize,  // number of bytes within the transfer
    input  logic [1:0]                    S00_AXI_arburst,  // burst type
    input  logic [1:0]                    S00_AXI_arlock,   // lock type
    input  logic [3:0]                    S00_AXI_arcache,  // optional signal for connecting to different types of memories
    input  logic [2:0]                    S00_AXI_arprot,   // identifies the level of protection
    input  logic [3:0]                    S00_AXI_arregion, // AXI4 region signal
    input  logic [3:0]                    S00_AXI_arqos,    // for priority transactions
    input  logic                          S00_AXI_arvalid, // Address read valid signal
    output logic                          S00_AXI_arready, // Address read ready signal
    
    // Read Data Channel
    output logic [S00_Read_data_bus_width-1:0]  S00_AXI_rdata,  // Read Data Bus
    output logic [1:0]                          S00_AXI_rresp, // Read Response
    output logic                                 S00_AXI_rlast, // Read Last Signal
    output logic                                 S00_AXI_rvalid, // Read Valid Signal
    input  logic                                 S00_AXI_rready, // Read Ready Signal

    // Master M00 Ports
    // Slave General Ports
    input  logic                          M00_ACLK,
    input  logic                          M00_ARESETN,

    // Address Write Channel
    output logic [Slaves_ID_Size-1:0]     M00_AXI_awaddr_ID,
    output logic [Address_width-1:0]      M00_AXI_awaddr,
    output logic [M00_Aw_len-1:0]         M00_AXI_awlen,
    output logic [2:0]                    M00_AXI_awsize,  // number of bytes within the transfer
    output logic [1:0]                    M00_AXI_awburst,  // burst type
    output logic [1:0]                    M00_AXI_awlock,   // lock type
    output logic [3:0]                    M00_AXI_awcache,  // optional signal for connecting to different types of memories
    output logic [2:0]                    M00_AXI_awprot,   // identifies the level of protection
    output logic [3:0]                    M00_AXI_awqos,    // for priority transactions
    output logic                          M00_AXI_awvalid,  // Address write valid signal
    input  logic                          M00_AXI_awready,  // Address write ready signal
    
    // Write Data Channel
    output logic [M00_Write_data_bus_width-1:0]   M00_AXI_wdata,  // Write data bus
    output logic [M00_Write_data_bytes_num-1:0]   M00_AXI_wstrb,  // strobes identifies the active data lines
    output logic                                 M00_AXI_wlast,  // last signal to identify the last transfer in a burst
    output logic                                 M00_AXI_wvalid, // write valid signal
    input  logic                                 M00_AXI_wready, // write ready signal

    // Write Response Channel
    input  logic [Master_ID_Width-1:0]     M00_AXI_BID,
    input  logic [1:0]                    M00_AXI_bresp,  // Write response
    input  logic                          M00_AXI_bvalid, // Write response valid signal
    output logic                          M00_AXI_bready, // Write response ready signal

    // Address Read Channel
    output logic [Address_width-1:0]     M00_AXI_araddr,  // the read address
    output logic [M00_AR_len-1:0]        M00_AXI_arlen,  // number of transfer per burst
    output logic [2:0]                   M00_AXI_arsize,  // number of bytes within the transfer
    output logic [1:0]                   M00_AXI_arburst,  // burst type
    output logic [1:0]                   M00_AXI_arlock,   // lock type
    output logic [3:0]                   M00_AXI_arcache,  // optional signal for connecting to different types of memories
    output logic [2:0]                   M00_AXI_arprot,   // identifies the level of protection
    output logic [3:0]                   M00_AXI_arregion, // AXI4 region signal
    output logic [3:0]                   M00_AXI_arqos,    // for priority transactions
    output logic                         M00_AXI_arvalid, // Address read valid signal
    input  logic                         M00_AXI_arready, // Address read ready signal

    // Read Data Channel
    input  logic [M00_Read_data_bus_width-1:0]  M00_AXI_rdata,  // Read Data Bus
    input  logic [1:0]                          M00_AXI_rresp, // Read Response
    input  logic                                 M00_AXI_rlast, // Read Last Signal
    input  logic                                 M00_AXI_rvalid, // Read Valid Signal
    output logic                                 M00_AXI_rready, // Read Ready Signal

    // Master M01 Ports
    // Slave General Ports
    input  logic                          M01_ACLK,
    input  logic                          M01_ARESETN,

    // Address Write Channel
    output logic [Slaves_ID_Size-1:0]    M01_AXI_awaddr_ID,
    output logic [Address_width-1:0]      M01_AXI_awaddr,
    output logic [M01_Aw_len-1:0]         M01_AXI_awlen,
    output logic [2:0]                    M01_AXI_awsize,  // number of bytes within the transfer
    output logic [1:0]                    M01_AXI_awburst,  // burst type
    output logic [1:0]                    M01_AXI_awlock,   // lock type
    output logic [3:0]                    M01_AXI_awcache,  // optional signal for connecting to different types of memories
    output logic [2:0]                    M01_AXI_awprot,   // identifies the level of protection
    output logic [3:0]                    M01_AXI_awqos,    // for priority transactions
    output logic                          M01_AXI_awvalid,  // Address write valid signal
    input  logic                          M01_AXI_awready,  // Address write ready signal

    // Write Data Channel
    output logic [M00_Write_data_bus_width-1:0]   M01_AXI_wdata,  // Write data bus
    output logic [M00_Write_data_bytes_num-1:0]   M01_AXI_wstrb,  // strobes identifies the active data lines
    output logic                                 M01_AXI_wlast,  // last signal to identify the last transfer in a burst
    output logic                                 M01_AXI_wvalid, // write valid signal
    input  logic                                 M01_AXI_wready, // write ready signal

    // Write Response Channel
    input  logic [Master_ID_Width-1:0]     M01_AXI_BID,
    input  logic [1:0]                    M01_AXI_bresp,  // Write response
    input  logic                          M01_AXI_bvalid, // Write response valid signal
    output logic                          M01_AXI_bready, // Write response ready signal

    // Address Read Channel
    output logic [Address_width-1:0]     M01_AXI_araddr,  // the read address
    output logic [M01_AR_len-1:0]        M01_AXI_arlen,  // number of transfer per burst
    output logic [2:0]                   M01_AXI_arsize,  // number of bytes within the transfer
    output logic [1:0]                   M01_AXI_arburst,  // burst type
    output logic [1:0]                   M01_AXI_arlock,   // lock type
    output logic [3:0]                   M01_AXI_arcache,  // optional signal for connecting to different types of memories
    output logic [2:0]                   M01_AXI_arprot,   // identifies the level of protection
    output logic [3:0]                   M01_AXI_arregion, // AXI4 region signal
    output logic [3:0]                   M01_AXI_arqos,    // for priority transactions
    output logic                         M01_AXI_arvalid, // Address read valid signal
    input  logic                         M01_AXI_arready, // Address read ready signal

    // Read Data Channel
    input  logic [M00_Read_data_bus_width-1:0]  M01_AXI_rdata,  // Read Data Bus
    input  logic [1:0]                          M01_AXI_rresp, // Read Response
    input  logic                                 M01_AXI_rlast, // Read Last Signal
    input  logic                                 M01_AXI_rvalid, // Read Valid Signal
    output logic                                 M01_AXI_rready, // Read Ready Signal

    // Address ranges for each slave
    input logic [31:0] slave0_addr1,
    input logic [31:0] slave0_addr2,
    input logic [31:0] slave1_addr1,
    input logic [31:0] slave1_addr2,
    input logic [31:0] slave2_addr1,
    input logic [31:0] slave2_addr2,
    input logic [31:0] slave3_addr1,
    input logic [31:0] slave3_addr2,

    // Master M02 Ports (Read Only)
    // Slave General Ports
    input  logic                          M02_ACLK,
    input  logic                          M02_ARESETN,

    // Address Read Channel
    output logic [Address_width-1:0]     M02_AXI_araddr,
    output logic [M02_AR_len-1:0]        M02_AXI_arlen,
    output logic [2:0]                   M02_AXI_arsize,
    output logic [1:0]                   M02_AXI_arburst,
    output logic [1:0]                   M02_AXI_arlock,
    output logic [3:0]                   M02_AXI_arcache,
    output logic [2:0]                   M02_AXI_arprot,
    output logic [3:0]                   M02_AXI_arregion,
    output logic [3:0]                   M02_AXI_arqos,
    output logic                         M02_AXI_arvalid,
    input  logic                         M02_AXI_arready,

    // Read Data Channel
    input  logic [M02_Read_data_bus_width-1:0]  M02_AXI_rdata,
    input  logic [1:0]                          M02_AXI_rresp,
    input  logic                                 M02_AXI_rlast,
    input  logic                                 M02_AXI_rvalid,
    output logic                                 M02_AXI_rready,

    // Master M03 Ports (Read Only)
    // Slave General Ports
    input  logic                          M03_ACLK,
    input  logic                          M03_ARESETN,

    // Address Read Channel
    output logic [Address_width-1:0]     M03_AXI_araddr,
    output logic [M03_AR_len-1:0]        M03_AXI_arlen,
    output logic [2:0]                   M03_AXI_arsize,
    output logic [1:0]                   M03_AXI_arburst,
    output logic [1:0]                   M03_AXI_arlock,
    output logic [3:0]                   M03_AXI_arcache,
    output logic [2:0]                   M03_AXI_arprot,
    output logic [3:0]                   M03_AXI_arregion,
    output logic [3:0]                   M03_AXI_arqos,
    output logic                         M03_AXI_arvalid,
    input  logic                         M03_AXI_arready,

    // Read Data Channel
    input  logic [M03_Read_data_bus_width-1:0]  M03_AXI_rdata,
    input  logic [1:0]                          M03_AXI_rresp,
    input  logic                                 M03_AXI_rlast,
    input  logic                                 M03_AXI_rvalid,
    output logic                                 M03_AXI_rready
);

    //------------------- Internal Signals -------------------
    //****************Write Channels*********************/
    logic AW_Access_Grant;
    logic Write_Data_Finsh;
    logic [Slaves_ID_Size-1:0] AW_Selected_Slave;
    logic [Slaves_ID_Size-1:0] Write_Data_Master;
    logic Last_Signal_Data;
    logic Queue_Is_Full;
    logic Token;
    logic [(S00_Aw_len/2)-1:0] Rem;  // Reminder of the division
    logic [(S00_Aw_len/2)-1:0] Num_Of_Compl_Bursts;  // Number of Complete Bursts
    logic Is_Master_Part_Of_Split;
    logic Load_The_Original_Signals;
    // Added by mahmoud
    // Q_Enable_W_Data should match Num_Of_Slaves (4) not Masters_Num (2)
    logic [Num_Of_Slaves - 1 : 0] Q_Enable_W_Data_Signal;
    logic Is_Master_Part_Of_Split2, Write_Data_Finsh2, Write_Data_Master2;
    // --------------------------------------------------------

    //**************** Read Channels*********************/
    // select lines for muxs and demuxs coming from controller:
    logic             S_addr_wire;
    logic [1:0]       M0_data_wire;  // Updated: 2-bit for 4 Slaves
    logic [1:0]       M1_data_wire;  // Updated: 2-bit for 4 Slaves
    logic             M_addr_wire;

    // wires connecting between a mux and a demux:
    logic             ARVALID_wire;
    logic [31:0]     ARADDR_wire;
    logic [7:0]      ARLEN_wire;
    logic [2:0]      ARSIZE_wire;
    logic [1:0]      ARBURST_wire;

    logic [1:0]       en_S0_wire;
    logic [1:0]       en_S1_wire;
    logic [1:0]       en_S2_wire;
    logic [1:0]       en_S3_wire;

    logic             enable_S0_wire;
    logic             enable_S1_wire;
    logic             enable_S2_wire;
    logic             enable_S3_wire;

    logic             RREADY_S0_wire;
    logic             RREADY_S1_wire;
    logic             RREADY_S2_wire;
    logic             RREADY_S3_wire;

    logic             RREADY_S0_wire_2;
    logic             RREADY_S1_wire_2;
    logic             RREADY_S2_wire_2;
    logic             RREADY_S3_wire_2;
    // --------------------------------------------------------

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

    /*Data Write Channel Managers and MUXs*/
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
        .M01_AXI_wdata      (M01_AXI_wdata         ),
        .M01_AXI_wstrb      (M01_AXI_wstrb         ),
        .M01_AXI_wlast      (M01_AXI_wlast         ),
        .M01_AXI_wvalid     (M01_AXI_wvalid        ),
        .M01_AXI_wready     (M01_AXI_wready        ),
        .Q_Enable_W_Data_In (Q_Enable_W_Data_Signal)
    );

    // Write Response Channel
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
    // Internal signals for AR Channel Controller
    logic AR_Access_Grant;
    logic [Slaves_ID_Size-1:0] AR_Selected_Slave;
    logic AR_Channel_Request;

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
    // Mux to select address from active master for Controller
    logic [Address_width-1:0] M_ADDR_muxed;
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
        .en_S2                         (en_S2_wire),  // CONNECTED for Slave 2
        .en_S3                         (en_S3_wire)   // CONNECTED for Slave 3
    );

    //---------------- Data Channel ---------------------

    //------------------ RREADY -------------------------
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

endmodule

