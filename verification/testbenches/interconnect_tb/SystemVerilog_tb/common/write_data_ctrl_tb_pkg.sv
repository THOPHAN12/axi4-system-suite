`timescale 1ns/1ps

package write_data_ctrl_tb_pkg;

    typedef struct {
        logic [31:0] data;
        logic [3:0]  strb;
        bit          last;
    } wd_beat_t;

    typedef class wd_scenario;

    class wd_sample;
        logic [31:0] data;
        logic [3:0]  strb;
        bit          last;
        bit          valid;
        logic [0:0]  master_id;
        logic        finish;
        logic [0:0]  selected_slave;

        function new(
            logic [31:0] data,
            logic [3:0]  strb,
            bit          last,
            bit          valid,
            logic [0:0]  master_id,
            logic        finish,
            logic [0:0]  selected_slave
        );
            this.data  = data;
            this.strb  = strb;
            this.last  = last;
            this.valid = valid;
            this.master_id = master_id;
            this.finish = finish;
            this.selected_slave = selected_slave;
        endfunction
    endclass

    class wd_scenario;
        string name;
        int    master_id;
        logic [0:0] selected_slave;
        wd_beat_t beats[$];
        int idle_cycles;
        bit expect_finish;

        function new(string name = "wd_scenario");
            this.name = name;
            master_id = 0;
            selected_slave = '0;
            idle_cycles = 0;
            expect_finish = 0;
        endfunction

        function void add_beat(logic [31:0] data,
                               logic [3:0] strb,
                               bit last);
            wd_beat_t beat;
            beat.data = data;
            beat.strb = strb;
            beat.last = last;
            beats.push_back(beat);
        endfunction
    endclass

    class wd_driver;
        string name;
        virtual write_data_ctrl_if #(2,32,1) vif;
        mailbox #(wd_scenario) scen_mbx;

        function new(string name,
                     virtual write_data_ctrl_if #(2,32,1) vif,
                     mailbox #(wd_scenario) scen_mbx);
            this.name = name;
            this.vif = vif;
            this.scen_mbx = scen_mbx;
        endfunction

        task run();
            wd_scenario scen;
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
            vif.cb.s_wdata  <= '{default:32'h0};
            vif.cb.s_wstrb  <= '{default:4'h0};
            vif.cb.s_wlast  <= '{default:1'b0};
            vif.cb.s_wvalid <= '{default:1'b0};
            vif.cb.m_wready <= 1'b1;
            vif.cb.AW_Access_Grant  <= 1'b0;
            vif.cb.AW_Selected_Slave <= '0;
        endtask

        protected task drive_scenario(wd_scenario scen);
            // Grant phase
            vif.cb.AW_Selected_Slave <= scen.selected_slave;
            vif.cb.AW_Access_Grant   <= 1'b1;
            @(vif.cb);
            vif.cb.AW_Access_Grant   <= 1'b0;

            // Optional idle cycles
            repeat (scen.idle_cycles) @(vif.cb);

            // Drive beats
            foreach (scen.beats[idx]) begin
                wd_beat_t beat = scen.beats[idx];
                vif.cb.s_wdata[scen.master_id]  <= beat.data;
                vif.cb.s_wstrb[scen.master_id]  <= beat.strb;
                vif.cb.s_wlast[scen.master_id]  <= beat.last;
                vif.cb.s_wvalid[scen.master_id] <= 1'b1;
                wait (vif.s_wready[scen.master_id]);
                @(vif.cb);
                vif.cb.s_wvalid[scen.master_id] <= 1'b0;
            end

            reset_signals();
        endtask
    endclass

    class wd_monitor;
        string name;
        virtual write_data_ctrl_if #(2,32,1) vif;
        mailbox #(wd_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual write_data_ctrl_if #(2,32,1) vif,
                     mailbox #(wd_sample) sample_mbx);
            this.name = name;
            this.vif = vif;
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
                wd_sample sample = new(
                    vif.m_wdata,
                    vif.m_wstrb,
                    vif.m_wlast,
                    vif.m_wvalid & vif.m_wready,
                    vif.Write_Data_Master,
                    vif.Write_Data_Finsh,
                    vif.AW_Selected_Slave
                );
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class wd_scoreboard;
        string name;
        mailbox #(wd_sample) sample_mbx;
        wd_beat_t beat_queue[$];
        logic [0:0] master_queue[$];
        bit finish_queue[$];
        logic [0:0] slave_queue[$];

        int pass_count;
        int fail_count;

        function new(string name,
                     mailbox #(wd_sample) sample_mbx);
            this.name = name;
            this.sample_mbx = sample_mbx;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task expect(wd_scenario scen);
            foreach (scen.beats[idx]) begin
                beat_queue.push_back(scen.beats[idx]);
                master_queue.push_back(scen.master_id);
            end
            if (scen.expect_finish) begin
                finish_queue.push_back(1'b1);
                slave_queue.push_back(scen.selected_slave);
            end
        endtask

        task start();
            fork monitor_actual(); join_none;
        endtask

        task stop();
            sample_mbx.put(null);
        endtask

        task monitor_actual();
            wd_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) break;
                if (sample.valid) begin
                    if (beat_queue.size() == 0) begin
                        $error("[%s] Unexpected data beat %h", name, sample.data);
                        fail_count++;
                    end else begin
                        wd_beat_t beat = beat_queue.pop_front();
                        logic [0:0] exp_master = master_queue.pop_front();
                        if (beat.data !== sample.data || beat.last !== sample.last) begin
                            $error("[%s] Data mismatch exp=%h last=%b got=%h last=%b",
                                   name, beat.data, beat.last, sample.data, sample.last);
                            fail_count++;
                        end else begin
                            pass_count++;
                        end
                        if (sample.master_id !== exp_master) begin
                            $error("[%s] Master ID mismatch exp=%0d got=%0d",
                                   name, exp_master, sample.master_id);
                            fail_count++;
                        end
                    end
                end

                if (sample.finish) begin
                    if (finish_queue.size() == 0) begin
                        $error("[%s] Unexpected finish pulse", name);
                        fail_count++;
                    end else begin
                        bit exp_finish = finish_queue.pop_front();
                        logic [0:0] exp_slave = slave_queue.pop_front();
                        if (!exp_finish) begin
                            $error("[%s] Finish not expected", name);
                            fail_count++;
                        end else if (sample.selected_slave !== exp_slave) begin
                            $error("[%s] Selected slave mismatch exp=%0d got=%0d",
                                   name, exp_slave, sample.selected_slave);
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

    class write_data_ctrl_env;
        string name;
        wd_driver     driver;
        wd_monitor    monitor;
        wd_scoreboard scoreboard;
        mailbox #(wd_scenario) scen_mbx;
        mailbox #(wd_sample)   sample_mbx;
        virtual write_data_ctrl_if #(2,32,1) vif;

        function new(string name,
                     virtual write_data_ctrl_if #(2,32,1) vif);
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

        task send(wd_scenario scen);
            scoreboard.expect(scen);
            scen_mbx.put(scen);
        endtask

        function wd_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class write_data_ctrl_test_base;
        string name;
        write_data_ctrl_env env;

        function new(string name = "write_data_ctrl_test_base");
            this.name = name;
        endfunction

        function void set_env(write_data_ctrl_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No WD stimulus", name);
        endtask

        task send(wd_scenario scen);
            env.send(scen);
        endtask

        function wd_scenario make_scenario(string name,
                                           int master_id,
                                           logic [0:0] selected_slave);
            wd_scenario scen = new(name);
            scen.master_id = master_id;
            scen.selected_slave = selected_slave;
            return scen;
        endfunction
    endclass

endpackage

