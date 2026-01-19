library verilog;
use verilog.vl_types.all;
entity Write_Addr_Channel_Dec_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Address_width   : integer := 32;
        Base_Addr_Width : integer := 2;
        Slaves_Num      : integer := 2;
        Slaves_ID_Size  : vl_notype;
        S00_Aw_len      : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Address_width : constant is 1;
    attribute mti_svvh_generic_type of Base_Addr_Width : constant is 1;
    attribute mti_svvh_generic_type of Slaves_Num : constant is 1;
    attribute mti_svvh_generic_type of Slaves_ID_Size : constant is 3;
    attribute mti_svvh_generic_type of S00_Aw_len : constant is 1;
end Write_Addr_Channel_Dec_tb;
