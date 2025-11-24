//=============================================================================
// Queue.sv - SystemVerilog
// Queue buffer for tracking master IDs in write transactions
//=============================================================================

`timescale 1ns/1ps

module Queue #(
    parameter int unsigned Slaves_Num = 2,
    parameter int unsigned ID_Size = $clog2(Slaves_Num)
) (
    input  logic                 ACLK,
    input  logic                 ARESETN,
    input  logic [ID_Size-1:0]   Slave_ID,
    input  logic                 AW_Access_Grant,
    input  logic                 Write_Data_Finsh,
    input  logic                 Is_Transaction_Part_of_Split,
    output logic                 Queue_Is_Full,
    output logic                 Write_Data_HandShake_En_Pulse,
    output logic                 Is_Master_Part_Of_Split,
    output logic                 Master_Valid,
    output logic [ID_Size-1:0]   Write_Data_Master
);

    // Integer i is used only in for loop initialization, not as a state variable
    // This prevents inferred latch warning
    logic [ID_Size-1:0] Queue [Slaves_Num-1:0];
    logic [Slaves_Num-1:0] Split_Burst_Queue;
    logic [ID_Size:0] Read_Pointer, Write_Pointer;
    logic Write_Data_HandShake_En;
    logic Pulse;
    
    assign Master_Valid = Write_Data_HandShake_En;

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            // Initialize queue array - i is loop variable only, not a state
            for (int i = 0; i < Slaves_Num; i++) begin
                Queue[i] <= '0;
            end
        end else if (AW_Access_Grant) begin
            Queue[Write_Pointer[0]] <= Slave_ID;
        end
    end

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Split_Burst_Queue <= '0;
        end else if (AW_Access_Grant) begin
            Split_Burst_Queue[Write_Pointer[0]] <= Is_Transaction_Part_of_Split;
        end
    end
    
    assign Is_Master_Part_Of_Split = Split_Burst_Queue[Read_Pointer[0]];

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Write_Pointer <= '0;
        end else if (AW_Access_Grant) begin
            Write_Pointer <= Write_Pointer + 1'b1;  // Explicit 1-bit addition to avoid truncation warning
        end
    end
    
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Read_Pointer <= '0;
        end else if (Write_Data_Finsh) begin
            Read_Pointer <= Read_Pointer + 1'b1;  // Explicit 1-bit addition to avoid truncation warning
        end
    end
    
    assign Write_Data_Master = Queue[Read_Pointer[0]];
    assign Write_Data_HandShake_En = (Read_Pointer != Write_Pointer);

    always_comb begin
        if ((Read_Pointer[ID_Size] != Write_Pointer[ID_Size]) && 
            (Read_Pointer[ID_Size-1:0] == Write_Pointer[ID_Size-1:0])) begin
            Queue_Is_Full = 1'b1;
        end else begin
            Queue_Is_Full = 1'b0;
        end
    end

    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Pulse <= '0;
        end else begin
            Pulse <= Write_Data_HandShake_En;
        end
    end
    
    assign Write_Data_HandShake_En_Pulse = (~Pulse) & Write_Data_HandShake_En;

endmodule

