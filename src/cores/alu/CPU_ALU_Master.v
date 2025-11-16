`timescale 1ns/1ps

//============================================================================
// CPU ALU Master - CPU with ALU connected via AXI4 Master Interface
// Purpose: Execute ALU operations by reading operands from memory and
//          writing results back to memory
//============================================================================
module CPU_ALU_Master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    // Global signals
    input  wire                          ACLK,
    input  wire                          ARESETN,
    
    // Control signals
    input  wire                          start,           // Start CPU execution
    output wire                          busy,            // CPU is busy
    output wire                          done,            // Instruction execution done
    
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
    output reg  [3:0]                   M_AXI_arregion,
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

    // Internal signals
    wire [3:0]                    alu_opcode;
    wire [DATA_WIDTH-1:0]         alu_operand_a;
    wire [DATA_WIDTH-1:0]         alu_operand_b;
    wire [DATA_WIDTH-1:0]         alu_result;
    wire                          alu_zero_flag;
    wire                          alu_carry_flag;
    
    wire                          controller_read_req;
    wire [ADDR_WIDTH-1:0]         controller_read_addr;
    wire                          controller_read_ready;
    wire                          controller_read_valid;
    wire [DATA_WIDTH-1:0]         controller_read_data;
    wire                          controller_read_done;
    
    wire                          controller_write_req;
    wire [ADDR_WIDTH-1:0]         controller_write_addr;
    wire [DATA_WIDTH-1:0]         controller_write_data;
    wire                          controller_write_ready;
    wire                          controller_write_data_ready;
    wire                          controller_write_done;
    
    // Instantiate ALU Core
    ALU_Core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu (
        .opcode(alu_opcode),
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .result(alu_result),
        .zero_flag(alu_zero_flag),
        .carry_flag(alu_carry_flag)
    );
    
    // Instantiate CPU Controller
    CPU_Controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_controller (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .start(start),
        .busy(busy),
        .done(done),
        .alu_opcode(alu_opcode),
        .alu_operand_a(alu_operand_a),
        .alu_operand_b(alu_operand_b),
        .alu_result(alu_result),
        .alu_zero_flag(alu_zero_flag),
        .alu_carry_flag(alu_carry_flag),
        .read_req(controller_read_req),
        .read_addr(controller_read_addr),
        .read_ready(controller_read_ready),
        .read_valid(controller_read_valid),
        .read_data(controller_read_data),
        .read_done(controller_read_done),
        .write_req(controller_write_req),
        .write_addr(controller_write_addr),
        .write_data(controller_write_data),
        .write_ready(controller_write_ready),
        .write_data_ready(controller_write_data_ready),
        .write_done(controller_write_done)
    );
    
    // ========================================================================
    // AXI Read Address Channel Control
    // ========================================================================
    reg read_addr_sent;
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M_AXI_arvalid <= 1'b0;
            M_AXI_araddr <= 32'h0;
            M_AXI_arlen <= 8'h0;
            M_AXI_arsize <= 3'b010;  // 4 bytes
            M_AXI_arburst <= 2'b01;  // INCR burst
            M_AXI_arlock <= 2'b00;
            M_AXI_arcache <= 4'b0000;
            M_AXI_arprot <= 3'b000;
            M_AXI_arregion <= 4'b0000;
            M_AXI_arqos <= 4'b0000;
            read_addr_sent <= 1'b0;
        end else begin
            if (controller_read_req && !read_addr_sent) begin
                M_AXI_arvalid <= 1'b1;
                M_AXI_araddr <= controller_read_addr;
                M_AXI_arlen <= 8'h0;  // Single transfer
                read_addr_sent <= 1'b1;
            end else if (M_AXI_arvalid && M_AXI_arready) begin
                M_AXI_arvalid <= 1'b0;
            end else if (controller_read_done) begin
                read_addr_sent <= 1'b0;
            end
        end
    end
    
    assign controller_read_ready = M_AXI_arvalid && M_AXI_arready;
    
    // ========================================================================
    // AXI Read Data Channel Control
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M_AXI_rready <= 1'b0;
        end else begin
            if (read_addr_sent || M_AXI_rvalid) begin
                M_AXI_rready <= 1'b1;
            end else begin
                M_AXI_rready <= 1'b0;
            end
        end
    end
    
    assign controller_read_valid = M_AXI_rvalid;
    assign controller_read_data = M_AXI_rdata;
    assign controller_read_done = M_AXI_rvalid && M_AXI_rready && M_AXI_rlast;
    
    // ========================================================================
    // AXI Write Address Channel Control
    // ========================================================================
    reg write_addr_sent;
    
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M_AXI_awvalid <= 1'b0;
            M_AXI_awaddr <= 32'h0;
            M_AXI_awlen <= 8'h0;
            M_AXI_awsize <= 3'b010;  // 4 bytes
            M_AXI_awburst <= 2'b01;  // INCR burst
            M_AXI_awlock <= 2'b00;
            M_AXI_awcache <= 4'b0000;
            M_AXI_awprot <= 3'b000;
            M_AXI_awregion <= 4'b0000;
            M_AXI_awqos <= 4'b0000;
            write_addr_sent <= 1'b0;
        end else begin
            if (controller_write_req && !write_addr_sent) begin
                M_AXI_awvalid <= 1'b1;
                M_AXI_awaddr <= controller_write_addr;
                M_AXI_awlen <= 8'h0;  // Single transfer
                write_addr_sent <= 1'b1;
            end else if (M_AXI_awvalid && M_AXI_awready) begin
                M_AXI_awvalid <= 1'b0;
            end else if (controller_write_done) begin
                write_addr_sent <= 1'b0;
            end
        end
    end
    
    assign controller_write_ready = M_AXI_awvalid && M_AXI_awready;
    
    // ========================================================================
    // AXI Write Data Channel Control
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M_AXI_wvalid <= 1'b0;
            M_AXI_wdata <= 32'h0;
            M_AXI_wstrb <= 4'hF;  // All bytes valid
            M_AXI_wlast <= 1'b0;
        end else begin
            if (controller_write_req && write_addr_sent && !M_AXI_wvalid) begin
                M_AXI_wvalid <= 1'b1;
                M_AXI_wdata <= controller_write_data;
                M_AXI_wstrb <= 4'hF;  // All bytes valid
                M_AXI_wlast <= 1'b1;
            end else if (M_AXI_wvalid && M_AXI_wready) begin
                M_AXI_wvalid <= 1'b0;
                M_AXI_wlast <= 1'b0;
            end
        end
    end
    
    assign controller_write_data_ready = M_AXI_wvalid && M_AXI_wready;
    
    // ========================================================================
    // AXI Write Response Channel Control
    // ========================================================================
    always @(posedge ACLK) begin
        if (!ARESETN) begin
            M_AXI_bready <= 1'b0;
        end else begin
            if (controller_write_req && write_addr_sent) begin
                M_AXI_bready <= 1'b1;
            end else if (M_AXI_bvalid && M_AXI_bready) begin
                M_AXI_bready <= 1'b0;
            end
        end
    end
    
    assign controller_write_done = M_AXI_bvalid && M_AXI_bready;

endmodule

