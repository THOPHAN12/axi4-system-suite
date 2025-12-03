`timescale 1ns/1ps

package read_controller_tb_pkg;

    typedef struct packed {
        bit          check_select_slave;
        logic [1:0]  select_slave;
        bit          check_select_master;
        logic        select_master;
        bit          check_select_data_m0;
        logic [1:0]  select_data_m0;
        bit          check_select_data_m1;
        logic [1:0]  select_data_m1;
        bit          check_en_s0;
        logic [1:0]  en_s0;
        bit          check_en_s1;
        logic [1:0]  en_s1;
        bit          check_en_s2;
        logic [1:0]  en_s2;
        bit          check_en_s3;
        logic [1:0]  en_s3;
    } read_ctrl_expected_t;

    typedef class read_ctrl_scenario;

    class read_ctrl_sample;
        logic [1:0] select_slave_address;
        logic       select_master_address;
        logic [1:0] select_data_M0;
        logic [1:0] select_data_M1;
        logic [1:0] en_S0, en_S1, en_S2, en_S3;

        function new(
            logic [1:0] select_slave_address,
            logic       select_master_address,
            logic [1:0] select_data_M0,
            logic [1:0] select_data_M1,
            logic [1:0] en_S0,
            logic [1:0] en_S1,
            logic [1:0] en_S2,
            logic [1:0] en_S3
        );
            this.select_slave_address = select_slave_address;
            this.select_master_address = select_master_address;
            this.select_data_M0 = select_data_M0;
            this.select_data_M1 = select_data_M1;
            this.en_S0 = en_S0;
            this.en_S1 = en_S1;
            this.en_S2 = en_S2;
            this.en_S3 = en_S3;
        endfunction
    endclass

    class read_ctrl_scenario;
        string name;
        logic [31:0] addr;
        bit          use_addr;
        bit          m0_arvalid;
        bit          m1_arvalid;
        bit          m0_rready;
        bit          m1_rready;
        bit [3:0]    slave_arready;
        bit [3:0]    slave_rvalid;
        bit [3:0]    slave_rlast;
        int          cycles;
        read_ctrl_expected_t expected;

        function new(string name = "scenario");
            this.name = name;
            addr = 32'h0;
            use_addr = 1'b1;
            m0_arvalid = 1'b0;
            m1_arvalid = 1'b0;
            m0_rready = 1'b0;
            m1_rready = 1'b0;
            slave_arready = 4'hF;
            slave_rvalid  = 4'h0;
            slave_rlast   = 4'h0;
            cycles = 1;
            expected = '{default:0};
        endfunction
    endclass

    class read_ctrl_driver;
        string name;
        virtual read_controller_if vif;
        mailbox #(read_ctrl_scenario) scen_mbx;

        function new(string name,
                     virtual read_controller_if vif,
                     mailbox #(read_ctrl_scenario) scen_mbx);
            this.name    = name;
            this.vif     = vif;
            this.scen_mbx = scen_mbx;
        endfunction

        task run();
            read_ctrl_scenario scen;
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
            vif.cb.M_ADDR       <= 32'h0;
            vif.cb.M0_ARVALID   <= 1'b0;
            vif.cb.M1_ARVALID   <= 1'b0;
            vif.cb.M0_RREADY    <= 1'b0;
            vif.cb.M1_RREADY    <= 1'b0;
            vif.cb.S0_ARREADY   <= 1'b1;
            vif.cb.S1_ARREADY   <= 1'b1;
            vif.cb.S2_ARREADY   <= 1'b1;
            vif.cb.S3_ARREADY   <= 1'b1;
            vif.cb.S0_RVALID    <= 1'b0;
            vif.cb.S1_RVALID    <= 1'b0;
            vif.cb.S2_RVALID    <= 1'b0;
            vif.cb.S3_RVALID    <= 1'b0;
            vif.cb.S0_RLAST     <= 1'b0;
            vif.cb.S1_RLAST     <= 1'b0;
            vif.cb.S2_RLAST     <= 1'b0;
            vif.cb.S3_RLAST     <= 1'b0;
        endtask

        protected task drive_scenario(read_ctrl_scenario scen);
            for (int i = 0; i < scen.cycles; i++) begin
                @(vif.cb);
                if (scen.use_addr) begin
                    vif.cb.M_ADDR <= scen.addr;
                end
                vif.cb.M0_ARVALID <= scen.m0_arvalid;
                vif.cb.M1_ARVALID <= scen.m1_arvalid;
                vif.cb.M0_RREADY  <= scen.m0_rready;
                vif.cb.M1_RREADY  <= scen.m1_rready;
                vif.cb.S0_ARREADY <= scen.slave_arready[0];
                vif.cb.S1_ARREADY <= scen.slave_arready[1];
                vif.cb.S2_ARREADY <= scen.slave_arready[2];
                vif.cb.S3_ARREADY <= scen.slave_arready[3];
                vif.cb.S0_RVALID  <= scen.slave_rvalid[0];
                vif.cb.S1_RVALID  <= scen.slave_rvalid[1];
                vif.cb.S2_RVALID  <= scen.slave_rvalid[2];
                vif.cb.S3_RVALID  <= scen.slave_rvalid[3];
                vif.cb.S0_RLAST   <= scen.slave_rlast[0];
                vif.cb.S1_RLAST   <= scen.slave_rlast[1];
                vif.cb.S2_RLAST   <= scen.slave_rlast[2];
                vif.cb.S3_RLAST   <= scen.slave_rlast[3];
            end
            reset_signals();
        endtask
    endclass

    class read_ctrl_monitor;
        string name;
        virtual read_controller_if vif;
        mailbox #(read_ctrl_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual read_controller_if vif,
                     mailbox #(read_ctrl_sample) sample_mbx);
            this.name       = name;
            this.vif        = vif;
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
                read_ctrl_sample sample = new(
                    vif.select_slave_address,
                    vif.select_master_address,
                    vif.select_data_M0,
                    vif.select_data_M1,
                    vif.en_S0,
                    vif.en_S1,
                    vif.en_S2,
                    vif.en_S3
                );
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class read_ctrl_scoreboard;
        string name;
        mailbox #(read_ctrl_sample) sample_mbx;
        read_ctrl_expected_t exp_queue[$];
        int pass_count;
        int fail_count;

        function new(string name,
                     mailbox #(read_ctrl_sample) sample_mbx);
            this.name       = name;
            this.sample_mbx = sample_mbx;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task expect(read_ctrl_scenario scen);
            read_ctrl_expected_t exp = scen.expected;
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
            read_ctrl_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) begin
                    break;
                end
                if (exp_queue.size() == 0) begin
                    continue;
                end
                read_ctrl_expected_t exp = exp_queue.pop_front();
                check_field("select_slave", exp.check_select_slave,
                            exp.select_slave, sample.select_slave_address);
                check_field("select_master", exp.check_select_master,
                            exp.select_master, sample.select_master_address);
                check_field("select_data_M0", exp.check_select_data_m0,
                            exp.select_data_m0, sample.select_data_M0);
                check_field("select_data_M1", exp.check_select_data_m1,
                            exp.select_data_m1, sample.select_data_M1);
                check_field("en_S0", exp.check_en_s0, exp.en_s0, sample.en_S0);
                check_field("en_S1", exp.check_en_s1, exp.en_s1, sample.en_S1);
                check_field("en_S2", exp.check_en_s2, exp.en_s2, sample.en_S2);
                check_field("en_S3", exp.check_en_s3, exp.en_s3, sample.en_S3);
            end
        endtask

        protected task check_field(string field_name,
                                   bit check_enable,
                                   logic [1:0] expected,
                                   logic [1:0] actual);
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

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS = %0d, FAIL = %0d, Pending = %0d",
                     name, pass_count, fail_count, exp_queue.size());
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class read_ctrl_env;
        string name;
        read_ctrl_driver    driver;
        read_ctrl_monitor   monitor;
        read_ctrl_scoreboard scoreboard;
        mailbox #(read_ctrl_scenario) scen_mbx;
        mailbox #(read_ctrl_sample)   sample_mbx;
        virtual read_controller_if    vif;

        function new(string name,
                     virtual read_controller_if vif);
            this.name = name;
            this.vif  = vif;
            scen_mbx   = new();
            sample_mbx = new();
            scoreboard = new({name, "::scoreboard"}, sample_mbx);
            driver     = new({name, "::driver"}, vif, scen_mbx);
            monitor    = new({name, "::monitor"}, vif, sample_mbx);
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

        task send(read_ctrl_scenario scen);
            scoreboard.expect(scen);
            scen_mbx.put(scen);
        endtask

        function read_ctrl_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class read_ctrl_test_base;
        string name;
        read_ctrl_env env;

        function new(string name = "read_ctrl_test_base");
            this.name = name;
        endfunction

        function void set_env(read_ctrl_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No test scenario defined", name);
        endtask

        task send_scenario(read_ctrl_scenario scen);
            env.send(scen);
        endtask

        task send_idle(int cycles = 1);
            read_ctrl_scenario scen = new("idle");
            scen.use_addr = 0;
            scen.cycles = cycles;
            send_scenario(scen);
        endtask

        function read_ctrl_scenario make_addr_request(
            string name,
            logic [31:0] addr,
            bit m0_req,
            bit m1_req,
            logic [1:0] expected_slave,
            bit check_master = 0,
            logic select_master = 1'b0
        );
            read_ctrl_scenario scen = new(name);
            scen.addr        = addr;
            scen.m0_arvalid  = m0_req;
            scen.m1_arvalid  = m1_req;
            scen.expected.check_select_slave = 1'b1;
            scen.expected.select_slave       = expected_slave;
            if (check_master) begin
                scen.expected.check_select_master = 1'b1;
                scen.expected.select_master       = select_master;
            end
            return scen;
        endfunction

        function read_ctrl_scenario make_data_response(
            string name,
            bit [3:0] rvalid_vec,
            bit [3:0] rlast_vec,
            bit m0_ready,
            bit m1_ready,
            logic [1:0] expected_data_m0 = '0,
            bit check_data_m0 = 0,
            logic [1:0] expected_data_m1 = '0,
            bit check_data_m1 = 0,
            logic [1:0] expected_en_s0 = '0,
            bit check_en_s0 = 0,
            logic [1:0] expected_en_s1 = '0,
            bit check_en_s1 = 0,
            logic [1:0] expected_en_s2 = '0,
            bit check_en_s2 = 0,
            logic [1:0] expected_en_s3 = '0,
            bit check_en_s3 = 0
        );
            read_ctrl_scenario scen = new(name);
            scen.use_addr = 0;
            scen.slave_rvalid = rvalid_vec;
            scen.slave_rlast  = rlast_vec;
            scen.m0_rready    = m0_ready;
            scen.m1_rready    = m1_ready;
            scen.expected.check_select_data_m0 = check_data_m0;
            scen.expected.select_data_m0       = expected_data_m0;
            scen.expected.check_select_data_m1 = check_data_m1;
            scen.expected.select_data_m1       = expected_data_m1;
            scen.expected.check_en_s0 = check_en_s0;
            scen.expected.en_s0       = expected_en_s0;
            scen.expected.check_en_s1 = check_en_s1;
            scen.expected.en_s1       = expected_en_s1;
            scen.expected.check_en_s2 = check_en_s2;
            scen.expected.en_s2       = expected_en_s2;
            scen.expected.check_en_s3 = check_en_s3;
            scen.expected.en_s3       = expected_en_s3;
            return scen;
        endfunction
    endclass

endpackage

