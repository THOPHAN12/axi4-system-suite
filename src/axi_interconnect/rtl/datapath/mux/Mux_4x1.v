////////////////////////////////////////////////////////////////////////////////
// Module Name: Mux_4x1
// Description: 4-to-1 Multiplexer for AXI Interconnect
//              Routes data from 4 Slaves to 1 Master (for Read channel)
//
// Selection Logic:
//   - sel = 2'b00 → Route in0
//   - sel = 2'b01 → Route in1
//   - sel = 2'b10 → Route in2
//   - sel = 2'b11 → Route in3
//
// Parameters:
//   - width: Bit width of input/output signals (default: 31)
//
// Usage:
//   - Read Data (RDATA): Route from 4 Slaves → Master
//   - Read Valid (RVALID): Route from 4 Slaves → Master
//   - Read Last (RLAST): Route from 4 Slaves → Master
//   - Read Response (RRESP): Route from 4 Slaves → Master
////////////////////////////////////////////////////////////////////////////////

module Mux_4x1 #(
    parameter width = 31
) (
    //---------------------- Input Ports ----------------------
    input wire [width:0] in0,  // From Slave 0 (M00)
    input wire [width:0] in1,  // From Slave 1 (M01)
    input wire [width:0] in2,  // From Slave 2 (M02)
    input wire [width:0] in3,  // From Slave 3 (M03)
    
    input wire [1:0] sel,      // Selection line (2 bits for 4 inputs)
    
    //---------------------- Output Ports ----------------------
    output reg [width:0] out   // Selected input
);

    //==========================================================================
    // Selection Logic
    //==========================================================================
    always @(*) begin
        case (sel)
            2'b00: out = in0; // Select first input (Slave 0)
            2'b01: out = in1; // Select second input (Slave 1)
            2'b10: out = in2; // Select third input (Slave 2)
            2'b11: out = in3; // Select fourth input (Slave 3)
            default: out = in0; // Default to avoid latch
        endcase
    end

endmodule

