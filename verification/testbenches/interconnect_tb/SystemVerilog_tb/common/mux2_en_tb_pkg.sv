`timescale 1ns/1ps

package mux2_en_tb_pkg;

    typedef class mux2_en_scenario;

    class mux2_en_scenario;
        string name;
        mux2_en_if::data_t in0;
        mux2_en_if::data_t in1;
        bit sel;
        bit enable;
        mux2_en_if::data_t expected;

        function new(string name = "mux2_en_scenario");
            this.name = name;
            expected = '0;
        endfunction
    endclass

    class mux2_en_env;
        string name;
        mux2_en_if vif;
        int pass_count;
        int fail_count;

        function new(string name, mux2_en_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run(mux2_en_scenario scen);
            vif.in0    = scen.in0;
            vif.in1    = scen.in1;
            vif.sel    = scen.sel;
            vif.enable = scen.enable;
            #1;
            mux2_en_if::data_t expected = scen.enable ? (scen.sel ? scen.in1 : scen.in0) : '0;
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

    class mux2_en_test_base;
        string name;
        mux2_en_env env;

        function new(string name = "mux2_en_test_base");
            this.name = name;
        endfunction

        function void set_env(mux2_en_env env);
            this.env = env;
        endfunction

        task send(mux2_en_scenario scen);
            env.run(scen);
        endtask
    endclass

endpackage

