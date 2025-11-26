//=============================================================================
// Qos_Arbiter.sv - SystemVerilog
// QoS-based Arbiter for AXI Write Address Channel
//=============================================================================

`timescale 1ns/1ps

module Qos_Arbiter #(
    parameter int unsigned Slaves_Num = 2,
    parameter int unsigned Slaves_ID_Size = $clog2(Slaves_Num)
) (
    input  logic                      ACLK,
    input  logic                      ARESETN,
    input  logic                      S00_AXI_awvalid,
    input  logic [3:0]                S00_AXI_awqos,   // for priority transactions
    input  logic                      S01_AXI_awvalid,
    input  logic [3:0]                S01_AXI_awqos,   // for priority transactions
    input  logic                      Channel_Granted,
    input  logic                      Token,
    output logic                      Channel_Request,
    output logic [Slaves_ID_Size-1:0] Selected_Slave
);

    logic [Slaves_ID_Size-1:0] Slave;
    logic Request;
    
    always_comb begin
        if (S01_AXI_awvalid && S00_AXI_awvalid) begin
            if (S00_AXI_awqos >= S01_AXI_awqos) begin
                Slave = 1'b0;
            end else begin
                Slave = 1'b1;
            end
        end else if (S00_AXI_awvalid) begin
            Slave = 1'b0;
        end else if (S01_AXI_awvalid) begin
            Slave = 1'b1;
        end else begin
            Slave = 1'b0;
        end
    end

    always_comb begin
        if (!Channel_Granted) begin
            Request = 1'b0;
        end else if ((S00_AXI_awvalid || S01_AXI_awvalid)) begin
            Request = 1'b1;
        end else begin
            Request = 1'b0;
        end
    end
    
    assign Channel_Request = Request & (~Token);
    
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Selected_Slave <= '0;
        end else if (Channel_Granted & (~Token)) begin
            Selected_Slave <= Slave;
        end
    end

endmodule

