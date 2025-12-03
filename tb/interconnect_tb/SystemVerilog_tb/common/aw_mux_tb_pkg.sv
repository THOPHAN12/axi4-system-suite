`timescale 1ns/1ps

package aw_mux_tb_pkg;

    typedef class aw_mux_scenario;

    class aw_mux_scenario;
        string name;
        aw_mux_if::aw_channel_t s0;
        aw_mux_if::aw_channel_t s1;
        int select;
        aw_mux_if::aw_channel_t expected;

        function new(string name = "aw_mux_scenario");
            this.name = name;
            s0 = '{default:'0};
            s1 = '{default:'0};
            expected = '{default:'0};
            select = 0;
        endfunction
    endclass

    class aw_mux_driver;
        string name;
        aw_mux_if vif;

        function new(string name, aw_mux_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task apply(aw_mux_scenario scen);
            vif.drive_input(0, scen.s0);
            vif.drive_input(1, scen.s1);
            vif.Selected_Slave = scen.select[0];
            #1;
        endtask
    endclass

    class aw_mux_scoreboard;
        string name;
        aw_mux_if vif;
        int pass_count;
        int fail_count;

        function new(string name, aw_mux_if vif);
            this.name = name;
            this.vif  = vif;
            pass_count = 0;
            fail_count = 0;
        endfunction

        task check(aw_mux_scenario scen);
            if (vif.sel !== scen.expected) begin
                $error("[%s] Scenario %s mismatch", name, scen.name);
                fail_count++;
            end else begin
                pass_count++;
            end
        endtask

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class aw_mux_env;
        string name;
        aw_mux_driver    driver;
        aw_mux_scoreboard scoreboard;

        function new(string name, aw_mux_if vif);
            this.name = name;
            driver    = new({name,"::driver"}, vif);
            scoreboard= new({name,"::scoreboard"}, vif);
        endfunction

        task run_scenario(aw_mux_scenario scen);
            driver.apply(scen);
            scoreboard.check(scen);
        endtask

        function void report();
            scoreboard.report();
        endfunction
    endclass

    class aw_mux_test_base;
        string name;
        aw_mux_env env;

        function new(string name = "aw_mux_test_base");
            this.name = name;
        endfunction

        function void set_env(aw_mux_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No scenarios", name);
        endtask

        task send(aw_mux_scenario scen);
            env.run_scenario(scen);
        endtask

        function aw_mux_scenario make_scenario(string name,
                                               aw_mux_if::aw_channel_t s0,
                                               aw_mux_if::aw_channel_t s1,
                                               int select);
            aw_mux_scenario scen = new(name);
            scen.s0 = s0;
            scen.s1 = s1;
            scen.select = select;
            scen.expected = (select == 0) ? s0 : s1;
            return scen;
        endfunction
    endclass

endpackage

