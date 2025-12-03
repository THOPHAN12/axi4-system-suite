//=============================================================================
// Write_Arbiter.sv - SystemVerilog
// Fixed Priority Arbiter for AXI Write Address Channel
// Master 0 has higher priority than Master 1
//=============================================================================

`timescale 1ns/1ps

module Write_Arbiter #(
    parameter int unsigned Slaves_Num = 2,
    parameter int unsigned Slaves_ID_Size = $clog2(Slaves_Num)
) (
    // Clock and Reset
    input  logic                      ACLK,
    input  logic                      ARESETN,
    
    // Master Request Signals
    input  logic                      S00_AXI_awvalid,  // Master 0 write address valid
    input  logic                      S01_AXI_awvalid,  // Master 1 write address valid
    
    // Channel Control
    input  logic                      Channel_Granted,  // Channel grant from controller
    output logic                      Channel_Request,  // Request to use channel
    
    // Arbitration Result
    output logic [Slaves_ID_Size-1:0]  Selected_Slave    // Selected master (0=M0, 1=M1)
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    logic [Slaves_ID_Size-1:0] Slave;  // Combinational master selection

    //==========================================================================
    // Channel Request Generation
    // Purpose: Generate request signal when any master wants to use channel
    // Logic: Request = Channel_Granted AND (M0_valid OR M1_valid)
    //==========================================================================
    always_comb begin
        if (!Channel_Granted) begin
            // Channel not granted - block request
            Channel_Request = 1'b0;
        end else if (S00_AXI_awvalid || S01_AXI_awvalid) begin
            // At least one master is requesting - generate request
            Channel_Request = 1'b1;
        end else begin
            // No master requesting
            Channel_Request = 1'b0;
        end
    end

    //==========================================================================
    // Master Selection Logic (Fixed Priority)
    // Priority: Master 0 > Master 1
    //==========================================================================
    always_comb begin
        if (S00_AXI_awvalid) begin
            // Master 0 requests - always prioritize M0
            Slave = 1'b0;
        end else if (S01_AXI_awvalid) begin
            // Only Master 1 requests
            Slave = 1'b1;
        end else begin
            // No requests - default to M0
            Slave = 1'b0;
        end
    end

    //==========================================================================
    // Register Selected Master
    // Purpose: Register the selected master for timing closure
    // Timing: 1 clock cycle delay from Slave to Selected_Slave
    //==========================================================================
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            // Reset: Default to Master 0
            Selected_Slave <= 1'b0;
        end else if (Channel_Granted) begin
            // Update selected master when channel is granted
            Selected_Slave <= Slave;
        end
        // else: Hold previous value
    end

endmodule

