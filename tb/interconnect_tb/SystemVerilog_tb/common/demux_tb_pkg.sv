`timescale 1ns/1ps

package demux_tb_pkg;

    typedef class demux_scenario;

    class demux_scenario #(parameter int DATA_W = 1);
        string name;
        bit select;
        logic [DATA_W-1:0] input_data;
        logic [DATA_W-1:0] out0;
        logic [DATA_W-1:0] out1;

        function new(string name = "demux_scenario");
            this.name = name;
            select = 0;
            input_data = '0;
            out0 = '0;
            out1 = '0;
        endfunction
    endclass

    class demux_checker #(parameter int DATA_W = 1);
        string name;
        demux_if #(DATA_W) vif;
        int pass_count;
        int fail_count;

        function new(string name, demux_if #(DATA_W) vif);
            this.name = name;
            this.vif  = vif;
        endfunction

        task run(demux_scenario #(DATA_W) scen);
            vif.Selection_Line = scen.select;
            vif.input_data     = scen.input_data;
            #1;
            if (vif.output_0 !== scen.out0 || vif.output_1 !== scen.out1) begin
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

    class demux_test_base #(parameter int DATA_W = 1);
        string name;
        demux_checker #(DATA_W) checker;

        function new(string name = "demux_test_base");
            this.name = name;
        endfunction

        function void set_checker(demux_checker #(DATA_W) checker);
            this.checker = checker;
        endfunction

        virtual task run();
            $display("[%s] No demux scenarios", name);
        endtask

        task send(demux_scenario #(DATA_W) scen);
            checker.run(scen);
        endtask
    endclass

endpackage

