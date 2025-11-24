//=============================================================================
// Improved AXI Slave Model - SystemVerilog
// Slave model với proper AXI protocol implementation
//=============================================================================

`timescale 1ns/1ps

`include "../../src/axi_interconnect/sv/packages/axi_pkg.sv"

module axi_slave_model_improved (
    axi_slave_simple_if.slave s_if,
    input int unsigned slave_id,
    input int unsigned delay_cycles = 0  // Configurable delay
);
    // Memory array
    logic [31:0] memory [0:4095];  // 16KB memory
    
    // Write Address Channel State
    typedef enum logic [1:0] {
        AW_IDLE,
        AW_READY,
        AW_DONE
    } aw_state_t;
    
    aw_state_t aw_state = AW_IDLE;
    logic [31:0] aw_addr_latched;
    logic [7:0] aw_len_latched;
    logic [2:0] aw_size_latched;
    logic [1:0] aw_burst_latched;
    int unsigned write_beats_remaining;
    
    // Write Data Channel State
    typedef enum logic [1:0] {
        W_IDLE,
        W_ACTIVE,
        W_DONE
    } w_state_t;
    
    w_state_t w_state = W_IDLE;
    int unsigned write_data_count;
    
    // Write Response Channel State
    typedef enum logic [1:0] {
        B_IDLE,
        B_VALID,
        B_DONE
    } b_state_t;
    
    b_state_t b_state = B_IDLE;
    logic [1:0] bresp_latched;
    
    // Read Address Channel State
    typedef enum logic [1:0] {
        AR_IDLE,
        AR_READY,
        AR_DONE
    } ar_state_t;
    
    ar_state_t ar_state = AR_IDLE;
    logic [31:0] ar_addr_latched;
    logic [7:0] ar_len_latched;
    logic [2:0] ar_size_latched;
    logic [1:0] ar_burst_latched;
    int unsigned read_beats_remaining;
    
    // Read Data Channel State
    typedef enum logic [1:0] {
        R_IDLE,
        R_ACTIVE,
        R_DONE
    } r_state_t;
    
    r_state_t r_state = R_IDLE;
    int unsigned read_data_count;
    logic [31:0] current_read_addr;
    
    // Delay counter
    int unsigned delay_counter;
    
    //=========================================================================
    // Write Address Channel FSM
    //=========================================================================
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            aw_state <= AW_IDLE;
            s_if.awready <= 1'b0;
            aw_addr_latched <= 32'h0;
            aw_len_latched <= 8'h0;
            aw_size_latched <= 3'h0;
            aw_burst_latched <= 2'h0;
            write_beats_remaining <= 0;
            delay_counter <= 0;
        end else begin
            case (aw_state)
                AW_IDLE: begin
                    if (s_if.awvalid) begin
                        if (delay_counter < delay_cycles) begin
                            delay_counter <= delay_counter + 1;
                            s_if.awready <= 1'b0;
                        end else begin
                            s_if.awready <= 1'b1;
                            aw_state <= AW_READY;
                            aw_addr_latched <= s_if.awaddr;
                            aw_len_latched <= s_if.awlen;
                            aw_size_latched <= s_if.awsize;
                            aw_burst_latched <= s_if.awburst;
                            write_beats_remaining <= s_if.awlen + 1;
                            delay_counter <= 0;
                        end
                    end else begin
                        s_if.awready <= 1'b0;
                    end
                end
                
                AW_READY: begin
                    if (s_if.awvalid && s_if.awready) begin
                        s_if.awready <= 1'b0;
                        aw_state <= AW_DONE;
                    end
                end
                
                AW_DONE: begin
                    if (w_state == W_DONE && b_state == B_DONE) begin
                        aw_state <= AW_IDLE;
                    end
                end
            endcase
        end
    end
    
    //=========================================================================
    // Write Data Channel FSM
    //=========================================================================
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            w_state <= W_IDLE;
            s_if.wready <= 1'b0;
            write_data_count <= 0;
        end else begin
            case (w_state)
                W_IDLE: begin
                    if (aw_state == AW_DONE) begin
                        w_state <= W_ACTIVE;
                        s_if.wready <= 1'b1;
                        write_data_count <= 0;
                    end
                end
                
                W_ACTIVE: begin
                    if (s_if.wvalid && s_if.wready) begin
                        // Calculate address based on burst type
                        logic [31:0] write_addr;
                        case (aw_burst_latched)
                            2'b00: begin // FIXED
                                write_addr = aw_addr_latched;
                            end
                            2'b01: begin // INCR
                                write_addr = aw_addr_latched + (write_data_count << aw_size_latched);
                            end
                            2'b10: begin // WRAP
                                automatic int unsigned wrap_boundary = (1 << aw_size_latched) * (aw_len_latched + 1);
                                automatic int unsigned offset = (write_data_count << aw_size_latched);
                                write_addr = (aw_addr_latched & ~(wrap_boundary - 1)) | 
                                            ((aw_addr_latched + offset) & (wrap_boundary - 1));
                            end
                            default: write_addr = aw_addr_latched;
                        endcase
                        
                        // Write to memory
                        memory[write_addr[13:2]] <= s_if.wdata;
                        write_data_count <= write_data_count + 1;
                        write_beats_remaining <= write_beats_remaining - 1;
                        
                        if (s_if.wlast) begin
                            s_if.wready <= 1'b0;
                            w_state <= W_DONE;
                        end
                    end
                end
                
                W_DONE: begin
                    if (b_state == B_DONE && aw_state == AW_IDLE) begin
                        w_state <= W_IDLE;
                    end
                end
            endcase
        end
    end
    
    //=========================================================================
    // Write Response Channel FSM
    //=========================================================================
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            b_state <= B_IDLE;
            s_if.bvalid <= 1'b0;
            s_if.bresp <= 2'b00;
            s_if.bid <= 4'h0;
        end else begin
            case (b_state)
                B_IDLE: begin
                    if (w_state == W_DONE) begin
                        b_state <= B_VALID;
                        s_if.bvalid <= 1'b1;
                        s_if.bresp <= 2'b00; // OKAY
                        s_if.bid <= slave_id[3:0];
                    end
                end
                
                B_VALID: begin
                    if (s_if.bready && s_if.bvalid) begin
                        s_if.bvalid <= 1'b0;
                        b_state <= B_DONE;
                    end
                end
                
                B_DONE: begin
                    if (aw_state == AW_IDLE && w_state == W_IDLE) begin
                        b_state <= B_IDLE;
                    end
                end
            endcase
        end
    end
    
    //=========================================================================
    // Read Address Channel FSM
    //=========================================================================
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            ar_state <= AR_IDLE;
            s_if.arready <= 1'b0;
            ar_addr_latched <= 32'h0;
            ar_len_latched <= 8'h0;
            ar_size_latched <= 3'h0;
            ar_burst_latched <= 2'h0;
            read_beats_remaining <= 0;
            delay_counter <= 0;
        end else begin
            case (ar_state)
                AR_IDLE: begin
                    if (s_if.arvalid) begin
                        if (delay_counter < delay_cycles) begin
                            delay_counter <= delay_counter + 1;
                            s_if.arready <= 1'b0;
                        end else begin
                            s_if.arready <= 1'b1;
                            ar_state <= AR_READY;
                            ar_addr_latched <= s_if.araddr;
                            ar_len_latched <= s_if.arlen;
                            ar_size_latched <= s_if.arsize;
                            ar_burst_latched <= s_if.arburst;
                            read_beats_remaining <= s_if.arlen + 1;
                            delay_counter <= 0;
                        end
                    end else begin
                        s_if.arready <= 1'b0;
                    end
                end
                
                AR_READY: begin
                    if (s_if.arvalid && s_if.arready) begin
                        s_if.arready <= 1'b0;
                        ar_state <= AR_DONE;
                    end
                end
                
                AR_DONE: begin
                    if (r_state == R_DONE) begin
                        ar_state <= AR_IDLE;
                    end
                end
            endcase
        end
    end
    
    //=========================================================================
    // Read Data Channel FSM
    //=========================================================================
    always_ff @(posedge s_if.ACLK or negedge s_if.ARESETN) begin
        if (!s_if.ARESETN) begin
            r_state <= R_IDLE;
            s_if.rvalid <= 1'b0;
            s_if.rdata <= 32'h0;
            s_if.rresp <= 2'b00;
            s_if.rlast <= 1'b0;
            s_if.rid <= 4'h0;
            read_data_count <= 0;
            current_read_addr <= 32'h0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    if (ar_state == AR_DONE) begin
                        r_state <= R_ACTIVE;
                        read_data_count <= 0;
                        current_read_addr <= ar_addr_latched;
                    end
                end
                
                R_ACTIVE: begin
                    if (!s_if.rvalid || (s_if.rvalid && s_if.rready)) begin
                        // Calculate address based on burst type
                        logic [31:0] read_addr;
                        automatic int unsigned wrap_boundary;
                        automatic int unsigned offset;
                        case (ar_burst_latched)
                            2'b00: begin // FIXED
                                read_addr = ar_addr_latched;
                            end
                            2'b01: begin // INCR
                                read_addr = ar_addr_latched + (read_data_count << ar_size_latched);
                            end
                            2'b10: begin // WRAP
                                wrap_boundary = (1 << ar_size_latched) * (ar_len_latched + 1);
                                offset = (read_data_count << ar_size_latched);
                                read_addr = (ar_addr_latched & ~(wrap_boundary - 1)) | 
                                           ((ar_addr_latched + offset) & (wrap_boundary - 1));
                            end
                            default: read_addr = ar_addr_latched;
                        endcase
                        
                        // Read from memory
                        s_if.rdata <= memory[read_addr[13:2]];
                        s_if.rresp <= 2'b00; // OKAY
                        s_if.rid <= slave_id[3:0];
                        s_if.rvalid <= 1'b1;
                        s_if.rlast <= (read_beats_remaining == 1);
                        
                        read_data_count <= read_data_count + 1;
                        read_beats_remaining <= read_beats_remaining - 1;
                        current_read_addr <= read_addr;
                        
                        if (read_beats_remaining == 1) begin
                            r_state <= R_DONE;
                        end
                    end
                end
                
                R_DONE: begin
                    if (s_if.rready && s_if.rvalid) begin
                        s_if.rvalid <= 1'b0;
                        s_if.rlast <= 1'b0;
                        r_state <= R_IDLE;
                    end
                end
            endcase
        end
    end
    
    // Debug output
    initial begin
        $display("[%0t] Slave %0d: Initialized with delay=%0d cycles", $time, slave_id, delay_cycles);
    end
    
endmodule

