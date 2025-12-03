`timescale 1ns/1ps

package demux_en_tb_pkg;

    typedef class demux_en_scenario;

    class demux_en_scenario;
        string name;
        demux_en_if::data_t data;
        bit select;
        bit enable;

        function new(string name = "demux_en_scenario");
            this.name = name;
            data = '0;
            select = 0;
            enable = 1;
        endfunction
    endclass

    class demux_en_env;
        string name;
        demux_en_if vif;
        int pass_count;
        int fail_count;

        function new(string name, demux_en_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run(demux_en_scenario scen);
            vif.select  = scen.select;
            vif.enable  = scen.enable;
            vif.in_data = scen.data;
            #1;
            demux_en_if::data_t exp_out0 = (scen.enable && scen.select == 0) ? scen.data : '0;
            demux_en_if::data_t exp_out1 = (scen.enable && scen.select == 1) ? scen.data : '0;
            if (vif.out0 !== exp_out0 || vif.out1 !== exp_out1) begin
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

    class demux_en_test_base;
        string name;
        demux_en_env env;

        function new(string name = "demux_en_test_base");
            this.name = name;
        endfunction

        function void set_env(demux_en_env env);
            this.env = env;
        endfunction

        task send(demux_en_scenario scen);
            env.run(scen);
        endtask
    endclass

endpackage

