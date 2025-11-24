//=============================================================================
// BR_Channel_Controller_Top.sv - SystemVerilog
// Write Response Channel Controller Top
//=============================================================================

`timescale 1ns/1ps

module BR_Channel_Controller_Top #(
    parameter int unsigned Slaves_Num = 2,
    parameter int unsigned Slaves_ID_Size = $clog2(Slaves_Num),
    parameter int unsigned AXI4_Aw_len = 8,
    parameter int unsigned Resp_ID_width = 2,
    parameter int unsigned Num_Of_Masters = 2,
    parameter int unsigned Num_Of_Slaves = 2,
    parameter int unsigned Master_ID_Width = $clog2(Num_Of_Masters),
    parameter int unsigned M1_ID = 0,
    parameter int unsigned M2_ID = 1
) (
    input logic [Slaves_ID_Size-1:0] Write_Data_Master,
    input logic                      Write_Data_Finsh,
    input logic [(AXI4_Aw_len/2)-1:0] Rem,  // Reminder of the division
    input logic [(AXI4_Aw_len/2)-1:0] Num_Of_Compl_Bursts,  // Number of Complete Bursts
    input logic                         Is_Master_Part_Of_Split,
    input logic                         Load_The_Original_Signals,
    
    // Interconnect Ports
    input  logic                          ACLK,
    input  logic                          ARESETN,

    // Slave S01 Ports
    // Write Response Channel
    output logic [1:0]                   S01_AXI_bresp,  // Write response
    output logic                         S01_AXI_bvalid, // Write response valid signal
    input  logic                         S01_AXI_bready, // Write response ready signal
    
    // Slave S00 Ports
    // Write Response Channel
    output logic [1:0]                   S00_AXI_bresp,  // Write response
    output logic                         S00_AXI_bvalid, // Write response valid signal
    input  logic                         S00_AXI_bready, // Write response ready signal
    
    // Master M00 Ports
    // Write Response Channel
    input  logic [Master_ID_Width-1:0]     M00_AXI_BID,
    input  logic [1:0]                    M00_AXI_bresp,  // Write response
    input  logic                          M00_AXI_bvalid, // Write response valid signal
    output logic                          M00_AXI_bready, // Write response ready signal
    
    // Master M01 Ports (added by mahmoud)
    // Write Response Channel
    input  logic [Master_ID_Width-1:0]     M01_AXI_BID,
    input  logic [1:0]                    M01_AXI_bresp,  // Write response
    input  logic                          M01_AXI_bvalid, // Write response valid signal
    output logic                          M01_AXI_bready  // Write response ready signal
);
    
    logic Write_Res_HandShake_Done;
    logic Write_Res_HandShake_En_Pulse;
    logic Sele_S_AXI_bready;
    logic Virtual_Sele_S_AXI_bready;
    logic [1:0] Virtual_M00_AXI_bresp;
    logic Virtual_M00_AXI_bvalid;
    logic Disconnect_Master;
    
    // Added by Mahmoud
    logic [Master_ID_Width - 1 : 0] Sel_M_ID_Signal;
    logic [1:0]                     Sel_Write_Resp_Signal;
    logic                           Sel_Valid_Signal;
    logic [$clog2(Num_Of_Slaves) - 1 : 0]  Selected_Slave;
    
    // Unused wires for M02 and M03 (read-only masters, no write response channels)
    logic [$clog2(Num_Of_Masters)-1:0]     M02_AXI_BID_unused;
    logic [1:0]                     M02_AXI_bresp_unused;
    logic                           M02_AXI_bvalid_unused;
    logic [$clog2(Num_Of_Masters)-1:0]     M03_AXI_BID_unused;
    logic [1:0]                     M03_AXI_bresp_unused;
    logic                           M03_AXI_bvalid_unused;
    
    // Unused wires for S02 and S03 (no write responses since M02/M03 are read-only)
    logic [1:0]                     S02_AXI_bresp_unused;
    logic                           S02_AXI_bvalid_unused;
    logic [1:0]                     S03_AXI_bresp_unused;
    logic                           S03_AXI_bvalid_unused;

    WR_HandShake u_WR_HandShake(
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .Valid_Signal   (Sel_Valid_Signal   ),
        .Ready_Signal   (Virtual_Sele_S_AXI_bready   ),
        .HandShake_En   (Write_Res_HandShake_En_Pulse   ),
        .HandShake_Done (Write_Res_HandShake_Done )
    );

    // Mahmoud Modules Instantiations
    // Arbiter Module
    Write_Resp_Channel_Arb #(
        .Num_Of_Masters (Num_Of_Masters ),
        .Num_Of_Slaves  (Num_Of_Slaves  )
    )
    u_Write_Resp_Channel_Arb(
        .clk             (ACLK             ),
        .rst             (ARESETN             ),
        .Channel_Granted (Write_Res_HandShake_Done ),
        .M00_AXI_BID     (M00_AXI_BID     ),
        .M00_AXI_bresp   (M00_AXI_bresp   ),
        .M00_AXI_bvalid  (M00_AXI_bvalid  ),
        .M01_AXI_BID     (M01_AXI_BID     ),
        .M01_AXI_bresp   (M01_AXI_bresp   ),
        .M01_AXI_bvalid  (M01_AXI_bvalid  ),
        // M02 and M03 are read-only masters, no write response channels
        .M02_AXI_BID     (M02_AXI_BID_unused     ),
        .M02_AXI_bresp   (M02_AXI_bresp_unused   ),
        .M02_AXI_bvalid  (M02_AXI_bvalid_unused  ),
        .M03_AXI_BID     (M03_AXI_BID_unused     ),
        .M03_AXI_bresp   (M03_AXI_bresp_unused   ),
        .M03_AXI_bvalid  (M03_AXI_bvalid_unused  ),
        .Channel_Request (Write_Res_HandShake_En_Pulse ),
        .Selected_Slave  (Selected_Slave  ),
        .Sel_Resp_ID     (Sel_M_ID_Signal     ),
        .Sel_Write_Resp  (Sel_Write_Resp_Signal  ),
        .Sel_Valid       (Sel_Valid_Signal       )
    );

    // Direct AXI4 connection - no virtual master needed
    assign Virtual_Sele_S_AXI_bready = Sele_S_AXI_bready;
    assign Virtual_M00_AXI_bresp = Sel_Write_Resp_Signal;
    assign Virtual_M00_AXI_bvalid = Sel_Valid_Signal;
    assign Disconnect_Master = 1'b0;  // No burst splitting needed for AXI4

    BReady_MUX_2_1 u_BReady_MUX_2_1(
        .Selected_Slave    (Sel_M_ID_Signal   ),
        .S00_AXI_bready    (S00_AXI_bready    ),
        .S01_AXI_bready    (S01_AXI_bready    ),
        .Sele_S_AXI_bready (Sele_S_AXI_bready ) 
    );

    Demux_1_2 #(
        .Data_Width (1 )
    )
    u_Demux_1_2(
        // Only use LSB of Selected_Slave since Demux_1_2 only supports 2 outputs (M00/M01)
        // M02/M03 are read-only and don't need write response channels
        .Selection_Line (Selected_Slave[0]             ),
        .Input_1        (Virtual_Sele_S_AXI_bready  ),
        .Output_1       (M00_AXI_bready             ),
        .Output_2       (M01_AXI_bready             )
    );

    // Decoder Module
    Write_Resp_Channel_Dec #(
        .Num_Of_Masters (Num_Of_Masters ),
        .Master_ID_Width (Master_ID_Width ),
        .M1_ID          (M1_ID          ),
        .M2_ID          (M2_ID          ),
        .M3_ID          (2            ),  // M02 ID
        .M4_ID          (3            )   // M03 ID
    )
    u_Write_Resp_Channel_Dec(
        .Sel_Resp_ID    (Sel_M_ID_Signal        ),
        .Sel_Write_Resp (Virtual_M00_AXI_bresp  ),
        .Sel_Valid      (Virtual_M00_AXI_bvalid & (~Disconnect_Master) ),
        .S01_AXI_bresp  (S01_AXI_bresp  ),
        .S01_AXI_bvalid (S01_AXI_bvalid ),
        .S00_AXI_bresp  (S00_AXI_bresp  ),
        .S00_AXI_bvalid (S00_AXI_bvalid ),
        // S02 and S03 are unused since M02/M03 are read-only masters
        .S02_AXI_bresp  (S02_AXI_bresp_unused  ),
        .S02_AXI_bvalid (S02_AXI_bvalid_unused ),
        .S03_AXI_bresp  (S03_AXI_bresp_unused  ),
        .S03_AXI_bvalid (S03_AXI_bvalid_unused )
    );

endmodule

