`timescale 1ns/1ps

package wd_handshake_tb_pkg;

    class wd_handshake_scoreboard;
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

    class wd_handshake_env;
        string name;
        virtual wd_handshake_if vif;
        wd_handshake_scoreboard scoreboard;

        function new(string name,
                     virtual wd_handshake_if vif);
            this.name = name;
            this.vif  = vif;
            scoreboard = new({name,"::scoreboard"});
            init_signals();
        endfunction

        task init_signals();
            vif.reset_n     = 1'b0;
            vif.valid       = 1'b0;
            vif.ready       = 1'b0;
            vif.last        = 1'b0;
            vif.handshake_en= 1'b0;
        endtask

        task apply_reset(int cycles = 2);
            vif.reset_n = 1'b0;
            repeat (cycles) @(posedge vif.clk);
            vif.reset_n = 1'b1;
            @(posedge vif.clk);
        endtask

        task pulse_enable();
            vif.handshake_en = 1'b1;
            @(posedge vif.clk);
            vif.handshake_en = 1'b0;
        endtask

        task drive_valid_ready_last(bit valid, bit ready, bit last);
            vif.valid = valid;
            vif.ready = ready;
            vif.last  = last;
            @(posedge vif.clk);
        endtask

        task idle();
            vif.valid = 1'b0;
            vif.ready = 1'b0;
            vif.last  = 1'b0;
            @(posedge vif.clk);
        endtask

        function bit get_done();
            return vif.handshake_done;
        endfunction

        function wd_handshake_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class wd_handshake_test_base;
        string name;
        wd_handshake_env env;

        function new(string name = "wd_handshake_test_base");
            this.name = name;
        endfunction

        function void set_env(wd_handshake_env env);
            this.env = env;
        endfunction

        task check_done(string msg, bit expected);
            env.get_scoreboard().check(msg, expected, env.get_done());
        endtask
    endclass

endpackage

