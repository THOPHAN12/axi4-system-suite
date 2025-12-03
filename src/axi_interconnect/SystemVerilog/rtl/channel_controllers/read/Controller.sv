//=============================================================================
// Controller.sv - SystemVerilog
// Read Data Channel Controller with FSM for routing
//=============================================================================

`timescale 1ns/1ps

module Controller (
    //---------------------- Input Ports ----------------------
    input logic clkk,
    input logic resett,

    // input from reg file to indicate range of addresses of slave 0:
    input logic [31:0] slave0_addr1,
    input logic [31:0] slave0_addr2,

    // input from reg file to indicate range of addresses of slave 1:
    input logic [31:0] slave1_addr1,
    input logic [31:0] slave1_addr2,

    // input from reg file to indicate range of addresses of slave 2:
    input logic [31:0] slave2_addr1,
    input logic [31:0] slave2_addr2,

    // input from reg file to indicate range of addresses of slave 3:
    input logic [31:0] slave3_addr1,
    input logic [31:0] slave3_addr2,

    // Address from the master on read address channel:
    input logic [31:0] M_ADDR,

    // ready signal from each slave:
    input logic S0_ARREADY,
    input logic S1_ARREADY,
    input logic S2_ARREADY,
    input logic S3_ARREADY,

    // two valid signals from masters on read address channel:
    input logic M0_ARVALID,
    input logic M1_ARVALID,

    // two ready signals from masters on read data channel:
    input logic M0_RREADY,
    input logic M1_RREADY,

    // valid signal from each slave:
    input logic S0_RVALID,
    input logic S1_RVALID,
    input logic S2_RVALID,
    input logic S3_RVALID,

    // last signal from each slave:
    input logic S0_RLAST,
    input logic S1_RLAST,
    input logic S2_RLAST,
    input logic S3_RLAST,
    
    //---------------------- Output Ports ----------------------
    
    // select lines for muxs to choose which slave (now 2-bit for 4 slaves):
    output logic [1:0] select_slave_address,
    output logic [1:0] select_data_M0,
    output logic [1:0] select_data_M1,

    // enable signal based on the ID from slave to choose the right master (2-bit: 00=M0, 01=M1):
    output logic [1:0] en_S0,
    output logic [1:0] en_S1,
    output logic [1:0] en_S2,
    output logic [1:0] en_S3,

    output logic select_master_address
);

    //---------------------- Code Start ----------------------
    // Changed to 3-bit state encoding to support 5 states (Idle + 4 Slaves)
    logic [2:0] curr_state_slave, next_state_slave, curr_state_slave2;
    logic [1:0] curr_state_address, next_state_address;
    logic [2:0] next_state_slave2;

    // Intentional: busy signals assigned but not read (may be used for debug/future monitoring)
    logic S0_busy = 1'b0, S1_busy = 1'b0, S2_busy = 1'b0, S3_busy = 1'b0;
    // Removed: last_served_address (Round-Robin) - Using Fixed-Priority QoS Arbiter instead

    // Internal enable signals for each master (to avoid multiple drivers)
    logic [1:0] en_S0_M0, en_S1_M0, en_S2_M0, en_S3_M0;
    logic [1:0] en_S0_M1, en_S1_M1, en_S2_M1, en_S3_M1;

    // FSM 1: Address Channel States
    localparam logic [1:0] Idle_address = 2'b00;
    localparam logic [1:0] M0_Address = 2'b01;
    localparam logic [1:0] M1_Address = 2'b10;

    // FSM 2: Master 0 Data Channel States (3-bit encoding for 5 states)
    localparam logic [2:0] Idle_slave = 3'b000;
    localparam logic [2:0] Slave0 = 3'b001;
    localparam logic [2:0] Slave1 = 3'b010;
    localparam logic [2:0] Slave2 = 3'b011;
    localparam logic [2:0] Slave3 = 3'b100;

    // FSM 3: Master 1 Data Channel States (3-bit encoding for 5 states)
    localparam logic [2:0] Idle_slave_2 = 3'b000;
    localparam logic [2:0] Slave0_2 = 3'b001;
    localparam logic [2:0] Slave1_2 = 3'b010;
    localparam logic [2:0] Slave2_2 = 3'b011;
    localparam logic [2:0] Slave3_2 = 3'b100;

    always_ff @(posedge clkk or negedge resett) begin
        if (!resett) begin
            curr_state_slave <= Idle_slave;
            curr_state_slave2 <= Idle_slave_2;
            curr_state_address <= Idle_address;
        end else begin
            curr_state_slave <= next_state_slave;
            curr_state_slave2 <= next_state_slave2;
            curr_state_address <= next_state_address;
        end
    end

    // Address Channel FSM
    always_comb begin
        // Default assignments to avoid latches
        next_state_address = curr_state_address;
        select_slave_address = 2'b00;
        select_master_address = 1'b0;
        
        //========================================================================
        // FSM 1: Address Channel Arbitration
        //========================================================================
        case (curr_state_address)
            Idle_address: begin
                if (M0_ARVALID && M1_ARVALID) begin
                    // Fixed-Priority QoS Arbiter: M0 has priority over M1
                    next_state_address = M0_Address;
                    select_master_address = 1'b0;
                end else begin
                    if (M0_ARVALID) begin
                        next_state_address = M0_Address;
                        select_master_address = 1'b0;
                        // Address decode
                        if (M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
                            select_slave_address = 2'b00;
                        end else if (M_ADDR >= slave1_addr1 && M_ADDR <= slave1_addr2) begin
                            select_slave_address = 2'b01;
                        end else if (M_ADDR >= slave2_addr1 && M_ADDR <= slave2_addr2) begin
                            select_slave_address = 2'b10;
                        end else if (M_ADDR >= slave3_addr1 && M_ADDR <= slave3_addr2) begin
                            select_slave_address = 2'b11;
                        end else begin
                            next_state_address = Idle_address;
                        end
                    end else if (M1_ARVALID) begin
                        next_state_address = M1_Address;
                        select_master_address = 1'b1;
                        // Address decode
                        if (M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
                            select_slave_address = 2'b00;
                        end else if (M_ADDR >= slave1_addr1 && M_ADDR <= slave1_addr2) begin
                            select_slave_address = 2'b01;
                        end else if (M_ADDR >= slave2_addr1 && M_ADDR <= slave2_addr2) begin
                            select_slave_address = 2'b10;
                        end else if (M_ADDR >= slave3_addr1 && M_ADDR <= slave3_addr2) begin
                            select_slave_address = 2'b11;
                        end
                    end else begin
                        next_state_address = Idle_address;
                    end
                end
            end
            
            M0_Address: begin
                // Check address to determine which Slave to route to
                // Note: next_state_slave is handled by Master 0 Data Channel FSM
                if (M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
                    // Address belongs to Slave 0
                    select_slave_address = 2'b00;
                    if (M0_ARVALID && S0_ARREADY) begin
                        // next_state_slave will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        // Wait for handshake
                        next_state_address = M0_Address;
                    end
                end else if (M_ADDR >= slave1_addr1 && M_ADDR <= slave1_addr2) begin
                    // Address belongs to Slave 1
                    select_slave_address = 2'b01;
                    if (M0_ARVALID && S1_ARREADY) begin
                        // next_state_slave will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M0_Address;
                    end
                end else if (M_ADDR >= slave2_addr1 && M_ADDR <= slave2_addr2) begin
                    // Address belongs to Slave 2
                    select_slave_address = 2'b10;
                    if (M0_ARVALID && S2_ARREADY) begin
                        // next_state_slave will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M0_Address;
                    end
                end else if (M_ADDR >= slave3_addr1 && M_ADDR <= slave3_addr2) begin
                    // Address belongs to Slave 3
                    select_slave_address = 2'b11;
                    if (M0_ARVALID && S3_ARREADY) begin
                        // next_state_slave will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M0_Address;
                    end
                end else begin
                    // Invalid address range
                    next_state_address = Idle_address;
                end
            end
            
            M1_Address: begin
                // Check address to determine which Slave to route to
                // Note: next_state_slave2 is handled by Master 1 Data Channel FSM
                if (M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
                    // Address belongs to Slave 0
                    select_slave_address = 2'b00;
                    if (M1_ARVALID && S0_ARREADY) begin
                        // next_state_slave2 will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M1_Address;
                    end
                end else if (M_ADDR >= slave1_addr1 && M_ADDR <= slave1_addr2) begin
                    // Address belongs to Slave 1
                    select_slave_address = 2'b01;
                    if (M1_ARVALID && S1_ARREADY) begin
                        // next_state_slave2 will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M1_Address;
                    end
                end else if (M_ADDR >= slave2_addr1 && M_ADDR <= slave2_addr2) begin
                    // Address belongs to Slave 2
                    select_slave_address = 2'b10;
                    if (M1_ARVALID && S2_ARREADY) begin
                        // next_state_slave2 will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M1_Address;
                    end
                end else if (M_ADDR >= slave3_addr1 && M_ADDR <= slave3_addr2) begin
                    // Address belongs to Slave 3
                    select_slave_address = 2'b11;
                    if (M1_ARVALID && S3_ARREADY) begin
                        // next_state_slave2 will be set by Data Channel FSM
                        next_state_address = Idle_address;
                    end else begin
                        next_state_address = M1_Address;
                    end
                end else begin
                    // Invalid address range
                    next_state_address = Idle_address;
                end
            end
            
            default: next_state_address = Idle_address;
        endcase
    end

    // Master 0 Data Channel FSM
    always_comb begin
        // Default assignments
        next_state_slave = curr_state_slave;
        select_data_M0 = 2'b00;
        en_S0_M0 = 2'b00;
        en_S1_M0 = 2'b00;
        en_S2_M0 = 2'b00;
        en_S3_M0 = 2'b00;
        
        //========================================================================
        // FSM 2: Master 0 Data Channel
        //========================================================================
        case (curr_state_slave)
            Idle_slave: begin
                // Default outputs
                select_data_M0 = 2'b00;
                en_S0_M0 = 2'b00;
                en_S1_M0 = 2'b00;
                en_S2_M0 = 2'b00;
                en_S3_M0 = 2'b00;
                
                // Transition to slave state when address handshake completes
                // Check address to determine which slave to route to
                if (M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
                    if (M0_ARVALID && S0_ARREADY) begin
                        next_state_slave = Slave0;
                    end
                end else if (M_ADDR >= slave1_addr1 && M_ADDR <= slave1_addr2) begin
                    if (M0_ARVALID && S1_ARREADY) begin
                        next_state_slave = Slave1;
                    end
                end else if (M_ADDR >= slave2_addr1 && M_ADDR <= slave2_addr2) begin
                    if (M0_ARVALID && S2_ARREADY) begin
                        next_state_slave = Slave2;
                    end
                end else if (M_ADDR >= slave3_addr1 && M_ADDR <= slave3_addr2) begin
                    if (M0_ARVALID && S3_ARREADY) begin
                        next_state_slave = Slave3;
                    end
                end
            end
            
            Slave0: begin
                // Master 0 is reading from Slave 0
                select_data_M0 = 2'b00;
                en_S0_M0 = 2'b00;  // M0 = 00

                if (M0_RREADY && S0_RVALID && S0_RLAST) begin
                    // Last beat completed - return to Idle
                    next_state_slave = Idle_slave;
                end else if (M0_RREADY && S0_RVALID && !S0_RLAST) begin
                    // Transaction ongoing, more beats to come
                    next_state_slave = Slave0;
                end else begin
                    // Waiting for handshake - stay in current state
                    next_state_slave = Slave0;
                end
            end
            
            Slave1: begin
                // Master 0 is reading from Slave 1
                select_data_M0 = 2'b01;
                en_S1_M0 = 2'b00;  // M0 = 00

                if (M0_RREADY && S1_RVALID && S1_RLAST) begin
                    next_state_slave = Idle_slave;
                end else if (M0_RREADY && S1_RVALID && !S1_RLAST) begin
                    next_state_slave = Slave1;
                end else begin
                    next_state_slave = Slave1;
                end
            end
            
            Slave2: begin
                // Master 0 is reading from Slave 2
                select_data_M0 = 2'b10;
                en_S2_M0 = 2'b00;  // M0 = 00

                if (M0_RREADY && S2_RVALID && S2_RLAST) begin
                    next_state_slave = Idle_slave;
                end else if (M0_RREADY && S2_RVALID && !S2_RLAST) begin
                    next_state_slave = Slave2;
                end else begin
                    next_state_slave = Slave2;
                end
            end
            
            Slave3: begin
                // Master 0 is reading from Slave 3
                select_data_M0 = 2'b11;
                en_S3_M0 = 2'b00;  // M0 = 00

                if (M0_RREADY && S3_RVALID && S3_RLAST) begin
                    next_state_slave = Idle_slave;
                end else if (M0_RREADY && S3_RVALID && !S3_RLAST) begin
                    next_state_slave = Slave3;
                end else begin
                    next_state_slave = Slave3;
                end
            end
            
            default: begin
                next_state_slave = Idle_slave;
                select_data_M0 = 2'b00;
                en_S0_M0 = 2'b00;
                en_S1_M0 = 2'b00;
                en_S2_M0 = 2'b00;
                en_S3_M0 = 2'b00;
            end
        endcase
    end

    // Master 1 Data Channel FSM
    always_comb begin
        // Default assignments
        next_state_slave2 = curr_state_slave2;
        select_data_M1 = 2'b00;
        en_S0_M1 = 2'b00;
        en_S1_M1 = 2'b00;
        en_S2_M1 = 2'b00;
        en_S3_M1 = 2'b00;
        
        //========================================================================
        // FSM 3: Master 1 Data Channel
        //========================================================================
        case (curr_state_slave2)
            Idle_slave_2: begin
                // Default outputs
                select_data_M1 = 2'b00;
                en_S0_M1 = 2'b00;
                en_S1_M1 = 2'b00;
                en_S2_M1 = 2'b00;
                en_S3_M1 = 2'b00;
                
                // Transition to slave state when address handshake completes
                // Check address to determine which slave to route to
                if (M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
                    if (M1_ARVALID && S0_ARREADY) begin
                        next_state_slave2 = Slave0_2;
                    end
                end else if (M_ADDR >= slave1_addr1 && M_ADDR <= slave1_addr2) begin
                    if (M1_ARVALID && S1_ARREADY) begin
                        next_state_slave2 = Slave1_2;
                    end
                end else if (M_ADDR >= slave2_addr1 && M_ADDR <= slave2_addr2) begin
                    if (M1_ARVALID && S2_ARREADY) begin
                        next_state_slave2 = Slave2_2;
                    end
                end else if (M_ADDR >= slave3_addr1 && M_ADDR <= slave3_addr2) begin
                    if (M1_ARVALID && S3_ARREADY) begin
                        next_state_slave2 = Slave3_2;
                    end
                end
            end
            
            Slave0_2: begin
                // Master 1 is reading from Slave 0
                select_data_M1 = 2'b00;
                en_S0_M1 = 2'b01;  // M1 = 01

                if (M1_RREADY && S0_RVALID && S0_RLAST) begin
                    next_state_slave2 = Idle_slave_2;
                end else if (M1_RREADY && S0_RVALID && !S0_RLAST) begin
                    next_state_slave2 = Slave0_2;
                end else begin
                    next_state_slave2 = Slave0_2;
                end
            end
            
            Slave1_2: begin
                // Master 1 is reading from Slave 1
                select_data_M1 = 2'b01;
                en_S1_M1 = 2'b01;  // M1 = 01

                if (M1_RREADY && S1_RVALID && S1_RLAST) begin
                    next_state_slave2 = Idle_slave_2;
                end else if (M1_RREADY && S1_RVALID && !S1_RLAST) begin
                    next_state_slave2 = Slave1_2;
                end else begin
                    next_state_slave2 = Slave1_2;
                end
            end
            
            Slave2_2: begin
                // Master 1 is reading from Slave 2
                select_data_M1 = 2'b10;
                en_S2_M1 = 2'b01;  // M1 = 01

                if (M1_RREADY && S2_RVALID && S2_RLAST) begin
                    next_state_slave2 = Idle_slave_2;
                end else if (M1_RREADY && S2_RVALID && !S2_RLAST) begin
                    next_state_slave2 = Slave2_2;
                end else begin
                    next_state_slave2 = Slave2_2;
                end
            end
            
            Slave3_2: begin
                // Master 1 is reading from Slave 3
                select_data_M1 = 2'b11;
                en_S3_M1 = 2'b01;  // M1 = 01

                if (M1_RREADY && S3_RVALID && S3_RLAST) begin
                    next_state_slave2 = Idle_slave_2;
                end else if (M1_RREADY && S3_RVALID && !S3_RLAST) begin
                    next_state_slave2 = Slave3_2;
                end else begin
                    next_state_slave2 = Slave3_2;
                end
            end
            
            default: begin
                next_state_slave2 = Idle_slave_2;
                select_data_M1 = 2'b00;
                en_S0_M1 = 2'b00;
                en_S1_M1 = 2'b00;
                en_S2_M1 = 2'b00;
                en_S3_M1 = 2'b00;
            end
        endcase
    end

    // Combine enable signals from both masters (Master 1 has priority if both active)
    always_comb begin
        // Check if Master 1 is actively using a slave (not in idle state)
        // If Master 1 is active, use M1's value; otherwise use M0's value
        // This ensures proper priority: M1 has priority when both are active
        if (curr_state_slave2 != Idle_slave_2) begin
            // Master 1 is active - use M1's enable signals
            en_S0 = en_S0_M1;
            en_S1 = en_S1_M1;
            en_S2 = en_S2_M1;
            en_S3 = en_S3_M1;
        end else begin
            // Master 1 is idle - use M0's enable signals
            en_S0 = en_S0_M0;
            en_S1 = en_S1_M0;
            en_S2 = en_S2_M0;
            en_S3 = en_S3_M0;
        end
    end

endmodule

