`timescale 1ns/1ps

package handshake_tb_pkg;

    class handshake_scoreboard;
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

    class handshake_env;
        string name;
        virtual handshake_if vif;
        handshake_scoreboard scoreboard;

        function new(string name,
                     virtual handshake_if vif);
            this.name = name;
            this.vif  = vif;
            scoreboard = new({name,"::scoreboard"});
            init_signals();
        endfunction

        task init_signals();
            vif.reset_n         = 1'b0;
            vif.valid           = 1'b0;
            vif.ready           = 1'b0;
            vif.channel_request = 1'b0;
        endtask

        task apply_reset(int cycles = 2);
            vif.reset_n = 1'b0;
            repeat (cycles) @(posedge vif.clk);
            vif.reset_n = 1'b1;
            @(posedge vif.clk);
        endtask

        task pulse_channel_request();
            vif.channel_request = 1'b1;
            @(posedge vif.clk);
            vif.channel_request = 1'b0;
        endtask

        task drive_valid_ready(bit valid, bit ready);
            vif.valid = valid;
            vif.ready = ready;
            @(posedge vif.clk);
        endtask

        task idle();
            vif.valid = 1'b0;
            vif.ready = 1'b0;
            @(posedge vif.clk);
        endtask

        function bit get_done();
            return vif.handshake_done;
        endfunction

        function handshake_scoreboard get_scoreboard();
            return scoreboard;
        endfunction
    endclass

    class handshake_test_base;
        string name;
        handshake_env env;

        function new(string name = "handshake_test_base");
            this.name = name;
        endfunction

        function void set_env(handshake_env env);
            this.env = env;
        endfunction

        task check_done(string msg, bit expected);
            env.get_scoreboard().check(msg, expected, env.get_done());
        endtask
    endclass

endpackage

