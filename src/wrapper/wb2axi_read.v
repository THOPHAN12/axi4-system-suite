/*
 * wb2axi_read.v : Wishbone to AXI4 Read Converter
 * 
 * Converts Wishbone Classic read interface to AXI4 Read channels (AR + R)
 * Used for SERV instruction bus (read-only)
 * 
 * Wishbone Interface:
 *   - o_ibus_adr[31:0]  : Address
 *   - o_ibus_cyc        : Cycle (valid request)
 *   - i_ibus_rdt[31:0]  : Read data
 *   - i_ibus_ack        : Acknowledge
 * 
 * AXI4 Interface:
 *   - AR Channel: Address Read
 *   - R Channel: Read Data
 */

module wb2axi_read #(
    parameter ADDR_WIDTH   = 32,
    parameter DATA_WIDTH   = 32,
    parameter ID_WIDTH     = 4,
    parameter ENABLE_DEBUG = 1'b0
) (
    input  wire                    ACLK,
    input  wire                    ARESETN,
    
    // Wishbone Interface (Master side - connected to SERV)
    input  wire [ADDR_WIDTH-1:0]   wb_adr,
    input  wire                    wb_cyc,
    // Counter done signal (for bit-serial mode address capture)
    input  wire                    i_cnt_done,
    output reg  [DATA_WIDTH-1:0]   wb_rdt,
    output reg                     wb_ack,
    
    // AXI4 Read Address Channel (Master to Interconnect)
    output reg  [ID_WIDTH-1:0]     M_AXI_arid,
    output reg  [ADDR_WIDTH-1:0]   M_AXI_araddr,
    output reg  [7:0]              M_AXI_arlen,
    output reg  [2:0]              M_AXI_arsize,
    output reg  [1:0]              M_AXI_arburst,
    output reg  [1:0]              M_AXI_arlock,
    output reg  [3:0]              M_AXI_arcache,
    output reg  [2:0]              M_AXI_arprot,
    output reg  [3:0]              M_AXI_arqos,
    output reg  [3:0]              M_AXI_arregion,
    output reg                     M_AXI_arvalid,
    input  wire                    M_AXI_arready,
    
    // AXI4 Read Data Channel (Interconnect to Master)
    input  wire [ID_WIDTH-1:0]     M_AXI_rid,
    input  wire [DATA_WIDTH-1:0]   M_AXI_rdata,
    input  wire [1:0]              M_AXI_rresp,
    input  wire                    M_AXI_rlast,
    input  wire                    M_AXI_rvalid,
    output reg                     M_AXI_rready
);

// FSM States
localparam IDLE     = 2'b00;
localparam ADDR_REQ = 2'b01;
localparam DATA_WAIT = 2'b10;
localparam DATA_RECV = 2'b11;

reg [1:0] state;
reg [1:0] next_state;

// Address request latch
reg [ADDR_WIDTH-1:0] addr_latch;
reg addr_captured;  // Flag to track if address has been captured for current transaction
reg [ADDR_WIDTH-1:0] wb_adr_prev;  // Previous cycle address for debug
reg [31:0] cycle_count;  // Cycle counter for debug
reg wb_cyc_prev;  // Previous cycle wb_cyc for edge detection
reg cnt_done_prev;  // Previous cycle cnt_done for edge detection

always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state;
    
    case (state)
        IDLE: begin
            // Only transition to ADDR_REQ when wb_cyc is asserted AND address is captured (cnt_done=1)
            // This ensures we wait for address to be stable before sending AXI request
            if (wb_cyc && !wb_ack && addr_captured) begin
                next_state = ADDR_REQ;
            end
        end
        
        ADDR_REQ: begin
            if (M_AXI_arvalid && M_AXI_arready) begin
                next_state = DATA_WAIT;
            end
        end
        
        DATA_WAIT: begin
            if (M_AXI_rvalid && M_AXI_rready) begin
                next_state = IDLE;
            end
        end
        
        default: next_state = IDLE;
    endcase
end

// Update cnt_done_prev and wb_cyc_prev every cycle (for edge detection)
// This ensures both signals are updated in the same always block to avoid race conditions
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        cnt_done_prev <= 1'b0;
        wb_cyc_prev <= 1'b0;
    end else begin
        // Update wb_cyc_prev first (for edge detection)
        wb_cyc_prev <= wb_cyc;
        
        // Reset cnt_done_prev when new transaction starts (wb_cyc rising edge)
        // This ensures we don't use stale cnt_done_prev from previous transaction
        if (wb_cyc && !wb_cyc_prev) begin
            cnt_done_prev <= 1'b0;  // Reset when transaction starts
        end else begin
            cnt_done_prev <= i_cnt_done;
        end
    end
end

// Address Channel Logic
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_arvalid <= 1'b0;
        M_AXI_araddr  <= 32'h0;
        M_AXI_arlen   <= 8'h0;
        M_AXI_arsize  <= 3'b010;  // 4 bytes (32-bit word)
        M_AXI_arburst <= 2'b01;   // INCR burst
        M_AXI_arlock  <= 2'b00;
        M_AXI_arcache <= 4'b0011; // Normal Non-cacheable Bufferable
        M_AXI_arprot  <= 3'b000;  // Unprivileged, Secure, Data
        M_AXI_arqos   <= 4'h0;
        M_AXI_arregion <= 4'h0;
        M_AXI_arid    <= {ID_WIDTH{1'b0}};
        addr_latch    <= 32'h0;
        addr_captured <= 1'b0;
        wb_adr_prev   <= 32'hFFFFFFFF;  // Initialize to non-zero to detect first change
        cycle_count   <= 32'h0;
        wb_cyc_prev   <= 1'b0;
    end else begin
        case (state)
            IDLE: begin
                // Default assignments to avoid latches
                M_AXI_arsize  <= 3'b010;  // 4 bytes
                M_AXI_arburst <= 2'b01;   // INCR
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
                
                // Debug: Track wb_cyc transitions
                if (wb_cyc && !wb_cyc_prev) begin
                    if (ENABLE_DEBUG) begin
                        $display("[%0t] wb2axi_read: wb_cyc RISING EDGE! wb_adr=0x%08h, cnt_done=%0d", 
                                 $time, wb_adr, i_cnt_done);
                    end
                end else if (!wb_cyc && wb_cyc_prev) begin
                    if (ENABLE_DEBUG) begin
                        $display("[%0t] wb2axi_read: wb_cyc FALLING EDGE! cycle_count=%0d, addr_captured=%0d", 
                                 $time, cycle_count, addr_captured);
                    end
                end
                
                // Clear capture flag when in IDLE and no active transaction
                if (!wb_cyc) begin
                    addr_captured <= 1'b0;
                    cycle_count <= 32'h0;
                    // Don't reset wb_adr_prev here - keep it to track address changes across transactions
                    // Note: wb_cyc_prev is now updated in separate always block to avoid race conditions
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_araddr  <= 32'h0;
                    M_AXI_arlen  <= 8'h0;
                end else if (wb_cyc && !wb_ack) begin
                    // Debug: Print when wb_cyc is first asserted
                    if (cycle_count == 0) begin
                        if (ENABLE_DEBUG) begin
                            $display("[%0t] wb2axi_read: wb_cyc ASSERTED! wb_adr=0x%08h, cnt_done=%0d", 
                                     $time, wb_adr, i_cnt_done);
                        end
                    end
                    // Debug: Track address changes
                    cycle_count <= cycle_count + 1'b1;
                    
                    // Debug: Print address changes (only when address actually changes)
                    if (wb_adr != wb_adr_prev) begin
                        if (ENABLE_DEBUG) begin
                            $display("[%0t] wb2axi_read: wb_adr changed: 0x%08h -> 0x%08h (cycle %0d, state=%0d, cnt_done=%0d)", 
                                     $time, wb_adr_prev, wb_adr, cycle_count, state, i_cnt_done);
                        end
                    end
                    // Debug: Print cnt_done status periodically and when it changes
                    if (cycle_count % 32 == 0 && cycle_count > 0) begin
                        if (ENABLE_DEBUG) begin
                            $display("[%0t] wb2axi_read: Status - wb_cyc=%0d, cnt_done=%0d, addr_captured=%0d, wb_adr=0x%08h", 
                                     $time, wb_cyc, i_cnt_done, addr_captured, wb_adr);
                        end
                    end
                    // Debug: Print when cnt_done is asserted
                    if (i_cnt_done && !addr_captured) begin
                        if (ENABLE_DEBUG) begin
                            $display("[%0t] wb2axi_read: cnt_done ASSERTED! wb_cyc=%0d, wb_adr=0x%08h, cycle=%0d", 
                                     $time, wb_cyc, wb_adr, cycle_count);
                        end
                    end
                    // Debug: Print cnt_done every cycle for first 100 cycles to see pattern
                    if (cycle_count < 100) begin
                        if (ENABLE_DEBUG) begin
                            $display("[%0t] wb2axi_read: Cycle %0d - wb_cyc=%0d, wb_ack=%0d, cnt_done=%0d, wb_adr=0x%08h, addr_captured=%0d, M_AXI_arvalid=%0d", 
                                     $time, cycle_count, wb_cyc, wb_ack, i_cnt_done, wb_adr, addr_captured, M_AXI_arvalid);
                        end
                    end
                    // Debug: Print address value at key cycles to understand bit-serial encoding
                    if (cycle_count == 0 || cycle_count == 31 || cycle_count == 32 || cycle_count == 33) begin
                        if (ENABLE_DEBUG) begin
                            $display("[%0t] wb2axi_read: Key cycle %0d - wb_adr=0x%08h (binary: %032b)", 
                                     $time, cycle_count, wb_adr, wb_adr);
                        end
                    end
                    // Update previous address for next cycle comparison
                    wb_adr_prev <= wb_adr;
                    // Note: wb_cyc_prev and cnt_done_prev are now updated in separate always block to avoid race conditions
                    
                    // In bit-serial mode (W=1), SERV outputs PC in special format
                    // PC is shifted right each cycle: o_ibus_adr <= {new_pc, o_ibus_adr[31:1]}
                    // The address bits are transmitted serially over multiple cycles
                    // serv_aligner forwards the address directly: o_wb_ibus_adr = i_ibus_adr (or i_ibus_adr+4 for misaligned)
                    // So address from serv_aligner also changes each cycle in bit-serial mode
                    // In bit-serial mode, address bits are transmitted serially over 32 cycles
                    // 
                    // Strategy: Capture address when it becomes stable
                    // Option 1: Use cnt_done if available (most accurate)
                    // Option 2: Wait for address to stabilize (32 cycles) or use fixed delay
                    // Option 3: Capture when address stops changing (simpler but may miss timing)
                    //
                    // We use a hybrid approach:
                    // - If cnt_done is available and asserted, use it (most accurate)
                    // - Otherwise, wait for 32 cycles (worst case for bit-serial mode)
                    // - Also check if address has stabilized (not changed for a few cycles)
                    
                    if (!addr_captured) begin
                        // Priority 1: Use cnt_done if available (most accurate)
                        // In bit-serial mode, address is stable 1 cycle AFTER cnt_done asserts
                        // So we capture on the cycle AFTER cnt_done was asserted (cnt_done_prev=1)
                        // But only if cnt_done_prev was set during THIS transaction (cycle_count > 0)
                        // This ensures we capture the stable address after the shift completes
                        if (cnt_done_prev && wb_cyc && cycle_count > 0) begin
                            if (ENABLE_DEBUG) begin
                                $display("[%0t] wb2axi_read: Capturing address (1 cycle after cnt_done): wb_adr=0x%08h, masked=0x%08h (cycle %0d)", 
                                         $time, wb_adr, (wb_adr & 32'hFFFF_FFFC), cycle_count);
                            end
                            
                            // Address is now stable - capture it
                            // Word-align address (clear bits 1:0) - don't mask high bits
                            addr_latch <= (wb_adr & 32'hFFFF_FFFC);  // Word-align only (clear bits [1:0])
                            addr_captured <= 1'b1;
                            M_AXI_arvalid <= 1'b1;
                            M_AXI_araddr <= (wb_adr & 32'hFFFF_FFFC);
                            M_AXI_arlen <= 8'h0;
                        end
                        // Priority 1b: Use cnt_done rising edge, but wait 1 cycle before capturing
                        // This is a fallback if cnt_done_prev logic doesn't work correctly
                        // We use a flag to track when cnt_done was asserted, then capture next cycle
                        else if (i_cnt_done && !cnt_done_prev && wb_cyc) begin
                            // Don't capture immediately - wait for next cycle
                            // This will be handled by Priority 1 on next cycle
                            // Just mark that cnt_done was asserted
                            // (cnt_done_prev will be set next cycle, triggering Priority 1)
                        end
                        // Priority 2: Wait for 32 cycles (REQUIRED for bit-serial mode)
                        // In bit-serial mode, address bits are transmitted over 32 cycles
                        // After 32 cycles, address should be stable
                        // However, we need to capture at cycle 33 (after the 32nd shift completes)
                        // This is the PRIMARY method when cnt_done is not available
                        else if (cycle_count >= 33 && wb_cyc) begin
                            if (ENABLE_DEBUG) begin
                                $display("[%0t] wb2axi_read: Capturing address (33 cycles elapsed): wb_adr=0x%08h, masked=0x%08h (cycle %0d)", 
                                         $time, wb_adr, (wb_adr & 32'hFFFF_FFFC), cycle_count);
                            end
                            
                            // Address should be stable after 33 cycles (32 shifts + 1 cycle for stability) - capture it
                            addr_latch <= (wb_adr & 32'hFFFF_FFFC);  // Word-align only (clear bits [1:0])
                            addr_captured <= 1'b1;
                            M_AXI_arvalid <= 1'b1;
                            M_AXI_araddr <= (wb_adr & 32'hFFFF_FFFC);
                            M_AXI_arlen <= 8'h0;
                        end
                        // Priority 3: REMOVED - "address stable" check was capturing too early
                        // In bit-serial mode, address changes every cycle for 32 cycles
                        // We MUST wait for 32 cycles or cnt_done before capturing
                        // This fallback was causing incorrect address capture
                        // Do NOT capture address before 32 cycles have elapsed
                        else begin
                            // Wait for address to stabilize - don't send address yet
                            // Must wait for 32 cycles or cnt_done before capturing
                            M_AXI_arvalid <= 1'b0;
                            M_AXI_araddr <= 32'h0;
                            M_AXI_arlen <= 8'h0;
                        end
                    end else begin
                        // Address already captured - use latched address
                        M_AXI_arvalid <= 1'b1;
                        M_AXI_araddr <= addr_latch;  // Use latched address for entire transaction (AXI requirement)
                        M_AXI_arlen <= 8'h0;  // 1 transfer (single beat)
                    end
                end else begin
                    M_AXI_arvalid <= 1'b0;
                    M_AXI_araddr  <= 32'h0;
                    M_AXI_arlen   <= 8'h0;
                end
            end
            
            ADDR_REQ: begin
                // Default assignments to avoid latches
                M_AXI_arsize  <= 3'b010;
                M_AXI_arburst <= 2'b01;
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
                M_AXI_araddr  <= addr_latch;  // Use latched address
                M_AXI_arlen   <= 8'h0;
                
                // Keep arvalid asserted until handshake
                if (M_AXI_arvalid && M_AXI_arready) begin
                    M_AXI_arvalid <= 1'b0;
                end else if (!M_AXI_arvalid && addr_captured) begin
                    // Assert arvalid if address is captured but not yet asserted
                    M_AXI_arvalid <= 1'b1;
                end
            end
            
            DATA_WAIT: begin
                // Default assignments to avoid latches
                M_AXI_arvalid <= 1'b0;
                M_AXI_arsize  <= 3'b010;
                M_AXI_arburst <= 2'b01;
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
                M_AXI_araddr  <= addr_latch;
                M_AXI_arlen   <= 8'h0;
            end
            
            default: begin
                M_AXI_arvalid <= 1'b0;
                M_AXI_araddr  <= 32'h0;
                M_AXI_arlen   <= 8'h0;
                M_AXI_arsize  <= 3'b010;
                M_AXI_arburst <= 2'b01;
                M_AXI_arlock  <= 2'b00;
                M_AXI_arcache <= 4'b0011;
                M_AXI_arprot  <= 3'b000;
                M_AXI_arqos   <= 4'h0;
                M_AXI_arregion <= 4'h0;
                M_AXI_arid    <= {ID_WIDTH{1'b0}};
            end
        endcase
    end
end

// Read Data Channel Logic
always @(posedge ACLK or negedge ARESETN) begin
    if (!ARESETN) begin
        M_AXI_rready <= 1'b0;
        wb_rdt <= 32'h0;
        wb_ack <= 1'b0;
    end else begin
        wb_ack <= 1'b0;

        case (state)
            IDLE: begin
                M_AXI_rready <= 1'b0;
            end

            ADDR_REQ: begin
                if (M_AXI_arvalid && M_AXI_arready) begin
                    M_AXI_rready <= 1'b1;
                end
            end
            
            DATA_WAIT: begin
                // Assert wb_ack when data is received
                if (M_AXI_rvalid && M_AXI_rready) begin
                    wb_rdt <= M_AXI_rdata;
                    wb_ack <= 1'b1;
                    M_AXI_rready <= 1'b0;
                end
            end
            
            default: begin
                M_AXI_rready <= 1'b0;
            end
        endcase
    end
end

endmodule
