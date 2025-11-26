`timescale 1ns/1ps
`default_nettype none

module serv_core_tb;

    // -------------------------------------------------------------------------
    // Configuration
    // -------------------------------------------------------------------------
    parameter MEM_WORDS      = 4096;
    parameter MEM_INIT_HEX   = "D:/AXI/src/cores/serv/sw/hello_uart.hex";
    parameter RESET_CYCLES   = 10;
    parameter MAX_CYCLES     = 200000;
    parameter LOG_LEVEL      = 2;  // 0=none, 1=summary, 2=detailed, 3=verbose

    localparam MEM_ADDR_BITS = $clog2(MEM_WORDS);

    // -------------------------------------------------------------------------
    // Clock / Reset
    // -------------------------------------------------------------------------
    reg clk = 1'b0;
    always #5 clk = ~clk;  // 100 MHz

    reg rst = 1'b1;
    integer reset_count;
    initial begin
        $display("============================================================================");
        $display("[SERV_TB] Starting SERV Core Testbench");
        $display("============================================================================");
        $display("[SERV_TB] Configuration:");
        $display("  - Memory Size: %0d words (%0d KB)", MEM_WORDS, MEM_WORDS*4/1024);
        $display("  - Reset Cycles: %0d", RESET_CYCLES);
        $display("  - Max Cycles: %0d", MAX_CYCLES);
        $display("  - Log Level: %0d", LOG_LEVEL);
        $display("============================================================================");
        $display("[SERV_TB] Reset sequence starting...");
        reset_count = 0;
        while (reset_count < RESET_CYCLES) begin
            @(posedge clk);
            reset_count = reset_count + 1;
            if (LOG_LEVEL >= 3) begin
                $display("[SERV_TB] Reset cycle %0d/%0d", reset_count, RESET_CYCLES);
            end
        end
        rst = 1'b0;
        $display("[SERV_TB] Reset released at time %0t", $time);
        $display("[SERV_TB] Starting execution...");
        $display("============================================================================");
    end

    // -------------------------------------------------------------------------
    // Simple instruction/data memory shared between ibus and dbus
    // -------------------------------------------------------------------------
    reg [31:0] mem [0:MEM_WORDS-1];
    reg [1023:0] firmware_override;
    integer idx;

    integer mem_words_loaded;
    initial begin
        $display("[SERV_TB] Initializing memory with NOP instructions...");
        for (idx = 0; idx < MEM_WORDS; idx = idx + 1) begin
            mem[idx] = 32'h0000_0013; // RISC-V NOP
        end
        mem_words_loaded = 0;

        if (MEM_INIT_HEX != "") begin
            $display("[SERV_TB] Loading default firmware from %0s", MEM_INIT_HEX);
            $readmemh(MEM_INIT_HEX, mem);
            // Count non-NOP words loaded
            for (idx = 0; idx < MEM_WORDS; idx = idx + 1) begin
                if (mem[idx] != 32'h0000_0013) begin
                    mem_words_loaded = mem_words_loaded + 1;
                end
            end
            $display("[SERV_TB] Loaded %0d non-NOP words from firmware", mem_words_loaded);
        end

        if ($value$plusargs("firmware=%s", firmware_override)) begin
            $display("[SERV_TB] Overriding firmware with %0s", firmware_override);
            $readmemh(firmware_override, mem);
            mem_words_loaded = 0;
            for (idx = 0; idx < MEM_WORDS; idx = idx + 1) begin
                if (mem[idx] != 32'h0000_0013) begin
                    mem_words_loaded = mem_words_loaded + 1;
                end
            end
            $display("[SERV_TB] Loaded %0d non-NOP words from override firmware", mem_words_loaded);
        end
        
        if (LOG_LEVEL >= 2 && mem_words_loaded > 0) begin
            $display("[SERV_TB] First few instructions loaded:");
            for (idx = 0; idx < 16 && idx < MEM_WORDS; idx = idx + 1) begin
                if (mem[idx] != 32'h0000_0013) begin
                    $display("  [%04x] 0x%08x", idx*4, mem[idx]);
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // DUT instance (SERV core + RF wrapper)
    // -------------------------------------------------------------------------
    wire [31:0] ibus_adr;
    wire        ibus_cyc;
    wire [31:0] dbus_adr;
    wire [31:0] dbus_dat;
    wire [3:0]  dbus_sel;
    wire        dbus_we;
    wire        dbus_cyc;
    wire [2:0]  ext_funct3;
    wire [31:0] ext_rs1;
    wire [31:0] ext_rs2;
    wire        mdu_valid;
    wire        cnt_done;

    reg  [31:0] ibus_rdt;
    reg         ibus_ack;
    reg  [31:0] dbus_rdt;
    reg         dbus_ack;

    serv_rf_top
    #(
        .RESET_PC(32'h0000_0000),
        .WITH_CSR(1),
        .W(1)
    ) dut (
        .clk          (clk),
        .i_rst        (rst),
        .i_timer_irq  (1'b0),
        .o_ibus_adr   (ibus_adr),
        .o_ibus_cyc   (ibus_cyc),
        .i_ibus_rdt   (ibus_rdt),
        .i_ibus_ack   (ibus_ack),
        .o_dbus_adr   (dbus_adr),
        .o_dbus_dat   (dbus_dat),
        .o_dbus_sel   (dbus_sel),
        .o_dbus_we    (dbus_we),
        .o_dbus_cyc   (dbus_cyc),
        .i_dbus_rdt   (dbus_rdt),
        .i_dbus_ack   (dbus_ack),
        .o_ext_rs1    (ext_rs1),
        .o_ext_rs2    (ext_rs2),
        .o_ext_funct3 (ext_funct3),
        .i_ext_rd     (32'h0),
        .i_ext_ready  (1'b1),
        .o_mdu_valid  (mdu_valid),
        .o_cnt_done   (cnt_done)
    );

    // -------------------------------------------------------------------------
    // Instruction bus model (single-cycle response)
    // -------------------------------------------------------------------------
    reg [31:0] prev_ibus_adr;
    integer ibus_fetch_count;
    initial begin
        prev_ibus_adr = 32'h0;
        ibus_fetch_count = 0;
    end
    
    always @(posedge clk) begin
        if (rst) begin
            ibus_ack <= 1'b0;
            ibus_rdt <= 32'h0;
            prev_ibus_adr <= 32'h0;
        end else begin
            ibus_ack <= 1'b0;
            if (ibus_cyc) begin
                ibus_rdt <= mem[ibus_adr[MEM_ADDR_BITS+1:2]];
                ibus_ack <= 1'b1;
                ibus_fetch_count = ibus_fetch_count + 1;
                
                if (LOG_LEVEL >= 2) begin
                    $display("[SERV_TB] [CYCLE %0d] IFETCH: PC=0x%08x, INST=0x%08x", 
                             cycle_ctr, ibus_adr, mem[ibus_adr[MEM_ADDR_BITS+1:2]]);
                end else if (LOG_LEVEL >= 1 && ibus_adr != prev_ibus_adr) begin
                    $display("[SERV_TB] [CYCLE %0d] PC change: 0x%08x -> 0x%08x", 
                             cycle_ctr, prev_ibus_adr, ibus_adr);
                end
                prev_ibus_adr <= ibus_adr;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Data bus model (read/write with byte enables)
    // -------------------------------------------------------------------------
    reg [31:0] write_data;
    integer dbus_read_count, dbus_write_count;
    initial begin
        dbus_read_count = 0;
        dbus_write_count = 0;
    end
    
    always @(posedge clk) begin
        if (rst) begin
            dbus_ack  <= 1'b0;
            dbus_rdt  <= 32'h0;
        end else begin
            dbus_ack <= 1'b0;
            if (dbus_cyc) begin
                dbus_ack <= 1'b1;
                if (dbus_we) begin
                    // Write operation
                    write_data = mem[dbus_adr[MEM_ADDR_BITS+1:2]];
                    if (dbus_sel[0])
                        write_data[7:0]   = dbus_dat[7:0];
                    if (dbus_sel[1])
                        write_data[15:8]  = dbus_dat[15:8];
                    if (dbus_sel[2])
                        write_data[23:16] = dbus_dat[23:16];
                    if (dbus_sel[3])
                        write_data[31:24] = dbus_dat[31:24];
                    mem[dbus_adr[MEM_ADDR_BITS+1:2]] <= write_data;
                    dbus_write_count = dbus_write_count + 1;
                    
                    if (LOG_LEVEL >= 2) begin
                        $display("[SERV_TB] [CYCLE %0d] MEM_WRITE: addr=0x%08x, data=0x%08x, sel=%b, old=0x%08x, new=0x%08x",
                                 cycle_ctr, dbus_adr, dbus_dat, dbus_sel, 
                                 mem[dbus_adr[MEM_ADDR_BITS+1:2]], write_data);
                    end else if (LOG_LEVEL >= 1) begin
                        $display("[SERV_TB] [CYCLE %0d] MEM_WRITE: addr=0x%08x, data=0x%08x, sel=%b",
                                 cycle_ctr, dbus_adr, dbus_dat, dbus_sel);
                    end
                end else begin
                    // Read operation
                    dbus_rdt <= mem[dbus_adr[MEM_ADDR_BITS+1:2]];
                    dbus_read_count = dbus_read_count + 1;
                    
                    if (LOG_LEVEL >= 2) begin
                        $display("[SERV_TB] [CYCLE %0d] MEM_READ:  addr=0x%08x, data=0x%08x",
                                 cycle_ctr, dbus_adr, mem[dbus_adr[MEM_ADDR_BITS+1:2]]);
                    end
                end
            end
        end
    end

    // -------------------------------------------------------------------------
    // Simulation control / monitors
    // -------------------------------------------------------------------------
    integer cycle_ctr;
    integer last_summary_cycle;
    initial begin
        cycle_ctr = 0;
        last_summary_cycle = 0;
    end
    
    always @(posedge clk) begin
        if (rst) begin
            cycle_ctr <= 0;
            last_summary_cycle <= 0;
        end else begin
            cycle_ctr <= cycle_ctr + 1;
            
            // Periodic summary every 10000 cycles
            if (LOG_LEVEL >= 1 && (cycle_ctr - last_summary_cycle) >= 10000) begin
                $display("============================================================================");
                $display("[SERV_TB] [CYCLE %0d] Progress Summary:", cycle_ctr);
                $display("  - Instruction Fetches: %0d", ibus_fetch_count);
                $display("  - Memory Reads: %0d", dbus_read_count);
                $display("  - Memory Writes: %0d", dbus_write_count);
                $display("  - Current PC: 0x%08x", ibus_adr);
                $display("  - Simulation Time: %0t ns", $time);
                $display("============================================================================");
                last_summary_cycle = cycle_ctr;
            end
            
            if (cycle_ctr >= MAX_CYCLES) begin
                $display("============================================================================");
                $display("[SERV_TB] Reached MAX_CYCLES (%0d). Ending simulation.", MAX_CYCLES);
                $display("============================================================================");
                $finish;
            end
        end
    end
    
    // Final summary on finish
    initial begin
        $monitoroff;
        wait(cycle_ctr >= MAX_CYCLES || $time > 2000000);
        #100;
        $display("============================================================================");
        $display("[SERV_TB] SIMULATION SUMMARY");
        $display("============================================================================");
        $display("Total Cycles Executed: %0d", cycle_ctr);
        $display("Total Simulation Time: %0t ns (%0.3f us)", $time, $time/1000.0);
        $display("Instruction Fetches: %0d", ibus_fetch_count);
        $display("Memory Reads: %0d", dbus_read_count);
        $display("Memory Writes: %0d", dbus_write_count);
        $display("Final PC: 0x%08x", ibus_adr);
        $display("Firmware Words Loaded: %0d", mem_words_loaded);
        if (ibus_fetch_count > 0) begin
            $display("Average Cycles per Instruction: %0.2f", 
                     real'(cycle_ctr) / real'(ibus_fetch_count));
        end
        $display("============================================================================");
    end

endmodule

`default_nettype wire

