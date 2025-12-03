`timescale 1ns/1ps

package write_resp_dec_tb_pkg;

    typedef class write_resp_dec_scenario;

    class write_resp_dec_scenario;
        string name;
        logic [0:0] sel_id;
        logic       sel_valid;
        logic [1:0] sel_resp;
        int         expected_master;

        function new(string name = "write_resp_dec_scenario");
            this.name = name;
            sel_id = '0;
            sel_valid = 1'b0;
            sel_resp = 2'b00;
            expected_master = 0;
        endfunction
    endclass

    class write_resp_dec_env;
        string name;
        write_resp_dec_if vif;
        int pass_count;
        int fail_count;

        function new(string name, write_resp_dec_if vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run_scenario(write_resp_dec_scenario scen);
            vif.Sel_Resp_ID   = scen.sel_id;
            vif.Sel_Valid     = scen.sel_valid;
            vif.Sel_Write_Resp= scen.sel_resp;
            #1;
            if (scen.sel_valid) begin
                for (int m = 0; m < vif.NUM_MASTERS; m++) begin
                    if (m == scen.expected_master) begin
                        if (!vif.bvalid[m] || vif.bresp[m] !== scen.sel_resp) begin
                            $error("[%s] Scenario %s mismatch at master %0d", name, scen.name, m);
                            fail_count++;
                            return;
                        end
                    end else if (vif.bvalid[m]) begin
                        $error("[%s] Scenario %s unexpected valid on master %0d", name, scen.name, m);
                        fail_count++;
                        return;
                    end
                end
                pass_count++;
            end
        endtask

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class write_resp_dec_test;
        string name;
        write_resp_dec_env env;

        function new(string name = "write_resp_dec_test");
            this.name = name;
        endfunction

        function void set_env(write_resp_dec_env env);
            this.env = env;
        endfunction

        task send(write_resp_dec_scenario scen);
            env.run_scenario(scen);
        endtask
    endclass

endpackage

