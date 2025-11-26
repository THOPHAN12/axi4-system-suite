//=============================================================================
// BReady_MUX_2_1.sv - SystemVerilog
// Write Response Ready MUX (2-to-1)
//=============================================================================

`timescale 1ns/1ps

module BReady_MUX_2_1 (
    input  logic Selected_Slave,
    input  logic S00_AXI_bready,
    input  logic S01_AXI_bready,
    output logic Sele_S_AXI_bready
);

    always_comb begin
        if (!Selected_Slave) begin
            Sele_S_AXI_bready = S00_AXI_bready;
        end else begin
            Sele_S_AXI_bready = S01_AXI_bready;
        end
    end

endmodule

