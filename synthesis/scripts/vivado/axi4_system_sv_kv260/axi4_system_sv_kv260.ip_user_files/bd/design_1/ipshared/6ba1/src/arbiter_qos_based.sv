module Qos_Arbiter #(
    parameter Slaves_Num='d2, Slaves_ID_Size=$clog2(Slaves_Num)
) (
    input logic                      ACLK           ,
    input logic                      ARESETN        ,
    input logic                      S00_AXI_awvalid,
    input logic  [3:0]               S00_AXI_awqos  , // for priority transactions
    input logic                      S01_AXI_awvalid,
    input logic  [3:0]               S01_AXI_awqos  , // for priority transactions
    input logic                      Channel_Granted,
    input logic                      Token          ,
    output logic                      Channel_Request,
    output logic [Slaves_ID_Size-1:0] Selected_Slave
);
logic [Slaves_ID_Size-1:0] Slave;
logic Request;
always_comb begin
    if (S01_AXI_awvalid && S00_AXI_awvalid) begin
        if (S00_AXI_awqos >= S01_AXI_awqos) begin
            Slave='b0;
        end else begin
            Slave='b1;
        end

    end else if (S00_AXI_awvalid) begin
        Slave='b0;
    end else if (S01_AXI_awvalid) begin
        Slave='b1;
    end else begin
        Slave='b0;
    end
end

    always_comb begin
        // Request should be asserted when there's a valid request, regardless of Channel_Granted
        // Channel_Granted is used to update Selected_Slave, not to block requests
        if ((S00_AXI_awvalid || S01_AXI_awvalid)) begin
            Request='b1;
        end else begin
            Request='b0;
        end
    end
    assign Channel_Request = Request & (~ Token);
    
    // Debug messages
    logic Selected_Slave_prev;
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Selected_Slave_prev <= 1'b0;
        end else begin
            Selected_Slave_prev <= Selected_Slave;
        end
    end
    
    // Debug messages removed - only keeping essential transaction information
    
    always_ff @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            Selected_Slave<='b0;
        end else if((Channel_Granted & (~ Token)) || (Channel_Request & (~ Token))) begin
            // Update Selected_Slave when channel is granted OR when there's a new request
            // Only update if there's actually a request (Slave is valid)
            if (S00_AXI_awvalid || S01_AXI_awvalid) begin
                Selected_Slave<=Slave;
            end
        end else if ((S00_AXI_awvalid || S01_AXI_awvalid) && !Channel_Granted) begin
            // Also update when there's a request but channel is not granted yet
            // This ensures Selected_Slave is correct when AW_Access_Grant asserts
            Selected_Slave<=Slave;
        end
        // Don't reset Selected_Slave when there's no request - keep the last value
        // This ensures Selected_Slave is correct when AW_Access_Grant asserts after handshake completes
        // Selected_Slave will only change when there's a new request or channel is granted
    end
endmodule
