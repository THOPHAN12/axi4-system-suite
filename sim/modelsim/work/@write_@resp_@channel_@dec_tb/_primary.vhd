library verilog;
use verilog.vl_types.all;
entity Write_Resp_Channel_Dec_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Num_Of_Masters  : integer := 2;
        Master_ID_Width : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Num_Of_Masters : constant is 1;
    attribute mti_svvh_generic_type of Master_ID_Width : constant is 3;
end Write_Resp_Channel_Dec_tb;
