`timescale 1ns/1ps

package edge_det_tb_pkg;

    class edge_det_scoreboard;
        string name;
        int pass_count;
        int fail_count;

        function new(string name);
            this.name = name;
        endfunction

        function void check(string msg, bit expected, bit actual);
            if (actual !== expected) begin
                $error("[%s] %s expected=%0b got=%0b", name, msg, expected, actual);
                fail_count++;
            end else begin
                $display("[%s] PASS: %s", name, msg);
                pass_count++;
            end
        endfunction

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] PASS=%0d FAIL=%0d", name, pass_count, fail_count);
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class edge_det_env;
        string name;
        virtual edge_det_if vif;
        edge_det_scoreboard scoreboard;

        function new(string name,
                     virtual edge_det_if vif);
            this.name = name;
            this.vif  = vif;
            scoreboard = new({name,"::scoreboard"});
            init_signals();
        endfunction

        task init_signals();
            vif.reset_n     = 1'b0;
            vif.test_signal = 1'b0;
        endtask

        task apply_reset(int cycles = 2);
            vif.reset_n = 1'b0;
            repeat (cycles) @(posedge vif.clk);
            vif.reset_n = 1'b1;
            @(posedge vif.clk);
        endtask

        task set_signal(bit value);
            vif.test_signal = value;
        endtask

        task wait_and_check(string msg = "",
                            bit check_rise = 0, bit rise_val = 0,
                            bit check_fall = 0, bit fall_val = 0);
            @(posedge vif.clk);
            if (check_rise)
                scoreboard.check({msg," (rise)"}, rise_val, vif.rising_pulse);
            if (check_fall)
                scoreboard.check({msg," (fall)"}, fall_val, vif.falling_pulse);
        endtask

        task hold_cycles(int cycles);
            repeat (cycles) @(posedge vif.clk);
        endtask

        function edge_det_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class edge_det_test_base;
        string name;
        edge_det_env env;

        function new(string name = "edge_det_test_base");
            this.name = name;
        endfunction

        function void set_env(edge_det_env env);
            this.env = env;
        endfunction
    endclass

endpackage

