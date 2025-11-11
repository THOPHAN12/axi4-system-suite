library verilog;
use verilog.vl_types.all;
entity AW_Channel_Controller_Top_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Masters_Num     : integer := 2;
        Slaves_ID_Size  : vl_notype;
        Address_width   : integer := 32;
        S00_Aw_len      : integer := 8;
        S01_Aw_len      : integer := 8;
        M00_Aw_len      : integer := 8;
        M01_Aw_len      : integer := 8;
        Num_Of_Slaves   : integer := 2
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Masters_Num : constant is 1;
    attribute mti_svvh_generic_type of Slaves_ID_Size : constant is 3;
    attribute mti_svvh_generic_type of Address_width : constant is 1;
    attribute mti_svvh_generic_type of S00_Aw_len : constant is 1;
    attribute mti_svvh_generic_type of S01_Aw_len : constant is 1;
    attribute mti_svvh_generic_type of M00_Aw_len : constant is 1;
    attribute mti_svvh_generic_type of M01_Aw_len : constant is 1;
    attribute mti_svvh_generic_type of Num_Of_Slaves : constant is 1;
end AW_Channel_Controller_Top_tb;
