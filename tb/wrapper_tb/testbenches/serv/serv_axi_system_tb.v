/*
 * serv_axi_system_tb.v : Testbench for SERV + AXI System
 * 
 * Tests the complete system: SERV RISC-V processor with AXI Interconnect
 */

`timescale 1ns/1ps

module serv_axi_system_tb;

// Parameters
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter ID_WIDTH   = 4;
parameter CLK_PERIOD = 10;  // 100 MHz

// Clock and Reset
reg  ACLK;
reg  ARESETN;
reg  i_timer_irq;

// Instruction Memory (ROM) Interface
wire [ADDR_WIDTH-1:0]   M00_AXI_araddr;
wire [7:0]              M00_AXI_arlen;
wire [2:0]              M00_AXI_arsize;
wire [1:0]              M00_AXI_arburst;
wire [1:0]              M00_AXI_arlock;
wire [3:0]              M00_AXI_arcache;
wire [2:0]              M00_AXI_arprot;
wire [3:0]              M00_AXI_arregion;
wire [3:0]              M00_AXI_arqos;
wire                    M00_AXI_arvalid;
wire                    M00_AXI_arready;  // Output from memory slave

wire [DATA_WIDTH-1:0]   M00_AXI_rdata;    // Output from memory slave
wire [1:0]              M00_AXI_rresp;    // Output from memory slave
wire                    M00_AXI_rlast;    // Output from memory slave
wire                    M00_AXI_rvalid;   // Output from memory slave
wire                    M00_AXI_rready;

// Data Memory (RAM) Interface
wire [ID_WIDTH-1:0]     M01_AXI_awid;
wire [ADDR_WIDTH-1:0]   M01_AXI_awaddr;
wire [7:0]              M01_AXI_awlen;
wire [2:0]              M01_AXI_awsize;
wire [1:0]              M01_AXI_awburst;
wire [1:0]              M01_AXI_awlock;
wire [3:0]              M01_AXI_awcache;
wire [2:0]              M01_AXI_awprot;
wire [3:0]              M01_AXI_awqos;
wire [3:0]              M01_AXI_awregion;
wire                    M01_AXI_awvalid;
wire                    M01_AXI_awready;  // Output from memory slave

wire [DATA_WIDTH-1:0]   M01_AXI_wdata;
wire [(DATA_WIDTH/8)-1:0] M01_AXI_wstrb;
wire                    M01_AXI_wlast;
wire                    M01_AXI_wvalid;
wire                    M01_AXI_wready;    // Output from memory slave

wire [ID_WIDTH-1:0]     M01_AXI_bid;       // Output from memory slave
wire [1:0]              M01_AXI_bresp;     // Output from memory slave
wire                    M01_AXI_bvalid;    // Output from memory slave
wire                    M01_AXI_bready;

wire [ID_WIDTH-1:0]     M01_AXI_arid;
wire [ADDR_WIDTH-1:0]   M01_AXI_araddr;
wire [7:0]              M01_AXI_arlen;
wire [2:0]              M01_AXI_arsize;
wire [1:0]              M01_AXI_arburst;
wire [1:0]              M01_AXI_arlock;
wire [3:0]              M01_AXI_arcache;
wire [2:0]              M01_AXI_arprot;
wire [3:0]              M01_AXI_arqos;
wire [3:0]              M01_AXI_arregion;
wire                    M01_AXI_arvalid;
wire                    M01_AXI_arready;  // Output from memory slave

wire [ID_WIDTH-1:0]     M01_AXI_rid;       // Output from memory slave
wire [DATA_WIDTH-1:0]   M01_AXI_rdata;     // Output from memory slave
wire [1:0]              M01_AXI_rresp;     // Output from memory slave
wire                    M01_AXI_rlast;     // Output from memory slave
wire                    M01_AXI_rvalid;    // Output from memory slave
wire                    M01_AXI_rready;

// Clock generation
always begin
    ACLK = 1'b0;
    #(CLK_PERIOD/2);
    ACLK = 1'b1;
    #(CLK_PERIOD/2);
end

// Reset generation
initial begin
    ARESETN = 1'b0;
    i_timer_irq = 1'b0;
    #(CLK_PERIOD * 10);
    ARESETN = 1'b1;
    #(CLK_PERIOD * 1000);
    $finish;
end

// DUT Instance
serv_axi_system #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .ID_WIDTH           (ID_WIDTH),
    .WITH_CSR           (1),
    .W                  (1),
    .PRE_REGISTER       (1),
    .RESET_STRATEGY     ("MINI"),
    .RESET_PC           (32'h0000_0000),
    .DEBUG              (1'b0),
    .MDU                (1'b0),
    .COMPRESSED         (0),
    .Num_Of_Slaves      (2),
    .SLAVE0_ADDR1       (32'h0000_0000),
    .SLAVE0_ADDR2       (32'h0000_FFFF),
    .SLAVE1_ADDR1       (32'h1000_0000),
    .SLAVE1_ADDR2       (32'h1FFF_FFFF)
) u_dut (
    .ACLK               (ACLK),
    .ARESETN            (ARESETN),
    .i_timer_irq        (i_timer_irq),
    
    // Instruction Memory Interface
    .M00_AXI_araddr     (M00_AXI_araddr),
    .M00_AXI_arlen      (M00_AXI_arlen),
    .M00_AXI_arsize     (M00_AXI_arsize),
    .M00_AXI_arburst    (M00_AXI_arburst),
    .M00_AXI_arlock     (M00_AXI_arlock),
    .M00_AXI_arcache    (M00_AXI_arcache),
    .M00_AXI_arprot     (M00_AXI_arprot),
    .M00_AXI_arregion   (M00_AXI_arregion),
    .M00_AXI_arqos      (M00_AXI_arqos),
    .M00_AXI_arvalid    (M00_AXI_arvalid),
    .M00_AXI_arready    (M00_AXI_arready),
    .M00_AXI_rdata      (M00_AXI_rdata),
    .M00_AXI_rresp      (M00_AXI_rresp),
    .M00_AXI_rlast      (M00_AXI_rlast),
    .M00_AXI_rvalid     (M00_AXI_rvalid),
    .M00_AXI_rready     (M00_AXI_rready),
    
    // Data Memory Interface
    .M01_AXI_awid       (M01_AXI_awid),
    .M01_AXI_awaddr     (M01_AXI_awaddr),
    .M01_AXI_awlen      (M01_AXI_awlen),
    .M01_AXI_awsize     (M01_AXI_awsize),
    .M01_AXI_awburst    (M01_AXI_awburst),
    .M01_AXI_awlock     (M01_AXI_awlock),
    .M01_AXI_awcache    (M01_AXI_awcache),
    .M01_AXI_awprot     (M01_AXI_awprot),
    .M01_AXI_awqos      (M01_AXI_awqos),
    .M01_AXI_awregion   (M01_AXI_awregion),
    .M01_AXI_awvalid    (M01_AXI_awvalid),
    .M01_AXI_awready    (M01_AXI_awready),
    .M01_AXI_wdata      (M01_AXI_wdata),
    .M01_AXI_wstrb      (M01_AXI_wstrb),
    .M01_AXI_wlast      (M01_AXI_wlast),
    .M01_AXI_wvalid     (M01_AXI_wvalid),
    .M01_AXI_wready     (M01_AXI_wready),
    .M01_AXI_bid        (M01_AXI_bid),
    .M01_AXI_bresp      (M01_AXI_bresp),
    .M01_AXI_bvalid     (M01_AXI_bvalid),
    .M01_AXI_bready     (M01_AXI_bready),
    .M01_AXI_arid       (M01_AXI_arid),
    .M01_AXI_araddr     (M01_AXI_araddr),
    .M01_AXI_arlen      (M01_AXI_arlen),
    .M01_AXI_arsize     (M01_AXI_arsize),
    .M01_AXI_arburst    (M01_AXI_arburst),
    .M01_AXI_arlock     (M01_AXI_arlock),
    .M01_AXI_arcache    (M01_AXI_arcache),
    .M01_AXI_arprot     (M01_AXI_arprot),
    .M01_AXI_arqos      (M01_AXI_arqos),
    .M01_AXI_arregion   (M01_AXI_arregion),
    .M01_AXI_arvalid    (M01_AXI_arvalid),
    .M01_AXI_arready    (M01_AXI_arready),
    .M01_AXI_rid        (M01_AXI_rid),
    .M01_AXI_rdata      (M01_AXI_rdata),
    .M01_AXI_rresp      (M01_AXI_rresp),
    .M01_AXI_rlast      (M01_AXI_rlast),
    .M01_AXI_rvalid     (M01_AXI_rvalid),
    .M01_AXI_rready     (M01_AXI_rready)
);

// Instruction Memory (ROM) Slave
axi_rom_slave #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .ID_WIDTH           (ID_WIDTH),
    .MEM_SIZE           (1024),
    .MEM_INIT_FILE      ("../../sim/modelsim/test_program_simple.hex")  // Load test program
) u_inst_mem (
    .ACLK               (ACLK),
    .ARESETN            (ARESETN),
    .S_AXI_arid         (4'h0),  // Not used for read-only
    .S_AXI_araddr       (M00_AXI_araddr),
    .S_AXI_arlen        (M00_AXI_arlen),
    .S_AXI_arsize       (M00_AXI_arsize),
    .S_AXI_arburst      (M00_AXI_arburst),
    .S_AXI_arlock       (M00_AXI_arlock),
    .S_AXI_arcache      (M00_AXI_arcache),
    .S_AXI_arprot       (M00_AXI_arprot),
    .S_AXI_arqos        (M00_AXI_arqos),
    .S_AXI_arregion     (M00_AXI_arregion),
    .S_AXI_arvalid      (M00_AXI_arvalid),
    .S_AXI_arready      (M00_AXI_arready),
    .S_AXI_rid          (),
    .S_AXI_rdata        (M00_AXI_rdata),
    .S_AXI_rresp        (M00_AXI_rresp),
    .S_AXI_rlast        (M00_AXI_rlast),
    .S_AXI_rvalid       (M00_AXI_rvalid),
    .S_AXI_rready       (M00_AXI_rready)
);

// Data Memory (RAM) Slave
axi_memory_slave #(
    .ADDR_WIDTH         (ADDR_WIDTH),
    .DATA_WIDTH         (DATA_WIDTH),
    .ID_WIDTH           (ID_WIDTH),
    .MEM_SIZE           (1024),
    .MEM_INIT_FILE      ("")
) u_data_mem (
    .ACLK               (ACLK),
    .ARESETN            (ARESETN),
    .S_AXI_awid         (M01_AXI_awid),
    .S_AXI_awaddr       (M01_AXI_awaddr),
    .S_AXI_awlen        (M01_AXI_awlen),
    .S_AXI_awsize       (M01_AXI_awsize),
    .S_AXI_awburst      (M01_AXI_awburst),
    .S_AXI_awlock       (M01_AXI_awlock),
    .S_AXI_awcache      (M01_AXI_awcache),
    .S_AXI_awprot       (M01_AXI_awprot),
    .S_AXI_awqos        (M01_AXI_awqos),
    .S_AXI_awregion      (M01_AXI_awregion),
    .S_AXI_awvalid      (M01_AXI_awvalid),
    .S_AXI_awready      (M01_AXI_awready),
    .S_AXI_wdata        (M01_AXI_wdata),
    .S_AXI_wstrb        (M01_AXI_wstrb),
    .S_AXI_wlast        (M01_AXI_wlast),
    .S_AXI_wvalid       (M01_AXI_wvalid),
    .S_AXI_wready       (M01_AXI_wready),
    .S_AXI_bid          (M01_AXI_bid),
    .S_AXI_bresp        (M01_AXI_bresp),
    .S_AXI_bvalid       (M01_AXI_bvalid),
    .S_AXI_bready       (M01_AXI_bready),
    .S_AXI_arid         (M01_AXI_arid),
    .S_AXI_araddr       (M01_AXI_araddr),
    .S_AXI_arlen        (M01_AXI_arlen),
    .S_AXI_arsize       (M01_AXI_arsize),
    .S_AXI_arburst      (M01_AXI_arburst),
    .S_AXI_arlock       (M01_AXI_arlock),
    .S_AXI_arcache      (M01_AXI_arcache),
    .S_AXI_arprot       (M01_AXI_arprot),
    .S_AXI_arqos        (M01_AXI_arqos),
    .S_AXI_arregion     (M01_AXI_arregion),
    .S_AXI_arvalid      (M01_AXI_arvalid),
    .S_AXI_arready      (M01_AXI_arready),
    .S_AXI_rid          (M01_AXI_rid),
    .S_AXI_rdata        (M01_AXI_rdata),
    .S_AXI_rresp        (M01_AXI_rresp),
    .S_AXI_rlast        (M01_AXI_rlast),
    .S_AXI_rvalid       (M01_AXI_rvalid),
    .S_AXI_rready       (M01_AXI_rready)
);

// Monitoring
initial begin
    $dumpfile("serv_axi_system_tb.vcd");
    $dumpvars(0, serv_axi_system_tb);
end

// Test stimulus
initial begin
    // Wait for reset
    wait(ARESETN);
    #(CLK_PERIOD * 10);
    
    $display("=========================================");
    $display("SERV AXI System Testbench Started");
    $display("=========================================");
    $display("");
    $display("Connection Status:");
    $display("  - serv_axi_system.M00_AXI → axi_rom_slave (Instruction Memory)");
    $display("  - serv_axi_system.M01_AXI → axi_memory_slave (Data Memory)");
    $display("");
    $display("Address Mapping:");
    $display("  - Instruction Memory: 0x0000_0000 - 0x0000_FFFF");
    $display("  - Data Memory: 0x1000_0000 - 0x1FFF_FFFF");
    $display("");
    $display("=========================================");
    $display("Transaction Log:");
    $display("=========================================");
    
    // Monitor instruction fetches
    forever begin
        @(posedge ACLK);
        
        // Instruction Memory (M00) - Read Address
        if (M00_AXI_arvalid && M00_AXI_arready) begin
            $display("[%0t] [Interconnect→ROM] Instruction Fetch: Address = 0x%08h", 
                     $time, M00_AXI_araddr);
        end
        // Instruction Memory (M00) - Read Data
        if (M00_AXI_rvalid && M00_AXI_rready) begin
            $display("[%0t] [ROM→Interconnect] Instruction Read: Data = 0x%08h", 
                     $time, M00_AXI_rdata);
        end
        
        // Data Memory (M01) - Write Address
        if (M01_AXI_awvalid && M01_AXI_awready) begin
            $display("[%0t] [Interconnect→RAM] Data Write: Address = 0x%08h", 
                     $time, M01_AXI_awaddr);
        end
        // Data Memory (M01) - Write Data
        if (M01_AXI_wvalid && M01_AXI_wready) begin
            $display("[%0t] [Interconnect→RAM] Data Write: Data = 0x%08h, STRB = 0x%02h", 
                     $time, M01_AXI_wdata, M01_AXI_wstrb);
        end
        // Data Memory (M01) - Write Response
        if (M01_AXI_bvalid && M01_AXI_bready) begin
            $display("[%0t] [RAM→Interconnect] Write Response: resp = %0d", 
                     $time, M01_AXI_bresp);
        end
        // Data Memory (M01) - Read Address
        if (M01_AXI_arvalid && M01_AXI_arready) begin
            $display("[%0t] [Interconnect→RAM] Data Read: Address = 0x%08h", 
                     $time, M01_AXI_araddr);
        end
        // Data Memory (M01) - Read Data
        if (M01_AXI_rvalid && M01_AXI_rready) begin
            $display("[%0t] [RAM→Interconnect] Data Read: Data = 0x%08h", 
                     $time, M01_AXI_rdata);
        end
    end
end

endmodule

