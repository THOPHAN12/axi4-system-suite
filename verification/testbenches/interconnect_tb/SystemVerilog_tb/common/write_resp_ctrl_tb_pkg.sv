`timescale 1ns/1ps

package write_resp_ctrl_tb_pkg;

    typedef struct {
        logic [1:0] bresp;
        int         master_id;
    } wr_resp_expected_t;

    typedef class wr_resp_scenario;

    class wr_resp_sample;
        logic [1:0] bresp[2];
        logic       valid[2];

        function new(logic [1:0] bresp[2],
                     logic valid[2]);
            this.bresp = bresp;
            this.valid = valid;
        endfunction
    endclass

    class wr_resp_scenario;
        string name;
        int    slave_id;
        int    master_id;
        logic [1:0] bresp;
        bit         valid;
        wr_resp_expected_t expected;

        function new(string name = "wr_resp_scenario");
            this.name = name;
            slave_id  = 0;
            master_id = 0;
            bresp     = 2'b00;
            valid     = 1'b1;
            expected  = '{bresp:2'b00, master_id:0};
        endfunction
    endclass

    class wr_resp_driver;
        string name;
        virtual write_resp_ctrl_if #(2,2,1) vif;
        mailbox #(wr_resp_scenario) scen_mbx;

        function new(string name,
                     virtual write_resp_ctrl_if #(2,2,1) vif,
                     mailbox #(wr_resp_scenario) scen_mbx);
            this.name = name;
            this.vif  = vif;
            this.scen_mbx = scen_mbx;
        endfunction

        task run();
            wr_resp_scenario scen;
            reset_signals();
            @(posedge vif.reset_n);
            forever begin
                scen_mbx.get(scen);
                if (scen == null) begin
                    reset_signals();
                    break;
                end
                drive_scenario(scen);
            end
        endtask

        protected task reset_signals();
            vif.cb.m_bid    <= '{default:'0};
            vif.cb.m_bresp  <= '{default:2'b00};
            vif.cb.m_bvalid <= '{default:1'b0};
            vif.cb.s_bready <= '{default:1'b1};
            vif.cb.Write_Data_Master      <= '0;
            vif.cb.Write_Data_Finsh       <= 1'b0;
            vif.cb.Rem                    <= '0;
            vif.cb.Num_Of_Compl_Bursts    <= '0;
            vif.cb.Is_Master_Part_Of_Split<= 1'b0;
            vif.cb.Load_The_Original_Signals <= 1'b0;
        endtask

        protected task drive_scenario(wr_resp_scenario scen);
            vif.cb.Write_Data_Master <= scen.master_id;
            vif.cb.Write_Data_Finsh  <= scen.valid;
            @(vif.cb);
            vif.cb.Write_Data_Finsh  <= 1'b0;

            vif.cb.m_bid[scen.slave_id]    <= scen.master_id;
            vif.cb.m_bresp[scen.slave_id]  <= scen.bresp;
            vif.cb.m_bvalid[scen.slave_id] <= scen.valid;
            @(vif.cb);
            vif.cb.m_bvalid[scen.slave_id] <= 1'b0;
        endtask
    endclass

    class wr_resp_monitor;
        string name;
        virtual write_resp_ctrl_if #(2,2,1) vif;
        mailbox #(wr_resp_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual write_resp_ctrl_if #(2,2,1) vif,
                     mailbox #(wr_resp_sample) sample_mbx);
            this.name = name;
            this.vif  = vif;
            this.sample_mbx = sample_mbx;
        endfunction

        task run();
            stop_requested = 0;
            forever begin
                @(posedge vif.clk);
                if (!vif.reset_n) continue;
                if (stop_requested) begin
                    sample_mbx.put(null);
                    break;
                end
                wr_resp_sample sample = new(vif.s_bresp, vif.s_bvalid);
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class wr_resp_scoreboard;
        string name;
        mailbox #(wr_resp_sample) sample_mbx;
        wr_resp_expected_t exp_queue[$];
        int pass_count;
        int fail_count;

        function new(string name,
                     mailbox #(wr_resp_sample) sample_mbx);
            this.name = name;
            this.sample_mbx = sample_mbx;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task expect(wr_resp_scenario scen);
            wr_resp_expected_t exp;
            exp.bresp     = scen.bresp;
            exp.master_id = scen.master_id;
            exp_queue.push_back(exp);
        endtask

        task start();
            fork monitor_actual(); join_none;
        endtask

        task stop();
            sample_mbx.put(null);
        endtask

        task monitor_actual();
            wr_resp_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) break;
                if (exp_queue.size() == 0) continue;
                wr_resp_expected_t exp = exp_queue.pop_front();
                int mid = exp.master_id;
                if (!sample.valid[mid]) begin
                    $error("[%s] Expected master %0d response, none observed", name, mid);
                    fail_count++;
                end else if (sample.bresp[mid] !== exp.bresp) begin
                    $error("[%s] Master %0d bresp mismatch exp=%b got=%b",
                           name, mid, exp.bresp, sample.bresp[mid]);
                    fail_count++;
                end else begin
                    pass_count++;
                end
            end
        endtask

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class write_resp_ctrl_env;
        string name;
        wr_resp_driver     driver;
        wr_resp_monitor    monitor;
        wr_resp_scoreboard scoreboard;
        mailbox #(wr_resp_scenario) scen_mbx;
        mailbox #(wr_resp_sample)   sample_mbx;
        virtual write_resp_ctrl_if #(2,2,1) vif;

        function new(string name,
                     virtual write_resp_ctrl_if #(2,2,1) vif);
            this.name = name;
            this.vif  = vif;
            scen_mbx   = new();
            sample_mbx = new();
            scoreboard = new({name,"::scoreboard"}, sample_mbx);
            driver     = new({name,"::driver"}, vif, scen_mbx);
            monitor    = new({name,"::monitor"}, vif, sample_mbx);
        endfunction

        task start();
            scoreboard.start();
            fork
                driver.run();
                monitor.run();
            join_none
        endtask

        task stop();
            scen_mbx.put(null);
            monitor.stop();
            scoreboard.stop();
        endtask

        task send(wr_resp_scenario scen);
            scoreboard.expect(scen);
            scen_mbx.put(scen);
        endtask

        function wr_resp_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class write_resp_ctrl_test_base;
        string name;
        write_resp_ctrl_env env;

        function new(string name = "write_resp_ctrl_test_base");
            this.name = name;
        endfunction

        function void set_env(write_resp_ctrl_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No response stimulus", name);
        endtask

        task send(wr_resp_scenario scen);
            env.send(scen);
        endtask

        function wr_resp_scenario make_scenario(string name,
                                                int slave_id,
                                                int master_id,
                                                logic [1:0] bresp);
            wr_resp_scenario scen = new(name);
            scen.slave_id  = slave_id;
            scen.master_id = master_id;
            scen.bresp     = bresp;
            scen.expected.bresp     = bresp;
            scen.expected.master_id = master_id;
            return scen;
        endfunction
    endclass

endpackage

