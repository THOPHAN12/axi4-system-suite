library verilog;
use verilog.vl_types.all;
entity Mux_2x1_tb is
    generic(
        WIDTH_0         : integer := 0;
        WIDTH_32        : integer := 31;
        WIDTH_8         : integer := 7
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH_0 : constant is 1;
    attribute mti_svvh_generic_type of WIDTH_32 : constant is 1;
    attribute mti_svvh_generic_type of WIDTH_8 : constant is 1;
end Mux_2x1_tb;
