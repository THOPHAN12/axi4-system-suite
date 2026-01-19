// Read_Arbiter_General.sv - QoS-based arbiter for N masters

`timescale 1ns/1ps

module Read_Arbiter_General #(
    parameter int unsigned Masters_Num     = 2,
    parameter int unsigned Masters_ID_Size = (Masters_Num > 1) ? $clog2(Masters_Num) : 1
) (
    input  logic                      ACLK,
    input  logic                      ARESETN,

    // Per-master request and QoS
    input  logic [Masters_Num-1:0]          M_arvalid,
    input  logic [Masters_Num-1:0][3:0]     M_arqos,

    // Channel control
    input  logic                      Channel_Granted,
    input  logic                      Token,

    // Arbitration result
    output logic                      Channel_Request,
    output logic [Masters_ID_Size-1:0] Selected_Master
);

    // Internal combinational winner
    logic [Masters_ID_Size-1:0] best_idx;
    logic [3:0]                 best_qos;
    logic                       best_valid;

    // Choose master with highest QoS, tie-breaker: lowest index
    always_comb begin
        best_valid = 1'b0;
        best_qos   = 4'd0;
        best_idx   = '0;

        for (int i = 0; i < Masters_Num; i++) begin
            if (M_arvalid[i]) begin
                if (!best_valid ||
                    (M_arqos[i] > best_qos) ||
                    ((M_arqos[i] == best_qos) && (i < best_idx))) begin
                    best_valid = 1'b1;
                    best_qos   = M_arqos[i];
                    best_idx   = i[Masters_ID_Size-1:0];
                end
            end
        end
    end

    // Generate request: any valid master, channel granted, no split token
    always_comb begin
        if (!Channel_Granted) begin
            Channel_Request = 1'b0;
        end else if (best_valid && !Token) begin
            Channel_Request = 1'b1;
        end else begin
            Channel_Request = 1'b0;
        end
    end

    // Register selected master for timing closure
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Selected_Master <= '0;
        end else if (Channel_Granted && !Token && Channel_Request) begin
            Selected_Master <= best_idx;
        end
    end

endmodule




















