`timescale 1ns/1ps

package write_addr_dec_tb_pkg;

    typedef class write_addr_dec_scenario;

    class write_addr_dec_scenario;
        string name;
        logic [31:0] addr;
        logic [0:0]  addr_id;
        bit          valid;
        int          expected_slave;

        function new(string name = "write_addr_dec_scenario");
            this.name = name;
            addr = '0;
            addr_id = '0;
            valid = 1'b1;
            expected_slave = 0;
        endfunction
    endclass

    class write_addr_dec_env;
        string name;
        write_addr_dec_if #(32,8,2,1) vif;
        int pass_count;
        int fail_count;

        function new(string name,
                     write_addr_dec_if #(32,8,2,1) vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task apply(write_addr_dec_scenario scen);
            vif.Master_AXI_awaddr    = scen.addr;
            vif.Master_AXI_awaddr_ID = scen.addr_id;
            vif.Master_AXI_awvalid   = scen.valid;
            #1;
            if (scen.valid) begin
                for (int s = 0; s < 2; s++) begin
                    bit expected = (s == scen.expected_slave);
                    if (vif.slave_awvalid[s] !== expected) begin
                        $error("[%s] Scenario %s: slave %0d valid mismatch (exp=%0b got=%0b)",
                               name, scen.name, s, expected, vif.slave_awvalid[s]);
                        fail_count++;
                        return;
                    end
                end
                pass_count++;
            end
            vif.Master_AXI_awvalid = 1'b0;
        endtask

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class write_addr_dec_test;
        string name;
        write_addr_dec_env env;

        function new(string name = "write_addr_dec_test");
            this.name = name;
        endfunction

        function void set_env(write_addr_dec_env env);
            this.env = env;
        endfunction

        task send(write_addr_dec_scenario scen);
            env.apply(scen);
        endtask
    endclass

endpackage

