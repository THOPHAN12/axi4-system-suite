library verilog;
use verilog.vl_types.all;
entity AW_MUX_2_1_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Address_width   : integer := 32;
        Aw_len          : integer := 8
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Address_width : constant is 1;
    attribute mti_svvh_generic_type of Aw_len : constant is 1;
end AW_MUX_2_1_tb;
