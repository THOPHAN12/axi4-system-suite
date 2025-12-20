module WD_MUX_2_1 #(parameter S_Write_data_bus_width='d32,S_Write_data_bytes_num=S_Write_data_bus_width/8

) (
    input logic                          Selected_Slave,

    input logic  [S_Write_data_bus_width-1:0]   S00_AXI_wdata,//Write data bus
    input logic  [S_Write_data_bytes_num-1:0]   S00_AXI_wstrb, // strops identifes the active data lines
    input logic                                 S00_AXI_wlast, // last signal to identify the last transfer in a burst
    input logic                                 S00_AXI_wvalid, // write valid signal
   
    input logic  [S_Write_data_bus_width-1:0]   S01_AXI_wdata,//Write data bus
    input logic  [S_Write_data_bytes_num-1:0]   S01_AXI_wstrb, // strops identifes the active data lines
    input logic                                 S01_AXI_wlast, // last signal to identify the last transfer in a burst
    input logic                                 S01_AXI_wvalid, // write valid signal
   
    output logic [S_Write_data_bus_width-1:0]   Sel_S_AXI_wdata,//Write data bus
    output logic [S_Write_data_bytes_num-1:0]   Sel_S_AXI_wstrb, // strops identifes the active data lines
    output logic Sel_S_AXI_wlast, // last signal to identify the last transfer in a burst
    output logic Sel_S_AXI_wvalid // write valid signal
    
);


always_comb begin
    if (!Selected_Slave) begin
        Sel_S_AXI_wdata=S00_AXI_wdata;
        Sel_S_AXI_wstrb=S00_AXI_wstrb;
        Sel_S_AXI_wlast=S00_AXI_wlast;
        Sel_S_AXI_wvalid=S00_AXI_wvalid;
    end else begin
        Sel_S_AXI_wdata=S01_AXI_wdata;
        Sel_S_AXI_wstrb=S01_AXI_wstrb;
        Sel_S_AXI_wlast=S01_AXI_wlast;
        Sel_S_AXI_wvalid=S01_AXI_wvalid;
    end

end
    
endmodule
