`timescale 1ns/1ps

package wd_mux_tb_pkg;

    typedef class wd_mux_scenario;

    class wd_mux_scenario;
        string name;
        wd_mux_if::wd_channel_t m0;
        wd_mux_if::wd_channel_t m1;
        bit select;

        function new(string name = "wd_mux_scenario");
            this.name = name;
            m0 = '{default:'0};
            m1 = '{default:'0};
            select = 0;
        endfunction
    endclass

    class wd_mux_env;
        string name;
        wd_mux_if vif;
        int pass_count;
        int fail_count;

        function new(string name, wd_mux_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run_scenario(wd_mux_scenario scen);
            vif.m0 = scen.m0;
            vif.m1 = scen.m1;
            vif.Selected_Slave = scen.select;
            #1;
            wd_mux_if::wd_channel_t expected = scen.select ? scen.m1 : scen.m0;
            if (vif.sel !== expected) begin
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

    class wd_mux_test_base;
        string name;
        wd_mux_env env;

        function new(string name = "wd_mux_test_base");
            this.name = name;
        endfunction

        function void set_env(wd_mux_env env);
            this.env = env;
        endfunction

        task send(wd_mux_scenario scen);
            env.run_scenario(scen);
        endtask
    endclass

endpackage

