`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// MINIMAL TESTBENCH for Controller Test 11 Issue
// Purpose: Isolate state transition problem
//////////////////////////////////////////////////////////////////////////////////

module Controller_minimal_tb();

    parameter CLK_PERIOD = 10;

    // Clock and Reset
    reg clkk, resett;
    
    // Address ranges
    reg [31:0] slave3_addr1 = 32'h60000000;
    reg [31:0] slave3_addr2 = 32'h7FFFFFFF;
    reg [31:0] slave0_addr1 = 32'h00000000;
    reg [31:0] slave0_addr2 = 32'h1FFFFFFF;
    reg [31:0] slave1_addr1 = 32'h20000000;
    reg [31:0] slave1_addr2 = 32'h3FFFFFFF;
    reg [31:0] slave2_addr1 = 32'h40000000;
    reg [31:0] slave2_addr2 = 32'h5FFFFFFF;
    
    // Master signals
    reg [31:0] M_ADDR;
    reg M0_ARVALID, M1_ARVALID;
    reg M0_RREADY, M1_RREADY;
    
    // Slave signals
    reg S0_ARREADY, S1_ARREADY, S2_ARREADY, S3_ARREADY;
    reg S0_RVALID, S1_RVALID, S2_RVALID, S3_RVALID;
    reg S0_RLAST, S1_RLAST, S2_RLAST, S3_RLAST;
    
    // Outputs
    wire [1:0] select_slave_address;
    wire [1:0] select_data_M0;
    wire [1:0] select_data_M1;
    wire [1:0] en_S0, en_S1, en_S2, en_S3;
    wire select_master_address;

    // DUT
    Controller uut (
        .clkk(clkk),
        .resett(resett),
        .slave0_addr1(slave0_addr1),
        .slave0_addr2(slave0_addr2),
        .slave1_addr1(slave1_addr1),
        .slave1_addr2(slave1_addr2),
        .slave2_addr1(slave2_addr1),
        .slave2_addr2(slave2_addr2),
        .slave3_addr1(slave3_addr1),
        .slave3_addr2(slave3_addr2),
        .M_ADDR(M_ADDR),
        .S0_ARREADY(S0_ARREADY),
        .S1_ARREADY(S1_ARREADY),
        .S2_ARREADY(S2_ARREADY),
        .S3_ARREADY(S3_ARREADY),
        .M0_ARVALID(M0_ARVALID),
        .M1_ARVALID(M1_ARVALID),
        .M0_RREADY(M0_RREADY),
        .M1_RREADY(M1_RREADY),
        .S0_RVALID(S0_RVALID),
        .S1_RVALID(S1_RVALID),
        .S2_RVALID(S2_RVALID),
        .S3_RVALID(S3_RVALID),
        .S0_RLAST(S0_RLAST),
        .S1_RLAST(S1_RLAST),
        .S2_RLAST(S2_RLAST),
        .S3_RLAST(S3_RLAST),
        .select_slave_address(select_slave_address),
        .select_data_M0(select_data_M0),
        .select_data_M1(select_data_M1),
        .en_S0(en_S0),
        .en_S1(en_S1),
        .en_S2(en_S2),
        .en_S3(en_S3),
        .select_master_address(select_master_address)
    );

    // Clock generation
    initial begin
        clkk = 0;
        forever #(CLK_PERIOD/2) clkk = ~clkk;
    end

    // Test
    initial begin
        $display("========================================");
        $display("MINIMAL TEST: State Transition to Slave3");
        $display("========================================");
        
        // Initialize
        resett = 0;
        M_ADDR = 0;
        M0_ARVALID = 0;
        M1_ARVALID = 0;
        M0_RREADY = 0;
        M1_RREADY = 0;
        S0_ARREADY = 0;
        S1_ARREADY = 0;
        S2_ARREADY = 0;
        S3_ARREADY = 0;
        S0_RVALID = 0;
        S1_RVALID = 0;
        S2_RVALID = 0;
        S3_RVALID = 0;
        S0_RLAST = 0;
        S1_RLAST = 0;
        S2_RLAST = 0;
        S3_RLAST = 0;
        
        // Reset
        #(CLK_PERIOD * 2);
        resett = 1;
        #(CLK_PERIOD * 2);
        
        $display("\n[Time %0t] Initial State:", $time);
        $display("  curr_state_slave = %b", uut.curr_state_slave);
        
        // Set ALL signals for S3 transition
        $display("\n[Time %0t] Setting signals for S3 transition:", $time);
        M_ADDR = 32'h65000000;
        M0_ARVALID = 1;
        S3_ARREADY = 1;
        
        $display("  M_ADDR = 0x%h", M_ADDR);
        $display("  M0_ARVALID = %b", M0_ARVALID);
        $display("  S3_ARREADY = %b", S3_ARREADY);
        $display("  S3 Range: 0x%h - 0x%h", slave3_addr1, slave3_addr2);
        
        // Wait and check each clock cycle
        repeat (10) begin
            @(posedge clkk);
            #1; // Delta delay
            $display("\n[Time %0t] After clock edge:", $time);
            $display("  curr_state_slave = %b (0=Idle, 100=Slave3)", uut.curr_state_slave);
            $display("  next_state_slave = %b", uut.next_state_slave);
            $display("  select_data_M0 = %b", select_data_M0);
            
            if (uut.curr_state_slave == 3'b100) begin
                $display("\n*** SUCCESS! State transitioned to Slave3! ***");
                if (select_data_M0 == 2'b11) begin
                    $display("*** PASS! select_data_M0 = 11 ***");
                end else begin
                    $display("*** FAIL! select_data_M0 = %b (expected 11) ***", select_data_M0);
                end
                #(CLK_PERIOD * 2);
                $finish;
            end
        end
        
        $display("\n========================================");
        $display("*** FAIL: State did NOT transition after 10 clocks ***");
        $display("========================================");
        $finish;
    end

endmodule


