////////////////////////////////////////////////////////////////////////////////
// Module Name: Read_Arbiter
// Description: QoS-based Arbiter for AXI Read Address Channel
//              Supports QoS priority arbitration between masters
//
// Arbitration Policy:
//   - QoS-based: Higher QoS value has priority
//   - When both masters have same QoS, M0 has priority
//   - Supports 2 masters (can be extended)
//
// Features:
//   + QoS-based priority arbitration
//   + Synchronous reset
//   + Registered output for timing closure
//
// Parameters:
//   - Masters_Num: Number of masters (default: 2)
//   - Masters_ID_Size: Bit width for master ID
////////////////////////////////////////////////////////////////////////////////

module Read_Arbiter #(
    parameter Masters_Num     = 'd2,
    parameter Masters_ID_Size = $clog2(Masters_Num)
) (
    // Clock and Reset
    input logic                      ACLK,
    input logic                      ARESETN,
    
    // Master Request Signals
    input logic                      S00_AXI_arvalid,  // Master 0 read address valid
    input logic [3:0]                S00_AXI_arqos,   // Master 0 QoS
    input logic                      S01_AXI_arvalid,  // Master 1 read address valid
    input logic [3:0]                S01_AXI_arqos,   // Master 1 QoS
    
    // Channel Control
    input logic                      Channel_Granted,  // Channel grant from controller
    input logic                      Token,           // Split transaction token
    
    // Arbitration Result
    output logic                      Channel_Request,  // Request to use channel
    output logic [Masters_ID_Size-1:0] Selected_Master  // Selected master (0=M0, 1=M1)
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    logic [Masters_ID_Size-1:0] Master;  // Combinational master selection
    logic Request;                         // Combinational request signal

    //==========================================================================
    // Master Selection Logic (QoS-based)
    // Priority: Higher QoS > Lower QoS
    // If same QoS: M0 has priority
    // 
    // Truth Table:
    // ??????????????????????????????????????
    // ? M0_valid ? M1_valid ? M0_QoS ? M1_QoS ? Selected ?
    // ??????????????????????????????????????
    // ? 0        ? 0        ? x      ? x      ? M0 (def) ?
    // ? 1        ? 0        ? x      ? x      ? M0       ?
    // ? 0        ? 1        ? x      ? x      ? M1       ?
    // ? 1        ? 1        ? >=     ? <      ? M0       ?
    // ? 1        ? 1        ? <      ? >=     ? M1       ?
    // ? 1        ? 1        ? ==     ? ==     ? M0       ?
    // ??????????????????????????????????????
    //==========================================================================
    always_comb begin
        if (S00_AXI_arvalid && S01_AXI_arvalid) begin
            // Both masters requesting - compare QoS
            if (S00_AXI_arqos >= S01_AXI_arqos) begin
                // M0 has higher or equal QoS - prioritize M0
                Master = 1'b0;
            end else begin
                // M1 has higher QoS - prioritize M1
                Master = 1'b1;
            end
        end else if (S00_AXI_arvalid) begin
            // Only Master 0 requesting
            Master = 1'b0;
        end else if (S01_AXI_arvalid) begin
            // Only Master 1 requesting
            Master = 1'b1;
        end else begin
            // No requests - default to M0
            Master = 1'b0;
        end
    end

    //==========================================================================
    // Channel Request Generation
    // Purpose: Generate request signal when any master wants to use channel
    // Logic: Request = Channel_Granted AND (M0_valid OR M1_valid) AND (~Token)
    // Token prevents new requests during split transactions
    //==========================================================================
    always_comb begin
        if (!Channel_Granted) begin
            // Channel not granted - block request
            Request = 1'b0;
        end else if ((S00_AXI_arvalid || S01_AXI_arvalid) && !Token) begin
            // At least one master requesting and no split transaction - generate request
            Request = 1'b1;
        end else begin
            // No master requesting or split transaction in progress
            Request = 1'b0;
        end
    end

    assign Channel_Request = Request;

    //==========================================================================
    // Register Selected Master
    // Purpose: Register the selected master for timing closure
    // Timing: 1 clock cycle delay from Master to Selected_Master
    //==========================================================================
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            // Reset: Default to Master 0
            Selected_Master <= {Masters_ID_Size{1'b0}};
        end else if (Channel_Granted && !Token) begin
            // Update selected master when channel is granted and no split transaction
            Selected_Master <= Master;
        end
        // else: Hold previous value
    end

endmodule

