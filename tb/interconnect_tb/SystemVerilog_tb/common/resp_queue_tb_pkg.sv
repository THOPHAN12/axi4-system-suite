`timescale 1ns/1ps

package resp_queue_tb_pkg;

    typedef class resp_queue_scenario;

    class resp_queue_sample;
        logic valid;
        logic [0:0] id;
        logic queue_full;

        function new(logic valid, logic [0:0] id, logic queue_full);
            this.valid = valid;
            this.id    = id;
            this.queue_full = queue_full;
        endfunction
    endclass

    class resp_queue_scenario;
        string name;
        logic [0:0] master_id;
        bit grant;
        bit finish;
        int push_cycles;
        bit expect_queue_full;

        function new(string name = "resp_queue_scenario");
            this.name = name;
            master_id = '0;
            grant = 1'b1;
            finish = 1'b1;
            push_cycles = 1;
            expect_queue_full = 0;
        endfunction
    endclass

    class resp_queue_driver;
        string name;
        virtual resp_queue_if #(1) vif;
        mailbox #(resp_queue_scenario) scen_mbx;

        function new(string name,
                     virtual resp_queue_if #(1) vif,
                     mailbox #(resp_queue_scenario) scen_mbx);
            this.name    = name;
            this.vif     = vif;
            this.scen_mbx = scen_mbx;
        endfunction

        task run();
            resp_queue_scenario scen;
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
            vif.cb.Master_ID        <= '0;
            vif.cb.Write_Resp_Grant <= 1'b0;
            vif.cb.Write_Resp_Finsh <= 1'b0;
        endtask

        protected task drive_scenario(resp_queue_scenario scen);
            vif.cb.Master_ID        <= scen.master_id;
            vif.cb.Write_Resp_Grant <= scen.grant;
            @(vif.cb);
            vif.cb.Write_Resp_Grant <= 1'b0;

            repeat (scen.push_cycles-1) @(vif.cb);

            vif.cb.Write_Resp_Finsh <= scen.finish;
            @(vif.cb);
            vif.cb.Write_Resp_Finsh <= 1'b0;

            reset_signals();
        endtask
    endclass

    class resp_queue_monitor;
        string name;
        virtual resp_queue_if #(1) vif;
        mailbox #(resp_queue_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual resp_queue_if #(1) vif,
                     mailbox #(resp_queue_sample) sample_mbx);
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
                resp_queue_sample sample = new(
                    vif.Resp_Master_Valid,
                    vif.Resp_Master_ID,
                    vif.Queue_Is_Full
                );
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class resp_queue_scoreboard;
        string name;
        mailbox #(resp_queue_sample) sample_mbx;
        logic [0:0] expected_ids[$];
        int pass_count;
        int fail_count;

        function new(string name,
                     mailbox #(resp_queue_sample) sample_mbx);
            this.name = name;
            this.sample_mbx = sample_mbx;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task expect(resp_queue_scenario scen);
            expected_ids.push_back(scen.master_id);
        endtask

        task start();
            fork monitor_actual(); join_none;
        endtask

        task stop();
            sample_mbx.put(null);
        endtask

        task monitor_actual();
            resp_queue_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) break;
                if (sample.valid) begin
                    if (expected_ids.size() == 0) begin
                        $error("[%s] Unexpected response ID %0d", name, sample.id);
                        fail_count++;
                    end else begin
                        logic [0:0] exp_id = expected_ids.pop_front();
                        if (exp_id !== sample.id) begin
                            $error("[%s] Response ID mismatch exp=%0d got=%0d",
                                   name, exp_id, sample.id);
                            fail_count++;
                        end else begin
                            pass_count++;
                        end
                    end
                end
            end
        endtask

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class resp_queue_env;
        string name;
        resp_queue_driver    driver;
        resp_queue_monitor   monitor;
        resp_queue_scoreboard scoreboard;
        mailbox #(resp_queue_scenario) scen_mbx;
        mailbox #(resp_queue_sample)   sample_mbx;
        virtual resp_queue_if #(1)     vif;

        function new(string name,
                     virtual resp_queue_if #(1) vif);
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

        task send(resp_queue_scenario scen);
            scoreboard.expect(scen);
            scen_mbx.put(scen);
        endtask

        function resp_queue_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class resp_queue_test_base;
        string name;
        resp_queue_env env;

        function new(string name = "resp_queue_test_base");
            this.name = name;
        endfunction

        function void set_env(resp_queue_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No response queue stimulus", name);
        endtask

        task send(resp_queue_scenario scen);
            env.send(scen);
        endtask
    endclass

endpackage

