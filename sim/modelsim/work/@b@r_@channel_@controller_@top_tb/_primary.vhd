library verilog;
use verilog.vl_types.all;
entity BR_Channel_Controller_Top_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Num_Of_Masters  : integer := 2;
        Num_Of_Slaves   : integer := 2;
        Master_ID_Width : vl_notype;
        AXI4_Aw_len     : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Num_Of_Masters : constant is 1;
    attribute mti_svvh_generic_type of Num_Of_Slaves : constant is 1;
    attribute mti_svvh_generic_type of Master_ID_Width : constant is 3;
    attribute mti_svvh_generic_type of AXI4_Aw_len : constant is 1;
end BR_Channel_Controller_Top_tb;
