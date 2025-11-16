`timescale 1ns/1ps

//============================================================================
// Simple AXI Master Test Module
// Purpose: Simple AXI4 Master for testing interconnect and slaves
// Features: 
//   - Single transaction read/write
//   - Control via start signal and base_address input
//   - Automatic test sequence execution
//============================================================================
module Simple_AXI_Master_Test #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
) (
    // Global signals
    input  wire                          ACLK,
    input  wire                          ARESETN,
    
    // Control signals
    input  wire                          start,           // Start test sequence
    input  wire [ADDR_WIDTH-1:0]         base_address,    // Base address for test
    output reg                           busy,            // Test in progress
    output reg                           done,            // Test completed
    
    // ========================================================================
    // AXI4 Write Address Channel
    // ========================================================================
    output reg  [ADDR_WIDTH-1:0]         M_AXI_awaddr,
    output reg  [7:0]                    M_AXI_awlen,
    output reg  [2:0]                    M_AXI_awsize,
    output reg  [1:0]                    M_AXI_awburst,
    output reg  [1:0]                    M_AXI_awlock,
    output reg  [3:0]                    M_AXI_awcache,
    output reg  [2:0]                    M_AXI_awprot,
    output reg  [3:0]                    M_AXI_awregion,
    output reg  [3:0]                    M_AXI_awqos,
    output reg                           M_AXI_awvalid,
    input  wire                          M_AXI_awready,
    
    // ========================================================================
    // AXI4 Write Data Channel
    // ========================================================================
    output reg  [DATA_WIDTH-1:0]         M_AXI_wdata,
    output reg  [(DATA_WIDTH/8)-1:0]     M_AXI_wstrb,
    output reg                           M_AXI_wlast,
    output reg                           M_AXI_wvalid,
    input  wire                          M_AXI_wready,
    
    // ========================================================================
    // AXI4 Write Response Channel
    // ========================================================================
    input  wire [1:0]                    M_AXI_bresp,
    input  wire                          M_AXI_bvalid,
    output reg                           M_AXI_bready,
    
    // ========================================================================
    // AXI4 Read Address Channel
    // ========================================================================
    output reg  [ADDR_WIDTH-1:0]         M_AXI_araddr,
    output reg  [7:0]                    M_AXI_arlen,
    output reg  [2:0]                    M_AXI_arsize,
    output reg  [1:0]                    M_AXI_arburst,
    output reg  [1:0]                    M_AXI_arlock,
    output reg  [3:0]                    M_AXI_arcache,
    output reg  [2:0]                    M_AXI_arprot,
    output reg  [3:0]                    M_AXI_arregion,
    output reg  [3:0]                    M_AXI_arqos,
    output reg                           M_AXI_arvalid,
    input  wire                          M_AXI_arready,
    
    // ========================================================================
    // AXI4 Read Data Channel
    // ========================================================================
    input  wire [DATA_WIDTH-1:0]         M_AXI_rdata,
    input  wire [1:0]                    M_AXI_rresp,
    input  wire                          M_AXI_rlast,
    input  wire                          M_AXI_rvalid,
    output reg                           M_AXI_rready
);

    // ========================================================================
    // State Machine
    // ========================================================================
    localparam IDLE         = 4'd0;
    localparam WRITE_ADDR   = 4'd1;
    localparam WRITE_DATA   = 4'd2;
    localparam WRITE_RESP   = 4'd3;
    localparam READ_ADDR    = 4'd4;
    localparam READ_DATA    = 4'd5;
    localparam VERIFY       = 4'd6;
    localparam DONE_STATE   = 4'd7;
    
    reg [3:0] state, next_state;
    
    // Internal registers
    reg [DATA_WIDTH-1:0] write_data;
    reg [DATA_WIDTH-1:0] read_data;
    reg [ADDR_WIDTH-1:0] test_addr;
    
    // ========================================================================
    // State Register
    // ========================================================================
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // ========================================================================
    // Next State Logic
    // ========================================================================
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = WRITE_ADDR;
            end
            
            WRITE_ADDR: begin
                if (M_AXI_awvalid && M_AXI_awready)
                    next_state = WRITE_DATA;
            end
            
            WRITE_DATA: begin
                if (M_AXI_wvalid && M_AXI_wready)
                    next_state = WRITE_RESP;
            end
            
            WRITE_RESP: begin
                if (M_AXI_bvalid && M_AXI_bready)
                    next_state = READ_ADDR;
            end
            
            READ_ADDR: begin
                if (M_AXI_arvalid && M_AXI_arready)
                    next_state = READ_DATA;
            end
            
            READ_DATA: begin
                if (M_AXI_rvalid && M_AXI_rready)
                    next_state = VERIFY;
            end
            
            VERIFY: begin
                next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // ========================================================================
    // Output Logic
    // ========================================================================
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            // Reset all outputs
            M_AXI_awaddr   <= {ADDR_WIDTH{1'b0}};
            M_AXI_awlen    <= 8'h00;
            M_AXI_awsize   <= 3'b010;  // 4 bytes
            M_AXI_awburst  <= 2'b01;   // INCR
            M_AXI_awlock   <= 2'b00;
            M_AXI_awcache  <= 4'b0000;
            M_AXI_awprot   <= 3'b000;
            M_AXI_awregion <= 4'h0;
            M_AXI_awqos    <= 4'h0;
            M_AXI_awvalid  <= 1'b0;
            
            M_AXI_wdata    <= {DATA_WIDTH{1'b0}};
            M_AXI_wstrb    <= {(DATA_WIDTH/8){1'b1}};
            M_AXI_wlast    <= 1'b0;
            M_AXI_wvalid   <= 1'b0;
            
            M_AXI_bready   <= 1'b0;
            
            M_AXI_araddr   <= {ADDR_WIDTH{1'b0}};
            M_AXI_arlen    <= 8'h00;
            M_AXI_arsize   <= 3'b010;  // 4 bytes
            M_AXI_arburst  <= 2'b01;   // INCR
            M_AXI_arlock   <= 2'b00;
            M_AXI_arcache  <= 4'b0000;
            M_AXI_arprot   <= 3'b000;
            M_AXI_arregion <= 4'h0;
            M_AXI_arqos    <= 4'h0;
            M_AXI_arvalid  <= 1'b0;
            
            M_AXI_rready   <= 1'b0;
            
            busy           <= 1'b0;
            done           <= 1'b0;
            
            test_addr      <= {ADDR_WIDTH{1'b0}};
            write_data     <= {DATA_WIDTH{1'b0}};
            read_data      <= {DATA_WIDTH{1'b0}};
            
        end else begin
            // Default values
            M_AXI_awvalid <= 1'b0;
            M_AXI_wvalid  <= 1'b0;
            M_AXI_bready  <= 1'b0;
            M_AXI_arvalid <= 1'b0;
            M_AXI_rready  <= 1'b0;
            done          <= 1'b0;
            
            case (state)
                IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        test_addr  <= base_address;
                        write_data <= base_address[15:0] + 32'hA5A5_0000; // Generate test data based on address
                    end
                end
                
                WRITE_ADDR: begin
                    busy          <= 1'b1;
                    M_AXI_awaddr  <= test_addr;
                    M_AXI_awlen   <= 8'h00;      // Single transfer
                    M_AXI_awsize  <= 3'b010;     // 4 bytes (32-bit)
                    M_AXI_awvalid <= 1'b1;
                end
                
                WRITE_DATA: begin
                    busy         <= 1'b1;
                    M_AXI_wdata  <= write_data;
                    M_AXI_wstrb  <= 4'hF;        // All bytes valid
                    M_AXI_wlast  <= 1'b1;        // Last (and only) data
                    M_AXI_wvalid <= 1'b1;
                end
                
                WRITE_RESP: begin
                    busy         <= 1'b1;
                    M_AXI_bready <= 1'b1;
                end
                
                READ_ADDR: begin
                    busy          <= 1'b1;
                    M_AXI_araddr  <= test_addr;
                    M_AXI_arlen   <= 8'h00;      // Single transfer
                    M_AXI_arsize  <= 3'b010;     // 4 bytes (32-bit)
                    M_AXI_arvalid <= 1'b1;
                end
                
                READ_DATA: begin
                    busy         <= 1'b1;
                    M_AXI_rready <= 1'b1;
                    if (M_AXI_rvalid) begin
                        read_data <= M_AXI_rdata;
                    end
                end
                
                VERIFY: begin
                    busy <= 1'b1;
                    // Verification is handled in testbench monitor
                end
                
                DONE_STATE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
                
                default: begin
                    busy <= 1'b0;
                end
            endcase
        end
    end

endmodule

