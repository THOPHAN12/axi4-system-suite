module Write_Resp_Channel_Arb #(
    parameter  Num_Of_Masters ='d2, Masters_Id_Size=$clog2(Num_Of_Masters),
    parameter Num_Of_Slaves = 4 ,Slaves_Id_Size=$clog2(Num_Of_Slaves)
) (
    input  wire                          clk, rst,
   
    input  wire                          Channel_Granted,


    // Slaves Ports -----------------------------------------------
    // Slave 1

    input  wire [Masters_Id_Size-1:0]    M00_AXI_BID  ,
    input  wire [1:0]                    M00_AXI_bresp,//Write response
    input  wire                          M00_AXI_bvalid, //Write response valid signal
    // Slave 2
    input  wire [Masters_Id_Size-1:0]    M01_AXI_BID  ,
    input  wire [1:0]                    M01_AXI_bresp,//Write response
    input  wire                          M01_AXI_bvalid, //Write response valid signal
    // ------------------------------------------------------------
    // TH�M M02
    input wire [Masters_Id_Size-1:0] M02_AXI_BID,
    input wire [1:0] M02_AXI_bresp,
    input wire M02_AXI_bvalid,
    
    // TH�M M03
    input wire [Masters_Id_Size-1:0] M03_AXI_BID,
    input wire [1:0] M03_AXI_bresp,
    input wire M03_AXI_bvalid,
                                            
    output reg                           Channel_Request,
    output reg  [Slaves_Id_Size - 1 : 0]  Selected_Slave, 
    
    output reg  [Masters_Id_Size - 1 : 0]  Sel_Resp_ID,
    output reg  [1:0]                    Sel_Write_Resp,
    output reg                           Sel_Valid
);


reg [Slaves_Id_Size-1:0]  Slave_Sel;
reg [Masters_Id_Size-1:0]  Sel_Resp_ID_Comb;
reg [1:0] Sel_Write_Resp_Comb;
reg       Sel_Valid_Comb;

reg Channel_Request_Com;
wire [Num_Of_Slaves - 1 : 0]  Slaves_Valid;
assign Slaves_Valid ={M03_AXI_bvalid, M02_AXI_bvalid, 
                       M01_AXI_bvalid, M00_AXI_bvalid};
always @(*) begin
    casez (Slaves_Valid)
        4'b???1: begin  // M00 c� priority cao nh?t
            Slave_Sel = 2'b00;
            Sel_Write_Resp_Comb = M00_AXI_bresp;
            Sel_Valid_Comb = M00_AXI_bvalid;
            Sel_Resp_ID_Comb = M00_AXI_BID;
        end
        4'b??10: begin  // M01
            Slave_Sel = 2'b01;
            Sel_Write_Resp_Comb = M01_AXI_bresp;
            Sel_Valid_Comb = M01_AXI_bvalid;
            Sel_Resp_ID_Comb = M01_AXI_BID;
        end
        4'b?100: begin  // M02
            Slave_Sel = 2'b10;
            Sel_Write_Resp_Comb = M02_AXI_bresp;
            Sel_Valid_Comb = M02_AXI_bvalid;
            Sel_Resp_ID_Comb = M02_AXI_BID;
        end
        4'b1000: begin  // M03
            Slave_Sel = 2'b11;
            Sel_Write_Resp_Comb = M03_AXI_bresp;
            Sel_Valid_Comb = M03_AXI_bvalid;
            Sel_Resp_ID_Comb = M03_AXI_BID;
        end
        default: begin
            Slave_Sel = 2'b00;
            Sel_Write_Resp_Comb = 2'b00;
            Sel_Valid_Comb = 1'b0;
            Sel_Resp_ID_Comb = 'b0;
        end
    endcase
end

// Channel Request Logic
always @(*) begin
    if (|Slaves_Valid) begin  // At least one Slave has valid response
        Channel_Request_Com = 1'b1;
    end else begin
        Channel_Request_Com = 1'b0;
    end
end

// Register outputs for timing closure
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        Channel_Request <= 1'b0;
        Selected_Slave <= 2'b00;
        Sel_Resp_ID <= 'b0;
        Sel_Write_Resp <= 2'b00;
        Sel_Valid <= 1'b0;
    end else begin
        // Channel_Request updates continuously when there's valid response
        Channel_Request <= Channel_Request_Com;
        
        // Other outputs update when Channel_Granted
        if (Channel_Granted) begin
            Selected_Slave <= Slave_Sel;
            Sel_Resp_ID <= Sel_Resp_ID_Comb;
            Sel_Write_Resp <= Sel_Write_Resp_Comb;
            Sel_Valid <= Sel_Valid_Comb;
        end
    end
end

endmodule
