library verilog;
use verilog.vl_types.all;
entity Resp_Queue_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Masters_Num     : integer := 2;
        ID_Size         : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Masters_Num : constant is 1;
    attribute mti_svvh_generic_type of ID_Size : constant is 3;
end Resp_Queue_tb;
