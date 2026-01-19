module AW_HandShake_Checker
(
    input logic  ACLK,
    input logic  ARESETN,
    input logic  Valid_Signal,
    input logic  Ready_Signal,
    input logic  Channel_Request,
    output logic HandShake_Done 
);

always_ff @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        HandShake_Done<='b1;
    end else if(Channel_Request && !(Valid_Signal && Ready_Signal)) begin
        // Reset HandShake_Done when there's a new request, but not if handshake is completing
        HandShake_Done<='b0;
    end else if(Valid_Signal && Ready_Signal) begin
        // Set HandShake_Done when handshake completes, even if Channel_Request is still high
        HandShake_Done<='b1;
    end
end



endmodule
