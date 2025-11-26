module Faling_Edge_Detc  (
    input  wire ACLK,
    input  wire ARESETN,
    input  wire Test_Singal,
    output reg  Falling
);

reg reg_Test_Signal;

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        reg_Test_Signal <= 1'b0;
    end else begin
        reg_Test_Signal <= Test_Singal;
    end
end

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        Falling <= 1'b0;
    end else begin
        Falling <= (reg_Test_Signal ^ Test_Singal) & ~(Test_Singal);
    end
end
endmodule
