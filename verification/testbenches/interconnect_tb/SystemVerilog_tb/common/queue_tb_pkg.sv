`timescale 1ns/1ps

package queue_tb_pkg;

    localparam int QUEUE_ID_WIDTH = 1;
    typedef logic [QUEUE_ID_WIDTH-1:0] queue_id_t;

    typedef struct packed {
        bit          check_master_valid;
        logic        master_valid;
        bit          check_write_data_master;
        queue_id_t   write_data_master;
        bit          check_queue_full;
        logic        queue_full;
        bit          check_split_flag;
        logic        split_flag;
        bit          check_handshake_pulse;
        logic        handshake_pulse;
    } queue_expected_t;

    typedef class queue_scenario;

    class queue_sample;
        logic        master_valid;
        queue_id_t   write_data_master;
        logic        queue_is_full;
        logic        split_flag;
        logic        handshake_pulse;

        function new(
            logic master_valid,
            queue_id_t write_data_master,
            logic queue_is_full,
            logic split_flag,
            logic handshake_pulse
        );
            this.master_valid       = master_valid;
            this.write_data_master  = write_data_master;
            this.queue_is_full      = queue_is_full;
            this.split_flag         = split_flag;
            this.handshake_pulse    = handshake_pulse;
        endfunction
    endclass

    class queue_scenario;
        string name;
        queue_id_t slave_id;
        logic       AW_Access_Grant;
        logic       Write_Data_Finsh;
        logic       Is_Transaction_Part_of_Split;
        int         cycles;
        queue_expected_t expected;

        function new(string name = "queue_scenario");
            this.name = name;
            slave_id = '0;
            AW_Access_Grant = 1'b0;
            Write_Data_Finsh = 1'b0;
            Is_Transaction_Part_of_Split = 1'b0;
            cycles = 1;
            expected = '{default:0};
        endfunction
    endclass

    class queue_driver;
        string name;
        virtual queue_if #(QUEUE_ID_WIDTH) vif;
        mailbox #(queue_scenario) scen_mbx;

        function new(string name,
                     virtual queue_if #(QUEUE_ID_WIDTH) vif,
                     mailbox #(queue_scenario) scen_mbx);
            this.name = name;
            this.vif = vif;
            this.scen_mbx = scen_mbx;
        endfunction

        task run();
            queue_scenario scen;
            reset_signals();
            @(posedge vif.reset);
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
            vif.cb.slave_id                   <= '0;
            vif.cb.AW_Access_Grant            <= 1'b0;
            vif.cb.Write_Data_Finsh           <= 1'b0;
            vif.cb.Is_Transaction_Part_of_Split <= 1'b0;
        endtask

        protected task drive_scenario(queue_scenario scen);
            for (int i = 0; i < scen.cycles; i++) begin
                @(vif.cb);
                vif.cb.slave_id                    <= scen.slave_id;
                vif.cb.AW_Access_Grant             <= scen.AW_Access_Grant;
                vif.cb.Write_Data_Finsh            <= scen.Write_Data_Finsh;
                vif.cb.Is_Transaction_Part_of_Split <= scen.Is_Transaction_Part_of_Split;
            end
            reset_signals();
        endtask
    endclass

    class queue_monitor;
        string name;
        virtual queue_if #(QUEUE_ID_WIDTH) vif;
        mailbox #(queue_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual queue_if #(QUEUE_ID_WIDTH) vif,
                     mailbox #(queue_sample) sample_mbx);
            this.name = name;
            this.vif = vif;
            this.sample_mbx = sample_mbx;
        endfunction

        task run();
            stop_requested = 0;
            forever begin
                @(posedge vif.clk);
                if (!vif.reset) begin
                    continue;
                end
                if (stop_requested) begin
                    sample_mbx.put(null);
                    break;
                end
                queue_sample sample = new(
                    vif.Master_Valid,
                    vif.Write_Data_Master,
                    vif.Queue_Is_Full,
                    vif.Is_Master_Part_Of_Split,
                    vif.Write_Data_HandShake_En_Pulse
                );
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class queue_scoreboard;
        string name;
        mailbox #(queue_sample) sample_mbx;
        queue_expected_t exp_queue[$];
        int pass_count;
        int fail_count;

        function new(string name,
                     mailbox #(queue_sample) sample_mbx);
            this.name = name;
            this.sample_mbx = sample_mbx;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task expect(queue_scenario scen);
            queue_expected_t exp = scen.expected;
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
            queue_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) begin
                    break;
                end
                if (exp_queue.size() == 0) begin
                    continue;
                end
                queue_expected_t exp = exp_queue.pop_front();
                check_field("Master_Valid",exp.check_master_valid,
                            exp.master_valid, sample.master_valid);
                check_field("Write_Data_Master", exp.check_write_data_master,
                            exp.write_data_master, sample.write_data_master);
                check_field("Queue_Is_Full", exp.check_queue_full,
                            exp.queue_full, sample.queue_is_full);
                check_field("Is_Master_Part_Of_Split", exp.check_split_flag,
                            exp.split_flag, sample.split_flag);
                check_field("Write_Data_HandShake_En_Pulse", exp.check_handshake_pulse,
                            exp.handshake_pulse, sample.handshake_pulse);
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
                                   queue_id_t expected,
                                   queue_id_t actual);
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

    class queue_env;
        string name;
        queue_driver    driver;
        queue_monitor   monitor;
        queue_scoreboard scoreboard;
        mailbox #(queue_scenario) scen_mbx;
        mailbox #(queue_sample)   sample_mbx;
        virtual queue_if #(QUEUE_ID_WIDTH)     vif;

        function new(string name,
                     virtual queue_if #(QUEUE_ID_WIDTH) vif);
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

        task send(queue_scenario scen);
            scoreboard.expect(scen);
            scen_mbx.put(scen);
        endtask

        function queue_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class queue_test_base;
        string name;
        queue_env env;

        function new(string name = "queue_test_base");
            this.name = name;
        endfunction

        function void set_env(queue_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No queue stimulus", name);
        endtask

        task send_scenario(queue_scenario scen);
            env.send(scen);
        endtask

        task wait_cycles(int cycles);
            queue_scenario idle = new("idle");
            idle.cycles = cycles;
            idle.expected = '{default:0};
            send_scenario(idle);
        endtask

        function queue_scenario make_push(string name, queue_id_t id);
            queue_scenario scen = new(name);
            scen.slave_id = id;
            scen.AW_Access_Grant = 1'b1;
            scen.expected.check_master_valid = 1'b1;
            scen.expected.master_valid       = 1'b1;
            scen.expected.check_write_data_master = 1'b1;
            scen.expected.write_data_master       = id;
            scen.expected.check_handshake_pulse   = 1'b0;
            return scen;
        endfunction

        function queue_scenario make_finish(string name);
            queue_scenario scen = new(name);
            scen.Write_Data_Finsh = 1'b1;
            scen.expected.check_master_valid = 1'b0;
            scen.expected.check_write_data_master = 1'b0;
            return scen;
        endfunction
    endclass

endpackage

