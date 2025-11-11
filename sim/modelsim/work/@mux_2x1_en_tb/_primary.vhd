library verilog;
use verilog.vl_types.all;
entity Mux_2x1_en_tb is
    generic(
        WIDTH_0         : integer := 0;
        WIDTH_31        : integer := 31
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH_0 : constant is 1;
    attribute mti_svvh_generic_type of WIDTH_31 : constant is 1;
end Mux_2x1_en_tb;
