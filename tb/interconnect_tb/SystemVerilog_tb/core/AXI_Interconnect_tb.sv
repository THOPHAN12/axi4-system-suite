`timescale 1ns/1ps

import axi_tb_pkg::*;

module AXI_Interconnect_tb;

    localparam int NUM_MASTERS = 2;
    localparam int NUM_SLAVES  = 2;
    localparam int ADDR_W      = 32;
    localparam int LEN_W       = 4;
    localparam int SIZE_W      = 3;
    localparam int DATA_W      = 32;

    localparam logic [31:0] SLAVE_ADDR_LO [NUM_SLAVES] = '{
        32'h0000_0000,
        32'h0001_0000
    };
    localparam logic [31:0] SLAVE_ADDR_HI [NUM_SLAVES] = '{
        32'h0000_0FFF,
        32'h0001_0FFF
    };

    logic clk;
    logic reset_n;

    axi_master_if #(ADDR_W, LEN_W, SIZE_W, DATA_W) master_if [NUM_MASTERS] (clk, reset_n);
    axi_slave_if  #(ADDR_W, LEN_W, SIZE_W, DATA_W) slave_if  [NUM_SLAVES]  (clk, reset_n);

    // -------------------------------------------------------------------------
    // DUT Connections
    // -------------------------------------------------------------------------
    AXI_Interconnect dut (
        .G_clk         (clk),
        .G_reset       (reset_n),

        // Master 0
        .M0_RREADY     (master_if[0].rready),
        .M0_ARADDR     (master_if[0].araddr),
        .M0_ARLEN      (master_if[0].arlen),
        .M0_ARSIZE     (master_if[0].arsize),
        .M0_ARBURST    (master_if[0].arburst),
        .M0_ARVALID    (master_if[0].arvalid),

        // Master 1
        .M1_RREADY     (master_if[1].rready),
        .M1_ARADDR     (master_if[1].araddr),
        .M1_ARLEN      (master_if[1].arlen),
        .M1_ARSIZE     (master_if[1].arsize),
        .M1_ARBURST    (master_if[1].arburst),
        .M1_ARVALID    (master_if[1].arvalid),

        // Slave responses
        .S0_ARREADY    (slave_if[0].arready),
        .S0_RVALID     (slave_if[0].rvalid),
        .S0_RLAST      (slave_if[0].rlast),
        .S0_RRESP      (slave_if[0].rresp),
        .S0_RDATA      (slave_if[0].rdata),

        .S1_ARREADY    (slave_if[1].arready),
        .S1_RVALID     (slave_if[1].rvalid),
        .S1_RLAST      (slave_if[1].rlast),
        .S1_RRESP      (slave_if[1].rresp),
        .S1_RDATA      (slave_if[1].rdata),

        // Address map
        .slave0_addr1  (SLAVE_ADDR_LO[0]),
        .slave0_addr2  (SLAVE_ADDR_HI[0]),
        .slave1_addr1  (SLAVE_ADDR_LO[1]),
        .slave1_addr2  (SLAVE_ADDR_HI[1]),

        // Master responses
        .ARREADY_M0    (master_if[0].arready),
        .RVALID_M0     (master_if[0].rvalid),
        .RLAST_M0      (master_if[0].rlast),
        .RRESP_M0      (master_if[0].rresp),
        .RDATA_M0      (master_if[0].rdata),

        .ARREADY_M1    (master_if[1].arready),
        .RVALID_M1     (master_if[1].rvalid),
        .RLAST_M1      (master_if[1].rlast),
        .RRESP_M1      (master_if[1].rresp),
        .RDATA_M1      (master_if[1].rdata),

        // Slave command paths
        .ARADDR_S0     (slave_if[0].araddr),
        .ARLEN_S0      (slave_if[0].arlen),
        .ARSIZE_S0     (slave_if[0].arsize),
        .ARBURST_S0    (slave_if[0].arburst),
        .ARVALID_S0    (slave_if[0].arvalid),
        .RREADY_S0     (slave_if[0].rready),

        .ARADDR_S1     (slave_if[1].araddr),
        .ARLEN_S1      (slave_if[1].arlen),
        .ARSIZE_S1     (slave_if[1].arsize),
        .ARBURST_S1    (slave_if[1].arburst),
        .ARVALID_S1    (slave_if[1].arvalid),
        .RREADY_S1     (slave_if[1].rready)
    );

    // -------------------------------------------------------------------------
    // Clock & Reset
    // -------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 1'b0;
        repeat (5) @(posedge clk);
        reset_n = 1'b1;
    end

    // -------------------------------------------------------------------------
    // Environment & Test control
    // -------------------------------------------------------------------------
    axi_env env;

    initial begin
        env = new("axi_env");

        for (int m = 0; m < NUM_MASTERS; m++) begin
            env.add_master(m, master_if[m], master_if[m]);
        end

        for (int s = 0; s < NUM_SLAVES; s++) begin
            axi_slave_cfg_t cfg;
            cfg.addr_lo    = SLAVE_ADDR_LO[s];
            cfg.addr_hi    = SLAVE_ADDR_HI[s];
            cfg.pattern_id = s;
            env.add_slave(s, slave_if[s], cfg);
        end

        env.start();

        string test_name;
        if (!$value$plusargs("TEST=%s", test_name)) begin
            test_name = "test_case1";
        end

        axi_test_base test = create_test(test_name);
        if (test == null) begin
            $fatal(1, "[AXI_Interconnect_tb] Unknown TEST=%s", test_name);
        end

        test.set_env(env);
        $display("[AXI_Interconnect_tb] Starting test %s", test_name);
        test.run();

        #200;
        env.get_scoreboard().report();
        env.stop();
        #50;
        $finish;
    end

    // -------------------------------------------------------------------------
    // Simple factory for tests
    // -------------------------------------------------------------------------
    function axi_test_base create_test(string test_name);
        axi_test_base test;
        if (test_name == "test_case1") begin
            axi_test_case1 t = new();
            test = t;
        end else if (test_name == "test_case2") begin
            axi_test_case2 t = new();
            test = t;
        end else if (test_name == "test_case3") begin
            axi_test_case3 t = new();
            test = t;
        end else if (test_name == "test_case4") begin
            axi_test_case4 t = new();
            test = t;
        end else if (test_name == "test_case5") begin
            axi_test_case5 t = new();
            test = t;
        end else begin
            test = null;
        end
        return test;
    endfunction

endmodule

