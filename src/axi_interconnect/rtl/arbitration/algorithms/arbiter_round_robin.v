////////////////////////////////////////////////////////////////////////////////
// Module Name: Write_Arbiter_RR (Round-Robin)
// Description: Round-Robin Arbiter for AXI Write Address Channel
//              Provides fair arbitration between Master 0 and Master 1
//
// Arbitration Policy:
//   - Round-Robin: Alternates between M0 and M1
//   - When both masters request, selects the one NOT served last time
//   - No starvation - both masters get fair access
//
// Features:
//   + Fair arbitration (no starvation)
//   + Round-robin when both request simultaneously
//   + Single master requests are immediately granted
//   + Synchronous reset
//   + Registered output for timing closure
//
// Advantages over Fixed Priority:
//   + Prevents M1 starvation
//   + Fair bandwidth distribution
//   + Better for equal-priority masters
////////////////////////////////////////////////////////////////////////////////

module Write_Arbiter_RR #(
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
    reg [Slaves_ID_Size-1:0] Slave;         // Combinational master selection
    reg                      last_served;   // Track last served master (0=M0, 1=M1)

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
    // Master Selection Logic (Round-Robin)
    // 
    // Truth Table:
    // ??????????????????????????????????????????????????
    // ? M0_valid ? M1_valid ? last_served ? Selected   ?
    // ??????????????????????????????????????????????????
    // ? 0        ? 0        ? x           ? M0 (def)   ?
    // ? 1        ? 0        ? x           ? M0         ?
    // ? 0        ? 1        ? x           ? M1         ?
    // ? 1        ? 1        ? 0 (M0)      ? M1         ? ? Round-Robin!
    // ? 1        ? 1        ? 1 (M1)      ? M0         ? ? Round-Robin!
    // ??????????????????????????????????????????????????
    //
    // Round-Robin Logic:
    //   - When both masters request, select the one NOT served last time
    //   - This ensures fair alternation and prevents starvation
    //==========================================================================
    always @(*) begin
        if (S00_AXI_awvalid && S01_AXI_awvalid) begin
            // Both masters request - use round-robin
            // Select the master that was NOT served last time
            if (last_served == 1'b0) begin
                // M0 was served last ? serve M1 now
                Slave = 1'b1;
            end else begin
                // M1 was served last ? serve M0 now
                Slave = 1'b0;
            end
        end else if (S00_AXI_awvalid) begin
            // Only Master 0 requests
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
    // Track Last Served Master
    // Purpose: Remember which master was served last for round-robin logic
    //==========================================================================
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            // Reset: Start with M1 (so M0 will be first)
            last_served <= 1'b1;
        end else if (Channel_Granted && (S00_AXI_awvalid || S01_AXI_awvalid)) begin
            // Update last served when a transaction is granted
            last_served <= Slave;
        end
        // else: Keep previous value
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

