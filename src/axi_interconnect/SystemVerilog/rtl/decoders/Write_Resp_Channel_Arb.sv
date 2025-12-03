//=============================================================================
// Write_Resp_Channel_Arb.sv - SystemVerilog
// Write Response Channel Arbiter
//=============================================================================

`timescale 1ns/1ps

module Write_Resp_Channel_Arb #(
    parameter int unsigned Num_Of_Masters = 2,
    parameter int unsigned Masters_Id_Size = $clog2(Num_Of_Masters),
    parameter int unsigned Num_Of_Slaves = 4,
    parameter int unsigned Slaves_Id_Size = $clog2(Num_Of_Slaves)
) (
    input  logic                          clk,
    input  logic                          rst,
    input  logic                          Channel_Granted,

    // Slaves Ports
    // Slave 1
    input  logic [Masters_Id_Size-1:0]    M00_AXI_BID,
    input  logic [1:0]                    M00_AXI_bresp,  // Write response
    input  logic                          M00_AXI_bvalid, // Write response valid signal
    
    // Slave 2
    input  logic [Masters_Id_Size-1:0]    M01_AXI_BID,
    input  logic [1:0]                    M01_AXI_bresp,  // Write response
    input  logic                          M01_AXI_bvalid, // Write response valid signal
    
    // M02
    input  logic [Masters_Id_Size-1:0]    M02_AXI_BID,
    input  logic [1:0]                    M02_AXI_bresp,
    input  logic                          M02_AXI_bvalid,
    
    // M03
    input  logic [Masters_Id_Size-1:0]    M03_AXI_BID,
    input  logic [1:0]                    M03_AXI_bresp,
    input  logic                          M03_AXI_bvalid,
                                            
    output logic                          Channel_Request,
    output logic [Slaves_Id_Size - 1 : 0]  Selected_Slave,
    
    output logic [Masters_Id_Size - 1 : 0]  Sel_Resp_ID,
    output logic [1:0]                    Sel_Write_Resp,
    output logic                          Sel_Valid
);

    logic [Slaves_Id_Size-1:0]  Slave_Sel;
    logic [Masters_Id_Size-1:0]  Sel_Resp_ID_Comb;
    logic [1:0] Sel_Write_Resp_Comb;
    logic       Sel_Valid_Comb;
    logic       Channel_Request_Com;
    
    logic [Num_Of_Slaves - 1 : 0]  Slaves_Valid;
    assign Slaves_Valid = {M03_AXI_bvalid, M02_AXI_bvalid, 
                           M01_AXI_bvalid, M00_AXI_bvalid};
    
    always_comb begin
        casez (Slaves_Valid)
            4'b???1: begin  // M00 has highest priority
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
                Sel_Resp_ID_Comb = '0;
            end
        endcase
    end

    // Channel Request Logic
    always_comb begin
        if (|Slaves_Valid) begin  // At least one Slave has valid response
            Channel_Request_Com = 1'b1;
        end else begin
            Channel_Request_Com = 1'b0;
        end
    end

    // Register outputs for timing closure
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            Channel_Request <= 1'b0;
            Selected_Slave <= 2'b00;
            Sel_Resp_ID <= '0;
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

