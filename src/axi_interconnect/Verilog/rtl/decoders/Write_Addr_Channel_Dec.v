module Write_Addr_Channel_Dec #(
    parameter  Num_OF_Masters='d2,
    parameter  Masters_ID_Size=$clog2(Num_OF_Masters),
    parameter  Address_width='d32,
    parameter  AXI4_Aw_len='d8 ,
   
    
    parameter Num_Of_Slaves = 4,
    parameter Base_Addr_Width = $clog2(Num_Of_Slaves)
) (
    // Ports of the selected master from the arbiter

    input  wire  [Masters_ID_Size-1:0]   Master_AXI_awaddr_ID,
    input  wire  [Address_width-1:0]     Master_AXI_awaddr,// the write address
    input  wire  [AXI4_Aw_len-1:0]        Master_AXI_awlen, // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    input  wire  [2:0]                   Master_AXI_awsize,//number of bytes within the transfer
    input  wire  [1:0]                   Master_AXI_awburst, // burst type
    input  wire  [1:0]                   Master_AXI_awlock , // lock type
    input  wire  [3:0]                   Master_AXI_awcache, // a opptional signal for connecting to diffrent types of  memories
    input  wire  [2:0]                   Master_AXI_awprot ,// identifies the level of protection
    input  wire  [3:0]                   Master_AXI_awqos  , // for priority transactions
    input  wire                          Master_AXI_awvalid, // Address write valid signal 
    
    output reg   [Masters_ID_Size-1:0]   M00_AXI_awaddr_ID,
    output reg  [Address_width-1:0]      M00_AXI_awaddr,
    output reg  [AXI4_Aw_len-1:0]        M00_AXI_awlen ,
    output reg  [2:0]                    M00_AXI_awsize,  //number of bytes within the transfer
    output reg  [1:0]                    M00_AXI_awburst,// burst type
    output reg  [1:0]                    M00_AXI_awlock ,// lock type
    output reg  [3:0]                    M00_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output reg  [2:0]                    M00_AXI_awprot ,// identifies the level of protection
    output reg  [3:0]                    M00_AXI_awqos  , // for priority transactions
    output reg                           M00_AXI_awvalid,// Address write valid signal 
    input  wire                          M00_AXI_awready,// Address write ready signal 

    output reg   [Masters_ID_Size-1:0]   M01_AXI_awaddr_ID,
    output reg  [Address_width-1:0]      M01_AXI_awaddr,
    output reg  [AXI4_Aw_len-1:0]        M01_AXI_awlen ,
    output reg  [2:0]                    M01_AXI_awsize,  //number of bytes within the transfer
    output reg  [1:0]                    M01_AXI_awburst,// burst type
    output reg  [1:0]                    M01_AXI_awlock ,// lock type
    output reg  [3:0]                    M01_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output reg  [2:0]                    M01_AXI_awprot ,// identifies the level of protection
    output reg  [3:0]                    M01_AXI_awqos  , // for priority transactions
    output reg                           M01_AXI_awvalid,// Address write valid signal 
    input  wire                          M01_AXI_awready,// Address write ready signal 



    output reg   [Masters_ID_Size-1:0]   M02_AXI_awaddr_ID,
    output reg  [Address_width-1:0]      M02_AXI_awaddr,
    output reg  [AXI4_Aw_len-1:0]        M02_AXI_awlen ,
    output reg  [2:0]                    M02_AXI_awsize,  //number of bytes within the transfer
    output reg  [1:0]                    M02_AXI_awburst,// burst type
    output reg  [1:0]                    M02_AXI_awlock ,// lock type
    output reg  [3:0]                    M02_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output reg  [2:0]                    M02_AXI_awprot ,// identifies the level of protection
    output reg  [3:0]                    M02_AXI_awqos  , // for priority transactions
    output reg                           M02_AXI_awvalid,// Address write valid signal 
    input  wire                          M02_AXI_awready,// Address write ready signal 

    output reg   [Masters_ID_Size-1:0]   M03_AXI_awaddr_ID,
    output reg  [Address_width-1:0]      M03_AXI_awaddr,
    output reg  [AXI4_Aw_len-1:0]        M03_AXI_awlen ,
    output reg  [2:0]                    M03_AXI_awsize,  //number of bytes within the transfer
    output reg  [1:0]                    M03_AXI_awburst,// burst type
    output reg  [1:0]                    M03_AXI_awlock ,// lock type
    output reg  [3:0]                    M03_AXI_awcache,// a opptional signal for connecting to diffrent types of  memories
    output reg  [2:0]                    M03_AXI_awprot ,// identifies the level of protection
    output reg  [3:0]                    M03_AXI_awqos  , // for priority transactions
    output reg                           M03_AXI_awvalid,// Address write valid signal 
    input  wire                          M03_AXI_awready,// Address write ready signal 



    output reg                           Sel_Slave_Ready,
    output reg [Num_Of_Slaves - 1 : 0]   Q_Enables
);


localparam Slave0_Base_Addr = 2'b00,
           Slave1_Base_Addr = 2'b01,
           Slave2_Base_Addr = 2'b10,
           Slave3_Base_Addr = 2'b11;
wire [Base_Addr_Width - 1 : 0] Base_Addr_Master;
assign Base_Addr_Master = Master_AXI_awaddr[Address_width-1:Address_width-Base_Addr_Width];

// Debug visibility for write address decoding
always @(*) begin
    if (Master_AXI_awvalid) begin
        $display("[%0t] WRITE_DEC: addr=0x%08h base_addr=%02b -> Slave%0d",
                 $time, Master_AXI_awaddr, Base_Addr_Master, Base_Addr_Master);
    end
end


always @(*) begin
    // Default values - All outputs should have default to avoid multiple drivers
    M00_AXI_awvalid = 1'b0;
    M01_AXI_awvalid = 1'b0;
    M02_AXI_awvalid = 1'b0;
    M03_AXI_awvalid = 1'b0;
    Q_Enables = 4'b0000;
    Sel_Slave_Ready = 1'b0;
    
    // Default address/data signals
    M00_AXI_awaddr_ID = {Masters_ID_Size{1'b0}};
    M00_AXI_awaddr = {Address_width{1'b0}};
    M00_AXI_awlen = {AXI4_Aw_len{1'b0}};
    M00_AXI_awsize = 3'b0;
    M00_AXI_awburst = 2'b0;
    M00_AXI_awlock = 2'b0;
    M00_AXI_awcache = 4'b0;
    M00_AXI_awprot = 3'b0;
    M00_AXI_awqos = 4'b0;
    
    M01_AXI_awaddr_ID = {Masters_ID_Size{1'b0}};
    M01_AXI_awaddr = {Address_width{1'b0}};
    M01_AXI_awlen = {AXI4_Aw_len{1'b0}};
    M01_AXI_awsize = 3'b0;
    M01_AXI_awburst = 2'b0;
    M01_AXI_awlock = 2'b0;
    M01_AXI_awcache = 4'b0;
    M01_AXI_awprot = 3'b0;
    M01_AXI_awqos = 4'b0;
    
    M02_AXI_awaddr_ID = {Masters_ID_Size{1'b0}};
    M02_AXI_awaddr = {Address_width{1'b0}};
    M02_AXI_awlen = {AXI4_Aw_len{1'b0}};
    M02_AXI_awsize = 3'b0;
    M02_AXI_awburst = 2'b0;
    M02_AXI_awlock = 2'b0;
    M02_AXI_awcache = 4'b0;
    M02_AXI_awprot = 3'b0;
    M02_AXI_awqos = 4'b0;
    
    M03_AXI_awaddr_ID = {Masters_ID_Size{1'b0}};
    M03_AXI_awaddr = {Address_width{1'b0}};
    M03_AXI_awlen = {AXI4_Aw_len{1'b0}};
    M03_AXI_awsize = 3'b0;
    M03_AXI_awburst = 2'b0;
    M03_AXI_awlock = 2'b0;
    M03_AXI_awcache = 4'b0;
    M03_AXI_awprot = 3'b0;
    M03_AXI_awqos = 4'b0;
    
    case (Base_Addr_Master)
            Slave0_Base_Addr: begin
            Q_Enables = 4'b0001;

                    Sel_Slave_Ready =M00_AXI_awready;
                    M00_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M00_AXI_awaddr =Master_AXI_awaddr;
                    M00_AXI_awlen=Master_AXI_awlen;
                    M00_AXI_awsize=Master_AXI_awsize;
                    M00_AXI_awburst=Master_AXI_awburst;
                    M00_AXI_awlock=Master_AXI_awlock;
                    M00_AXI_awcache=Master_AXI_awcache;
                    M00_AXI_awprot=Master_AXI_awprot;
                    M00_AXI_awqos=Master_AXI_awqos;
                    M00_AXI_awvalid = Master_AXI_awvalid;    
                   end

           Slave1_Base_Addr: begin
            Q_Enables = 4'b0010;
            Sel_Slave_Ready = M01_AXI_awready;

                    M01_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M01_AXI_awaddr =Master_AXI_awaddr;
                    M01_AXI_awlen=Master_AXI_awlen;
                    M01_AXI_awsize=Master_AXI_awsize;
                    M01_AXI_awburst=Master_AXI_awburst;
                    M01_AXI_awlock=Master_AXI_awlock;
                    M01_AXI_awcache=Master_AXI_awcache;
                    M01_AXI_awprot=Master_AXI_awprot;
                    M01_AXI_awqos=Master_AXI_awqos;
                    M01_AXI_awvalid = Master_AXI_awvalid;
                    M00_AXI_awvalid = 'b0; 
                    M02_AXI_awvalid = 'b0; 
                    M03_AXI_awvalid = 'b0; 

                  end  
            

Slave2_Base_Addr: begin
            Q_Enables = 4'b0100;
            Sel_Slave_Ready = M02_AXI_awready;

                    M02_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M02_AXI_awaddr =Master_AXI_awaddr;
                    M02_AXI_awlen=Master_AXI_awlen;
                    M02_AXI_awsize=Master_AXI_awsize;
                    M02_AXI_awburst=Master_AXI_awburst;
                    M02_AXI_awlock=Master_AXI_awlock;
                    M02_AXI_awcache=Master_AXI_awcache;
                    M02_AXI_awprot=Master_AXI_awprot;
                    M02_AXI_awqos=Master_AXI_awqos;
                    M02_AXI_awvalid = Master_AXI_awvalid;
                    M00_AXI_awvalid = 'b0; 
		    M01_AXI_awvalid = 'b0; 
                    M03_AXI_awvalid = 'b0; 

                  end  
Slave3_Base_Addr: begin
            Q_Enables = 4'b1000;
            Sel_Slave_Ready = M03_AXI_awready;

                    M03_AXI_awaddr_ID=Master_AXI_awaddr_ID;
                    M03_AXI_awaddr =Master_AXI_awaddr;
                    M03_AXI_awlen=Master_AXI_awlen;
                    M03_AXI_awsize=Master_AXI_awsize;
                    M03_AXI_awburst=Master_AXI_awburst;
                    M03_AXI_awlock=Master_AXI_awlock;
                    M03_AXI_awcache=Master_AXI_awcache;
                    M03_AXI_awprot=Master_AXI_awprot;
                    M03_AXI_awqos=Master_AXI_awqos;
                    M03_AXI_awvalid = Master_AXI_awvalid;
                    M00_AXI_awvalid = 'b0; 
		    M01_AXI_awvalid = 'b0; 
                    M02_AXI_awvalid = 'b0; 

                  end  






default: begin
            Q_Enables = 4'b0001;
            M00_AXI_awvalid = Master_AXI_awvalid;
        end
    endcase
end
endmodule

//    if (!rst) begin

    //     Write_Addr_Channel_To_Slave0 <= {{(Write_Address_Channel_width-1){1'b0}}, 1'b0}; 
    //     Write_Addr_Channel_To_Slave1 <= {{(Write_Address_Channel_width-1){1'b0}}, 1'b0}; 
    //     Write_Addr_Channel_To_Slave2 <= {{(Write_Address_Channel_width-1){1'b0}}, 1'b0};

    //  end
    // else 


