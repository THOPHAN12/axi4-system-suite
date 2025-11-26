`timescale 1ns/1ps

package mux2_tb_pkg;

    typedef class mux2_scenario;

    class mux2_scenario;
        string name;
        mux2_if::data_t in0;
        mux2_if::data_t in1;
        bit sel;

        function new(string name = "mux2_scenario");
            this.name = name;
        endfunction
    endclass

    class mux2_env;
        string name;
        mux2_if vif;
        int pass_count;
        int fail_count;

        function new(string name, mux2_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run(mux2_scenario scen);
            vif.in0 = scen.in0;
            vif.in1 = scen.in1;
            vif.sel = scen.sel;
            #1;
            mux2_if::data_t expected = scen.sel ? scen.in1 : scen.in0;
            if (vif.out !== expected) begin
                $error("[%s] Scenario %s mismatch exp=%h got=%h",
                       name, scen.name, expected, vif.out);
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

    class mux2_test_base;
        string name;
        mux2_env env;

        function new(string name = "mux2_test_base");
            this.name = name;
        endfunction

        function void set_env(mux2_env env);
            this.env = env;
        endfunction

        task send(mux2_scenario scen);
            env.run(scen);
        endtask
    endclass

endpackage

