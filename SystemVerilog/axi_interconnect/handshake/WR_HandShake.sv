module WR_HandShake  (
    input logic  ACLK,
    input logic  ARESETN,
    input logic  Valid_Signal,
    input logic  Ready_Signal,
    input logic  HandShake_En,
    output logic HandShake_Done  
);
    always_ff @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        HandShake_Done<='b1;
    end else if(HandShake_En) begin
        HandShake_Done<='b0;
    end else if(Valid_Signal && Ready_Signal) begin
        HandShake_Done<='b1;
    end
end

endmodule





