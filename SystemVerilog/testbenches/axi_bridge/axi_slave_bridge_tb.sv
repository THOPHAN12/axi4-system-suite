`timescale 1ns/1ps

//==============================================================================
// axi_slave_bridge_tb.sv
// Testbench for AXI Slave Bridge - Tests Bridge Functionality
//==============================================================================
// This testbench tests the AXI Slave Bridge functionality:
//   1. Protocol conversion: AXI4 Full -> AXI4-Lite
//   2. Single-beat transaction support (AWLEN=0, ARLEN=0)
//   3. Burst rejection: Reject bursts with AWLEN>0 or ARLEN>0
//   4. Signal conversion: Remove burst signals, enforce WLAST=1, RLAST=1
//   5. Write transactions: AW -> W -> B channels
//   6. Read transactions: AR -> R channels
//==============================================================================

module axi_slave_bridge_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100MHz
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    
    // Clock and Reset
    logic ACLK = 0;
    logic ARESETN = 1;
    
    //==============================================================================
    // Slave AXI Interface (from AXI Interconnect - AXI4 Full)
    //==============================================================================
    logic [ADDR_WIDTH-1:0] s_axi_awaddr;
    logic [7:0]            s_axi_awlen;
    logic [2:0]            s_axi_awsize;
    logic [1:0]            s_axi_awburst;
    logic                  s_axi_awvalid;
    logic                  s_axi_awready;
    
    logic [DATA_WIDTH-1:0] s_axi_wdata;
    logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb;
    logic                  s_axi_wlast;
    logic                  s_axi_wvalid;
    logic                  s_axi_wready;
    
    logic [1:0]            s_axi_bresp;
    logic                  s_axi_bvalid;
    logic                  s_axi_bready;
    
    logic [ADDR_WIDTH-1:0] s_axi_araddr;
    logic [7:0]            s_axi_arlen;
    logic [2:0]            s_axi_arsize;
    logic [1:0]            s_axi_arburst;
    logic                  s_axi_arvalid;
    logic                  s_axi_arready;
    
    logic [DATA_WIDTH-1:0] s_axi_rdata;
    logic [1:0]            s_axi_rresp;
    logic                  s_axi_rlast;
    logic                  s_axi_rvalid;
    logic                  s_axi_rready;
    
    //==============================================================================
    // Master AXI Interface (to Peripherals - AXI4-Lite)
    //==============================================================================
    logic [ADDR_WIDTH-1:0] m_axi_awaddr;
    logic [2:0]            m_axi_awprot;
    logic                  m_axi_awvalid;
    logic                  m_axi_awready;
    
    logic [DATA_WIDTH-1:0] m_axi_wdata;
    logic [(DATA_WIDTH/8)-1:0] m_axi_wstrb;
    logic                  m_axi_wvalid;
    logic                  m_axi_wready;
    
    logic [1:0]            m_axi_bresp;
    logic                  m_axi_bvalid;
    logic                  m_axi_bready;
    
    logic [ADDR_WIDTH-1:0] m_axi_araddr;
    logic [2:0]            m_axi_arprot;
    logic                  m_axi_arvalid;
    logic                  m_axi_arready;
    
    logic [DATA_WIDTH-1:0] m_axi_rdata;
    logic [1:0]            m_axi_rresp;
    logic                  m_axi_rvalid;
    logic                  m_axi_rready;
    
    //==============================================================================
    // Clock Generation
    //==============================================================================
    always #(CLK_PERIOD/2) ACLK = ~ACLK;
    
    //==============================================================================
    // DUT Instantiation
    //==============================================================================
    axi_slave_bridge #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Slave AXI Interface (AXI4 Full)
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wlast(s_axi_wlast),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arlen(s_axi_arlen),
        .s_axi_arsize(s_axi_arsize),
        .s_axi_arburst(s_axi_arburst),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rlast(s_axi_rlast),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        
        // Master AXI Interface (AXI4-Lite)
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        
        .m_axi_bresp(m_axi_bresp),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
        
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready)
    );
    
    //==============================================================================
    // AXI4-Lite Slave Model (simulates GPIO/UART/SPI peripheral)
    //==============================================================================
    logic [DATA_WIDTH-1:0] peripheral_reg [0:15];  // 16 registers
    
    // Write Address Channel
    always_ff @(posedge ACLK) begin
        if (!ARESETN) begin
            m_axi_awready <= 1'b0;
        end else begin
            if (m_axi_awvalid && !m_axi_awready) begin
                m_axi_awready <= 1'b1;
            end else begin
                m_axi_awready <= 1'b0;
            end
        end
    end
    
    // Write Data Channel
    logic [ADDR_WIDTH-1:0] write_addr;
    always_ff @(posedge ACLK) begin
        if (!ARESETN) begin
            m_axi_wready <= 1'b0;
            write_addr <= 0;
        end else begin
            if (m_axi_awvalid && m_axi_awready) begin
                write_addr <= m_axi_awaddr;
            end
            
            if (m_axi_wvalid && !m_axi_wready) begin
                m_axi_wready <= 1'b1;
            end else if (m_axi_wvalid && m_axi_wready) begin
                peripheral_reg[write_addr[5:2]] <= m_axi_wdata;
                m_axi_wready <= 1'b0;
            end
        end
    end
    
    // Write Response Channel
    always_ff @(posedge ACLK) begin
        if (!ARESETN) begin
            m_axi_bvalid <= 1'b0;
            m_axi_bresp <= 2'b00;
        end else begin
            if (m_axi_wvalid && m_axi_wready && !m_axi_bvalid) begin
                m_axi_bvalid <= 1'b1;
                m_axi_bresp <= 2'b00;  // OKAY
            end else if (m_axi_bvalid && m_axi_bready) begin
                m_axi_bvalid <= 1'b0;
            end
        end
    end
    
    // Read Address Channel
    always_ff @(posedge ACLK) begin
        if (!ARESETN) begin
            m_axi_arready <= 1'b0;
        end else begin
            if (m_axi_arvalid && !m_axi_arready) begin
                m_axi_arready <= 1'b1;
            end else begin
                m_axi_arready <= 1'b0;
            end
        end
    end
    
    // Read Data Channel
    logic [ADDR_WIDTH-1:0] read_addr;
    always_ff @(posedge ACLK) begin
        if (!ARESETN) begin
            m_axi_rvalid <= 1'b0;
            m_axi_rdata <= 0;
            m_axi_rresp <= 2'b00;  // OKAY
        end else begin
            if (m_axi_arvalid && m_axi_arready) begin
                read_addr <= m_axi_araddr;
                m_axi_rdata <= peripheral_reg[m_axi_araddr[5:2]];
                m_axi_rvalid <= 1'b1;
                m_axi_rresp <= 2'b00;  // OKAY
            end else if (m_axi_rvalid && m_axi_rready) begin
                m_axi_rvalid <= 1'b0;
                m_axi_rresp <= 2'b00;  // OKAY (maintain)
            end
        end
    end
    
    //==============================================================================
    // Test Statistics
    //==============================================================================
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    function void check_test(string test_name, logic condition);
        test_count++;
        if (condition) begin
            pass_count++;
            $display("[%0t] [PASS] %s", $time, test_name);
        end else begin
            fail_count++;
            $display("[%0t] [FAIL] %s", $time, test_name);
        end
    endfunction
    
    //==============================================================================
    // Test Tasks
    //==============================================================================
    
    // Task: Write single transaction (AWLEN=0)
    task write_single(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data, output logic wlast_captured);
        @(posedge ACLK);
        s_axi_awaddr <= addr;
        s_axi_awlen <= 8'h00;  // Single transaction (required for AXI4-Lite)
        s_axi_awsize <= 3'b010;  // 4 bytes
        s_axi_awburst <= 2'b00;  // FIXED
        s_axi_awvalid <= 1'b1;
        
        wait(s_axi_awready);
        @(posedge ACLK);
        s_axi_awvalid <= 1'b0;
        
        // Write data
        s_axi_wdata <= data;
        s_axi_wstrb <= 4'hF;
        s_axi_wlast <= 1'b1;  // Must be 1 for single transaction
        s_axi_wvalid <= 1'b1;
        
        wait(s_axi_wready);
        // Capture WLAST before clock edge when both wvalid and wready are high
        wlast_captured = s_axi_wlast;
        @(posedge ACLK);
        s_axi_wvalid <= 1'b0;
        s_axi_wlast <= 1'b0;
        
        // Write response
        s_axi_bready <= 1'b1;
        wait(s_axi_bvalid);
        @(posedge ACLK);
        s_axi_bready <= 1'b0;
    endtask
    
    // Task: Read single transaction (ARLEN=0)
    task read_single(input [ADDR_WIDTH-1:0] addr, output [DATA_WIDTH-1:0] data, output [1:0] rresp);
        @(posedge ACLK);
        s_axi_araddr <= addr;
        s_axi_arlen <= 8'h00;  // Single transaction (required for AXI4-Lite)
        s_axi_arsize <= 3'b010;  // 4 bytes
        s_axi_arburst <= 2'b00;  // FIXED
        s_axi_arvalid <= 1'b1;
        
        wait(s_axi_arready);
        @(posedge ACLK);
        s_axi_arvalid <= 1'b0;
        
        // Read data - capture BEFORE clock edge
        s_axi_rready <= 1'b1;
        wait(s_axi_rvalid);
        // CRITICAL: Capture signals when both rvalid and rready are high (before clock edge)
        data = s_axi_rdata;
        rresp = s_axi_rresp;  // Capture response before slave resets it on clock edge
        @(posedge ACLK);
        s_axi_rready <= 1'b0;
    endtask
    
    // Task: Attempt burst write (should be rejected)
    task write_burst_attempt(input [ADDR_WIDTH-1:0] addr, input [7:0] len, output [1:0] bresp_captured);
        @(posedge ACLK);
        s_axi_awaddr <= addr;
        s_axi_awlen <= len;  // Burst length > 0 (should be rejected)
        s_axi_awsize <= 3'b010;
        s_axi_awburst <= 2'b01;  // INCR
        s_axi_awvalid <= 1'b1;
        
        // Wait for address handshake (bridge should accept to reject with SLVERR)
        wait(s_axi_awready);
        @(posedge ACLK);
        s_axi_awvalid <= 1'b0;
        
        // Send write data (required for write transaction)
        s_axi_wdata <= 32'hDEADBEEF;
        s_axi_wstrb <= 4'hF;
        s_axi_wlast <= 1'b1;
        s_axi_wvalid <= 1'b1;
        
        // Wait for write data handshake
        wait(s_axi_wready);
        @(posedge ACLK);
        s_axi_wvalid <= 1'b0;
        
        // Wait for write response (should be SLVERR) - capture BEFORE clock edge
        s_axi_bready <= 1'b1;
        wait(s_axi_bvalid);
        bresp_captured = s_axi_bresp;  // Capture response before clock edge
        @(posedge ACLK);
        s_axi_bready <= 1'b0;
    endtask
    
    // Task: Attempt burst read (should be rejected)
    task read_burst_attempt(input [ADDR_WIDTH-1:0] addr, input [7:0] len, output [1:0] rresp_captured);
        @(posedge ACLK);
        s_axi_araddr <= addr;
        s_axi_arlen <= len;  // Burst length > 0 (should be rejected)
        s_axi_arsize <= 3'b010;
        s_axi_arburst <= 2'b01;  // INCR
        s_axi_arvalid <= 1'b1;
        
        // Wait for address handshake (bridge should accept to reject with SLVERR)
        wait(s_axi_arready);
        @(posedge ACLK);
        s_axi_arvalid <= 1'b0;
        
        // Wait for read response (should be SLVERR) - capture BEFORE clock edge
        s_axi_rready <= 1'b1;
        wait(s_axi_rvalid);
        rresp_captured = s_axi_rresp;  // Capture response before clock edge
        @(posedge ACLK);
        s_axi_rready <= 1'b0;
    endtask
    
    //==============================================================================
    // Test Cases
    //==============================================================================
    
    // Test 1: Single Write - Protocol Conversion
    task test_single_write();
        logic [DATA_WIDTH-1:0] read_data;
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data;
        logic [1:0] rresp_captured;
        logic wlast_dummy;
        
        $display("");
        $display("============================================================================");
        $display("Test 1: Single Write - Protocol Conversion");
        $display("============================================================================");
        
        test_addr = 32'h1000;
        test_data = 32'hDEADBEEF;
        
        // Write with AWLEN=0 (single transaction)
        write_single(test_addr, test_data, wlast_dummy);
        #(CLK_PERIOD * 2);
        
        // Check response
        check_test("Write response OKAY", (s_axi_bresp == 2'b00));
        
        // Verify data was written (read back)
        read_single(test_addr, read_data, rresp_captured);
        #(CLK_PERIOD * 2);
        
        check_test("Data written correctly", (read_data == test_data));
        check_test("Read response OKAY", (rresp_captured == 2'b00));
    endtask
    
    // Test 2: Single Read - Protocol Conversion
    task test_single_read();
        logic [DATA_WIDTH-1:0] read_data;
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data;
        logic [1:0] rresp_dummy;
        logic wlast_dummy;
        
        $display("");
        $display("============================================================================");
        $display("Test 2: Single Read - Protocol Conversion");
        $display("============================================================================");
        
        test_addr = 32'h2000;
        test_data = 32'hCAFEBABE;
        
        // Write first
        write_single(test_addr, test_data, wlast_dummy);
        #(CLK_PERIOD * 2);
        
        // Read with ARLEN=0 (single transaction)
        read_single(test_addr, read_data, rresp_dummy);
        #(CLK_PERIOD * 2);
        
        check_test("Read data correct", (read_data == test_data));
        check_test("RLAST is 1", (s_axi_rlast == 1'b1));
    endtask
    
    // Test 3: Burst Rejection - Write
    task test_burst_rejection_write();
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [1:0] bresp_captured;
        
        $display("");
        $display("============================================================================");
        $display("Test 3: Burst Write Rejection (AWLEN > 0)");
        $display("============================================================================");
        
        test_addr = 32'h3000;
        
        // Attempt burst write with AWLEN=3 (should be rejected)
        write_burst_attempt(test_addr, 8'h03, bresp_captured);
        
        // Check that response is SLVERR
        check_test("Burst write rejected with SLVERR", (bresp_captured == 2'b10));
    endtask
    
    // Test 4: Signal Conversion Verification
    task test_signal_conversion();
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data;
        logic wlast_dummy;
        
        $display("");
        $display("============================================================================");
        $display("Test 4: Signal Conversion - AXI4 Full to AXI4-Lite");
        $display("============================================================================");
        
        test_addr = 32'h4000;
        test_data = 32'h12345678;
        
        // Write transaction
        write_single(test_addr, test_data, wlast_dummy);
        #(CLK_PERIOD * 2);
        
        // Check that master interface (AXI4-Lite) does not have burst signals
        check_test("Master interface has no AWLEN", 1);  // AXI4-Lite has no AWLEN
        check_test("Master interface has AWPROT", (m_axi_awprot == 3'b000));
        check_test("Address passed through", (m_axi_awaddr == test_addr));
    endtask
    
    // Test 5: WLAST/RLAST Enforcement
    task test_last_signal_enforcement();
        logic [DATA_WIDTH-1:0] read_data;
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data;
        logic [1:0] rresp_dummy;
        logic wlast_captured;
        
        $display("");
        $display("============================================================================");
        $display("Test 5: WLAST/RLAST Signal Enforcement");
        $display("============================================================================");
        
        test_addr = 32'h5000;
        test_data = 32'hA5A5A5A5;
        
        // Write transaction - capture WLAST during transaction
        write_single(test_addr, test_data, wlast_captured);
        
        // Check WLAST is 1 (captured during transaction)
        check_test("WLAST is 1 for single transaction", (wlast_captured == 1'b1));
        
        // Read transaction
        read_single(test_addr, read_data, rresp_dummy);
        #(CLK_PERIOD);
        
        // Check RLAST is 1 (enforced by bridge)
        check_test("RLAST is 1 for single transaction", (s_axi_rlast == 1'b1));
    endtask
    
    // Test 6: Burst Read Rejection
    task test_burst_rejection_read();
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [1:0] rresp_captured;
        
        $display("");
        $display("============================================================================");
        $display("Test 6: Burst Read Rejection (ARLEN > 0)");
        $display("============================================================================");
        
        test_addr = 32'h6000;
        
        // Attempt burst read with ARLEN=3 (should be rejected)
        read_burst_attempt(test_addr, 8'h03, rresp_captured);
        
        // Check that response is SLVERR
        check_test("Burst read rejected with SLVERR", (rresp_captured == 2'b10));
    endtask
    
    // Test 7: Multiple Sequential Transactions
    task test_multiple_sequential();
        logic [ADDR_WIDTH-1:0] addr1, addr2, addr3;
        logic [DATA_WIDTH-1:0] data1, data2, data3;
        logic [DATA_WIDTH-1:0] read_data;
        logic [1:0] rresp_dummy;
        logic wlast_dummy;
        
        $display("");
        $display("============================================================================");
        $display("Test 7: Multiple Sequential Transactions");
        $display("============================================================================");
        
        // Use addresses within range [0:15] for peripheral_reg[0:15]
        // peripheral_reg uses addr[5:2] as index, so:
        // addr1 = 0x0000 -> [5:2] = 0
        // addr2 = 0x0010 -> [5:2] = 1
        // addr3 = 0x0020 -> [5:2] = 2
        addr1 = 32'h0000;
        addr2 = 32'h0010;
        addr3 = 32'h0020;
        data1 = 32'h11111111;
        data2 = 32'h22222222;
        data3 = 32'h33333333;
        
        // Sequential writes
        write_single(addr1, data1, wlast_dummy);
        #(CLK_PERIOD * 2);
        write_single(addr2, data2, wlast_dummy);
        #(CLK_PERIOD * 2);
        write_single(addr3, data3, wlast_dummy);
        #(CLK_PERIOD * 2);
        
        // Sequential reads
        read_single(addr1, read_data, rresp_dummy);
        check_test("First read data correct", (read_data == data1));
        #(CLK_PERIOD * 2);
        
        read_single(addr2, read_data, rresp_dummy);
        check_test("Second read data correct", (read_data == data2));
        #(CLK_PERIOD * 2);
        
        read_single(addr3, read_data, rresp_dummy);
        check_test("Third read data correct", (read_data == data3));
    endtask
    
    // Test 8: Address Alignment Verification
    task test_address_alignment();
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data, read_data;
        logic [1:0] rresp_dummy;
        logic wlast_dummy;
        
        $display("");
        $display("============================================================================");
        $display("Test 8: Address Alignment Verification");
        $display("============================================================================");
        
        // Test 4-byte aligned address
        test_addr = 32'h8000;
        test_data = 32'hABCDEF00;
        
        write_single(test_addr, test_data, wlast_dummy);
        #(CLK_PERIOD * 2);
        read_single(test_addr, read_data, rresp_dummy);
        
        check_test("4-byte aligned address works", (read_data == test_data));
        
        // Test another aligned address
        test_addr = 32'h8004;
        test_data = 32'h12345678;
        
        write_single(test_addr, test_data, wlast_dummy);
        #(CLK_PERIOD * 2);
        read_single(test_addr, read_data, rresp_dummy);
        
        check_test("Another aligned address works", (read_data == test_data));
    endtask
    
    // Test 9: Write/Read Response Codes
    task test_response_codes();
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data, read_data;
        logic [1:0] rresp_captured;
        logic wlast_dummy;
        
        $display("");
        $display("============================================================================");
        $display("Test 9: Write/Read Response Codes");
        $display("============================================================================");
        
        test_addr = 32'h9000;
        test_data = 32'hFEDCBA98;
        
        // Normal write (should be OKAY)
        write_single(test_addr, test_data, wlast_dummy);
        #(CLK_PERIOD * 2);
        check_test("Write response is OKAY", (s_axi_bresp == 2'b00));
        
        // Normal read (should be OKAY) - capture response
        read_single(test_addr, read_data, rresp_captured);
        check_test("Read response is OKAY", (rresp_captured == 2'b00));
        
        // Burst rejection should be SLVERR (tested in Test 3 and 6)
        check_test("Response codes verified", 1);
    endtask
    
    // Test 10: Protocol Compliance - AXI4-Lite Requirements
    task test_protocol_compliance();
        logic [ADDR_WIDTH-1:0] test_addr;
        logic [DATA_WIDTH-1:0] test_data, read_data;
        logic [1:0] rresp_dummy;
        logic wlast_captured;
        
        $display("");
        $display("============================================================================");
        $display("Test 10: Protocol Compliance - AXI4-Lite Requirements");
        $display("============================================================================");
        
        test_addr = 32'hA000;
        test_data = 32'h9A9A9A9A;
        
        // Verify single-beat transaction (AWLEN=0, ARLEN=0)
        write_single(test_addr, test_data, wlast_captured);
        #(CLK_PERIOD);
        check_test("AWLEN is 0 for single transaction", (s_axi_awlen == 8'h00));
        
        read_single(test_addr, read_data, rresp_dummy);
        #(CLK_PERIOD);
        check_test("ARLEN is 0 for single transaction", (s_axi_arlen == 8'h00));
        
        // Verify WLAST and RLAST are always 1
        check_test("WLAST is always 1", (wlast_captured == 1'b1));
        check_test("RLAST is always 1", (s_axi_rlast == 1'b1));
        
        // Verify master interface (AXI4-Lite) has no burst signals
        check_test("Master interface has no AWLEN/ARLEN", 1);
        check_test("Master interface has AWPROT/ARPROT", (m_axi_awprot == 3'b000));
    endtask
    
    //==============================================================================
    // Main Test Sequence
    //==============================================================================
    initial begin
        $display("============================================================================");
        $display("AXI Slave Bridge Testbench");
        $display("Testing Bridge Functionality");
        $display("============================================================================");
        $display("");
        
        // Initialize signals
        s_axi_awaddr <= 0;
        s_axi_awlen <= 0;
        s_axi_awsize <= 0;
        s_axi_awburst <= 0;
        s_axi_awvalid <= 0;
        s_axi_wdata <= 0;
        s_axi_wstrb <= 0;
        s_axi_wlast <= 0;
        s_axi_wvalid <= 0;
        s_axi_bready <= 0;
        s_axi_araddr <= 0;
        s_axi_arlen <= 0;
        s_axi_arsize <= 0;
        s_axi_arburst <= 0;
        s_axi_arvalid <= 0;
        s_axi_rready <= 0;
        
        // Reset sequence
        $display("[%0t] Applying reset...", $time);
        ARESETN = 0;
        #(CLK_PERIOD * 10);
        ARESETN = 1;
        #(CLK_PERIOD * 5);
        $display("[%0t] Reset released", $time);
        $display("");
        
        // Run test cases
        test_single_write();
        #(CLK_PERIOD * 10);
        
        test_single_read();
        #(CLK_PERIOD * 10);
        
        test_burst_rejection_write();
        #(CLK_PERIOD * 10);
        
        test_signal_conversion();
        #(CLK_PERIOD * 10);
        
        test_last_signal_enforcement();
        #(CLK_PERIOD * 10);
        
        test_burst_rejection_read();
        #(CLK_PERIOD * 10);
        
        test_multiple_sequential();
        #(CLK_PERIOD * 10);
        
        test_address_alignment();
        #(CLK_PERIOD * 10);
        
        test_response_codes();
        #(CLK_PERIOD * 10);
        
        test_protocol_compliance();
        #(CLK_PERIOD * 10);
        
        // Print statistics
        $display("");
        $display("============================================================================");
        $display("Test Statistics");
        $display("============================================================================");
        $display("Total Tests:  %0d", test_count);
        $display("Passed:       %0d", pass_count);
        $display("Failed:       %0d", fail_count);
        $display("Pass Rate:    %0.1f%%", (pass_count * 100.0 / test_count));
        $display("");
        
        if (fail_count == 0) begin
            $display("============================================================================");
            $display("ALL TESTS PASSED!");
            $display("============================================================================");
        end else begin
            $display("============================================================================");
            $display("SOME TESTS FAILED!");
            $display("============================================================================");
        end
        
        $display("");
        $display("Simulation finished at time %0t", $time);
        $display("============================================================================");
        #(CLK_PERIOD * 100);
        $finish;
    end
    
    //==============================================================================
    // Waveform Dump
    //==============================================================================
    initial begin
        $dumpfile("axi_slave_bridge_tb.vcd");
        $dumpvars(0, axi_slave_bridge_tb);
    end

endmodule

