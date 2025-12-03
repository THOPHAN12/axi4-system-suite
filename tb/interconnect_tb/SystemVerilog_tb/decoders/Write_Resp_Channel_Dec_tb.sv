`timescale 1ns/1ps

import write_resp_dec_tb_pkg::*;

module Write_Resp_Channel_Dec_tb;

    write_resp_dec_if #(2, 1) dec_if();

    Write_Resp_Channel_Dec #(
        .Num_Of_Masters(2),
        .Master_ID_Width(1)
    ) dut (
        .Sel_Resp_ID   (dec_if.Sel_Resp_ID),
        .Sel_Valid     (dec_if.Sel_Valid),
        .Sel_Write_Resp(dec_if.Sel_Write_Resp),
        .S00_AXI_bvalid(dec_if.bvalid[0]),
        .S01_AXI_bvalid(dec_if.bvalid[1]),
        .S00_AXI_bresp (dec_if.bresp[0]),
        .S01_AXI_bresp (dec_if.bresp[1])
    );

    initial begin
        write_resp_dec_env env = new("write_resp_dec_env", dec_if);
        write_resp_dec_test test = new();
        test.set_env(env);

        write_resp_dec_scenario scen;

        scen = new("route_to_master0");
        scen.sel_id = 0;
        scen.sel_valid = 1;
        scen.sel_resp = 2'b00;
        scen.expected_master = 0;
        test.send(scen);

        scen = new("route_to_master1");
        scen.sel_id = 1;
        scen.sel_valid = 1;
        scen.sel_resp = 2'b01;
        scen.expected_master = 1;
        test.send(scen);

        env.report();
        $finish;
    end

endmodule

