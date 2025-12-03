`timescale 1ns/1ps

import axi_tb_pkg::*;

package write_arb_tb_pkg;

    localparam int NUM_REQ  = 2;
    localparam int ID_WIDTH = $clog2(NUM_REQ);

    typedef logic [NUM_REQ-1:0] req_t;
    typedef logic [NUM_REQ-1:0][3:0] qos_t;

    class write_arb_transaction;
        req_t  req;
        qos_t  qos;
        bit    token;
        bit    channel_granted;
        logic [ID_WIDTH-1:0] expected_slave;
        bit    expected_request;
        int    hold_cycles;
        bit    check_enable;

        function new();
            req              = '0;
            qos              = '{default:4'h0};
            token            = 1'b1;
            channel_granted  = 1'b1;
            expected_slave   = '0;
            expected_request = 1'b0;
            hold_cycles      = 1;
            check_enable     = 1'b1;
        endfunction
    endclass

    class write_arb_sample;
        logic [ID_WIDTH-1:0] selected_slave;
        bit                  channel_request;

        function new(logic [ID_WIDTH-1:0] sel = '0, bit req = 0);
            selected_slave  = sel;
            channel_request = req;
        endfunction
    endclass

    typedef struct packed {
        logic [ID_WIDTH-1:0] selected_slave;
        bit                  channel_request;
    } write_arb_expected_t;

    class write_arb_driver;
        string name;
        virtual write_arb_if vif;
        mailbox #(write_arb_transaction) txn_mbx;

        function new(string name,
                     virtual write_arb_if vif,
                     mailbox #(write_arb_transaction) txn_mbx);
            this.name    = name;
            this.vif     = vif;
            this.txn_mbx = txn_mbx;
        endfunction

        task run();
            write_arb_transaction txn;
            reset_signals();
            @(posedge vif.reset_n);
            forever begin
                txn_mbx.get(txn);
                if (txn == null) begin
                    reset_signals();
                    break;
                end
                drive(txn);
            end
        endtask

        protected task reset_signals();
            vif.cb.req             <= '0;
            vif.cb.qos             <= '{default:4'h0};
            vif.cb.token           <= 1'b1;
            vif.cb.channel_granted <= 1'b1;
        endtask

        protected task drive(write_arb_transaction txn);
            int cycles = (txn.hold_cycles <= 0) ? 1 : txn.hold_cycles;
            for (int i = 0; i < cycles; i++) begin
                @(vif.cb);
                vif.cb.req             <= txn.req;
                vif.cb.qos             <= txn.qos;
                vif.cb.token           <= txn.token;
                vif.cb.channel_granted <= txn.channel_granted;
            end
        endtask
    endclass

    class write_arb_monitor;
        string name;
        virtual write_arb_if vif;
        mailbox #(write_arb_sample) sample_mbx;
        bit stop_requested;

        function new(string name,
                     virtual write_arb_if vif,
                     mailbox #(write_arb_sample) sample_mbx);
            this.name       = name;
            this.vif        = vif;
            this.sample_mbx = sample_mbx;
        endfunction

        task run();
            stop_requested = 0;
            forever begin
                @(posedge vif.clk);
                if (!vif.reset_n) begin
                    continue;
                end
                if (stop_requested) begin
                    sample_mbx.put(null);
                    break;
                end
                write_arb_sample sample = new(vif.selected_slave, vif.channel_request);
                sample_mbx.put(sample);
            end
        endtask

        task stop();
            stop_requested = 1;
        endtask
    endclass

    class write_arb_scoreboard;
        string name;
        mailbox #(write_arb_sample) sample_mbx;
        write_arb_expected_t expected_queue[$];
        int pass_count;
        int fail_count;
        bit stop_requested;

        function new(string name = "write_arb_scoreboard",
                     mailbox #(write_arb_sample) sample_mbx = null);
            this.name       = name;
            this.sample_mbx = (sample_mbx == null) ? new() : sample_mbx;
            pass_count = 0;
            fail_count = 0;
            stop_requested = 0;
        endfunction

        task start();
            fork monitor_actual(); join_none;
        endtask

        task stop();
            stop_requested = 1;
            sample_mbx.put(null);
        endtask

        task monitor_actual();
            write_arb_sample sample;
            forever begin
                sample_mbx.get(sample);
                if (sample == null) begin
                    if (stop_requested) begin
                        if (expected_queue.size() != 0) begin
                            $warning("[%s] Exiting with %0d pending expectations",
                                     name, expected_queue.size());
                        end
                        break;
                    end
                    if (expected_queue.size() == 0) begin
                        break;
                    end
                    continue;
                end
                if (expected_queue.size() == 0) begin
                    $error("[%s] Unexpected activity sel=%0d req=%0b",
                           name, sample.selected_slave, sample.channel_request);
                    fail_count++;
                end else begin
                    write_arb_expected_t exp = expected_queue.pop_front();
                    if (exp.selected_slave !== sample.selected_slave ||
                        exp.channel_request !== sample.channel_request) begin
                        $error("[%s] Mismatch exp(sel=%0d, req=%0b) got(sel=%0d, req=%0b)",
                               name,
                               exp.selected_slave, exp.channel_request,
                               sample.selected_slave, sample.channel_request);
                        fail_count++;
                    end else begin
                        pass_count++;
                    end
                end
            end
        endtask

        function void expect(write_arb_transaction txn);
            if (!txn.check_enable) return;
            int cycles = (txn.hold_cycles <= 0) ? 1 : txn.hold_cycles;
            for (int i = 0; i < cycles; i++) begin
                write_arb_expected_t exp;
                exp.selected_slave  = txn.expected_slave;
                exp.channel_request = txn.expected_request;
                expected_queue.push_back(exp);
            end
        endfunction

        function void report();
            $display("--------------------------------------------------------");
            $display("[%s] pass=%0d fail=%0d pending=%0d",
                     name, pass_count, fail_count, expected_queue.size());
            $display("--------------------------------------------------------");
        endfunction
    endclass

    class write_arb_env;
        string name;
        write_arb_driver    driver;
        write_arb_monitor   monitor;
        write_arb_scoreboard scoreboard;
        mailbox #(write_arb_transaction) txn_mbx;
        mailbox #(write_arb_sample)      sample_mbx;
        virtual write_arb_if vif;

        function new(string name,
                     virtual write_arb_if vif);
            this.name = name;
            this.vif  = vif;
            txn_mbx    = new();
            sample_mbx = new();
            scoreboard = new({name, "::scoreboard"}, sample_mbx);
            driver     = new({name, "::driver"}, vif, txn_mbx);
            monitor    = new({name, "::monitor"}, vif, sample_mbx);
        endfunction

        task start();
            scoreboard.start();
            fork
                driver.run();
                monitor.run();
            join_none
        endtask

        task stop();
            txn_mbx.put(null);
            monitor.stop();
            scoreboard.stop();
        endtask

        function void send(write_arb_transaction txn);
            scoreboard.expect(txn);
            txn_mbx.put(txn);
        endfunction

        function write_arb_scoreboard get_scoreboard();
            return scoreboard;
        endfunction

        function void report();
            scoreboard.report();
        endfunction
    endclass

    class write_arb_test_base;
        string name;
        write_arb_env env;

        function new(string name = "write_arb_test_base");
            this.name = name;
        endfunction

        function void set_env(write_arb_env env);
            this.env = env;
        endfunction

        virtual task run();
            $display("[%s] No test defined", name);
        endtask

        protected task send_step(
            req_t req,
            bit channel_granted,
            logic [ID_WIDTH-1:0] expected_slave,
            bit expected_request,
            int hold_cycles = 1,
            qos_t qos = '{default:4'h0},
            bit token = 1'b1,
            bit check_enable = 1'b1
        );
            write_arb_transaction txn = new();
            txn.req              = req;
            txn.channel_granted  = channel_granted;
            txn.expected_slave   = expected_slave;
            txn.expected_request = expected_request;
            txn.hold_cycles      = hold_cycles;
            txn.qos              = qos;
            txn.token            = token;
            txn.check_enable     = check_enable;
            env.send(txn);
        endtask

        protected task wait_cycles(int cycles);
            send_step('0, 1'b1, '0, 1'b0, cycles, '{default:4'h0}, 1'b1, 1'b0);
        endtask
    endclass

endpackage

