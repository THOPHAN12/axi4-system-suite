`timescale 1ns/1ps

package bready_mux_tb_pkg;

    typedef class bready_mux_scenario;

    class bready_mux_scenario;
        string name;
        bit select;
        bit m0;
        bit m1;

        function new(string name = "bready_mux_scenario");
            this.name = name;
        endfunction
    endclass

    class bready_mux_env;
        string name;
        bready_mux_if vif;
        int pass_count;
        int fail_count;

        function new(string name, bready_mux_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run_scenario(bready_mux_scenario scen);
            vif.select   = scen.select;
            vif.m0_ready = scen.m0;
            vif.m1_ready = scen.m1;
            #1;
            bit expected = scen.select ? scen.m1 : scen.m0;
            if (vif.sel_ready !== expected) begin
                $error("[%s] Scenario %s mismatch exp=%0b got=%0b",
                       name, scen.name, expected, vif.sel_ready);
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

    class bready_mux_test_base;
        string name;
        bready_mux_env env;

        function new(string name = "bready_mux_test_base");
            this.name = name;
        endfunction

        function void set_env(bready_mux_env env);
            this.env = env;
        endfunction

        task send(bready_mux_scenario scen);
            env.run_scenario(scen);
        endtask
    endclass

endpackage

