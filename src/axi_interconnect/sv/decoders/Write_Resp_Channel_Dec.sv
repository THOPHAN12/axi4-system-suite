//=============================================================================
// Write_Resp_Channel_Dec.sv - SystemVerilog
// Write Response Channel Decoder
//=============================================================================

`timescale 1ns/1ps

module Write_Resp_Channel_Dec #(
    parameter int unsigned Num_Of_Masters = 4,
    parameter int unsigned Master_ID_Width = $clog2(Num_Of_Masters),
    parameter int unsigned M1_ID = 0,
    parameter int unsigned M2_ID = 1,
    parameter int unsigned M3_ID = 2,  // For future expansion
    parameter int unsigned M4_ID = 3   // For future expansion
) (
    input  logic [Master_ID_Width - 1 : 0]  Sel_Resp_ID,
    input  logic [1:0]                      Sel_Write_Resp,
    input  logic                            Sel_Valid,
    
    // Outputs to masters
    // Write Response Channel
    output logic [1:0]                      S01_AXI_bresp,  // Write response
    output logic                             S01_AXI_bvalid, // Write response valid signal
    
    // Slave S00 Ports
    // Write Response Channel
    output logic [1:0]                      S00_AXI_bresp,  // Write response
    output logic                             S00_AXI_bvalid, // Write response valid signal
    
    // S02 (for future expansion)
    output logic [1:0]                      S02_AXI_bresp,
    output logic                             S02_AXI_bvalid,
    
    // S03 (for future expansion)
    output logic [1:0]                      S03_AXI_bresp,
    output logic                             S03_AXI_bvalid
);

    assign S00_AXI_bresp = Sel_Write_Resp;
    assign S01_AXI_bresp = Sel_Write_Resp;
    assign S02_AXI_bresp = Sel_Write_Resp;
    assign S03_AXI_bresp = Sel_Write_Resp;
    
    always_comb begin
        // synthesis parallel_case
        // Note: full_case not used because we have explicit default case
        case (Sel_Resp_ID)
            M1_ID: begin
                S00_AXI_bvalid = Sel_Valid;
                S01_AXI_bvalid = 1'b0;
                S02_AXI_bvalid = 1'b0;
                S03_AXI_bvalid = 1'b0;
            end
            M2_ID: begin
                S00_AXI_bvalid = 1'b0;
                S01_AXI_bvalid = Sel_Valid;
                S02_AXI_bvalid = 1'b0;
                S03_AXI_bvalid = 1'b0;
            end
            // M3_ID and M4_ID are for future expansion when Num_Of_Masters >= 3 or 4
            // These cases may not match when Num_Of_Masters = 2, which is expected
            // Warning note: Quartus may warn that these case items never match when Num_Of_Masters = 2.
            // This is intentional for future multi-master support.
            M3_ID: begin
                S00_AXI_bvalid = 1'b0;
                S01_AXI_bvalid = 1'b0;
                S02_AXI_bvalid = Sel_Valid;
                S03_AXI_bvalid = 1'b0;
            end
            M4_ID: begin
                S00_AXI_bvalid = 1'b0;
                S01_AXI_bvalid = 1'b0;
                S02_AXI_bvalid = 1'b0;
                S03_AXI_bvalid = Sel_Valid;
            end
            default: begin
                S00_AXI_bvalid = 1'b0;
                S01_AXI_bvalid = 1'b0;
                S02_AXI_bvalid = 1'b0;
                S03_AXI_bvalid = 1'b0;
            end
        endcase
    end

endmodule

