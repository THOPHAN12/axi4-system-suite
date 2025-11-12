module AXI_Interconnect_tb #(
    parameter Address_width='d32,Masters_Num='d2,Slaves_ID_Size=$clog2(Masters_Num),
          S00_Aw_len='d8,//!AXI4 - 8 bits for burst length
          S00_Write_data_bus_width='d32,S00_Write_data_bytes_num=S00_Write_data_bus_width/8,
          S00_AR_len='d8, //!AXI4 - 8 bits for burst length
          S00_Read_data_bus_width='d32,
          S01_Aw_len='d8,//!AXI4 - 8 bits for burst length
          S01_AR_len='d8, //!AXI4 - 8 bits for burst length
          M00_Aw_len='d8,//!AXI4 - 8 bits for burst length
          M00_Write_data_bus_width='d32,M00_Write_data_bytes_num=M00_Write_data_bus_width/8,
          M00_AR_len='d8, //!AXI4 - 8 bits for burst length   
          M00_Read_data_bus_width='d32,
          M01_Aw_len='d8,//!AXI4 - 8 bits for burst length
          M01_AR_len='d8, //!AXI4 - 8 bits for burst length
          Num_Of_Masters='d2,Master_ID_Width=$clog2(Num_Of_Masters)
) ();
/*                   /****** Slave S01 Ports *******/
                    /******************************/
    //* Slave General Port;
    reg                            S01_ACLK;
    reg                            S01_ARESETN;
    //* Address Write Channel
    reg    [Address_width-1:0]     S01_AXI_awaddr;// the write address
    reg    [S01_Aw_len-1:0]        S01_AXI_awlen; // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    reg    [2:0]                   S01_AXI_awsize;//number of bytes within the transfer
    reg    [1:0]                   S01_AXI_awburst; // burst type
    reg    [1:0]                   S01_AXI_awlock ; // lock type
    reg    [3:0]                   S01_AXI_awcache; // a opptional signal for connecting to diffrent types of  memories
    reg    [2:0]                   S01_AXI_awprot ;// identifies the level of protection
    reg    [3:0]                   S01_AXI_awqos  ; // for priority transactions
    reg                            S01_AXI_awvalid; // Address write valid signal 
    wire                           S01_AXI_awready; // Address write ready signal 

    //* Write Data Channel
    
    reg    [S00_Write_data_bus_width-1:0]   S01_AXI_wdata;//Write data bus
    reg    [S00_Write_data_bytes_num-1:0]   S01_AXI_wstrb; // strops identifes the active data lines
    reg                                     S01_AXI_wlast; // last signal to identify the last transfer in a burst
    reg                                     S01_AXI_wvalid; // write valid signal
    wire                                    S01_AXI_wready; // write ready signal

    //*Write Response Channel
    wire  [1:0]                    S01_AXI_bresp;//Write response
    wire                           S01_AXI_bvalid; //Write response valid signal
    reg                            S01_AXI_bready; //Write response ready signal

    //*Address Read Channel
    reg    [Address_width-1:0]     S01_AXI_araddr;// the write address
    reg    [S01_AR_len-1:0]        S01_AXI_arlen; // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    reg    [2:0]                   S01_AXI_arsize;//number of bytes within the transfer
    reg    [1:0]                   S01_AXI_arburst; // burst type
    reg    [1:0]                   S01_AXI_arlock ; // lock type
    reg    [3:0]                   S01_AXI_arcache; // a opptional signal for connecting to diffrent types of  memories
    reg    [2:0]                   S01_AXI_arprot ;// identifies the level of protection
    reg    [3:0]                   S01_AXI_arregion; // AXI4 region signal
    reg    [3:0]                   S01_AXI_arqos  ; // for priority transactions
    reg                            S01_AXI_arvalid; // Address write valid signal 
    wire                           S01_AXI_arready; // Address write ready signal 
    
    //*Read Data Channel
    wire   [S00_Read_data_bus_width-1:0]  S01_AXI_rdata;//Read Data Bus
    wire   [1:0]                          S01_AXI_rresp; // Read Response
    wire                                  S01_AXI_rlast; // Read Last Signal
    wire                                  S01_AXI_rvalid; // Read Valid Signal 
    reg                                   S01_AXI_rready; // Read Ready Signal
/*                /***** Interconnect Ports *****/
                    /******************************/
    reg                            ACLK;
    reg                            ARESETN;
                
/*                /****** Slave S00 Ports *******/
                    /******************************/
    //* Slave General Ports
    reg                            S00_ACLK;
    reg                            S00_ARESETN;
    //* Address Write Channel
    reg    [Address_width-1:0]     S00_AXI_awaddr;// the write address
    reg    [S00_Aw_len-1:0]        S00_AXI_awlen ; // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    reg    [2:0]                   S00_AXI_awsize ;//number of bytes within the transfer
    reg    [1:0]                   S00_AXI_awburst; // burst type
    reg    [1:0]                   S00_AXI_awlock ; // lock type
    reg    [3:0]                   S00_AXI_awcache; // a opptional signal for connecting to diffrent types of  memories
    reg    [2:0]                   S00_AXI_awprot ;// identifies the level of protection
    reg    [3:0]                   S00_AXI_awqos  ; // for priority transactions
    reg                            S00_AXI_awvalid; // Address write valid signal 
    wire                           S00_AXI_awready; // Address write ready signal 

    //* Write Data Channel
    
    reg    [S00_Write_data_bus_width-1:0]   S00_AXI_wdata;//Write data bus
    reg    [S00_Write_data_bytes_num-1:0]   S00_AXI_wstrb; // strops identifes the active data lines
    reg                                     S00_AXI_wlast; // last signal to identify the last transfer in a burst
    reg                                     S00_AXI_wvalid; // write valid signal
    wire                                    S00_AXI_wready; // write ready signal

    //*Write Response Channel
    wire  [1:0]                    S00_AXI_bresp;//Write response
    wire                           S00_AXI_bvalid; //Write response valid signal
    reg                            S00_AXI_bready; //Write response ready signal

    //*Address Read Channel
    reg    [Address_width-1:0]     S00_AXI_araddr;// the write address
    reg    [S00_AR_len-1:0]        S00_AXI_arlen; // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    reg    [2:0]                   S00_AXI_arsize;//number of bytes within the transfer
    reg    [1:0]                   S00_AXI_arburst; // burst type
    reg    [1:0]                   S00_AXI_arlock ; // lock type
    reg    [3:0]                   S00_AXI_arcache; // a opptional signal for connecting to diffrent types of  memories
    reg    [2:0]                   S00_AXI_arprot ;// identifies the level of protection
    reg    [3:0]                   S00_AXI_arregion; // AXI4 region signal
    reg    [3:0]                   S00_AXI_arqos  ; // for priority transactions
    reg                            S00_AXI_arvalid; // Address write valid signal 
    wire                           S00_AXI_arready; // Address write ready signal 
    
    //*Read Data Channel
    wire   [S00_Read_data_bus_width-1:0]  S00_AXI_rdata;//Read Data Bus
    wire   [1:0]                          S00_AXI_rresp; // Read Response
    wire                                  S00_AXI_rlast; // Read Last Signal
    wire                                  S00_AXI_rvalid; // Read Valid Signal 
    reg                                   S00_AXI_rready; // Read Ready Signal 

/*                /****** Master M00 Ports *****/   
                  /*****************************/
    //* Slave General Ports
    reg                            M00_ACLK;
    reg                            M00_ARESETN;

    //* Address Write Channel              
    wire  [Slaves_ID_Size-1:0]     M00_AXI_awaddr_ID;
    wire  [Address_width-1:0]      M00_AXI_awaddr;
    wire  [M00_Aw_len-1:0]         M00_AXI_awlen ;
    wire  [2:0]                    M00_AXI_awsize;  //number of bytes within the transfer
    wire  [1:0]                    M00_AXI_awburst;// burst type
    wire  [1:0]                    M00_AXI_awlock ;// lock type
    wire  [3:0]                    M00_AXI_awcache;// a opptional signal for connecting to diffrent types of  memories
    wire  [2:0]                    M00_AXI_awprot ;// identifies the level of protection
    wire  [3:0]                    M00_AXI_awqos  ; // for priority transactions
    wire                           M00_AXI_awvalid;// Address write valid signal 
    reg                            M00_AXI_awready;// Address write ready signal 
    
    //* Write Data Channel
    wire   [M00_Write_data_bus_width-1:0]   M00_AXI_wdata;//Write data bus
    wire   [M00_Write_data_bytes_num-1:0]   M00_AXI_wstrb; // strops identifes the active data lines
    wire                                    M00_AXI_wlast; // last signal to identify the last transfer in a burst
    wire                                    M00_AXI_wvalid; // write valid signal
    reg                                     M00_AXI_wready; // write ready signal

    //*Write Response Channel
    reg  [Master_ID_Width-1:0]     M00_AXI_BID  ;
    reg  [1:0]                     M00_AXI_bresp;//Write response
    reg                            M00_AXI_bvalid; //Write response valid signal
    wire                           M00_AXI_bready; //Write response ready signal

    //*Address Read Channel
    wire   [Address_width-1:0]     M00_AXI_araddr;// the write address
    wire   [M00_AR_len-1:0]        M00_AXI_arlen; // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    wire   [2:0]                   M00_AXI_arsize;//number of bytes within the transfer
    wire   [1:0]                   M00_AXI_arburst; // burst type
    wire   [1:0]                   M00_AXI_arlock ; // lock type
    wire   [3:0]                   M00_AXI_arcache; // a opptional signal for connecting to diffrent types of  memories
    wire   [2:0]                   M00_AXI_arprot ;// identifies the level of protection
    wire   [3:0]                   M00_AXI_arregion; // AXI4 region signal
    wire   [3:0]                   M00_AXI_arqos  ; // for priority transactions
    wire                           M00_AXI_arvalid; // Address write valid signal 
    reg                            M00_AXI_arready; // Address write ready signal 

    //*Read Data Channel
    reg    [M00_Read_data_bus_width-1:0]  M00_AXI_rdata;//Read Data Bus
    reg    [1:0]                          M00_AXI_rresp; // Read Response
    reg                                   M00_AXI_rlast; // Read Last Signal
    reg                                   M00_AXI_rvalid; // Read Valid Signal 
    wire                                  M00_AXI_rready; // Read Ready Signal


/*                /****** Master M0 Ports *****/   
                  /*****************************/
    //* Slave General Ports
    reg                            M01_ACLK;
    reg                            M01_ARESETN;

    //* Address Write Channel              
    wire  [Slaves_ID_Size-1:0]     M01_AXI_awaddr_ID;
    wire  [Address_width-1:0]      M01_AXI_awaddr;
    wire  [M01_Aw_len-1:0]         M01_AXI_awlen ;
    wire  [2:0]                    M01_AXI_awsize;  //number of bytes within the transfer
    wire  [1:0]                    M01_AXI_awburst;// burst type
    wire  [1:0]                    M01_AXI_awlock ;// lock type
    wire  [3:0]                    M01_AXI_awcache;// a opptional signal for connecting to diffrent types of  memories
    wire  [2:0]                    M01_AXI_awprot ;// identifies the level of protection
    wire  [3:0]                    M01_AXI_awqos  ; // for priority transactions
    wire                           M01_AXI_awvalid;// Address write valid signal 
    reg                            M01_AXI_awready;// Address write ready signal 
    
    //* Write Data Channel
    wire   [M00_Write_data_bus_width-1:0]   M01_AXI_wdata;//Write data bus
    wire   [M00_Write_data_bytes_num-1:0]   M01_AXI_wstrb; // strops identifes the active data lines
    wire                                    M01_AXI_wlast; // last signal to identify the last transfer in a burst
    wire                                    M01_AXI_wvalid; // write valid signal
    reg                                     M01_AXI_wready; // write ready signal

    //*Write Response Channel
    reg  [Master_ID_Width-1:0]      M01_AXI_BID  ;
    reg  [1:0]                      M01_AXI_bresp;//Write response
    reg                            M01_AXI_bvalid; //Write response valid signal
    wire                           M01_AXI_bready; //Write response ready signal

    //*Address Read Channel
    wire   [Address_width-1:0]     M01_AXI_araddr;// the write address
    wire   [M01_AR_len-1:0]        M01_AXI_arlen; // number of transfer per burst //! For AXI4 limit is 256 for inc bursts only 
    wire   [2:0]                   M01_AXI_arsize;//number of bytes within the transfer
    wire   [1:0]                   M01_AXI_arburst; // burst type
    wire   [1:0]                   M01_AXI_arlock ; // lock type
    wire   [3:0]                   M01_AXI_arcache; // a opptional signal for connecting to diffrent types of  memories
    wire   [2:0]                   M01_AXI_arprot ;// identifies the level of protection
    wire   [3:0]                   M01_AXI_arregion; // AXI4 region signal
    wire   [3:0]                   M01_AXI_arqos  ; // for priority transactions
    wire                           M01_AXI_arvalid; // Address write valid signal 
    reg                            M01_AXI_arready; // Address write ready signal 

    //*Read Data Channel
    reg    [M00_Read_data_bus_width-1:0]  M01_AXI_rdata;//Read Data Bus
    reg    [1:0]                          M01_AXI_rresp; // Read Response
    reg                                   M01_AXI_rlast; // Read Last Signal
    reg                                   M01_AXI_rvalid; // Read Valid Signal 
    wire                                  M01_AXI_rready; // Read Ready Signal

/*                /****** Master M02 Ports *****/   
                  /*****************************/
    //* Slave General Ports
    reg                            M02_ACLK;
    reg                            M02_ARESETN;

    //*Address Read Channel
    wire   [Address_width-1:0]     M02_AXI_araddr;// the write address
    wire   [M00_AR_len-1:0]        M02_AXI_arlen; // number of transfer per burst
    wire   [2:0]                   M02_AXI_arsize;//number of bytes within the transfer
    wire   [1:0]                   M02_AXI_arburst; // burst type
    wire   [1:0]                   M02_AXI_arlock ; // lock type
    wire   [3:0]                   M02_AXI_arcache; // a opptional signal for connecting to diffrent types of  memories
    wire   [2:0]                   M02_AXI_arprot ;// identifies the level of protection
    wire   [3:0]                   M02_AXI_arregion; // AXI4 region signal
    wire   [3:0]                   M02_AXI_arqos  ; // for priority transactions
    wire                           M02_AXI_arvalid; // Address write valid signal 
    reg                            M02_AXI_arready; // Address write ready signal 

    //*Read Data Channel
    reg    [M00_Read_data_bus_width-1:0]  M02_AXI_rdata;//Read Data Bus
    reg    [1:0]                          M02_AXI_rresp; // Read Response
    reg                                   M02_AXI_rlast; // Read Last Signal
    reg                                   M02_AXI_rvalid; // Read Valid Signal 
    wire                                  M02_AXI_rready; // Read Ready Signal

/*                /****** Master M03 Ports *****/   
                  /*****************************/
    //* Slave General Ports
    reg                            M03_ACLK;
    reg                            M03_ARESETN;

    //*Address Read Channel
    wire   [Address_width-1:0]     M03_AXI_araddr;// the write address
    wire   [M00_AR_len-1:0]        M03_AXI_arlen; // number of transfer per burst
    wire   [2:0]                   M03_AXI_arsize;//number of bytes within the transfer
    wire   [1:0]                   M03_AXI_arburst; // burst type
    wire   [1:0]                   M03_AXI_arlock ; // lock type
    wire   [3:0]                   M03_AXI_arcache; // a opptional signal for connecting to diffrent types of  memories
    wire   [2:0]                   M03_AXI_arprot ;// identifies the level of protection
    wire   [3:0]                   M03_AXI_arregion; // AXI4 region signal
    wire   [3:0]                   M03_AXI_arqos  ; // for priority transactions
    wire                           M03_AXI_arvalid; // Address write valid signal 
    reg                            M03_AXI_arready; // Address write ready signal 

    //*Read Data Channel
    reg    [M00_Read_data_bus_width-1:0]  M03_AXI_rdata;//Read Data Bus
    reg    [1:0]                          M03_AXI_rresp; // Read Response
    reg                                   M03_AXI_rlast; // Read Last Signal
    reg                                   M03_AXI_rvalid; // Read Valid Signal 
    wire                                  M03_AXI_rready; // Read Ready Signal


/* Clock Def*/
parameter Interconnect_Clock_Period = 10;
always #(Interconnect_Clock_Period/2) ACLK =~ ACLK;

parameter S00_Clock_Period = 10;
always #(S00_Clock_Period/2) S00_ACLK =~ S00_ACLK;

parameter S01_Clock_Period = 10;
always #(S01_Clock_Period/2) S01_ACLK =~ S01_ACLK;

parameter M00_Clock_Period = 10;
always #(M00_Clock_Period/2) M00_ACLK =~ M00_ACLK;

parameter M01_Clock_Period = 10;
always #(M01_Clock_Period/2) M01_ACLK =~ M01_ACLK;

parameter M02_Clock_Period = 10;
always #(M02_Clock_Period/2) M02_ACLK =~ M02_ACLK;

parameter M03_Clock_Period = 10;
always #(M03_Clock_Period/2) M03_ACLK =~ M03_ACLK;

integer i;

// Test statistics
integer test_pass_count = 0;
integer test_fail_count = 0;
integer total_tests = 0;
integer test_pass_count_sub = 0;
integer test_fail_count_sub = 0;

initial begin
    // Print header
    $display("\n");
    $display("********************************************************************************");
    $display("*                   AXI INTERCONNECT TESTBENCH - SIMULATION                    *");
    $display("********************************************************************************");
    $display("\n");
    
    // Print configuration
    $display("********************************************************************************");
    $display("* CONFIGURATION                                                                *");
    $display("********************************************************************************");
    $display("* Address Width           : %0d bits", Address_width);
    $display("* Number of Masters       : %0d", Num_Of_Masters);
    $display("* Number of Slaves        : 4 (S00, S01, M02, M03)");
    $display("* Interconnect Clock      : %0t ns period", Interconnect_Clock_Period);
    $display("********************************************************************************");
    $display("\n");
    
    $display("********************************************************************************");
    $display("* INITIALIZATION                                                               *");
    $display("********************************************************************************");
    $display("* [%0t] Starting initialization...", $time);
    
    // Reset assertion
    ARESETN='b0;
    S00_ARESETN='b0;
    S01_ARESETN='b0;
    M00_ARESETN='b0;
    M01_ARESETN='b0;
    M02_ARESETN='b0;
    M03_ARESETN='b0;
    $display("* [%0t] All resets asserted (ARESETN = 0)", $time);

    // Clock initialization
    ACLK='b1;
    S00_ACLK='b1;
    S01_ACLK='b1;
    M00_ACLK='b1;
    M01_ACLK='b1;
    M02_ACLK='b1;
    M03_ACLK='b1;
    $display("* [%0t] All clocks initialized", $time);

    // Stimulus initialization
    S00_Stim('h0AAAAAAA,'h0,'b0,'b0,'b0);
    S01_Stim('h0AAAAAAA,'h0,'b0,'b0,'b0);
    S00_AXI_wlast='b0;
    S01_AXI_wlast='b0;
    // Initialize arregion signals
    S00_AXI_arregion = 4'b0;
    S01_AXI_arregion = 4'b0;
    $display("* [%0t] Stimulus signals initialized", $time);
    
    // Master initialization
    $display("* [%0t] Initializing Master 0 (M00)...", $time);
    M00_Init();
    $display("* [%0t] Initializing Master 1 (M01)...", $time);
    M01_Init();
    $display("* [%0t] Initializing Master 2 (M02)...", $time);
    M02_Init();
    $display("* [%0t] Initializing Master 3 (M03)...", $time);
    M03_Init();
    
    // Wait before deasserting reset
    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Waiting 2 clock cycles...", $time);
    
    // Reset deassertion
    ARESETN='b1;
    S00_ARESETN='b1;
    S01_ARESETN='b1;
    M00_ARESETN='b1;
    M01_ARESETN='b1;
    M02_ARESETN='b1;
    M03_ARESETN='b1;
    $display("* [%0t] All resets deasserted (ARESETN = 1)", $time);
    $display("* [%0t] Initialization complete!", $time);
    $display("********************************************************************************");
    $display("\n");

    //Slave_1();
    //Slave_2();
    //M0_2_S0_and_M1_2_S1();
    
    //Write_Data_LARGE_Burst_S01();
    
    // Run QoS Test
    $display("********************************************************************************");
    $display("* STARTING TESTS                                                               *");
    $display("********************************************************************************");
    $display("\n");
    
    total_tests = total_tests + 1;
    QoS_Test();
    
    // Print test summary
    $display("\n");
    $display("********************************************************************************");
    $display("*                           TEST SUMMARY                                       *");
    $display("********************************************************************************");
    $display("* Total Main Tests Executed: %0d", total_tests);
    $display("* Sub-tests PASSED         : %0d", test_pass_count_sub);
    $display("* Sub-tests FAILED         : %0d", test_fail_count_sub);
    if (test_pass_count_sub + test_fail_count_sub > 0) begin
        $display("* Success Rate             : %.2f%%", 
                 100.0 * test_pass_count_sub / (test_pass_count_sub + test_fail_count_sub));
    end else begin
        $display("* Success Rate             : N/A (No sub-tests executed)");
    end
    $display("********************************************************************************");
    $display("\n");

    $stop;






end

task M0_2_S0_and_M1_2_S1();
begin
    S01_Stim('b10000000000000000000000000000000,'hFFFFFFFF,'d0,'b01,'b0);
    S01_AXI_awvalid='b1;
    repeat(1)#Interconnect_Clock_Period;
    S00_Stim('h0AAAAAAA,'hAAAAAAAA,'b0,'b0,'b0);
    S00_AXI_awvalid='b1;
    repeat(5)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    M01_AXI_awready='b1;
    @(posedge ACLK) ;
    if(M01_AXI_awready==S01_AXI_awvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("#1 Tranfer from S01 Burst Failed");
    end

    @(posedge ACLK) ;
    if(M00_AXI_awready==S00_AXI_awvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S00_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("#1 Tranfer from S01 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b1;

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_wready='b1;
    repeat(2)#Interconnect_Clock_Period;
    S01_AXI_wvalid='b1;
    S01_AXI_wlast='b1;
    @(posedge ACLK) 
    if(M01_AXI_wready==S01_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_wready='b0;
    S01_AXI_wvalid='b0;
    S01_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S01 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b1;
    @(posedge ACLK) 
    if(M00_AXI_wready==S00_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    S00_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S00 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    M00_AXI_BID='b0;
    repeat(3)#Interconnect_Clock_Period;
    S00_AXI_bready='b1;
    @(posedge ACLK) 
    if(M00_AXI_bvalid==S00_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    S00_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Response at S00 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    M01_AXI_bresp='b00;
    M01_AXI_bvalid='b1;
    M01_AXI_BID='b1;
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    @(posedge ACLK) 
    if(M01_AXI_bvalid==S01_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    S01_AXI_bready='b0;
    M01_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Response at S00 Burst Failed");
    end
    repeat(3)#Interconnect_Clock_Period;
end
endtask


task Slave_1();
begin
    // Simple Transfer where both Master 1 and 2 send data to slave 1
    S01_Stim('hFFFFFFF,'hFFFFFFFF,'d0,'b01,'b0);
    S01_AXI_awvalid='b1;
    repeat(1)#Interconnect_Clock_Period;
    S00_Stim('h0AAAAAAA,'hAAAAAAAA,'b0,'b0,'b0);
    S00_AXI_awvalid='b1;
    repeat(5)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_awready==S01_AXI_awvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("#1 Tranfer from S01 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
   @(posedge ACLK) ;
    if(M00_AXI_awready==S00_AXI_awvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S00_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("#1 Tranfer from S00 Burst Failed");
    end
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b1;

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b1;
    repeat(2)#Interconnect_Clock_Period;
    S01_AXI_wvalid='b1;
    S01_AXI_wlast='b1;
    @(posedge ACLK) 
    if(M00_AXI_wready==S01_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S01_AXI_wvalid='b0;
    S01_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S01 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b1;
    @(posedge ACLK) 
    if(M00_AXI_wready==S00_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    S00_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S00 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    M00_AXI_BID='d1;
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    @(posedge ACLK) 
    if(M00_AXI_bvalid==S01_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    S01_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Response at S00 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    M00_AXI_BID='d0;
    repeat(3)#Interconnect_Clock_Period;
    S00_AXI_bready='b1;
    @(posedge ACLK) 
    if(M00_AXI_bvalid==S00_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    S00_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Response at S00 Burst Failed");
    end
end
endtask


task Slave_2();
begin
    // Simple Transfer where both Master 1 and 2 send data to slave 1
    S01_Stim('b11010101010101010101010101010101,'hFFFFFFFF,'d0,'b01,'b0);
    S01_AXI_awvalid='b1;
    repeat(1)#Interconnect_Clock_Period;
    S00_Stim('b11010101010101010101010101010101,'hAAAAAAAA,'b0,'b0,'b0);
    S00_AXI_awvalid='b1;
    repeat(5)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_awready='b1;
    @(posedge ACLK) ;
    if(M01_AXI_awready==S01_AXI_awvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("#1 Tranfer from S01 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_awready='b1;
   @(posedge ACLK) ;
    if(M01_AXI_awready==S00_AXI_awvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_awready='b0;
    S00_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("#1 Tranfer from S00 Burst Failed");
    end
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b1;

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_wready='b1;
    repeat(2)#Interconnect_Clock_Period;
    S01_AXI_wvalid='b1;
    S01_AXI_wlast='b1;
    @(posedge ACLK) 
    if(M01_AXI_wready==S01_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_wready='b0;
    S01_AXI_wvalid='b0;
    S01_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S01 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_wready='b1;
    @(posedge ACLK) 
    if(M01_AXI_wready==S00_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M01_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    S00_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S00 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    M01_AXI_bresp='b00;
    M01_AXI_bvalid='b1;
    M01_AXI_BID='d1;
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    @(posedge ACLK) 
    if(M01_AXI_bvalid==S01_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    S01_AXI_bready='b0;
    M01_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Response at S00 Burst Failed");
    end

    repeat(2)#Interconnect_Clock_Period;
    M01_AXI_bresp='b00;
    M01_AXI_bvalid='b1;
    M01_AXI_BID='d0;
    repeat(3)#Interconnect_Clock_Period;
    S00_AXI_bready='b1;
    @(posedge ACLK) 
    if(M01_AXI_bvalid==S00_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    S00_AXI_bready='b0;
    M01_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Response at S00 Burst Failed");
    end
end
endtask



task Write_Data_LARGE_Burst_S01();
begin
    // A large Burst of a 19 beats is sent from master 1 to slave 0 
    // Goal is to test the burst spilting and aother protocol convertion functions
    S01_Stim('h0,'hFFFFFFFF,'d18,'b01,'b0);
    S01_AXI_awvalid='b1;
    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    #(0.75*Interconnect_Clock_Period);
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    repeat(3)#Interconnect_Clock_Period;
 
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    #(0.75*Interconnect_Clock_Period);
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    repeat(3)#Interconnect_Clock_Period;
 
    S01_AXI_wlast='b0;
    for (i ='d0 ;i<16 ;i=i+1 ) begin
        Wirte_Data_SO1(i);
    end
    Wirte_Data_SO1('d16);

    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b10;
    M00_AXI_BID='b1;
    M00_AXI_bvalid='b1;
    repeat(1)#Interconnect_Clock_Period;
    @(posedge ACLK) 
    if(M00_AXI_bvalid==M00_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("First Response at S00 Burst Failed");
    end

    Wirte_Data_SO1('d17);
    S01_AXI_wlast='b1;
    Wirte_Data_SO1('d18);
   
    repeat(1)#Interconnect_Clock_Period;
   
    repeat(3)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    S01_AXI_bready='b1;
    @(posedge ACLK) 
    if(M00_AXI_bvalid==M00_AXI_bready) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_bvalid='b0;
    S01_AXI_bready='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("First Response at S00 Burst Failed");
    end

   
    repeat(2)#Interconnect_Clock_Period;
end
endtask

task Wirte_Data_SO1(input [31:0] Data);
begin
    repeat(3)#Interconnect_Clock_Period;
    S01_Stim('h0CCCCCCC,Data,'d15,'b01,'b1);
    S01_AXI_wvalid='b1;
    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b1;
    #(0.75*Interconnect_Clock_Period);
    @(posedge ACLK) 
    if(M00_AXI_wready==S01_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S01_AXI_wvalid='b0;
    S01_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("%0d Tranfer at S00 Burst Failed",Data);
    end
end
endtask

task QoS_Test();
begin
    $display("********************************************************************************");
    $display("* TEST: QoS Arbitration Test                                                   *");
    $display("********************************************************************************");
    $display("* Description: Tests QoS-based arbitration between S00 and S01                 *");
    $display("* Expected: S01 (QoS=15) should win arbitration over S00 (QoS=0)               *");
    $display("********************************************************************************");
    $display("");
    
    // Setup transaction 1: S00 -> Address 0x0BBBBBBB, QoS=0
    $display("* [%0t] Setting up Transaction 1: S00 -> Address 0x0BBBBBBB, QoS=0, Data=0x11111111", $time);
    S00_Stim('h0BBBBBBB,'h11111111,'d0,'b0,'b0);
    
    // Setup transaction 2: S01 -> Address 0x0CCCCCCC, QoS=15
    $display("* [%0t] Setting up Transaction 2: S01 -> Address 0x0CCCCCCC, QoS=15, Burst=16 beats", $time);
    S01_Stim('h0CCCCCCC,'h0,'d15,'b01,'b1);
    
    // Assert AWVALID for both slaves
    $display("* [%0t] Asserting AWVALID for S00 and S01 (both request simultaneously)", $time);
    S01_AXI_awvalid='b1;
    S00_AXI_awvalid='b1;

    // Wait for arbitration
    $display("* [%0t] Waiting for QoS Arbiter decision...", $time);
    repeat(10)#Interconnect_Clock_Period;
    
    // Check arbitration result (S01 should win due to higher QoS)
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_awready==S01_AXI_awvalid) begin
        $display("* [%0t] ✓✓✓ PASS: S01 (QoS=15) won arbitration (handshake completed)", $time);
        test_pass_count_sub = test_pass_count_sub + 1;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("* [%0t]�� FAIL: S01 arbitration failed", $time);
        test_fail_count_sub = test_fail_count_sub + 1;
    end
    repeat(5)#Interconnect_Clock_Period;
    
    // Write data burst: S01 -> 16 beats (0-15)
    $display("*");
    $display("* [%0t] Starting Write Data Burst Transfer: S01 -> 16 beats", $time);
    $display("*");
    
    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 0/15: Data = 0x%0h", $time, 'd0);
    Wirte_Data_SO1('d0);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 1/15: Data = 0x%0h", $time, 'd1);
    Wirte_Data_SO1('d1);
    
    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 2/15: Data = 0x%0h", $time, 'd2);
    Wirte_Data_SO1('d2);
    
    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 3/15: Data = 0x%0h", $time, 'd3);
    Wirte_Data_SO1('d3);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 4/15: Data = 0x%0h", $time, 'd4);
    Wirte_Data_SO1('d4);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 5/15: Data = 0x%0h", $time, 'd5);
    Wirte_Data_SO1('d5);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 6/15: Data = 0x%0h", $time, 'd6);
    Wirte_Data_SO1('d6);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 7/15: Data = 0x%0h", $time, 'd7);
    Wirte_Data_SO1('d7);
    
    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 8/15: Data = 0x%0h", $time, 'd8);
    Wirte_Data_SO1('d8);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 9/15: Data = 0x%0h", $time, 'd9);
    Wirte_Data_SO1('d9);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 10/15: Data = 0x%0h", $time, 'd10);
    S01_Stim('h0CCCCCCC,'d10,'d15,'b01,'b1);
    S01_AXI_wvalid='b1;

    // Now handle S00 transaction (after S01)
    $display("*");
    $display("* [%0t] Processing S00 transaction (delayed due to S01 priority)", $time);

    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b1;
    M00_AXI_awready='b1;
    @(posedge ACLK) ;
    if((M00_AXI_awready==S00_AXI_awvalid)&&(M00_AXI_wready==S01_AXI_wvalid)) begin
        $display("* [%0t]� PASS: Both S00 and S01 handshakes completed", $time);
        test_pass_count_sub = test_pass_count_sub + 1;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    M00_AXI_wready='b0;
    S00_AXI_awvalid='b0;
    S01_AXI_wvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("* [%0t]�� FAIL: Transfer from S01 and S00 failed", $time);
        test_fail_count_sub = test_fail_count_sub + 1;
    end
    
    S00_AXI_wvalid='b1;

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 11/15: Data = 0x%0h", $time, 'd11);
    Wirte_Data_SO1('d11);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 12/15: Data = 0x%0h", $time, 'd12);
    Wirte_Data_SO1('d12);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 13/15: Data = 0x%0h", $time, 'd13);
    Wirte_Data_SO1('d13);

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 14/15: Data = 0x%0h", $time, 'd14);
    Wirte_Data_SO1('d14);

    

    repeat(2)#Interconnect_Clock_Period;
    $display("* [%0t] Write Data Beat 15/15 (LAST): Data = 0x%0h, WLAST asserted", $time, 'd15);
    S01_Stim('h0CCCCCCC,'d15,'d15,'b01,'b1);
    S01_AXI_wvalid='b1;
    S01_AXI_wlast='b1;
    M00_AXI_wready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_wready==S01_AXI_wvalid) begin
        $display("* [%0t]�� PASS: S01 last write data beat handshake completed", $time);
        test_pass_count_sub = test_pass_count_sub + 1;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S01_AXI_wlast='b0;
    S01_AXI_wvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("* [%0t]�� FAIL: Transfer from S01 (last beat) failed", $time);
        test_fail_count_sub = test_fail_count_sub + 1;
    end

    // Write response for S01
    $display("*");
    $display("* [%0t] Waiting for Write Response from M00 for S01 transaction...", $time);
    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_BID='b1;
    M00_AXI_bvalid='b1;
    $display("* [%0t] M00 asserted BVALID: BRESP=0x%0h, BID=0x%0h", $time, M00_AXI_bresp, M00_AXI_BID);
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_bvalid==S01_AXI_bready) begin
        $display("* [%0t] ✓✓✓ PASS: S01 write response received (BRESP=OKAY, BID=1)", $time);
        test_pass_count_sub = test_pass_count_sub + 1;
    #(0.25*Interconnect_Clock_Period);
    S01_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("* [%0t] ✗✗✗ FAIL: Write response from S01 failed", $time);
        test_fail_count_sub = test_fail_count_sub + 1;
    end
    repeat(2)#Interconnect_Clock_Period;

    // Write data for S00 (single beat)
    $display("*");
    $display("* [%0t] Processing S00 write transaction (single beat)", $time);
    S00_Stim('h0BBBBBBB,'h11111111,'d0,'b0,'b0);
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b1;
    M00_AXI_wready='b1;
    M00_AXI_BID='b0;
    $display("* [%0t] S00 write data: Data = 0x11111111, WLAST asserted", $time);
    @(posedge ACLK) ;
    if(M00_AXI_wready==S00_AXI_wvalid) begin
        $display("* [%0t] PASS: S00 write data handshake completed", $time);
        test_pass_count_sub = test_pass_count_sub + 1;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("* [%0t]� FAIL: Transfer from S00 failed", $time);
        test_fail_count_sub = test_fail_count_sub + 1;
    end

    // Write response for S00
    $display("*");
    $display("* [%0t] Waiting for Write Response from M00 for S00 transaction...", $time);
    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    $display("* [%0t] M00 asserted BVALID: BRESP=0x%0h, BID=0x%0h", $time, M00_AXI_bresp, M00_AXI_BID);
    repeat(3)#Interconnect_Clock_Period;
    S00_AXI_bready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_bvalid==S00_AXI_bready) begin
        $display("* [%0t] PASS: S00 write response received (BRESP=OKAY, BID=0)", $time);
        test_pass_count_sub = test_pass_count_sub + 1;
    #(0.25*Interconnect_Clock_Period);
    S00_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("* [%0t]�� FAIL: Write response from S00 failed", $time);
        test_fail_count_sub = test_fail_count_sub + 1;
    end
    repeat(2)#Interconnect_Clock_Period;
    
    $display("*");
    $display("********************************************************************************");
    $display("* [%0t] QoS Test completed", $time);
    $display("");




end
endtask

/*
task Write_Data_Sim_S01();
begin
    S01_Stim('h0FFFFFFF,'h0,'b0);
    S01_AXI_awvalid='b1;
    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    #(0.75*Interconnect_Clock_Period);
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S01_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    repeat(3)#Interconnect_Clock_Period;
    S01_Stim('h0,'hAAAAAAAA,'b0);
    S01_AXI_wvalid='b1;
    S01_AXI_wlast='b1;
    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_wready==S01_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S01_AXI_wvalid='b0;
    S01_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S01 Simple Failed");
    end
    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    repeat(1)#Interconnect_Clock_Period;
    S01_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    repeat(2)#Interconnect_Clock_Period;
end
endtask
*/
task Write_Data_Sim_S00();
begin
    S00_Stim('h0AAAAAAA,'h0,'b0,'b0,'b0);
    S00_AXI_awvalid='b1;
    repeat(2)#Interconnect_Clock_Period;

    #(0.25*Interconnect_Clock_Period);

    M00_AXI_awready='b1;

    #(0.75*Interconnect_Clock_Period);

    #(0.25*Interconnect_Clock_Period);

    M00_AXI_awready='b0;
    S00_AXI_awvalid='b0;

    #(0.75*Interconnect_Clock_Period);

    repeat(3)#Interconnect_Clock_Period;
    S00_Stim('h0,'hAAAAAAAA,'b0,'b0,'b0);
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b1;
    repeat(10)#Interconnect_Clock_Period;
    M00_AXI_wready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_wready==S00_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    S00_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display(" Tranfer at S00 Simple Failed");
    end
    

    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    repeat(1)#Interconnect_Clock_Period;
    S00_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    repeat(2)#Interconnect_Clock_Period;

end
endtask

task Write_Data_Burst_S00();
begin
    S00_Stim('h0ccccccc,'h0,'d2,'b01,'b0);
    S00_AXI_awvalid='b1;
    repeat(2)#Interconnect_Clock_Period;
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b1;
    #(0.75*Interconnect_Clock_Period);
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_awready='b0;
    S00_AXI_awvalid='b0;
    #(0.75*Interconnect_Clock_Period);
    repeat(3)#Interconnect_Clock_Period;
    S00_Stim('h0,'hcccccccc,'d2,'b01,'b0);
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b0;
    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_wready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_wready==S00_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    S00_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("First Tranfer at S00 Burst Failed");
    end
    repeat(3)#Interconnect_Clock_Period;
    S00_Stim('h0,'h11111111,'d2,'b01,'b0);
    S00_AXI_wvalid='b1;
    S00_AXI_wlast='b1;
    repeat(2)#Interconnect_Clock_Period;
    M00_AXI_wready='b1;
    @(posedge ACLK) ;
    if(M00_AXI_wready==S00_AXI_wvalid) begin
    #(0.25*Interconnect_Clock_Period);
    M00_AXI_wready='b0;
    S00_AXI_wvalid='b0;
    S00_AXI_wlast='b0;
    #(0.75*Interconnect_Clock_Period);
    end else begin
        $display("Last Tranfer at S00 Burst Failed");
    end
    repeat(1)#Interconnect_Clock_Period;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b1;
    repeat(3)#Interconnect_Clock_Period;
    S01_AXI_bready='b1;
    repeat(1)#Interconnect_Clock_Period;
    S00_AXI_bready='b0;
    M00_AXI_bvalid='b0;
    repeat(2)#Interconnect_Clock_Period;
end
endtask

task S00_Stim (input [Address_width-1:0] Address ,input [S00_Write_data_bus_width-1:0] Data,input [S00_Aw_len:0] Burst_Size,input [1:0] Burst_Type,input [3:0] QoS); 
begin
    S00_AXI_awaddr =Address;
    S00_AXI_awlen=Burst_Size;
    S00_AXI_awsize='b011;
    S00_AXI_awburst=Burst_Type;
    S00_AXI_awlock='b0;
    S00_AXI_awcache='b0;
    S00_AXI_awprot='b0;
    S00_AXI_awqos=QoS;
    S00_AXI_awvalid='b0;

    S00_AXI_wdata =Data;
    S00_AXI_wstrb='b1111;
   
    S00_AXI_wvalid='b0;

    S00_AXI_bready='b0;
end
endtask



task S01_Stim (input [Address_width-1:0] Address ,input [S00_Write_data_bus_width-1:0] Data,input [S01_Aw_len:0] Burst_Size,input [1:0] Burst_Type,input [3:0] QoS); 
begin
    S01_AXI_awaddr =Address;
    S01_AXI_awlen=Burst_Size;
    S01_AXI_awsize='b011;
    S01_AXI_awburst=Burst_Type;
    S01_AXI_awlock='b0;
    S01_AXI_awcache='b0;
    S01_AXI_awprot='b0;
    S01_AXI_awqos=QoS;
    S01_AXI_awvalid='b0;
    S01_AXI_wdata =Data;
    S01_AXI_wstrb='b1111;
    S01_AXI_wvalid='b0;
    S01_AXI_bready='b0;
end
endtask

task M00_Init ();
begin
    M00_AXI_awready='b0;
    M00_AXI_bresp='b00;
    M00_AXI_bvalid='b0;
    M00_AXI_wready='b0;
    M00_AXI_BID='b0;
    //M00_AXI_awqos='b0;
end
endtask

task M01_Init ();
begin
    M01_AXI_awready='b0;
    M01_AXI_bresp='b00;
    M01_AXI_bvalid='b0;
    M01_AXI_wready='b0;
    M01_AXI_BID='b0;
    //M01_AXI_awqos='b0;
end
endtask

task M02_Init ();
begin
    M02_AXI_arready='b0;
    M02_AXI_rdata='b0;
    M02_AXI_rresp='b00;
    M02_AXI_rlast='b0;
    M02_AXI_rvalid='b0;
end
endtask

task M03_Init ();
begin
    M03_AXI_arready='b0;
    M03_AXI_rdata='b0;
    M03_AXI_rresp='b00;
    M03_AXI_rlast='b0;
    M03_AXI_rvalid='b0;
end
endtask


AXI_Interconnect_Full u_AXI_Interconnect(
    .S01_ACLK          (S01_ACLK          ),
    .S01_ARESETN       (S01_ARESETN       ),
    .S01_AXI_awaddr    (S01_AXI_awaddr    ),
    .S01_AXI_awlen     (S01_AXI_awlen     ),
    .S01_AXI_awsize    (S01_AXI_awsize    ),
    .S01_AXI_awburst   (S01_AXI_awburst   ),
    .S01_AXI_awlock    (S01_AXI_awlock    ),
    .S01_AXI_awcache   (S01_AXI_awcache   ),
    .S01_AXI_awprot    (S01_AXI_awprot    ),
    .S01_AXI_awqos     (S01_AXI_awqos     ),
    .S01_AXI_awvalid   (S01_AXI_awvalid   ),
    .S01_AXI_awready   (S01_AXI_awready   ),
    .S01_AXI_wdata     (S01_AXI_wdata     ),
    .S01_AXI_wstrb     (S01_AXI_wstrb     ),
    .S01_AXI_wlast     (S01_AXI_wlast     ),
    .S01_AXI_wvalid    (S01_AXI_wvalid    ),
    .S01_AXI_wready    (S01_AXI_wready    ),
    .S01_AXI_bresp     (S01_AXI_bresp     ),
    .S01_AXI_bvalid    (S01_AXI_bvalid    ),
    .S01_AXI_bready    (S01_AXI_bready    ),
    .S01_AXI_araddr    (S01_AXI_araddr    ),
    .S01_AXI_arlen     (S01_AXI_arlen     ),
    .S01_AXI_arsize    (S01_AXI_arsize    ),
    .S01_AXI_arburst   (S01_AXI_arburst   ),
    .S01_AXI_arlock    (S01_AXI_arlock    ),
    .S01_AXI_arcache   (S01_AXI_arcache   ),
    .S01_AXI_arprot    (S01_AXI_arprot    ),
    .S01_AXI_arqos     (S01_AXI_arqos     ),
    .S01_AXI_arvalid   (S01_AXI_arvalid   ),
    .S01_AXI_arready   (S01_AXI_arready   ),
    .S01_AXI_rdata     (S01_AXI_rdata     ),
    .S01_AXI_rresp     (S01_AXI_rresp     ),
    .S01_AXI_rlast     (S01_AXI_rlast     ),
    .S01_AXI_rvalid    (S01_AXI_rvalid    ),
    .S01_AXI_rready    (S01_AXI_rready    ),
    .ACLK              (ACLK              ),
    .ARESETN           (ARESETN           ),
    .S00_ACLK          (S00_ACLK          ),
    .S00_ARESETN       (S00_ARESETN       ),
    .S00_AXI_awaddr    (S00_AXI_awaddr    ),
    .S00_AXI_awlen     (S00_AXI_awlen     ),
    .S00_AXI_awsize    (S00_AXI_awsize    ),
    .S00_AXI_awburst   (S00_AXI_awburst   ),
    .S00_AXI_awlock    (S00_AXI_awlock    ),
    .S00_AXI_awcache   (S00_AXI_awcache   ),
    .S00_AXI_awprot    (S00_AXI_awprot    ),
    .S00_AXI_awqos     (S00_AXI_awqos     ),
    .S00_AXI_awvalid   (S00_AXI_awvalid   ),
    .S00_AXI_awready   (S00_AXI_awready   ),
    .S00_AXI_wdata     (S00_AXI_wdata     ),
    .S00_AXI_wstrb     (S00_AXI_wstrb     ),
    .S00_AXI_wlast     (S00_AXI_wlast     ),
    .S00_AXI_wvalid    (S00_AXI_wvalid    ),
    .S00_AXI_wready    (S00_AXI_wready    ),
    .S00_AXI_bresp     (S00_AXI_bresp     ),
    .S00_AXI_bvalid    (S00_AXI_bvalid    ),
    .S00_AXI_bready    (S00_AXI_bready    ),
    .S00_AXI_araddr    (S00_AXI_araddr    ),
    .S00_AXI_arlen     (S00_AXI_arlen     ),
    .S00_AXI_arsize    (S00_AXI_arsize    ),
    .S00_AXI_arburst   (S00_AXI_arburst   ),
    .S00_AXI_arlock    (S00_AXI_arlock    ),
    .S00_AXI_arcache   (S00_AXI_arcache   ),
    .S00_AXI_arprot    (S00_AXI_arprot    ),
    .S00_AXI_arqos     (S00_AXI_arqos     ),
    .S00_AXI_arvalid   (S00_AXI_arvalid   ),
    .S00_AXI_arready   (S00_AXI_arready   ),
    .S00_AXI_rdata     (S00_AXI_rdata     ),
    .S00_AXI_rresp     (S00_AXI_rresp     ),
    .S00_AXI_rlast     (S00_AXI_rlast     ),
    .S00_AXI_rvalid    (S00_AXI_rvalid    ),
    .S00_AXI_rready    (S00_AXI_rready    ),
    .M00_ACLK          (M00_ACLK          ),
    .M00_ARESETN       (M00_ARESETN       ),
    .M00_AXI_awaddr_ID (M00_AXI_awaddr_ID ),
    .M00_AXI_awaddr    (M00_AXI_awaddr    ),
    .M00_AXI_awlen     (M00_AXI_awlen     ),
    .M00_AXI_awsize    (M00_AXI_awsize    ),
    .M00_AXI_awburst   (M00_AXI_awburst   ),
    .M00_AXI_awlock    (M00_AXI_awlock    ),
    .M00_AXI_awcache   (M00_AXI_awcache   ),
    .M00_AXI_awprot    (M00_AXI_awprot    ),
    .M00_AXI_awqos     (M00_AXI_awqos     ),
    .M00_AXI_awvalid   (M00_AXI_awvalid   ),
    .M00_AXI_awready   (M00_AXI_awready   ),
    .M00_AXI_wdata     (M00_AXI_wdata     ),
    .M00_AXI_wstrb     (M00_AXI_wstrb     ),
    .M00_AXI_wlast     (M00_AXI_wlast     ),
    .M00_AXI_wvalid    (M00_AXI_wvalid    ),
    .M00_AXI_wready    (M00_AXI_wready    ),
    .M00_AXI_BID       (M00_AXI_BID       ),
    .M00_AXI_bresp     (M00_AXI_bresp     ),
    .M00_AXI_bvalid    (M00_AXI_bvalid    ),
    .M00_AXI_bready    (M00_AXI_bready    ),
    .M00_AXI_araddr    (M00_AXI_araddr    ),
    .M00_AXI_arlen     (M00_AXI_arlen     ),
    .M00_AXI_arsize    (M00_AXI_arsize    ),
    .M00_AXI_arburst   (M00_AXI_arburst   ),
    .M00_AXI_arlock    (M00_AXI_arlock    ),
    .M00_AXI_arcache   (M00_AXI_arcache   ),
    .M00_AXI_arprot    (M00_AXI_arprot    ),
    .M00_AXI_arregion  (M00_AXI_arregion  ),
    .M00_AXI_arqos     (M00_AXI_arqos     ),
    .M00_AXI_arvalid   (M00_AXI_arvalid   ),
    .M00_AXI_arready   (M00_AXI_arready   ),
    .M00_AXI_rdata     (M00_AXI_rdata     ),
    .M00_AXI_rresp     (M00_AXI_rresp     ),
    .M00_AXI_rlast     (M00_AXI_rlast     ),
    .M00_AXI_rvalid    (M00_AXI_rvalid    ),
    .M00_AXI_rready    (M00_AXI_rready    ),
    .M01_ACLK          (M01_ACLK          ),
    .M01_ARESETN       (M01_ARESETN       ),
    .M01_AXI_awaddr_ID (M01_AXI_awaddr_ID ),
    .M01_AXI_awaddr    (M01_AXI_awaddr    ),
    .M01_AXI_awlen     (M01_AXI_awlen     ),
    .M01_AXI_awsize    (M01_AXI_awsize    ),
    .M01_AXI_awburst   (M01_AXI_awburst   ),
    .M01_AXI_awlock    (M01_AXI_awlock    ),
    .M01_AXI_awcache   (M01_AXI_awcache   ),
    .M01_AXI_awprot    (M01_AXI_awprot    ),
    .M01_AXI_awqos     (M01_AXI_awqos     ),
    .M01_AXI_awvalid   (M01_AXI_awvalid   ),
    .M01_AXI_awready   (M01_AXI_awready   ),
    .M01_AXI_wdata     (M01_AXI_wdata     ),
    .M01_AXI_wstrb     (M01_AXI_wstrb     ),
    .M01_AXI_wlast     (M01_AXI_wlast     ),
    .M01_AXI_wvalid    (M01_AXI_wvalid    ),
    .M01_AXI_wready    (M01_AXI_wready    ),
    .M01_AXI_bresp     (M01_AXI_bresp     ),
    .M01_AXI_BID       (M01_AXI_BID       ),
    .M01_AXI_bvalid    (M01_AXI_bvalid    ),
    .M01_AXI_bready    (M01_AXI_bready    ),
    .M01_AXI_araddr    (M01_AXI_araddr    ),
    .M01_AXI_arlen     (M01_AXI_arlen     ),
    .M01_AXI_arsize    (M01_AXI_arsize    ),
    .M01_AXI_arburst   (M01_AXI_arburst   ),
    .M01_AXI_arlock    (M01_AXI_arlock    ),
    .M01_AXI_arcache   (M01_AXI_arcache   ),
    .M01_AXI_arprot    (M01_AXI_arprot    ),
    .M01_AXI_arregion  (M01_AXI_arregion  ),
    .M01_AXI_arqos     (M01_AXI_arqos     ),
    .M01_AXI_arvalid   (M01_AXI_arvalid   ),
    .M01_AXI_arready   (M01_AXI_arready   ),
    .M01_AXI_rdata     (M01_AXI_rdata     ),
    .M01_AXI_rresp     (M01_AXI_rresp     ),
    .M01_AXI_rlast     (M01_AXI_rlast     ),
    .M01_AXI_rvalid    (M01_AXI_rvalid    ),
    .M01_AXI_rready    (M01_AXI_rready    ),
    .M02_ACLK          (M02_ACLK          ),
    .M02_ARESETN       (M02_ARESETN       ),
    .M02_AXI_araddr    (M02_AXI_araddr    ),
    .M02_AXI_arlen     (M02_AXI_arlen     ),
    .M02_AXI_arsize    (M02_AXI_arsize    ),
    .M02_AXI_arburst   (M02_AXI_arburst   ),
    .M02_AXI_arlock    (M02_AXI_arlock    ),
    .M02_AXI_arcache   (M02_AXI_arcache   ),
    .M02_AXI_arprot    (M02_AXI_arprot    ),
    .M02_AXI_arregion  (M02_AXI_arregion  ),
    .M02_AXI_arqos     (M02_AXI_arqos     ),
    .M02_AXI_arvalid   (M02_AXI_arvalid   ),
    .M02_AXI_arready   (M02_AXI_arready   ),
    .M02_AXI_rdata     (M02_AXI_rdata     ),
    .M02_AXI_rresp     (M02_AXI_rresp     ),
    .M02_AXI_rlast     (M02_AXI_rlast     ),
    .M02_AXI_rvalid    (M02_AXI_rvalid    ),
    .M02_AXI_rready    (M02_AXI_rready    ),
    .M03_ACLK          (M03_ACLK          ),
    .M03_ARESETN       (M03_ARESETN       ),
    .M03_AXI_araddr    (M03_AXI_araddr    ),
    .M03_AXI_arlen     (M03_AXI_arlen     ),
    .M03_AXI_arsize    (M03_AXI_arsize    ),
    .M03_AXI_arburst   (M03_AXI_arburst   ),
    .M03_AXI_arlock    (M03_AXI_arlock    ),
    .M03_AXI_arcache   (M03_AXI_arcache   ),
    .M03_AXI_arprot    (M03_AXI_arprot    ),
    .M03_AXI_arregion  (M03_AXI_arregion  ),
    .M03_AXI_arqos     (M03_AXI_arqos     ),
    .M03_AXI_arvalid   (M03_AXI_arvalid   ),
    .M03_AXI_arready   (M03_AXI_arready   ),
    .M03_AXI_rdata     (M03_AXI_rdata     ),
    .M03_AXI_rresp     (M03_AXI_rresp     ),
    .M03_AXI_rlast     (M03_AXI_rlast     ),
    .M03_AXI_rvalid    (M03_AXI_rvalid    ),
    .M03_AXI_rready    (M03_AXI_rready    ),
    .slave0_addr1(32'h0000_0000),  // Slave 0 base address
    .slave0_addr2(32'h0FFF_FFFF),  // Slave 0 end address
    .slave1_addr1(32'h1000_0000),  // Slave 1 base address
    .slave1_addr2(32'h1FFF_FFFF),  // Slave 1 end address
    .slave2_addr1(32'h2000_0000),  // Slave 2 base address
    .slave2_addr2(32'h2FFF_FFFF),  // Slave 2 end address
    .slave3_addr1(32'h3000_0000),  // Slave 3 base address
    .slave3_addr2(32'h3FFF_FFFF)   // Slave 3 end address
    //.M1_ID             (M1_ID             ),
    //.M2_ID             (M2_ID             )
);



/*
AXI_Interconnect #(
    .Address_width            (Address_width            ),
    .S00_Aw_len               (S00_Aw_len               ),
    .S00_Write_data_bus_width (S00_Write_data_bus_width ),
    .S00_Write_data_bytes_num (S00_Write_data_bytes_num ),
    .S00_AR_len               (S00_AR_len               ),
    .S00_Read_data_bus_width  (S00_Read_data_bus_width  ),
    .S01_Aw_len               (S01_Aw_len               ),
    .S01_AR_len               (S01_AR_len               ),
    .M00_Aw_len               (M00_Aw_len               ),
    .M00_Write_data_bus_width (M00_Write_data_bus_width ),
    .M00_Write_data_bytes_num (M00_Write_data_bytes_num ),
    .M00_AR_len               (M00_AR_len               ),
    .M00_Read_data_bus_width  (M00_Read_data_bus_width  )
)
u_AXI_Interconnect(
    .S01_ACLK         (S01_ACLK         ),
    .S01_ARESETN      (S01_ARESETN      ),
    .S01_AXI_awaddr   (S01_AXI_awaddr   ),
    .S01_AXI_awlen    (S01_AXI_awlen    ),
    .S01_AXI_awsize   (S01_AXI_awsize   ),
    .S01_AXI_awburst  (S01_AXI_awburst  ),
    .S01_AXI_awlock   (S01_AXI_awlock   ),
    .S01_AXI_awcache  (S01_AXI_awcache  ),
    .S01_AXI_awprot   (S01_AXI_awprot   ),
    .S01_AXI_awqos    (S01_AXI_awqos    ),
    .S01_AXI_awvalid  (S01_AXI_awvalid  ),
    .S01_AXI_awready  (S01_AXI_awready  ),
    .S01_AXI_wdata    (S01_AXI_wdata    ),
    .S01_AXI_wstrb    (S01_AXI_wstrb    ),
    .S01_AXI_wlast    (S01_AXI_wlast    ),
    .S01_AXI_wvalid   (S01_AXI_wvalid   ),
    .S01_AXI_wready   (S01_AXI_wready   ),
    .S01_AXI_bresp    (S01_AXI_bresp    ),
    .S01_AXI_bvalid   (S01_AXI_bvalid   ),
    .S01_AXI_bready   (S01_AXI_bready   ),
    .S01_AXI_araddr   (S01_AXI_araddr   ),
    .S01_AXI_arlen    (S01_AXI_arlen    ),
    .S01_AXI_arsize   (S01_AXI_arsize   ),
    .S01_AXI_arburst  (S01_AXI_arburst  ),
    .S01_AXI_arlock   (S01_AXI_arlock   ),
    .S01_AXI_arcache  (S01_AXI_arcache  ),
    .S01_AXI_arprot   (S01_AXI_arprot   ),
    .S01_AXI_arregion (S01_AXI_arregion ),
    .S01_AXI_arqos    (S01_AXI_arqos    ),
    .S01_AXI_arvalid  (S01_AXI_arvalid  ),
    .S01_AXI_arready  (S01_AXI_arready  ),
    .S01_AXI_rdata    (S01_AXI_rdata    ),
    .S01_AXI_rresp    (S01_AXI_rresp    ),
    .S01_AXI_rlast    (S01_AXI_rlast    ),
    .S01_AXI_rvalid   (S01_AXI_rvalid   ),
    .S01_AXI_rready   (S01_AXI_rready   ),
    .ACLK             (ACLK             ),
    .ARESETN          (ARESETN          ),
    .S00_ACLK         (S00_ACLK         ),
    .S00_ARESETN      (S00_ARESETN      ),
    .S00_AXI_awaddr   (S00_AXI_awaddr   ),
    .S00_AXI_awlen    (S00_AXI_awlen    ),
    .S00_AXI_awsize   (S00_AXI_awsize   ),
    .S00_AXI_awburst  (S00_AXI_awburst  ),
    .S00_AXI_awlock   (S00_AXI_awlock   ),
    .S00_AXI_awcache  (S00_AXI_awcache  ),
    .S00_AXI_awprot   (S00_AXI_awprot   ),
    .S00_AXI_awqos    (S00_AXI_awqos    ),
    .S00_AXI_awvalid  (S00_AXI_awvalid  ),
    .S00_AXI_awready  (S00_AXI_awready  ),
    .S00_AXI_wdata    (S00_AXI_wdata    ),
    .S00_AXI_wstrb    (S00_AXI_wstrb    ),
    .S00_AXI_wlast    (S00_AXI_wlast    ),
    .S00_AXI_wvalid   (S00_AXI_wvalid   ),
    .S00_AXI_wready   (S00_AXI_wready   ),
    .S00_AXI_bresp    (S00_AXI_bresp    ),
    .S00_AXI_bvalid   (S00_AXI_bvalid   ),
    .S00_AXI_bready   (S00_AXI_bready   ),
    .S00_AXI_araddr   (S00_AXI_araddr   ),
    .S00_AXI_arlen    (S00_AXI_arlen    ),
    .S00_AXI_arsize   (S00_AXI_arsize   ),
    .S00_AXI_arburst  (S00_AXI_arburst  ),
    .S00_AXI_arlock   (S00_AXI_arlock   ),
    .S00_AXI_arcache  (S00_AXI_arcache  ),
    .S00_AXI_arprot   (S00_AXI_arprot   ),
    .S00_AXI_arregion (S00_AXI_arregion ),
    .S00_AXI_arqos    (S00_AXI_arqos    ),
    .S00_AXI_arvalid  (S00_AXI_arvalid  ),
    .S00_AXI_arready  (S00_AXI_arready  ),
    .S00_AXI_rdata    (S00_AXI_rdata    ),
    .S00_AXI_rresp    (S00_AXI_rresp    ),
    .S00_AXI_rlast    (S00_AXI_rlast    ),
    .S00_AXI_rvalid   (S00_AXI_rvalid   ),
    .S00_AXI_rready   (S00_AXI_rready   ),
    .M00_ACLK         (M00_ACLK         ),
    .M00_ARESETN      (M00_ARESETN      ),
    .M00_AXI_awaddr   (M00_AXI_awaddr   ),
    .M00_AXI_awlen    (M00_AXI_awlen    ),
    .M00_AXI_awsize   (M00_AXI_awsize   ),
    .M00_AXI_awburst  (M00_AXI_awburst  ),
    .M00_AXI_awlock   (M00_AXI_awlock   ),
    .M00_AXI_awcache  (M00_AXI_awcache  ),
    .M00_AXI_awprot   (M00_AXI_awprot   ),
    .M00_AXI_awqos    (M00_AXI_awqos    ),
    .M00_AXI_awvalid  (M00_AXI_awvalid  ),
    .M00_AXI_awready  (M00_AXI_awready  ),
    .M00_AXI_wdata    (M00_AXI_wdata    ),
    .M00_AXI_wstrb    (M00_AXI_wstrb    ),
    .M00_AXI_wlast    (M00_AXI_wlast    ),
    .M00_AXI_wvalid   (M00_AXI_wvalid   ),
    .M00_AXI_wready   (M00_AXI_wready   ),
    .M00_AXI_bresp    (M00_AXI_bresp    ),
    .M00_AXI_bvalid   (M00_AXI_bvalid   ),
    .M00_AXI_bready   (M00_AXI_bready   ),
    .M00_AXI_araddr   (M00_AXI_araddr   ),
    .M00_AXI_arlen    (M00_AXI_arlen    ),
    .M00_AXI_arsize   (M00_AXI_arsize   ),
    .M00_AXI_arburst  (M00_AXI_arburst  ),
    .M00_AXI_arlock   (M00_AXI_arlock   ),
    .M00_AXI_arcache  (M00_AXI_arcache  ),
    .M00_AXI_arprot   (M00_AXI_arprot   ),
    //.M00_AXI_arregion (M00_AXI_arregion ),
    //.M00_AXI_arqos    (M00_AXI_arqos    ),
    .M00_AXI_arvalid  (M00_AXI_arvalid  ),
    .M00_AXI_arready  (M00_AXI_arready  ),
    .M00_AXI_rdata    (M00_AXI_rdata    ),
    .M00_AXI_rresp    (M00_AXI_rresp    ),
    .M00_AXI_rlast    (M00_AXI_rlast    ),
    .M00_AXI_rvalid   (M00_AXI_rvalid   ),
    .M00_AXI_rready   (M00_AXI_rready   )
);*/

    
endmodule
