module Demux_1_2 #(parameter Data_Width ='d1 )(

    input logic                       Selection_Line,
    input logic [Data_Width-1:0]     Input_1,//Write response
   
    output logic [Data_Width-1:0]     Output_1,//Write response
    output logic [Data_Width-1:0]    Output_2 //Write response valid signal

);
    always_comb begin
        if (!Selection_Line) begin
            Output_1=Input_1;
            Output_2='b0;
        end else begin
            Output_1='b0;
            Output_2=Input_1;
        end

    end
endmodule
