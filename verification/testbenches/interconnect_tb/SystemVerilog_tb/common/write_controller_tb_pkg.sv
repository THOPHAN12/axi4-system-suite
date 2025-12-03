`timescale 1ns/1ps

import queue_tb_pkg::queue_id_t;

package write_controller_tb_pkg;

    typedef struct packed {
        bit          check_aw_grant;
        logic        aw_grant;
        bit          check_selected_slave;
        logic [0:0]  selected_slave;
        bit          check_queue_full;
        logic        queue_full;
        bit          check_token;
        logic        token;
        bit          check_load_original;
        logic        load_original;
        bit          check_slave_awvalid[2];
        logic [1:0]  slave_awvalid[2];
    } write_ctrl_expected_t;

    typedef class write_ctrl_scenario;

    class write_ctrl_sample;
        logic        aw_grant;
        logic [0:0]  selected_slave;
        logic        queue_full;
        logic        token;
        logic        load_original;
        logic [1:0]  slave_awvalid[2];

        function new(
            logic        aw_grant,
            logic [0:0]  selected_slave,
            logic        queue_full,
            logic        token,
            logic        load_original,
            logic [1:0]  slave_awvalid [2]
        );
            this.aw_grant       = aw_grant;
            this.selected_slave = selected_slave;
            this.queue_full     = queue_full;
            this.token          = token;
            this.load_original  = load_original;
            this.slave_awvalid  = slave_awvalid;
        endfunction
    endclass

    class write_ctrl_scenario;
        string name;
        logic [1:0][31:0] s_awaddr;
        logic [1:0][7:0]  s_awlen;
        logic [1:0][2:0]  s_awsize;
        logic [1:0][1:0]  s_awburst;
        logic [1:0][3:0]  s_awqos;
        logic [1:0]       s_awvalid;
        logic [1:0]       m_awready;
        logic             queue_full;
        int               cycles;
        write_ctrl_expected_t expected;

        function new(string name = "write_ctrl_scenario");
            this.name = name;
            s_awaddr  = '{default:32'h0};
            s_awlen   = '{default:8'h0};
            s_awsize  = '{default:3'h2};
            s_awburst = '{default:2'b01};
            s_awqos   = '{default:4'h0};
            s_awvalid = '{default:1'b0};
            m_awready = '{default:1'b1};
            queue_full = 1'b0;
            cycles = 1;
            expected = '{default:0};
        endfunction
    endclass

    class write_ctrl_driver;
        string name;
        virtual write_controller_if #(2,2,32,8) vif;
        mailbox #(write_ctrl_scenario) scen_mbx;

        function new(string name,
                     virtual write_controller_if #(2,2,32,8) vif,
                     mailbox #(write_ctrl_scenario) scen_mbx);
            this.name = name;
            this.vif  = vif;
            this.scen_mbx = scen_mbx;
        endfunction

        task run();
            write_ctrl_scenario scen;
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
            vif.cb.s_awaddr  <= '{default:32'h0};
            vif.cb.s_awlen   <= '{default:8'h0};
            vif.cb.s_awsize  <= '{default:3'h2};
            vif.cb.s_awburst <= '{default:2'b01};
            vif.cb.s_awqos   <= '{default:4'h0};
            vif.cb.s_awvalid <= '{default:1'b0};
            vif.cb.m_awready <= '{default:1'b1};
            vif.cb.Queue_Is_Full <= 1'b0;
        endtask

        protected task drive_scenario(write_ctrl_scenario scen);
            for (int i = 0; i < scen.cycles; i++) begin
                @(vif.cb);
                vif.cb.s_awaddr  <= scen.s_awaddr;
                vif.cb.s_awlen   <= scen.s_awlen;
                vif.cb.s_awsize  <= scen.s_awsize;
                vif.cb.s_awburst <= scen.s_awburst;
                vif.cb.s_awqos   <= scen.s_awqos;
                vif.cb.s_awvalid <= scen.s_awvalid;
                vif.cb.m_awready <= scen.m_awready;
                vif.cb.Queue_Is_Full <= scen.queue_full;
            end
            reset_signals();
        endtask
    endclass

    class write_ctrl_monitor;
        string name;
        virtual write_controller_if #(2,2,32,8) vif;
        mailbox #(write_ctrl_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual write_controller_if #(2,2,32,8) vif,
                     mailbox #(write_ctrl_sample) sample_mbx);
            this.name = name;
            this.vif  = vif;
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
                    sample_mbx.put(null);
                    break;
                end
                logic [1:0] slave_valid[2];
                for (int s = 0; s < 2; s++) begin
                    slave_valid[s] = {vif.m_awvalid[s], vif.m_awready[s]};
                end
                write_ctrl_sample sample = new(
                    vif.AW_Access_Grant,
                    vif.AW_Selected_Slave,
                    vif.Queue_Is_Full,
                    vif.Token,
                    vif.Load_The_Original_Signals,
                    slave_valid
                );
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class write_ctrl_scoreboard;
        string name;
        mailbox #(write_ctrl_sample) sample_mbx;
        write_ctrl_expected_t exp_queue[$];
        int pass_count;
        int fail_count;

        function new(string name,
                     mailbox #(write_ctrl_sample) sample_mbx);
            this.name = name;
            this.sample_mbx = sample_mbx;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task expect(write_ctrl_scenario scen);
            write_ctrl_expected_t exp = scen.expected;
            for (int i = 0; i < scen.cycles; i++) begin
                exp_queue.push_back(exp);
            end
        endtask

        task start();
            fork monitor_actual(); join_none;
        endtask

        task stop();
            sample_mbx.put(null);
        endtask

        task monitor_actual();
            write_ctrl_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) begin
                    break;
                end
                if (exp_queue.size() == 0) begin
                    continue;
                end
                write_ctrl_expected_t exp = exp_queue.pop_front();
                check_field("AW_Access_Grant", exp.check_aw_grant, exp.aw_grant, sample.aw_grant);
                check_field("AW_Selected_Slave", exp.check_selected_slave,
                            exp.selected_slave, sample.selected_slave);
                check_field("Queue_Is_Full", exp.check_queue_full, exp.queue_full, sample.queue_full);
                check_field("Token", exp.check_token, exp.token, sample.token);
                check_field("Load_Original", exp.check_load_original,
                            exp.load_original, sample.load_original);
            end
        endtask

        protected task check_field(string field_name,
                                   bit check_enable,
                                   logic expected,
                                   logic actual);
            if (!check_enable) begin
                return;
            end
            if (expected !== actual) begin
                $error("[%s] %s mismatch exp=%b got=%b", name, field_name, expected, actual);
                fail_count++;
            end else begin
                pass_count++;
            end
        endtask

        protected task check_field(string field_name,
                                   bit check_enable,
                                   logic [0:0] expected,
                                   logic [0:0] actual);
            if (!check_enable) begin
                return;
            end
            if (expected !== actual) begin
                $error("[%s] %s mismatch exp=%b got=%b", name, field_name, expected, actual);
                fail_count++;
            end else begin
                pass_count++;
            end
        endtask

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d Pending=%0d",
                     name, pass_count, fail_count, exp_queue.size());
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class write_ctrl_env;
        string name;
        write_ctrl_driver    driver;
        write_ctrl_monitor   monitor;
        write_ctrl_scoreboard scoreboard;
        mailbox #(write_ctrl_scenario) scen_mbx;
        mailbox #(write_ctrl_sample)   sample_mbx;
        virtual write_controller_if #(2,2,32,8) vif;

        function new(string name,
                     virtual write_controller_if #(2,2,32,8) vif);
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

        task send(write_ctrl_scenario scen);
            scoreboard.expect(scen);
            scen_mbx.put(scen);
        endtask

        function write_ctrl_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class write_ctrl_test_base;
        string name;
        write_ctrl_env env;

        function new(string name = "write_ctrl_test_base");
            this.name = name;
        endfunction

        function void set_env(write_ctrl_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No write controller stimulus", name);
        endtask

        task send(write_ctrl_scenario scen);
            env.send(scen);
        endtask
    endclass

endpackage

