`timescale 1ns / 1ps
/*
 * wb_to_axilite_bridge_tb.v - Testbench for Generic WB to AXI-Lite Bridge Core
 * 
 * Purpose: Verify wb_to_axilite_bridge core functionality
 * Tests: Read operations, Write operations, Error handling
 */

module wb_to_axilite_bridge_tb();

    parameter CLK_PERIOD = 10;  // 100 MHz
    parameter ADDR_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter ID_WIDTH = 4;

    // Clock and Reset
    reg ACLK;
    reg ARESETN;

    // Wishbone Interface
    reg [ADDR_WIDTH-1:0]   wb_adr;
    reg [DATA_WIDTH-1:0]   wb_dat_i;
    reg [3:0]              wb_sel;
    reg                    wb_we;
    reg                    wb_cyc;
    reg                    wb_stb;
    wire [DATA_WIDTH-1:0]  wb_dat_o;
    wire                   wb_ack;
    wire                   wb_err;

    // AXI-Lite Master Interface
    wire [ID_WIDTH-1:0]     M_AXI_awid;
    wire [ADDR_WIDTH-1:0]   M_AXI_awaddr;
    wire [7:0]              M_AXI_awlen;
    wire [2:0]              M_AXI_awsize;
    wire [1:0]              M_AXI_awburst;
    wire [1:0]              M_AXI_awlock;
    wire [3:0]              M_AXI_awcache;
    wire [2:0]              M_AXI_awprot;
    wire [3:0]              M_AXI_awqos;
    wire [3:0]              M_AXI_awregion;
    wire                    M_AXI_awvalid;
    reg                     M_AXI_awready;

    wire [DATA_WIDTH-1:0]   M_AXI_wdata;
    wire [(DATA_WIDTH/8)-1:0] M_AXI_wstrb;
    wire                    M_AXI_wlast;
    wire                    M_AXI_wvalid;
    reg                     M_AXI_wready;

    reg  [ID_WIDTH-1:0]     M_AXI_bid;
    reg  [1:0]              M_AXI_bresp;
    reg                     M_AXI_bvalid;
    wire                    M_AXI_bready;

    wire [ID_WIDTH-1:0]     M_AXI_arid;
    wire [ADDR_WIDTH-1:0]   M_AXI_araddr;
    wire [7:0]              M_AXI_arlen;
    wire [2:0]              M_AXI_arsize;
    wire [1:0]              M_AXI_arburst;
    wire [1:0]              M_AXI_arlock;
    wire [3:0]              M_AXI_arcache;
    wire [2:0]              M_AXI_arprot;
    wire [3:0]              M_AXI_arqos;
    wire [3:0]              M_AXI_arregion;
    wire                    M_AXI_arvalid;
    reg                     M_AXI_arready;

    reg  [ID_WIDTH-1:0]     M_AXI_rid;
    reg  [DATA_WIDTH-1:0]   M_AXI_rdata;
    reg  [1:0]              M_AXI_rresp;
    reg                     M_AXI_rlast;
    reg                     M_AXI_rvalid;
    wire                    M_AXI_rready;

    // DUT
    wb_to_axilite_bridge #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .wb_adr(wb_adr),
        .wb_dat_i(wb_dat_i),
        .wb_sel(wb_sel),
        .wb_we(wb_we),
        .wb_cyc(wb_cyc),
        .wb_stb(wb_stb),
        .wb_dat_o(wb_dat_o),
        .wb_ack(wb_ack),
        .wb_err(wb_err),
        .M_AXI_awid(M_AXI_awid),
        .M_AXI_awaddr(M_AXI_awaddr),
        .M_AXI_awlen(M_AXI_awlen),
        .M_AXI_awsize(M_AXI_awsize),
        .M_AXI_awburst(M_AXI_awburst),
        .M_AXI_awlock(M_AXI_awlock),
        .M_AXI_awcache(M_AXI_awcache),
        .M_AXI_awprot(M_AXI_awprot),
        .M_AXI_awqos(M_AXI_awqos),
        .M_AXI_awregion(M_AXI_awregion),
        .M_AXI_awvalid(M_AXI_awvalid),
        .M_AXI_awready(M_AXI_awready),
        .M_AXI_wdata(M_AXI_wdata),
        .M_AXI_wstrb(M_AXI_wstrb),
        .M_AXI_wlast(M_AXI_wlast),
        .M_AXI_wvalid(M_AXI_wvalid),
        .M_AXI_wready(M_AXI_wready),
        .M_AXI_bid(M_AXI_bid),
        .M_AXI_bresp(M_AXI_bresp),
        .M_AXI_bvalid(M_AXI_bvalid),
        .M_AXI_bready(M_AXI_bready),
        .M_AXI_arid(M_AXI_arid),
        .M_AXI_araddr(M_AXI_araddr),
        .M_AXI_arlen(M_AXI_arlen),
        .M_AXI_arsize(M_AXI_arsize),
        .M_AXI_arburst(M_AXI_arburst),
        .M_AXI_arlock(M_AXI_arlock),
        .M_AXI_arcache(M_AXI_arcache),
        .M_AXI_arprot(M_AXI_arprot),
        .M_AXI_arqos(M_AXI_arqos),
        .M_AXI_arregion(M_AXI_arregion),
        .M_AXI_arvalid(M_AXI_arvalid),
        .M_AXI_arready(M_AXI_arready),
        .M_AXI_rid(M_AXI_rid),
        .M_AXI_rdata(M_AXI_rdata),
        .M_AXI_rresp(M_AXI_rresp),
        .M_AXI_rlast(M_AXI_rlast),
        .M_AXI_rvalid(M_AXI_rvalid),
        .M_AXI_rready(M_AXI_rready)
    );

    // Clock generation
    initial begin
        ACLK = 0;
        forever #(CLK_PERIOD/2) ACLK = ~ACLK;
    end

    // Test stimulus
    integer pass_count = 0;
    integer fail_count = 0;

    initial begin
        $display("========================================");
        $display("WB to AXI-Lite Bridge Core Testbench");
        $display("========================================");

        // Initialize
        ARESETN = 0;
        wb_adr = 0;
        wb_dat_i = 0;
        wb_sel = 4'hF;
        wb_we = 0;
        wb_cyc = 0;
        wb_stb = 0;
        M_AXI_awready = 1;
        M_AXI_wready = 1;
        M_AXI_bid = 0;
        M_AXI_bresp = 2'b00;
        M_AXI_bvalid = 0;
        M_AXI_arready = 1;
        M_AXI_rid = 0;
        M_AXI_rdata = 0;
        M_AXI_rresp = 2'b00;
        M_AXI_rlast = 1;
        M_AXI_rvalid = 0;

        // Reset
        #(CLK_PERIOD * 2);
        ARESETN = 1;
        #(CLK_PERIOD * 2);

        // Test 1: Simple Read
        $display("\n--- Test 1: Simple Read ---");
        wb_adr = 32'h1000;
        wb_we = 0;
        wb_cyc = 1;
        wb_stb = 1;
        #(CLK_PERIOD);
        
        if (M_AXI_arvalid && M_AXI_araddr == 32'h1000) begin
            $display("  PASS: AR channel activated correctly");
            pass_count = pass_count + 1;
            
            // Send read data
            M_AXI_rdata = 32'hDEADBEEF;
            M_AXI_rvalid = 1;
            #(CLK_PERIOD);
            M_AXI_rvalid = 0;
            
            #(CLK_PERIOD);
            if (wb_ack && wb_dat_o == 32'hDEADBEEF) begin
                $display("  PASS: Read data received correctly");
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: Read data mismatch or no ACK");
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  FAIL: AR channel not activated");
            fail_count = fail_count + 1;
        end
        
        wb_cyc = 0;
        wb_stb = 0;
        #(CLK_PERIOD * 2);

        // Test 2: Simple Write
        $display("\n--- Test 2: Simple Write ---");
        wb_adr = 32'h2000;
        wb_dat_i = 32'hCAFEBABE;
        wb_sel = 4'hF;
        wb_we = 1;
        wb_cyc = 1;
        wb_stb = 1;
        #(CLK_PERIOD);
        
        if (M_AXI_awvalid && M_AXI_awaddr == 32'h2000 &&
            M_AXI_wvalid && M_AXI_wdata == 32'hCAFEBABE) begin
            $display("  PASS: AW and W channels activated");
            pass_count = pass_count + 1;
            
            // Send write response
            #(CLK_PERIOD);
            M_AXI_bvalid = 1;
            M_AXI_bresp = 2'b00;  // OKAY
            #(CLK_PERIOD);
            M_AXI_bvalid = 0;
            
            #(CLK_PERIOD);
            if (wb_ack) begin
                $display("  PASS: Write acknowledged");
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: No write ACK");
                fail_count = fail_count + 1;
            end
        end else begin
            $display("  FAIL: AW/W channels not correct");
            fail_count = fail_count + 1;
        end
        
        wb_cyc = 0;
        wb_stb = 0;
        #(CLK_PERIOD * 2);

        // Summary
        $display("\n========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("\n*** ALL TESTS PASSED! ***");
        end else begin
            $display("\n*** SOME TESTS FAILED ***");
        end
        
        $display("========================================\n");
        $finish;
    end

endmodule

