//=============================================================================
// Demux_1x4.sv - SystemVerilog
// 1-to-4 Demultiplexer for AXI Interconnect
// Routes data from 1 Master to 4 Slaves (for RREADY)
//
// Selection Logic:
//   - sel = 2'b00 → Route to out0 (Slave 0)
//   - sel = 2'b01 → Route to out1 (Slave 1)
//   - sel = 2'b10 → Route to out2 (Slave 2)
//   - sel = 2'b11 → Route to out3 (Slave 3)
//
// Parameters:
//   - width: Bit width of input/output signals (default: 0 for single bit)
//
// Usage:
//   - RREADY: Route from Master → 4 Slaves based on slave selection
//=============================================================================

`timescale 1ns/1ps

module Demux_1x4 #(
    parameter int unsigned width = 0
) (
    //---------------------- Input Ports ----------------------
    input logic [width:0] in,      // From Master
    
    input logic [1:0] sel,         // Selection line (2 bits for 4 outputs)
    
    //---------------------- Output Ports ----------------------
    output logic [width:0] out0,    // To Slave 0 (M00)
    output logic [width:0] out1,    // To Slave 1 (M01)
    output logic [width:0] out2,    // To Slave 2 (M02)
    output logic [width:0] out3     // To Slave 3 (M03)
);

    //==========================================================================
    // Demultiplex Logic
    //==========================================================================
    always_comb begin
        // Default: All outputs inactive
        out0 = '0;
        out1 = '0;
        out2 = '0;
        out3 = '0;
        
        // Route input to selected output
        case (sel)
            2'b00: out0 = in; // Route to Slave 0
            2'b01: out1 = in; // Route to Slave 1
            2'b10: out2 = in; // Route to Slave 2
            2'b11: out3 = in; // Route to Slave 3
            default: out0 = in; // Default to Slave 0
        endcase
    end

endmodule

