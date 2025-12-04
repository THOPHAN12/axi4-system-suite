////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Arbiter
// Description: Fixed Priority Arbiter for AXI Write Address Channel
//              Master 0 has higher priority than Master 1
//
// Arbitration Policy:
//   - Fixed Priority: M0 > M1
//   - When both masters request, M0 is always selected
//   - WARNING: M1 may experience starvation under heavy M0 load
//
// Features:
//   + Simple, low latency arbitration
//   + Synchronous reset
//   + Registered output for timing closure
//
// Limitations:
//   - No QoS support
//   - No fairness mechanism
//   - M1 can be starved if M0 continuously requests
////////////////////////////////////////////////////////////////////////////////

module Write_Arbiter #(
    parameter Slaves_Num     = 'd2,
    parameter Slaves_ID_Size = $clog2(Slaves_Num)
) (
    // Clock and Reset
    input  wire                      ACLK,
    input  wire                      ARESETN,
    
    // Master Request Signals
    input  wire                      S00_AXI_awvalid,  // Master 0 write address valid
    input  wire                      S01_AXI_awvalid,  // Master 1 write address valid
    
    // Channel Control
    input  wire                      Channel_Granted,  // Channel grant from controller
    output reg                       Channel_Request,  // Request to use channel
    
    // Arbitration Result
    output reg [Slaves_ID_Size-1:0]  Selected_Slave    // Selected master (0=M0, 1=M1)
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    reg [Slaves_ID_Size-1:0] Slave;  // Combinational master selection

    //==========================================================================
    // Channel Request Generation
    // Purpose: Generate request signal when any master wants to use channel
    // Logic: Request = Channel_Granted AND (M0_valid OR M1_valid)
    //==========================================================================
    always @(*) begin
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
    // 
    // Truth Table:
    // ????????????????????????????????????
    // ? M0_valid ? M1_valid ? Selected   ?
    // ????????????????????????????????????
    // ? 0        ? 0        ? M0 (def)   ?
    // ? 1        ? 0        ? M0         ?
    // ? 0        ? 1        ? M1         ?
    // ? 1        ? 1        ? M0 (M0>M1) ? ? Fixed Priority
    // ????????????????????????????????????
    //
    // WARNING: When both masters request simultaneously, M0 always wins.
    //          This can cause M1 starvation if M0 continuously requests.
    //==========================================================================
    always @(*) begin
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
    always @(posedge ACLK or negedge ARESETN) begin
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





