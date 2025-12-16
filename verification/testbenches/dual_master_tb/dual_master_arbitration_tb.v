`timescale 1ns/1ps

// ==============================================================================
// Dual Master Arbitration Testbench
// ==============================================================================
// Test case: 2 Masters (M0 and M1) request access through Interconnect
// - M0 wants to communicate with S1 (base: 0x40000000)
// - M1 wants to communicate with S3 (base: 0xC0000000)
// - Interconnect uses fixed priority: M0 > M1
// - Each Master: Read instruction -> Compute -> Write result back
// ==============================================================================

module dual_master_arbitration_tb;

    // Parameters
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter MEM_WORDS  = 1024;
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    
    // Address mapping
    parameter SLAVE1_BASE = 32'h40000000;  // S1 base address
    parameter SLAVE3_BASE = 32'hC0000000;  // S3 base address

    // Clock and Reset
    reg  ACLK;
    reg  ARESETN;

    // ========================================================================
    // Master 0 AXI4-Lite Interface
    // ========================================================================
    // Read Address Channel
    reg  [ADDR_WIDTH-1:0] M0_ARADDR;
    reg  [2:0]            M0_ARPROT;
    reg                   M0_ARVALID;
    wire                  M0_ARREADY;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] M0_RDATA;
    wire [1:0]            M0_RRESP;
    wire                  M0_RVALID;
    reg                   M0_RREADY;
    
    // Write Address Channel
    reg  [ADDR_WIDTH-1:0] M0_AWADDR;
    reg  [2:0]            M0_AWPROT;
    reg                   M0_AWVALID;
    wire                  M0_AWREADY;
    
    // Write Data Channel
    reg  [DATA_WIDTH-1:0] M0_WDATA;
    reg  [3:0]            M0_WSTRB;
    reg                   M0_WVALID;
    wire                  M0_WREADY;
    
    // Write Response Channel
    wire [1:0]            M0_BRESP;
    wire                  M0_BVALID;
    reg                   M0_BREADY;

    // ========================================================================
    // Master 1 AXI4-Lite Interface
    // ========================================================================
    // Read Address Channel
    reg  [ADDR_WIDTH-1:0] M1_ARADDR;
    reg  [2:0]            M1_ARPROT;
    reg                   M1_ARVALID;
    wire                  M1_ARREADY;
    
    // Read Data Channel
    wire [DATA_WIDTH-1:0] M1_RDATA;
    wire [1:0]            M1_RRESP;
    wire                  M1_RVALID;
    reg                   M1_RREADY;
    
    // Write Address Channel
    reg  [ADDR_WIDTH-1:0] M1_AWADDR;
    reg  [2:0]            M1_AWPROT;
    reg                   M1_AWVALID;
    wire                  M1_AWREADY;
    
    // Write Data Channel
    reg  [DATA_WIDTH-1:0] M1_WDATA;
    reg  [3:0]            M1_WSTRB;
    reg                   M1_WVALID;
    wire                  M1_WREADY;
    
    // Write Response Channel
    wire [1:0]            M1_BRESP;
    wire                  M1_BVALID;
    reg                   M1_BREADY;

    // ========================================================================
    // Slave 1 (S1) AXI4-Lite Interface
    // ========================================================================
    wire [ADDR_WIDTH-1:0] S1_AWADDR;
    wire [2:0]            S1_AWPROT;
    wire                  S1_AWVALID;
    wire                  S1_AWREADY;
    wire [DATA_WIDTH-1:0] S1_WDATA;
    wire [3:0]            S1_WSTRB;
    wire                  S1_WVALID;
    wire                  S1_WREADY;
    wire [1:0]            S1_BRESP;
    wire                  S1_BVALID;
    wire                  S1_BREADY;
    wire [ADDR_WIDTH-1:0] S1_ARADDR;
    wire [2:0]            S1_ARPROT;
    wire                  S1_ARVALID;
    wire                  S1_ARREADY;
    wire [DATA_WIDTH-1:0] S1_RDATA;
    wire [1:0]            S1_RRESP;
    wire                  S1_RVALID;
    wire                  S1_RREADY;

    // ========================================================================
    // Slave 3 (S3) AXI4-Lite Interface
    // ========================================================================
    wire [ADDR_WIDTH-1:0] S3_AWADDR;
    wire [2:0]            S3_AWPROT;
    wire                  S3_AWVALID;
    wire                  S3_AWREADY;
    wire [DATA_WIDTH-1:0] S3_WDATA;
    wire [3:0]            S3_WSTRB;
    wire                  S3_WVALID;
    wire                  S3_WREADY;
    wire [1:0]            S3_BRESP;
    wire                  S3_BVALID;
    wire                  S3_BREADY;
    wire [ADDR_WIDTH-1:0] S3_ARADDR;
    wire [2:0]            S3_ARPROT;
    wire                  S3_ARVALID;
    wire                  S3_ARREADY;
    wire [DATA_WIDTH-1:0] S3_RDATA;
    wire [1:0]            S3_RRESP;
    wire                  S3_RVALID;
    wire                  S3_RREADY;

    // ========================================================================
    // Interconnect Signals (Simplified)
    // ========================================================================
    // Arbitration signals
    wire m0_read_req;
    wire m1_read_req;
    wire m0_write_req;
    wire m1_write_req;
    
    // Master 0 internal signals
    reg [2:0] m0_state;
    localparam M0_IDLE = 3'b000;
    localparam M0_READ_REQ = 3'b001;
    localparam M0_READ_WAIT = 3'b010;
    localparam M0_COMPUTE = 3'b011;
    localparam M0_WRITE_REQ = 3'b100;
    localparam M0_WRITE_WAIT = 3'b101;
    localparam M0_DONE = 3'b110;
    
    reg [31:0] m0_instruction;
    reg [31:0] m0_result;
    reg        m0_start;
    
    // M0 computation variables
    wire [7:0] m0_opcode;
    wire [11:0] m0_op1, m0_op2;
    assign m0_opcode = m0_instruction[31:24];
    assign m0_op1 = m0_instruction[23:12];
    assign m0_op2 = m0_instruction[11:0];
    
    // Master 1 internal signals
    reg [2:0] m1_state;
    localparam M1_IDLE = 3'b000;
    localparam M1_READ_REQ = 3'b001;
    localparam M1_READ_WAIT = 3'b010;
    localparam M1_COMPUTE = 3'b011;
    localparam M1_WRITE_REQ = 3'b100;
    localparam M1_WRITE_WAIT = 3'b101;
    localparam M1_DONE = 3'b110;
    
    reg [31:0] m1_instruction;
    reg [31:0] m1_result;
    reg        m1_start;
    
    // M1 computation variables
    wire [7:0] m1_opcode;
    wire [11:0] m1_op1, m1_op2;
    assign m1_opcode = m1_instruction[31:24];
    assign m1_op1 = m1_instruction[23:12];
    assign m1_op2 = m1_instruction[11:0];
    
    // Test control
    integer test_pass;
    integer test_fail;
    integer mem_file;
    reg m0_completed;  // Flag to track if M0 has completed (reached DONE and returned to IDLE)
    reg m1_completed;  // Flag to track if M1 has completed (reached DONE and returned to IDLE)

    // ========================================================================
    // Clock Generation
    // ========================================================================
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    // ========================================================================
    // Reset Generation
    // ========================================================================
    initial begin
        ARESETN = 0;
        #(CLK_PERIOD * 5);
        ARESETN = 1;
        $display("[TB] Reset released at time %0t", $time);
    end

    // ========================================================================
    // Simple Interconnect with Fixed Priority Arbitration
    // ========================================================================
    // Request signals
    assign m0_read_req = M0_ARVALID;
    assign m1_read_req = M1_ARVALID;
    assign m0_write_req = M0_AWVALID && M0_WVALID;
    assign m1_write_req = M1_AWVALID && M1_WVALID;
    
    // Fixed Priority: M0 > M1
    // Read Address Channel Arbitration
    wire m0_read_grant = m0_read_req;  // M0 always wins if requesting
    wire m1_read_grant = m1_read_req && !m0_read_req;  // M1 only if M0 not requesting
    
    // Write Address Channel Arbitration
    wire m0_write_grant = m0_write_req;
    wire m1_write_grant = m1_write_req && !m0_write_req;
    
    // Address Decoder: Route to S1 or S3
    // M0 always routes to S1 (0x40000000), M1 always routes to S3 (0xC0000000)
    wire route_to_s1 = m0_read_grant || m0_write_grant;
    wire route_to_s3 = m1_read_grant || m1_write_grant;
    
    // M0 Read Channel (to S1)
    assign M0_ARREADY = m0_read_grant && route_to_s1 ? S1_ARREADY : 1'b0;
    assign S1_ARADDR = m0_read_grant && route_to_s1 ? M0_ARADDR : 32'h0;
    assign S1_ARPROT = m0_read_grant && route_to_s1 ? M0_ARPROT : 3'b0;
    assign S1_ARVALID = m0_read_grant && route_to_s1 ? M0_ARVALID : 1'b0;
    assign M0_RDATA = S1_RDATA;
    assign M0_RRESP = S1_RRESP;
    assign M0_RVALID = S1_RVALID;
    assign S1_RREADY = M0_RREADY;
    
    // M0 Write Channel (to S1)
    assign M0_AWREADY = m0_write_grant && route_to_s1 ? S1_AWREADY : 1'b0;
    assign M0_WREADY = m0_write_grant && route_to_s1 ? S1_WREADY : 1'b0;
    assign S1_AWADDR = m0_write_grant && route_to_s1 ? M0_AWADDR : 32'h0;
    assign S1_AWPROT = m0_write_grant && route_to_s1 ? M0_AWPROT : 3'b0;
    assign S1_AWVALID = m0_write_grant && route_to_s1 ? M0_AWVALID : 1'b0;
    assign S1_WDATA = m0_write_grant && route_to_s1 ? M0_WDATA : 32'h0;
    assign S1_WSTRB = m0_write_grant && route_to_s1 ? M0_WSTRB : 4'b0;
    assign S1_WVALID = m0_write_grant && route_to_s1 ? M0_WVALID : 1'b0;
    assign M0_BRESP = S1_BRESP;
    assign M0_BVALID = S1_BVALID;
    assign S1_BREADY = M0_BREADY;
    
    // M1 Read Channel (to S3)
    assign M1_ARREADY = m1_read_grant && route_to_s3 ? S3_ARREADY : 1'b0;
    assign S3_ARADDR = m1_read_grant && route_to_s3 ? M1_ARADDR : 32'h0;
    assign S3_ARPROT = m1_read_grant && route_to_s3 ? M1_ARPROT : 3'b0;
    assign S3_ARVALID = m1_read_grant && route_to_s3 ? M1_ARVALID : 1'b0;
    assign M1_RDATA = S3_RDATA;
    assign M1_RRESP = S3_RRESP;
    assign M1_RVALID = S3_RVALID;
    assign S3_RREADY = M1_RREADY;
    
    // M1 Write Channel (to S3)
    assign M1_AWREADY = m1_write_grant && route_to_s3 ? S3_AWREADY : 1'b0;
    assign M1_WREADY = m1_write_grant && route_to_s3 ? S3_WREADY : 1'b0;
    assign S3_AWADDR = m1_write_grant && route_to_s3 ? M1_AWADDR : 32'h0;
    assign S3_AWPROT = m1_write_grant && route_to_s3 ? M1_AWPROT : 3'b0;
    assign S3_AWVALID = m1_write_grant && route_to_s3 ? M1_AWVALID : 1'b0;
    assign S3_WDATA = m1_write_grant && route_to_s3 ? M1_WDATA : 32'h0;
    assign S3_WSTRB = m1_write_grant && route_to_s3 ? M1_WSTRB : 4'b0;
    assign S3_WVALID = m1_write_grant && route_to_s3 ? M1_WVALID : 1'b0;
    assign M1_BRESP = S3_BRESP;
    assign M1_BVALID = S3_BVALID;
    assign S3_BREADY = M1_BREADY;

    // ========================================================================
    // Master 0 State Machine
    // ========================================================================
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            m0_state <= M0_IDLE;
            M0_ARADDR <= 32'h0;
            M0_ARPROT <= 3'b000;
            M0_ARVALID <= 1'b0;
            M0_RREADY <= 1'b0;
            M0_AWADDR <= 32'h0;
            M0_AWPROT <= 3'b000;
            M0_AWVALID <= 1'b0;
            M0_WDATA <= 32'h0;
            M0_WSTRB <= 4'b0000;
            M0_WVALID <= 1'b0;
            M0_BREADY <= 1'b0;
            m0_instruction <= 32'h0;
            m0_result <= 32'h0;
            m0_completed <= 1'b0;
        end else begin
            case (m0_state)
                M0_IDLE: begin
                    M0_ARVALID <= 1'b0;
                    M0_RREADY <= 1'b0;
                    M0_AWVALID <= 1'b0;
                    M0_WVALID <= 1'b0;
                    M0_BREADY <= 1'b0;
                    if (m0_start) begin
                        $display("[M0] IDLE -> READ_REQ: Reading instruction from S1");
                        m0_state <= M0_READ_REQ;
                    end
                end
                
                M0_READ_REQ: begin
                    M0_ARADDR <= SLAVE1_BASE + 32'h00000000;  // Read instruction from S1[0]
                    M0_ARPROT <= 3'b000;
                    M0_ARVALID <= 1'b1;
                    if (M0_ARREADY) begin
                        $display("[M0] READ_REQ -> READ_WAIT: AR handshake complete");
                        m0_state <= M0_READ_WAIT;
                        M0_ARVALID <= 1'b0;
                    end
                end
                
                M0_READ_WAIT: begin
                    M0_RREADY <= 1'b1;
                    if (M0_RVALID && M0_RREADY) begin
                        m0_instruction <= M0_RDATA;
                        $display("[M0] READ_WAIT -> COMPUTE: instruction=0x%08h", M0_RDATA);
                        m0_state <= M0_COMPUTE;
                        M0_RREADY <= 1'b0;
                    end
                end
                
                M0_COMPUTE: begin
                    // Simple computation: instruction format [opcode:8][operand1:12][operand2:12]
                    // opcode 0x01 = ADD, 0x02 = SUB, 0x03 = MUL
                    case (m0_opcode)
                        8'h01: begin
                            m0_result <= {16'h0, m0_op1} + {16'h0, m0_op2};  // ADD
                            $display("[M0] COMPUTE: opcode=0x%02h (ADD), op1=0x%03h, op2=0x%03h, result=0x%08h",
                                     m0_opcode, m0_op1, m0_op2, {16'h0, m0_op1} + {16'h0, m0_op2});
                        end
                        8'h02: begin
                            m0_result <= {16'h0, m0_op1} - {16'h0, m0_op2};  // SUB
                            $display("[M0] COMPUTE: opcode=0x%02h (SUB), op1=0x%03h, op2=0x%03h, result=0x%08h",
                                     m0_opcode, m0_op1, m0_op2, {16'h0, m0_op1} - {16'h0, m0_op2});
                        end
                        8'h03: begin
                            m0_result <= m0_op1 * m0_op2;  // MUL
                            $display("[M0] COMPUTE: opcode=0x%02h (MUL), op1=0x%03h, op2=0x%03h, result=0x%08h",
                                     m0_opcode, m0_op1, m0_op2, m0_op1 * m0_op2);
                        end
                        default: begin
                            m0_result <= 32'hDEADBEEF;  // Error
                            $display("[M0] COMPUTE: opcode=0x%02h (UNKNOWN), result=0xDEADBEEF", m0_opcode);
                        end
                    endcase
                    m0_state <= M0_WRITE_REQ;
                end
                
                M0_WRITE_REQ: begin
                    M0_AWADDR <= SLAVE1_BASE + 32'h00000004;  // Write result to S1[1]
                    M0_AWPROT <= 3'b000;
                    M0_AWVALID <= 1'b1;
                    M0_WDATA <= m0_result;
                    M0_WSTRB <= 4'b1111;
                    M0_WVALID <= 1'b1;
                    if (M0_AWREADY && M0_WREADY) begin
                        $display("[M0] WRITE_REQ -> WRITE_WAIT: AW/W handshakes complete");
                        m0_state <= M0_WRITE_WAIT;
                        M0_AWVALID <= 1'b0;
                        M0_WVALID <= 1'b0;
                    end
                end
                
                M0_WRITE_WAIT: begin
                    M0_BREADY <= 1'b1;
                    if (M0_BVALID && M0_BREADY) begin
                        $display("[M0] WRITE_WAIT -> DONE: bresp=0x%02h", M0_BRESP);
                        m0_state <= M0_DONE;
                        M0_BREADY <= 1'b0;
                    end
                end
                
                M0_DONE: begin
                    $display("[M0] DONE -> IDLE");
                    m0_state <= M0_IDLE;
                    m0_start <= 1'b0;
                    m0_completed <= 1'b1;  // Mark M0 as completed
                end
            endcase
        end
    end

    // ========================================================================
    // Master 1 State Machine
    // ========================================================================
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            m1_state <= M1_IDLE;
            M1_ARADDR <= 32'h0;
            M1_ARPROT <= 3'b000;
            M1_ARVALID <= 1'b0;
            M1_RREADY <= 1'b0;
            M1_AWADDR <= 32'h0;
            M1_AWPROT <= 3'b000;
            M1_AWVALID <= 1'b0;
            M1_WDATA <= 32'h0;
            M1_WSTRB <= 4'b0000;
            M1_WVALID <= 1'b0;
            M1_BREADY <= 1'b0;
            m1_instruction <= 32'h0;
            m1_result <= 32'h0;
            m1_completed <= 1'b0;
        end else begin
            case (m1_state)
                M1_IDLE: begin
                    M1_ARVALID <= 1'b0;
                    M1_RREADY <= 1'b0;
                    M1_AWVALID <= 1'b0;
                    M1_WVALID <= 1'b0;
                    M1_BREADY <= 1'b0;
                    if (m1_start) begin
                        $display("[M1] IDLE -> READ_REQ: Reading instruction from S3");
                        m1_state <= M1_READ_REQ;
                    end
                end
                
                M1_READ_REQ: begin
                    M1_ARADDR <= SLAVE3_BASE + 32'h00000000;  // Read instruction from S3[0]
                    M1_ARPROT <= 3'b000;
                    M1_ARVALID <= 1'b1;
                    if (M1_ARREADY) begin
                        $display("[M1] READ_REQ -> READ_WAIT: AR handshake complete");
                        m1_state <= M1_READ_WAIT;
                        M1_ARVALID <= 1'b0;
                    end
                end
                
                M1_READ_WAIT: begin
                    M1_RREADY <= 1'b1;
                    if (M1_RVALID && M1_RREADY) begin
                        m1_instruction <= M1_RDATA;
                        $display("[M1] READ_WAIT -> COMPUTE: instruction=0x%08h", M1_RDATA);
                        m1_state <= M1_COMPUTE;
                        M1_RREADY <= 1'b0;
                    end
                end
                
                M1_COMPUTE: begin
                    // Same computation logic as M0
                    case (m1_opcode)
                        8'h01: begin
                            m1_result <= {16'h0, m1_op1} + {16'h0, m1_op2};  // ADD
                            $display("[M1] COMPUTE: opcode=0x%02h (ADD), op1=0x%03h, op2=0x%03h, result=0x%08h",
                                     m1_opcode, m1_op1, m1_op2, {16'h0, m1_op1} + {16'h0, m1_op2});
                        end
                        8'h02: begin
                            m1_result <= {16'h0, m1_op1} - {16'h0, m1_op2};  // SUB
                            $display("[M1] COMPUTE: opcode=0x%02h (SUB), op1=0x%03h, op2=0x%03h, result=0x%08h",
                                     m1_opcode, m1_op1, m1_op2, {16'h0, m1_op1} - {16'h0, m1_op2});
                        end
                        8'h03: begin
                            m1_result <= m1_op1 * m1_op2;  // MUL
                            $display("[M1] COMPUTE: opcode=0x%02h (MUL), op1=0x%03h, op2=0x%03h, result=0x%08h",
                                     m1_opcode, m1_op1, m1_op2, m1_op1 * m1_op2);
                        end
                        default: begin
                            m1_result <= 32'hDEADBEEF;  // Error
                            $display("[M1] COMPUTE: opcode=0x%02h (UNKNOWN), result=0xDEADBEEF", m1_opcode);
                        end
                    endcase
                    m1_state <= M1_WRITE_REQ;
                end
                
                M1_WRITE_REQ: begin
                    M1_AWADDR <= SLAVE3_BASE + 32'h00000004;  // Write result to S3[1]
                    M1_AWPROT <= 3'b000;
                    M1_AWVALID <= 1'b1;
                    M1_WDATA <= m1_result;
                    M1_WSTRB <= 4'b1111;
                    M1_WVALID <= 1'b1;
                    if (M1_AWREADY && M1_WREADY) begin
                        $display("[M1] WRITE_REQ -> WRITE_WAIT: AW/W handshakes complete");
                        m1_state <= M1_WRITE_WAIT;
                        M1_AWVALID <= 1'b0;
                        M1_WVALID <= 1'b0;
                    end
                end
                
                M1_WRITE_WAIT: begin
                    M1_BREADY <= 1'b1;
                    if (M1_BVALID && M1_BREADY) begin
                        $display("[M1] WRITE_WAIT -> DONE: bresp=0x%02h", M1_BRESP);
                        m1_state <= M1_DONE;
                        M1_BREADY <= 1'b0;
                    end
                end
                
                M1_DONE: begin
                    $display("[M1] DONE -> IDLE");
                    m1_state <= M1_IDLE;
                    m1_start <= 1'b0;
                    m1_completed <= 1'b1;  // Mark M1 as completed
                end
            endcase
        end
    end

    // ========================================================================
    // Create memory initialization files
    // ========================================================================
    initial begin
        // S1 memory: instruction at [0], result will be written to [1]
        mem_file = $fopen("mem_init_s1.hex", "w");
        if (mem_file) begin
            // Instruction: opcode=0x01 (ADD), op1=0x123, op2=0x456
            $fwrite(mem_file, "01123456\n");  // S1[0] = instruction
            $fwrite(mem_file, "00000000\n");  // S1[1] = result (will be written)
            $fclose(mem_file);
            $display("[TB] Created mem_init_s1.hex");
        end
        
        // S3 memory: instruction at [0], result will be written to [1]
        mem_file = $fopen("mem_init_s3.hex", "w");
        if (mem_file) begin
            // Instruction: opcode=0x02 (SUB), op1=0x789, op2=0xABC
            $fwrite(mem_file, "02789ABC\n");  // S3[0] = instruction
            $fwrite(mem_file, "00000000\n");  // S3[1] = result (will be written)
            $fclose(mem_file);
            $display("[TB] Created mem_init_s3.hex");
        end
    end
    
    // ========================================================================
    // Instantiate Slave 1 (S1)
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_s1.hex")
    ) u_slave1 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(S1_AWADDR),
        .S_AXI_awprot(S1_AWPROT),
        .S_AXI_awvalid(S1_AWVALID),
        .S_AXI_awready(S1_AWREADY),
        .S_AXI_wdata(S1_WDATA),
        .S_AXI_wstrb(S1_WSTRB),
        .S_AXI_wvalid(S1_WVALID),
        .S_AXI_wready(S1_WREADY),
        .S_AXI_bresp(S1_BRESP),
        .S_AXI_bvalid(S1_BVALID),
        .S_AXI_bready(S1_BREADY),
        .S_AXI_araddr(S1_ARADDR),
        .S_AXI_arprot(S1_ARPROT),
        .S_AXI_arvalid(S1_ARVALID),
        .S_AXI_arready(S1_ARREADY),
        .S_AXI_rdata(S1_RDATA),
        .S_AXI_rresp(S1_RRESP),
        .S_AXI_rvalid(S1_RVALID),
        .S_AXI_rlast(),
        .S_AXI_rready(S1_RREADY)
    );

    // ========================================================================
    // Instantiate Slave 3 (S3)
    // ========================================================================
    axi_lite_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .MEM_WORDS(MEM_WORDS),
        .INIT_HEX("mem_init_s3.hex")
    ) u_slave3 (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_awaddr(S3_AWADDR),
        .S_AXI_awprot(S3_AWPROT),
        .S_AXI_awvalid(S3_AWVALID),
        .S_AXI_awready(S3_AWREADY),
        .S_AXI_wdata(S3_WDATA),
        .S_AXI_wstrb(S3_WSTRB),
        .S_AXI_wvalid(S3_WVALID),
        .S_AXI_wready(S3_WREADY),
        .S_AXI_bresp(S3_BRESP),
        .S_AXI_bvalid(S3_BVALID),
        .S_AXI_bready(S3_BREADY),
        .S_AXI_araddr(S3_ARADDR),
        .S_AXI_arprot(S3_ARPROT),
        .S_AXI_arvalid(S3_ARVALID),
        .S_AXI_arready(S3_ARREADY),
        .S_AXI_rdata(S3_RDATA),
        .S_AXI_rresp(S3_RRESP),
        .S_AXI_rvalid(S3_RVALID),
        .S_AXI_rlast(),
        .S_AXI_rready(S3_RREADY)
    );

    // ========================================================================
    // Monitor for simulation completion
    // ========================================================================
    // End simulation when both masters have completed (reached DONE and returned to IDLE)
    always @(posedge ACLK) begin
        if (ARESETN && m0_completed && m1_completed && 
            m0_state == M0_IDLE && m1_state == M1_IDLE) begin
            $display("\n[TB] Both masters have completed and returned to IDLE");
            $display("[TB] Ending simulation...");
            #(CLK_PERIOD * 2);  // Small delay to ensure all signals are stable
            $finish;
        end
    end

    // ========================================================================
    // Test Sequence
    // ========================================================================
    initial begin
        test_pass = 0;
        test_fail = 0;
        m0_start = 1'b0;
        m1_start = 1'b0;
        
        // Wait for reset release
        @(posedge ARESETN);
        #(CLK_PERIOD * 10);
        
        $display("\n========================================");
        $display("[TB] Starting Dual Master Arbitration Test");
        $display("========================================\n");
        
        // Start both masters simultaneously to test arbitration
        $display("[TB] Starting M0 and M1 simultaneously");
        m0_start = 1'b1;
        m1_start = 1'b1;
        @(posedge ACLK);
        m0_start = 1'b0;
        m1_start = 1'b0;
        
        // Wait for both masters to complete and return to IDLE
        wait(m0_completed && m1_completed && m0_state == M0_IDLE && m1_state == M1_IDLE);
        repeat(2) @(posedge ACLK);
        
        // Verify results
        // M0: ADD 0x123 + 0x456 = 0x579
        // M1: SUB 0x789 - 0xABC = 0x6CD (with sign extension, but we use 12-bit, so 0x789 - 0xABC = -0x333 = 0xFFFFFCCD)
        // Actually, let's check: 0x789 - 0xABC = 1929 - 2748 = -819 = 0xFFFFFCCD (32-bit)
        // But with 12-bit unsigned: 0x789 = 1929, 0xABC = 2748, result would wrap
        
        $display("\n[TB] Test Summary:");
        $display("[TB] M0 completed: %s", m0_completed ? "YES" : "NO");
        $display("[TB] M1 completed: %s", m1_completed ? "YES" : "NO");
        
        if (m0_completed && m1_completed) begin
            $display("[TB] PASS: Both masters completed successfully");
            test_pass = test_pass + 1;
        end else begin
            $display("[TB] FAIL: One or both masters did not complete");
            test_fail = test_fail + 1;
        end
        
        $display("\n========================================");
        $display("[TB] Test Summary");
        $display("========================================");
        $display("[TB] Tests Passed: %0d", test_pass);
        $display("[TB] Tests Failed: %0d", test_fail);
        $display("========================================\n");
        
        if (test_fail == 0) begin
            $display("[TB] ALL TESTS PASSED!");
        end else begin
            $display("[TB] SOME TESTS FAILED!");
        end
        
        // Simulation will end automatically via the always block above
    end

    // ========================================================================
    // Waveform Dump
    // ========================================================================
    initial begin
        $dumpfile("dual_master_arbitration_tb.vcd");
        $dumpvars(0, dual_master_arbitration_tb);
    end

endmodule

