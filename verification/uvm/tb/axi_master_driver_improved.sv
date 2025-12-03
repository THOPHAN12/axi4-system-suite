//=============================================================================
// Improved AXI Master Driver - SystemVerilog
// Master driver với nhiều test cases
//=============================================================================

`timescale 1ns/1ps

`include "../../src/axi_interconnect/sv/packages/axi_pkg.sv"

module axi_master_driver_improved (
    axi_master_simple_if.master m_if,
    input int unsigned master_id
);
    
    //=========================================================================
    // Task: Single Write Transaction
    //=========================================================================
    task single_write(logic [31:0] addr, logic [31:0] data);
        @(posedge m_if.ACLK);
        m_if.awaddr = addr;
        m_if.awlen = 8'h0;  // 1 beat
        m_if.awsize = 3'h2; // 4 bytes
        m_if.awburst = 2'h1; // INCR
        m_if.awvalid = 1'b1;
        
        wait(m_if.awready);
        @(posedge m_if.ACLK);
        m_if.awvalid = 1'b0;
        
        @(posedge m_if.ACLK);
        m_if.wdata = data;
        m_if.wstrb = 4'hF;
        m_if.wlast = 1'b1;
        m_if.wvalid = 1'b1;
        
        wait(m_if.wready);
        @(posedge m_if.ACLK);
        m_if.wvalid = 1'b0;
        m_if.wlast = 1'b0;
        
        m_if.bready = 1'b1;
        wait(m_if.bvalid);
        @(posedge m_if.ACLK);
        m_if.bready = 1'b0;
        
        $display("[%0t] Master %0d: Write completed - Addr=0x%08x, Data=0x%08x, Resp=%0b", 
                 $time, master_id, addr, data, m_if.bresp);
    endtask
    
    //=========================================================================
    // Task: Burst Write Transaction
    //=========================================================================
    task burst_write(logic [31:0] start_addr, int unsigned len, logic [1:0] burst_type);
        logic [31:0] data_array[];
        data_array = new[len + 1];
        
        // Generate data
        for (int i = 0; i <= len; i++) begin
            data_array[i] = $urandom();
        end
        
        @(posedge m_if.ACLK);
        m_if.awaddr = start_addr;
        m_if.awlen = len;
        m_if.awsize = 3'h2; // 4 bytes
        m_if.awburst = burst_type;
        m_if.awvalid = 1'b1;
        
        wait(m_if.awready);
        @(posedge m_if.ACLK);
        m_if.awvalid = 1'b0;
        
        // Send write data
        for (int i = 0; i <= len; i++) begin
            @(posedge m_if.ACLK);
            m_if.wdata = data_array[i];
            m_if.wstrb = 4'hF;
            m_if.wlast = (i == len);
            m_if.wvalid = 1'b1;
            
            wait(m_if.wready);
            @(posedge m_if.ACLK);
            m_if.wvalid = 1'b0;
        end
        
        // Wait for write response
        m_if.bready = 1'b1;
        wait(m_if.bvalid);
        @(posedge m_if.ACLK);
        m_if.bready = 1'b0;
        
        $display("[%0t] Master %0d: Burst Write completed - Addr=0x%08x, Len=%0d, Burst=%0b, Resp=%0b", 
                 $time, master_id, start_addr, len, burst_type, m_if.bresp);
    endtask
    
    //=========================================================================
    // Task: Single Read Transaction
    //=========================================================================
    task single_read(logic [31:0] addr, output logic [31:0] data);
        @(posedge m_if.ACLK);
        m_if.araddr = addr;
        m_if.arlen = 8'h0;  // 1 beat
        m_if.arsize = 3'h2; // 4 bytes
        m_if.arburst = 2'h1; // INCR
        m_if.arvalid = 1'b1;
        
        wait(m_if.arready);
        @(posedge m_if.ACLK);
        m_if.arvalid = 1'b0;
        
        m_if.rready = 1'b1;
        wait(m_if.rvalid);
        data = m_if.rdata;
        @(posedge m_if.ACLK);
        m_if.rready = 1'b0;
        
        $display("[%0t] Master %0d: Read completed - Addr=0x%08x, Data=0x%08x, Resp=%0b", 
                 $time, master_id, addr, data, m_if.rresp);
    endtask
    
    //=========================================================================
    // Task: Burst Read Transaction
    //=========================================================================
    task burst_read(logic [31:0] start_addr, int unsigned len, logic [1:0] burst_type, 
                    output logic [31:0] data_array[]);
        data_array = new[len + 1];
        
        @(posedge m_if.ACLK);
        m_if.araddr = start_addr;
        m_if.arlen = len;
        m_if.arsize = 3'h2; // 4 bytes
        m_if.arburst = burst_type;
        m_if.arvalid = 1'b1;
        
        wait(m_if.arready);
        @(posedge m_if.ACLK);
        m_if.arvalid = 1'b0;
        
        // Receive read data
        m_if.rready = 1'b1;
        for (int i = 0; i <= len; i++) begin
            wait(m_if.rvalid);
            data_array[i] = m_if.rdata;
            @(posedge m_if.ACLK);
            if (m_if.rlast) begin
                m_if.rready = 1'b0;
                break;
            end
        end
        
        $display("[%0t] Master %0d: Burst Read completed - Addr=0x%08x, Len=%0d, Burst=%0b", 
                 $time, master_id, start_addr, len, burst_type);
    endtask
    
    //=========================================================================
    // Task: Write-Read-Verify Test
    //=========================================================================
    task write_read_verify(logic [31:0] addr, logic [31:0] write_data);
        logic [31:0] read_data;
        
        $display("[%0t] Master %0d: Starting Write-Read-Verify test at 0x%08x", 
                 $time, master_id, addr);
        
        // Write
        single_write(addr, write_data);
        #100;
        
        // Read back
        single_read(addr, read_data);
        
        // Verify
        if (read_data == write_data) begin
            $display("[%0t] Master %0d: VERIFY PASSED - Data matches!", $time, master_id);
        end else begin
            $display("[%0t] Master %0d: VERIFY FAILED - Expected 0x%08x, Got 0x%08x", 
                     $time, master_id, write_data, read_data);
        end
    endtask
    
    //=========================================================================
    // Main Test Sequence
    //=========================================================================
    initial begin
        // Initialize signals
        m_if.awvalid = 1'b0;
        m_if.wvalid = 1'b0;
        m_if.bready = 1'b0;
        m_if.arvalid = 1'b0;
        m_if.rready = 1'b0;
        
        wait(m_if.ARESETN);
        #200;
        
        $display("[%0t] ========== Master %0d Test Suite Started ==========", $time, master_id);
        
        // Test 1: Single write to slave 0
        $display("\n[%0t] Test 1: Single Write to Slave 0", $time);
        single_write(32'h0000_1000, 32'hDEAD_BEEF);
        #100;
        
        // Test 2: Single read from slave 0
        $display("\n[%0t] Test 2: Single Read from Slave 0", $time);
        begin
            logic [31:0] read_data;
            single_read(32'h0000_1000, read_data);
        end
        #100;
        
        // Test 3: Write-Read-Verify
        $display("\n[%0t] Test 3: Write-Read-Verify", $time);
        write_read_verify(32'h0000_2000, 32'hCAFE_BABE);
        #100;
        
        // Test 4: Burst write (INCR, 4 beats)
        $display("\n[%0t] Test 4: Burst Write (INCR, 4 beats)", $time);
        burst_write(32'h0000_3000, 3, 2'b01); // INCR
        #100;
        
        // Test 5: Burst read (INCR, 4 beats)
        $display("\n[%0t] Test 5: Burst Read (INCR, 4 beats)", $time);
        begin
            logic [31:0] read_data[];
            burst_read(32'h0000_3000, 3, 2'b01, read_data);
        end
        #100;
        
        // Test 6: Write to different slave (slave 1)
        $display("\n[%0t] Test 6: Write to Slave 1", $time);
        single_write(32'h4000_1000, 32'h1234_5678);
        #100;
        
        // Test 7: Concurrent transactions (if master_id == 0, start second transaction)
        if (master_id == 0) begin
            $display("\n[%0t] Test 7: Multiple writes to different addresses", $time);
            fork
                single_write(32'h0000_4000, 32'hAAAA_AAAA);
                #50 single_write(32'h0000_5000, 32'hBBBB_BBBB);
            join
            #100;
        end
        
        $display("[%0t] ========== Master %0d Test Suite Completed ==========", $time, master_id);
        #1000;
    end
    
endmodule

