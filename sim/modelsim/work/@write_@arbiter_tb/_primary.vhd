library verilog;
use verilog.vl_types.all;
entity Write_Arbiter_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Slaves_Num      : integer := 2;
        Slaves_ID_Size  : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Slaves_Num : constant is 1;
    attribute mti_svvh_generic_type of Slaves_ID_Size : constant is 3;
end Write_Arbiter_tb;
