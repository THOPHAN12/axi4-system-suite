`timescale 1ns/1ps

package axi_tb_pkg;

    typedef enum logic [1:0] {
        AXI_RESP_OKAY   = 2'b00,
        AXI_RESP_EXOKAY = 2'b01,
        AXI_RESP_SLVERR = 2'b10,
        AXI_RESP_DECERR = 2'b11
    } axi_resp_e;

    typedef struct packed {
        logic [31:0] addr_lo;
        logic [31:0] addr_hi;
        int          pattern_id;
    } axi_slave_cfg_t;

    // ------------------------------------------------------------
    // Utility functions
    // ------------------------------------------------------------
    function automatic logic [31:0] pattern_value(
        int          pattern_id,
        logic [31:0] base_addr,
        int          beat_idx
    );
        logic [31:0] base_word;
        base_word = base_addr + (beat_idx << 2);
        case (pattern_id)
            0: pattern_value = base_word ^ 32'h0000_0000;
            1: pattern_value = base_word ^ 32'h1ACE_0000;
            default: pattern_value = base_word ^ (32'h55AA_0000 | pattern_id[7:0]);
        endcase
    endfunction

    // ------------------------------------------------------------
    // Transaction & sample classes
    // ------------------------------------------------------------
    class axi_ar_transaction;
        rand logic [31:0] addr;
        rand logic [3:0]  len;
        rand logic [2:0]  size;
        rand logic [1:0]  burst;
        int               master_id;
        int               slave_id;

        constraint c_default {
            burst inside {2'b01}; // INCR
            size  inside {3'b010}; // word
            len  <= 4'd15;
        }

        function new(
            int master_id = 0,
            logic [31:0] addr = 32'h0,
            logic [3:0] len = 4'd0
        );
            this.master_id = master_id;
            this.addr      = addr;
            this.len       = len;
            this.size      = 3'b010;
            this.burst     = 2'b01;
            this.slave_id  = -1;
        endfunction

        function string sprint();
            return $sformatf("AR txn (m=%0d, addr=0x%08h, len=%0d, slave=%0d)",
                             master_id, addr, len, slave_id);
        endfunction
    endclass

    class axi_read_sample;
        int               master_id;
        logic [31:0]      data;
        axi_resp_e        resp;
        bit               last;

        function new(int master_id = 0,
                     logic [31:0] data = 32'h0,
                     axi_resp_e resp = AXI_RESP_OKAY,
                     bit last = 0);
            this.master_id = master_id;
            this.data      = data;
            this.resp      = resp;
            this.last      = last;
        endfunction
    endclass

    typedef struct packed {
        logic [31:0] data;
        axi_resp_e   resp;
        bit          last;
    } axi_expected_beat_t;

    // ------------------------------------------------------------
    // Master driver
    // ------------------------------------------------------------
    class axi_master_driver;
        string name;
        int master_id;
        virtual axi_master_if.drv vif;
        mailbox #(axi_ar_transaction) txn_mbx;

        function new(
            string name,
            int master_id,
            virtual axi_master_if.drv vif,
            mailbox #(axi_ar_transaction) txn_mbx
        );
            this.name      = name;
            this.master_id = master_id;
            this.vif       = vif;
            this.txn_mbx   = txn_mbx;
        endfunction

        task reset_signals();
            vif.cb.araddr  <= '0;
            vif.cb.arlen   <= '0;
            vif.cb.arsize  <= '0;
            vif.cb.arburst <= '0;
            vif.cb.arvalid <= 1'b0;
            vif.cb.rready  <= 1'b0;
        endtask

        task run();
            axi_ar_transaction txn;
            reset_signals();
            wait (vif.reset_n);
            forever begin
                txn_mbx.get(txn);
                if (txn == null) begin
                    reset_signals();
                    break;
                end
                drive_txn(txn);
            end
        endtask

        protected task drive_txn(axi_ar_transaction txn);
            @(vif.cb);
            vif.cb.araddr  <= txn.addr;
            vif.cb.arlen   <= txn.len;
            vif.cb.arsize  <= txn.size;
            vif.cb.arburst <= txn.burst;
            vif.cb.arvalid <= 1'b1;
            vif.cb.rready  <= 1'b1;

            // Address handshake
            wait (vif.cb.arready == 1'b1);
            @(vif.cb);
            vif.cb.arvalid <= 1'b0;

            // Wait for completion of burst
            int beats = txn.len + 1;
            int acked = 0;
            while (acked < beats) begin
                @(vif.cb);
                if (!vif.reset_n) begin
                    acked = 0;
                end else if (vif.cb.rvalid && vif.cb.rready) begin
                    acked++;
                end
            end
        endtask
    endclass

    // ------------------------------------------------------------
    // Master monitor
    // ------------------------------------------------------------
    class axi_master_monitor;
        string name;
        int master_id;
        virtual axi_master_if.mon vif;
        mailbox #(axi_read_sample) sample_mbx;
        bit stop_requested;

        function new(
            string name,
            int master_id,
            virtual axi_master_if.mon vif,
            mailbox #(axi_read_sample) sample_mbx
        );
            this.name       = name;
            this.master_id  = master_id;
            this.vif        = vif;
            this.sample_mbx = sample_mbx;
        endfunction

        task run();
            stop_requested = 0;
            forever begin
                @(posedge vif.clk);
                if (!vif.reset_n) begin
                    continue;
                end
                if (stop_requested) begin
                    break;
                end
                if (vif.rvalid && vif.rready) begin
                    axi_read_sample sample = new(
                        master_id,
                        vif.rdata,
                        axi_resp_e'(vif.rresp),
                        vif.rlast
                    );
                    sample_mbx.put(sample);
                end
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    // ------------------------------------------------------------
    // Master agent
    // ------------------------------------------------------------
    class axi_master_agent;
        string name;
        int master_id;
        axi_master_driver  driver;
        axi_master_monitor monitor;
        mailbox #(axi_ar_transaction) txn_mbx;
        mailbox #(axi_read_sample)    sample_mbx;

        function new(
            string name,
            int master_id,
            virtual axi_master_if.drv drv_vif,
            virtual axi_master_if.mon mon_vif,
            mailbox #(axi_read_sample) sample_mbx
        );
            this.name       = name;
            this.master_id  = master_id;
            this.sample_mbx = sample_mbx;
            this.txn_mbx    = new();
            driver  = new({name, "::driver"}, master_id, drv_vif, txn_mbx);
            monitor = new({name, "::monitor"}, master_id, mon_vif, sample_mbx);
        endfunction

        task start();
            fork
                driver.run();
                monitor.run();
            join_none
        endtask

        task stop();
            txn_mbx.put(null);
            monitor.stop();
        endtask

        task send(axi_ar_transaction txn);
            txn_mbx.put(txn);
        endtask
    endclass

    // ------------------------------------------------------------
    // Slave model
    // ------------------------------------------------------------
    class axi_slave_model;
        string name;
        int slave_id;
        int pattern_id;
        virtual axi_slave_if.model vif;

        function new(
            string name,
            int slave_id,
            int pattern_id,
            virtual axi_slave_if.model vif
        );
            this.name       = name;
            this.slave_id   = slave_id;
            this.pattern_id = pattern_id;
            this.vif        = vif;
        endfunction

        task run();
            vif.cb.arready <= 1'b0;
            vif.cb.rvalid  <= 1'b0;
            vif.cb.rlast   <= 1'b0;
            vif.cb.rresp   <= AXI_RESP_OKAY;
            @(posedge vif.reset_n);
            forever begin
                wait_for_request();
            end
        endtask

        protected task wait_for_request();
            // Wait for AR handshake
            do @(vif.cb); while (!vif.reset_n || !(vif.cb.arvalid));
            logic [31:0] base_addr = vif.cb.araddr;
            logic [3:0]  len       = vif.cb.arlen;

            // Accept the request
            vif.cb.arready <= 1'b1;
            @(vif.cb);
            vif.cb.arready <= 1'b0;

            // Provide data
            int beats = len + 1;
            for (int beat = 0; beat < beats; ) begin
                @(vif.cb);
                if (!vif.reset_n) begin
                    beat = 0;
                    vif.cb.rvalid <= 1'b0;
                    continue;
                end
                vif.cb.rvalid <= 1'b1;
                vif.cb.rdata  <= pattern_value(pattern_id, base_addr, beat);
                vif.cb.rresp  <= AXI_RESP_OKAY;
                vif.cb.rlast  <= (beat == beats-1);

                if (vif.cb.rvalid && vif.cb.rready) begin
                    beat++;
                end
            end

            @(vif.cb);
            vif.cb.rvalid <= 1'b0;
            vif.cb.rlast  <= 1'b0;
        endtask
    endclass

    // ------------------------------------------------------------
    // Scoreboard
    // ------------------------------------------------------------
    class axi_scoreboard;
        string name;
        mailbox #(axi_read_sample) sample_mbx;
        axi_expected_beat_t        expected[int][$];
        int pass_count;
        int fail_count;
        bit stop_requested;

        function new(string name = "axi_scoreboard");
            this.name       = name;
            this.sample_mbx = new();
            this.pass_count = 0;
            this.fail_count = 0;
            this.stop_requested = 0;
        endfunction

        function mailbox #(axi_read_sample) get_sample_mbx();
            return sample_mbx;
        endfunction

        task start();
            fork
                monitor_actual();
            join_none
        endtask

        task stop();
            stop_requested = 1;
        endtask

        task monitor_actual();
            axi_read_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) begin
                    if (stop_requested) break;
                    else continue;
                end
                if (expected.exists(sample.master_id) && expected[sample.master_id].size() > 0) begin
                    axi_expected_beat_t exp = expected[sample.master_id].pop_front();
                    if (sample.data !== exp.data || sample.resp !== exp.resp || sample.last !== exp.last) begin
                        $error("[%s] Data mismatch: master %0d exp=0x%08h resp=%0d last=%0b, got data=0x%08h resp=%0d last=%0b",
                               name, sample.master_id, exp.data, exp.resp, exp.last,
                               sample.data, sample.resp, sample.last);
                        fail_count++;
                    end else begin
                        pass_count++;
                    end
                end else begin
                    $error("[%s] Unexpected beat from master %0d data=0x%08h", name, sample.master_id, sample.data);
                    fail_count++;
                end
            end
        endtask

        function void expect_beats(
            int master_id,
            axi_ar_transaction txn,
            int pattern_id
        );
            axi_expected_beat_t exp;
            int beats = txn.len + 1;
            for (int beat = 0; beat < beats; beat++) begin
                exp.data = pattern_value(pattern_id, txn.addr, beat);
                exp.resp = AXI_RESP_OKAY;
                exp.last = (beat == beats-1);
                expected[master_id].push_back(exp);
            end
        endfunction

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] Scoreboard summary: pass=%0d fail=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    // ------------------------------------------------------------
    // Environment
    // ------------------------------------------------------------
    class axi_env;
        string name;
        axi_master_agent master_agents[int];
        axi_slave_model  slave_models[int];
        axi_slave_cfg_t  slave_cfg[int];
        axi_scoreboard   scoreboard;

        function new(string name = "axi_env");
            this.name = name;
            this.scoreboard = new({name, "::scoreboard"});
        endfunction

        function axi_scoreboard get_scoreboard();
            return scoreboard;
        endfunction

        function void add_master(
            int master_id,
            virtual axi_master_if.drv drv_vif,
            virtual axi_master_if.mon mon_vif
        );
            axi_master_agent agent = new($sformatf("master_agent_%0d", master_id),
                                         master_id,
                                         drv_vif,
                                         mon_vif,
                                         scoreboard.get_sample_mbx());
            master_agents[master_id] = agent;
        endfunction

        function void add_slave(
            int slave_id,
            virtual axi_slave_if.model slv_vif,
            axi_slave_cfg_t cfg
        );
            axi_slave_model model = new($sformatf("slave_model_%0d", slave_id),
                                        slave_id,
                                        cfg.pattern_id,
                                        slv_vif);
            slave_models[slave_id] = model;
            slave_cfg[slave_id]    = cfg;
        endfunction

        task start();
            scoreboard.start();
            foreach (slave_models[idx]) begin
                fork
                    slave_models[idx].run();
                join_none
            end
            foreach (master_agents[idx]) begin
                master_agents[idx].start();
            end
        endtask

        task stop();
            foreach (master_agents[idx]) begin
                master_agents[idx].stop();
            end
            scoreboard.stop();
            scoreboard.get_sample_mbx().put(null);
        endtask

        function void expect_txn(axi_ar_transaction txn);
            int slave_id = locate_slave(txn.addr);
            if (slave_id < 0) begin
                $error("[%s] No slave mapped for addr 0x%08h", name, txn.addr);
                return;
            end
            txn.slave_id = slave_id;
            axi_slave_cfg_t cfg = slave_cfg[slave_id];
            scoreboard.expect_beats(txn.master_id, txn, cfg.pattern_id);
        endfunction

        function void send_txn(int master_id, axi_ar_transaction txn);
            txn.master_id = master_id;
            expect_txn(txn);
            if (master_agents.exists(master_id)) begin
                master_agents[master_id].send(txn);
            end else begin
                $error("[%s] No master agent %0d", name, master_id);
            end
        endfunction

        function int locate_slave(logic [31:0] addr);
            foreach (slave_cfg[idx]) begin
                if (addr >= slave_cfg[idx].addr_lo && addr <= slave_cfg[idx].addr_hi) begin
                    return idx;
                end
            end
            return -1;
        endfunction
    endclass

    // ------------------------------------------------------------
    // Base test
    // ------------------------------------------------------------
    class axi_test_base;
        string name;
        axi_env env;

        function new(string name = "axi_test_base");
            this.name = name;
        endfunction

        function void set_env(axi_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No stimulus defined.", name);
        endtask

        protected function axi_ar_transaction make_txn(
            int master_id,
            logic [31:0] addr,
            logic [7:0] len = 8'd0
        );
            axi_ar_transaction txn = new(master_id, addr, len);
            return txn;
        endfunction

        task send_txn(int master_id, logic [31:0] addr, logic [7:0] len = 8'd0);
            axi_ar_transaction txn = make_txn(master_id, addr, len);
            env.send_txn(master_id, txn);
        endtask
    endclass

endpackage

